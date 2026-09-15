# Day 2: S3 Practice Questions

## Multiple Choice Questions

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

## Scenario-Based Questions

6. **You need to store log files that are accessed frequently for the first 30 days, then infrequently for compliance purposes. Which storage class strategy would be most cost-effective?**
   - A) Keep all logs in S3 Standard
   - B) Use S3 Intelligent-Tiering
   - C) Use S3 Standard for 30 days, then transition to S3 Standard-IA
   - D) Use S3 Standard for 30 days, then transition to S3 Glacier

7. **Your company needs to retain financial records for 7 years for regulatory compliance. The records are rarely accessed but must be retrievable within 4 hours when needed. Which storage class is most appropriate?**
   - A) S3 Standard
   - B) S3 Standard-IA
   - C) S3 Glacier
   - D) S3 Glacier Deep Archive

8. **You have a global application that serves users from North America, Europe, and Asia. You want to reduce latency for users accessing static assets. Which S3 feature would help most?**
   - A) Cross-Region Replication
   - B) Transfer Acceleration
   - C) S3 Batch Operations
   - D) S3 Access Points

9. **A developer accidentally overwrote a critical configuration file in S3. Which feature would have allowed them to recover the previous version?**
   - A) S3 Object Lock
   - B) Versioning
   - C) Cross-region replication
   - D) Lifecycle policies

10. **You need to process 100,000 objects in S3 to add metadata tags based on file content. Which approach would be most efficient?**
    - A) Write a script to download, process, and re-upload each object
    - B) Use S3 Batch Operations with AWS Lambda function
    - C) Use S3 Select to filter and modify objects in place
    - D) Manually process objects through the AWS Console

## Answers

### Multiple Choice Questions
1. **B** - S3 Standard is the default storage class
2. **B** - Read-after-write consistency ensures a read immediately after a write sees the written data
3. **C** - Maximum size of a single S3 object is 5 TB
4. **A** - Versioning protects against accidental deletion by preserving previous versions
5. **D** - Both enabling static website hosting AND configuring public read access via bucket policy are required

### Scenario-Based Questions
6. **C** - Use S3 Standard for 30 days (frequent access), then transition to S3 Standard-IA (infrequent access) for cost optimization
7. **C** - S3 Glacier provides low-cost storage with retrieval times from minutes to hours (expedited retrieval available)
8. **A** - Cross-Region Replication creates copies in different regions for lower latency access
9. **B** - Versioning preserves every version of an object, allowing recovery from accidental overwrites or deletions
10. **B** - S3 Batch Operations can process billions of objects with a Lambda function for custom processing

## Explanations

### Question 1: Default Storage Class
S3 Standard is the default storage class because it provides the best balance of performance, availability, and cost for general-purpose workloads. It offers 99.99% availability and 99.999999999% durability.

### Question 2: Read-After-Write Consistency
When you successfully write a new object to S3 and immediately read it, you will get the written data. This applies only to new object writes (PUTS), not to overwrites or deletes. For overwrite PUTS and DELETES, S3 offers eventual consistency.

### Question 3: Object Size Limit
The maximum size of a single S3 object is 5 TB. For objects larger than 100 MB, AWS recommends using the multipart upload capability. Objects can be as small as 0 bytes.

### Question 4: Accidental Deletion Protection
Versioning in S3 preserves every version of every object in the bucket. When you enable versioning, S3 automatically assigns a unique version ID to each object. Even if an object is "deleted," S3 inserts a delete marker, and the original object remains accessible via its version ID.

### Question 5: Static Website Hosting
To serve a static website from S3:
1. Enable static website hosting on the bucket properties
2. Configure a bucket policy that grants public read access to the objects
3. Upload your website files (HTML, CSS, JS, images) to the bucket
4. Optionally configure error documents (404, 500 pages)

### Question 6: Log File Storage Strategy
For log files with changing access patterns:
- First 30 days: Frequently accessed for debugging/monitoring → S3 Standard
- After 30 days: Infrequently accessed for compliance → S3 Standard-IA
This lifecycle policy optimizes cost while maintaining appropriate performance.

### Question 7: Long-Term Archival Storage
S3 Glacier is designed for data archiving with:
- Low storage cost
- Retrieval options from minutes to hours
- Expedited retrieval (1-5 minutes) available for additional cost
- Suitable for regulatory compliance with infrequent access needs

### Question 8: Global Latency Reduction
Cross-Region Replication (CRR) automatically copies objects to destination buckets in different AWS regions. Users can then access the geographically closest copy for lower latency.

### Question 9: Accidental Overwrite Recovery
Versioning is the primary protection against accidental overwrites and deletes. When versioning is enabled:
- Each write creates a new version
- Previous versions are preserved
- Deleted objects have delete markers but original data remains accessible
- You can restore previous versions by copying them or removing delete markers

### Question 10: Large-Scale Object Processing
S3 Batch Operations allows you to:
- Process billions of objects with a single request
- Define custom actions using AWS Lambda functions
- Track progress and completion reports
- Handle failures and partial completions gracefully
This is far more efficient than individual object processing.