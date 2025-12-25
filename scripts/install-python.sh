#!/bin/bash
set -e

echo "=== Installing Python Dependencies ==="
sudo yum install -y git python3 python3-pip

echo "=== Cloning Application Repository ==="
cd ~
rm -rf fruits-veg_market
git clone https://github.com/jidavy/fruits-veg_market.git

echo "=== Installing Python Application Requirements ==="
cd fruits-veg_market/python
pip3 install --user -r requirements.txt

echo "=== Starting Python Application on Port 8080 ==="
# Kill any existing process on port 8080
sudo fuser -k 8080/tcp || true

# Start application in background
nohup python3 app.py > /tmp/python-app.log 2>&1 &

echo "=== Verifying Python Application ==="
sleep 5
curl -s http://localhost:8080 && echo "✅ Python app deployed successfully!" || echo "❌ Python deployment failed!"