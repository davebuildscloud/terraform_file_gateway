data "aws_vpc" "deployment_vpc" {
  id = "${var.vpc_id}"
}

data "aws_route53_zone" "zone_name" {
  name = "${var.zone_name}"
}

data "aws_ami" "gateway_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["aws-thinstaller-1528922603"]
  }
}

resource "aws_instance" "gateway" {
  ami           = "${data.aws_ami.gateway_ami.image_id}"
  instance_type = "${var.instance_type}"

  # Refer to AWS File Gateway documentation for minimum system requirements.
  ebs_optimized = true
  subnet_id     = "${var.subnet_id}"

  ebs_block_device {
    device_name           = "/dev/xvdf"
    volume_size           = "${var.ebs_cache_volume_size}"
    volume_type           = "gp2"
    delete_on_termination = true
  }

  key_name = "${var.key_name}"

  vpc_security_group_ids = [
    "${aws_security_group.storage_gateway.id}",
  ]
}

resource "aws_storagegateway_gateway" "nfs_file_gateway" {
  gateway_ip_address = "${aws_instance.gateway.private_ip}"
  gateway_name       = "${var.gateway_name}"
  gateway_timezone   = "${var.gateway_time_zone}"
  gateway_type       = "FILE_S3"
}

data "aws_storagegateway_local_disk" "cache" {
  disk_path   = "/dev/xvdf"
  node_path   = "/dev/xvdf"
  gateway_arn = "${aws_storagegateway_gateway.nfs_file_gateway.id}"
}

resource "aws_storagegateway_cache" "nfs_cache_volume" {
  disk_id     = "${data.aws_storagegateway_local_disk.cache.id}"
  gateway_arn = "${aws_storagegateway_gateway.nfs_file_gateway.id}"
}

resource "aws_route53_record" "gateway_A_record" {
  zone_id = "${data.aws_route53_zone.zone_name.zone_id}"
  name    = "${var.gateway_name}"
  type    = "A"
  ttl     = "3600"
  records = ["${aws_instance.gateway.private_ip}"]
}

resource "aws_s3_bucket" "bucket" {
  bucket = "${var.bucket_name}"
  acl    = "private"
  region = "${var.bucket_region}"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_storagegateway_nfs_file_share" "same_account" {
  client_list  = ["${var.client_access_list}"]
  gateway_arn  = "${aws_storagegateway_gateway.nfs_file_gateway.id}"
  role_arn     = "${aws_iam_role.role.arn}"
  location_arn = "${aws_s3_bucket.bucket.arn}"
}
