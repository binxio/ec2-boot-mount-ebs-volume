Mounts an EBS Volume on ec2 instance boot
=========================================
This utility is intended to be used in the boot phase of an EC2 instance. It will:

- wait for the EBS volume to be attached
- format the volume, if unformatted
- mounts the device

The utility will also work on Nitro-based instance types, where
the device name specified in the attach volume command is ignored. The 
volume will be assigned a device name which matches the pattern 
/dev/nvme[0-9]+n1, where the number is associated with the order 
in which the volumes was mounted.

On Nitro-based instance types, the volume will be queried for the
assigned device name using ebsnvme-id. This will ensure that 
the mount command is the same and independent of the machine type and
and order of volume attachment.

As the device name now potentially fluctuates on every boot,
the use of /etc/fstab is hazardous.

## Usage
In your cloud-init and the following bootcmd:
```
 - ec2-boot-mount-ebs-volume --device /dev/xvdd --directory /var/mysql --fstype ext4 --options defaults || shutdown now
```
this shuts down the instance, if an error occurs. Typically volumes are attached, with precious data. Allowing
the machine to continue to boot, while the disk is not mounted would be dangerous.
