#!/bin/bash

# Update package lists
sudo apt-get update

# Install wget and apt-utils
sudo apt-get install -y wget apt-utils

# Install Azure CLI
#curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Variables
# Create a container with the name of the current date in this format: YYYYMMDD
# Example: 20231001 for October 1, 2023
MIRROR_URL="http://archive.ubuntu.com/ubuntu"
STORAGE_ACCOUNT="<STORAGE_ACCOUNT>"
CONTAINER_NAME="<CONTAINER_NAME>"
ACCOUNT_KEY="<STORAGE_ACCOUNT_KEY>"

# Create directories
mkdir -p dists/jammy-updates/{main,multiverse,restricted,universe}/binary-amd64
mkdir -p pool/{main,multiverse,restricted,universe}

# Download metadata files
echo "Downloading metadata files..."
wget -q -P dists/jammy-updates/ ${MIRROR_URL}/dists/jammy-updates/InRelease
wget -q -P dists/jammy-updates/ ${MIRROR_URL}/dists/jammy-updates/Release
wget -q -P dists/jammy-updates/ ${MIRROR_URL}/dists/jammy-updates/Release.gpg

# Download Packages files
components=("main" "multiverse" "restricted" "universe")
for component in "${components[@]}"; do
  wget -q -P dists/jammy-updates/${component}/binary-amd64/ ${MIRROR_URL}/dists/jammy-updates/${component}/binary-amd64/Packages
  wget -q -P dists/jammy-updates/${component}/binary-amd64/ ${MIRROR_URL}/dists/jammy-updates/${component}/binary-amd64/Packages.gz
  wget -q -P dists/jammy-updates/${component}/binary-amd64/ ${MIRROR_URL}/dists/jammy-updates/${component}/binary-amd64/Packages.xz
done

# Check if dists directory exists
if [ ! -d "dists" ]; then
  echo "Error: 'dists' directory not found. Please ensure the wget commands are downloading the files correctly."
  exit 1
fi

# Upload dists directory to Azure Blob Storage
echo "Uploading dists directory to Azure Blob Storage..."
az storage blob upload-batch -s dists -d ${CONTAINER_NAME} --account-name ${STORAGE_ACCOUNT} --account-key ${ACCOUNT_KEY} --destination-path dists

echo "APT repository metadata successfully downloaded and uploaded to Azure Blob Storage."