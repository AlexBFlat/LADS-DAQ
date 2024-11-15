########################### temperature_recorder_v2.py ###################################
#  Fancy version of program to monitor room temperature using a LabJack U3
#  Use XGraph  http://www.xgraph.org  to make a nice graph of the resulting data file
#  Halverson Nov 10, 2014
print ("Use ^C to kill this program")
import u3
from easyU3 import (u3setup,analogIn0,analogIn1,
dac0out,dac1out,digitalIn2,digitalIn3,
FIO4on,FIO4off,FIO5on,FIO5off,FIO6on,FIO6off,FIO7on,FIO7off,
temperatureC,temperatureF,LED)
import time                                               # See docs.python.org/2/library/time.html
d = u3.U3()                                               # Opens first found U3 over USB
u3setup(d)
start_time=time.time()
file_name_time=time.strftime('%Y_%m_%d_%H_%M',time.localtime(start_time))  #  docs.python.org/2/library/time.html#time.strftime
data_file=open('temp_data_'+file_name_time+'.dat','w')
#Put the start time as a comment, and some other useful info
data_file.write('! '+time.asctime(time.localtime(start_time))+"1st column is hours, 2nd column is temperature\n")  
current_time=0
print ("start_time=",time.asctime(time.localtime(start_time)))
n=0
seconds_per_loop=60                                                 #Write to file once per minute
blink_state=True
while True:
   number_of_measurements=0
   average_T=0.0
   n=n+1
   while n*seconds_per_loop > current_time:
      current_time=time.time()-start_time
      number_of_measurements=number_of_measurements+1
      average_T = average_T + temperatureF(d)-7.3        #Add up measurements for averaging
      #I am subtracting few degrees because the sensor is inside the U3's box and due to the 
      #heat of the electronics it always reads a little higher than ambient.
      #Just for fun add blinking
      LED(d,(blink_state))
      blink_state= not blink_state
      time.sleep(0.1)
   average_T=average_T/number_of_measurements            #Now we have the average  
   print (current_time/3600.," ",average_T,)               #time will be displayed in hours
   #Make a primitive graph on screen
   for i in range(0,int(average_T-40.0)):                #Note: int rounds towards zero, whereas math.floor rounds down
      print (" "),                                         #Note: the "," at the end of the line prevents a newline
   print ("F")
   data_file.write(str(current_time/3600.)+","+str(average_T)+"\n")
   data_file.flush()                                     #Make sure everything is written to disk