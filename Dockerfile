# 使用 Ubuntu 作为基础镜像
FROM ubuntu:22.04

# 设置环境变量以避免在安装时出现交互提示
ENV DEBIAN_FRONTEND=noninteractive

# 更新包列表并安装所需的软件包
RUN apt-get update && apt-get install -y \
    apt-utils \
    isc-dhcp-server \
    tftpd-hpa \
    apache2 \
    wget \
    vim \
    lsof \
    iproute2 \
    iputils-ping \
    libarchive-tools && \
    mkdir -p /var/www/html/autoinstall/ /var/www/html/Ubuntu_22.04.4_Live-server/ /var/www/html/CentOS7.9/ /srv/tftp/Ubuntu_22.04.4_Live-server/ /srv/tftp/CentOS7.9/ /srv/tftp/pxelinux.cfg/ /srv/tftp/grub/ && \
    wget --progress=bar:force -O /var/www/html/autoinstall/ubuntu-22.04.4-live-server-amd64.iso https://mirrors.tuna.tsinghua.edu.cn/ubuntu-releases/22.04/ubuntu-22.04.4-live-server-amd64.iso && \
    wget --progress=bar:force -O /var/www/html/autoinstall/CentOS-7-x86_64-DVD-2009.iso https://mirrors.aliyun.com/centos/7/isos/x86_64/CentOS-7-x86_64-DVD-2009.iso && \
    bsdtar -xf /var/www/html/autoinstall/ubuntu-22.04.4-live-server-amd64.iso -C /var/www/html/Ubuntu_22.04.4_Live-server/ && \
    bsdtar -xf /var/www/html/autoinstall/CentOS-7-x86_64-DVD-2009.iso -C /var/www/html/CentOS7.9/ && \
    cp /var/www/html/Ubuntu_22.04.4_Live-server/casper/vmlinuz /srv/tftp/Ubuntu_22.04.4_Live-server/ && \
    cp /var/www/html/Ubuntu_22.04.4_Live-server/casper/initrd /srv/tftp/Ubuntu_22.04.4_Live-server/ && \
    cp /var/www/html/CentOS7.9/images/pxeboot/vmlinuz /srv/tftp/CentOS7.9/ && \
    cp /var/www/html/CentOS7.9/images/pxeboot/initrd.img /srv/tftp/CentOS7.9/ && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /var/www/html/Ubuntu_22.04.4_Live-server/* /var/www/html/CentOS7.9/*

# 复制 PXE 引导文件、菜单文件等
COPY /etc/netplan/00-installer-config.yaml /etc/netplan/00-installer-config.yaml
COPY /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf
COPY /etc/default/tftpd-hpa /etc/default/tftpd-hpa
COPY /etc/default/isc-dhcp-server /etc/default/isc-dhcp-server
COPY /var/www/html/autoinstall/user-data /var/www/html/autoinstall/user-data
COPY /var/www/html/autoinstall/meta-data /var/www/html/autoinstall/meta-data
COPY /srv/tftp/bootx64.efi /srv/tftp/
COPY /srv/tftp/unicode.pf2 /srv/tftp/
COPY /srv/tftp/grubx64.efi /srv/tftp/
COPY /srv/tftp/grub/grub.cfg /srv/tftp/grub/
COPY /srv/tftp/ldlinux.c32 /srv/tftp/
COPY /srv/tftp/libutil.c32 /srv/tftp/
COPY /srv/tftp/lpxelinux.0 /srv/tftp/
COPY /srv/tftp/menu.c32 /srv/tftp/
COPY /srv/tftp/pxelinux.0 srv/tftp/
COPY /srv/tftp/vesamenu.c32 srv/tftp/
COPY /srv/tftp/pxelinux.cfg/default /srv/tftp/pxelinux.cfg/

# 暴露 DHCP、TFTP 和 HTTP 端口
EXPOSE 67/udp 69/udp 80

# 启动脚本
COPY start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

# 设置容器启动时执行的命令
CMD ["/usr/local/bin/start.sh"]
