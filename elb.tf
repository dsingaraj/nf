# Elastic Load Balancer resource, also known as a Classic Load Balancer 
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elb

resource "aws_elb" "nginx-elb"{
    name = "nginx-elb"
    subnets = [module.customvpc.public_subnet]
    security_groups = [aws_security_group.devVPC_wp_sg_allow_ssh_http.id]

    listener {
      instance_port = 80 
      instance_protocol = "http"
      lb_port = 80
      lb_protocol = "http"
    }

    health_check {
      healthy_threshold = 3
      unhealthy_threshold = 3
      timeout = 3
      target = "HTTP:80/"
      interval = 30
    }
    tags = {
        Name = "nginx_elb"
    }
}
