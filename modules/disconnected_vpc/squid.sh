#!/bin/bash

sudo dnf -y update
sudo dnf -y install python36 squid

systemctl enable --now squid
sleep 5

iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 3129
iptables -t nat -A PREROUTING -p tcp --dport 443 -j REDIRECT --to-port 3130

cp -a /etc/squid /etc/squid_orig

# Create a SSL certificate for the SslBump Squid module
mkdir /etc/squid/ssl
pushd /etc/squid/ssl
openssl genrsa -out squid.key 4096
openssl req -new -key squid.key -out squid.csr -subj "/C=US/ST=VA/L=squid/O=squid/CN=squid"
openssl x509 -req -days 3650 -in squid.csr -signkey squid.key -out squid.crt
cat squid.key squid.crt >> squid.pem

echo '.amazonaws.com' > /etc/squid/whitelist.txt
echo '.cloudfront.net' >> /etc/squid/whitelist.txt

cat > /etc/squid/squid.conf << 'EOF'

visible_hostname squid
cache deny all

# Log format and rotation
logformat squid %ts.%03tu %6tr %>a %Ss/%03>Hs %<st %rm %ru %ssl::>sni %Sh/%<a %mt
logfile_rotate 10
debug_options rotate=10

# Handle HTTP requests
http_port 3128
http_port 3129 intercept

# Handle HTTPS requests
https_port 3130 cert=/etc/squid/ssl/squid.pem ssl-bump intercept
acl SSL_port port 443
http_access allow SSL_port
acl step1 at_step SslBump1
acl step2 at_step SslBump2
acl step3 at_step SslBump3
ssl_bump peek step1 all

# Deny requests to proxy instance metadata
acl instance_metadata dst 169.254.169.254
http_access deny instance_metadata

# Filter HTTP requests based on the whitelist
acl allowed_http_sites dstdomain "/etc/squid/whitelist.txt"
http_access allow allowed_http_sites

# Filter HTTPS requests based on the whitelist
acl allowed_https_sites ssl::server_name "/etc/squid/whitelist.txt"
ssl_bump peek step2 allowed_https_sites
ssl_bump splice step3 allowed_https_sites
ssl_bump terminate step2 all

http_access deny all
EOF

/usr/sbin/squid -k parse && /usr/sbin/squid -k reconfigure

sudo reboot now
