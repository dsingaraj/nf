# Network Mask - 255.255.255.0 Addresses Available - 256
variable "instance_type"{
    default = "t3.micro"
}

variable "cidr_blocks"{
    default = "0.0.0.0/0"
}