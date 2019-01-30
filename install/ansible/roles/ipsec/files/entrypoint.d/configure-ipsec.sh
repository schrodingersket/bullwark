#!/usr/bin/env bash

IPSEC_IP=${IPSEC_IP:-%defaultroute}
IPSEC_CIDRS=${IPSEC_CIDRS:-""}
INSTALL_DIR=${INSTALL_DIR:-"/opt/bullwark"}

# Configure opportunistic encryption
#
sed -i "s:IPSEC_IP:${IPSEC_IP}:g" /etc/ipsec.d/oe-certificate.conf

# Add IPSec CIDR groups
#
for i in $(echo ${IPSEC_CIDRS} | sed "s/,/ /g")
do
    # call your procedure/other scripts here below
    echo "$i" >> /etc/ipsec.d/policies/private
done

ipsec import ${INSTALL_DIR}/certs/certs.p12
