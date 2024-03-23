variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "bucket_name" {
  description = "Name of the bucket"
  type        = string
}

variable "api-methods" {
  type = map(object({
    api_key_required = string
    authorization = string
    http_method = string 
  }))
}

