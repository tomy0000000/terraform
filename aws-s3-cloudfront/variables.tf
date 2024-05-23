variable "project-name" {
  type        = string
  description = "Name of the project to tag"
  default     = "playground"
}

variable "bucket-region" {
  type        = string
  description = "Region where the bucket is created"
  default     = "us-east-1"
}

variable "bucket-name" {
  type        = string
  description = "Name of the bucket to create"
}

variable "cloudfront-origin-shield-region" {
  type        = string
  description = "Region to add an additional caching layer"
}

variable "domain" {
  type        = string
  description = "Domain name to serve the assets"
}
