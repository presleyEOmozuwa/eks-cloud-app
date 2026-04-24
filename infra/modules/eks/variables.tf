// value from iam resource
variable "eks_role_arn" {
   type = string
}

// value from iam resource
variable "node_role_arn" {
   type = string
}

// value from iam resource
variable "cicd_role_arns" {
   type = map(string)
}

// value from vpc resource
variable "subnet_ids" {
   type = list(string)
}

variable "project" {
  type = string
}

variable "environment" {
  type = string
}







