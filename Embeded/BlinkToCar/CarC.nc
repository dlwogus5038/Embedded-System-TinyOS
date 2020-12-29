#include "msp430usart.h"
module CarC
{
	uses interface HplMsp430Usart;
	uses interface HplMsp430UsartInterrupts;
	uses interface Resource;
	uses interface HplMsp430GeneralIO;
	provides interface Car;
}

implementation
{
	uint16_t angleOne = MIDDLE_POSITION;
	uint16_t angleTwo = MIDDLE_POSITION;
	uint16_t angleThree = MIDDLE_POSITION;

	uint8_t instruction;
	uint16_t data;
	uint8_t byte = 1;
	bool busy_write = FALSE;
	uint8_t data_start;
	uint8_t data_end;
	bool resetcheck = FALSE;

	msp430_uart_union_config_t config = {
		{
			utxe : 1,
			urxe : 1,
			ubr : UBR_1MHZ_115200,
			umctl : UMCTL_1MHZ_115200,
			ssel : 0x02,
			pena : 0,
			pev : 0,
			clen : 1,
			listen : 0,
			mm : 0,
			ckpl : 0,
			urxse : 0,
			urxeie : 0,
			urxwie : 0,
			utxe : 1,
			urxe : 1
		}
	};

	command void Car.requestResource()
	{
		call Resource.request();
	}

	event void Resource.granted()
	{
		call HplMsp430Usart.setModeUart(&config);
		call HplMsp430Usart.enableUart();
		atomic U0CTL&=~SYNC;
		signal Car.resourceGranted();
	}

	async event void HplMsp430UsartInterrupts.rxDone(uint8_t data)
	{
	}

	async event void HplMsp430UsartInterrupts.txDone()
	{
	}
	task void writeOrder()
	{
		switch(byte)
		{
			case 1:
			if(!(call HplMsp430Usart.isTxEmpty()))
			{
				post writeOrder();
				break;
			}
			call HplMsp430Usart.tx(0x01);
			byte++;

			case 2:
			if(!(call HplMsp430Usart.isTxEmpty()))
			{
				post writeOrder();
				break;
			}
			call HplMsp430Usart.tx(0x02);
			byte++;

			case 3:
			if(!(call HplMsp430Usart.isTxEmpty()))
			{
				post writeOrder();
				break;
			}
			call HplMsp430Usart.tx(instruction);
			byte++;

			case 4:
			if(!(call HplMsp430Usart.isTxEmpty()))
			{
				post writeOrder();
				break;
			}
			data_start = data / 0x100;
			call HplMsp430Usart.tx(data_start);
			byte++;

			case 5:
			if(!(call HplMsp430Usart.isTxEmpty()))
			{
				post writeOrder();
				break;
			}
			data_end = data % 0x100;
			call HplMsp430Usart.tx(data_end);
			byte++;

			case 6:
			if(!(call HplMsp430Usart.isTxEmpty()))
			{
				post writeOrder();
				break;
			}
			call HplMsp430Usart.tx(0xFF);
			byte++;

			case 7:
			if(!(call HplMsp430Usart.isTxEmpty()))
			{
				post writeOrder();
				break;
			}
			call HplMsp430Usart.tx(0xFF);
			byte++;

			case 8:
			if(!(call HplMsp430Usart.isTxEmpty()))
			{
				post writeOrder();
				break;
			}
			call HplMsp430Usart.tx(0x00);
			call Resource.release();
			busy_write = FALSE;
			byte = 1;
			
		}
	} 

	command void Car.reset1()
	{
		if(busy_write)
			return;
		busy_write = TRUE;
		angleOne = MIDDLE_POSITION;
		angleTwo = MIDDLE_POSITION;
		instruction = STEER_ONE;
		data = MIDDLE_POSITION;
		post writeOrder();
	}

	command void Car.reset2()
	{
		if(busy_write)
			return;
		busy_write = TRUE;
		angleOne = MIDDLE_POSITION;
		angleTwo = MIDDLE_POSITION;
		instruction = STEER_TWO;
		data = MIDDLE_POSITION;
		post writeOrder();
	}

	command void Car.angleOneUp()
	{
		if(busy_write)
			return;
		busy_write = TRUE;
		if(angleOne < MAX_ANGLE)
		  angleOne += STEP;
		instruction = STEER_ONE;
		data = angleOne;
		post writeOrder();
	}

	command void Car.angleOneDown()
	{
		if(busy_write)
			return;
		busy_write = TRUE;
		if(angleOne > MIN_ANGLE)
			angleOne -= STEP;
		instruction = STEER_ONE;
		data = angleOne;
		post writeOrder();
	}

	command void Car.angleTwoUp()
	{
		if(busy_write)
			return;
		busy_write = TRUE;
		if(angleTwo < MAX_ANGLE)
			angleTwo += STEP;
		instruction = STEER_TWO;
		data = angleTwo;
		post writeOrder();
	}

	command void Car.angleTwoDown()
	{
		if(busy_write)
			return;
		busy_write = TRUE;
		if(angleTwo > MIN_ANGLE)
			angleTwo -= STEP;
		instruction = STEER_TWO;
		data = angleTwo;
		post writeOrder();
	}

	command void Car.left()
	{
		if(busy_write)
			return;
		busy_write = TRUE;
		instruction = TURN_LEFT;
		data = SPEED;
		post writeOrder();
	}

	command void Car.right()
	{
		if(busy_write)
			return;
		busy_write = TRUE;
		instruction = TURN_RIGHT;
		data = SPEED;
		post writeOrder();
	}

	command void Car.forward()
	{
		if(busy_write)
			return;
		busy_write = TRUE;
		instruction = GO_STRAIGHT;
		data = SPEED;
		post writeOrder();
	}

	command void Car.back()
	{
		if(busy_write)
			return;
		busy_write = TRUE;
		instruction = GO_BACK;
		data = SPEED;
		post writeOrder();
	}

	command void Car.stop()
	{
		if(busy_write)
			return;
		busy_write = TRUE;
		instruction = STOP;
		data = SPEED;
		post writeOrder();
	}
}
