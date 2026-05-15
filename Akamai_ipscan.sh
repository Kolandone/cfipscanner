
#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

if ! command -v python3 &> /dev/null; then
    echo -e "\e[32mPython3 not found. Installing...\e[0m"
    pkg update -y && pkg install python -y
fi

outputFile="clean_ips.txt"

rawList=$(cat <<'EOF'
92.123.102.43
2.19.204.0/24
2.19.205.0/24
92.123.0.0/16
23.200.0.0/16
184.31.169.0/24
184.31.170.0/24
23.218.0.0/16
104.64.0.0/12
2.16.0.0/14
EOF
)

rm -f "$outputFile"
touch "$outputFile"
tmpIPs="$(mktemp)"
trap 'rm -f "$tmpIPs"' EXIT

echo -e "\e[33m[1/2] --- Generating Smart Samples from Ranges ---\e[0m"

while IFS= read -r line; do
    line=$(echo "$line" | xargs)
    [[ -z "$line" || "$line" == "#"* ]] && continue

    if [[ "$line" == *"/"* ]]; then
        ipBase="${line%%/*}"
        mask="${line##*/}"
        IFS='.' read -r o1 o2 o3 o4 <<<"$ipBase"

        if (( mask >= 24 )); then
            prefix="$o1.$o2.$o3"
            for i in {1..254}; do
                echo "$prefix.$i" >> "$tmpIPs"
            done
        else
            echo -e "\e[90mSampling 500 IPs from large range: $line\e[0m"
            for n in {1..500}; do
                r2=$o2; [[ $mask -le 16 ]] && r2=$((RANDOM % 255))
                r3=$((RANDOM % 255))
                r4=$(( (RANDOM % 253) + 1 ))
                echo "$o1.$r2.$r3.$r4" >> "$tmpIPs"
            done
        fi
    else
        echo "$line" >> "$tmpIPs"
    fi
done <<< "$rawList"

sort -u "$tmpIPs" -o "$tmpIPs"
total_count=$(wc -l < "$tmpIPs")

echo -e "\e[36m[2/2] --- Starting Parallel Scan ($total_count IPs) ---\e[0m"
echo -e "\e[35mMax Workers: 10 | Timeout: 600ms | Results: LIVE sorted\e[0m\n"

python3 -u - <<'PY' "$tmpIPs" "$outputFile"
import sys, time, socket
from concurrent.futures import ThreadPoolExecutor, as_completed

ip_file, out_file = sys.argv[1], sys.argv[2]
TIMEOUT = 0.6
PORT = 443
MAX_WORKERS = 10
results = []

def save_results():
    results.sort(key=lambda x: x[0])
    with open(out_file, "w") as f:
        for ms, ip in results:
            f.write(f"{ip}\n")

def test_ip(ip):
    start_time = time.perf_counter()
    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(TIMEOUT)
        result = sock.connect_ex((ip, PORT))
        if result == 0:
            elapsed = int((time.perf_counter() - start_time) * 1000)
            sock.close()
            return (True, ip, elapsed)
        sock.close()
    except:
        pass
    return (False, ip, None)

with open(ip_file, "r") as f:
    ips = [line.strip() for line in f if line.strip()]

try:
    with ThreadPoolExecutor(max_workers=MAX_WORKERS) as executor:
        future_to_ip = {executor.submit(test_ip, ip): ip for ip in ips}
        
        for future in as_completed(future_to_ip):
            ok, ip, ms = future.result()
            if ok:
                print(f" \033[32m[OK]\033[0m {ip} \033[90m({ms} ms)\033[0m")
                results.append((ms, ip))
                save_results()

except KeyboardInterrupt:
    print("\n\n\033[33mStop requested by user.\033[0m")
finally:
    print(f"\n--- Scan Finished. Found {len(results)} clean IPs. ---")
    print(f"Results saved in: {out_file}")
PY
