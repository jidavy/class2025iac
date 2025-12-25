#!/bin/bash
set -e

echo "=== Installing Web Server Dependencies ==="
sudo yum install -y git nginx

echo "=== Starting and Enabling NGINX ==="
sudo systemctl start nginx
sudo systemctl enable nginx

echo "=== Cloning Application Repository ==="
cd ~
rm -rf fruits-veg_market
git clone https://github.com/jidavy/fruits-veg_market.git

echo "=== Deploying Web Application ==="
cd fruits-veg_market
sudo cp web/index.html /usr/share/nginx/html/

echo "=== Restarting NGINX ==="
sudo systemctl restart nginx

echo "=== Verifying Deployment ==="
sleep 3
curl -s localhost | grep -q "vegetables" && echo "✅ Web deployment successful!" || echo "❌ Web deployment failed!"