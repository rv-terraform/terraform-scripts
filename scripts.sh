#!/bin/bash

curl -o /etc/yum.repos.d/centos.repo https://raw.githubusercontent.com/tso-ansible/ansible-tower/master/centos.repo
curl -o /tmp https://archive.fedoraproject.org/pub/epel/7Server/x86_64/Packages/e/epel-release-7-11.noarch.rpm
cd /tmp
rpm -ivh epel-release-7-11.noarch.rpm
yum install git httpd -y
firewall-cmd --permanent --add-port=80/tcp
firewall-cmd --permanent --add-port=443/tcp
