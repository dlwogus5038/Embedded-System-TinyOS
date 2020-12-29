#include <Timer.h>
#include "BlinkToRadio.h"

configuration BlinkToRadioAppC 
{
}

implementation 
{
	components MainC;
	components LedsC;
	components BlinkToRadioC as App;
	components new TimerMilliC() as Timer0;
	components ActiveMessageC;
	components new AMSenderC(AM_BLINKTORADIOMSG);
	components ButtonC;
	components JoyStickC;
	components HplMsp430GeneralIOC;

	App.Boot -> MainC;
	App.Leds -> LedsC;
	App.Timer0 -> Timer0;
	App.Packet -> AMSenderC;
	App.AMPacket -> AMSenderC;
	App.AMControl -> ActiveMessageC;
	App.AMSend -> AMSenderC;
	App.Button -> ButtonC;
	App.StickX -> JoyStickC.StickX;
	App.StickY -> JoyStickC.StickY;
	ButtonC.PortA -> HplMsp430GeneralIOC.Port60;
	ButtonC.PortB -> HplMsp430GeneralIOC.Port21;
	ButtonC.PortC -> HplMsp430GeneralIOC.Port61;
	ButtonC.PortD -> HplMsp430GeneralIOC.Port23;
	ButtonC.PortE -> HplMsp430GeneralIOC.Port62;
	ButtonC.PortF -> HplMsp430GeneralIOC.Port26;
}
