output "network" {
  value = {
    vpc_id              = aws_vpc.lab.id
    vpc_cidr            = aws_vpc.lab.cidr_block
    public_subnet_id    = aws_subnet.public.id
    public_subnet_cidr  = aws_subnet.public.cidr_block
    internet_gateway_id = aws_internet_gateway.lab.id
    route_table_id      = aws_route_table.public.id
  }
}

output "web_instance" {
  value = {
    security_group_id   = aws_security_group.web.id
    instance_id         = aws_instance.web.id
    instance_public_ip  = aws_instance.web.public_ip
    instance_private_ip = aws_instance.web.private_ip
  }
}
