ec2-boot-mount-ebs-volume-min: ec2-boot-mount-ebs-volume
	pyminifier ec2-boot-mount-ebs-volume > $@
	chmod +x $@
