#!/bin/bash
# Day 2: S3 Setup Verification Script
# This script verifies that the S3 bucket is properly configured with versioning, lifecycle policy, and website hosting

set -euo pipefail

echo "=== S3 Setup Verification ==="

# Check if bucket name is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <bucket-name>"
    echo "Example: $0 aws-interview-prep-s3-1234567890"
    exit 1
fi

BUCKET_NAME=$1
REGION=$(aws configure get region)
if [ -z "$REGION" ]; then
    REGION="us-east-1"  # Default region
fi

echo "Verifying bucket: $BUCKET_NAME"
echo "Region: $REGION"
echo ""

# Check if bucket exists
echo "1. Checking if bucket exists..."
if aws s3api head-bucket --bucket "$BUCKET_NAME" &> /dev/null; then
    echo "✓ Bucket exists"
else
    echo "✗ Bucket does not exist or access denied"
    exit 1
fi

# Check versioning status
echo "2. Checking versioning status..."
VERSIONING_STATUS=$(aws s3api get-bucket-versioning --bucket "$BUCKET_NAME" --query 'Status' --output text)
if [ "$VERSIONING_STATUS" = "Enabled" ]; then
    echo "✓ Versioning is enabled"
else
    echo "✗ Versioning is not enabled (current status: $VERSIONING_STATUS)"
fi

# Check lifecycle configuration
echo "3. Checking lifecycle configuration..."
if aws s3api get-bucket-lifecycle-configuration --bucket "$BUCKET_NAME" &> /dev/null; then
    LIFECYCLE_RULES=$(aws s3api get-bucket-lifecycle-configuration --bucket "$BUCKET_NAME" --query 'Rules[0].ID' --output text)
    if [ "$LIFECYCLE_RULES" = "TransitionToGlacierAfter30Days" ]; then
        echo "✓ Lifecycle configuration found: $LIFECYCLE_RULES"
        
        # Check transition details
        TRANSITION_DAYS=$(aws s3api get-bucket-lifecycle-configuration --bucket "$BUCKET_NAME" --query 'Rules[0].Transitions[0].Days' --output text)
        TRANSITION_STORAGE=$(aws s3api get-bucket-lifecycle-configuration --bucket "$BUCKET_NAME" --query 'Rules[0].Transitions[0].StorageClass' --output text)
        echo "  → Transition after $TRANSITION_DAYS days to $TRANSITION_STORAGE"
    else
        echo "⚠ Lifecycle configuration found but unexpected ID: $LIFECYCLE_RULES"
    fi
else
    echo "✗ No lifecycle configuration found"
fi

# Check website configuration
echo "4. Checking website configuration..."
if aws s3api get-bucket-website --bucket "$BUCKET_NAME" &> /dev/null; then
    INDEX_DOC=$(aws s3api get-bucket-website --bucket "$BUCKET_NAME" --query 'IndexDocument.Suffix' --output text)
    ERROR_DOC=$(aws s3api get-bucket-website --bucket "$BUCKET_NAME" --query 'ErrorDocument.Key' --output text)
    echo "✓ Website hosting configured"
    echo "  → Index document: $INDEX_DOC"
    echo "  → Error document: $ERROR_DOC"
else
    echo "✗ Website hosting not configured"
fi

# Check bucket policy for public read access
echo "5. Checking bucket policy for public read access..."
if aws s3api get-bucket-policy --bucket "$BUCKET_NAME" &> /dev/null; then
    POLICY=$(aws s3api get-bucket-policy --bucket "$BUCKET_NAME" --query 'Policy' --output text)
    if echo "$POLICY" | grep -q '"Effect":"Allow"' && echo "$POLICY" | grep -q '"Action":"s3:GetObject"' && echo "$POLICY" | grep -q '"Principal":{"*":*}'; then
        echo "✓ Bucket policy allows public read access"
    else
        echo "⚠ Bucket policy exists but may not grant public read access"
        echo "  Policy: $POLICY"
    fi
else
    echo "✗ No bucket policy found"
fi

# Check objects in bucket
echo "6. Checking objects in bucket..."
OBJECT_COUNT=$(aws s3api list-objects-v2 --bucket "$BUCKET_NAME" --query 'Contents[].Size' --output text | wc -w)
if [ "$OBJECT_COUNT" -gt 0 ]; then
    echo "✓ Bucket contains $OBJECT_COUNT object(s)"
    
    # Show total size
    TOTAL_SIZE=$(aws s3api list-objects-v2 --bucket "$BUCKET_NAME" --query 'sum(Contents[].Size)' --output text)
    echo "  → Total size: $TOTAL_SIZE bytes"
    
    # List objects
    echo "  Objects:"
    aws s3 ls s3://"$BUCKET_NAME/" --human-readable
else
    echo "⚠ Bucket is empty (no objects found)"
fi

# Check if website is accessible
echo "7. Checking website accessibility..."
WEBSITE_ENDPOINT="${BUCKET_NAME}.s3-website-${REGION}.amazonaws.com"
echo "Testing website at: http://$WEBSITE_ENDPOINT"
if curl -s -o /dev/null -w "%{http_code}" http://"$WEBSITE_ENDPOINT" | grep -q "^2"; then
    echo "✓ Website is accessible (HTTP 2xx)"
    
    # Check if it's serving expected content
    if curl -s http://"$WEBSITE_ENDPOINT" | grep -q -i "aws s3"; then
        echo "✓ Website appears to be serving expected content"
    else
        echo "⚠ Website accessible but content may not be as expected"
    fi
else
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://"$WEBSITE_ENDPOINT")
    echo "✗ Website not accessible (HTTP $HTTP_CODE)"
    echo "  Possible causes:"
    echo "    - Website hosting not properly configured"
    echo "    - Missing public read access in bucket policy"
    echo "    - Index document not uploaded"
fi

# Summary
echo ""
echo "=== VERIFICATION SUMMARY ==="
echo "If most checks show ✓, your S3 bucket is properly configured!"
echo "For any ✗ marks, review the corresponding setup steps."
echo ""
echo "Key S3 Concepts to Review for Interview:"
echo "1. Storage Classes: Standard, Standard-IA, One Zone-IA, Intelligent-Tiering, Glacier, Glacier Deep Archive"
echo "2. Consistency Model: Read-after-write for new objects, eventual for overwrites/deletes"
echo "3. Versioning: Protects against accidental deletion/overwrites"
echo "4. Lifecycle Policies: Automate transitions between storage classes"
echo "5. Cross-Region Replication: For disaster recovery and lower latency"
echo "6. Static Website Hosting: Cost-effective way to host static websites"
echo "7. Security: Bucket policies, ACLs, encryption options, access points"
echo ""
echo "Next Steps for Interview Preparation:"
echo "1. Practice explaining each feature and when to use it"
echo "2. Be ready to discuss cost optimization strategies"
echo "3. Understand performance characteristics and limits"
echo "4. Know how to troubleshoot common S3 issues"