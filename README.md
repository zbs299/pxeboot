# 创建一个基于 Ubuntu Server 的 PXE 服务器的 Dockerfile，并在其中安装 DHCP、TFTP 和 HTTP 服务，可以按照以下步骤进行。
# 这里，我们将使用 Ubuntu 作为基础镜像，安装必要的软件包并配置服务
# 拉取ubuntu22.04基础镜像
docker pull swr.cn-north-4.myhuaweicloud.com/ddn-k8s/docker.io/ubuntu:22.04\
docker tag  swr.cn-north-4.myhuaweicloud.com/ddn-k8s/docker.io/ubuntu:22.04  docker.io/ubuntu:22.04
# 将所有文件拉取到同一目录内进行操作
#1. vi etc/default/isc-dhcp-server            修改为服务器网卡真实名称\
#2. vi etc/netplan/00-installer-config.yaml   修改为服务器网卡真实地址\
#3. vi etc/dhcp/dhcpd.conf                    根据实际IP地址进行修改\
#4. vi srv/tftp/grub/grub.cfg                 根据实际IP地址进行修改\
#5. vi srv/tftp/pxelinux.cfg/default          根据实际IP地址进行修改

# 在目录中运行命令构建镜像
docker build -t pxe:v1 .
# 以下停止端口的命令具体情况具体分析，总之要停掉80/69/67这三个\
snap stop nextcloud                    #停止宿主机80端口\
systemctl stop apache2                 #停止宿主机80端口\
systemctl stop tftpd-hpa               #停止宿主机69端口\
systemctl stop isc-dhcp-server         #停止宿主机67端口
# 创建一个容器
docker run -d --name a1 --network host pxe:v1
# 进入命令行（检查运行）
docker exec -it a1 bash
