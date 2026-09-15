# Day 3: VPC Hands-On Exercise

## Objective
Create a VPC with public and private subnets, internet gateway, NAT gateway, launch an EC2 instance in private subnet, and configure bastion host in public subnet.

## Prerequisites
- AWS Account with Free Tier eligibility
- AWS CLI installed and configured (`aws configure`)
- Key pair created in your AWS account
- Basic Linux/CLI knowledge

## Estimated Time: 60 minutes

## Exercise Steps

### Part 1: Preparation (10 minutes)

#### Step 1: Verify AWS CLI Configuration
```bash
aws sts get-caller-identity
```
Expected output should show your Account ID and User/Role ARN.

#### Step 2: Create Key Pair (if not already done)
```bash
aws ec2 create-key-pair --key-name vpc-interview-key --query 'KeyMaterial' --output text > vpc-interview-key.pem
chmod 400 vpc-interview-key.pem
```

### Part 2: Create VPC Infrastructure (25 minutes)

#### Step 3: Create VPC
```bash
VPC_ID=$(aws ec2 create-vpc \
    --cidr-block 10.0.0.0/16 \
    --tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=interview-prep-vpc}]' \
    --query 'Vpc.VpcId' \
    --output text)

echo "Created VPC: $VPC_ID"
```

#### Step 4: Enable DNS Hostnames and Support
```bash
aws ec2 modify-vpc-attribute --vpc-id $VPC_ID --enable-dns-hostnames
aws ec2 modify-vpc-attribute --vpc-id $VPC_ID --enable-dns-support
echo "Enabled DNS hostnames and support for VPC"
```

#### Step 5: Create Internet Gateway
```bash
IGW_ID=$(aws ec2 create-internet-gateway \
    --query 'InternetGateway.InternetGatewayId' \
    --output text)

aws ec2 attach-internet-gateway --internet-gateway-id $IGW_ID --vpc-id $VPC_ID
echo "Created and attached Internet Gateway: $IGW_ID"
```

#### Step 6: Create Subnets
```bash
# Get Availability Zones
AZ1=$(aws ec2 describe-availability-zones --query 'AvailabilityZones[0].ZoneName' --output text)
AZ2=$(aws ec2 describe-availability-zones --query 'AvailabilityZones[1].ZoneName' --output text)

echo "Using AZs: $AZ1 and $AZ2"

# Create Public Subnet
PUBLIC_SUBNET_ID=$(aws ec2 create-subnet \
    --vpc-id $VPC_ID \
    --cidr-block 10.0.1.0/24 \
    --availability-zone $AZ1 \
    --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=public-subnet-1}]' \
    --query 'Subnet.SubnetId' \
    --output text)

# Create Private Subnet
PRIVATE_SUBNET_ID=$(aws ec2 create-subnet \
    --vpc-id $VPC_ID \
    --cidr-block 10.0.2.0/24 \
    --availability-zone $AZ1 \
    --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=private-subnet-1}]' \
    --query 'Subnet.SubnetId' \
    --output text)

# Create Second Public Subnet (for HA)
PUBLIC_SUBNET_ID_2=$(aws ec2 create-subnet \
    --vpc-id $VPC_ID \
    --cidr-block 10.0.3.0/24 \
    --availability-zone $AZ2 \
    --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=public-subnet-2}]' \
    --query 'Subnet.SubnetId' \
    --output text)

# Create Second Private Subnet (for HA)
PRIVATE_SUBNET_ID_2=$(aws ec2 create-subnet \
    --vpc-id $VPC_ID \
    --cidr-block 10.0.4.0/24 \
    --availability-zone $AZ2 \
    --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=private-subnet-2}]' \
    --query 'Subnet.SubnetId' \
    --output text)

echo "Created subnets:"
echo "  Public Subnet 1: $PUBLIC_SUBNET_ID ($AZ1)"
echo "  Private Subnet 1: $PRIVATE_SUBNET_ID ($AZ1)"
echo "  Public Subnet 2: $PUBLIC_SUBNET_ID_2 ($AZ2)"
echo "  Private Subnet 2: $PRIVATE_SUBNET_ID_2 ($AZ2)"
```

#### Step 7: Create Route Tables
```bash
# Get main route table
MAIN_ROUTE_TABLE_ID=$(aws ec2 describe-route-tables \
    --filters "Name=vpc-id,Values=$VPC_ID" "Name=association.main,Values=true" \
    --query 'RouteTables[0].RouteTableId' \
    --output text)

# Create custom route table for public subnets
PUBLIC_ROUTE_TABLE_ID=$(aws ec2 create-route-table \
    --vpc-id $VPC_ID \
    --query 'RouteTable.RouteTableId' \
    --output text)

echo "Created route tables:"
echo "  Main Route Table: $MAIN_ROUTE_TABLE_ID"
echo "  Public Route Table: $PUBLIC_ROUTE_TABLE_ID"
```

#### Step 8: Configure Routes
```bash
# Add route to Internet Gateway in public route table
aws ec2 create-route \
    --route-table-id $PUBLIC_ROUTE_TABLE_ID \
    --destination-cidr-block 0.0.0.0/0 \
    --gateway-id $IGW_ID

echo "Added route to Internet Gateway in public route table"

# Associate public subnets with public route table
aws ec2 associate-route-table \
    --route-table-id $PUBLIC_ROUTE_TABLE_ID \
    --subnet-id $PUBLIC_SUBNET_ID

aws ec2 associate-route-table \
    --route-table-id $PUBLIC_ROUTE_TABLE_ID \
    --subnet-id $PUBLIC_SUBNET_ID_2

echo "Associated public subnets with public route table"

# Main route table remains for private subnets (will add NAT route later)
```

#### Step 9: Create NAT Gateway
```bash
# Allocate Elastic IP for NAT gateway
EIP_ALLOC_ID=$(aws ec2 allocate-address \
    --query 'AllocationId' \
    --output text)

# Create NAT gateway in first public subnet
NAT_GW_ID=$(aws ec2 create-nat-gateway \
    --subnet-id $PUBLIC_SUBNET_ID \
    --allocation-id $EIP_ALLOC_ID \
    --query 'NatGateway.NatGatewayId' \
    --output text)

echo "Created NAT Gateway: $NAT_GW_ID with EIP: $EIP_ALLOC_ID"

# Wait for NAT gateway to be available
echo "Waiting for NAT gateway to become available..."
aws ec2 wait nat-gateway-available --nat-gateway-ids $NAT_GW_ID
echo "NAT gateway is now available"

# Add route to NAT gateway in main route table (for private subnets)
aws ec2 create-route \
    --route-table-id $MAIN_ROUTE_TABLE_ID \
    --destination-cidr-block 0.0.0.0/0 \
    --nat-gateway-id $NAT_GW_ID

echo "Added route to NAT gateway in main route table"
```

#### Step 10: Create Security Groups
```bash
# Security group for bastion host
BASTION_SG_ID=$(aws ec2 create-security-group \
    --group-name bastion-sg \
    --description "Security group for bastion host" \
    --vpc-id $VPC_ID \
    --query 'GroupId' \
    --output text)

# Security group for private instance
PRIVATE_SG_ID=$(aws ec2 create-security-group \
    --group-name private-instance-sg \
    --description "Security group for private instance" \
    --vpc-id $VPC_ID \
    --query 'GroupId' \
    --output text)

echo "Created security groups:"
echo "  Bastion SG: $BASTION_SG_ID"
echo "  Private Instance SG: $PRIVATE_SG_ID"

# Configure bastion security group
aws ec2 authorize-security-group-ingress \
    --group-id $BASTION_SG_ID \
    --protocol tcp --port 22 --cidr $(curl -s http://checkip.amazonaws.com)/32

echo "Added SSH access to bastion security group from your IP"

# Configure private instance security group
# Allow SSH from bastion security group
aws ec2 authorize-security-group-ingress \
    --group-id $PRIVATE_SG_ID \
    --protocol tcp --port 22 --source-group $BASTION_SG_ID

# Allow HTTP/HTTPS from anywhere (for web server testing)
aws ec2 authorize-security-group-ingress \
    --group-id $PRIVATE_SG_ID \
    --protocol tcp --port 80 --cidr 0.0.0.0/0

aws ec2 authorize-security-group-ingress \
    --group-id $PRIVATE_SG_ID \
    --protocol tcp --port 443 --cidr 0.0.0.0/0

echo "Configured private instance security group:"
echo "  - SSH from bastion SG only"
echo "  - HTTP/HTTPS from anywhere"
```

### Part 3: Launch Instances (20 minutes)

#### Step 11: Find Amazon Linux 2 AMI
```bash
AMI_ID=$(aws ec2 describe-images \
    --owners amazon \
    --filters "Name=name,Values=amzn2-ami-hvm-2.0.????????-x86_64-gp2" "Name=state,Values=available" \
    --query 'Images[0].ImageId' \
    --output text)

echo "Using AMI: $AMI_ID"
```

#### Step 12: Launch Bastion Host in Public Subnet
```bash
BASTION_INSTANCE_ID=$(aws ec2 run-instances \
    --image-id $AMI_ID \
    --instance-type t2.micro \
    --key-name vpc-interview-key \
    --security-group-ids $BASTION_SG_ID \
    --subnet-id $PUBLIC_SUBNET_ID \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=bastion-host}]' \
    --query 'Instances[0].InstanceId' \
    --output text)

echo "Launched bastion host: $BASTION_INSTANCE_ID"
```

#### Step 13: Launch Private Instance in Private Subnet
```bash
PRIVATE_INSTANCE_ID=$(aws ec2 run-instances \
    --image-id $AMI_ID \
    --instance-type t2.micro \
    --key-name vpc-interview-key \
    --security-group-ids $PRIVATE_SG_ID \
    --subnet-id $PRIVATE_SUBNET_ID \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=private-web-server}]' \
    --query 'Instances[0].InstanceId' \
    --output text)

echo "Launched private instance: $PRIVATE_INSTANCE_ID"
```

#### Step 14: Wait for Instances to be Running
```bash
echo "Waiting for instances to be running..."
aws ec2 wait instance-running --instance-ids $BASTION_INSTANCE_ID $PRIVATE_INSTANCE_ID
echo "Both instances are now running!"
```

#### Step 15: Get Instance Information
```bash
# Get bastion host public IP
BASTION_PUBLIC_IP=$(aws ec2 describe-instances \
    --instance-ids $BASTION_INSTANCE_ID \
    --query 'Reservations[0].Instances[0].PublicIpAddress' \
    --output text)

# Get private instance private IP
PRIVATE_INSTANCE_PRIVATE_IP=$(aws ec2 describe-instances \
    --instance-ids $PRIVATE_INSTANCE_ID \
    --query 'Reservations[0].Instances[0].PrivateIpAddress' \
    --output text)

echo "Instance Information:"
echo "  Bastion Host: $BASTION_INSTANCE_ID"
echo "    Public IP: $BASTION_PUBLIC_IP"
echo "    Private IP: $(aws ec2 describe-instances --instance-ids $BASTION_INSTANCE_ID --query 'Reservations[0].Instances[0].PrivateIpAddress' --output text)"
echo ""
echo "  Private Instance: $PRIVATE_INSTANCE_ID"
echo "    Public IP: $(aws ec2 describe-instances --instance-ids $PRIVATE_INSTANCE_ID --query 'Reservations[0].Instances[0].PublicIpAddress' --output text || echo 'None (expected)')"
echo "    Private IP: $PRIVATE_INSTANCE_PRIVATE_IP"
```

### Part 4: Configure and Test Connectivity (5 minutes)

#### Step 16: Configure Bastion Host
```bash
echo "Configuring bastion host..."
ssh -i "vpc-interview-key.pem" ec2-user@$BASTION_PUBLIC_IP << 'EOF'
    sudo yum update -y
    sudo yum install -y httpd
    sudo systemctl start httpd
    sudo systemctl enable httpd
    echo "<h1>Bastion Host</h1><p>This is the bastion host in the public subnet.</p>" | sudo tee /var/www/html/index.html
    sudo systemctl restart httpd
EOF
```

#### Step 17: Configure Private Instance
```bash
echo "Configuring private instance..."
ssh -i "vpc-interview-key.pem" ec2-user@$BASTION_PUBLIC_IP << EOF
    ssh -o StrictHostKeyChecking=no -i "vpc-interview-key.pem" ec2-user@$PRIVATE_INSTANCE_PRIVATE_IP << 'INNER_EOF'
        sudo yum update -y
        sudo yum install -y httpd
        sudo systemctl start httpd
        sudo systemctl enable httpd
        echo "<h1>Private Web Server</h1><p>This web server is running in a private subnet and accessed via bastion host.</p><p>Instance ID: $(curl -s http://169.254.169.254/latest/meta-data/instance-id)</p>" | sudo tee /var/www/html/index.html
        sudo systemctl restart httpd
INNER_EOF
EOF
```

#### Step 18: Test Connectivity
```bash
echo "Testing connectivity..."

# Test bastion host web server
echo "Testing bastion host web server:"
curl -s http://$BASTION_PUBLIC_IP | grep -i "bastion host" && echo "✓ Bastion host web server accessible" || echo "✗ Bastion host web server test failed"

# Test private instance web server via bastion (SSH tunnel)
echo "Testing private instance web server via bastion host:"
ssh -i "vpc-interview-key.pem" -L 8080:$PRIVATE_INSTANCE_PRIVATE_IP:80 ec2-user@$BASTION_PUBLIC_IP << 'EOF'
    echo "Testing private instance web server on localhost:8080..."
    curl -s http://localhost:8080 | grep -i "private web server" && echo "✓ Private instance web server accessible via bastion" || echo "✗ Private instance web server test failed"
    exit
EOF
```

### Part 5: Verification and Cleanup (5 minutes)

#### Step 19: Final Verification
```bash
echo "=== VPC VERIFICATION SUMMARY ==="
echo "VPC ID: $VPC_ID"
echo "Internet Gateway: $IGW_ID"
echo "NAT Gateway: $NAT_GW_ID"
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
echo "Instances:"
echo "  Bastion Host: $BASTION_INSTANCE_ID (Public IP: $BASTION_PUBLIC_IP)"
echo "  Private Instance: $PRIVATE_INSTANCE_ID (Private IP: $PRIVATE_INSTANCE_PRIVATE_IP)"
echo ""
echo "Connectivity Test Results:"
echo "  Bastion Host Web: http://$BASTION_PUBLIC_IP"
echo "  Private Instance Web: Accessible via SSH tunnel to bastion host"
echo ""
echo "To access private instance web server:"
echo "  ssh -i \"vpc-interview-key.pem\" -L 8080:$PRIVATE_INSTANCE_PRIVATE_IP:80 ec2-user@$BASTION_PUBLIC_IP"
echo "  Then browse to: http://localhost:8080"
```

#### Step 20: Optional Cleanup
```bash
# To terminate instances when you're done practicing:
# echo "Terminating instances..."
# aws ec2 terminate-instances --instance-ids $BASTION_INSTANCE_ID $PRIVATE_INSTANCE_ID
# 
# To delete NAT gateway and EIP:
# echo "Deleting NAT gateway..."
# aws ec2 delete-nat-gateway --nat-gateway-id $NAT_GW_ID
# aws ec2 release-address --allocation-id $EIP_ALLOC_ID
# 
# To delete internet gateway:
# echo "Detaching and deleting internet gateway..."
# aws ec2 detach-internet-gateway --internet-gateway-id $IGW_ID --vpc-id $VPC_ID
# aws ec2 delete-internet-gateway --internet-gateway-id $IGW_ID
# 
# To delete VPC (this will delete all remaining resources):
# echo "Deleting VPC..."
# aws ec2 delete-vpc --vpc-id $VPC_ID
# 
# echo "Cleanup complete!"
```

## Expected Outcomes

By completing this exercise, you should have:

1. ✅ A VPC with CIDR block 10.0.0.0/16
2. ✅ Internet gateway attached to VPC
3. ✅ Two public subnets (one per AZ) and two private subnets (one per AZ)
4. ✅ NAT gateway in first public subnet for private subnet internet access
5. ✅ Properly configured route tables:
   - Public route table: Routes to internet gateway
   - Main route table: Routes to NAT gateway (for private subnets)
6. ✅ Security groups:
   - Bastion SG: SSH access from your IP only
   - Private instance SG: SSH from bastion SG, HTTP/HTTPS from anywhere
7. ✅ Bastion host in public subnet
8. ✅ Private web server instance in private subnet
9. ✅ Connectivity verified:
   - Bastion host web server accessible directly
   - Private instance web server accessible via SSH tunnel through bastion

## Troubleshooting Tips

### VPC Creation Issues
- **CIDR block conflicts**: Ensure your chosen CIDR block doesn't overlap with other VPCs or your corporate network
- **Insufficient address space**: /16 provides 65,536 addresses - plenty for this exercise
- **DNS not working**: Remember to enable DNS hostnames and support after VPC creation

### Internet Gateway Issues
- **Not attached**: Must attach IGW to VPC before it can be used
- **Missing route**: Public subnets need route to IGW (0.0.0.0/0 → IGW)
- **Detachment issues**: Must detach IGW from VPC before deleting

### NAT Gateway Issues
- **Not available state**: NAT gateways take a few minutes to become available
- **Missing EIP**: NAT gateway requires allocated Elastic IP
- **Wrong subnet**: NAT gateway must be in public subnet
- **Route not configured**: Private subnets need route to NAT gateway (0.0.0.0/0 → NAT GW)

### Subnet Issues
- **Wrong AZ**: Subnets must be in valid Availability Zones for the region
- **CIDR overlap**: Subnet CIDR blocks must not overlap within the same VPC
- **Incorrect sizing**: /24 subnets provide 251 usable IP addresses (enough for this exercise)

### Security Group Issues
- **Missing rules**: Remember security groups are deny-all by default
- **Wrong reference**: When referencing other SGs, ensure they exist and are in same VPC
- **Stateful vs stateless**: Remember SGs are stateful, NACLs are stateless

### Connectivity Issues
- **SSH timeout**: Check security group rules (port 22) and network ACLs
- **Web server not responding**: Verify service is running and security group allows port 80/443
- **Private instance not reachable**: Remember private instances don't have public IPs by design
- **Bastion tunnel not working**: Check key permissions and SSH configuration

### Route Table Issues
- **Missing associations**: Subnets must be explicitly associated with route tables
- **Wrong routes**: Public subnets need IGW route, private subnets need NAT route
- **Black hole routes**: Ensure gateways/NAT gateways exist and are available

## Extension Activities (Optional)

If you complete the basic exercise early, try these extensions:

1. **VPC Peering**: Create a second VPC and establish peering connection
2. **Flow Logs**: Enable VPC flow logs and send to CloudWatch Logs or S3
3. **VPN Connection**: Set up AWS Site-to-Site VPN connection to simulate on-premises connectivity
4. **PrivateLink**: Create VPC endpoint for S3 access without internet gateway
5. **Transit Gateway**: Experiment with AWS Transit Gateway for hub-and-spoke architecture
6. **Network ACLs**: Add specific rules to NACLs for additional subnet-level security
7. **Elastic IPs**: Allocate and associate Elastic IP with NAT gateway or bastion host
8. **Secondary Private IPs**: Assign multiple private IPs to instances for multi-homing

## GitHub Commit Instructions

After completing the exercise, update these files:

1. `day03-vpc-networking/notes.md` - Add any notes or observations from your hands-on experience
2. `day03-vpc-networking/scripts/create-vpc.sh` - Save the AWS CLI commands you used
3. `day03-vpc-networking/scripts/verify-vpc.sh` - Save verification commands
4. `day03-vpc-networking/scripts/cleanup-vpc.sh` - Save cleanup commands

Then commit and push:
```bash
git add day03-vpc-networking/
git commit -m "Day 3: VPC Hands-On Exercise completed - created VPC with public/private subnets, IGW, NAT gateway, bastion host, and private instance"
git push origin main
```