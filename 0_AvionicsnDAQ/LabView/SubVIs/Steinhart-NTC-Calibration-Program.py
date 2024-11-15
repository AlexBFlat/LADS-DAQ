# Steinhart NTC Calibration program
# This program takes in six data points; 1 temperature and 1 measured resistance from an NTC thermistor.
from scipy.optimize import fsolve
import math

### User input section
R1 = float(input("R1 (Kohm): ")) # User input of first resistance value in kilo-Ohms
T1 = float(input("T1 (K): "))    # User input of first temperature value in K
R1t = R1*pow(10,3)            # Converts input resistance to Ohms.
RTest = (math.log(R1t))
print(" ")

R2 = float(input("R2 (Kohm): ")) # User input of first resistance value in kilo-Ohms
T2 = float(input("T2 (K): ")) # User input of first temperature value in K
R2t = R2*pow(10,3)            # Converts input resistance to Ohms.

print(" ")

R3 = float(input("R3 (Kohm): ")) # User input of first resistance value in kilo-Ohms
T3 = float(input("T3 (K): ")) # User input of first temperature value in K
R3t = R3*pow(10,3)           # Converts input resistance to Ohms.

### Calculations
def equations(p):
    A, B, C = p
    return (A + B*math.log(R1t)+C*pow((math.log(R1t)),3) - 1/T1, A + B*math.log(R2t)+C*pow((math.log(R2t)),3) - 1/T2, A + B*math.log(R3t)+C*pow((math.log(R3t)),3) - 1/T3)

A, B, C = fsolve(equations, (1, 1, 1))

print(equations((A, B, C)))