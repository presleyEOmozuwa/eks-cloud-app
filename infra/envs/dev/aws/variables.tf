#############################################
# EKS VARIABLES
#############################################

variable "environment" {
  type = string
}

variable "subnet_ids" {
   type = list(string)
}

variable "project" {
  type = string
}

variable "region" {
  type = string
}

variable "github_org" {
   type = string
}

variable "github_repo" {
   type = string
}

#############################################
# VPC  VARIABLES
#############################################

variable "public_subnet_tags_1" {
    type = object({
      Name = string
    })
}

variable "public_subnet_tags_2" {
    type = object({
      Name = string
    })
}

variable "igw_tags" {
   type = object({
     Name = string
   })
}

variable "rt_tags" {
   type = object({
     Name = string
   })
}

variable "sg_tags" {
   type = object({
     Name = string
   })
}