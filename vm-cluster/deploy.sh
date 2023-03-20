#!/bin/sh

NODEFILE=nodes

NET_TEMPLATE=beye-network-tmpl.yaml
CONFIG_VM=beye-config-vm-cluster.yaml
CONFIG_LB=beye-config-grafana.yaml

# Deploy VictoriaMetrics containers
for node in $(awk '{if($3 == "vm")print $1}' $NODEFILE); do
	lxc stop -f $node
	lxc delete $node

	lxc init images:almalinux/8/cloud $node
	IP=$(grep ^$node $NODEFILE | awk '{print $2}');sed -e "s/@@IP@@/$IP/" $NET_TEMPLATE | lxc config set $node cloud-init.network-config -
	lxc config set $node cloud-init.user-data - < ${CONFIG_VM}
	lxc start $node
done

# Deploy an container for loadbalancer && grafana
LBNODE=$(awk '{if($3 == "lb")print $1}' $NODEFILE)
lxc stop -f ${LBNODE}
lxc delete ${LBNODE}
lxc init images:almalinux/8/cloud ${LBNODE}
IP=$(grep ^$LBNODE $NODEFILE | awk '{print $2}');sed -e "s/@@IP@@/$IP/" $NET_TEMPLATE | lxc config set $LBNODE cloud-init.network-config -
lxc config set ${LBNODE} cloud-init.user-data - < ${CONFIG_LB}
lxc file push -p grafana_tmpl/dashboard.json ${LBNODE}/var/lib/grafana/dashboards/
lxc start ${LBNODE}
