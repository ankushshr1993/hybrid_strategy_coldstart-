import pandas as pd
import os
import time
data=pd.read_csv(r'/home/ankush_sharma_job_gmail_com/scripts/functions/data.csv',header=None)

cont_id=data[5].unique()
cont_id = ' '.join(cont_id).split()
for i in range(len(cont_id)):
    id = cont_id[i].split(')')[0]

    print(str(i) + ' : ' + id)
    #pause function
    pausefunc='docker pause ' + str(id)
    os.system(pausefunc)
    # Unpause Function 1
    unpausefunc='docker unpause ' + str(id)
    os.system(unpausefunc)
