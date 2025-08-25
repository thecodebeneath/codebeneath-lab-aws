resource "aws_resourcegroups_group" "lab-group" {
  name        = "${var.project-name}-rg"
  description = "All Codebeneath Lab resources"
  resource_query {
    type  = "TAG_FILTERS_1_0"
    query = <<JSON
{
  "ResourceTypeFilters": [
    "AWS::S3::Bucket",
    "AWS::EC2::Instance",
    "AWS::EC2::Volume",
    "AWS::EC2::VPC",
    "AWS::EC2::VPCEndpoint",
    "AWS::EC2::ClientVpnEndpoint",
    "AWS::ElasticLoadBalancingV2::LoadBalancer",
    "AWS::Route53::HostedZone",
    "AWS::CertificateManager::Certificate",
    "AWS::ECR::Repository"
  ],
  "TagFilters": [
    {
      "Key": "Environment",
      "Values": ["codebeneath-lab"]
    }
  ]
}
JSON
  }
  tags = {
    Name = var.project-name
  }
}
