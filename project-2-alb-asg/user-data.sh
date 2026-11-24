#!/bin/bash
dnf install -y httpd
echo "<h1>Welcome from $(hostname -f)</h1>" > /var/www/html/index.html
systemctl enable --now httpd
