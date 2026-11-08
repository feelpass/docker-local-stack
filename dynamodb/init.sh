#!/bin/bash

# DynamoDB initialization script
# This script creates tables and sample data for DynamoDB Local

# DynamoDB Local용 가짜 자격 (실계정 자격 불필요)
export AWS_ACCESS_KEY_ID=local AWS_SECRET_ACCESS_KEY=local AWS_DEFAULT_REGION=ap-northeast-2

echo "🚀 Initializing DynamoDB tables..."

# Wait for DynamoDB to be ready
until aws dynamodb list-tables --endpoint-url http://localhost:8000 --region ap-northeast-2 > /dev/null 2>&1; do
    echo "⏳ Waiting for DynamoDB to be ready..."
    sleep 2
done

# Create BomCalendar Reports table
echo "📊 Creating BomCalendar-Reports table..."
aws dynamodb create-table \
    --endpoint-url http://localhost:8000 \
    --table-name BomCalendar-Reports \
    --attribute-definitions \
        AttributeName=PK,AttributeType=S \
        AttributeName=SK,AttributeType=S \
        AttributeName=GSI1PK,AttributeType=S \
        AttributeName=GSI1SK,AttributeType=S \
    --key-schema \
        AttributeName=PK,KeyType=HASH \
        AttributeName=SK,KeyType=RANGE \
    --global-secondary-indexes \
        "IndexName=GSI1,KeySchema=[{AttributeName=GSI1PK,KeyType=HASH},{AttributeName=GSI1SK,KeyType=RANGE}],Projection={ProjectionType=ALL},BillingMode=PAY_PER_REQUEST" \
    --billing-mode PAY_PER_REQUEST \
    --region ap-northeast-2 \
    2>/dev/null || echo "Table BomCalendar-Reports already exists"

# Create Users table
echo "📊 Creating Users table..."
aws dynamodb create-table \
    --endpoint-url http://localhost:8000 \
    --table-name Users \
    --attribute-definitions \
        AttributeName=userId,AttributeType=S \
        AttributeName=email,AttributeType=S \
    --key-schema \
        AttributeName=userId,KeyType=HASH \
    --global-secondary-indexes \
        "IndexName=EmailIndex,KeySchema=[{AttributeName=email,KeyType=HASH}],Projection={ProjectionType=ALL},BillingMode=PAY_PER_REQUEST" \
    --billing-mode PAY_PER_REQUEST \
    --region ap-northeast-2 \
    2>/dev/null || echo "Table Users already exists"

# Create Events table
echo "📊 Creating Events table..."
aws dynamodb create-table \
    --endpoint-url http://localhost:8000 \
    --table-name Events \
    --attribute-definitions \
        AttributeName=eventId,AttributeType=S \
        AttributeName=userId,AttributeType=S \
        AttributeName=timestamp,AttributeType=N \
    --key-schema \
        AttributeName=eventId,KeyType=HASH \
    --global-secondary-indexes \
        "IndexName=UserIdIndex,KeySchema=[{AttributeName=userId,KeyType=HASH},{AttributeName=timestamp,KeyType=RANGE}],Projection={ProjectionType=ALL},BillingMode=PAY_PER_REQUEST" \
    --billing-mode PAY_PER_REQUEST \
    --region ap-northeast-2 \
    2>/dev/null || echo "Table Events already exists"

# Insert sample data
echo "📝 Inserting sample data..."

# Sample user data
aws dynamodb put-item \
    --endpoint-url http://localhost:8000 \
    --table-name Users \
    --item '{
        "userId": {"S": "user-001"},
        "email": {"S": "test@example.com"},
        "name": {"S": "Test User"},
        "createdAt": {"S": "2024-01-01T00:00:00Z"},
        "status": {"S": "active"}
    }' \
    --region ap-northeast-2

# Sample period data for BomCalendar
aws dynamodb put-item \
    --endpoint-url http://localhost:8000 \
    --table-name BomCalendar-Reports \
    --item '{
        "PK": {"S": "USER#user-001"},
        "SK": {"S": "PROFILE"},
        "name": {"S": "Test User"},
        "email": {"S": "test@example.com"},
        "createdAt": {"S": "2024-01-01T00:00:00Z"}
    }' \
    --region ap-northeast-2

# Add sample period data
for i in {1..3}; do
    MONTH=$(date -v-${i}m +%Y-%m 2>/dev/null || date -d "-${i} month" +%Y-%m)
    aws dynamodb put-item \
        --endpoint-url http://localhost:8000 \
        --table-name BomCalendar-Reports \
        --item "{
            \"PK\": {\"S\": \"USER#user-001\"},
            \"SK\": {\"S\": \"PERIOD#${MONTH}-15\"},
            \"startDate\": {\"S\": \"${MONTH}-15\"},
            \"endDate\": {\"S\": \"${MONTH}-20\"},
            \"flow\": {\"S\": \"normal\"},
            \"notes\": {\"S\": \"Sample period data\"}
        }" \
        --region ap-northeast-2
done

# List created tables
echo ""
echo "✅ DynamoDB initialization complete!"
echo ""
echo "📋 Created tables:"
aws dynamodb list-tables --endpoint-url http://localhost:8000 --region ap-northeast-2

echo ""
echo "📌 Access DynamoDB Admin UI at: http://localhost:8001"