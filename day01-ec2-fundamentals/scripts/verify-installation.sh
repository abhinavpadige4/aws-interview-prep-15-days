#!/bin/bash
# Day 1: EC2 Installation Verification Script
# This script verifies that the EC2 instance and web server are properly configured

set -euo pipefail

echo "=== EC2 Instance Verification ==="

# Check if we're on an EC2 instance
if [ -f /sys/hypervisor/uuid ] && [ "$(head -c 3 /sys/hypervisor/uuid)" = "ec2" ]; then
    echo "✓ Running on EC2 instance"
else
    echo "⚠ Warning: Does not appear to be running on EC2 instance"
fi

# Check instance metadata availability
echo "Checking instance metadata accessibility..."
if curl -s http://169.254.169.254/latest/meta-data/instance-id &> /dev/null; then
    echo "✓ Instance metadata accessible"
    INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
    INSTANCE_TYPE=$(curl -s http://169.254.169.254/latest/meta-data/instance-type)
    echo "  Instance ID: $INSTANCE_ID"
    echo "  Instance Type: $INSTANCE_TYPE"
else
    echo "✗ Instance metadata not accessible"
fi

# Check if Apache is installed and running
echo "Checking Apache web server..."
if command -v httpd &> /dev/null; then
    echo "✓ Apache (httpd) is installed"
else
    echo "✗ Apache is not installed"
fi

if systemctl is-active --quiet httpd; then
    echo "✓ Apache service is running"
else
    echo "✗ Apache service is not running"
    echo "  Try: sudo systemctl start httpd"
fi

# Check if web server is serving content
echo "Checking web server response..."
LOCAL_IP=$(hostname -I | awk '{print $1}')
if curl -s http://localhost &> /dev/null; then
    echo "✓ Web server responding on localhost"
    
    # Check for custom content
    if curl -s http://localhost | grep -q "Welcome to AWS EC2"; then
        echo "✓ Custom HTML page detected"
    else
        echo "⚠ Default Apache page or custom content not found"
    fi
else
    echo "✗ Web server not responding on localhost"
    echo "  Try: sudo systemctl start httpd"
fi

# Check firewall/security group (basic check)
echo "Checking network accessibility..."
if nc -z localhost 80; then
    echo "✓ Port 80 (HTTP) is accessible locally"
else
    echo "✗ Port 80 (HTTP) is not accessible locally"
fi

if nc -z localhost 22; then
    echo "✓ Port 22 (SSH) is accessible locally"
else
    echo "✗ Port 22 (SSH) is not accessible locally"
fi

# Check document root
echo "Checking web document root..."
if [ -d /var/www/html ]; then
    echo "✓ Document root (/var/www/html) exists"
    
    if [ -f /var/www/html/index.html ]; then
        echo "✓ index.html found in document root"
        
        # Check file size
        SIZE=$(stat -c%s /var/www/html/index.html)
        if [ "$SIZE" -gt 1000 ]; then
            echo "✓ index.html has substantial content ($SIZE bytes)"
        else
            echo "⚠ index.html seems small ($SIZE bytes)"
        fi
    else
        echo "✗ index.html not found in document root"
    fi
else
    echo "✗ Document root (/var/www/html) does not exist"
fi

# Summary
echo ""
echo "=== VERIFICATION SUMMARY ==="
echo "If most checks show ✓, your EC2 instance is properly configured!"
echo "For any ✗ marks, review the corresponding setup steps."
echo ""
echo "Next steps for interview preparation:"
echo "1. Practice explaining each step of this setup process"
echo "2. Be ready to discuss EC2 instance types, AMIs, and security groups"
echo "3. Understand the difference between stopping and terminating instances"
echo "4. Know how to troubleshoot common EC2 connectivity issues"