# 프로젝트 환경
 - Ubuntu 16.04
 - TinyOS 2.1.2

# 프로젝트 목표
 -	TinyOS 작업모드 및 프로그래밍 방식 이해
 -	무선 센서 노드의 기존 구조 및 작동 원리 이해
 -	STM32 소형 로봇 차량과 무선 센서 노드간의 통신 메커니즘 이해 & 노드간의 무선 통신 프로그래밍 습득.
 -	임베디드 프로그래밍의 기본 원칙 습득

# 프로젝트 요구사항
 -	STM32가 탑재된 소형 로봇 차량을 작동시키기 위해 프로그래밍하여 Telosb 노드를 컨트롤. 전진, 후퇴, 좌회전, 우회전, 정지 구현.
 -	STM32가 탑재된 소형 로봇 차량의 로봇 팔을 작동시키기 위해 프로그래밍하여 Telosb 노드를 컨트롤. 로봇 팔 상승, 하강, 좌회전, 우회전, 처음위치로 복귀 구현
 -	각 조작마다 소형 로봇 차량에 탑재된 LED등을 다르게 점등시키기.
 -	 조작을 통해 차량의 움직임을 통제하고, 버튼을 통해 로봇 팔의 움직임을 통제.

# 설계방법
 ## 콘솔
  - 콘솔 부분의 메인모듈인 BlinkToRadio에서 100ms 시간 간격으로 콘솔의 각 버튼 클릭 여부와 조이스틱의 X축, Y축 기울어진 정도를 파악한 후 로봇 차량으로 uint16_t 유형의 신호를 발송.
 ## 로봇 차량
  - BlinkToRadioC 모듈에서 콘솔의 신호를 받은 후, CarC에서 HplMsp430Usart 인터페이스의 request 함수를 사용하여 자원 수집.
  - 成功后会启动granted事件，在该事件中对进行串口信息写入的初始化，并将成功的信号发送到BlinkToRadioC模块。
  - 해당 기능 완성시 granted 이벤트 발생. 
  - 接着BlinkToRadioC模块会根据信息指令数据域的不同数值，调用Car接口的不同函数来控制CarC向串口写入不同命令。
  - 接到不同指令的CarC通过调用接口HplMsp430Usart中的tx函数来发送操控小车的信息，一次发送一个byte数据，每次发完需要通过函数isTxEmpty来检查是否空闲，再去发送下一个byte。

# 발생한 문제 및 해결방안
 - 问题一：在代码逻辑正常的情况下，为什么小车无法收到手柄的控制信息？
解决方案：测试中发现某个信号一直被往小车发送，干扰我们通过手柄操作发送信号的 -> 发现某个按钮是坏了的（按钮D）,所以屏蔽按钮D之后就可以正常地发送信号，而且小车也正常地接收信号。
 - 问题二：怎样用非抢占的方式处理isTxDone返回FALSE的情况？
解决方案：将写指令的部分设置成一个任务，通过一个外部变量byte来控制从指令的第几位开始写起。如果想要写当前位的时候tx函数没有执行完，便会post写的任务一段时间后再写；如果成功写入就将外部变量byte++，并继续试图写下一个byte的数据。当8个byte都写完之后，将变量byte重新置为1并释放串口的资源。
task void writeOrder(){
	switch(byte){
		case 1:
		if(!(call HplMsp430Usart.isTxEmpty())){
			post writeOrder();
			break;
		}
		data_end = data % 0x100;
		call HplMsp430Usart.tx(0x01);
		byte++;
        
		case 2:
		…
		case 3:
		…
		case 4:
		…
		case 5:
		…
		case 6:
		…
		case 7:
		…
		case 8:
		…
		call Resource.release();
		busy_write = FALSE;
		byte = 1;			
	}
}
 - 问题二：用上述方法处理后怎样保证一个指令的8个byte都写完之后再写入下一个指令？
解决方案：设置一个busy_write变量对post命令做出限制。只有当busy_write为FALSE的时候才可一个post一个写一条指令的命令，而一个指令开始写之后便会将busy_write设为TRUE，直到这条指令被完全写完再将busy_write置为FALSE。这样一来可以避免一条指令在写入的时候另一条指令post写指令的任务的情况。因为这种情况发生的时候如果前面的指令没有写完，想要post的时候会因为队列中已经有一个相同任务而失败。
 - 问题四：怎样实现一键复位？
一开始我们试图设计机制使得控制舵机1的指令写完后立刻开始写控制舵机2的指令，可是都不太成功。后来我们转变思路，设置一个bool变量来选择发出复位命令的时候复位的命令，TRUE时发送复位舵机1的命令，FALSE时发送复位舵机2的命令。因为手柄模块扫描的频率是10HZ，所以一般按一下会发出多条交替的“复位舵机1”、“复位舵机2”的命令，这样从外部看起来效果与一键复位相同。

# 느낀점
 - 这次大作业实现的功能虽然简单，但是让我们对嵌入式系统的开发有了初步的了解。在编写代码的过程中，我们发现nesC的事件机制和 QT很相像，split phase的设计思想、task execution的模型又涉及到很多操作系统调度的思想。感觉随着学习的深入和实践经验的增加，我们可以触类旁通，更快地上手一个新的工具，并且加深对原有知识的认识。
