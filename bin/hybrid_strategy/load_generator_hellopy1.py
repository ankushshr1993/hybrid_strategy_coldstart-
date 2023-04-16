import os
import sys
import subprocess
import multiprocessing
import time
import yaml
from datetime import datetime
import csv

# Define command line arguments
args = sys.argv

# Trigger Algo 

# Set up Kubernetes node label command
if args[4] == "1":
    node = "worker-node1"
elif args[4] == "2":
    node = "worker-node2" 
elif args[4] == "3":
    node = "worker-node3"
elif args[4] == "4":
    node = "worker-node4"
else:
    raise ValueError("use value of nodes between 1-4")
cmd0 = 'kubectl label node '+ node +' openwhisk-role=invoker'
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
        t=datetime.now()
        cmd1 = 'wsk -i action create ' + self.fun + str(self.id) + ' ' + self.fun_script
        cmd2 = 'wsk -i action invoke ' + self.fun + str(self.id) + ' --result --param name World'
        os.system(cmd1)
        os.system(cmd2)
        print(str(t))
        print("I'm the process with id: {}".format(self.id))
        
        
if __name__ == '__main__':
    
    t=datetime.now()
    [h,m,s]=(str(t).split(' ')[1].split(":"))
    time_inseconds=(int(h)*3600+int(m)*60+float(s.split('Z')[0]))
    row=[time_inseconds, args[1]+ str(0)]
    with open(r'loaddata.csv','a') as f:
        writer=csv.writer(f)
        writer.writerow(row)
        f.close()
    p = Process(0, args[1])

    #Parallel invocation
    if args[2] == "parallel":
        p.start()
    elif args[2] == "series":      
        p.start()
        p.join()

    # Process.join() to wait for task completion.
    for i in range(1,int(args[3])):
        t=datetime.now()
        [h,m,s]=(str(t).split(' ')[1].split(":"))
        time_inseconds=(int(h)*3600+int(m)*60+float(s.split('Z')[0]))
        row=[time_inseconds,args[1]+ str(i)]
        with open(r'loaddata.csv','a') as f:
            writer=csv.writer(f)
            writer.writerow(row)
            f.close()
        p = Process(i, args[1])
        if args[2] == "parallel":
            p.start()
        elif args[2] == "series":      
            p.start()
            p.join()
    # Run Kubernetes to remove node label command
    cmd3 = 'kubectl label node '+ node +' openwhisk-role-'
    os.system(cmd3)
