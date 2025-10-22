#!/bin/bash
# DR Failover Testing Script

# Set variables
PROJECT_NAME=$(terraform output -raw project_name)
PRIMARY_REGION=$(terraform output -raw aws_region)
DR_REGION=$(terraform output -raw disaster_recovery_dr_region)
APP_DOMAIN=$(terraform output -raw application_domain)
LAMBDA_FUNCTION_NAME="${PROJECT_NAME}-dr-failover"

echo "==================================================="
echo "Starting Disaster Recovery Failover Test"
echo "==================================================="
echo "Project: $PROJECT_NAME"
echo "Primary region: $PRIMARY_REGION"
echo "DR region: $DR_REGION"
echo "Application domain: $APP_DOMAIN"
echo "---------------------------------------------------"

# Capture initial state
echo "Capturing initial state..."
echo "Checking primary region health..."
PRIMARY_HEALTH=$(aws --region $PRIMARY_REGION cloudwatch get-metric-statistics \
  --namespace AWS/ApplicationELB \
  --metric-name HealthyHostCount \
  --start-time "$(date -u -d '5 minutes ago' '+%Y-%m-%dT%H:%M:%SZ')" \
  --end-time "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" \
  --period 60 \
  --statistics Average)

echo "Checking DNS configuration..."
DNS_BEFORE=$(dig +short $APP_DOMAIN)

echo "---------------------------------------------------"
echo "Current DNS points to: $DNS_BEFORE"
echo "---------------------------------------------------"

echo "Initiating simulated failover..."
echo "Invoking Lambda function $LAMBDA_FUNCTION_NAME"
aws lambda invoke \
  --region $PRIMARY_REGION \
  --function-name $LAMBDA_FUNCTION_NAME \
  --payload '{"TestFailover": true}' \
  /tmp/lambda_output.json

echo "---------------------------------------------------"
echo "Failover initiated. Waiting for DNS propagation (60 seconds)..."
sleep 60

# Check post-failover state
echo "Checking post-failover state..."
DNS_AFTER=$(dig +short $APP_DOMAIN)

echo "---------------------------------------------------"
echo "DNS now points to: $DNS_AFTER"
echo "---------------------------------------------------"

# Test application health in DR region
echo "Testing application health in DR region..."
DR_APP_HEALTH=$(curl -s -o /dev/null -w "%{http_code}" https://$APP_DOMAIN/health)

echo "Application health check status: $DR_APP_HEALTH"

# Report summary
echo "==================================================="
echo "DR Failover Test Summary"
echo "==================================================="
echo "Pre-failover DNS: $DNS_BEFORE"
echo "Post-failover DNS: $DNS_AFTER"
echo "Application health: $DR_APP_HEALTH"

if [ "$DNS_BEFORE" != "$DNS_AFTER" ] && [ "$DR_APP_HEALTH" == "200" ]; then
  echo "✅ DR FAILOVER TEST SUCCESSFUL"
else
  echo "❌ DR FAILOVER TEST FAILED"
  echo "See logs for details"
fi

echo "==================================================="