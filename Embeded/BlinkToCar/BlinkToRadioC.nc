#include <Timer.h>
#include "msp430usart.h"
#include "BlinkToRadio.h"

module BlinkToRadioC 
{
  uses interface Boot;
  uses interface Leds;
  uses interface Receive;
  uses interface AMPacket;
  uses interface SplitControl as AMControl;
  uses interface Car;
}

implementation 
{
  uint8_t instruction;
  uint16_t data;
  message_t pkt;
  bool busy = FALSE;
  bool resetSelect = FALSE;

  event void Boot.booted() 
  {
    call AMControl.start();
    call Leds.led0On();
    call Leds.led1On();
    call Leds.led2On();
  }

  event void AMControl.startDone(error_t err) 
  {
    if (err != SUCCESS) 
    {
      call AMControl.start();
    }
  }

  event void AMControl.stopDone(error_t err) 
  {
  }

  event void Car.resourceGranted()
  {
    switch(instruction)
      {
        case BUTTON_A:
          call Car.angleOneUp();
          break;
        case BUTTON_B:
          call Car.angleOneDown();
          break;
        case BUTTON_C:
          call Car.angleTwoUp();
          break;
        case BUTTON_E:
	  if(resetSelect)
	  {
          	call Car.reset1();
		resetSelect = FALSE;
	  }
	  else
	  {
		call Car.reset2();
		resetSelect = TRUE;
	  }
          break;
        case BUTTON_F:
	  call Car.angleTwoDown();
          break;
        case GO_STRAIGHT:
          call Car.forward();
          break;
        case GO_BACK:
          call Car.back();
          break;
        case TURN_LEFT:
          call Car.left();
          break;  
        case TURN_RIGHT:
          call Car.right();
          break;  
        case STOP:
          call Car.stop();
          break;  
      }
  }

  event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len)
  {
    
    if (len == sizeof(BlinkToRadioMsg)) 
    {
      BlinkToRadioMsg* btrpkt = (BlinkToRadioMsg*)payload;
      instruction = btrpkt->instruction;
      call Leds.set(instruction);
      call Car.requestResource();
    }
    return msg;
  }
}
