
########################################
# Environment setting
########################################
env         = "mz-demo-prj3"
aws_region  = "ap-northeast-2"
aws_profile = "mz"


########################################
# VPC C-class
########################################
vpc_prefix             = "eks-prj3"
vpc_cidr_block         = "192.168.0.0/16"
vpc_availability_zones = ["ap-northeast-2a", "ap-northeast-2b"]
vpc_public_subnets     = ["192.168.101.0/24", "192.168.102.0/24"]
vpc_private_subnets    = ["192.168.10.0/24", "192.168.20.0/24"]
vpc_database_subnets   = ["192.168.151.0/24", "192.168.152.0/24"]
vpc_enable_nat_gateway = true
vpc_single_nat_gateway = true

vpc_create_database_subnet_group       = true
vpc_create_database_subnet_route_table = true
