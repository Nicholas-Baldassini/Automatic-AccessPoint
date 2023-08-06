#!/bin/bash

:'
Plug in internet adpater first so its wlan0
Plug in AP adapter second so its wlan1
'

AP_STATIC=192.168.1.1/24
AP_SUBNET=192.168.1.0/24

AP_INTERFACE=wlan1
NET_INTERFACE=wlan0

AP_NAME=FREEWIFI
AP_PASSWORD=hello123

HOSTAPD_PATH=/etc/hostapd/hostapd.conf

while getopts ":a:n:e:p:" opt; do
  case $opt in
     a)
       AP_INTERFACE==$OPTARG
       ;;
     n)
       NET_INTERFACE=$OPTARG
       ;;
     e)
        AP_NAME=$OPTARG
        ;;
     p)
        AP_PASSWORD=$OPTARG
	;;
     *)
       echo "Invalid flag"
       exit
       ;;
  esac
done

echo "Starting with the following parameters"
echo "Internet connection interface: $NET_INTERFACE"
echo "Access point interface: $AP_INTERFACE"
echo "Access point name: $AP_NAME"
echo "Access point password: $AP_PASSWORD"
echo "Access point subnet: $AP_SUBNET"


if ! ip a | grep -q -e "${AP_INTERFACE}";
then
	echo "AP interface not found"
	exit 1
fi

if ! ip a | grep -q -e "${NET_INTERFACE}";
then
	echo "NET interface: $NET_INTERFACE not found"
	exit 1
fi

# Blacklist access point interface from networkmanager so it does not mess with it
if ! cat /etc/NetworkManager/NetworkManager.conf | grep -q -e "interface-name:$AP_INTERFACE";
then
	echo "unmanaged-devices=interface-name:$AP_INTERFACE" >> /etc/NetworkManager/NetworkManager.conf
fi
service NetworkManager restart

ip addr add $AP_STATIC dev $AP_INTERFACE

# Configuring hostapd file with custom parameters
cat /home/kali/Documents/AP_stuff/startAP/hostapdConfTemplate > $HOSTAPD_PATH
awk "{sub(/REPLACEINTERFACE/,\"${AP_INTERFACE}\")}1" $HOSTAPD_PATH > tmp.txt && mv tmp.txt $HOSTAPD_PATH
awk "{sub(/REPLACENAME/,\"${AP_NAME}\")}1" $HOSTAPD_PATH > tmp.txt && mv tmp.txt $HOSTAPD_PATH
awk "{sub(/REPLACEPASSWORD/,\"${AP_PASSWORD}\")}1" $HOSTAPD_PATH > tmp.txt && mv tmp.txt $HOSTAPD_PATH

# Check for ip forwarding is enabled
if ! sysctl net.ipv4.ip_forward | grep -q -e "1";
then
	echo "ip_forward = 0"
	exit 1
fi

# Forward access point packets to the internet
iptables -P FORWARD ACCEPT
iptables -t nat -A POSTROUTING -s $AP_SUBNET -o $NET_INTERFACE -j MASQUERADE

# Make sure dnsmasq is not running, ps -aux | grep -F "dnsmasq"
# Start dnsmasq and hostapd
dnsmasq -C /home/kali/Documents/AP_stuff/startAP/dnsmasq.conf
hostapd -d /etc/hostapd/hostapd.conf

# Command to run
# iptables -A FORWARD  -s xxx.xxx.xxx.xxx -m statistic --mode random --probability 0.95 -j DROP
