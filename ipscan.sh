#!/bin/bash


ip_to_decimal() {
    local ip="$1"
    local a b c d
    IFS=. read -r a b c d <<< "$ip"
    echo "$((a * 256**3 + b * 256**2 + c * 256 + d))"
}


decimal_to_ip() {
    local dec="$1"
    local a=$((dec / 256**3 % 256))
    local b=$((dec / 256**2 % 256))
    local c=$((dec / 256 % 256))
    local d=$((dec % 256))
    echo "$a.$b.$c.$d"
}


measure_latency() {
    local ip=$1
    local latency=$(ping -c 1 -W 1 "$ip" | grep 'time=' | awk -F'time=' '{ print $2 }' | cut -d' ' -f1)
    if [ -z "$latency" ]; then
        latency="N/A"
    fi
    printf "%s %s\n" "$ip" "$latency"
}


generate_ips_in_cidr() {
    local cidr="$1"
    local base_ip=$(echo "$cidr" | cut -d'/' -f1)
    local prefix=$(echo "$cidr" | cut -d'/' -f2)
    local ip_dec=$(ip_to_decimal "$base_ip")
    local range_size=$((2 ** (32 - prefix)))
    local ips=()

    for ((i=0; i<range_size; i++)); do
        ips+=("$(decimal_to_ip $((ip_dec + i)))")
    done

    echo "${ips[@]}"
}

check_and_install() {
    if ! command -v $1 &> /dev/null; then
        echo "$1 not found, installing..."
        pkg install -y $2
    else
        echo "$1 is already installed."
    fi
}


check_and_install ping inetutils
check_and_install awk coreutils
check_and_install grep grep
check_and_install cut coreutils
check_and_install curl curl
check_and_install bc bc


IP_RANGES=(
    "104.24.25.0/24" "104.24.26.0/24" "104.24.27.0/24" "104.24.28.0/24"
    "104.24.29.0/24" "104.24.30.0/24" "104.24.31.0/24" "104.24.32.0/24"
    "104.24.33.0/24" "104.24.34.0/24" "104.24.35.0/24" "104.24.36.0/24"
    "104.24.37.0/24" "104.24.38.0/24" "104.24.39.0/24" "104.24.40.0/24"
    "104.24.41.0/24" "104.24.42.0/24" "104.24.43.0/24" "104.24.44.0/24"
    "104.24.45.0/24" "104.24.46.0/24" "104.24.47.0/24" "104.24.48.0/24"
    "104.24.49.0/24" "104.24.50.0/24" "104.24.51.0/24" "104.24.52.0/24"
    "104.24.53.0/24" "104.24.54.0/24" "104.24.55.0/24" "104.24.56.0/24"
    "104.24.57.0/24" "104.24.58.0/24" "104.24.59.0/24" "104.24.60.0/24"
    "104.24.61.0/24" "104.24.62.0/24" "104.24.63.0/24" "104.24.64.0/24"
    "104.24.65.0/24" "104.24.66.0/24" "104.24.67.0/24" "104.24.68.0/24"
    "104.24.69.0/24" "104.24.70.0/24" "104.24.71.0/24" "104.24.72.0/24"
    "104.24.73.0/24" "104.24.74.0/24" "104.24.75.0/24" "104.24.76.0/24"
    "104.24.77.0/24" "104.24.78.0/24" "104.24.79.0/24" "104.24.80.0/24"
    "162.158.145.0/24" "162.158.146.0/24" "162.158.147.0/24" "162.158.148.0/24"
    "162.158.149.0/24" "162.158.150.0/24" "162.158.151.0/24" "162.158.152.0/24"
    "162.158.153.0/24" "162.158.154.0/24" "162.158.155.0/24" "162.158.156.0/24"
    "162.158.157.0/24" "162.158.158.0/24" "162.158.159.0/24" "162.158.160.0/24"
    "162.158.161.0/24" "162.158.162.0/24" "162.158.163.0/24" "162.158.164.0/24"
    "162.158.165.0/24" "162.158.166.0/24" "162.158.167.0/24" "162.158.168.0/24"
    "162.158.169.0/24" "162.158.170.0/24" "162.158.171.0/24" "162.158.172.0/24"
    "162.158.173.0/24" "162.158.174.0/24" "162.158.175.0/24" "162.158.176.0/24"
    "162.158.178.0/24" "162.158.179.0/24" "162.158.180.0/24" "162.158.184.0/24"
    "162.158.185.0/24" "172.64.21.0/24" "172.64.22.0/24" "172.64.23.0/24"
    "172.64.24.0/24" "172.64.25.0/24" "172.64.26.0/24" "172.64.27.0/24"
    "172.64.28.0/24" "172.64.29.0/24" "172.64.30.0/24" "172.64.31.0/24"
    "172.64.32.0/24" "172.64.33.0/24" "172.64.34.0/24" "172.64.35.0/24"
    "172.64.36.0/24" "172.64.38.0/24" "172.64.40.0/24" "172.64.41.0/24"
    "185.215.234.0/24" "185.215.235.0/24" "185.221.160.0/24" "185.234.22.0/24"
    "185.238.228.0/24" "185.244.106.0/24" "188.42.88.0/24" "188.42.89.0/24"
    "188.114.96.0/24" "188.114.97.0/24" "188.114.98.0/24" "188.114.99.0/24"
    "188.114.100.0/24" "188.114.102.0/24"    "188.114.103.0/24" "188.114.106.0/24" "188.114.108.0/24" "188.114.111.0/24"
    "188.244.122.0/24" "190.2.130.0/24" "190.93.244.0/24" "190.93.245.0/24"    "190.93.246.0/24"
)


fetch_additional_ips() {
    local needed_ips=$1
    local ip_ranges=("${@:2}")

    local ips=()
    for range in "${ip_ranges[@]}"; do
        ips+=($(generate_ips_in_cidr "$range"))
        if [[ ${#ips[@]} -ge $needed_ips ]]; then
            break
        fi
    done

    echo "${ips[@]}"
}


show_progress() {
    local current=$1
    local total=$2
    local percent=$(( 100 * current / total ))
    local progress=$(( current * 50 / total ))
    local green=$(( progress ))
    local red=$(( 50 - progress ))

    
    printf "\r["
    printf "\e[42m%${green}s\e[0m" | tr ' ' '='
    printf "\e[41m%${red}s\e[0m" | tr ' ' '='
    printf "] %d%%" "$percent"
}


SELECTED_IP_RANGES=($(shuf -e "${IP_RANGES[@]}" -n 10))
echo "Selected IP Ranges: ${SELECTED_IP_RANGES[@]}"


SELECTED_IPS=()
for range in "${SELECTED_IP_RANGES[@]}"; do
    ips=($(generate_ips_in_cidr "$range"))
    SELECTED_IPS+=("${ips[@]}")
done


SHUFFLED_IPS=($(shuf -e "${SELECTED_IPS[@]}" -n 100))


display_table_ipv4() {
    printf "+-----------------------+------------+\n"
    printf "| IP                    | Latency(ms) |\n"
    printf "+-----------------------+------------+\n"
    echo "$1" | head -n 10 | while read -r ip latency; do
        if [ "$latency" == "N/A" ]; then
            
            continue
        fi
        printf "| %-21s | %-10s |\n" "$ip" "$latency"
    done
    printf "+-----------------------+------------+\n"
}


valid_ips=()
total_ips=${#SHUFFLED_IPS[@]}
processed_ips=0

while [[ ${#valid_ips[@]} -lt 10 ]]; do
    
    ping_results=$(printf "%s\n" "${SHUFFLED_IPS[@]}" | xargs -I {} -P 10 bash -c '
    measure_latency() {
        local ip="$1"
        local latency=$(ping -c 1 -W 1 "$ip" | grep "time=" | awk -F"time=" "{ print \$2 }" | cut -d" " -f1)
        if [ -z "$latency" ]; then
            latency="N/A"
        fi
        printf "%s %s\n" "$ip" "$latency"
    }
    measure_latency "$@"
    ' _ {})

    
    valid_ips=($(echo "$ping_results" | grep -v "N/A" | awk '{print $1}'))

    processed_ips=$((${#valid_ips[@]} + ${#SHUFFLED_IPS[@]} - $total_ips))
    show_progress $processed_ips $total_ips

    if [[ ${#valid_ips[@]} -lt 10 ]]; then
        echo -e "\nNot enough valid IPs found. Selecting more IP ranges..."
        additional_ips=($(fetch_additional_ips $((100 - ${#valid_ips[@]})) "${IP_RANGES[@]}"))
        SHUFFLED_IPS=($(shuf -e "${additional_ips[@]}" -n 100))
        total_ips=${#SHUFFLED_IPS[@]}
        processed_ips=0
    fi
done


clear
echo -e "\e[1;35m*****************************************"
echo -e "\e[1;35m*\e[0m \e[1;31mY\e[1;32mO\e[1;33mU\e[1;34mT\e[1;35mU\e[1;36mB\e[1;37mE\e[0m : \e[4;34mKOLANDONE\e[0m         \e[1;35m"
echo -e "\e[1;35m*\e[0m \e[1;31mT\e[1;32mE\e[1;33mL\e[1;34mE\e[1;35mG\e[1;36mR\e[1;37mA\e[1;31mM\e[0m : \e[4;34mKOLANDJS\e[0m         \e[1;35m"
echo -e "\e[1;35m*\e[0m \e[1;31mG\e[1;32mI\e[1;33mT\e[1;34mH\e[1;35mU\e[1;36mB\e[0m : \e[4;34mhttps://github.com/Kolandone\e[0m \e[1;35m"
echo -e "\e[1;35m*****************************************\e[0m"
echo ""

show_progress $total_ips $total_ips
echo -e "\n"


echo -e "\e[1;32mDisplaying top 10 IPs with valid latency...\e[0m"
display_table_ipv4 "$ping_results"


comma_separated_ips=$(IFS=,; echo "${valid_ips[*]}")
echo -e "\e[1;33mDisplaying all valid IPs:\e[0m"
echo "$comma_separated_ips"

