module "template_files" {
  source = "hashicorp/dir/template"

  base_dir = "${path.module}/web"
}
##########################################################################
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}
##########################################################################
resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}
##########################################################################
resource "aws_lambda_function" "lambda-fn" {
  function_name = "lambda_function_name"
  runtime       = "python3.9"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "lambda_function.lambda_handler"
  filename      = "./lambda/lambda_function.py.zip"

  depends_on = [
    aws_iam_role.iam_for_lambda,
    data.aws_iam_policy_document.assume_role
  ]
}
##########################################################################
resource "aws_api_gateway_rest_api" "rest-api" {

  api_key_source               = "HEADER"
  disable_execute_api_endpoint = "false"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  minimum_compression_size = "-1"
  name                     = "tic-tac-toe-api"
}

output "rest-api-id" {
  value = aws_api_gateway_rest_api.rest-api.id
}

##########################################################################
resource "aws_api_gateway_resource" "api-gw-resource" {
  parent_id   = aws_api_gateway_rest_api.rest-api.root_resource_id
  path_part   = "myResource"
  rest_api_id = aws_api_gateway_rest_api.rest-api.id

  depends_on = [aws_api_gateway_rest_api.rest-api]
}

##########################################################################
resource "aws_api_gateway_method" "gw-method" {
  for_each = var.api-methods

  api_key_required = each.value.api_key_required
  authorization    = each.value.authorization
  http_method      = each.value.http_method
  resource_id      = aws_api_gateway_resource.api-gw-resource.id
  rest_api_id      = aws_api_gateway_rest_api.rest-api.id

  depends_on = [aws_api_gateway_rest_api.rest-api, aws_api_gateway_resource.api-gw-resource]
}
##########################################################################
resource "aws_api_gateway_method_response" "gw-method-response-1" {
  http_method = "OPTIONS"
  resource_id = aws_api_gateway_resource.api-gw-resource.id

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "false"
    "method.response.header.Access-Control-Allow-Methods" = "false"
    "method.response.header.Access-Control-Allow-Origin"  = "false"
  }

  rest_api_id = aws_api_gateway_rest_api.rest-api.id
  status_code = "200"

  depends_on = [aws_api_gateway_rest_api.rest-api, aws_api_gateway_resource.api-gw-resource, aws_api_gateway_method.gw-method]
}

resource "aws_api_gateway_method_response" "gw-method-response-2" {
  http_method = "POST"

  resource_id = aws_api_gateway_resource.api-gw-resource.id

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "false"
  }

  rest_api_id = aws_api_gateway_rest_api.rest-api.id
  status_code = "200"
  depends_on  = [aws_api_gateway_rest_api.rest-api, aws_api_gateway_resource.api-gw-resource, aws_api_gateway_method.gw-method]
}
##########################################################################
resource "aws_api_gateway_integration" "gw-integration-1" {
  cache_namespace      = aws_api_gateway_resource.api-gw-resource.id
  connection_type      = "INTERNET"
  http_method          = "OPTIONS"
  passthrough_behavior = "WHEN_NO_MATCH"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }


  resource_id = aws_api_gateway_resource.api-gw-resource.id
  rest_api_id          = aws_api_gateway_rest_api.rest-api.id
  timeout_milliseconds = "29000"
  type                 = "MOCK"

  depends_on = [aws_api_gateway_rest_api.rest-api, aws_api_gateway_resource.api-gw-resource, aws_api_gateway_method.gw-method, aws_api_gateway_method_response.gw-method-response-1, aws_api_gateway_method_response.gw-method-response-2]

}
##########################################################################
resource "aws_lambda_permission" "apigw-lambda" {
  statement_id = "AllowExecutionFromAPIGateway"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda-fn.function_name
  principal = "apigateway.amazonaws.com"
  source_arn = aws_api_gateway_rest_api.rest-api.execution_arn
  
  depends_on = [
    aws_api_gateway_rest_api.rest-api,
    aws_api_gateway_resource.api-gw-resource,
    aws_api_gateway_method.gw-method,
    aws_lambda_function.lambda-fn
  ]
}
##########################################################################
resource "aws_api_gateway_integration" "gw-integration-2" {
  cache_namespace         = aws_api_gateway_resource.api-gw-resource.id
  connection_type         = "INTERNET"
  content_handling        = "CONVERT_TO_TEXT"
  http_method             = "POST"
  integration_http_method = "POST"
  passthrough_behavior    = "WHEN_NO_MATCH"
  resource_id = aws_api_gateway_resource.api-gw-resource.id
  rest_api_id          = aws_api_gateway_rest_api.rest-api.id
  timeout_milliseconds = "29000"
  type                 = "AWS"
  uri                  = aws_lambda_function.lambda-fn.invoke_arn

  depends_on = [ aws_lambda_function.lambda-fn, aws_iam_role.iam_for_lambda, aws_api_gateway_rest_api.rest-api ]
}
##########################################################################
resource "aws_api_gateway_integration_response" "gw-integration-response-1" {
  http_method = "OPTIONS"

  resource_id          = aws_api_gateway_resource.api-gw-resource.id

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'OPTIONS,POST'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

  rest_api_id          = aws_api_gateway_rest_api.rest-api.id
  status_code = "200"

  depends_on = [aws_api_gateway_integration.gw-integration-1, aws_api_gateway_rest_api.rest-api, aws_api_gateway_resource.api-gw-resource, aws_api_gateway_method.gw-method, aws_api_gateway_method_response.gw-method-response-1, aws_api_gateway_method_response.gw-method-response-2]
}

resource "aws_api_gateway_integration_response" "gw-integration-response-2" {
  http_method = "POST"
  resource_id          = aws_api_gateway_resource.api-gw-resource.id

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }

  rest_api_id          = aws_api_gateway_rest_api.rest-api.id
  status_code = "200"

  depends_on = [
    aws_api_gateway_rest_api.rest-api, aws_api_gateway_resource.api-gw-resource, 
    aws_api_gateway_method.gw-method, 
    aws_api_gateway_method_response.gw-method-response-1, 
    aws_api_gateway_method_response.gw-method-response-2, aws_lambda_function.lambda-fn,
    aws_api_gateway_integration.gw-integration-2
  ]
}
##########################################################################
resource "aws_api_gateway_deployment" "api-deploy" {
  rest_api_id             = aws_api_gateway_rest_api.rest-api.id

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_method.gw-method,
    aws_api_gateway_integration.gw-integration-1
    ]
}
##########################################################################
resource "aws_api_gateway_stage" "gw-stage" {
    deployment_id = aws_api_gateway_deployment.api-deploy.id
    rest_api_id = aws_api_gateway_rest_api.rest-api.id
    stage_name = "dev" 
}
######################################################################
resource "aws_s3_bucket" "hosting_bucket" {
  bucket = var.bucket_name
}
######################################################################
resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.hosting_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false

  depends_on = [aws_s3_bucket.hosting_bucket]
}
######################################################################
resource "aws_s3_bucket_policy" "hosting_bucket_policy" {
  bucket = aws_s3_bucket.hosting_bucket.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : "*",
        "Action" : "s3:GetObject",
        "Resource" : "${aws_s3_bucket.hosting_bucket.arn}/*"
      }
    ]
  })

  depends_on = [aws_s3_bucket.hosting_bucket, aws_s3_bucket_public_access_block.example]
}
######################################################################
resource "aws_s3_bucket_website_configuration" "hosting_bucket_website_configuration" {
  bucket = aws_s3_bucket.hosting_bucket.id

  index_document {
    suffix = "index.html"
  }

  depends_on = [aws_s3_bucket.hosting_bucket]
}
######################################################################
resource "aws_s3_object" "hosting_bucket_files" {
  bucket = aws_s3_bucket.hosting_bucket.id

  for_each = module.template_files.files

  key          = each.key
  content_type = each.value.content_type

  source  = each.value.source_path
  content = each.value.content

  etag = each.value.digests.md5

  depends_on = [aws_s3_bucket.hosting_bucket]
}
######################################################################
