//iep2.p   -  set up IEP interrupt on CMP0 hitting compare value.
//            and on CMP1 hitting compare value.
//            toggles pin p9.31 -  attached to r30.t0 - mode 5 output
//
//            Depends on call linux program to initialize the INTC 
//
.setcallreg r2.w0  //  Going to use r30
.origin 0
.entrypoint TB
TB:
       set r30,r30, 0         //turn on 
       jmp ISET                //this is the routine to setup

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
       mov r31,35          //trigger host interrupt for Linux
       HALT

ISET: //  This section is to initialize the interrupts

//    INITIALIZE IEP INTERRUPTS

       mov r14,0x2fAf0800           //For CMP0, compare trigger
       sbco r14,c26,0x48,4
       mov r14,0x17D78400          //For CMP1, compare trigger
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
       mov r15,0x400            //set up Channel map
       mov r14,0x09090909       // first map all unused events to
       sbco r14,c0,r15,4        //  Channel 9
       mov r15,0x408
       sbco r14,c0,r15,4
       mov r15,0x40C            // skiping offsets 410 & 414, they
       sbco r14,c0,r15,4        // were set by the C program via prussdrv
       mov r18,0x43C            // end for loop
       mov r15,0x414            // start -4 for loop
TB43:
       add r15,r15,4
       sbco r14,c0,r15,4
       qbgt TB43,r15,r18
       mov r14,0x00090909       // map SysEvt 7 to channel 0
       mov r15,0x404            // now do 404, which has the
       sbco r14,c0,r15,4        // entries for 4,5,6,7

//   Done with Channel Map, Host Interrupt Map now
           // Host Interrupt 0 - 3 were setup by Linux   

       mov r14,0x09090909       // map channels 4,5,6,7 to Host Int 9 
       mov r15,0x804
       sbco r14,c0,r15,4
       mov r14,0x00000909       // map channel 8 & 9 to Host Int 9
       mov r15,0x808
       sbco r14,c0,r15,4

       ldi r15, 0x24             //clear all events
       call ALLEVT


       ldi r15,0x28              // enable all events
       call ALLEVT
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
