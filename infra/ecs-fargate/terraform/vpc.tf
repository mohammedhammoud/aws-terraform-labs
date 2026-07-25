resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${local.name_prefix}-vpc"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  count                   = local.az_count
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${local.name_prefix}-public-${var.availability_zones[count.index]}"
  }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  count             = local.az_count
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, local.az_count + count.index)
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "${local.name_prefix}-private-${var.availability_zones[count.index]}"
  }
}

resource "aws_subnet" "db" {
  vpc_id            = aws_vpc.main.id
  count             = local.az_count
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, local.az_count * 2 + count.index)
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "${local.name_prefix}-db-${var.availability_zones[count.index]}"
  }
}

resource "aws_eip" "nat" {
  count  = local.az_count
  domain = "vpc"

  tags = {
    Name = "${local.name_prefix}-nat-eip-${var.availability_zones[count.index]}"
  }
}

resource "aws_internet_gateway" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${local.name_prefix}-igw"
  }
}

resource "aws_nat_gateway" "main" {
  count         = local.az_count
  subnet_id     = aws_subnet.public[count.index].id
  allocation_id = aws_eip.nat[count.index].id

  depends_on = [
    aws_internet_gateway.public
  ]

  tags = {
    Name = "${local.name_prefix}-nat-gw-${var.availability_zones[count.index]}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.public.id
  }

  tags = {
    Name = "${local.name_prefix}-rt-public"
  }
}

resource "aws_route_table_association" "public" {
  count          = local.az_count
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  count  = local.az_count
  vpc_id = aws_vpc.main.id

  route {
    nat_gateway_id = aws_nat_gateway.main[count.index].id
    cidr_block     = "0.0.0.0/0"
  }

  tags = {
    Name = "${local.name_prefix}-rt-private-${var.availability_zones[count.index]}"
  }
}

resource "aws_route_table_association" "private" {
  count          = local.az_count
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

resource "aws_route_table" "db" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${local.name_prefix}-rt-db"
  }
}

resource "aws_route_table_association" "db" {
  count          = local.az_count
  subnet_id      = aws_subnet.db[count.index].id
  route_table_id = aws_route_table.db.id
}
