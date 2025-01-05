#!/bin/bash

# Variables
AMI_ID="ami-0e2c8caa4b6378d8c"  # Replace with your AMI ID
INSTANCE_TYPE="t3.medium"        # Replace with your instance type
KEY_NAME="om"          # Replace with your key pair name
SECURITY_GROUP="sg-06cdc6b5411b571e1"# Replace with your security group ID
SUBNET_ID="subnet-01bd273ed92a89d2c"   # Replace with your subnet ID
INSTANCE_COUNT=2                # Number of instances to launch

# Launch EC2 instances
aws ec2 run-instances \
    --image-id $AMI_ID \
    --instance-type $INSTANCE_TYPE \
    --key-name $KEY_NAME \
    --security-group-ids $SECURITY_GROUP \
    --subnet-id $SUBNET_ID \
    --associate-public-ip-address \
    --count $INSTANCE_COUNT

echo "EC2 instances launched successfully."
# Wait for instances to be in running state
INSTANCE_IDS=$(aws ec2 describe-instances --filters "Name=image-id,Values=$AMI_ID" "Name=instance-state-name,Values=pending" --query "Reservations[*].Instances[*].InstanceId" --output text)

for INSTANCE_ID in $INSTANCE_IDS; do
    aws ec2 wait instance-running --instance-ids $INSTANCE_ID
    echo "Instance $INSTANCE_ID is running."
done