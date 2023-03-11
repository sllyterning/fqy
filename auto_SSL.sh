#!/bin/bash
# 指定域名
my_domain="enample.cnaidun.net"
# 指定目录路径
path="/apps/cerfile/fullchain.crt"
# 指定重启服务脚本路径
re_service_path="/path/to/restart.sh"

diff=$(( $(date +%s) - $(stat -c %Y ${path}) ))
# 判断差值是否大于2个月的时间戳，即5184000秒
if [ ${diff} -gt 5184000 ]; then
  # 删除旧的备份
  if [ -f ${path}/backup/backup.tar.gz ]; then
    rm -f ${path}/backup/backup.tar.gz
  fi
# 备份文件
  mkdir -p "${path}/backup"
  tar czvf "${path}/backup/backup.tar.gz" "${path}"/*
# 删除2个月前的文件
  find "${path}" -type f -atime +60 -delete
# 执行申请证书
  /root/.acme.sh/acme.sh --issue -d ${my_domain} --standalone --force
# 移动证书文件并改名
  mv /root/.acme.sh/${my_domain}_ecc/${my_domain}.key /apps/cerfile/private.pem
  mv /root/.acme.sh/${my_domain}_ecc/fullchain.cer /apps/cerfile/fullchain.crt
# 执行重启服务脚本
#  bash ${re_service_path}
systemctl restart gost
fi
