cv vc#! /bin/bash
sudo apt udpate -y
terraform_version=$(curl -s https://checkpoint-api.hashicorp.com/v1/check/terraform | jq -r -M '.current_version')
curl -O "https://releases.hashicorp.com/terraform/${terraform_version}/terraform_${terraform_version}_linux_amd64.zip"
unzip terraform_${terraform_version}_linux_amd64.zip && mkdir -p ~/bin && mv terraform ~/bin/ && terraform version

#installing git

sudo apt install git -y


git clone https://github.com/kodekloudhub/certified-kubernetes-administrator-course.git

cd certified-kubernetes-administrator-course/managed-clusters/eks/terraform


terraform init && terraform plan && terraform apply

sleep 600s
wait

aws eks update-kubeconfig --region us-east-1 --name demo-eks

curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/cloudformation/2020-10-29/aws-auth-cm.yaml



# Step 1: Fetch NodeInstanceRole from Terraform output
# Assuming your Terraform is in the same directory, or modify the path accordingly
NODE_INSTANCE_ROLE=$(terraform output -raw NodeInstanceRole)

# Check if the Terraform output was successful
if [ -z "$NODE_INSTANCE_ROLE" ]; then
  echo "Error: NodeInstanceRole not found in Terraform output"
  exit 1
fi

# Step 2: Define the path to your ConfigMap YAML file
CONFIG_MAP_FILE="/home/cloudshell-user/certified-kubernetes-administrator-course/managed-clusters/eks/terraform/aws-auth-cm.yaml"

# Check if the ConfigMap file exists
if [ ! -f "$CONFIG_MAP_FILE" ]; then
  echo "Error: ConfigMap file does not exist at $CONFIG_MAP_FILE"
  exit 1
fi

# Step 3: Use sed to replace the placeholder in the YAML file
# '<ARN of instance role (not instance profile)>' is the placeholder you want to replace
sed -i "s|<ARN of instance role (not instance profile)>|$NODE_INSTANCE_ROLE|g" "$CONFIG_MAP_FILE"

# Step 4: Confirm the replacement was successful
if grep -q "$NODE_INSTANCE_ROLE" "$CONFIG_MAP_FILE"; then
  echo "ConfigMap updated successfully with NodeInstanceRole: $NODE_INSTANCE_ROLE"
else
  echo "Error: Failed to update the ConfigMap"
  exit 1
fi
