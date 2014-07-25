//ieps.p   -  setup PRU INTC without help of Linux Prussdrv
//            All the setup is done by the pru.  Still does the same
//            as iepx.p, Initalizes CMP0 and toggle the pin on interrupt
//            and on CMP1 hitting compare value.
//            toggles pin p9.31 -  attached to r30.t0 - mode 5 output
//
//            Changed the loop time to 1 second.
//
.setcallreg r2.w0  //  Going to use r30
.origin 0
.entrypoint TB
TB:
       set r30,r30, 0         //turn on 
       jmp ASET           //this is the routine to setup

TB1:
       ldi r17,0             // init loop counter
       call RSET             // routine to clear & enable interrupts

TB2:
       qbbc TB2,r31.t30     // spin here for interrupt
       lbco r3,c26,0x44,4   //get status, which interrupt
       qbbs TB5,r3.t0       // check for CMP0
TB3:
       clr r30,r30,0        // CMP1 interrupt
TB4:
       call RSET            // clear, enable
       add r17,r17,1        //loop counter
       qblt TB9,r17,50      //loop 50 times
       jmp TB2

TB5:
       set r30,r30,0        // CMP0 interrupt
       jmp TB4

TB9:    //  exit point 
       clr r30,r30,0
       HALT

ASET: //  This section is to initialize the interrupts

//    INITIALIZE` THE PRU INTC

      mov r15,0xD00               //offset for SIPR0
      mov r14,0xFFFFFFFF          // must be oll bits = one
      sbco r14,c0,r15,4
      mov r15,0xD04               //offset for SIPR1
      sbco r14,c0,r15,4

      mov r15,0xD80               //offset for SITR0
      mov r14,0                   // must be zero
      sbco r14,c0,r15,4
      mov r15,0xD84               //offset for SITR1
      sbco r14,c0,r15,4

//    INITIALIZE IEP INTERRUPTS

       mov r14,0x0BEBC200           //For CMP0, compare trigger
       sbco r14,c26,0x48,4
       mov r14,0x05F5E100         //For CMP1, compare trigger
       sbco r14,c26,0x4c,4
       mov r14,0x7                // enable CMP0 & CPM1, and enable
       sbco r14,c26,0x40,4        // counter reset on event
       mov r14,0x3
       sbco r14,c26,0x44,4        // clear status for CMP0 & CMP1
       lbco r14,c26,0x4,4
       sbco r14,c26,0x4,4         // clear GLOBAL status, overflow
       mov r14,0x111              // enable IEP counter, inc 1
       sbco r14,c26,0,4

//    DONE WITH IEP SETUP

//    SETUP CHANNEL MAP
//            map SysEvent to Channel 0, leave 16 - 23 alone set by Linux
       mov r18,0x43C
       mov r15,0x3FC            //set up Channel map
TB43:
       mov r14,0x09090909       // first map all events to
       add r15,r15,4            // to channel 9
       sbco r14,c0,r15,4
       qbgt TB43,r15,r18
       mov r14,0x00090909       // map SysEvt 7 to channel 0
       mov r15,0x404            // now do 404, which has the
       sbco r14,c0,r15,4        // entries for 4,5,6,7

//   Done with Channel Map, Host Interrupt Map now
           // Host Interrupt 0 - 3 were setup by Linux   

       mov r14,0x09090900       // map channels 1,2,3 to Host Int 9 
                                // and channel 0 to host 0
       mov r15,0x800
       sbco r14,c0,r15,4
       mov r14,0x09090909       // map channels 4,5,6,7 to Host Int 9 
       mov r15,0x804
       sbco r14,c0,r15,4
       mov r14,0x00000909       // map channel 8 & 9 to Host Int 9
       mov r15,0x808
       sbco r14,c0,r15,4

       ldi r15, 0x24             //clear all events
       call RSET

       ldi r15,0x28              // enable all events
       call ALLEVT
       ldi r14,1
       ldi r15,0x10
       sbco r14,c0,r15,4         //turn on global interrupts
       ldi r14,0xF
       ldi r15,0x1500
       sbco r14,c0,r15,4         //turn on  interrupts
       jmp TB1

RSET:  // Routine to clear & enable system events, also host interrupts
       mov r24,r2           // Save return address
                            // so can call ALLEVT
       lbco r14,c26,0x4,4   // clear GLOBAL_STATUS
       sbco r14,c26,0x4,4
       lbco r14,c26,0x44,4  // clear CMP_STATUS
       sbco r14,c26,0x44,4
       lbco r14,c26,0x44,4
       mov r15,0x24         //  to clear system event
       call ALLEVT
       mov r15,0x28         //  to enable system event
       call ALLEVT

       mov r2,r24            // restore return address
       ret
       
ALLEVT:  //Insert the system envent in the proper INTC register
         // register r15 must have the register offset
         // will only work with registers that take the event number
         // if you want to handle multiple events, just add 
         //   ldi r14,"sys event no."
         //   sbco r14, c0 ,r15,4

       ldi r14,0x7
       sbco r14, c0 ,r15,4
       ret
