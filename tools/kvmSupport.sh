#!/bin/bash
echo $(egrep -c '(vmx|svm)' /proc/cpuinfo)