#!/bin/sh

TEMPLATE_DIR=/template
BUSYBOX=$TEMPLATE_DIR/usr/bin/busybox

function init_ssh() {
  user=$1
  home_dir=$2
  if [ -n "$SSH_PUBKEY" ]; then
    echo "Adding SSH public key to $home_dir"
    mkdir -p $home_dir/.ssh
    chmod 700 $home_dir/.ssh
    echo "$SSH_PUBKEY" > $home_dir/.ssh/authorized_keys
    chmod 600 $home_dir/.ssh/authorized_keys
    chown -R $user:$user $home_dir/.ssh
  fi
}

if [ ! "$($BUSYBOX ls -A /usr)" ]; then
  echo "Copying system files from template"
  $BUSYBOX ln -sf $TEMPLATE_DIR/usr/bin /usr/
  $BUSYBOX ln -sf $TEMPLATE_DIR/usr/lib /usr/
  $BUSYBOX ln -sf $TEMPLATE_DIR/usr/lib64 /usr/
  rsync -al --delete $TEMPLATE_DIR/etc/ /etc/
  rsync -al --delete $TEMPLATE_DIR/opt/ /opt/
  rsync -al --delete $TEMPLATE_DIR/usr/ /usr/
  rsync -al --delete $TEMPLATE_DIR/var/ /var/

  if [ ! "$(ls -A /root)" ]; then
    echo "Copying root directory from template"
    rsync -al $TEMPLATE_DIR/root/ /root/
    init_ssh root /root
  fi

  if [ ! "$(ls -A /home)" ]; then
    echo "Copying home directory from template"
    rsync -al $TEMPLATE_DIR/home/ /home/
  fi
fi

exec "$@"
