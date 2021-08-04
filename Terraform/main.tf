provider "aws" {
  region = "us-west-2"
}

locals {
  test_workspace_map = {
    stage = "t2.nano"
    prod = "t2.micro"
  }

  test_workspace_instance_count = {
    stage = 1
    prod = 2
  }

  test_workspace_instance_count_fe = {
    "1" = 1
    "2" = 2
    "3" = 3
  }
}

data "aws_ami" "ubuntu" {
    most_recent = true

    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-hirsute-21.04-amd64-server-*"]
    }

    owners = ["099720109477"] # Canonical
}

resource "aws_subnet" "test_subnet" {
  vpc_id            = "vpc-d2a4a4aa"
  cidr_block        = "10.89.8.0/24"
  availability_zone = "us-west-2"

  tags = {
    Name = "test subnet"
  }
}

resource "aws_network_interface" "test_interface" {
  subnet_id   = aws_subnet.test_subnet.id
  private_ips = ["10.89.8.254"]

  tags = {
    Name = "primary_network_interface"
  }
}

resource "aws_instance" "test" {
    ami           = "${data.aws_ami.ubuntu.id}"
    # instance_type = "t2.micro"
    instance_type = local.test_workspace_map[terraform.workspace]
    count = local.test_workspace_instance_count[terraform.workspace]
    availability_zone = "us-west-2"
    key_name = "test_key_pair_1"

    network_interface {
    network_interface_id = aws_network_interface.test_interface.id
    device_index         = 0
    }

    tags = {
        Name = "Test ec2 instance"
    }
    lifecycle {
      create_before_destroy = true
    }
}

resource "aws_instance" "test2" {
    for_each = toset(["1","2"])
    ami           = "${data.aws_ami.ubuntu.id}"
    instance_type = local.test_workspace_map[terraform.workspace]
    availability_zone = "us-west-2"
}

data "aws_caller_identity" "identity" {}
data "aws_region" "region" {}
data "aws_subnet" "test" {
  id = aws_subnet.test_subnet.id
}
data "aws_network_interface" "test" {
  id = aws_network_interface.test_interface.id
}