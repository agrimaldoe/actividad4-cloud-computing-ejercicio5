set -euo pipefail

: "${CODE_BUCKET:?Define CODE_BUCKET en Variables de entorno}"
: "${ROLE_ARN:?Define ROLE_ARN en Variables de entorno}"
: "${DEST_BUCKET:?Define DEST_BUCKET en Variables de entorno}"
: "${TRIGGER_BUCKET:?Define TRIGGER_BUCKET en Variables de entorno}"
: "${FUNCTION_NAME:?Define FUNCTION_NAME en Variables de entorno}"

zip -r lambdaCode.zip lambdaCode/
aws s3 cp lambdaCode.zip "s3://${CODE_BUCKET}/lambdaCode.zip"

aws cloudformation validate-template --template-body file://template.yaml || true

mkdir -p output
cat > output/params.json <<JSON
{
  "Parameters": {
    "ExistingRoleArn": "${ROLE_ARN}",
    "CodeBucketName": "${CODE_BUCKET}",
    "DestinationBucketName": "${DEST_BUCKET}",
    "TriggerBucketName": "${TRIGGER_BUCKET}",
    "StudentFunctionName": "${FUNCTION_NAME}"
  }
}
JSON
