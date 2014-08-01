PruIEP_Int  3 examples
========
Examples of using the PRUSS IEP timer interrupt on the BEAGLEBONE to toggle a pin.

notes - comments about this example

iepx.c - Initialize the Pruss,  initializes the interrupt system, waits for the pru to finish executionjj
       
iepx.p - The PRUSS initializes the IEP interrupt for CMP0 (compare register 0).  Toggles pin on interrupt
       
prujts1-00A0.dts - The device tree overlay to enable the PRUSS and set P9.31 for Pru output.

iep2.c - Initialize the Pruss,  initializes the interrupt system, waits for the pru to finish executionjj
       
iep2.p - The PRUSS initializes the IEP interrupt for CMP0 (compare register 0). and  CMP1  On CMP1 interrupt clear the pin, on CMP0 set the pin and reset the counter.

ieps.c - Initialize the Pruss, waits 30 seconds and exits.  Does not initialize the PRUSS INTC

ieps.p - Initialize the PRUSS INTC interrupt system.  Initializes the IEP interrupts for CMP0 & CMP1.  Toggles P9.31 using interrupts form CMP0 & CMP1. 
