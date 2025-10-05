set -euo pipefail
for v in CODE_BUCKET ROLE_ARN DEST_BUCKET TRIGGER_BUCKET FUNCTION_NAME; do : "${!v:?}"; done

# 1) Empaquetar
zip -rq lambdaCode.zip lambdaCode/

# 2) Subir y OBTENER VersionId en VER
VER=$(aws s3api put-object \
  --bucket "$CODE_BUCKET" \
  --key "lambdaCode.zip" \
  --body lambdaCode.zip \
  --query 'VersionId' --output text)

# 3) Generar params.json incluyendo CodeObjectVersion=VER
mkdir -p output
printf '{"Parameters":{"ExistingRoleArn":"%s","CodeBucketName":"%s","CodeObjectVersion":"%s","DestinationBucketName":"%s","TriggerBucketName":"%s","StudentFunctionName":"%s"}}' \
  "$ROLE_ARN" "$CODE_BUCKET" "$VER" "$DEST_BUCKET" "$TRIGGER_BUCKET" "$FUNCTION_NAME" > output/params.json