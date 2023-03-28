resource "aws_launch_configuration" "nginx_launch_config"{
    image_id = data.aws_ami.packeramisnginx.id
    instance_type = var.instance_type
    security_groups = [aws_security_group.devVPC_sg_allow_ssh_http.id]

    user_data = data.template_file.init.rendered

    lifecycle {      
      create_before_destroy = true
    }    
}

resource "aws_autoscaling_group" "nginx_autoscaling_group"{
    launch_configuration = aws_launch_configuration.nginx_launch_config.id
    vpc_zone_identifier = [aws_subnet.devVPC_public_subnet.id]

    health_check_type = "ELB"

    min_size = 2
    max_size = 5
    load_balancers = [aws_elb.nginx-elb.id]

    tag{
        key = "Name"
        value = "dev_terraform_nginx_instance_asg"
        propagate_at_launch = true
    }
}

resource "aws_autoscaling_policy" "nginx_cpu_policy_scaleup"{
    name = "nginx_cpu_policy_scaleup"
    autoscaling_group_name = aws_autoscaling_group.nginx_autoscaling_group.name
    adjustment_type = "ChangeInCapacity"
    scaling_adjustment = 1
    cooldown="120"
}

resource "aws_autoscaling_policy" "nginx_cpu_policy_scaledown"{
    name = "nginx_cpu_policy_scaledown"
    autoscaling_group_name = aws_autoscaling_group.nginx_autoscaling_group.name
    adjustment_type = "ChangeInCapacity"
    scaling_adjustment = -1
    cooldown="120"
}

#Get latest AMI ID based on Filter - Here AMI created using packer
data "aws_ami" "packeramiswordpress"{
  owners= ["052784389769"]
  most_recent=true

  filter{
    name = "name"
    values=["packer-wp*"]
  }
}

# The template file data source usually loaded from an external file.

data "template_file" "init" {
    template = file("${path.module}/userdata.tpl")
}