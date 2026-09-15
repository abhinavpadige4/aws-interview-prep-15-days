# Day 3: VPC Networking

## Study Notes (60 minutes)

### Amazon VPC Overview
Amazon Virtual Private Cloud (VPC) lets you provision a logically isolated section of the AWS Cloud where you can launch AWS resources in a virtual network that you define. You have complete control over your virtual networking environment, including selection of IP address ranges, creation of subnets, and configuration of route tables and network gateways.

### Key Concepts

#### VPC Fundamentals
- **VPC**: Virtual network dedicated to your AWS account
- **CIDR Block**: IP address range for your VPC (e.g., 10.0.0.0/16)
- **Region**: VPCs are region-specific resources
- **Isolation**: Resources in different VPCs are isolated by default

#### Subnets
- **Subnet**: Range of IP addresses in your VPC
- **Public Subnet**: Subnet with route to Internet Gateway
- **Private Subnet**: Subnet without direct route to Internet Gateway
- **Availability Zone**: Subnets must reside in a single AZ

#### Route Tables
- **Route Table**: Contains rules (routes) that determine where network traffic is directed
- **Main Route Table**: Default route table created with VPC
- **Custom Route Table**: Additional route tables you create
- **Routes**: Define how traffic reaches destinations (0.0.0.0/0 → Internet Gateway)

#### Internet Gateway (IGW)
- **Internet Gateway**: Horizontally scaled, redundant VPC component that allows communication between VPC and internet
- **Attachment**: Must be attached to VPC to function
- **Route Table Entry**: Public subnets route 0.0.0.0/0 to IGW

#### NAT Gateway/NAT Instance
- **NAT Gateway**: Managed NAT service (high availability, scalable)
- **NAT Instance**: Self-managed NAT on EC2 instance
- **Purpose**: Allow instances in private subnets to initiate outbound IPv4 traffic to internet while preventing inbound traffic
- **Location**: Must be in public subnet

#### Network ACLs (NACLs)
- **Stateless**: Return traffic must be explicitly allowed by rules
- **Numbered Rules**: Evaluated in order (lowest number first)
- **Separate Inbound/Outbound**: Rules for each direction
- **Default**: Allow all inbound and outbound traffic
- **Subnet Level**: One NACL per subnet (can be shared)

#### Security Groups
- **Stateful**: Return traffic automatically allowed
- **Evaluation**: All rules evaluated
- **Default**: Deny all inbound, allow all outbound (to same SG)
- **Instance Level**: Can have multiple SGs per instance
- **Referencing**: Can reference other security groups in same VPC

#### VPC Peering
- **VPC Peering Connection**: Direct network route between two VPCs
- **Non-Transitive**: If A peers with B and B peers with C, A does not peer with C
- **Same or Different Accounts**: Can peer VPCs in same or different AWS accounts
- **Same or Different Regions**: Can peer VPCs in same or different regions (inter-region peering)
- **No Overlapping CIDRs**: VPCs in peering connection must not have overlapping CIDR blocks

#### Elastic IP Addresses (EIP)
- **Static IPv4**: For dynamic cloud computing
- **Attributes**: Can be associated with instances, network interfaces, or NAT gateways
- **Allocation**: Must be allocated from AWS pool before use
- **Limits**: Default limit of 5 EIPs per region (can be increased)

#### DHCP Options Sets
- **DHCP Options**: Domain name, domain name servers, NetBIOS settings
- **Default Set**: Created automatically with VPC
- **Custom Sets**: Can create and associate with VPC
- **Single Association**: Only one DHCP options set can be associated with VPC at a time

#### VPC Endpoints
- **Gateway Endpoints**: For S3 and DynamoDB (uses prefix lists)
- **Interface Endpoints**: Powered by AWS PrivateLink (most AWS services)
- **Benefits**: 
  - No internet gateway, NAT device, VPN, or Direct Connect needed
  - Traffic remains within AWS network
  - Improved security and reduced latency

## Practice Questions Overview (30 minutes)

### Multiple Choice Questions

1. **What is the CIDR block size limit for a VPC?**
   - A) /16 to /28
   - B) /16 to /24
   - C) /12 to /24
   - D) /16 to /20

2. **How many subnets can you create per VPC by default?**
   - A) 50 subnets per VPC
   - B) 100 subnets per VPC
   - C) 200 subnets per VPC
   - D) 500 subnets per VPC

3. **What is the purpose of a NAT gateway?**
   - A) To allow inbound internet traffic to private instances
   - B) To allow outbound internet traffic from private instances
   - C) To provide load balancing for web traffic
   - D) To encrypt traffic between VPC and internet

4. **Difference between network ACL and security group?**
   - A) NACL is stateful, Security Group is stateless
   - B) NACL operates at subnet level, Security Group at instance level
   - C) NACL evaluates all rules, Security Group uses first match
   - D) There is no difference; they are interchangeable

5. **How does VPC peering work?**
   - A) Creates a transitive connection between all peered VPCs
   - B) Requires internet gateway for traffic to flow
   - C) Provides direct network route using private IP addresses
   - D) Only works between VPCs in the same AWS account

### Answers
1. A) /16 to /28 (actually /16 to /28 netmask range, but AWS allows /16 to /28)
2. B) 100 subnets per VPC (default limit)
3. B) To allow outbound internet traffic from private instances
4. B) NACL operates at subnet level, Security Group at instance level
5. C) Provides direct network route using private IP addresses

## Hands-On Exercise Overview (60 minutes)
1. Create a VPC with public and private subnets
2. Create internet gateway and attach to VPC
3. Create NAT gateway in public subnet
4. Configure route tables for public and private subnets
5. Launch an EC2 instance in private subnet
6. Configure bastion host in public subnet for access

## GitHub Commit Instructions (15 minutes)
Add day3 notes, Terraform/AWS CLI script to create VPC, commit and push