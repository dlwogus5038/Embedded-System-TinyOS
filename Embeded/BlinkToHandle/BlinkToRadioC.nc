#include <Timer.h>
#include <Msp430Adc12.h>
#include "BlinkToRadio.h"

module BlinkToRadioC 
{
  	uses interface Boot;
  	uses interface Leds;
  	uses interface Timer<TMilli> as Timer0;
  	uses interface Packet;
  	uses interface AMPacket;
  	uses interface AMSend;
  	uses interface SplitControl as AMControl;
  	uses interface Button;
  	uses interface Read<uint16_t> as StickX;
  	uses interface Read<uint16_t> as StickY;
}

implementation 
{

 	 message_t pkt;
  	bool busy = FALSE;

  	event void Boot.booted() 
  	{
  	  call AMControl.start();
  	  call Leds.led0On();
  	  call Leds.led1On();
  	  call Leds.led2On();
  	}

  	event void AMControl.startDone(error_t err) 
  	{
   		if (err == SUCCESS) 
    		call Button.start();
   		else 
      		call AMControl.start();

  	}

	event void AMControl.stopDone(error_t err) 
	{
	}

	event void Button.startDone() 
	{  
	    call Timer0.startPeriodic(TIMER_PERIOD_MILLI);
	}

	event void Button.stopDone() 
	{
	}

	void sendOrder(uint8_t instruction)
	{
	    if (!busy) 
	    {
	    	BlinkToRadioMsg* btrpkt = (BlinkToRadioMsg*)(call Packet.getPayload(&pkt, sizeof(BlinkToRadioMsg)));
	      	if (btrpkt == NULL) 
		       return;
	     	btrpkt->instruction = instruction;
      		
	      	if (call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(BlinkToRadioMsg)) == SUCCESS) 
		{
			call Leds.set(instruction);
	        	busy = TRUE;
		}
	    }
	}

	event void Timer0.fired() 
	{
	    call Button.pinvalueA();
	    call Button.pinvalueB();
	    call Button.pinvalueC();
	    call Button.pinvalueD();
	    call Button.pinvalueE();
	    call Button.pinvalueF();
	    call StickX.read();
	    call StickY.read();
	}

	event void StickX.readDone(error_t result, uint16_t val)
	{
	    if(result == SUCCESS)
	    {
	    	if(val < 1000) {
	        	sendOrder(GO_STRAIGHT);
		}
	      	else if(val > 3000) {
	        	sendOrder(GO_BACK);
		}
	    }
	}

	event void StickY.readDone(error_t result, uint16_t val)
	{
	  if(result == SUCCESS)
	    {
		if(val < 1000) {
			sendOrder(TURN_LEFT);
		}
		else if(val > 3000) {
			sendOrder(TURN_RIGHT);
		}
	      	else{
			sendOrder(STOP);
		}
	    }
	}

	event void Button.pinvalueADone()
	{
		sendOrder(BUTTON_A);
	}

	event void Button.pinvalueBDone()
	{
		sendOrder(BUTTON_B);
	}

	event void Button.pinvalueCDone()
	{
		sendOrder(BUTTON_C);
	}

	event void Button.pinvalueDDone()
	{
		//sendOrder(BUTTON_D);
	}

	event void Button.pinvalueEDone()
	{
		sendOrder(BUTTON_E);
	}

	event void Button.pinvalueFDone()
	{
		sendOrder(BUTTON_F);
	}

	event void AMSend.sendDone(message_t* msg, error_t err) 
	{
	    if (&pkt == msg) 
	    {
	    	busy = FALSE;
	    }
	}
}
