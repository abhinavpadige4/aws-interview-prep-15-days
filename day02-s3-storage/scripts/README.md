# Day 2: S3 Scripts

This directory contains AWS CLI and shell scripts for the S3 hands-on exercise.

## Scripts Included

### create-bucket.sh
Creates an S3 bucket with:
- Versioning enabled
- Lifecycle policy (transition to Glacier after 30 days)
- Static website hosting configured
- Public read access via bucket policy
- Sample website content uploaded

### verify-setup.sh
Verifies that the S3 bucket is properly configured:
- Checks bucket existence
- Verifies versioning status
- Confirms lifecycle configuration
- Validates website hosting setup
- Checks bucket policy for public read access
- Tests website accessibility
- Provides detailed verification report

## Usage Instructions

### Prerequisites
- AWS CLI installed and configured (`aws configure`)
- Appropriate IAM permissions for S3 operations

### Make Scripts Executable
```bash
chmod +x create-bucket.sh verify-setup.sh
```

### Create S3 Bucket
```bash
./create-bucket.sh
```
This will:
1. Create a uniquely named bucket (aws-interview-prep-s3-<timestamp>)
2. Enable versioning
3. Apply lifecycle policy (transition to Glacier after 30 days)
4. Configure static website hosting
5. Set public read access via bucket policy
6. Upload sample website content
7. Output the website URL for testing

### Verify S3 Bucket Setup
```bash
./verify-setup.sh <bucket-name>
```
Replace `<bucket-name>` with the name of the bucket you created (output from create-bucket.sh).

This script performs comprehensive checks:
- Bucket existence and accessibility
- Versioning status
- Lifecycle configuration (30-day transition to Glacier)
- Website hosting configuration
- Bucket policy for public read access
- Object count and size
- Website accessibility test

## Expected Workflow

1. **Create the bucket**: Run `./create-bucket.sh`
2. **Note the bucket name**: From the output (e.g., aws-interview-prep-s3-1234567890)
3. **Verify the setup**: Run `./verify-setup.sh aws-interview-prep-s3-1234567890`
4. **Test the website**: Open the provided URL in your browser or use curl
5. **Experiment with versioning**: Upload the same file multiple times to see versions
6. **Cleanup when done**: Delete objects and bucket to avoid charges

## Expected Outcomes from create-bucket.sh

After running the creation script, you should have:

1. ✅ A uniquely named S3 bucket in us-east-1
2. ✅ Versioning enabled on the bucket
3. ✅ Lifecycle policy configured to transition objects to Glacier after 30 days
4. ✅ Static website hosting enabled (index.html and error.html)
5. ✅ Public read access configured via bucket policy
6. ✅ Sample website content uploaded
7. ✅ Website URL provided for testing

## Verification Checkpoints

The verify-setup.sh script checks for:

1. **Bucket Existence**: Confirms the bucket exists and is accessible
2. **Versioning Status**: Verifies versioning is enabled
3. **Lifecycle Configuration**: Checks for 30-day transition to Glacier rule
4. **Website Hosting**: Confirms static website hosting is configured
5. **Bucket Policy**: Validates public read access is granted
6. **Object Presence**: Ensures content has been uploaded
7. **Website Accessibility**: Tests that the website loads successfully

## Extension Activities (Optional)

If you complete the basic exercise early, try these extensions:

1. **Versioning Demo**: 
   ```bash
   # Upload same file multiple times
   echo "Version 1" > test.txt
   aws s3 cp test.txt s3://<bucket-name>/test.txt
   echo "Version 2" > test.txt
   aws s3 cp test.txt s3://<bucket-name>/test.txt
   
   # Check versions
   aws s3api list-object-versions --bucket <bucket-name> --prefix test.txt
   ```

2. **Lifecycle Policy Testing** (Note: Actual transition takes 24+ hours):
   ```bash
   # Check current storage class
   aws s3api head-object --bucket <bucket-name> --key <object-key> --query 'StorageClass'
   ```

3. **Cross-Region Replication Setup**:
   - Create destination bucket in another region
   - Set up replication rule via AWS Console or CLI

4. **Event Notifications**:
   - Configure S3 to trigger Lambda function on object creation
   - Test with simple Lambda function that logs events

5. **Access Logging**:
   - Enable access logging for the bucket
   - Analyze logs with Amazon Athena

6. **Encryption**:
   - Enable default encryption (SSE-S3 or SSE-KMS)
   - Verify objects are encrypted at rest

## Safety Notes
- The script uses us-east-1 region by default (free tier eligible)
- Bucket names are timestamp-based to ensure uniqueness
- Public read access is required for static website hosting
- Remember to delete objects and bucket when done to avoid charges
- Lifecycle transitions to Glacier take effect within 24 hours