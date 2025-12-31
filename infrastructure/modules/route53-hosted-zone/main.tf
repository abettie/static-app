resource "aws_route53_zone" "main" {
  name = var.domain_name

  tags = merge(
    {
      Name        = var.domain_name
      Environment = var.environment
    },
    var.tags
  )
}
