provider "aws" {
#  version = "~> 2.32"  #fix after "terraform init"
}

provider "aws" {
  alias = "virginia"
  region = "us-east-1"
}