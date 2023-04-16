#!/bin/bash -vx


# Path to the file containing IP addresses
ip_file="ip_address"

# Path to the output file for ping metrics
ping_output_file="ping_metrics.csv"

# Path to the output file for CPU utilization metrics
cpu_output_file="cpu_metrics.csv"


# Collect CPU usage details for each machine
echo > $cpu_output_file
while read -r ip; do
	ipa=$(echo $ip | awk -F',' '{print $1}')
    name=$(echo $ip | awk -F',' '{print $2}')
    location=$(echo $ip | awk -F',' '{print $3}')
    cpu_metrics=$(ssh -n -o StrictHostKeyChecking=no "$ipa" "top -b -n 1 | grep 'Cpu(s)' | awk '{print \$2}'")
    echo "$name,$cpu_metrics" >> $cpu_output_file
done < "$ip_file"
