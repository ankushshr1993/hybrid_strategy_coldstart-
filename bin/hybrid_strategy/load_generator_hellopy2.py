import os
import sys
import subprocess
import multiprocessing
import time
import yaml
import csv
import pandas as pd
import json
import kalman_filter
import numpy as np
import extended_kalman_filter
import particle_filter
# Define command line arguments
args = sys.argv

# Helper function to run a Python script and capture its output
def run_script(script):
    output = subprocess.check_output(['python3', script])
    return output.decode().strip()

# Load ping and CPU metrics from CSV files
ping = pd.read_csv('/home/ankush_sharma_job_gmail_com/scripts/ping_metrics.csv', sep=';', header=None)
cpu = pd.read_csv('/home/ankush_sharma_job_gmail_com/scripts/cpu_metrics.csv', header=None)

# Filter ping metrics for the current node
current_node = 'master-automation'
ping = ping.iloc[:, 0].str.split(',', expand=True)
ping = ping[~ping.iloc[:, 2].isnull()]
filtered_ping = ping[ping.iloc[:, 0].str.contains(current_node)]
filtered_ping = filtered_ping[~filtered_ping.iloc[:, 2].str.contains(current_node)]
filtered_ping = filtered_ping.iloc[:, [0, 2, 7]]
filtered_ping.iloc[:, 2] = filtered_ping.iloc[:, 2].apply(lambda x: x.split('=')[1])
filtered_ping.iloc[:, 2] = filtered_ping.iloc[:, 2].apply(lambda x: x.split('/')[1])

# Create input dictionary for the Kalman filter
input_dict = {}
for i, row in filtered_ping.iterrows():
    print(row[7])
    node_name = row[2]
    node_cpu = float(cpu[cpu.iloc[:, 0].str.contains(node_name)].iloc[0, 1])
    node_latency = float(row[7]) # .split('=')[1].split('/')[1])
    input_dict[node_name] = [node_latency, node_cpu]

# Set up command line arguments for the Kalman filter
if args[4] == "kalman":
    json_file_path = "kalman.json"
    if os.path.exists(json_file_path):
        with open(json_file_path, "r") as f:
            previous = json.load(f)
        s =((previous['state']))
        s =s.replace('[','').replace(']','').split()
        state = np.array([float(val) for val in s]).reshape(2,1)
        s = (previous['P'])
        s = s.replace('[','').replace(']','').replace('\n','').split()
        P = np.array([float(val) for val in s]).reshape(2,2)
    else:
        state, P = None, None
    best_node, predictions, state, P = kalman_filter.kalman_filter(input_dict, state, P)
    current = {
        'best_node': best_node,
        'predictions': str(predictions),
        'state': str(state),
        'P': str(P)
    }
    with open(json_file_path, "w") as f:
        json.dump(current, f)
    print("Best node for initial data:", best_node)
elif args[4] == "extended":
    json_file_path = "extended.json"
    if os.path.exists(json_file_path):
        with open(json_file_path, "r") as f:
            previous = json.load(f)
        s =((previous['state']))
        s =s.replace('[','').replace(']','').split()
        state = np.array([float(val) for val in s]).reshape(2,1)
        s = (previous['P'])
        s = s.replace('[','').replace(']','').replace('\n','').split()
        P = np.array([float(val) for val in s]).reshape(2,2)
    else:
        state, P = None, None
    best_node, predictions, state, P = extended_kalman_filter.extended_kalman_filter(input_dict, state, P)
    current = {
        'best_node': best_node,
        'predictions': str(predictions),
        'state': str(state),
        'P': str(P)
    }
    with open(json_file_path, "w") as f:
        json.dump(current, f)
elif args[4] == "particle":
    best_node, predictions = particle_filter.particle_optimization(input_dict )
    current = {
        'best_node': best_node,
    }
else:
    raise ValueError("Invalid algorithm")

print("Test complete.")

cmd0 = 'kubectl label node '+ best_node +' openwhisk-role=invoker'

# Run Kubernetes node label command
os.system(cmd0)

# Process class
class Process(multiprocessing.Process):
    def __init__(self, id, fun):
        super(Process, self).__init__()
        self.id = id
        self.fun = fun
        self.fun_script = fun[:-2] + '.' + fun[-2:]

    def run(self):
        start_time = time.perf_counter()
        cmd1 = 'wsk -i action create ' + self.fun + str(self.id) + ' ' + self.fun_script
        cmd2 = 'wsk -i action invoke ' + self.fun + str(self.id) + ' --result --param name World'
        os.system(cmd1)
        os.system(cmd2)
        end_time = time.perf_counter()
        elapsed_time = end_time - start_time
        print("Process with id: {} finished in {} seconds".format(self.id, elapsed_time))

if __name__ == '__main__':
    
    start_time = time.perf_counter()
    with open(r'loaddata.csv','a') as f:
        writer = csv.writer(f)
        writer.writerow([start_time, args[1]+ str(0)])
    p = Process(0, args[1])

    #Parallel invocation
    if args[2] == "parallel":
        p.start()
    elif args[2] == "series": 
        p.start()
        p.join() # Wait for task completion.

    for i in range(1,int(args[3])):
        with open(r'loaddata.csv','a') as f:
            writer = csv.writer(f)
            writer.writerow([time.perf_counter(),args[1]+ str(i)])
        p = Process(i, args[1])
        if args[2] == "parallel":
            p.start()
        elif args[2] == "series":      
            p.start()
            p.join() # Wait for task completion.

    end_time = time.perf_counter()
    total_time = end_time - start_time
    print("Total execution time: {} seconds".format(total_time))

    # Run Kubernetes to remove the node label command
    cmd3 = 'kubectl label node '+ node +' openwhisk-role-'
    os.system(cmd3)
