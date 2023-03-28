# Provides a security group resource - https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group

resource "aws_security_group" "devVPC_wp_sg_allow_ssh_http"{
    vpc_id = module.customvpc.vpc_id
    name = "devVPC_wp_terraform_vpc_allow_ssh_http"

    tags = {
        Name = "devVPC_wp_terraform_sg_allow_ssh_http"
    }
}

# Ingress Security Port 22 (Inbound) - Provides a security group rule resource (https://registry.terraform.io.providers/hashicorp/aws/latest/docs/resources/security_group_rule)

resource "aws_security_group_rule" "devVPC_wp_ssh_ingress_access"{
    from_port = 22
    protocol = "tcp"
    security_group_id = aws_security_group.devVPC_wp_sg_allow_ssh_http.id
    to_port = 22
    type = "ingress"
    cidr_blocks = [var.cidr_blocks]    
}

# Ingress Security Port 80 (Inbound)
resource "aws_security_group_rule" "devVPC_wp_http_ingress_access"{
    from_port = 80 
    protocol = "tcp"
    security_group_id = aws_security_group.devVPC_wp_sg_allow_ssh_http.id
    to_port= 80
    type = "ingress"
    cidr_blocks = [var.cidr_blocks]
}

# Egress Security(Outbound)
resource "aws_security_group_rule" "devVPC_wp_http_egress_access"{
    from_port = 0 
    protocol = "-1"
    security_group_id = aws_security_group.devVPC_wp_sg_allow_ssh_http.id
    to_port= 0
    type = "egress"
    cidr_blocks = [var.cidr_blocks]
}
