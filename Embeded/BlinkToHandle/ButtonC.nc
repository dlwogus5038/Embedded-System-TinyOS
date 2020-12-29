module ButtonC
{
	provides interface Button;
	uses interface HplMsp430GeneralIO as PortA;
	uses interface HplMsp430GeneralIO as PortB;
	uses interface HplMsp430GeneralIO as PortC;
	uses interface HplMsp430GeneralIO as PortD;
	uses interface HplMsp430GeneralIO as PortE;
	uses interface HplMsp430GeneralIO as PortF;
}

implementation
{
	command void Button.start()
	{
		call PortA.clr();
		call PortA.makeInput();

		call PortB.clr();
		call PortB.makeInput();

		call PortC.clr();
		call PortC.makeInput();

		call PortD.clr();
		call PortD.makeInput();

		call PortE.clr();
		call PortE.makeInput();

		call PortF.clr();
		call PortF.makeInput();

		signal Button.startDone();
	}

	command void Button.stop()
	{
	}

	command void Button.pinvalueA()
	{
		error_t err = call PortA.get();
		if(!err)
			signal Button.pinvalueADone();
	}
	
	command void Button.pinvalueB()
	{
		error_t err = call PortB.get();
		if(!err)
			signal Button.pinvalueBDone();
	}

	command void Button.pinvalueC()
	{
		error_t err = call PortC.get();
		if(!err)
			signal Button.pinvalueCDone();
	}
	command void Button.pinvalueD()
	{
		error_t err = call PortD.get();
		if(!err)
			signal Button.pinvalueDDone();
	}
	command void Button.pinvalueE()
	{
		error_t err = call PortE.get();
		if(!err)
			signal Button.pinvalueEDone();
	}
	command void Button.pinvalueF()
	{
		error_t err = call PortF.get();
		if(!err)
			signal Button.pinvalueFDone();
	}
}
