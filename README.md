PruIEP_Int
========
Example of using the PRUSS IEP timer interrupt on the BEAGLEBONE to toggle a pin.

notes - comments about this example

iepx.c - Initialize the Pruss,  initializes the interrupt system, waits for the pru to finish executionjj
       
iepx.p - The PRUSS initializes the IEP interrupt for cmp0 (compare register 0.  Toggles pin on interrupt
       
prujts1-00A0.dts - The device tree overlay to enable the PRUSS and set P9.31 for Pru output.
