import os
import subprocess
import pandas as pd
import csv

#stream=os.system('docker events')
#output = stream.read()
#data=pd.DataFrame(columns=['Date', 'Time', 'Event', 'Name'])

process = subprocess.Popen(['docker', 'events'], 
                           stdout=subprocess.PIPE,
                           universal_newlines=True)


while True:
    output = process.stdout.readline()
    print(output.strip())
    print(output.split(' '))
    runtime_metrics=output.split(' ')
    a=['pause','unpause','start','create']
    if runtime_metrics[2] in a and len(runtime_metrics)>16:
        event_type= runtime_metrics[1]
        container_id= runtime_metrics[3]
        time_metrics=runtime_metrics[0].split('T')
        event = runtime_metrics[2]
        container_name = runtime_metrics[18].split('=')[1]
        pod_name = runtime_metrics[14].split('=')[1]
        [h,m,s]=((time_metrics[1]).split(':'))
        time_inseconds=(int(h)*3600+int(m)*60+float(s.split('Z')[0]))
        sandbox_id=runtime_metrics[17].split('=')[1]



        row = [time_metrics[0], time_inseconds,container_id,event_type, event , container_name, pod_name,sandbox_id ]

        with open(r'/home/ankush_sharma_job_gmail_com/scripts/functions/data.csv','a') as f: 
            writer=csv.writer(f)
            writer.writerow(row)
            f.close()
        #data.loc[len(data.index)]=row
    


    if runtime_metrics[2] == 'connect':
        event_type= runtime_metrics[1]
        sandbox_id= runtime_metrics[4]
        container_id= ' '
        time_metrics=runtime_metrics[0].split('T')
        event = runtime_metrics[2]
        container_name = ' '
        pod_name = ' '
        [h,m,s]=((time_metrics[1]).split(':'))
        time_inseconds=(int(h)*3600+int(m)*60+float(s.split('Z')[0]))



        row = [time_metrics[0], time_inseconds,container_id,event_type, event , container_name, pod_name,sandbox_id]

        with open(r'/home/ankush_sharma_job_gmail_com/scripts/functions/data.csv','a') as f: 
            writer=csv.writer(f)
            writer.writerow(row)
            f.close()
