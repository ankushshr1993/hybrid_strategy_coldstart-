#!/bin/bash -vx

# Path to the file containing IP addresses
ip_file="ip_address"

# Path to the output file for ping metrics
ping_output_file="ping_metrics.csv"

# Path to the output file for CPU utilization metrics
cpu_output_file="cpu_metrics.csv"

#delete existing csv files.
rm -f ./*csv

# Loop through each IP address in the file and ping it
echo > $ping_output_file
echo > $cpu_output_file
while read -r ip; do
    # Parse the IP address, name and location from the line in the file
    ipa=$(echo $ip | awk -F',' '{print $1}')
    name=$(echo $ip | awk -F',' '{print $2}')
    location=$(echo $ip | awk -F',' '{print $3}')

    # Ping the IP address of each machine and capture the metrics
    while read -r dest_ip; do
        dest_name=$(grep "$dest_ip" "$ip_file" | awk -F',' '{print $2}')
        ping_metrics=$(ssh -n -o StrictHostKeyChecking=no "${ipa}" "ping -c 5 -i 0.2 -q $dest_ip | tail -n 2 | head -1")
        ping_metric_rtt=$(ssh -n -o StrictHostKeyChecking=no "${ipa}" "ping -c 5 -i 0.2 -q $dest_ip | tail -n 2 | tail -1")
        #cpu_utilization=$(ssh -n -o StrictHostKeyChecking=no "$dest_ip" "top -b -n 1 | grep 'Cpu(s)' | awk '{print \$2}'")

        # Write the ping metrics to the output file with the name of the source machine
        echo "$name,$dest_ip,$dest_name,$ping_metrics,$ping_metric_rtt" >> "${name}_ping.csv"

    done < <(grep -v "$ipa" "$ip_file" | awk -F',' '{print $1}')

    # Ping the IP address of the machine itself and capture the metrics
    ping_metrics=$(ssh -n -o StrictHostKeyChecking=no "${ipa}" "ping -c 5 -i 0.2 -q $ipa | tail -n 2 | head -1")
    ping_metric_rtt=$(ssh -n -o StrictHostKeyChecking=no "${ipa}" "ping -c 5 -i 0.2 -q $ipa | tail -n 2 | tail -1")
    #cpu_utilization=$(top -b -n 1 | grep 'Cpu(s)' | awk '{print $2}')

    # Write the ping metrics to the output file with the name of the source machine
    echo "$name,$ipa,$name,$ping_metrics,$ping_metric_rtt" >> "${name}_ping.csv"

    # Write the CPU utilization metrics to the output file with the name of the source machine
    #echo "$name,$ipa,$name,$cpu_utilization" >> "${name}_cpu.csv"
done < "$ip_file"

# Combine all the ping CSV files into a single file and separate lines with the source machine name
echo > $ping_output_file
for f in *_ping.csv; do
    echo "${f%%_*}" >> $ping_output_file
    cat "$f" >> $ping_output_file
    echo >> $ping_output_file
done

# Collect CPU usage details for each machine
echo > $cpu_output_file
while read -r ip; do
    ipa=$(echo $ip | awk -F',' '{print $1}')
    name=$(echo $ip | awk -F',' '{print $2}')
    location=$(echo $ip | awk -F',' '{print $3}')
    cpu_metrics=$(ssh -n -o StrictHostKeyChecking=no "$ipa" "top -b -n 1 | grep 'Cpu(s)' | awk '{print \$2}'")
    echo "$name,$cpu_metrics" >> $cpu_output_file
done < "$ip_file"
