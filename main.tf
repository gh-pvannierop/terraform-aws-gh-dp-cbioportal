provider aws {
  region = var.aws_region
  version = "~> 3.74.1"
}

provider github {
}

terraform {
  backend "s3" {
  }
}