# Prometheus-Monitoring-
# Prometheus Monitoring Setup with Node Exporter and Grafana on EC2

## Overview
This documentation outlines the steps to set up Prometheus, Node Exporter, and Grafana on an EC2 instance running Ubuntu, and configure monitoring for a node instance.

---

## Prerequisites
- **AWS EC2 Instances**:
  - One EC2 instance for Prometheus, Node Exporter, and Grafana.
  - One or more target node instances to monitor.
- **Ubuntu AMI**: Ensure the EC2 instances use an Ubuntu-based AMI.
- **Security Group**:
  - Allow inbound traffic for the following ports:
    - `9090` for Prometheus
    - `9100` for Node Exporter
    - `3000` for Grafana

---

## Steps

### 1. Launch EC2 Instances
1. Create an EC2 instance for Prometheus, Node Exporter, and Grafana.
2. Create one or more EC2 instances as target nodes to monitor.
3. Attach the necessary IAM roles and security groups to allow required traffic.

### 2. Install Prometheus on the Monitoring Instance
#### a. Update and Install Dependencies
```bash
sudo apt update && sudo apt upgrade -y
sudo apt install wget tar -y
```

#### b. Download and Extract Prometheus
```bash
cd /tmp
wget https://github.com/prometheus/prometheus/releases/download/v2.46.0/prometheus-2.46.0.linux-amd64.tar.gz
tar -xvf prometheus-2.46.0.linux-amd64.tar.gz
sudo mv prometheus-2.46.0.linux-amd64 /usr/local/prometheus
```

#### c. Configure Prometheus
1. Edit the Prometheus configuration file:
   ```bash
   sudo vim /usr/local/prometheus/prometheus.yml
   ```
2. Add the Node Exporter target under `scrape_configs`:
   ```yaml
   scrape_configs:
     - job_name: 'node-exporter'
       static_configs:
         - targets: ['<node-instance-ip>:9100']
   ```

#### d. Create a Systemd Service for Prometheus
```bash
sudo vim /etc/systemd/system/prometheus.service
```
Add the following content:
```ini
[Unit]
Description=Prometheus Service
After=network.target

[Service]
User=ubuntu
ExecStart=/usr/local/prometheus/prometheus --config.file=/usr/local/prometheus/prometheus.yml
Restart=always

[Install]
WantedBy=multi-user.target
```

#### e. Start and Enable Prometheus
```bash
sudo systemctl daemon-reload
sudo systemctl start prometheus
sudo systemctl enable prometheus
```

#### f. Verify Prometheus
Access Prometheus at `http://<monitoring-instance-ip>:9090`.

---

### 3. Install Node Exporter on Target Nodes
#### a. Download and Extract Node Exporter
```bash
cd /tmp
wget https://github.com/prometheus/node_exporter/releases/download/v1.6.0/node_exporter-1.6.0.linux-amd64.tar.gz
tar -xvf node_exporter-1.6.0.linux-amd64.tar.gz
sudo mv node_exporter-1.6.0.linux-amd64/node_exporter /usr/local/bin/
```

#### b. Create a Systemd Service for Node Exporter
```bash
sudo vim /etc/systemd/system/node-exporter.service
```
Add the following content:
```ini
[Unit]
Description=Node Exporter Service
After=network.target

[Service]
User=ubuntu
ExecStart=/usr/local/bin/node_exporter
Restart=always

[Install]
WantedBy=multi-user.target
```

#### c. Start and Enable Node Exporter
```bash
sudo systemctl daemon-reload
sudo systemctl start node-exporter
sudo systemctl enable node-exporter
```

#### d. Verify Node Exporter
Access Node Exporter metrics at `http://<node-instance-ip>:9100/metrics`.

---

### 4. Install Grafana
#### a. Add Grafana Repository
```bash
sudo apt-get install -y software-properties-common
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
sudo add-apt-repository "deb https://packages.grafana.com/oss/deb stable main"
```

#### b. Install and Start Grafana
```bash
sudo apt update
sudo apt install grafana -y
sudo systemctl start grafana-server
sudo systemctl enable grafana-server
```

#### c. Access Grafana
1. Open Grafana at `http://<monitoring-instance-ip>:3000`.
2. Log in with default credentials:
   - Username: `admin`
   - Password: `admin`
3. Update the password after the first login.

---

### 5. Configure Prometheus as a Data Source in Grafana
1. Navigate to **Configuration > Data Sources** in Grafana.
2. Click **Add data source** and select **Prometheus**.
3. Set the URL to `http://localhost:9090` and click **Save & Test**.

---

### 6. Create Dashboards in Grafana
1. Import pre-built Node Exporter dashboards or create custom dashboards.
2. Use Prometheus queries (PromQL) to visualize metrics like CPU usage, memory, and disk I/O.

---




