#!/bin/bash
# Day 1: EC2 Launch Script
# This script launches a t2.micro EC2 instance with proper configuration

set -euo pipefail

echo "=== AWS EC2 Instance Launch Script ==="
echo "This script will launch a t2.micro EC2 instance for interview preparation"

# Check if AWS CLI is configured
if ! aws sts get-caller-identity &> /dev/null; then
    echo "Error: AWS CLI not configured. Please run 'aws configure' first."
    exit 1
fi

# Variables
KEY_NAME="ec2-interview-key"
INSTANCE_NAME="interview-prep-web-server"
INSTANCE_TYPE="t2.micro"

# Get default VPC
echo "Finding default VPC..."
VPC_ID=$(aws ec2 describe-vpcs --filters "Name=isDefault,Values=true" --query 'Vpcs[0].VpcId' --output text)
if [ -z "$VPC_ID" ] || [ "$VPC_ID" = "None" ]; then
    echo "Error: No default VPC found. Please specify a VPC ID."
    exit 1
fi
echo "Using VPC: $VPC_ID"

# Get first subnet in default VPC
echo "Finding subnet..."
SUBNET_ID=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID" --query 'Subnets[0].SubnetId' --output text)
if [ -z "$SUBNET_ID" ] || [ "$SUBNET_ID" = "None" ]; then
    echo "Error: No subnet found in VPC $VPC_ID"
    exit 1
fi
echo "Using subnet: $SUBNET_ID"

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

# Create security group
SECURITY_GROUP_NAME="web-server-sg"
echo "Checking for security group: $SECURITY_GROUP_NAME"
SECURITY_GROUP_ID=$(aws ec2 describe-security-groups \
    --filters "Name=group-name,Values=$SECURITY_GROUP_NAME" "Name=vpc-id,Values=$VPC_ID" \
    --query 'SecurityGroups[0].GroupId' --output text)

if [ -z "$SECURITY_GROUP_ID" ] || [ "$SECURITY_GROUP_ID" = "None" ]; then
    echo "Creating security group: $SECURITY_GROUP_NAME"
    SECURITY_GROUP_ID=$(aws ec2 create-security-group \
        --group-name "$SECURITY_GROUP_NAME" \
        --description "Security group for web server - SSH, HTTP, HTTPS" \
        --vpc-id "$VPC_ID" \
        --query 'GroupId' --output text)
    echo "Created security group: $SECURITY_GROUP_ID"
    
    # Add inbound rules
    echo "Adding inbound rules..."
    MY_IP=$(curl -s http://checkip.amazonaws.com)
    
    # SSH access
    aws ec2 authorize-security-group-ingress \
        --group-id "$SECURITY_GROUP_ID" \
        --protocol tcp --port 22 --cidr "${MY_IP}/32"
    
    # HTTP access
    aws ec2 authorize-security-group-ingress \
        --group-id "$SECURITY_GROUP_ID" \
        --protocol tcp --port 80 --cidr 0.0.0.0/0
    
    # HTTPS access
    aws ec2 authorize-security-group-ingress \
        --group-id "$SECURITY_GROUP_ID" \
        --protocol tcp --port 443 --cidr 0.0.0.0/0
    
    echo "Inbound rules added for SSH (22), HTTP (80), HTTPS (443)"
else
    echo "Using existing security group: $SECURITY_GROUP_ID"
fi

# Find Amazon Linux 2 AMI
echo "Finding Amazon Linux 2 AMI..."
AMI_ID=$(aws ec2 describe-images \
    --owners amazon \
    --filters "Name=name,Values=amzn2-ami-hvm-2.0.????????-x86_64-gp2" "Name=state,Values=available" \
    --query 'Images[0].ImageId' --output text)

if [ -z "$AMI_ID" ] || [ "$AMI_ID" = "None" ]; then
    echo "Error: Could not find Amazon Linux 2 AMI"
    exit 1
fi
echo "Using AMI: $AMI_ID"

# Launch instance
echo "Launching $INSTANCE_TYPE instance..."
INSTANCE_ID=$(aws ec2 run-instances \
    --image-id "$AMI_ID" \
    --instance-type "$INSTANCE_TYPE" \
    --key-name "$KEY_NAME" \
    --security-group-ids "$SECURITY_GROUP_ID" \
    --subnet-id "$SUBNET_ID" \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$INSTANCE_NAME}]" \
    --query 'Instances[0].InstanceId' --output text)

if [ -z "$INSTANCE_ID" ] || [ "$INSTANCE_ID" = "None" ]; then
    echo "Error: Failed to launch instance"
    exit 1
fi
echo "Launched instance: $INSTANCE_ID"

# Wait for instance to be running
echo "Waiting for instance to be running..."
aws ec2 wait instance-running --instance-ids "$INSTANCE_ID"
echo "Instance is now running!"

# Get public IP
echo "Getting public IP address..."
PUBLIC_IP=$(aws ec2 describe-instances \
    --instance-ids "$INSTANCE_ID" \
    --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)

if [ -z "$PUBLIC_IP" ] || [ "$PUBLIC_IP" = "None" ]; then
    echo "Warning: Could not retrieve public IP address"
    PUBLIC_IP="<check AWS console>"
fi

# Display results
echo ""
echo "=== LAUNCH COMPLETE ==="
echo "Instance ID: $INSTANCE_ID"
echo "Instance Type: $INSTANCE_TYPE"
echo "Public IP: $PUBLIC_IP"
echo "Key Pair: ${KEY_NAME}.pem"
echo "Security Group: $SECURITY_GROUP_ID"
echo ""
echo "To connect via SSH:"
echo "ssh -i \"${KEY_NAME}.pem\" ec2-user@$PUBLIC_IP"
echo ""
echo "To terminate instance when done:"
echo "aws ec2 terminate-instances --instance-ids $INSTANCE_ID"
echo ""
echo "Next steps:"
echo "1. Connect via SSH using the command above"
echo "2. Install and configure Apache web server"
echo "3. Test your web server at http://$PUBLIC_IP"