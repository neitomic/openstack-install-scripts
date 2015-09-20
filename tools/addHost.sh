#!/bin/bash

echo "${CONTROLLER_IP} controller" >> /etc/hosts

COUNT="1"

TMP="COMPUTE_${COUNT}"

while [ ${!TMP} ];
do
	echo "${!TMP} compute${COUNT}" >> /etc/hosts
	COUNT=$[${COUNT}+1]
	TMP="COMPUTE_${COUNT}"
done
