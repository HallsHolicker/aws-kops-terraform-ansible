variable "key_pair" {
  default = "study-aws"
}

variable "study_name" {
  default = "pkos2"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "kops_subnet_cidr" {
  default = "10.0.0.0/24"
}

variable "s3_bucker_name" {
  default = "hallsholicker-kops"
}
