#include <Timer.h>
#include "msp430usart.h"
#include "BlinkToRadio.h"

configuration BlinkToRadioAppC 
{
}

implementation {
  components MainC;
  components LedsC;
  components BlinkToRadioC as App;
  components ActiveMessageC;
  components new AMReceiverC(AM_BLINKTORADIOMSG);
  components CarC;
  components HplMsp430Usart0C;
  components new Msp430Uart0C();
  components HplMsp430GeneralIOC;

  App.Boot -> MainC;
  App.Leds -> LedsC;
  App.AMControl -> ActiveMessageC;
  App.AMPacket -> AMReceiverC;
  App.Receive -> AMReceiverC;
  App.Car -> CarC;
  CarC.HplMsp430Usart->HplMsp430Usart0C.HplMsp430Usart;
  CarC.HplMsp430UsartInterrupts->HplMsp430Usart0C.HplMsp430UsartInterrupts;
  CarC.Resource -> Msp430Uart0C.Resource;
  CarC.HplMsp430GeneralIO -> HplMsp430GeneralIOC.Port20;
}
