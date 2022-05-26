import os
import subprocess
import multiprocessing


class Process(multiprocessing.Process):
    def __init__(self, id):
        super(Process, self).__init__()
        self.id = id  

    def run(self): 
        cmd1 = 'wsk -i action delete matrixpy' + str(self.id)
        os.system(cmd1 )





if __name__ == '__main__':
    p = Process(0)

#Parallel invocation
    p.start()

# Process.join() to wait for task completion.
    #p.join()
    for i in range(1,50):
        p = Process(i)
        p.start()
