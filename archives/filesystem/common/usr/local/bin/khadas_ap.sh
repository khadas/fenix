#!/bin/bash

SOFTAP_VERSION="2.0"
DBG=true

SOFTAP_INTERFACE_STATIC_IP="192.168.43.1"
DHCP_RANGE="dhcp-range=192.168.43.2,192.168.43.254"
DNSMASQ_CONF_DIR="/etc/dnsmasq.conf"
HOSTAPD_CONF_DIR="/etc/hostapd/hostapd.conf"
SYSTEMD_RESOLVED_CONF_DIR="/etc/systemd/resolved.conf.d/"
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

create_systemd_resolved_conf() {
    [ -d $SYSTEMD_RESOLVED_CONF_DIR ] || mkdir -p $SYSTEMD_RESOLVED_CONF_DIR

    cat > "$SYSTEMD_RESOLVED_CONF_DIR"/khadas_ap.conf <<EOF
[Resolve]
DNS=127.0.0.1
DNSStubListener=no
EOF
}

reload_systemd_resolved() {
    console_run "systemctl reload-or-restart systemd-resolved"
}

stop_services() {
    debug_info "Stopping all services..."
    console_run "killall dnsmasq"
    console_run "killall hostapd"
    console_run "killall wpa_supplicant"

    if [ -f "$SYSTEMD_RESOLVED_CONF_DIR"/khadas_ap.conf ]; then
        rm "$SYSTEMD_RESOLVED_CONF_DIR"/khadas_ap.conf
        reload_systemd_resolved
    fi

    # Clean up iptables rules
    console_run "iptables -t nat -F"
    console_run "iptables -F"
}

create_hostapd_conf() {
    local ssid=$1
    local password=$2
    local band=$3
    local channel
    local hw_mode

    if [ "$band" == "2.4" ]; then
        hw_mode="g"
        channel="6"
        debug_info "Creating hostapd configuration for 2.4GHz..."
    elif [ "$band" == "5" ]; then
        hw_mode="a"
        channel="36"
        debug_info "Creating hostapd configuration for 5GHz..."
    else
        debug_err "Invalid band specified: $band"
        return 1
    fi
    
    cat > "$HOSTAPD_CONF_DIR" <<EOF
interface=$SOFTAP_INTERFACE
ctrl_interface=/var/run/hostapd
driver=nl80211
ssid=$ssid
channel=$channel
hw_mode=$hw_mode
beacon_int=100
dtim_period=1
ap_isolate=0
ieee80211n=1
ieee80211ac=1
ignore_broadcast_ssid=0
auth_algs=1
wpa=2
wpa_passphrase=$password
ieee80211w=1
wpa_key_mgmt=WPA-PSK
rsn_pairwise=CCMP
wpa_group_rekey=3600
wpa_ptk_rekey=0
EOF
}

create_dnsmasq_conf() {
    debug_info "Creating dnsmasq configuration..."
    
    cat > "$DNSMASQ_CONF_DIR" <<EOF
user=root
listen-address=$SOFTAP_INTERFACE_STATIC_IP
$DHCP_RANGE
server=/google/8.8.8.8
port=53
EOF
}

start_ap_common() {
    local ssid=$1
    local password=$2
    local band=$3
    local upstream_interface=$4

    stop_services
    console_run "sleep 2"
    
    console_run "ifconfig $SOFTAP_INTERFACE $SOFTAP_INTERFACE_STATIC_IP netmask 255.255.255.0 up"
    
    create_dnsmasq_conf
    create_hostapd_conf "$ssid" "$password" "$band" || return 1
    create_systemd_resolved_conf

    reload_systemd_resolved
    
    console_run "dnsmasq -C $DNSMASQ_CONF_DIR --interface=$SOFTAP_INTERFACE"
    console_run "hostapd $HOSTAPD_CONF_DIR -B"
    
    debug_info "Setting up NAT for upstream interface $upstream_interface"
    console_run "echo 1 > /proc/sys/net/ipv4/ip_forward"
    console_run "iptables -t nat -A POSTROUTING -o $upstream_interface -j MASQUERADE"
    console_run "iptables -A FORWARD -i $SOFTAP_INTERFACE -o $upstream_interface -j ACCEPT"
}

start_sta_ap() {
    local ssid=$1
    local password=$2
    local band=$3
    debug_info "Starting STA+AP Mode ($band GHz)..."
    start_ap_common "$ssid" "$password" "$band" "$STA_INTERFACE"
}

start_eth_ap() {
    local ssid=$1
    local password=$2
    local band=$3
    debug_info "Starting ETH+AP Mode ($band GHz)..."
    start_ap_common "$ssid" "$password" "$band" "$ETH_INTERFACE"
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

get_band_choice() {
    while true; do
        clear >&2
        echo "========================================" >&2
        echo "   Select WiFi Band" >&2
        echo "========================================" >&2
        echo "1. 2.4GHz" >&2
        echo "2. 5GHz" >&2
        echo "3. Back to Main Menu" >&2
        echo "========================================" >&2
        read -p "Please select an option [1-3]: " band_choice
        case $band_choice in
            1)
                echo "2.4"
                return 0
                ;;
            2)
                echo "5"
                return 0
                ;;
            3)
                echo "back"
                return 0
                ;;
            *)
                echo "Invalid option, please try again." >&2
                read -p "Press [Enter] to continue..."
                ;;
        esac
    done
}

get_wifi_credentials() {
    read -p "Enter AP SSID: " ap_ssid
    if [ -z "$ap_ssid" ]; then
        echo "SSID cannot be empty."
        return 1
    fi
    read -sp "Enter AP Password (must be 8+ chars): " ap_password
    echo ""
    if [ ${#ap_password} -lt 8 ]; then
        echo "Password must be at least 8 characters long."
        return 1
    fi
}

main() {
    while true; do
        show_menu
        case $choice in
            1) # STA+AP Mode
                get_wifi_credentials || continue
                band=$(get_band_choice)
                if [ "$band" == "2.4" ] || [ "$band" == "5" ]; then
                    start_sta_ap "$ap_ssid" "$ap_password" "$band"
                fi
                ;;
            2) # ETH+AP Mode
                get_wifi_credentials || continue
                band=$(get_band_choice)
                if [ "$band" == "2.4" ] || [ "$band" == "5" ]; then
                    start_eth_ap "$ap_ssid" "$ap_password" "$band"
                fi
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
