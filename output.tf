output "vpc_id" {
  value = "${aws_vpc.default.id}"
}

output "internet_gateway_id" {
  value = "${aws_internet_gateway.default.id}"
}

output "public_route_table_id" {
  value = "${aws_route_table.public_rt.id}"
}
output "private_subnet_aza_id" {
  value = "${aws_subnet.private-subnet-aza.id}"
}
output "private_route_table_id" {
  value = "${aws_route_table.private_rt.id}"
}
output "nat_gateway_id" {
  value = "${aws_nat_gateway.default.id}"
}
output "web_security_group_id" {
  value = "${aws_security_group.web-sg.id}"
}

