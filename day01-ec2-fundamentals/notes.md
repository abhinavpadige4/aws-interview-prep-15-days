# Day 1: EC2 Fundamentals

## Study Notes (60 minutes)

### Amazon EC2 Overview
Elastic Compute Cloud (EC2) provides resizable compute capacity in the cloud. It allows you to launch virtual servers, configure security and networking, and manage storage.

### Key Concepts

#### Instance Types
EC2 offers various instance types optimized for different use cases:
- **General Purpose**: T3, T3a, M5, M5a (balanced compute, memory, networking)
- **Compute Optimized**: C5, C5a, C6i (high-performance processors)
- **Memory Optimized**: R5, R5a, X1 (memory-intensive applications)
- **Storage Optimized**: I3, I3a, D2 (high-speed local storage)
- **Accelerated Computing**: P3, G4, Inf1 (GPUs, FPGAs, specialized hardware)

#### Amazon Machine Images (AMIs)
AMIs are templates that contain the software configuration (operating system, application server, and applications) required to launch an instance.

Types of AMIs:
- **Amazon-provided AMIs**: Amazon Linux, Ubuntu, Windows Server, etc.
- **AWS Marketplace AMIs**: Pre-configured software from third-party vendors
- **Community AMIs**: Shared by other AWS users
- **Custom AMIs**: Created from your own instances

#### Key Pairs
Key pairs consist of a public key stored by AWS and a private key file stored by you. Used for secure SSH access to your instances.

#### Security Groups
Virtual firewalls that control inbound and outbound traffic for your instances. Rules are based on protocols, ports, and source/destination IP addresses.

#### Elastic IP Addresses
Static IPv4 addresses designed for dynamic cloud computing. You can associate an Elastic IP with any instance or network interface in your VPC.

#### EC2 Instance States
- **Pending**: Instance is being launched
- **Running**: Instance is operational
- **Stopping**: Instance is being stopped
- **Stopped**: Instance is stopped but not terminated (EBS volumes persist)
- **Terminated**: Instance is permanently deleted

#### Instance Purchasing Options
- **On-Demand**: Pay by the second with no long-term commitments
- **Reserved Instances**: 1-3 year commitment for significant discounts
- **Spot Instances**: Bid on unused EC2 capacity (up to 90% discount)
- **Dedicated Hosts**: Physical server dedicated for your use
- **Dedicated Instances**: Instances running on hardware dedicated to you

### Hands-On Exercise Overview (60 minutes)
1. Launch a t2.micro EC2 instance
2. Configure security group for HTTP/HTTPS/SSH access
3. Connect via SSH
4. Install Apache web server
5. Create a simple HTML page
6. Test the web server

## Practice Questions (30 minutes)

### Multiple Choice Questions

1. **What is the difference between stop and terminate an EC2 instance?**
   - A) Stopped instances incur hourly charges, terminated instances do not
   - B) Stopped instances preserve EBS volumes, terminated instances delete them
   - C) Stopped instances cannot be restarted, terminated instances can be
   - D) There is no difference between stop and terminate

2. **How can you assign an Elastic IP to an instance?**
   - A) Through the EC2 console under "Elastic IPs" → "Allocate new address"
   - B) By modifying the instance's network interface settings
   - C) Both A and B
   - D) Only through AWS CLI

3. **Which EC2 purchasing option offers the highest discount?**
   - A) On-Demand Instances
   - B) Reserved Instances (1-year term)
   - C) Reserved Instances (3-year term)
   - D) Spot Instances

4. **What is the default limit for security groups per region?**
   - A) 500 security groups per region
   - B) 1000 security groups per region
   - C) 250 security groups per region
   - D) 50 security groups per region

5. **How do you enable detailed monitoring on an EC2 instance?**
   - A) Through CloudWatch console → Enable detailed monitoring
   - B) By setting monitoring interval to 1 minute during launch
   - C) Both A and B
   - D) Detailed monitoring is enabled by default

### Answers
1. B) Stopped instances preserve EBS volumes, terminated instances delete them
2. C) Both A and B
3. D) Spot Instances (can offer up to 90% discount)
4. A) 500 security groups per region
5. C) Both A and B

## Hands-On Exercise: Launch EC2 Instance

### Step-by-Step Instructions

#### Prerequisites
- AWS Account with Free Tier eligibility
- AWS CLI installed and configured
- Key pair created in AWS Console

#### Step 1: Create Key Pair (if not already done)
```bash
aws ec2 create-key-pair --key-name my-ec2-key --query 'KeyMaterial' --output text > my-ec2-key.pem
chmod 400 my-ec2-key.pem
```

#### Step 2: Launch t2.micro EC2 Instance
```bash
INSTANCE_ID=$(aws ec2 run-instances \
    --image-id ami-0c55b159cbfafe1f0 \  # Amazon Linux 2 AMI (US East-1)
    --instance-type t2.micro \
    --key-name my-ec2-key \
    --security-group-ids sg-0123456789abcdef0 \  # Replace with your security group
    --subnet-id subnet-0123456789abcdef0 \      # Replace with your subnet
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=my-web-server}]' \
    --query 'Instances[0].InstanceId' \
    --output text)

echo "Launched instance: $INSTANCE_ID"
```

#### Step 3: Wait for Instance to be Running
```bash
aws ec2 wait instance-running --instance-ids $INSTANCE_ID
echo "Instance is now running!"
```

#### Step 4: Get Public IP Address
```bash
PUBLIC_IP=$(aws ec2 describe-instances \
    --instance-ids $INSTANCE_ID \
    --query 'Reservations[0].Instances[0].PublicIpAddress' \
    --output text)

echo "Public IP: $PUBLIC_IP"
```

#### Step 5: Connect via SSH and Install Apache
```bash
ssh -i "my-ec2-key.pem" ec2-user@$PUBLIC_IP << 'EOF'
    sudo yum update -y
    sudo yum install -y httpd
    sudo systemctl start httpd
    sudo systemctl enable httpd
    echo "<h1>Hello from AWS EC2!</h1><p>Instance ID: $(curl -s http://169.254.169.254/latest/meta-data/instance-id)</p>" | sudo tee /var/www/html/index.html
    sudo systemctl restart httpd
EOF
```

#### Step 6: Test the Web Server
```bash
echo "Testing web server at: http://$PUBLIC_IP"
curl http://$PUBLIC_IP
```

#### Step 7: Clean Up (Optional)
```bash
# To terminate the instance when done:
# aws ec2 terminate-instances --instance-ids $INSTANCE_ID
```

### Expected Results
- EC2 instance running with t2.micro type
- Security group allowing SSH (22), HTTP (80), and HTTPS (443) access
- Apache web server installed and serving a custom HTML page
- Accessible via public IP address in web browser

## GitHub Commit Instructions (15 minutes)

### Files to Add/Update
1. `day01-ec2-fundamentals/notes.md` - This file
2. `day01-ec2-fundamentals/practice-questions.md` - Practice questions and answers
3. `day01-ec2-fundamentals/hands-on-exercise.md` - Detailed exercise instructions
4. `day01-ec2-fundamentals/scripts/launch-ec2.sh` - AWS CLI script to launch instance
5. `day01-ec2-fundamentals/scripts/configure-apache.sh` - Script to install and configure Apache

### Commit Process
```bash
# Navigate to repository root
cd aws-interview-prep-15-days

# Add all Day 1 files
git add day01-ec2-fundamentals/

# Commit with descriptive message
git commit -m "Day 1: EC2 Fundamentals - notes, practice questions, hands-on exercise, and scripts"

# Push to GitHub
git push origin main
```

## Resources
- [Amazon EC2 Documentation](https://docs.aws.amazon.com/ec2/index.html)
- [EC2 Instance Types](https://aws.amazon.com/ec2/instance-types/)
- [EC2 Practice Questions](https://tutorialsdojo.com/aws-certified-solutions-architect-associate-practice-tests/ec2/)