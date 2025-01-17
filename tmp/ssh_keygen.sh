#!/bin/sh
if [ ! -f "/etc/ssh/ssh_host_rsa_key" ]; then
  # generate fresh rsa key
  ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa
fi
if [ ! -f "/etc/ssh/ssh_host_dsa_key" ]; then
  # generate fresh dsa key
  ssh-keygen -f /etc/ssh/ssh_host_dsa_key -N '' -t dsa
fi
if [ ! -f "/etc/ssh/ssh_host_ecdsa_key" ]; then
  # generate fresh ecdsa key
  ssh-keygen -f /etc/ssh/ssh_host_ecdsa_key -N '' -t dsa
fi
if [ ! -f "/etc/ssh/ssh_host_ed25519_key" ]; then
  # generate fresh ecdsa key
  ssh-keygen -f /etc/ssh/ssh_host_ed25519_key -N '' -t dsa
fi
if [ ! -d "/var/run/sshd" ]; then
  #prepare run dir
  mkdir -p /var/run/sshd
fi
echo "SSH keys generated"