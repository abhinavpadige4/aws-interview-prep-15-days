# Day 1: EC2 Scripts

This directory contains AWS CLI and shell scripts for the EC2 hands-on exercise.

## Scripts Included

### launch-ec2.sh
Launches a t2.micro EC2 instance with:
- Amazon Linux 2 AMI
- Proper security group (SSH, HTTP, HTTPS)
- Key pair for access
- Tags for easy identification

### configure-apache.sh
Installs and configures Apache web server on the EC2 instance:
- Updates system packages
- Installs httpd package
- Creates custom HTML page with instance metadata
- Sets proper permissions
- Starts and enables Apache service

### verify-installation.sh
Verifies that the EC2 instance and web server are properly configured:
- Checks EC2 instance metadata
- Verifies Apache installation and status
- Tests web server responsiveness
- Validates document root and content
- Provides troubleshooting guidance

## Usage Instructions

### Prerequisites
- AWS CLI installed and configured (`aws configure`)
- Running on an EC2 instance (for configure-apache.sh and verify-installation.sh)
- Proper IAM permissions for EC2 operations

### Make Scripts Executable
```bash
chmod +x launch-ec2.sh configure-apache.sh verify-installation.sh
```

### Launch EC2 Instance (Run from your local machine)
```bash
./launch-ec2.sh
```
This will:
1. Create/use key pair: ec2-interview-key.pem
2. Create security group: web-server-sg
3. Launch t2.micro instance with Amazon Linux 2
4. Output connection instructions

### Configure Web Server (Run on the EC2 instance via SSH)
```bash
./configure-apache.sh
```
This will install Apache and create a custom HTML page showing instance information.

### Verify Installation (Run on the EC2 instance)
```bash
./verify-installation.sh
```
This will check that everything is working correctly.

## Expected Workflow

1. **Local Machine**: Run `./launch-ec2.sh` to create the instance
2. **Local Machine**: Note the instance ID and public IP from the output
3. **Local Machine**: SSH into the instance: `ssh -i "ec2-interview-key.pem" ec2-user@<PUBLIC_IP>`
4. **EC2 Instance**: Run `./configure-apache.sh` to install the web server
5. **EC2 Instance**: Run `./verify-installation.sh` to confirm everything works
6. **Local Machine**: Test the web server: `curl http://<PUBLIC_IP}` or visit in browser
7. **Cleanup**: When done, terminate the instance: `aws ec2 terminate-instances --instance-ids <INSTANCE_ID>`

## Safety Notes
- The launch script uses the default VPC and first available subnet
- Security group allows SSH from your current IP only (for security)
- HTTP and HTTPS are open to the internet (necessary for web server)
- Remember to terminate instances when done to avoid charges
- Key pair file (ec2-interview-key.pem) should be kept secure