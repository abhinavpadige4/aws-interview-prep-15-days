#!/bin/bash
# Day 3: VPC Verification Script
# This script verifies that the VPC is properly configured with public/private subnets, IGW, NAT gateway, and security groups

set -euo pipefail

echo "=== VPC Verification ==="

# Check if VPC ID is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <vpc-id>"
    echo "Example: $0 vpc-0123456789abcdef0"
    exit 1
fi

VPC_ID=$1
REGION=$(aws configure get region)
if [ -z "$REGION" ]; then
    REGION="us-east-1"  # Default region
fi

echo "Verifying VPC: $VPC_ID"
echo "Region: $REGION"
echo ""

# Check if VPC exists
echo "1. Checking if VPC exists..."
if aws ec2 describe-vpcs --vpc-ids "$VPC_ID" &> /dev/null; then
    # Get VPC details
    VPC_CIDR=$(aws ec2 describe-vpcs --vpc-ids "$VPC_ID" --query 'Vpcs[0].CidrBlock' --output text)
    VPC_STATE=$(aws ec2 describe-vpcs --vpc-ids "$VPC_ID" --query 'Vpcs[0].State' --output text)
    VPC_DNS_HOSTNAMES=$(aws ec2 describe-vpcs --vpc-ids "$VPC_ID" --query 'Vpcs[0].EnableDnsHostnames' --output text)
    VPC_DNS_SUPPORT=$(aws ec2 describe-vpcs --vpc-ids "$VPC_ID" --query 'Vpcs[0].EnableDnsSupport' --output text)
    
    echo "✓ VPC exists"
    echo "  CIDR Block: $VPC_CIDR"
    echo "  State: $VPC_STATE"
    echo "  DNS Hostnames: $VPC_DNS_HOSTNAMES"
    echo "  DNS Support: $VPC_DNS_SUPPORT"
else
    echo "✗ VPC does not exist or access denied"
    exit 1
fi

echo ""

# Check Internet Gateway
echo "2. Checking Internet Gateway..."
IGW_IDS=$(aws ec2 describe-internet-gateways \
    --filters "Name=attachment.vpc-id,Values=$VPC_ID" \
    --query 'InternetGateways[].InternetGatewayId' --output text)

if [ -n "$IGW_IDS" ] && [ "$IGW_IDS" != "None" ]; then
    echo "✓ Internet Gateway attached to VPC"
    for IGW_ID in $IGW_IDS; do
        echo "  IGW ID: $IGW_ID"
    done
else
    echo "✗ No Internet Gateway found attached to VPC"
fi

echo ""

# Check Subnets
echo "3. Checking Subnets..."
SUBNETS=$(aws ec2 describe-subnets \
    --filters "Name=vpc-id,Values=$VPC_ID" \
    --query 'Subnets[].SubnetId' --output text)

if [ -n "$SUBNETS" ] && [ "$SUBNETS" != "None" ]; then
    SUBNET_COUNT=$(echo "$SUBNETS" | wc -w)
    echo "✓ Found $SUBNET_COUNT subnet(s)"
    
    # Check each subnet
    for SUBNET_ID in $SUBNETS; do
        SUBNET_CIDR=$(aws ec2 describe-subnets --subnet-ids "$SUBNET_ID" --query 'Subnets[0].CidrBlock' --output text)
        SUBNET_AZ=$(aws ec2 describe-subnets --subnet-ids "$SUBNET_ID" --query 'Subnets[0].AvailabilityZone' --output text)
        SUBNET_STATE=$(aws ec2 describe-subnets --subnet-ids "$SUBNET_ID" --query 'Subnets[0].State' --output text)
        
        # Check if public or private by looking for route to IGW
        ROUTE_TABLE_IDS=$(aws ec2 describe-route-tables \
            --filters "Name=association.subnet-id,Values=$SUBNET_ID" \
            --query 'RouteTables[].RouteTableId' --output text)
        
        IS_PUBLIC=false
        for RT_ID in $ROUTE_TABLE_IDS; do
            IGW_ROUTE=$(aws ec2 describe-route-tables \
                --route-table-ids "$RT_ID" \
                --query 'RouteTables[0].Routes[?DestinationCidrBlock==`0.0.0.0/0` && GatewayId!=`null`].GatewayId' --output text)
            if [ -n "$IGW_ROUTE" ] && [ "$IGW_ROUTE" != "None" ]; then
                IS_PUBLIC=true
                break
            fi
        done
        
        TYPE="Public" if [ "$IS_PUBLIC" = true ]; then TYPE="Public"; else TYPE="Private"; fi
        echo "  Subnet: $SUBNET_ID"
        echo "    CIDR: $SUBNET_CIDR"
        echo "    AZ: $SUBNET_AZ"
        echo "    State: $SUBNET_STATE"
        echo "    Type: $TYPE"
    done
else
    echo "✗ No subnets found in VPC"
fi

echo ""

# Check Route Tables
echo "4. Checking Route Tables..."
ROUTE_TABLES=$(aws ec2 describe-route-tables \
    --filters "Name=vpc-id,Values=$VPC_ID" \
    --query 'RouteTables[].RouteTableId' --output text)

if [ -n "$ROUTE_TABLES" ] && [ "$ROUTE_TABLES" != "None" ]; then
    RT_COUNT=$(echo "$ROUTE_TABLES" | wc -w)
    echo "✓ Found $RT_COUNT route table(s)"
    
    for RT_ID in $ROUTE_TABLES; do
        RT_ASSOCIATIONS=$(aws ec2 describe-route-tables \
            --route-table-ids "$RT_ID" \
            --query 'RouteTables[0].Associations[].SubnetId' --output text)
        
        RT_ROUTES=$(aws ec2 describe-route-tables \
            --route-table-ids "$RT_ID" \
            --query 'RouteTables[0].Routes[]' --output text)
        
        echo "  Route Table: $RT_ID"
        echo "    Associated Subnets: $RT_ASSOCIATIONS"
        
        # Check for key routes
        IGW_ROUTE=$(aws ec2 describe-route-tables \
            --route-table-ids "$RT_ID" \
            --query 'RouteTables[0].Routes[?DestinationCidrBlock==`0.0.0.0/0` && GatewayId!=`null`].GatewayId' --output text)
        NAT_ROUTE=$(aws ec2 describe-route-tables \
            --route-table-ids "$RT_ID" \
            --query 'RouteTables[0].Routes[?DestinationCidrBlock==`0.0.0.0/0` && NatGatewayId!=`null`].NatGatewayId' --output text)
        
        if [ -n "$IGW_ROUTE" ] && [ "$IGW_ROUTE" != "None" ]; then
            echo "    → Has route to Internet Gateway: $IGW_ROUTE"
        fi
        
        if [ -n "$NAT_ROUTE" ] && [ "$NAT_ROUTE" != "None" ]; then
            echo "    → Has route to NAT Gateway: $NAT_ROUTE"
        fi
    done
else
    echo "✗ No route tables found in VPC"
fi

echo ""

# Check NAT Gateway
echo "5. Checking NAT Gateway..."
NAT_GWS=$(aws ec2 describe-nat-gateways \
    --filter "Name=vpc-id,Values=$VPC_ID" \
    --query 'NatGateways[].NatGatewayId' --output text)

if [ -n "$NAT_GWS" ] && [ "$NAT_GWS" != "None" ]; then
    NAT_COUNT=$(echo "$NAT_GWS" | wc -w)
    echo "✓ Found $NAT_COUNT NAT Gateway(s)"
    
    for NAT_GW_ID in $NAT_GWS; do
        NAT_STATE=$(aws ec2 describe-nat-gateways \
            --nat-gateway-ids "$NAT_GW_ID" \
            --query 'NatGateways[0].State' --output text)
        
        # Get associated EIP and subnet
        NAT_DETAILS=$(aws ec2 describe-nat-gateways \
            --nat-gateway-ids "$NAT_GW_ID" \
            --query 'NatGateways[0]' --output text)
        
        echo "  NAT Gateway: $NAT_GW_ID"
        echo "    State: $NAT_STATE"
        # Extract details from JSON (simplified)
        if echo "$NAT_DETAILS" | grep -q '"SubnetId"'; then
            SUBNET_ID=$(echo "$NAT_DETAILS" | grep -o '"SubnetId":"[^"]*"' | cut -d'"' -f4)
            echo "    Subnet: $SUBNET_ID"
        fi
        if echo "$NAT_DETAILS" | grep -q '"AllocationId"'; then
            ALLOC_ID=$(echo "$NAT_DETAILS" | grep -o '"AllocationId":"[^"]*"' | cut -d'"' -f4)
            echo "    Allocation ID: $ALLOC_ID"
        fi
    done
else
    echo "✗ No NAT Gateways found in VPC"
fi

echo ""

# Check Security Groups
echo "6. Checking Security Groups..."
SECURITY_GROUPS=$(aws ec2 describe-security-groups \
    --filters "Name=vpc-id,Values=$VPC_ID" \
    --query 'SecurityGroups[].GroupId' --output text)

if [ -n "$SECURITY_GROUPS" ] && [ "$SECURITY_GROUPS" != "None" ]; then
    SG_COUNT=$(echo "$SECURITY_GROUPS" | wc -w)
    echo "✓ Found $SG_COUNT security group(s)"
    
    for SG_ID in $SECURITY_GROUPS; do
        SG_NAME=$(aws ec2 describe-security-groups \
            --group-ids "$SG_ID" \
            --query 'SecurityGroups[0].GroupName' --output text)
        SG_DESC=$(aws ec2 describe-security-groups \
            --group-ids "$SG_ID" \
            --query 'SecurityGroups[0].Description' --output text)
        
        echo "  Security Group: $SG_ID"
        echo "    Name: $SG_NAME"
        echo "    Description: $SG_DESC"
        
        # Check for key rules
        SSH_RULE=$(aws ec2 describe-security-groups \
            --group-ids "$SG_ID" \
            --query 'SecurityGroups[0].IpPermissions[?FromPort==`22` && ToPort==`22` && IpProtocol==`tcp`]' --output text)
        if [ -n "$SSH_RULE" ] && [ "$SSH_RULE" != "None" ] && [ "$SSH_RULE" != "[]" ]; then
            echo "    → Has SSH rule"
        fi
        
        HTTP_RULE=$(aws ec2 describe-security-groups \
            --group-ids "$SG_ID" \
            --query 'SecurityGroups[0].IpPermissions[?FromPort==`80` && ToPort==`80` && IpProtocol==`tcp`]' --output text)
        if [ -n "$HTTP_RULE" ] && [ "$HTTP_RULE" != "None" ] && [ "$HTTP_RULE" != "[]" ]; then
            echo "    → Has HTTP rule"
        fi
        
        HTTPS_RULE=$(aws ec2 describe-security-groups \
            --group-ids "$SG_ID" \
            --query 'SecurityGroups[0].IpPermissions[?FromPort==`443` && ToPort==`443` && IpProtocol==`tcp`]' --output text)
        if [ -n "$HTTPS_RULE" ] && [ "$HTTPS_RULE" != "None" ] && [ "$HTTPS_RULE" != "[]" ]; then
            echo "    → Has HTTPS rule"
        fi
    done
else
    echo "✗ No security groups found in VPC"
fi

echo ""

# Check Key Pair
echo "7. Checking Key Pair..."
if aws ec2 describe-key-pairs --key-names "vpc-interview-key" &> /dev/null; then
    echo "✓ Key pair 'vpc-interview-key' exists"
else
    echo "✗ Key pair 'vpc-interview-key' not found"
fi

echo ""

# Summary and Next Steps
echo "=== VERIFICATION SUMMARY ==="
echo "If most checks show ✓, your VPC is properly configured!"
echo "For any ✗ marks, review the corresponding setup steps."
echo ""
echo "Key VPC Concepts to Review for Interview:"
echo "1. VPC Fundamentals: CIDR blocks, tenancy, DNS settings"
echo "2. Internet Gateway: Attachment, route table configuration"
echo "3. NAT Gateway: Purpose, placement in public subnet, EIP requirement"
echo "4. Subnetting: Public vs private, AZ distribution, CIDR planning"
echo "5. Route Tables: Main vs custom, associations, route propagation"
echo "6. Security Groups: Stateful filtering, referencing other SGs, least privilege"
echo "7. Network ACLs: Stateless filtering, rule evaluation order"
echo "8. Bastion Hosts: Secure access pattern for private instances"
echo "9. VPC Peering: Inter-VPC communication, limitations"
echo "10. VPC Endpoints: Private access to AWS services"
echo ""
echo "Next Steps for Interview Preparation:"
echo "1. Practice explaining each component and its purpose"
echo "2. Be ready to discuss high availability patterns (multi-AZ)"
echo "3. Understand cost implications of different design choices"
echo "4. Know how to troubleshoot common VPC connectivity issues"
echo "5. Be familiar with VPC limits and how to request increases"