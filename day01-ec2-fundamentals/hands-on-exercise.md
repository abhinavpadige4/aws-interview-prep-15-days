# Day 1: EC2 Hands-On Exercise

## Objective
Launch a t2.micro EC2 instance, configure security group, connect via SSH, install Apache, and create a simple HTML page.

## Prerequisites
- AWS Account with Free Tier eligibility
- AWS CLI installed and configured (`aws configure`)
- Key pair created in your AWS account
- Basic Linux/SSH knowledge

## Estimated Time: 60 minutes

## Exercise Steps

### Part 1: Preparation (10 minutes)

#### Step 1: Verify AWS CLI Configuration
```bash
aws sts get-caller-identity
```
Expected output should show your Account ID and User/Role ARN.

#### Step 2: Check Available Key Pairs
```bash
aws ec2 describe-key-pairs
```
If you don't have a key pair, create one:
```bash
aws ec2 create-key-pair --key-name ec2-interview-key --query 'KeyMaterial' --output text > ec2-interview-key.pem
chmod 400 ec2-interview-key.pem
```

#### Step 3: Identify Default VPC and Subnet
```bash
# Get default VPC
aws ec2 describe-vpcs --filters "Name=isDefault,Values=true" --query 'Vpcs[0].VpcId' --output text

# Get subnets in default VPC
aws ec2 describe-subnets --filters "Name=vpc-id,Values=$(aws ec2 describe-vpcs --filters \"Name=isDefault,Values=true\" --query 'Vpcs[0].VpcId' --output text)" --query 'Subnets[0].SubnetId' --output text
```

### Part 2: Create Security Group (15 minutes)

#### Step 4: Create Security Group for Web Server
```bash
# Get your VPC ID
VPC_ID=$(aws ec2 describe-vpcs --filters "Name=isDefault,Values=true" --query 'Vpcs[0].VpcId' --output text)

# Create security group
SECURITY_GROUP_ID=$(aws ec2 create-security-group \
    --group-name web-server-sg \
    --description "Security group for web server - SSH, HTTP, HTTPS" \
    --vpc-id $VPC_ID \
    --query 'GroupId' \
    --output text)

echo "Created security group: $SECURITY_GROUP_ID"
```

#### Step 5: Add Inbound Rules
```bash
# Allow SSH (port 22) from your IP
MY_IP=$(curl -s http://checkip.amazonaws.com)
aws ec2 authorize-security-group-ingress \
    --group-id $SECURITY_GROUP_ID \
    --protocol tcp \
    --port 22 \
    --cidr $MY_IP/32

# Allow HTTP (port 80) from anywhere
aws ec2 authorize-security-group-ingress \
    --group-id $SECURITY_GROUP_ID \
    --protocol tcp \
    --port 80 \
    --cidr 0.0.0.0/0

# Allow HTTPS (port 443) from anywhere
aws ec2 authorize-security-group-ingress \
    --group-id $SECURITY_GROUP_ID \
    --protocol tcp \
    --port 443 \
    --cidr 0.0.0.0/0

echo "Added inbound rules for SSH, HTTP, and HTTPS"
```

### Part 3: Launch EC2 Instance (15 minutes)

#### Step 6: Find Amazon Linux 2 AMI
```bash
AMI_ID=$(aws ec2 describe-images \
    --owners amazon \
    --filters "Name=name,Values=amzn2-ami-hvm-2.0.????????-x86_64-gp2" "Name=state,Values=available" \
    --query 'Images[0].ImageId' \
    --output text)

echo "Using AMI: $AMI_ID"
```

#### Step 7: Launch t2.micro Instance
```bash
INSTANCE_ID=$(aws ec2 run-instances \
    --image-id $AMI_ID \
    --instance-type t2.micro \
    --key-name ec2-interview-key \
    --security-group-ids $SECURITY_GROUP_ID \
    --subnet-id $(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID" --query 'Subnets[0].SubnetId' --output text) \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=interview-prep-web-server}]' \
    --query 'Instances[0].InstanceId' \
    --output text)

echo "Launched instance: $INSTANCE_ID"
```

#### Step 8: Wait for Instance to be Ready
```bash
echo "Waiting for instance to be running..."
aws ec2 wait instance-running --instance-ids $INSTANCE_ID
echo "Instance is now running!"
```

#### Step 9: Get Public IP Address
```bash
PUBLIC_IP=$(aws ec2 describe-instances \
    --instance-ids $INSTANCE_ID \
    --query 'Reservations[0].Instances[0].PublicIpAddress' \
    --output text)

echo "Public IP address: $PUBLIC_IP"
```

### Part 4: Connect and Configure Web Server (15 minutes)

#### Step 10: Connect via SSH and Install Apache
```bash
ssh -i "ec2-interview-key.pem" ec2-user@$PUBLIC_IP << 'EOF'
    echo "Updating system packages..."
    sudo yum update -y
    
    echo "Installing Apache web server..."
    sudo yum install -y httpd
    
    echo "Starting and enabling Apache service..."
    sudo systemctl start httpd
    sudo systemctl enable httpd
    
    echo "Creating custom HTML page..."
    cat > /var/www/html/index.html << 'HTML'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AWS EC2 Interview Prep</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 40px;
            background-color: #f5f5f5;
        }
        .container {
            max-width: 800px;
            margin: 0 auto;
            background: white;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        h1 {
            color: #232f3e;
            border-bottom: 3px solid #ff9900;
            padding-bottom: 10px;
        }
        .info-box {
            background-color: #e8f4f8;
            border-left: 4px solid #ff9900;
            padding: 15px;
            margin: 20px 0;
        }
        .footer {
            margin-top: 30px;
            text-align: center;
            color: #666;
            font-size: 0.9em;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Welcome to AWS EC2!</h1>
        <div class="info-box">
            <h2>Instance Information</h2>
            <p><strong>Instance ID:</strong> $(curl -s http://169.254.169.254/latest/meta-data/instance-id)</p>
            <p><strong>Instance Type:</strong> $(curl -s http://169.254.169.254/latest/meta-data/instance-type)</p>
            <p><strong>Availability Zone:</strong> $(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)</p>
            <p><strong>Local IP:</strong> $(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)</p>
            <p><strong>Public IP:</strong> $(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)</p>
        </div>
        
        <div class="info-box">
            <h2>EC2 Concepts Learned</h2>
            <ul>
                <li>Instance types and families</li>
                <li>Amazon Machine Images (AMIs)</li>
                <li>Security groups and network configuration</li>
                <li>Key pairs for secure access</li>
                <li>Elastic IP addresses</li>
                <li>Instance states (pending, running, stopped, terminated)</li>
                <li>Purchasing options (On-Demand, Reserved, Spot)</li>
            </ul>
        </div>
        
        <div class="info-box">
            <h2>Next Steps in Your AWS Journey</h2>
            <ol>
                <li>Explore S3 storage services</li>
                <li>Learn VPC networking concepts</li>
                <li>Master IAM security best practices</li>
                <li>Practice with Lambda serverless functions</li>
                <li>Work with RDS managed databases</li>
            </ol>
        </div>
    </div>
    
    <div class="footer">
        <p>AWS Cloud Engineer Interview Preparation - Day 1: EC2 Fundamentals</p>
        <p>Generated on: $(date)</p>
    </div>
</body>
</html>
HTML
    
    echo "Setting correct permissions..."
    sudo chown -R apache:apache /var/www/html
    
    echo "Restarting Apache to apply changes..."
    sudo systemctl restart httpd
    
    echo "Apache installation complete!"
    echo "Web server should be accessible at: http://$PUBLIC_IP"
EOF
```

#### Step 11: Test the Web Server
```bash
echo "Testing web server..."
curl -s http://$PUBLIC_IP | head -20

echo ""
echo "Web server is accessible at: http://$PUBLIC_IP"
echo "Open this URL in your web browser to see the full page!"
```

### Part 5: Verification and Cleanup (5 minutes)

#### Step 12: Verify Instance Status
```bash
aws ec2 describe-instances \
    --instance-ids $INSTANCE_ID \
    --query 'Reservations[0].Instances[0].{State:State.Name,Type:InstanceType,IP:PublicIpAddress}' \
    --output table
```

#### Step 13: Optional Cleanup
```bash
# To terminate the instance when you're done practicing:
# aws ec2 terminate-instances --instance-ids $INSTANCE_ID
# echo "Instance $INSTANCE_ID terminated"

# To delete the security group (after terminating instance):
# aws ec2 delete-security-group --group-id $SECURITY_GROUP_ID
# echo "Security group $SECURITY_GROUP_ID deleted"
```

## Expected Outcomes

By completing this exercise, you should have:

1. ✅ A running t2.micro EC2 instance
2. ✅ A security group allowing SSH (22), HTTP (80), and HTTPS (443) access
3. ✅ Successful SSH connection to your instance
4. ✅ Apache web server installed and running
5. ✅ A custom HTML page displaying instance metadata
6. ✅ Web server accessible via public IP in a web browser

## Troubleshooting Tips

### Connection Issues
- **Timeout connecting via SSH**: Check security group rules and ensure port 22 is open
- **Permission denied (publickey)**: Verify you're using the correct .pem file and permissions are set to 400
- **Host key verification**: This is normal on first connection - type 'yes' to continue

### Web Server Issues
- **Connection refused**: Verify Apache is running (`sudo systemctl status httpd`) and security group allows port 80
- **Default Apache page showing**: Check that your custom index.html is in `/var/www/html/` and has correct permissions
- **Page not loading**: Verify the public IP address is correct and instance is in running state

### AWS CLI Issues
- **Command not found**: Ensure AWS CLI is installed and in your PATH
- **Authentication failed**: Run `aws configure` to re-enter your credentials
- **Invalid parameter**: Double-check parameter names and values in your commands

## Extension Activities (Optional)

If you complete the basic exercise early, try these extensions:

1. **Elastic IP Assignment**: Allocate and associate an Elastic IP with your instance
2. **Multiple Web Pages**: Create additional HTML pages and link them together
3. **PHP Installation**: Install PHP and create a simple PHP info page
4. **CloudWatch Monitoring**: Enable detailed monitoring and view metrics in CloudWatch console
5. **Instance Reboot**: Practice stopping and starting your instance

## GitHub Commit Instructions

After completing the exercise, update these files:

1. `day01-ec2-fundamentals/notes.md` - Add any notes or observations from your hands-on experience
2. `day01-ec2-fundamentals/scripts/launch-ec2.sh` - Save the AWS CLI commands you used
3. `day01-ec2-fundamentals/scripts/configure-apache.sh` - Save the SSH commands for Apache installation
4. `day01-ec2-fundamentals/screenshot.png` - Optional: Add a screenshot of your working web server

Then commit and push:
```bash
git add day01-ec2-fundamentals/
git commit -m "Day 1: EC2 Hands-On Exercise completed - launched instance, installed Apache, created web page"
git push origin main
```