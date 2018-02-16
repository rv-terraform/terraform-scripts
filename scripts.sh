#!/bin/bash

curl -o /etc/yum.repos.d/centos.repo https://raw.githubusercontent.com/tso-ansible/ansible-tower/master/centos.repo

wget https://archive.fedoraproject.org/pub/epel/7Server/x86_64/Packages/e/epel-release-7-11.noarch.rpm


yum install epel-release -y
yum update -y
yum install httpd -y
systemctl enable firewalld
systemctl start firewalld
firewall-cmd --permanent --add-port=80/tcp
systemctl enable httpd.service
systemctl start httpd.service
