#!/bin/bash
now=$(date +"%d%m%Y.%H%M%S")
lvcreate -L500M -s -n $now /dev/centos/homes
