provider "aws" {
    region = "us-west-2"
}

module "customvpc"{
    source = "./Custommodules/customvpc"
    region = "us-west-2"
    cidr_blocks = "0.0.0.0/0"
    vpc_cidr_block="10.0.0.0/16"
    public_cidr = "10.0.0.0/24"
    private_cidr = "10.0.0.0/24"
}
