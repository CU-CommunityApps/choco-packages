[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$USER_DATA_URI = "http://169.254.169.254/latest/user-data"
$BUCKET_PREFIX = "image-build-package-bucket"

$raw_user_data = (Invoke-WebRequest $USER_DATA_URI).Content
$user_data = [System.Text.Encoding]::ASCII.GetString($raw_user_data) | ConvertFrom-Json
$arn = $user_data.resourceArn.split(':')
$region = $arn[3]
$account = $arn[4]
$bucket = "$BUCKET_PREFIX-$account-$region"
$api_uri = (Invoke-WebRequest "https://s3.amazonaws.com/$bucket/api_endpoint.txt").Content.Trim()
$creds = (Invoke-WebRequest "$api_uri/get-build").Content | ConvertFrom-Json

