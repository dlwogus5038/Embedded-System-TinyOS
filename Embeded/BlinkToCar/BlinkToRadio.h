// $Id: BlinkToRadio.h,v 1.4 2006/12/12 18:22:52 vlahan Exp $

#ifndef BLINKTORADIO_H
#define BLINKTORADIO_H

enum {
	STEER_ONE = 1,
	GO_STRAIGHT = 2,
	GO_BACK = 3,
	TURN_LEFT = 4,
	TURN_RIGHT = 5,
	STOP = 6,
	STEER_TWO = 7,
	AM_BLINKTORADIOMSG = 0xbb,
	BUTTON_A = 9,
	BUTTON_B = 10,
	BUTTON_C = 11,
	BUTTON_D = 20,
	BUTTON_E = 12,
	BUTTON_F = 13,
	STEP = 300,
	TIMER_PERIOD_MILLI = 100,
	SPEED = 500,
	MIDDLE_POSITION = 3000,
	MAX_ANGLE = 4500,
  	MIN_ANGLE = 1800,
};

typedef nx_struct BlinkToRadioMsg {
  nx_uint8_t instruction;
} BlinkToRadioMsg;

#endif
