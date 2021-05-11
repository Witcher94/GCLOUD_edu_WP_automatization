#! /bin/bash

# Creating symlink to the bucket directory
ln -s /mnt/ /var/www/

#mount cloud-bucket
gcsfuse -o nonempty -o allow_other wp-back-bucket /mnt/










