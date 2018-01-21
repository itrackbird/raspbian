#!/usr/bin/env bash
ips=`cat host.ip`
passwd="123456@pzm"
for ip in $ips
do
	echo "=========$ip==========="
	./auto_ssh.sh root $passwd $ip
done
