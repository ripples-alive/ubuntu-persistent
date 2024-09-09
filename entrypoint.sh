#!/bin/sh

if [ ! -f /data/.inited ]; then
  echo "init from template"
  /template/bin/busybox ln -sf /template/usr/lib64 /usr/
  /template/bin/busybox ln -sf /template/usr/lib /usr/
  /template/bin/busybox ln -sf /template/usr/bin /usr/
  rsync -al --delete /template/ /data

  echo "root:${ROOT_PASSWORD}" | chpasswd
fi

tailscaled -tun userspace-networking &

mkdir -p /run/sshd
sshd -D -e &

cron -f -P &

exec "$@"
