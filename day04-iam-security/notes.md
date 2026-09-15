# Day 4: IAM Security

## Study Notes (60 minutes)

### AWS IAM Overview
Identity and Access Management (IAM) enables you to manage access to AWS services and resources securely. Using IAM, you can create and manage AWS users and groups, and use permissions to allow and deny their access to AWS resources.

### Key Concepts

#### IAM Entities
- **Users**: Individual people or applications that interact with AWS
- **Groups**: Collections of users that simplify managing permissions for multiple users
- **Roles**: AWS identities with specific permissions that can be assumed by trusted entities
- **Policies**: Documents that define permissions (JSON format)

#### Authentication vs Authorization
- **Authentication**: Verifying who you are (username/password, MFA, access keys)
- **Authorization**: Determining what you're allowed to do (policies, permissions)

#### IAM Policies
- **Managed Policies**: Standalone policies that can be attached to multiple users/groups/roles
  - AWS Managed Policies: Created and maintained by AWS
  - Customer Managed Policies: Created and maintained by you
- **Inline Policies**: Policies embedded directly in a user, group, or role

#### Policy Elements
- **Version**: Policy language version (typically "2012-10-17")
- **Statement**: Array of individual permission statements
- **Effect**: Allow or Deny
- **Action**: Specific AWS actions (e.g., s3:GetObject, ec2:StartInstances)
- **Resource**: ARN of the resource the action applies to
- **Condition**: Optional constraints on when the policy is in effect

#### Policy Evaluation Logic
1. By default, all requests are denied
2. An explicit allow overrides this default
3. An explicit deny overrides any allows
4. Permissions are evaluated across all applicable policies

#### IAM Best Practices
- **Principle of Least Privilege**: Grant only the permissions required to perform a task
- **Use Groups**: Assign permissions to groups, not individual users
- **Enable MFA**: Especially for privileged users
- **Rotate Credentials**: Regularly change access keys and passwords
- **Use Roles for Applications**: EC2 instances, Lambda functions, etc.
- **Monitor with CloudTrail**: Track API calls and changes
- **Regular Review**: Periodically audit permissions and remove unused ones

#### Access Types
- **Programmatic Access**: Access keys (access key ID + secret access key)
- **AWS Management Console Access**: Password + MFA
- **SSH Access to EC2**: Key pairs (separate from IAM)

#### Federated Access
- **Identity Providers**: External IdPs (Azure AD, Google Workspace, etc.)
- **SAML 2.0**: For web-based single sign-on
- **OpenID Connect**: For modern applications
- **AWS SSO**: Centralized SSO management for AWS accounts

## Practice Questions Overview (30 minutes)
See practice-questions.md for detailed questions and answers

## Hands-On Exercise Overview (60 minutes)
1. Create IAM users and groups
2. Attach managed policies to groups
3. Create custom inline policies
4. Enable MFA for users
5. Create IAM roles for EC2 instances
6. Test permissions and access

## GitHub Commit Instructions (15 minutes)
Add day4 notes, IAM user/role creation scripts, commit and push