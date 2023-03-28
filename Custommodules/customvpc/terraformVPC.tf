
# Providers are a logical abstration of an upstream API. They help to understand API # XXX: no example found in the provider docs
# and exposing provider resources such AWS, Google

provider "aws" {
    region = var.region
}

# Query all available Availability Zone; we will use specific availability zone using index - The Availability Zones data source
# provides access to the list of AWS availabililty zones which can be accessed by an AWS account specific to region configured in the provider. 

data "aws_availability_zones" "devVPC_wp_available"{}

# Providers a VPC resource

resource "aws_vpc" "devVPC_wp"{
    cidr_block =var.vpc_cidr
    enable_dns_hostnames=true
    enable_dns_support = true

    tags = {
        Name = "dev_terraform_vpc_wp"
    }
}

# Public subnet public CIDR block available in vars.tf and provisionersVPC

resource "aws_subnet" "devVPC_wp_public_subnet"{
    cidr_block = var.public_cidr
    vpc_id = aws_vpc.devVPC_wp_.id
    map_public_ip_on_launch = true
    availability_zone = data.aws_availability_zones.devVPC_wp_available.names[1]

    tags = {
        Name = "dev_terraform_vpc_wp_public_subnet"
    }    
}

resource "aws_subnet" "private_subnet"{
    cidr_block = var.private_cidr
    vpc_id = aws_vpc.devVPC_wp_.id
    map_public_ip_on_launch = false
    availability_zone = data.aws_availability_zones.devVPC_wp_available.names[1]

    tags = {
        Name = "dev_terraform_vpc_wp_private_subnet"
    }    
}

# To access EC2 instance inside a Virtual Private Cloud (VPC) we need an Internet Gateway 
# and a routing table Connecting the subnet to the Internet Gateway

# Creating Internet Gateway
# Provides a resource to create a VPC Internet Gateway

resource "aws_internet_gateway" "devVPC_wp_IGW"{
    vpc_id = aws_vpc.devVPC_wp_.id

    tags = {
        Name = "dev_terraform_vpc_wp_igw"
    }
}

# Provides a resource to create a VPC routing table
resource "aws_route_table" "devVPC_wp__public_route"{
    vpc_id = aws_vpc.devVPC_wp_.id

    route{
        cidr_block = var.cidr_blocks
        gateway_id = aws_internet_gateway.devVPC_wp_IGW.id
    }
    tags = {
        Name = "dev_terraform_vpc_wp_public_route"
    }
}

# Provides a resource to create an association between a Public Route Table and a Public Subnet

resource "aws_route_table_association" "public_subnet_association" {
    route_table_id = aws_route_table.devVPC_wp__public_route.id
    subnet_id = aws_subnet.devVPC_wp_public_subnet.id

    depends_on = [aws_route_table.devVPC_wp_public_route, aws_subnet.devVPC_wp_public_subnet]
}


# Create an Instance using latest Packer AMI and apply User Data
# This allows instances to be created, updated and deleted 
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance

resource "aws_instance" "wp-instance"{
    ami=data.aws_ami.packeramiswordpress.id
    instance_type=var.instance_type
    key_name= "terraform"
    vpc_security_group_ids = [aws_security_group.devVPC_wp_sg_allow_ssh_http.id]
    subnet_id = aws_subnet.devVPC_wp_public_subnet.id

    user_data = data.template_file.init.rendered
    
    tags = {
        Name = "dev_terraform_wp_instance"
    }
}