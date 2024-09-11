#!/bin/bash

# 删除旧的 PID 文件（如有）
rm -f /var/run/dhcpd.pid

# 启动 DHCP 服务
if ! pgrep dhcpd > /dev/null; then
    echo "Starting DHCP service..."
    service isc-dhcp-server start || { echo "Failed to start DHCP service"; exit 1; }
    sleep 2  # 等待服务启动
else
    echo "DHCP service is already running."
fi

# 启动 TFTP 服务
if ! pgrep in.tftpd > /dev/null; then
    echo "Starting TFTP service..."
    service tftpd-hpa start || { echo "Failed to start TFTP service"; exit 1; }
    sleep 2  # 等待服务启动
else
    echo "TFTP service is already running."
fi

# 启动 Apache 服务
if ! pgrep apache2 > /dev/null; then
    echo "Starting Apache web server..."
    service apache2 start || { echo "Failed to start Apache service"; exit 1; }
    sleep 2  # 等待服务启动
else
    echo "Apache service is already running."
fi

# 配置 Apache ServerName
if ! grep -q "ServerName" /etc/apache2/apache2.conf; then
    echo "ServerName localhost" >> /etc/apache2/apache2.conf
    service apache2 restart
fi

# 保持容器运行
echo "All services started. Keeping the container running..."
tail -f /dev/null
