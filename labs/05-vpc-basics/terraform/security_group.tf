# If we don't specify a security group, EC2 uses the VPC's default security group.
# The default security group usually:
# - allows all outbound traffic
# - allows inbound traffic only from resources using the same default security group

resource "aws_security_group" "web" {
  name   = "05-vpc-basics-web"
  vpc_id = aws_vpc.lab.id

  # Traffic into the resource
  ingress {
    description = "Allow HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Anyone can reach this resource over HTTP
  }

  # Traffic out from the resource
  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"          # All protocols
    cidr_blocks = ["0.0.0.0/0"] # Can reach any IPv4 address
  }

  tags = {
    Name = "05-vpc-basics-web-sg"
  }
}
