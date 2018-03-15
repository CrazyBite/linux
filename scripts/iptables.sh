#!/bin/bash
#Load useful kernel modules
modprobe ip_conntrack
modprobe ip_conntrack_ftp
modprobe ip_conntrack_irc
modprobe ip_nat_ftp
# Disabling ECN if enabled (explicit congestion notification
if [ -e /proc/sys/net/ipv4/tcp_ecn ]
then
echo 0 > /proc/sys/net/ipv4/tcp_ecn
fi

# Enabling forwarding
echo 1 > /proc/sys/net/ipv4/ip_forward

# AntiSpoofing protection
for x in lo enp0s3 enp0s8
do
echo 1 > /proc/sys/net/ipv4/conf/${x}/rp_filter
done

# Here is the place to define some variables

iptables="/sbin/iptables"
publicaddr="10.13.236.116"
privateaddr="192.168.0.1"
any="0.0.0.0/0"
localnet="192.168.0.0/24"

#First, flushing the existing rules
$iptables -F INPUT
$iptables -F OUTPUT
$iptables -F FORWARD
$iptables -F -t nat

#Now defining the standard policy
$iptables -P INPUT DROP
$iptables -P OUTPUT ACCEPT
$iptables -P FORWARD ACCEPT

#Defining the real stuff !

# Allow access to the firewall from the localnet
$iptables -A INPUT -s $localnet -d $privateaddr -j ACCEPT
$iptables -A INPUT -s $localnet -d $publicaddr -j ACCEPT

# Allow access from ourself to us !
$iptables -A INPUT -i lo -j ACCEPT

# Allow the firewall box to access the internet
$iptables -A INPUT -s $any -d $publicaddr -m state --state ESTABLISHED,RELATED -j ACCEPT

# Should we masquerade the localnet to internet ?
$iptables -t nat -A POSTROUTING -s $localnet -d $any -j MASQUERADE

#dns server input
$iptables -I INPUT 1 -p tcp -m tcp --dport 53 -m state --state NEW,ESTABLISHED -j ACCEPT
$iptables -I INPUT 2 -p udp -m udp --dport 53 -m state --state NEW,ESTABLISHED -j ACCEPT

#ssh
$iptables -I INPUT 1 -p tcp -m tcp --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT

#dns server response
$iptables -A OUTPUT -p tcp -m tcp --sport 53:65535 --dport 53 -m state --state NEW,ESTABLISHED -j ACCEPT
$iptables -A OUTPUT -p udp -m udp --sport 53:65535 --dport 53 -m state --state NEW,ESTABLISHED -j ACCEPT

#drop vk and ok
$iptables -I INPUT -p tcp --dport 443 -m string --string "Host: vk.com" --algo bm -j DROP
$iptables -I INPUT -p tcp --dport 443 -m string --string "Host: ok.ru" --algo bm -j DROP

#add route
ip route add 192.168.0.0/24 dev enp0s8 
