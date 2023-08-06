# PS4-Lag-switch
A set of files to automate creating a wireless access point and control the flow of packets in it.

# DISCLAIMER
This is for educational use only and network diagnostics. Do not use this script on networks that you do not own or not have permission to use. Use responsibly. I am not responsible for any trouble you get into. This is a script to use for fun to mess with your friends.

# HOW IT WORKS
On gaming consoles, some games do not offer dedicated servers to play multiplayer therefore when you want to play with other people online, one of your consoles must be used as the host/server to run the multiplayer session. For example when you create a private game with your friends, you are now the host and server in this example. You can then connect your ps4 to the access point setup in the script, then since you have full control over the access point start dropping packets with iptables command below. The access point will analyze each ip address and if one of them is your friends, it will be blocked, if you drop ~25% of them you can make them considerably lag, anymore will normally kick them out.

# HOW TO USE
This setup requires two network interfaces, one for the access point and one to connect to the internet.

clone this repo first.

`sudo apt install hostapd dnsmasq iptables`

`chmod +x enable_ap.sh`

`sudo ./enable_sh -a wlan0 -n wlan1 -e access_point_name -p access_point_password`

Then run the following command to drop packets based on an ip address(Your friend)

`# iptables -A FORWARD  -s xxx.xxx.xxx.xxx -m statistic --mode random --probability 0.95 -j DROP`
