hostname=$1
mac=$2
ip=$3
c_red=`tput setaf 1`
c_green=`tput setaf 2`
c_normal=`tput sgr0`

if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
	echo "${c_red}Use command with 3 parameters: hostname mac ip${c_normal}"
	exit 1
fi

if [[ ! $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
	echo "${c_red}THIS IP IS WRONG, TRY AGAIN${c_normal}"
	exit 1
fi

if [[ ! $mac =~ ^[0-9A-Z]{1,2}\:[0-9A-Z]{1,2}\:[0-9A-Z]{1,2}\:[0-9A-Z]{1,2}\:[0-9A-Z]{1,2}\:[0-9A-Z]{1,2}$ ]]; then
	echo "${c_red}THIS MAC ADRESS IS WRONG, TRY AGAIN\nUse '0-9,A-Z' and ':' like delimiter${c_normal}"
	exit 1
fi



echo "host $hostname {
	hardware ethernet $mac;
	fixed-address $ip;
}" >> /etc/dhcp/dhcpd.conf
systemctl restart dhcpd
if [[ $? -eq 0 ]]; then
	echo "${c_green}DONE${c_normal}"
else 
	echo "${c_red}FAIL${c_normal}"
fi
