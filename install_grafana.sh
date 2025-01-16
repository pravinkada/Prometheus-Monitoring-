#!/bin/bash

set -e

GRAFANA_VERSION="9.6.7"

echo "Installing Grafana..."

# Download Grafana
wget https://dl.grafana.com/oss/release/grafana-${GRAFANA_VERSION}.linux-amd64.tar.gz
tar -xvf grafana-${GRAFANA_VERSION}.linux-amd64.tar.gz
sudo mv grafana-${GRAFANA_VERSION} /usr/share/grafana

# Create symbolic links
sudo ln -s /usr/share/grafana/bin/grafana-server /usr/local/bin/grafana-server
sudo ln -s /usr/share/grafana/bin/grafana-cli /usr/local/bin/grafana-cli

# Create systemd service file
cat <<EOF | sudo tee /etc/systemd/system/grafana.service
[Unit]
Description=Grafana Server
Wants=network-online.target
After=network-online.target

[Service]
User=root
Type=simple
ExecStart=/usr/local/bin/grafana-server --config=/usr/share/grafana/conf/defaults.ini --homepath=/usr/share/grafana

[Install]
WantedBy=multi-user.target
EOF

# Start Grafana
sudo systemctl daemon-reload
sudo systemctl enable grafana
sudo systemctl start grafana

echo "Grafana installed and running at http://<instance-ip>:3000 (default login: admin/admin)"
