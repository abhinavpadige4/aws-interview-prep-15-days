# Day 1: EC2 Practice Questions

## Multiple Choice Questions

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

## Scenario-Based Questions

6. **You need to run a batch processing job that can tolerate interruptions and needs to complete within a flexible time window. Which EC2 purchasing option would be most cost-effective?**
   - A) On-Demand Instances
   - B) Reserved Instances
   - C) Spot Instances
   - D) Dedicated Hosts

7. **Your application requires consistent baseline performance with the ability to burst above that baseline when needed. Which instance type family would be most appropriate?**
   - A) Compute Optimized (C5)
   - B) Memory Optimized (R5)
   - C) General Purpose (T3)
   - D) Storage Optimized (I3)

8. **You need to ensure that your EC2 instances in different Availability Zones can communicate with each other using private IP addresses. What should you configure?**
   - A) Elastic IP addresses
   - B) Security groups referencing other security groups
   - C) VPC peering connections
   - D) Route table entries for inter-AZ communication

9. **Which of the following statements about Amazon Machine Images (AMIs) is TRUE?**
   - A) AMIs can only be created from running instances
   - B) AMIs are region-specific resources
   - C) You cannot share AMIs with other AWS accounts
   - D) AMIs include both the operating system and any additional software

10. **You launched an EC2 instance but cannot connect to it via SSH. Which of the following is LEAST likely to be the cause?**
    - A) Incorrect key pair used
    - B) Security group blocking port 22
    - C) Instance is in a stopped state
    - D) Network ACL blocking the traffic

## Answers

### Multiple Choice Questions
1. **B** - Stopped instances preserve EBS volumes (you're charged for storage), terminated instances delete them
2. **C** - Both methods work: allocate through console or modify network interface
3. **D** - Spot Instances can offer up to 90% discount compared to On-Demand
4. **A** - Default limit is 500 security groups per region (can be increased upon request)
5. **C** - Both methods: enable via CloudWatch console or set to 1-minute interval during launch

### Scenario-Based Questions
6. **C** - Spot Instances are ideal for fault-tolerant, flexible workloads with significant cost savings
7. **C** - T3 instances are burstable general purpose instances that provide baseline performance with ability to burst
8. **B** - Security groups can reference other security groups in the same VPC for inter-AZ communication using private IPs
9. **D** - AMIs are regional but can be copied, include OS and additional software, and can be shared with specific accounts
10. **C** - If instance is stopped, you wouldn't be trying to connect via SSH (would get connection refused immediately)

## Explanations

### Question 1: Stop vs Terminate
When you stop an instance, AWS preserves the root device and any attached EBS volumes. You're not charged for instance usage, but you are charged for EBS volume storage. When you terminate an instance, AWS automatically deletes the root EBS volume (unless you've changed the default behavior) and any attached EBS volumes that have the "DeleteOnTermination" attribute set to true.

### Question 3: Purchasing Options
Spot Instances allow you to bid on unused EC2 capacity. When your bid exceeds the current Spot price, your instance runs. If the Spot price rises above your bid, AWS may terminate your instance with a 2-minute warning. This makes them perfect for batch processing, data analysis, and other fault-tolerant workloads.

### Question 4: Security Group Limits
The default limit of 500 security groups per region applies to the number of security groups you can create. Each security group can have up to 60 inbound rules and 60 outbound rules. These limits can be increased by contacting AWS Support.

### Question 6: Batch Processing
Spot Instances are ideal for workloads that:
- Can tolerate interruptions
- Have flexible start/end times
- Are stateless or can checkpoint progress
- Would benefit from significant cost savings (up to 90% off On-Demand)

Examples include: data processing, rendering, testing, scientific simulations, and batch jobs.