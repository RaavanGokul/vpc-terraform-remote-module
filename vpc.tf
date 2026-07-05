resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_host
  tags                 = merge(var.tags, { "Name" = "${var.name}-vpc" })
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = merge({ "Name" = "${var.name}-igw" }, var.tags)
}

resource "aws_subnet" "public_subnet" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = element(var.public_subnet_cidrs, count.index)
  availability_zone       = length(var.public_subnet_azs) > 0 ? element(var.public_subnet_azs, count.index) : null
  map_public_ip_on_launch = true
  tags                    = merge(var.tags, var.public_subnet_tag, { "Name" = "${var.name}-pub-${count.index + 1}" })
}

resource "aws_subnet" "private" {
  count                   = length(var.private_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = element(var.private_subnet_cidrs, count.index)
  availability_zone       = length(var.private_subnet_azs) > 0 ? element(var.private_subnet_azs, count.index) : null
  map_public_ip_on_launch = false
  tags                    = merge(var.tags, var.private_subnet_tag, { "Name" = "${var.name}-private-${count.index + 1}" })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = merge({ Name = "${var.name}-public-rt" }, var.tags)
}
resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public_subnet)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_eip" "nat" {
  count      = var.create_nat ? 1 : 0
  tags       = merge({ Name = "${var.name}-nat-eip-${count.index + 1}" }, var.tags)
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_nat_gateway" "nat" {
  count         = var.create_nat ? 1 : 0
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public_subnet[count.index % length(aws_subnet.public_subnet)].id
  tags          = merge({ Name = "${var.name}-nat-gw-${count.index + 1}" }, var.tags)
  depends_on    = [aws_internet_gateway.igw]
}
resource "aws_route_table" "private" {
  count  = var.create_nat ? 1 : 0
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat[count.index].id
  }
  tags = merge({ Name = "${var.name}-private-rt-${count.index + 1}" }, var.tags)
}

resource "aws_route_table_association" "private" {
  count          = var.create_nat ? length(aws_subnet.private) : 0
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index % length(aws_route_table.private)].id
}