# Declaring the AWS Provider
provider "aws" {
  region = "us-west-1"
}

# Role
resource "aws_iam_role" "instance_role" {
  name = "my_test_role"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

resource "aws_iam_instance_profile" "test-profile" {
  name = "test_profile"
  role = aws_iam_role.instance_role.name
}


resource "aws_iam_policy" "policy" {
  name        = "iam-policy-for-instance-role"
  description = "iam-policy-for-instance-role"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:Get*", "s3:List*", "ec2:*", "SNS:List*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = aws_iam_role.instance_role.name
  policy_arn = aws_iam_policy.policy.arn
}

/*resource "aws_s3_bucket" "bucket" {
  bucket = "my-s3-test-bucket-99999"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}*/

data "aws_ami" "amzLinux2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-gp2"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_instance" "web" {
  ami                  = data.aws_ami.amzLinux2.id
  instance_type        = "t3.micro"
  iam_instance_profile = aws_iam_instance_profile.test-profile.id
  key_name = "ansible-key"

  tags = {
    Name = "Test_Instance_profile"
  }
}