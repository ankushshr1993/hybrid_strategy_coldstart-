#!/bin/bash -vx

# Path to the file containing IP addresses
ip_file="ip_address"

# Path to the output file
output_file="ping_metrics.csv"

#delete existing csv files.
rm -f ./*csv
# Loop through each IP address in the file and ping it
echo > $output_file
while read -r ip; do
    # Parse the IP address, name and location from the line in the file
    ipa=$(echo $ip | awk -F',' '{print $1}')
    name=$(echo $ip | awk -F',' '{print $2}')
    location=$(echo $ip | awk -F',' '{print $3}')

    # Ping the IP address of each machine and capture the metrics
    while read -r dest_ip; do
        dest_name=$(grep "$dest_ip" "$ip_file" | awk -F',' '{print $2}')
        metrics=$(ping -c 5 -i 0.2 -q "$dest_ip" | tail -n 2 | head -1)
        metric_rtt=$(ping -c 5 -i 0.2 -q "$dest_ip" | tail -n 2 | tail -1)
        
        # Write the metrics to the output file with the name of the source machine
        echo "$name,$dest_ip,$dest_name,$metrics,$metric_rtt" >> "${name}.csv"
    done < <(grep -v "$ipa" "$ip_file" | awk -F',' '{print $1}')

    # Ping the IP address of the machine itself and capture the metrics
    metrics=$(ping -c 5 -i 0.2 -q "$ipa" | tail -n 2 | head -1)
    metric_rtt=$(ping -c 5 -i 0.2 -q "$ipa" | tail -n 2 | tail -1)
    
    # Write the metrics to the output file with the name of the source machine
    echo "$name,$ipa,$name,$metrics,$metric_rtt" >> "${name}.csv"
done < "$ip_file"

# Combine all the CSV files into a single file and separate lines with the source machine name
echo > $output_file
for f in *.csv; do
    echo "${f%%.*}" >> $output_file
    cat "$f" >> $output_file
    echo >> $output_file
done
