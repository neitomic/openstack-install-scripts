#!/bin/bash

echo "${CONTROLLER_IP} controller" >> /etc/hosts

COUNT="1"

while [ -v "COMPUTE_${COUNT}" ];
do
	TMP="COMPUTE_${COUNT}"
	echo "${!TMP} compute${COUNT}" >> /etc/hosts
	COUNT=$[${COUNT}+1]
done
