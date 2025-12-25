#!/bin/bash
set -e

echo "=== Installing Java Dependencies ==="
sudo yum install -y git java-17-amazon-corretto maven

echo "=== Cloning Application Repository ==="
cd ~
rm -rf fruits-veg_market
git clone https://github.com/jidavy/fruits-veg_market.git

echo "=== Building Java Application ==="
cd fruits-veg_market/java
mvn clean package

echo "=== Starting Java Application on Port 9090 ==="
# Kill any existing process on port 9090
sudo fuser -k 9090/tcp || true

# Start application in background
nohup java -jar target/*.jar --server.port=9090 > /tmp/java-app.log 2>&1 &

echo "=== Verifying Java Application ==="
sleep 10
curl -s http://localhost:9090 && echo "✅ Java app deployed successfully!" || echo "❌ Java deployment failed!"