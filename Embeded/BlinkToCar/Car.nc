interface Car
{
	command void requestResource();
	event void resourceGranted();
	command void angleOneUp();
	command void angleOneDown();
	command void angleTwoUp();
	command void angleTwoDown();
	command void left();
	command void right();
	command void forward();
	command void back();
	command void stop();
	command void reset1();
	command void reset2();
}
