#!/bin/bash
# Script to package the DR failover Lambda function

# Navigate to the script directory
cd "$(dirname "$0")"

# Create a temporary directory
mkdir -p temp_lambda

# Copy the Lambda function to the temporary directory
cp dr_failover_function.js temp_lambda/index.js

# Create the ZIP file
cd temp_lambda
zip -r ../dr_failover_function.zip .
cd ..

# Clean up
rm -rf temp_lambda

echo "Lambda function packaged as dr_failover_function.zip"