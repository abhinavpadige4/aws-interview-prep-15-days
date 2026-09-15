#!/bin/bash
# Day 1: EC2 Apache Configuration Script
# This script installs and configures Apache web server on an EC2 instance

set -euo pipefail

echo "=== Apache Web Server Installation Script ==="
echo "This script will install Apache and create a custom HTML page"

# Update system packages
echo "Updating system packages..."
sudo yum update -y

# Install Apache
echo "Installing Apache web server..."
sudo yum install -y httpd

# Start and enable Apache service
echo "Starting and enabling Apache service..."
sudo systemctl start httpd
sudo systemctl enable httpd

# Get instance metadata for custom page
echo "Retrieving instance metadata..."
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
INSTANCE_TYPE=$(curl -s http://169.254.169.254/latest/meta-data/instance-type)
AVAILABILITY_ZONE=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
LOCAL_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)

# Create custom HTML page
echo "Creating custom HTML page..."
sudo tee /var/www/html/index.html > /dev/null << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AWS EC2 Interview Prep</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 40px;
            background-color: #f5f5f5;
        }
        .container {
            max-width: 800px;
            margin: 0 auto;
            background: white;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        h1 {
            color: #232f3e;
            border-bottom: 3px solid #ff9900;
            padding-bottom: 10px;
        }
        .info-box {
            background-color: #e8f4f8;
            border-left: 4px solid #ff9900;
            padding: 15px;
            margin: 20px 0;
        }
        .footer {
            margin-top: 30px;
            text-align: center;
            color: #666;
            font-size: 0.9em;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Welcome to AWS EC2!</h1>
        <div class="info-box">
            <h2>Instance Information</h2>
            <p><strong>Instance ID:</strong> '"$INSTANCE_ID"'</p>
            <p><strong>Instance Type:</strong> '"$INSTANCE_TYPE"'</p>
            <p><strong>Availability Zone:</strong> '"$AVAILABILITY_ZONE"'</p>
            <p><strong>Local IP:</strong> '"$LOCAL_IP"'</p>
            <p><strong>Public IP:</strong> '"$PUBLIC_IP"'</p>
        </div>
        
        <div class="info-box">
            <h2>EC2 Concepts Learned</h2>
            <ul>
                <li>Instance types and families</li>
                <li>Amazon Machine Images (AMIs)</li>
                <li>Security groups and network configuration</li>
                <li>Key pairs for secure access</li>
                <li>Elastic IP addresses</li>
                <li>Instance states (pending, running, stopped, terminated)</li>
                <li>Purchasing options (On-Demand, Reserved, Spot)</li>
            </ul>
        </div>
        
        <div class="info-box">
            <h2>Next Steps in Your AWS Journey</h2>
            <ol>
                <li>Explore S3 storage services</li>
                <li>Learn VPC networking concepts</li>
                <li>Master IAM security best practices</li>
                <li>Practice with Lambda serverless functions</li>
                <li>Work with RDS managed databases</li>
            </ol>
        </div>
    </div>
    
    <div class="footer">
        <p>AWS Cloud Engineer Interview Preparation - Day 1: EC2 Fundamentals</p>
        <p>Generated on: '"$(date)"'</p>
    </div>
</body>
</html>
EOF

# Set correct permissions
echo "Setting correct permissions..."
sudo chown -R apache:apache /var/www/html

# Restart Apache to apply changes
echo "Restarting Apache to apply changes..."
sudo systemctl restart httpd

# Verify Apache is running
echo "Verifying Apache status..."
sudo systemctl is-active --quiet httpd && echo "Apache is running!" || echo "Warning: Apache may not be running properly"

# Get local IP for testing
LOCAL_IP=$(hostname -I | awk '{print $1}')
echo ""
echo "=== INSTALLATION COMPLETE ==="
echo "Apache web server installed and configured!"
echo "Local access: http://$LOCAL_IP"
echo "To find your public IP, check AWS EC2 console or run:"
echo "curl http://checkip.amazonaws.com"
echo ""
echo "To test your web server:"
echo "curl http://$LOCAL_IP"
echo "Or visit the public IP in your web browser"
echo ""
echo "Management commands:"
echo "  sudo systemctl status httpd   # Check status"
echo "  sudo systemctl stop httpd     # Stop Apache"
echo "  sudo systemctl start httpd    # Start Apache"
echo "  sudo systemctl restart httpd  # Restart Apache"