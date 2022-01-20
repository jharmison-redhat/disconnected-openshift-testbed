resource "aws_route53_zone" "private" {
  name = "internal.${var.cluster_name}.${var.cluster_domain}"
  vpc {
    vpc_id = aws_vpc.vpc.id
  }
}
