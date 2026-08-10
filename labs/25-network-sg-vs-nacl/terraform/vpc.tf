resource "aws_vpc" "test" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
}

resource "aws_internet_gateway" "test" {
  vpc_id = aws_vpc.test.id
}

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.test.id
  cidr_block        = cidrsubnet(aws_vpc.test.cidr_block, 8, 1)
  availability_zone = data.aws_availability_zones.available.names[0]
}

resource "aws_network_acl" "public" {
  vpc_id     = aws_vpc.test.id
  subnet_ids = [aws_subnet.public.id]

  # Tested explicit deny.
  # Because rule 50 is evaluated before rule 100,
  # HTTP traffic is denied even though a later rule allows it.
  #
  # ingress {
  #   action     = "deny"
  #   protocol   = "tcp"
  #   cidr_block = "0.0.0.0/0"
  #   from_port  = 80
  #   to_port    = 80
  #   rule_no    = 50
  # }

  ingress {
    action     = "allow"
    protocol   = "tcp"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
    rule_no    = 100
  }

  # Tested allowing only outbound port 80.
  # This blocks HTTP return traffic because the client uses
  # an ephemeral source port, not port 80.
  #
  # Verified the client port with:
  # lsof -iTCP -n -P | grep curl
  #
  # egress {
  #   action     = "allow"
  #   cidr_block = "0.0.0.0/0"
  #   protocol   = "tcp"
  #   from_port  = 80
  #   to_port    = 80
  #   rule_no    = 150
  # }

  # Tested explicit deny of outbound ephemeral ports.
  # Because rule 180 is evaluated before rule 200,
  # the deny rule matches first and curl hangs/times out.
  #
  # egress {
  #   action     = "deny"
  #   cidr_block = "0.0.0.0/0"
  #   protocol   = "tcp"
  #   from_port  = 1024
  #   to_port    = 65535
  #   rule_no    = 180
  # }

  # Allow return traffic to client ephemeral ports.
  egress {
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    protocol   = "tcp"
    from_port  = 1024
    to_port    = 65535
    rule_no    = 200
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.test.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.test.id
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}
