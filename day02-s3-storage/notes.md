# Day 2: S3 Storage

## Study Notes (60 minutes)

### Amazon S3 Overview
Simple Storage Service (S3) is object storage built to store and retrieve any amount of data from anywhere. It's designed for 99.999999999% (11 nines) durability and scales automatically.

### Key Concepts

#### Buckets and Objects
- **Buckets**: Containers for objects (similar to folders, but flat namespace)
- **Objects**: Files stored in S3 consisting of data, key (name), and metadata
- **Key**: Unique identifier for an object within a bucket
- **Version ID**: Added when versioning is enabled to distinguish between object versions

#### Storage Classes
S3 offers different storage classes for various use cases and cost optimization:

1. **S3 Standard**: General purpose, 99.99% availability
2. **S3 Standard-IA (Infrequent Access)**: For data accessed less frequently, lower storage cost
3. **S3 One Zone-IA**: Similar to Standard-IA but stores data in a single AZ (lower cost, lower resilience)
4. **S3 Intelligent-Tiering**: Automatically moves data between access tiers based on changing patterns
5. **S3 Glacier**: Low-cost storage for data archiving (minutes to hours retrieval)
6. **S3 Glacier Deep Archive**: Lowest cost for long-term retention (hours to hours retrieval)

#### Data Consistency Model
S3 provides:
- **Read-after-write consistency** for PUTS of new objects
- **Eventual consistency** for overwrite PUTS and DELETES (can take seconds to propagate)

#### Bucket Policies and Access Control
- **Bucket Policies**: JSON-based policies for granting permissions to buckets and objects
- **ACLs (Access Control Lists)**: Legacy mechanism for granting read/write permissions
- **Access Points**: Named network endpoints with dedicated policies for accessing shared datasets

#### Encryption Options
- **SSE-S3**: Server-side encryption with S3-managed keys (AES-256)
- **SSE-KMS**: Server-side encryption with AWS KMS-managed keys
- **SSE-C**: Server-side encryption with customer-provided keys
- **Client-Side Encryption**: Encrypt data before uploading to S3

#### Transfer Acceleration
Uses CloudFront edge network to accelerate uploads to S3 over long distances.

#### Cross-Region Replication (CRR)
Automatically copies objects across buckets in different AWS regions for disaster recovery or lower latency access.

#### S3 Batch Operations
Manage billions of objects at scale with a single S3 Batch Operations request.

#### Event Notifications
Trigger AWS Lambda, SQS, SNS, or HTTP endpoints when specific events occur in S3.

## Practice Questions Overview (30 minutes)

### Multiple Choice Questions

1. **What is the default storage class for S3?**
   - A) S3 Standard-IA
   - B) S3 Standard
   - C) S3 One Zone-IA
   - D) S3 Intelligent-Tiering

2. **How does S3 provide read-after-write consistency?**
   - A) By immediately replicating data to all regions
   - B) By ensuring that a read immediately after a write sees the written data
   - C) By using eventual consistency model
   - D) S3 does not provide read-after-write consistency

3. **What is the maximum size of a single S3 object?**
   - A) 2 GB
   - B) 5 GB
   - C) 5 TB
   - D) Unlimited

4. **Which S3 feature protects against accidental deletion?**
   - A) Versioning
   - B) Cross-region replication
   - C) Lifecycle policies
   - D) Transfer acceleration

5. **How can you serve static website content from S3?**
   - A) By enabling static website hosting on the bucket
   - B) By using CloudFront distribution only
   - C) By configuring bucket policy for public read access
   - D) Both A and C

### Answers
1. B) S3 Standard
2. B) By ensuring that a read immediately after a write sees the written data
3. C) 5 TB
4. A) Versioning
5. D) Both A and C

## Hands-On Exercise Overview (60 minutes)
1. Create an S3 bucket
2. Enable versioning
3. Upload a file
4. Set a lifecycle policy to transition to Glacier after 30 days
5. Configure static website hosting

## GitHub Commit Instructions (15 minutes)
Add day2 notes, a CloudFormation template for S3 bucket with versioning, commit and push