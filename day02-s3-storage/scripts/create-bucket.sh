#!/bin/bash
# Day 2: S3 Bucket Creation Script
# This script creates an S3 bucket with versioning, lifecycle policy, and static website hosting using AWS CLI

set -euo pipefail

echo "=== S3 Bucket Creation Script ==="
echo "This script will create an S3 bucket with versioning, lifecycle policy, and static website hosting"

# Check if AWS CLI is configured
if ! aws sts get-caller-identity &> /dev/null; then
    echo "Error: AWS CLI not configured. Please run 'aws configure' first."
    exit 1
fi

# Variables
TIMESTAMP=$(date +%s)
BUCKET_NAME="aws-interview-prep-s3-${TIMESTAMP}"
REGION="us-east-1"

echo "Using bucket name: $BUCKET_NAME"
echo "Using region: $REGION"

# Create S3 bucket
echo "Creating S3 bucket..."
if [ "$REGION" = "us-east-1" ]; then
    # us-east-1 doesn't require CreateBucketConfiguration
    aws s3api create-bucket --bucket "$BUCKET_NAME" --region "$REGION"
else
    aws s3api create-bucket \
        --bucket "$BUCKET_NAME" \
        --region "$REGION" \
        --create-bucket-configuration LocationConstraint="$REGION"
fi

echo "✓ Bucket created: $BUCKET_NAME"

# Enable versioning
echo "Enabling versioning..."
aws s3api put-bucket-versioning \
    --bucket "$BUCKET_NAME" \
    --versioning-configuration Status=Enabled

echo "✓ Versioning enabled"

# Create lifecycle policy
echo "Creating lifecycle policy..."
cat > lifecycle-policy.json << EOF
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

aws s3api put-bucket-lifecycle-configuration \
    --bucket "$BUCKET_NAME" \
    --lifecycle-configuration file://lifecycle-policy.json

echo "✓ Lifecycle policy applied (transition to Glacier after 30 days)"

# Clean up lifecycle policy file
rm lifecycle-policy.json

# Configure static website hosting
echo "Configuring static website hosting..."
aws s3 website s3://"$BUCKET_NAME"/ \
    --index-document index.html \
    --error-document index.html

echo "✓ Static website hosting configured"

# Create sample website content
echo "Creating sample website content..."
cat > index.html << EOF
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
            <p><strong>Bucket Name:</strong> $BUCKET_NAME</p>
            <p><strong>Region:</strong> $REGION</p>
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
        <p>Generated on: $(date)</p>
    </div>
</body>
</html>
EOF

# Upload website content
echo "Uploading website content..."
aws s3 cp index.html s3://"$BUCKET_NAME"/index.html

# Clean up local file
rm index.html

# Set bucket policy for public read access (required for website hosting)
echo "Setting bucket policy for public read access..."
cat > bucket-policy.json << EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::${BUCKET_NAME}/*"
        }
    ]
}
EOF

aws s3api put-bucket-policy \
    --bucket "$BUCKET_NAME" \
    --policy file://bucket-policy.json

# Clean up policy file
rm bucket-policy.json

echo "✓ Public read access configured for website hosting"

# Get website endpoint
WEBSITE_ENDPOINT="${BUCKET_NAME}.s3-website-${REGION}.amazonaws.com"
echo ""
echo "=== SETUP COMPLETE ==="
echo "Bucket Name: $BUCKET_NAME"
echo "Region: $REGION"
echo ""
echo "Configuration Summary:"
echo "✓ Versioning: Enabled"
echo "✓ Lifecycle Policy: Transition to Glacier after 30 days"
echo "✓ Static Website Hosting: Enabled"
echo "✓ Public Read Access: Configured"
echo ""
echo "Website URL: http://$WEBSITE_ENDPOINT"
echo ""
echo "Next Steps:"
echo "1. Upload additional content: aws s3 cp <local-file> s3://$BUCKET_NAME/<remote-path>"
echo "2. Test website: curl http://$WEBSITE_ENDPOINT or open in browser"
echo "3. Enable versioning demo: Upload same file multiple times to see versions"
echo "4. Check lifecycle: Objects will transition to Glacier after 30 days"
echo ""
echo "To cleanup when done:"
echo "aws s3 rm s3://$BUCKET_NAME/ --recursive"
echo "aws s3 rb s3://$BUCKET_NAME"