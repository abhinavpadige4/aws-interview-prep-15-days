# Day 3: VPC Scripts

This directory contains AWS CLI and shell scripts for the VPC hands-on exercise.

## Scripts Included

### create-vpc.sh
Creates a complete VPC infrastructure with:
- VPC (10.0.0.0/16) with DNS hostnames and support enabled
- Internet Gateway attached to VPC
- Two public subnets (one per AZ) and two private subnets (one per AZ)
- NAT gateway in first public subnet for private subnet internet access
- Properly configured route tables:
  - Public route table: Routes to internet gateway (0.0.0.0/0 → IGW)
  - Main route table: Routes to NAT gateway (0.0.0.0/0 → NAT GW) for private subnets
- Security groups:
  - Bastion SG: SSH access from your IP only
  - Private instance SG: SSH from bastion SG, HTTP/HTTPS from anywhere
- Key pair for SSH access

### verify-vpc.sh
Verifies that the VPC is properly configured:
- Checks VPC existence and basic attributes (CIDR, DNS settings)
- Verifies Internet Gateway attachment
- Validates subnet creation and classification (public vs private)
- Checks route table configuration and associations
- Confirms NAT gateway creation and status
- Reviews security group rules and configurations
- Validates key pair existence

### cleanup-vpc.sh
Safely deletes all VPC resources:
- Terminates EC2 instances in the VPC
- Deletes NAT Gateways and releases associated Elastic IPs
- Detaches and deletes Internet Gateway
- Deletes all subnets
- Removes custom route tables (preserves main)
- Deletes custom security groups (preserves default)
- Deletes the VPC itself
- Optionally deletes the key pair and local key file

## Usage Instructions

### Prerequisites
- AWS CLI installed and configured (`aws configure`)
- Appropriate IAM permissions for VPC, EC2, and related operations

### Make Scripts Executable
```bash
chmod +x create-vpc.sh verify-vpc.sh cleanup-vpc.sh
```

### Create VPC Infrastructure
```bash
./create-vpc.sh
```
This script will:
1. Create or use key pair: vpc-interview-key.pem
2. Create VPC: interview-prep-vpc (10.0.0.0/16)
3. Attach Internet Gateway
4. Create public and private subnets in two AZs
5. Set up NAT gateway in first public subnet
6. Configure route tables for public and private subnets
7. Create security groups for bastion and private instances
8. Output complete resource IDs for reference

### Verify VPC Setup
```bash
./verify-vpc.sh <vpc-id>
```
Replace `<vpc-id>` with the VPC ID from the create-vpc.sh output.

This script performs comprehensive checks:
- VPC existence and attributes
- Internet Gateway attachment
- Subnet creation and classification
- Route table configuration
- NAT gateway status
- Security group rules
- Key pair availability

### Cleanup VPC Resources
```bash
./cleanup-vpc.sh
```
⚠️ **WARNING**: This script will DELETE all resources created by create-vpc.sh!
It will prompt for confirmation before proceeding with deletion.

The cleanup script removes:
- All EC2 instances in the VPC
- NAT Gateways and associated Elastic IPs
- Internet Gateway
- All subnets
- Custom route tables
- Custom security groups
- The VPC itself
- Key pair (optional)

## Expected Workflow

1. **Create the VPC**: Run `./create-vpc.sh`
2. **Note the VPC ID**: From the output (e.g., vpc-0123456789abcdef0)
3. **Verify the setup**: Run `./verify-vpc.sh vpc-0123456789abcdef0`
4. **Launch instances**: Follow the hands-on exercise to create bastion host and private instance
5. **Configure instances**: Set up web servers on both instances
6. **Test connectivity**: Verify bastion host access and private instance access via SSH tunnel
7. **Cleanup when done**: Run `./cleanup-vpc.sh` to avoid ongoing charges

## Expected Outcomes from create-vpc.sh

After running the creation script, you should have:

1. ✅ A VPC with CIDR block 10.0.0.0/16
2. ✅ DNS hostnames and support enabled
3. ✅ Internet Gateway attached to VPC
4. ✅ Two public subnets (10.0.1.0/24 and 10.0.3.0/24) - one per AZ
5. ✅ Two private subnets (10.0.2.0/24 and 10.0.4.0/24) - one per AZ
6. ✅ NAT gateway in first public subnet (10.0.1.0/24)
7. ✅ Public route table with route to Internet Gateway
8. ✅ Main route table with route to NAT gateway (for private subnets)
9. ✅ Bastion security group (SSH from your IP only)
10. ✅ Private instance security group (SSH from bastion SG, HTTP/HTTPS from anywhere)
11. ✅ Key pair: vpc-interview-key.pem

## Verification Checkpoints

The verify-vpc.sh script checks for:

1. **VPC Existence**: Confirms the VPC exists with correct CIDR and DNS settings
2. **Internet Gateway**: Verifies IGW is attached to the VPC
3. **Subnet Creation**: Validates public and private subnets in multiple AZs
4. **Route Table Configuration**: Checks for proper routing (IGW for public, NAT GW for private)
5. **NAT Gateway**: Confirms NAT gateway exists and is in available state
6. **Security Groups**: Reviews rules for bastion and private instance SGs
7. **Key Pair**: Ensures the SSH key pair exists

## Extension Activities (Optional)

If you complete the basic exercise early, try these extensions:

1. **Add Second NAT Gateway**:
   ```bash
   # Create EIP for second AZ
   EIP_ALLOC_ID_2=$(aws ec2 allocate-address --query 'AllocationId' --output text)
   
   # Create NAT gateway in second public subnet
   NAT_GW_ID_2=$(aws ec2 create-nat-gateway \
       --subnet-id $PUBLIC_SUBNET_ID_2 \
       --allocation-id $EIP_ALLOC_ID_2 \
       --query 'NatGateway.NatGatewayId' --output text)
   
   # Add route to second NAT gateway in second private subnet's route table
   # (Would need to create separate route table for second AZ)
   ```

2. **VPC Flow Logs**:
   ```bash
   # Create CloudWatch Logs group
   aws logs create-log-group --log-group-name vpc-flow-logs
   
   # Create IAM role for flow logs
   # Create flow log
   aws ec2 create-flow-logs \
       --resource-type VPC \
       --resource-ids $VPC_ID \
       --traffic-type ALL \
       --log-group-name vpc-flow-logs \
       --deliver-logs-permission-arn <role-arn>
   ```

3. **VPC Peering**:
   - Create second VPC with non-overlapping CIDR
   - Establish peering connection
   - Update route tables to enable communication

4. **VPN Connection**:
   - Create customer gateway
   - Create virtual private gateway
   - Attach VPG to VPC
   - Create VPN connection
   - Download configuration

5. **PrivateLink for S3**:
   ```bash
   # Create VPC endpoint for S3
   aws ec2 create-vpc-endpoint \
       --vpc-id $VPC_ID \
       --service-name com.amazonaws.$REGION.s3 \
       --route-table-ids $RT_IDS
   ```

6. **Network ACLs**:
   - Replace default network ACL with custom one
   - Add specific allow/deny rules
   - Associate with subnets

7. **Elastic IPs for Bastion**:
   - Allocate and associate EIP with bastion host
   - Update security group to allow SSH to EIP

## Safety Notes
- The script creates resources in the default region (check with `aws configure get region`)
- All resources are tagged for easy identification where applicable
- Remember to run cleanup when done to avoid ongoing charges
- NAT Gateways incur hourly charges + data processing fees
- Internet Gateways are free but associated data transfer has costs
- Key pair file (vpc-interview-key.pem) should be kept secure