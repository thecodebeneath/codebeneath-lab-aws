# resource "aws_instance" "gitlab-ec2" {
#   ami =
#   key_name =
  
#   user_data = file("${path.module}/gitlab-userdata.sh")
# }

# resource "aws_ebs_volume" "data-volume" {
#   size = 100
#   type = "gp3"
#   availability_zone = aws_instance.gitlab-ec2.availability_zone
#  )
# }

# resource "aws_volume_attachment" "data-volume_attachment" {
#     device_name = "/dev/sdd"
#     instance_id = aws_instance.gitlab-ec2.id
#     volume_id = aws_ebs_volume.data-volume.id
# }
