resource "aws_vpc" "default" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_hostnames = "${var.enable_dns_hostnames}"
  enable_dns_support   = "${var.enable_dns_support}"

  tags = "${merge(var.default_tags, map(
        "Name", "${var.env}-vpc-${var.project}",
        "Description", "${var.project} VPC"
    ))}"
}

resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"

  tags = "${merge(var.default_tags, map(
        "Name", "${var.project}-${var.env}-internet-gateway",
        "Description", "${var.project} Internet Gateway"
    ))}"
}
resource "aws_route_table" "public_rt" {
  vpc_id = "${aws_vpc.default.id}"

  route {
    cidr_block      = "0.0.0.0/0"
    gateway_id  = "${aws_internet_gateway.default.id}"
  }

  tags = "${merge(var.default_tags, map(
        "Name", "${var.project}-${var.env}-public-route_table",
        "Description", "${var.project} Public Route Table"
    ))}"
}
resource "aws_subnet" "public-subnet-aza" {
  vpc_id            = "${aws_vpc.default.id}"
  availability_zone = "${var.aws_region}a"
  cidr_block        = "${var.pub_subnet_aza_cidr}"

  tags = "${merge(var.default_tags, map(
        "Name", "${var.project}-${var.env}-public-subnet-aza",
        "Description", "${var.project} Internet Gateway"
    ))}"
}

resource "aws_route_table_association" "rta_public_aza" {
  subnet_id      = "${aws_subnet.public-subnet-aza.id}"
  route_table_id = "${aws_route_table.public_rt.id}"
}
resource "aws_subnet" "private-subnet-aza" {
  vpc_id            = "${aws_vpc.default.id}"
  availability_zone = "${var.aws_region}a"
  cidr_block        = "${var.pvt_subnet_aza_cidr}"

  tags = "${merge(var.default_tags, map(
        "Name", "${var.project}-${var.env}-private-subnet-azb",
        "Description", "${var.project} Internet Gateway"
    ))}"
}
resource "aws_eip" "default" {
        vpc     = true
}
resource "aws_nat_gateway" "default" {
  allocation_id = "${aws_eip.default.id}"
  subnet_id     = "${aws_subnet.public-subnet-aza.id}"
        depends_on              = ["aws_internet_gateway.default"]

  tags = "${merge(var.default_tags, map(
        "Name", "${var.project}-${var.env}-nat-gateway",
        "Description", "${var.project} NAT Gateway"
    ))}"
  }
resource "aws_route_table_association" "rta_private_aza" {
  subnet_id      = "${aws_subnet.private-subnet-aza.id}"
  route_table_id = "${aws_route_table.private_rt.id}"
}
resource "aws_route_table" "private_rt" {
  vpc_id = "${aws_vpc.default.id}"

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.default.id}"
  }

  tags = "${merge(var.default_tags, map(
        "Name", "${var.project}-${var.env}-private-route_table",
        "Description", "${var.project} Private Route Table"
    ))}"
}
resource "aws_security_group" "web-sg" {
  name        = "public web SG"
  description = "Public Web Security Group"
  vpc_id      = "${aws_vpc.default.id}"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${merge(var.default_tags, map(
        "Name", "${var.project}-${var.env}-pub-security-group",
        "Description", "${var.project} Public Security Group"
    ))}"
}
resource "aws_instance" "ami"{
   ami  = "${var.ami_id}"
   instance_type = "t2.micro"
   key_name = "${var.aws_key_pair}"
   subnet_id = "${aws_subnet.public-subnet-aza.id}"

 root_block_device {
   volume_type = "gp2"
   volume_size = "8"
}
}
