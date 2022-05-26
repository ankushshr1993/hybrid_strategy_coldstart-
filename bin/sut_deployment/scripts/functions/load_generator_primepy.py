import os
import subprocess
import multiprocessing
import time
import yaml
from datetime import datetime
import csv


# Process class
class Process(multiprocessing.Process):
    def __init__(self, id):
        super(Process, self).__init__()
        self.id = id

    def run(self): 
        t=datetime.now()
        [h,m,s]=(str(t).split(' ')[1].split(":"))
        time_inseconds=(int(h)*3600+int(m)*60+float(s.split('Z')[0]))
        row=[time_inseconds,'primepy'+ str(self.id)]
        with open(r'loaddata.csv','a') as f:
            writer=csv.writer(f)
            writer.writerow(row)
            f.close()
        cmd1 = 'wsk -i action create primePy' + str(self.id) + ' primenumber.py'
        cmd2 = 'wsk -i action invoke primePy' + str(self.id) + ' --result '
        os.system(cmd1)
        os.system(cmd2)
        print("I'm the process with id: {}".format(self.id))
        
        
if __name__ == '__main__':
    t=datetime.now()
    [h,m,s]=(str(t).split(' ')[1].split(":"))
    time_inseconds=(int(h)*3600+int(m)*60+float(s.split('Z')[0]))
    row=[time_inseconds,'primepy'+ str(0)]
    with open(r'loaddata.csv','a') as f:
        writer=csv.writer(f)
        writer.writerow(row)
        f.close()
    p = Process(0)

#Parallel invocation
    p.start()

# Process.join() to wait for task completion.
    
    for i in range(1,25):
        t=datetime.now()
        [h,m,s]=(str(t).split(' ')[1].split(":"))
        time_inseconds=(int(h)*3600+int(m)*60+float(s.split('Z')[0]))
        row=[time_inseconds,'primepy'+ str(i)]
        with open(r'loaddata.csv','a') as f:
            writer=csv.writer(f)
            writer.writerow(row)
            f.close()
        p = Process(i)
        p.start()
