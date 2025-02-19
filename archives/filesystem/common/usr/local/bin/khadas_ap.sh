#!/bin/bash

SOFTAP_VERSION="1.0"
DBG=true

SOFTAP_INTERFACE_STATIC_IP="192.168.43.1"
DHCP_RANGE="dhcp-range=192.168.43.2,192.168.43.254"
DNSMASQ_CONF_DIR="/etc/dnsmasq.conf"
HOSTAPD_CONF_DIR="/etc/hostapd/hostapd.conf"
SOFTAP_INTERFACE="wlan1"
STA_INTERFACE="wlan0"
ETH_INTERFACE="eth0"

debug_info() {
    if $DBG; then
        echo "DEBUG $BASH_LINENO: $*"
    fi
}

debug_err() {
    echo "DEBUG $BASH_LINENO: ERROR: $*" >&2
}

console_run() {
    debug_info "cmdline = $*"
    if ! eval "$@"; then
        debug_err "Running cmdline failed: $*"
        return 1
    fi
}

get_pid() {
    local name=$1
    local pid=$(pidof -s "$name" 2>/dev/null)
    if [ -n "$pid" ]; then
        debug_info "--- $name pid = $pid ---"
        echo "$pid"
    else
        echo 0
    fi
}

stop_services() {
    console_run "killall dnsmasq"
    console_run "killall hostapd"
    console_run "killall wpa_supplicant"
}

create_hostapd_conf() {
    local ssid=$1
    local password=$2
    debug_info "Creating hostapd configuration..."
    
    cat > "$HOSTAPD_CONF_DIR" <<EOF
interface=$SOFTAP_INTERFACE
ctrl_interface=/var/run/hostapd
driver=nl80211
ssid=$ssid
channel=6
hw_mode=g
ieee80211n=1
ignore_broadcast_ssid=0
auth_algs=1
wpa=2
wpa_passphrase=$password
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP
EOF
}

create_dnsmasq_conf() {
    debug_info "Creating dnsmasq configuration..."
    
    cat > "$DNSMASQ_CONF_DIR" <<EOF
user=root
listen-address=$SOFTAP_INTERFACE_STATIC_IP
$DHCP_RANGE
server=/google/8.8.8.8
port=5353
EOF
}

start_sta_ap() {
    local ssid=$1
    local password=$2
    debug_info "Starting STA+AP Mode..."
    
    stop_services
    console_run "sleep 2"
    
    console_run "ifconfig $SOFTAP_INTERFACE $SOFTAP_INTERFACE_STATIC_IP netmask 255.255.255.0 up"
    
    create_dnsmasq_conf
    create_hostapd_conf "$ssid" "$password"
    
    console_run "dnsmasq -C $DNSMASQ_CONF_DIR --interface=$SOFTAP_INTERFACE"
    console_run "hostapd $HOSTAPD_CONF_DIR -B"
    
    # Setup NAT
    console_run "echo 1 > /proc/sys/net/ipv4/ip_forward"
    console_run "iptables -t nat -A POSTROUTING -o $STA_INTERFACE -j MASQUERADE"
    console_run "iptables -A FORWARD -i $SOFTAP_INTERFACE -o $STA_INTERFACE -j ACCEPT"
}

start_eth_ap() {
    local ssid=$1
    local password=$2
    debug_info "Starting ETH+AP Mode..."

    stop_services
    console_run "sleep 2"

    console_run "ifconfig $SOFTAP_INTERFACE $SOFTAP_INTERFACE_STATIC_IP netmask 255.255.255.0 up"

    create_dnsmasq_conf
    create_hostapd_conf "$ssid" "$password"

    console_run "dnsmasq -C $DNSMASQ_CONF_DIR --interface=$SOFTAP_INTERFACE"
    console_run "hostapd $HOSTAPD_CONF_DIR -B"

    console_run "echo 1 > /proc/sys/net/ipv4/ip_forward"
    console_run "iptables -t nat -A POSTROUTING -o $ETH_INTERFACE -j MASQUERADE"
    console_run "iptables -A FORWARD -i $SOFTAP_INTERFACE -o $ETH_INTERFACE -j ACCEPT"
}

show_menu() {
    clear
    echo "========================================"
    echo " WiFi Configuration Tool v$SOFTAP_VERSION"
    echo "========================================"
    echo "1. STA+AP Mode"
    echo "2. ETH+AP Mode"
    echo "3. Stop All Services"
    echo "4. Exit"
    echo "========================================"
    read -p "Please select an option [1-4]: " choice
}

get_wifi_credentials() {
    read -p "Enter AP SSID: " ap_ssid
    read -p "Enter AP Password: " ap_password
}

main() {
    while true; do
        show_menu
        case $choice in
            1)
                get_wifi_credentials
                start_sta_ap "$ap_ssid" "$ap_password"
                ;;
            2)
                get_wifi_credentials
                start_eth_ap "$ap_ssid" "$ap_password"
                ;;
            3)
                stop_services
                echo "All services stopped"
                ;;
            4)
                echo "Exiting..."
                exit 0
                ;;
            *)
                echo "Invalid option, please try again"
                ;;
        esac
        read -p "Press [Enter] to continue..."
    done
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit 1
fi

main