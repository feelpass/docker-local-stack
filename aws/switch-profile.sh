#!/bin/bash

# AWS Profile Switcher Script
# Usage: ./switch-profile.sh [profile-name]

PROFILE=${1:-default}
ENV_FILE="../.env"

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}Switching to AWS Profile: ${PROFILE}${NC}"

# Check if .env file exists
if [ ! -f "$ENV_FILE" ]; then
    echo -e "${RED}Error: .env file not found. Please copy .env.example to .env first.${NC}"
    exit 1
fi

# Update AWS_PROFILE in .env
if grep -q "^AWS_PROFILE=" "$ENV_FILE"; then
    sed -i.bak "s/^AWS_PROFILE=.*/AWS_PROFILE=${PROFILE}/" "$ENV_FILE"
else
    echo "AWS_PROFILE=${PROFILE}" >> "$ENV_FILE"
fi

# Extract profile credentials based on profile name
case $PROFILE in
    default)
        KEY=$(grep "^AWS_PROFILE_DEFAULT_KEY=" "$ENV_FILE" | cut -d'=' -f2)
        SECRET=$(grep "^AWS_PROFILE_DEFAULT_SECRET=" "$ENV_FILE" | cut -d'=' -f2)
        REGION=$(grep "^AWS_PROFILE_DEFAULT_REGION=" "$ENV_FILE" | cut -d'=' -f2)
        ;;
    dev)
        KEY=$(grep "^AWS_PROFILE_DEV_KEY=" "$ENV_FILE" | cut -d'=' -f2)
        SECRET=$(grep "^AWS_PROFILE_DEV_SECRET=" "$ENV_FILE" | cut -d'=' -f2)
        REGION=$(grep "^AWS_PROFILE_DEV_REGION=" "$ENV_FILE" | cut -d'=' -f2)
        ;;
    staging)
        KEY=$(grep "^AWS_PROFILE_STAGING_KEY=" "$ENV_FILE" | cut -d'=' -f2)
        SECRET=$(grep "^AWS_PROFILE_STAGING_SECRET=" "$ENV_FILE" | cut -d'=' -f2)
        REGION=$(grep "^AWS_PROFILE_STAGING_REGION=" "$ENV_FILE" | cut -d'=' -f2)
        ;;
    prod)
        KEY=$(grep "^AWS_PROFILE_PROD_KEY=" "$ENV_FILE" | cut -d'=' -f2)
        SECRET=$(grep "^AWS_PROFILE_PROD_SECRET=" "$ENV_FILE" | cut -d'=' -f2)
        REGION=$(grep "^AWS_PROFILE_PROD_REGION=" "$ENV_FILE" | cut -d'=' -f2)
        ;;
    *)
        echo -e "${RED}Error: Unknown profile '${PROFILE}'${NC}"
        echo "Available profiles: default, dev, staging, prod"
        exit 1
        ;;
esac

# Update current AWS credentials in .env
sed -i.bak "s/^AWS_ACCESS_KEY_ID=.*/AWS_ACCESS_KEY_ID=${KEY}/" "$ENV_FILE"
sed -i.bak "s/^AWS_SECRET_ACCESS_KEY=.*/AWS_SECRET_ACCESS_KEY=${SECRET}/" "$ENV_FILE"
sed -i.bak "s/^AWS_REGION=.*/AWS_REGION=${REGION}/" "$ENV_FILE"

# Clean up backup files
rm -f "$ENV_FILE.bak"

echo -e "${GREEN}✅ Switched to AWS Profile: ${PROFILE}${NC}"
echo -e "   Region: ${REGION}"
echo -e "   Key: ${KEY:0:10}..."

# Export for current shell session
export AWS_PROFILE=$PROFILE
export AWS_ACCESS_KEY_ID=$KEY
export AWS_SECRET_ACCESS_KEY=$SECRET
export AWS_DEFAULT_REGION=$REGION

echo -e "${GREEN}✅ Environment variables exported for current session${NC}"