# Day 2: S3 Hands-On Exercise

## Objective
Create an S3 bucket, enable versioning, upload a file, set a lifecycle policy to transition to Glacier after 30 days, and configure static website hosting.

## Prerequisites
- AWS Account with Free Tier eligibility
- AWS CLI installed and configured (`aws configure`)
- Basic Linux/CLI knowledge

## Estimated Time: 60 minutes

## Exercise Steps

### Part 1: Preparation (10 minutes)

#### Step 1: Verify AWS CLI Configuration
```bash
aws sts get-caller-identity
```
Expected output should show your Account ID and User/Role ARN.

#### Step 2: Choose a Unique Bucket Name
S3 bucket names must be globally unique across all AWS accounts.
```bash
# Generate a unique bucket name using timestamp
BUCKET_NAME="aws-interview-prep-s3-$(date +%s)"
echo "Using bucket name: $BUCKET_NAME"
```

### Part 2: Create and Configure S3 Bucket (20 minutes)

#### Step 3: Create S3 Bucket
```bash
# Create bucket in us-east-1 (default region)
aws s3api create-bucket --bucket $BUCKET_NAME --region us-east-1

echo "Created bucket: $BUCKET_NAME"
```

#### Step 4: Enable Versioning
```bash
aws s3api put-bucket-versioning \
    --bucket $BUCKET_NAME \
    --versioning-configuration Status=Enabled

echo "Enabled versioning for bucket: $BUCKET_NAME"
```

#### Step 5: Create Test Files
```bash
# Create a simple HTML file for website hosting
cat > index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AWS S3 Static Website</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 40px;
            background-color: #f8f9fa;
        }
        .container {
            max-width: 600px;
            margin: 0 auto;
            text-align: center;
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        }
        h1 {
            color: #ff9900;
        }
        .info {
            background-color: #e7f3ff;
            border-left: 4px solid #ff9900;
            padding: 15px;
            margin: 20px 0;
            text-align: left;
        }
        .footer {
            margin-top: 30px;
            color: #666;
            font-size: 0.9em;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Welcome to AWS S3!</h1>
        <div class="info">
            <h2>Static Website Hosting Demo</h2>
            <p>This website is hosted entirely on Amazon S3 using static website hosting.</p>
            <p><strong>Bucket Name:</strong> '"$BUCKET_NAME"'</p>
            <p><strong>Region:</strong> us-east-1</p>
            <p><strong>Features Demonstrated:</strong></p>
            <ul>
                <li>S3 Bucket Creation</li>
                <li>Versioning Enabled</li>
                <li>Static Website Hosting</li>
                <li>Lifecycle Policies</li>
            </ul>
        </div>
        
        <div class="info">
            <h2>S3 Storage Classes</h2>
            <p>Objects in this bucket will transition through different storage classes based on age:</p>
            <ul>
                <li>Days 0-30: S3 Standard (frequent access)</li>
                <li>After 30 days: S3 Glacier (archival storage)</li>
            </ul>
        </div>
    </div>
    
    <div class="footer">
        <p>AWS Cloud Engineer Interview Preparation - Day 2: S3 Storage</p>
        <p>Generated on: '"$(date)"'</p>
    </div>
</body>
</html>
EOF

# Create a text document for versioning demo
cat > document.txt << 'EOF'
This is version 1 of the document.
Created for AWS S3 versioning demonstration.

Timestamp: $(date)
EOF

echo "Created test files: index.html and document.txt"
```

#### Step 6: Upload Files to S3 Bucket
```bash
# Upload the HTML file
aws s3 cp index.html s3://$BUCKET_NAME/index.html

# Upload the text document
aws s3 cp document.txt s3://$BUCKET_NAME/document.txt

echo "Uploaded files to bucket: $BUCKET_NAME"
```

#### Step 7: Verify Upload and Enable Versioning Check
```bash
# List objects in bucket
echo "Objects in bucket:"
aws s3 ls s3://$BUCKET_NAME/

# Check versioning status
echo "Versioning status:"
aws s3api get-bucket-versioning --bucket $BUCKET_NAME
```

#### Step 8: Demonstrate Versioning
```bash
# Create version 2 of the document
cat > document-v2.txt << 'EOF'
This is version 2 of the document.
Updated content for AWS S3 versioning demonstration.

Changes made:
- Added more detailed explanation
- Fixed typo in original text
- Updated timestamp

Timestamp: $(date)
EOF

# Upload as new version (same key)
aws s3 cp document-v2.txt s3://$BUCKET_NAME/document.txt

echo "Uploaded version 2 of document.txt"

# List all versions
echo "All versions of document.txt:"
aws s3api list-object-versions --bucket $BUCKET_NAME --prefix document.txt
```

#### Step 9: Set Lifecycle Policy
```bash
# Create lifecycle policy JSON
cat > lifecycle-policy.json << 'EOF'
{
    "Rules": [
        {
            "ID": "TransitionToGlacierAfter30Days",
            "Status": "Enabled",
            "Filter": {},
            "Transitions": [
                {
                    "Days": 30,
                    "StorageClass": "GLACIER"
                }
            ]
        }
    ]
}
EOF

# Apply lifecycle policy
aws s3api put-bucket-lifecycle-configuration \
    --bucket $BUCKET_NAME \
    --lifecycle-configuration file://lifecycle-policy.json

echo "Applied lifecycle policy to transition objects to Glacier after 30 days"

# Verify lifecycle policy
echo "Lifecycle policy:"
aws s3api get-bucket-lifecycle-configuration --bucket $BUCKET_NAME
```

#### Step 10: Configure Static Website Hosting
```bash
# Configure bucket for website hosting
aws s3 website s3://$BUCKET_NAME/ \
    --index-document index.html \
    --error-document index.html

echo "Configured static website hosting"

# Get website endpoint
WEBSITE_ENDPOINT="$BUCKET_NAME.s3-website-us-east-1.amazonaws.com"
echo "Website endpoint: http://$WEBSITE_ENDPOINT"

# Set bucket policy for public read access (required for website hosting)
cat > bucket-policy.json << 'EOF'
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::'"$BUCKET_NAME"'/*"
        }
    ]
}
EOF

# Apply bucket policy
aws s3api put-bucket-policy \
    --bucket $BUCKET_NAME \
    --policy file://bucket-policy.json

echo "Applied public read bucket policy for website access"
```

#### Step 11: Test Static Website
```bash
# Test website accessibility
echo "Testing website at: http://$WEBSITE_ENDPOINT"
curl -s http://$WEBSITE_ENDPOINT | grep -i "welcome to aws s3" && echo "✓ Website accessible and serving correct content" || echo "✗ Website test failed"

# Alternative test using AWS CLI
echo "Alternative test - check if website configuration exists:"
aws s3api get-bucket-website --bucket $BUCKET_NAME
```

### Part 3: Verification and Cleanup (10 minutes)

#### Step 12: Final Verification
```bash
echo "=== FINAL VERIFICATION ==="
echo "Bucket Name: $BUCKET_NAME"
echo "Region: us-east-1"
echo ""
echo "Configuration Status:"
echo "- Versioning: Enabled"
echo "- Lifecycle Policy: Transition to Glacier after 30 days"
echo "- Static Website Hosting: Enabled"
echo "- Public Read Access: Configured"
echo ""
echo "Objects in bucket:"
aws s3 ls s3://$BUCKET_NAME/ --human-readable --summarize
echo ""
echo "Website URL: http://$WEBSITE_ENDPOINT"
echo ""
echo "To test the website, open in browser: http://$WEBSITE_ENDPOINT"
```

#### Step 13: Optional Cleanup
```bash
# To delete all objects and the bucket when you're done:
# echo "Deleting all objects from bucket..."
# aws s3 rm s3://$BUCKET_NAME/ --recursive
# 
# echo "Deleting bucket..."
# aws s3 rb s3://$BUCKET_NAME
# 
# echo "Cleanup complete!"
```

## Expected Outcomes

By completing this exercise, you should have:

1. ✅ A uniquely named S3 bucket
2. ✅ Versioning enabled on the bucket
3. ✅ Two objects uploaded (index.html and document.txt with multiple versions)
4. ✅ Lifecycle policy configured to transition objects to Glacier after 30 days
5. ✅ Static website hosting enabled and configured
6. ✅ Public read access configured via bucket policy
7. ✅ Accessible static website at the S3 website endpoint

## Troubleshooting Tips

### Bucket Creation Issues
- **Bucket name already exists**: S3 bucket names must be globally unique. Try a different name or add more randomness.
- **Invalid bucket name**: Bucket names must comply with DNS naming conventions (lowercase, numbers, hyphens, 3-63 characters).
- **Region mismatch**: When creating buckets in regions other than us-east-1, you must specify the location constraint.

### Versioning Issues
- **Versioning not showing**: Ensure you used `put-bucket-versioning` with `Status=Enabled`
- **Not seeing multiple versions**: Make sure you're uploading to the same key (filename) to create new versions

### Lifecycle Policy Issues
- **Policy not applying**: Verify the JSON format is correct and you used `put-bucket-lifecycle-configuration`
- **Transitions not working**: Lifecycle policies take effect within 24 hours; don't expect immediate transitions

### Website Hosting Issues
- **Access denied errors**: Ensure you have both website hosting configured AND a bucket policy granting public read access
- **Website endpoint not working**: Verify you used the correct website endpoint format: `bucket-name.s3-website-region.amazonaws.com`
- **Error documents not showing**: Make sure you specified both index and error documents in the website configuration

### Permission Issues
- **Access Denied**: Check that your IAM user/role has permissions for:
  - s3:CreateBucket, s3:PutBucketVersioning
  - s3:PutObject, s3:GetObject
  - s3:PutBucketLifecycleConfiguration
  - s3:PutBucketWebsite, s3:PutBucketPolicy
  - s3:GetBucketLocation

## Extension Activities (Optional)

If you complete the basic exercise early, try these extensions:

1. **Cross-Region Replication**: Set up CRR to replicate your bucket to another region
2. **S3 Batch Operations**: Use batch operations to add tags to all objects
3. **Event Notifications**: Configure S3 to trigger Lambda when objects are uploaded
4. **Access Logs**: Enable access logging for your bucket and analyze with Athena
5. **Encryption**: Enable default encryption (SSE-S3 or SSE-KMS) for your bucket
6. **Object Lock**: Explore S3 Object Lock for compliance and governance use cases

## GitHub Commit Instructions

After completing the exercise, update these files:

1. `day02-s3-storage/notes.md` - Add any notes or observations from your hands-on experience
2. `day02-s3-storage/templates/s3-bucket-cf.yaml` - Save the CloudFormation template
3. `day02-s3-storage/scripts/create-bucket.sh` - Save the AWS CLI commands you used
4. `day02-s3-storage/scripts/verify-setup.sh` - Save verification commands

Then commit and push:
```bash
git add day02-s3-storage/
git commit -m "Day 2: S3 Hands-On Exercise completed - created bucket, enabled versioning, configured lifecycle policy and static website hosting"
git push origin main
```