#!/bin/sh

NODENAME=beye
NODEIP=10.128.15.103
IMAGE=almalinux/8/cloud

NET_TEMPLATE=beye-network-tmpl.yaml
CONFIG=beye-config.yaml

lxc stop -f $NODENAME
lxc delete $NODENAME

lxc init images:$IMAGE $NODENAME
sed -e "s/@@IP@@/$NODEIP/" $NET_TEMPLATE | lxc config set $NODENAME cloud-init.network-config -
lxc config set $NODENAME cloud-init.user-data - < ${CONFIG}
lxc file push -p grafana_tmpl/dashboard.json ${NODENAME}/var/lib/grafana/dashboards/
lxc start $NODENAME
