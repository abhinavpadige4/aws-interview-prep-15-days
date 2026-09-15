# Day 3: VPC Practice Questions

## Multiple Choice Questions

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

## Scenario-Based Questions

6. **You need to design a VPC for a 3-tier web application (web, app, database tiers) with high availability. What is the minimum number of Availability Zones you should use and why?**
   - A) 1 AZ - Simpler to manage and lower cost
   - B) 2 AZs - Provides basic high availability
   - C) 3 AZs - Maximum fault tolerance for 3-tier architecture
   - D) 2 AZs minimum, but 3 AZs recommended for better distribution

7. **Your application requires both public-facing web servers and private database servers. Which subnet configuration would be most appropriate?**
   - A) All resources in public subnets for simplicity
   - B) Web servers in public subnets, app and database in private subnets
   - C) All resources in private subnets with NAT gateway for internet access
   - D) Web and app in public subnets, database in private subnet

8. **You need to allow SSH access to EC2 instances in private subnets for administration. What is the recommended approach?**
   - A) Assign public IP addresses to all private instances
   - B) Configure security groups to allow SSH from 0.0.0.0/0
   - C) Use a bastion/jump host in a public subnet
   - D) Disable SSH and use AWS Systems Manager Session Manager only

9. **Your VPC has CIDR block 10.0.0.0/16. You need to create subnets for different departments, each requiring approximately 500 IP addresses. What subnet size should you use?**
   - A) /24 (256 addresses) - Not enough for 500 devices
   - B) /23 (512 addresses) - Provides ~500 usable addresses
   - C) /22 (1024 addresses) - Wastes too many addresses
   - D) /25 (128 addresses) - Too small for requirements

10. **You have two VPCs in different regions that need to communicate securely. Which AWS service would you use?**
    - A) VPC Peering
    - B) AWS Direct Connect
    - C) AWS Site-to-Site VPN
    - D) VPC Peering with inter-region support

## Answers

### Multiple Choice Questions
1. **A** - VPC CIDR blocks can range from /16 (65,536 addresses) to /28 (16 addresses)
2. **B** - Default limit is 100 subnets per VPC (can be increased upon request)
3. **B** - NAT gateway enables instances in private subnets to initiate outbound traffic to internet
4. **B** - NACLs are subnet-level stateless firewalls, Security Groups are instance-level stateful firewalls
5. **C** - VPC peering provides direct network route using private IP addresses, no internet gateway needed

### Scenario-Based Questions
6. **D** - Minimum 2 AZs for HA, but 3 AZs recommended for better distribution and fault tolerance across tiers
7. **B** - Web servers in public subnets (for internet access), app and database in private sublets (for security)
8. **C** - Bastion host in public subnet provides secure jump point to access private instances
9. **B** - /23 subnet provides 512 total addresses, ~500 usable after reserving network and broadcast addresses
10. **D** - Inter-region VPC Peering allows secure communication between VPCs in different AWS regions

## Explanations

### Question 1: VPC CIDR Block Limits
AWS allows VPC CIDR blocks from /16 to /28:
- /16: 65,536 IP addresses (10.0.0.0 - 10.0.255.255)
- /17: 32,768 IP addresses
- /18: 16,384 IP addresses
- /19: 8,192 IP addresses
- /20: 4,096 IP addresses
- /21: 2,048 IP addresses
- /22: 1,024 IP addresses
- /23: 512 IP addresses
- /24: 256 IP addresses
- /25: 128 IP addresses
- /26: 64 IP addresses
- /27: 32 IP addresses
- /28: 16 IP addresses

You cannot have a VPC larger than /16 or smaller than /28.

### Question 2: Subnet Limits Per VPC
The default limit is 100 subnets per VPC. This limit can be increased by contacting AWS Support. Each subnet must reside in a single Availability Zone, and you can have multiple subnets per AZ.

### Question 3: NAT Gateway Purpose
NAT (Network Address Translation) Gateway allows instances in private subnets to:
- Initiate outbound IPv4 traffic to the internet (for updates, patches, etc.)
- Prevent inbound internet traffic from reaching those instances
- Provide high availability and automatic scaling (managed service)
- Replace the need for self-managed NAT instances

### Question 4: NACL vs Security Group Differences
**Network ACLs (Subnet Level):**
- Stateless: Return traffic must be explicitly allowed by rules
- Evaluated in rule number order (lowest first)
- Separate inbound and outbound rule sets
- Default: Allow all inbound and outbound traffic
- One NACL can be associated with multiple subnets

**Security Groups (Instance Level):**
- Stateful: Return traffic automatically allowed if corresponding outbound traffic was allowed
- All rules evaluated before allowing traffic
- Default: Deny all inbound, allow all outbound (to same security group)
- Can have multiple security groups per instance
- Can reference other security groups in the same VPC

### Question 5: VPC Peering Mechanics
VPC peering creates a direct network route between two VPCs:
- Uses private IP addresses for communication
- No internet gateway, VPN, or AWS Direct Connect needed
- Traffic stays within AWS global network
- Not transitive: If A↔B and B↔C, then A↔/C (no direct route)
- Must not have overlapping CIDR blocks
- Can peer VPCs in same or different accounts
- Can peer VPCs in same or different regions (inter-region peering)

### Question 6: Multi-AZ Design for 3-Tier Application
For high availability in a 3-tier architecture:
- **Minimum 2 AZs**: Provides basic fault tolerance (if one AZ fails, other can take over)
- **Recommended 3 AZs**: Better distribution of resources across tiers
  - Web tier: Distribute across all 3 AZs
  - App tier: Distribute across all 3 AZs  
  - Database tier: Use Multi-AZ RDS or distribute read replicas
- Benefits: Improved fault tolerance, better load distribution, reduced blast radius

### Question 7: Public/Private Subnet Segmentation
Standard 3-tier web application architecture:
- **Public Subnets**: Web servers (need direct internet access for HTTP/HTTPS)
- **Private Subnets**: 
  - Application servers (business logic, APIs)
  - Database servers (data storage - should never be directly internet-accessible)
- **Bastion Host**: In public subnet for secure administration access to private instances
- **NAT Gateway**: In public subnet to allow private instances outbound internet access

### Question 8: Accessing Private Instances
Best practices for accessing instances in private subnets:
1. **Bastion/Jump Host**: Most common approach
   - Place in public subnet with restricted security group
   - Use SSH agent forwarding or SSH jump configuration
   - Monitor and log all access attempts
2. **AWS Systems Manager Session Manager**: Alternative approach
   - No need to open inbound ports
   - Uses IAM roles for authentication
   - Provides detailed logging and session recording
3. **Avoid**: Assigning public IPs to private instances (defeats purpose of private subnet)

### Question 9: Subnet Sizing Calculation
For approximately 500 IP addresses needed:
- /24 subnet: 256 total addresses (254 usable) - **INSUFFICIENT**
- /23 subnet: 512 total addresses (510 usable) - **SUFFICIENT** 
- /22 subnet: 1024 total addresses (1022 usable) - **WASTEFUL** (~50% unused)
- /25 subnet: 128 total addresses (126 usable) - **INSUFFICIENT>

Remember: First and last addresses in subnet are reserved (network and broadcast), so usable addresses = 2^(32-prefix) - 2

### Question 10: Inter-Region VPC Communication
For secure communication between VPCs in different regions:
- **Inter-Region VPC Peering**: 
  - Direct private network connection
  - Traffic encrypted and stays within AWS network
  - No single point of failure or bandwidth bottleneck
  - Supports transitive routing via route tables
- **AWS Direct Connect**: Requires physical connection to AWS locations
- **Site-to-Site VPN**: Encrypts traffic but goes over public internet
- **VPC Peering (same-region only)**: Would not work for different regions

## Additional VPC Best Practices for Interviews

### CIDR Planning
- Plan for growth: Leave room between subnets for future expansion
- Use hierarchical addressing: 10.0.0.0/16 → 10.0.[0-255].0/24 subnets
- Avoid overlapping with corporate networks if connecting via VPN/Direct Connect
- Consider using different octets for different environments (dev/test/prod)

### Security Best Practices
- Principle of least privilege: Start with deny all, add only necessary rules
- Security groups: Reference other SGs when possible instead of CIDR blocks
- NACLs: Use for subnet-level baseline protection (e.g., block known bad IPs)
- Flow Logs: Enable for monitoring and troubleshooting
- VPC Endpoints: Use for S3/DynamoDB to keep traffic off internet

### High Availability Patterns
- **Public Subnets**: At least 2 (one per AZ) for load balancer redundancy
- **Private Subnets**: At least 2 (one per AZ) for application redundancy
- **NAT Gateways**: At least 2 (one per AZ) for outbound internet redundancy
- **Internet Gateways**: Single IGW per VPC is sufficient (highly available by design)
- **Route Tables**: Main + custom tables for different subnet types

### Cost Optimization
- Right-size subnets: Don't allocate more IPs than needed
- Share route tables: Subnets with same routing requirements can share tables
- Elastic IPs: Only allocate when necessary (attached to running resources)
- NAT Gateways: Consider NAT instances for low-throughput, cost-sensitive workloads
- VPC Peering: Use instead of data transfer charges for inter-VPC communication