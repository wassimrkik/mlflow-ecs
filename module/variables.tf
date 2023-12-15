variable "role_name" {
  type        = string
  description = "Name of the role, which will be prefixed with App_"
}

variable "service" {
  type        = string
  description = "AWS service to trust: [ec2,lambda]"
  default     = "ec2"
  # Terraform 13
  # validation {
  #   condition     = contains(["ec2", "lambda"], var.service)
  #   error_message = "Invalid value for: service"
  # }
}

variable "policy_json" {
  type        = string
  description = "Policy document in JSON format"
}
