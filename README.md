# AWS Cloud Engineer Interview Preparation - 15 Day Plan

## Overview
This repository contains a comprehensive 15-day study plan to prepare for an AWS Cloud Engineer interview, covering all essential AWS services: EC2, S3, VPC, IAM, Lambda, RDS, CloudFormation, and CloudWatch.

## Daily Structure
Each day includes:
- **Study** (60 min): Documentation review and concept learning
- **Practice** (30 min): Multiple-choice questions and quizzes
- **Hands-on** (60 min): Practical exercises and labs
- **GitHub** (15 min): Documentation, scripts, and notes commit/push

## Topics Covered
- **Day 1**: EC2 Fundamentals
- **Day 2**: S3 Storage
- **Day 3**: VPC Networking
- **Day 4**: IAM Security
- **Day 5**: Lambda Functions
- **Day 6**: RDS Databases
- **Day 7**: CloudFormation
- **Day 8**: CloudWatch Monitoring
- **Day 9**: EC2 Advanced (Auto Scaling, Load Balancing)
- **Day 10**: S3 Advanced (Security, Performance)
- **Day 11**: VPC Advanced (Peering, Transit Gateway)
- **Day 12**: IAM Advanced (Roles, Policies, MFA)
- **Day 13**: Lambda Advanced (Event Sources, DLQ)
- **Day 14**: RDS Advanced (Read Replicas, Backup)
- **Day 15**: Review and Mock Interview

## Repository Structure
```
aws-interview-prep-15-days/
├── README.md
├── day01-ec2-fundamentals/
│   ├── notes.md
│   ├── practice-questions.md
│   ├── hands-on-exercise.md
│   └── scripts/
│       ├── launch-ec2.sh
│       └── configure-apache.sh
├── day02-s3-storage/
│   ├── notes.md
│   ├── practice-questions.md
│   ├── hands-on-exercise.md
│   └── templates/
│       └── s3-bucket-cf.yaml
├── day03-vpc-networking/
│   ├── notes.md
│   ├── practice-questions.md
│   ├── hands-on-exercise.md
│   └── scripts/
│       ├── create-vpc.sh
│       └── setup-bastion.sh
├── day04-iam-security/
│   ├── notes.md
│   ├── practice-questions.md
│   ├── hands-on-exercise.md
│   └── scripts/
│       ├── create-user.sh
│       └── setup-mfa.sh
├── day05-lambda-functions/
│   ├── notes.md
│   ├── practice-questions.md
│   ├── hands-on-exercise.md
│   └── code/
│       ├── hello-world.py
│       └── s3-trigger.py
├── day06-rds-databases/
│   ├── notes.md
│   ├── practice-questions.md
│   ├── hands-on-exercise.md
│   └── scripts/
│       ├── create-db.sh
│       └── backup-script.sh
├── day07-cloudformation/
│   ├── notes.md
│   ├── practice-questions.md
│   ├── hands-on-exercise.md
│   └── templates/
│       ├── web-app.yaml
│       └── database-stack.yaml
├── day08-cloudwatch/
│   ├── notes.md
│   ├── practice-questions.md
│   ├── hands-on-exercise.md
│   └── scripts/
│       ├── setup-alarms.sh
│       └── custom-metrics.py
├── day09-ec2-advanced/
│   ├── notes.md
│   ├── practice-questions.md
│   ├── hands-on-exercise.md
│   └── scripts/
│       ├── autoscaling-group.sh
│       └── load-balancer.sh
├── day10-s3-advanced/
│   ├── notes.md
│   ├── practice-questions.md
│   ├── hands-on-exercise.md
│   └── templates/
│       ├── secure-bucket.yaml
│       └── website-config.json
├── day11-vpc-advanced/
│   ├── notes.md
│   ├── practice-questions.md
│   ├── hands-on-exercise.md
│   └── scripts/
│       ├── vpc-peering.sh
│       └── transit-gateway.sh
├── day12-iam-advanced/
│   ├── notes.md
│   ├── practice-questions.md
│   ├── hands-on-exercise.md
│   └── scripts/
│       ├── role-assumption.sh
│       └── policy-audit.sh
├── day13-lambda-advanced/
│   ├── notes.md
│   ├── practice-questions.md
│   ├── hands-on-exercise.md
│   └── code/
│       ├── dlq-handler.py
│       └── event-processor.js
├── day14-rds-advanced/
│   ├── notes.md
│   ├── practice-questions.md
│   ├── hands-on-exercise.md
│   └── scripts/
│       ├── read-replica.sh
│       └── point-in-time-recovery.sh
└── day15-review/
    ├── notes.md
    ├── practice-questions.md
    ├── mock-interview-questions.md
    └── final-checklist.md
```

## How to Use This Plan
1. Clone this repository: `git clone https://github.com/abhinavpadige4/aws-interview-prep-15-days.git`
2. Follow the daily schedule in each day's folder
3. Complete the hands-on exercises using your AWS Free Tier account
4. Commit your progress daily to track your learning
5. Review all materials before your interview

## Prerequisites
- AWS Free Tier account
- GitHub account
- Basic Linux/CLI knowledge
- Text editor (VS Code recommended)
- Internet access

## Resources
- [AWS Documentation](https://docs.aws.amazon.com/)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- [AWS Free Tier](https://aws.amazon.com/free/)