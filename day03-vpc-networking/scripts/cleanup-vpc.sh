#!/bin/bash
# Day 3: VPC Cleanup Script
# This script cleans up all resources created by the VPC creation script

set -euo pipefail

echo "=== VPC Cleanup Script ==="
echo "WARNING: This script will DELETE all VPC-related resources!"
echo "This includes: Instances, NAT Gateway, Internet Gateway, Subnets, Route Tables, Security Groups, and the VPC itself"
echo ""

# Ask for confirmation
read -p "Are you sure you want to delete all VPC resources? Type 'DELETE' to confirm: " CONFIRMATION
if [ "$CONFIRMATION" != "DELETE" ]; then
    echo "Cleanup cancelled."
    exit 0
fi

# Check if AWS CLI is configured
if ! aws sts get-caller-identity &> /dev/null; then
    echo "Error: AWS CLI not configured. Please run 'aws configure' first."
    exit 1
fi

# Variables - these should match the create-vpc.sh script
VPC_NAME="interview-prep-vpc"
KEY_NAME="vpc-interview-key"

echo "Starting cleanup process..."

# Find the VPC
echo "Finding VPC: $VPC_NAME"
VPC_ID=$(aws ec2 describe-vpcs \
    --filters "Name=tag:Name,Values=$VPC_NAME" \
    --query 'Vpcs[0].VpcId' --output text)

if [ -z "$VPC_ID" ] || [ "$VPC_ID" = "None" ]; then
    echo "VPC '$VPC_NAME' not found. Checking for any VPC with similar name..."
    VPC_ID=$(aws ec2 describe-vpcs \
        --query 'Vpcs[?Tags[?Key==`Name` && contains(Value, `interview-prep-vpc`)]].VpcId' --output text)
fi

if [ -z "$VPC_ID" ] || [ "$VPC_ID" = "None" ]; then
    echo "No matching VPC found. Nothing to cleanup."
    exit 0
fi

echo "Found VPC: $VPC_ID"

# Terminate EC2 instances in the VPC
echo "Terminating EC2 instances in VPC..."
INSTANCE_IDS=$(aws ec2 describe-instances \
    --filters "Name=vpc-id,Values=$VPC_ID" "Name=instance-state-name,Values=running,stopped,stopping,pending" \
    --query 'Reservations[].Instances[].InstanceId' --output text)

if [ -n "$INSTANCE_IDS" ] && [ "$INSTANCE_IDS" != "None" ]; then
    echo "Terminating instances: $INSTANCE_IDS"
    aws ec2 terminate-instances --instance-ids $INSTANCE_IDS
    echo "Waiting for instances to terminate..."
    aws ec2 wait instance-terminated --instance-ids $INSTANCE_IDS
    echo "✓ All instances terminated"
else
    echo "No running instances found in VPC"
fi

# Delete NAT Gateways
echo "Deleting NAT Gateways..."
NAT_GW_IDS=$(aws ec2 describe-nat-gateways \
    --filter "Name=vpc-id,Values=$VPC_ID" \
    --query 'NatGateways[].NatGatewayId' --output text)

if [ -n "$NAT_GW_IDS" ] && [ "$NAT_GW_IDS" != "None" ]; then
    for NAT_GW_ID in $NAT_GW_IDS; do
        echo "Deleting NAT Gateway: $NAT_GW_ID"
        # Get the allocation ID before deleting
        EIP_ALLOC_ID=$(aws ec2 describe-nat-gateways \
            --nat-gateway-ids "$NAT_GW_ID" \
            --query 'NatGateways[0].NatGatewayAddress[0].AllocationId' --output text)
        
        aws ec2 delete-nat-gateway --nat-gateway-id "$NAT_GW_ID"
        echo "Waiting for NAT gateway to delete..."
        aws ec2 wait nat-gateway-deleted --nat-gateway-ids "$NAT_GW_ID"
        
        # Release the Elastic IP
        if [ -n "$EIP_ALLOC_ID" ] && [ "$EIP_ALLOC_ID" != "None" ]; then
            echo "Releasing Elastic IP: $EIP_ALLOC_ID"
            aws ec2 release-address --allocation-id "$EIP_ALLOC_ID"
        fi
    done
    echo "✓ All NAT Gateways deleted and Elastic IPs released"
else
    echo "No NAT Gateways found in VPC"
fi

# Delete Internet Gateway
echo "Deleting Internet Gateway..."
IGW_IDS=$(aws ec2 describe-internet-gateways \
    --filters "Name=attachment.vpc-id,Values=$VPC_ID" \
    --query 'InternetGateways[].InternetGatewayId' --output text)

if [ -n "$IGW_IDS" ] && [ "$IGW_IDS" != "None" ]; then
    for IGW_ID in $IGW_IDS; do
        echo "Detaching and deleting Internet Gateway: $IGW_ID"
        aws ec2 detach-internet-gateway --internet-gateway-id "$IGW_ID" --vpc-id "$VPC_ID"
        aws ec2 delete-internet-gateway --internet-gateway-id "$IGW_ID"
    done
    echo "✓ Internet Gateway detached and deleted"
else
    echo "No Internet Gateway found attached to VPC"
fi

# Delete Subnets
echo "Deleting Subnets..."
SUBNET_IDS=$(aws ec2 describe-subnets \
    --filters "Name=vpc-id,Values=$VPC_ID" \
    --query 'Subnets[].SubnetId' --output text)

if [ -n "$SUBNET_IDS" ] && [ "$SUBNET_IDS" != "None" ]; then
    for SUBNET_ID in $SUBNET_IDS; do
        echo "Deleting Subnet: $SUBNET_ID"
        aws ec2 delete-subnet --subnet-id "$SUBNET_ID"
    done
    echo "✓ All subnets deleted"
else
    echo "No subnets found in VPC"
fi

# Delete Route Tables (except main)
echo "Deleting Custom Route Tables..."
MAIN_ROUTE_TABLE_ID=$(aws ec2 describe-route-tables \
    --filters "Name=vpc-id,Values=$VPC_ID" "Name=association.main,Values=true" \
    --query 'RouteTables[0].RouteTableId' --output text)

CUSTOM_ROUTE_TABLE_IDS=$(aws ec2 describe-route-tables \
    --filters "Name=vpc-id,Values=$VPC_ID" \
    --query 'RouteTables[?AssociationCount==`0`].RouteTableId' --output text)

if [ -n "$CUSTOM_ROUTE_TABLE_IDS" ] && [ "$CUSTOM_ROUTE_TABLE_IDS" != "None" ]; then
    for RT_ID in $CUSTOM_ROUTE_TABLE_IDS; do
        # Skip if it's the main route table
        if [ "$RT_ID" != "$MAIN_ROUTE_TABLE_ID" ]; then
            echo "Deleting Custom Route Table: $RT_ID"
            aws ec2 delete-route-table --route-table-id "$RT_ID"
        fi
    done
    echo "✓ Custom route tables deleted"
else
    echo "No custom route tables found to delete"
fi

# Delete Security Groups (except default)
echo "Deleting Custom Security Groups..."
DEFAULT_SG_ID=$(aws ec2 describe-security-groups \
    --filters "Name=vpc-id,Values=$VPC_ID" "Name=group-name,Values=default" \
    --query 'SecurityGroups[0].GroupId' --output text)

CUSTOM_SG_IDS=$(aws ec2 describe-security-groups \
    --filters "Name=vpc-id,Values=$VPC_ID" \
    --query 'SecurityGroups[?GroupName!=`default`].GroupId' --output text)

if [ -n "$CUSTOM_SG_IDS" ] && [ "$CUSTOM_SG_IDS" != "None" ]; then
    for SG_ID in $CUSTOM_SG_IDS; do
        # Skip if it's the default security group
        if [ "$SG_ID" != "$DEFAULT_SG_ID" ]; then
            echo "Deleting Custom Security Group: $SG_ID"
            aws ec2 delete-security-group --group-id "$SG_ID"
        fi
    done
    echo "✓ Custom security groups deleted"
else
    echo "No custom security groups found to delete"
fi

# Delete the VPC
echo "Deleting VPC..."
echo "Deleting VPC: $VPC_ID"
aws ec2 delete-vpc --vpc-id "$VPC_ID"
echo "✓ VPC deleted"

# Delete key pair (optional - comment out if you want to keep it)
echo "Deleting key pair..."
if aws ec2 describe-key-pairs --key-names "$KEY_NAME" &> /dev/null; then
    echo "Deleting key pair: $KEY_NAME"
    aws ec2 delete-key-pair --key-name "$KEY_NAME"
    # Also remove the local key file
    rm -f "${KEY_NAME}.pem"
    echo "✓ Key pair deleted and local file removed"
else
    echo "Key pair not found or already deleted"
fi

echo ""
echo "=== CLEANUP COMPLETE ==="
echo "All VPC resources have been deleted:"
echo "  - VPC: $VPC_ID"
echo "  - Internet Gateway: Detached and deleted"
echo "  - NAT Gateways: Deleted and Elastic IPs released"
echo "  - Subnets: All deleted"
echo "  - Route Tables: Custom tables deleted"
echo "  - Security Groups: Custom tables deleted"
echo "  - EC2 Instances: Terminated"
echo "  - Key Pair: $KEY_NAME (deleted)"
echo ""
echo "You can now safely recreate the VPC using:"
echo "  ./create-vpc.sh"