#!/bin/bash

curl -o /etc/yum.repos.d/centos.repo https://raw.githubusercontent.com/tso-ansible/ansible-tower/master/centos.repo
yum install epel-release -y
yum update -y
yum install httpd -y
firewall-cmd --permanent --add-port=80/tcp
systemctl enable httpd.service
systemctl restart httpd.service
