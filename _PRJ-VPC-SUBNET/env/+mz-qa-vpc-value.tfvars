
########################################
# Environment setting
########################################
env         = "mz-qa-prj"
aws_region  = "ap-northeast-2"
aws_profile = "mz"


########################################
# VPC B-class
########################################
vpc_prefix             = "eks-vpc-qa"
vpc_cidr_block         = "172.16.0.0/16"
vpc_availability_zones = ["ap-northeast-2a", "ap-northeast-2b"]
vpc_public_subnets     = ["172.16.101.0/24", "172.16.102.0/24"]
vpc_private_subnets    = ["172.16.1.0/24", "172.16.2.0/24"]
vpc_database_subnets   = ["172.16.151.0/24", "172.16.152.0/24"]
vpc_enable_nat_gateway = true
vpc_single_nat_gateway = true

vpc_create_database_subnet_group       = true
vpc_create_database_subnet_route_table = true
