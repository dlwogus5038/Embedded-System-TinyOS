#include <Msp430Adc12.h>

configuration JoyStickC {
  provides interface Read<uint16_t> as StickX;
  provides interface Read<uint16_t> as StickY;
}

implementation {
  components new AdcReadClientC() as JoyStickX;
  components new AdcReadClientC() as JoyStickY;
  components JoyStickP;
  JoyStickX.AdcConfigure -> JoyStickP.AdcConfigureX;
  JoyStickY.AdcConfigure -> JoyStickP.AdcConfigureY;
  StickX = JoyStickX.Read;
  StickY = JoyStickY.Read;
}
