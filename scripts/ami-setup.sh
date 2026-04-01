#!/bin/bash
set -e

sudo dnf install -y docker wget
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ec2-user
sudo systemctl restart docker

cd /tmp
wget https://github.com/prometheus/node_exporter/releases/download/v1.10.2/node_exporter-1.10.2.linux-amd64.tar.gz
tar -xzf node_exporter-1.10.2.linux-amd64.tar.gz

sudo mv node_exporter-1.10.2.linux-amd64/node_exporter /usr/local/bin/

sudo useradd --no-create-home --shell /bin/false node_exporter || true

sudo tee /etc/systemd/system/node_exporter.service > /dev/null <<EOF
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=node_exporter
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable node_exporter

mkdir -p /home/ec2-user/.ssh
touch /home/ec2-user/.ssh/authorized_keys
cat /tmp/key.pub >> /home/ec2-user/.ssh/authorized_keys
chown -R ec2-user:ec2-user /home/ec2-user/.ssh
chmod 700 /home/ec2-user/.ssh
chmod 600 /home/ec2-user/.ssh/authorized_keys
