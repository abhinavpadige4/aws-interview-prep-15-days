# AWS Cloud Engineer Interview Preparation - 15 Day Plan
## COMPLETED STATUS

This repository contains the foundation for a comprehensive 15-day AWS Cloud Engineer interview preparation plan.

### What Has Been Completed:
✅ **Repository Setup**: Created `aws-interview-prep-15-days` GitHub repository
✅ **Documentation**: 
   - Main README.md with 15-day plan overview
   - STUDY_PLAN_SUMMARY.md with detailed structure
✅ **Day 1 - EC2 Fundamentals** (COMPLETE):
   - Detailed notes.md covering EC2 concepts, instance types, AMIs, security groups
   - Practice questions.md with 5 multiple-choice + 5 scenario-based questions and answers
   - Hands-on exercise.md with step-by-step instructions to launch EC2, install Apache, create web page
   - Scripts directory with:
     * launch-ec2.sh - AWS CLI script to create EC2 instance with security group
     * configure-apache.sh - Script to install and configure Apache web server
     * verify-installation.sh - Script to verify EC2 and web server setup
     * README.md explaining script usage
✅ **Day 2 - S3 Storage** (COMPLETE):
   - Detailed notes.md covering S3 concepts, storage classes, consistency model
   - Practice questions.md with 5 multiple-choice + 5 scenario-based questions and answers
   - Hands-on exercise.md with step-by-step instructions to create bucket, enable versioning, set lifecycle policy, configure static website hosting
   - Scripts directory with:
     * create-bucket.sh - AWS CLI script to create S3 bucket with versioning, lifecycle policy, website hosting
     * verify-setup.sh - Script to verify S3 bucket configuration
     * README.md explaining script usage
   - Templates directory with:
     * s3-bucket-cf.yaml - CloudFormation template for S3 bucket with versioning
✅ **Day 3 - VPC Networking** (COMPLETE):
   - Detailed notes.md covering VPC concepts, subnets, routing, NAT gateways, security groups
   - Practice questions.md with 5 multiple-choice + 5 scenario-based questions and answers
   - Hands-on exercise.md with step-by-step instructions to create VPC with public/private subnets, IGW, NAT gateway, bastion host, and private instance
   - Scripts directory with:
     * create-vpc.sh - AWS CLI script to create complete VPC infrastructure
     * verify-vpc.sh - Script to verify VPC configuration
     * cleanup-vpc.sh - Script to safely clean up all VPC resources
     * README.md explaining script usage
✅ **Day 4 - IAM Security** (STARTED):
   - notes.md with IAM overview, entities, policies, best practices
✅ **Day 5 - Lambda Functions** (STARTED):
   - code/hello-world.py - Sample Lambda function demonstrating basic concepts

### What Remains to be Completed:
- Day 4: IAM Security (practice questions, hands-on exercise, scripts)
- Day 5: Lambda Functions (notes, practice questions, hands-on exercise, additional code samples)
- Day 6: RDS Databases (complete day structure)
- Day 7: CloudFormation (complete day structure)
- Day 8: CloudWatch Monitoring (complete day structure)
- Day 9-15: Advanced topics and review (complete day structures)

### How to Continue:
1. Follow the same pattern established in Days 1-3 for remaining days
2. Each day should include:
   - notes.md: Study materials and concepts
   - practice-questions.md: Multiple-choice and scenario-based questions with answers
   - hands-on-exercise.md: Step-by-step practical exercises
   - scripts/ or code/: AWS CLI scripts, Lambda functions, or other code samples
   - templates/: CloudFormation templates where applicable
   - README.md in subdirectories explaining usage
3. Commit progress regularly using git
4. Test all hands-on exercises in your AWS Free Tier account
5. Review all materials before your interview

### Usage Instructions:
```bash
# Clone the repository
git clone https://github.com/abhinavpadige4/aws-interview-prep-15-days.git
cd aws-interview-prep-15-days

# To work on a specific day (example: Day 1)
cd day01-ec2-fundamentals
# Review notes.md
# Practice with practice-questions.md
# Follow hands-on-exercise.md
# Use scripts/ directory for automation

# Commit your progress
git add .
git commit -m "Day 1: EC2 Fundamentals completed"
git push origin main
```

### Resources for Completion:
- AWS Documentation: https://docs.aws.amazon.com/
- AWS Well-Architected Framework: https://aws.amazon.com/architecture/well-architected/
- AWS Free Tier: https://aws.amazon.com/free/
- AWS Blog: https://aws.amazon.com/blogs/aws/