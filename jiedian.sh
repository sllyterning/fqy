#!/bin/bash
read -p "change name: " newname
hostnamectl set-hostname ${newname}
mkdir /opt/node_exporter
wget -P /opt/node_exporter https://github.com/prometheus/node_exporter/releases/download/v1.5.0/node_exporter-1.5.0.linux-amd64.tar.gz
tar -xzvf /opt/node_exporter/node_exporter-1.5.0.linux-amd64.tar.gz -C /opt/node_exporter

sys_ubuntu() {
echo '[Unit]
Description=node_exporter service

[Service]
User=root
ExecStart=/opt/node_exporter/node_exporter-1.5.0.linux-amd64/node_exporter

TimeoutStopSec=10
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target' > /lib/systemd/system/node_exporter.service

ufw allow from 154.91.4.120
}

sys_centos() {
echo '[Unit]
Description=node_exporter service

[Service]
User=root
ExecStart=/opt/node_exporter/node_exporter-1.5.0.linux-amd64/node_exporter

TimeoutStopSec=10
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target' > /usr/lib/systemd/system/node_exporter.service

firewall-cmd --permanent --add-rich-rule 'rule family="ipv4" source address="154.91.4.120" port protocol="tcp" port="9100" accept'
firewall-cmd --reload
}

if grep -qi ubuntu /etc/issue; then
    sys_ubuntu
else
    sys_centos
fi

systemctl daemon-reload
systemctl enable --now node_exporter

wget -O -  https://get.acme.sh | sh -s email=my@example.com
apt install -y socat
