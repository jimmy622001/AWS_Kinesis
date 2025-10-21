# PowerShell script to run CloudFormation Guard validation

# Convert Terraform to CloudFormation format first
terraform plan -out=tfplan
terraform show -json tfplan > terraform-plan.json

# Install cfn-guard if not already installed
if (!(Get-Command cfn-guard -ErrorAction SilentlyContinue)) {
    Write-Host "Installing CloudFormation Guard..."
    # Download and install cfn-guard from GitHub releases
    Invoke-WebRequest -Uri "https://github.com/aws-cloudformation/cloudformation-guard/releases/latest/download/cfn-guard-v3-windows-latest.zip" -OutFile "cfn-guard.zip"
    Expand-Archive -Path "cfn-guard.zip" -DestinationPath "."
    Remove-Item "cfn-guard.zip"
}

# Run Guard validation
Write-Host "Running CloudFormation Guard validation..."
.\cfn-guard.exe validate --rules .cfn-guard\rules.guard --data terraform-plan.json --output-format json

# Cleanup
Remove-Item tfplan -ErrorAction SilentlyContinue
Remove-Item terraform-plan.json -ErrorAction SilentlyContinue