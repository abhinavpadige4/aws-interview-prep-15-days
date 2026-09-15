#!/bin/bash
# Day 3: VPC Creation Script
# This script creates a VPC with public and private subnets, internet gateway, NAT gateway, and security groups

set -euo pipefail

echo "=== VPC Creation Script ==="
echo "This script will create a VPC with public and private subnets, internet gateway, NAT gateway, and security groups"

# Check if AWS CLI is configured
if ! aws sts get-caller-identity &> /dev/null; then
    echo "Error: AWS CLI not configured. Please run 'aws configure' first."
    exit 1
fi

# Variables
VPC_NAME="interview-prep-vpc"
VPC_CIDR="10.0.0.0/16"
KEY_NAME="vpc-interview-key"
BASTION_SG_NAME="bastion-sg"
PRIVATE_SG_NAME="private-instance-sg"

echo "Using VPC name: $VPC_NAME"
echo "Using VPC CIDR: $VPC_CIDR"

# Create or use existing key pair
echo "Checking for key pair: $KEY_NAME"
if ! aws ec2 describe-key-pairs --key-names "$KEY_NAME" &> /dev/null; then
    echo "Creating new key pair: $KEY_NAME"
    aws ec2 create-key-pair --key-name "$KEY_NAME" --query 'KeyMaterial' --output text > "${KEY_NAME}.pem"
    chmod 400 "${KEY_NAME}.pem"
    echo "Key pair saved as ${KEY_NAME}.pem"
else
    echo "Using existing key pair: $KEY_NAME"
fi

# Create VPC
echo "Creating VPC..."
VPC_ID=$(aws ec2 create-vpc \
    --cidr-block "$VPC_CIDR" \
    --tag-specifications "ResourceType=vpc,Tags=[{Key=Name,Value=$VPC_NAME}]" \
    --query 'Vpc.VpcId' --output text)

if [ -z "$VPC_ID" ] || [ "$VPC_ID" = "None" ]; then
    echo "Error: Failed to create VPC"
    exit 1
fi
echo "✓ Created VPC: $VPC_ID"

# Enable DNS hostnames and support
echo "Enabling DNS hostnames and support..."
aws ec2 modify-vpc-attribute --vpc-id "$VPC_ID" --enable-dns-hostnames
aws ec2 modify-vpc-attribute --vpc-id "$VPC_ID" --enable-dns-support
echo "✓ DNS hostnames and support enabled"

# Create Internet Gateway
echo "Creating Internet Gateway..."
IGW_ID=$(aws ec2 create-internet-gateway \
    --query 'InternetGateway.InternetGatewayId' --output text)

aws ec2 attach-internet-gateway --internet-gateway-id "$IGW_ID" --vpc-id "$VPC_ID"
echo "✓ Created and attached Internet Gateway: $IGW_ID"

# Get Availability Zones
echo "Getting Availability Zones..."
AZ1=$(aws ec2 describe-availability-zones --query 'AvailabilityZones[0].ZoneName' --output text)
AZ2=$(aws ec2 describe-availability-zones --query 'AvailabilityZones[1].ZoneName' --output text)

if [ -z "$AZ1" ] || [ -z "$AZ2" ]; then
    echo "Error: Could not retrieve Availability Zones"
    exit 1
fi
echo "Using AZs: $AZ1 and $AZ2"

# Create Subnets
echo "Creating subnets..."

# Public Subnet 1
PUBLIC_SUBNET_ID=$(aws ec2 create-subnet \
    --vpc-id "$VPC_ID" \
    --cidr-block "10.0.1.0/24" \
    --availability-zone "$AZ1" \
    --tag-specifications "ResourceType=subnet,Tags=[{Key=Name,Value=public-subnet-1}]" \
    --query 'Subnet.SubnetId' --output text)

# Private Subnet 1
PRIVATE_SUBNET_ID=$(aws ec2 create-subnet \
    --vpc-id "$VPC_ID" \
    --cidr-block "10.0.2.0/24" \
    --availability-zone "$AZ1" \
    --tag-specifications "ResourceType=subnet,Tags=[{Key=Name,Value=private-subnet-1}]" \
    --query 'Subnet.SubnetId' --output text)

# Public Subnet 2 (for HA)
PUBLIC_SUBNET_ID_2=$(aws ec2 create-subnet \
    --vpc-id "$VPC_ID" \
    --cidr-block "10.0.3.0/24" \
    --availability-zone "$AZ2" \
    --tag-specifications "ResourceType=subnet,Tags=[{Key=Name,Value=public-subnet-2}]" \
    --query 'Subnet.SubnetId' --output text)

# Private Subnet 2 (for HA)
PRIVATE_SUBNET_ID_2=$(aws ec2 create-subnet \
    --vpc-id "$VPC_ID" \
    --cidr-block "10.0.4.0/24" \
    --availability-zone "$AZ2" \
    --tag-specifications "ResourceType=subnet,Tags=[{Key=Name,Value=private-subnet-2}]" \
    --query 'Subnet.SubnetId' --output text)

echo "✓ Created subnets:"
echo "  Public Subnet 1: $PUBLIC_SUBNET_ID ($AZ1)"
echo "  Private Subnet 1: $PRIVATE_SUBNET_ID ($AZ1)"
echo "  Public Subnet 2: $PUBLIC_SUBNET_ID_2 ($AZ2)"
echo "  Private Subnet 2: $PRIVATE_SUBNET_ID_2 ($AZ2)"

# Create Route Tables
echo "Creating route tables..."

# Get main route table
MAIN_ROUTE_TABLE_ID=$(aws ec2 describe-route-tables \
    --filters "Name=vpc-id,Values=$VPC_ID" "Name=association.main,Values=true" \
    --query 'RouteTables[0].RouteTableId' --output text)

# Create custom route table for public subnets
PUBLIC_ROUTE_TABLE_ID=$(aws ec2 create-route-table \
    --vpc-id "$VPC_ID" \
    --query 'RouteTable.RouteTableId' --output text)

echo "✓ Created route tables:"
echo "  Main Route Table: $MAIN_ROUTE_TABLE_ID"
echo "  Public Route Table: $PUBLIC_ROUTE_TABLE_ID"

# Configure Routes
echo "Configuring routes..."

# Add route to Internet Gateway in public route table
aws ec2 create-route \
    --route-table-id "$PUBLIC_ROUTE_TABLE_ID" \
    --destination-cidr-block "0.0.0.0/0" \
    --gateway-id "$IGW_ID"

echo "✓ Added route to Internet Gateway in public route table"

# Associate public subnets with public route table
aws ec2 associate-route-table \
    --route-table-id "$PUBLIC_ROUTE_TABLE_ID" \
    --subnet-id "$PUBLIC_SUBNET_ID"

aws ec2 associate-route-table \
    --route-table-id "$PUBLIC_ROUTE_TABLE_ID" \
    --subnet-id "$PUBLIC_SUBNET_ID_2"

echo "✓ Associated public subnets with public route table"

# Create NAT Gateway
echo "Creating NAT Gateway..."

# Allocate Elastic IP for NAT gateway
EIP_ALLOC_ID=$(aws ec2 allocate-address \
    --query 'AllocationId' --output text)

# Create NAT gateway in first public subnet
NAT_GW_ID=$(aws ec2 create-nat-gateway \
    --subnet-id "$PUBLIC_SUBNET_ID" \
    --allocation-id "$EIP_ALLOC_ID" \
    --query 'NatGateway.NatGatewayId' --output text)

echo "✓ Created NAT Gateway: $NAT_GW_ID with EIP: $EIP_ALLOC_ID"

# Wait for NAT gateway to be available
echo "Waiting for NAT gateway to become available..."
aws ec2 wait nat-gateway-available --nat-gateway-ids "$NAT_GW_ID"
echo "✓ NAT gateway is now available"

# Add route to NAT gateway in main route table (for private subnets)
aws ec2 create-route \
    --route-table-id "$MAIN_ROUTE_TABLE_ID" \
    --destination-cidr-block "0.0.0.0/0" \
    --nat-gateway-id "$NAT_GW_ID"

echo "✓ Added route to NAT gateway in main route table"

# Create Security Groups
echo "Creating security groups..."

# Security group for bastion host
BASTION_SG_ID=$(aws ec2 create-security-group \
    --group-name "$BASTION_SG_NAME" \
    --description "Security group for bastion host" \
    --vpc-id "$VPC_ID" \
    --query 'GroupId' --output text)

# Security group for private instance
PRIVATE_SG_ID=$(aws ec2 create-security-group \
    --group-name "$PRIVATE_SG_NAME" \
    --description "Security group for private instance" \
    --vpc-id "$VPC_ID" \
    --query 'GroupId' --output text)

echo "✓ Created security groups:"
echo "  Bastion SG: $BASTION_SG_ID"
echo "  Private Instance SG: $PRIVATE_SG_ID"

# Configure bastion security group
MY_IP=$(curl -s http://checkip.amazonaws.com)
aws ec2 authorize-security-group-ingress \
    --group-id "$BASTION_SG_ID" \
    --protocol tcp --port 22 --cidr "${MY_IP}/32"

echo "✓ Added SSH access to bastion security group from your IP ($MY_IP/32)"

# Configure private instance security group
# Allow SSH from bastion security group
aws ec2 authorize-security-group-ingress \
    --group-id "$PRIVATE_SG_ID" \
    --protocol tcp --port 22 --source-group "$BASTION_SG_ID"

# Allow HTTP/HTTPS from anywhere (for web server testing)
aws ec2 authorize-security-group-ingress \
    --group-id "$PRIVATE_SG_ID" \
    --protocol tcp --port 80 --cidr 0.0.0.0/0

aws ec2 authorize-security-group-ingress \
    --group-id "$PRIVATE_SG_ID" \
    --protocol tcp --port 443 --cidr 0.0.0.0/0

echo "✓ Configured private instance security group:"
echo "  - SSH from bastion SG only"
echo "  - HTTP/HTTPS from anywhere"

# Output summary
echo ""
echo "=== VPC CREATION COMPLETE ==="
echo "VPC ID: $VPC_ID"
echo "Internet Gateway: $IGW_ID"
echo "NAT Gateway: $NAT_GW_ID"
echo "Elastic IP Allocation ID: $EIP_ALLOC_ID"
echo ""
echo "Subnets:"
echo "  Public Subnet 1: $PUBLIC_SUBNET_ID ($AZ1)"
echo "  Private Subnet 1: $PRIVATE_SUBNET_ID ($AZ1)"
echo "  Public Subnet 2: $PUBLIC_SUBNET_ID_2 ($AZ2)"
echo "  Private Subnet 2: $PRIVATE_SUBNET_ID_2 ($AZ2)"
echo ""
echo "Route Tables:"
echo "  Main (Private): $MAIN_ROUTE_TABLE_ID"
echo "  Public: $PUBLIC_ROUTE_TABLE_ID"
echo ""
echo "Security Groups:"
echo "  Bastion: $BASTION_SG_ID"
echo "  Private Instance: $PRIVATE_SG_ID"
echo ""
echo "Key Pair: ${KEY_NAME}.pem"
echo ""
echo "Next Steps:"
echo "1. Launch EC2 instances:"
echo "   - Bastion host in public subnet"
echo "   - Private instance in private subnet"
echo "2. Configure instances with web servers"
echo "3. Test connectivity via SSH tunnel through bastion host"
echo ""
echo "To cleanup when done:"
echo "./cleanup-vpc.sh"