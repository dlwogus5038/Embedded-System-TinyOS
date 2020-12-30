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

# 구현방법
 ## 콘솔
  - 콘솔 부분의 메인모듈인 BlinkToRadio에서 100ms 시간 간격으로 콘솔의 각 버튼 클릭 여부와 조이스틱의 X축, Y축 기울어진 정도를 파악한 후 로봇 차량으로 uint16_t 유형의 신호를 발송.
 ## 로봇 차량
  - BlinkToRadioC 모듈에서 무선신호를 통해 콘솔의 데이터를 받은 후, 인터페이스를 통해 CarC에서 HplMsp430Usart 의 request 함수를 사용하도록 하여 리소스 수집.
  - 수집 후 granted 이벤트를 발생시켜 USB로 데이터를 주입하기 전 초기화를 실시하고, BlinkToRadioC 모듈로 신호 발송.
  - 전달 받은 정보의 데이터 영역의 값에 따라 BlinkToRadioC 모듈에서 Car 인터페이스의 특정 함수를 호출하여 CarC에서 USB로 특정 명령을 주입하도록 함.
  - 특정 명령을 받은 CarC는 HplMsp430Usart의 tx함수를 호출하며 로봇 차량을 조작하는 데이터를 발송함. 한번 발송시 1개의 byte 데이터를 발송하며, 발송이 끝날때마다 isTxEmpty 함수를 사용하여 데이터가 비었는지 확인한 후 다시 1개의 byte 데이터를 발송.

# 발생한 문제 및 해결방안
## 문제 1 : 코드 로직이 잘 짜여있는 상태이지만 콘솔을 조작해도 로봇 차량이 움직이지 않음.
 - 해결방안 : 테스트중에 특정 신호가 계속해서 로봇 차량으로 발송되고 있는것이 확인됨. 해당 신호가 계속해서 발송되고 있었기 때문에 콘솔에서 로봇 차량으로 보내는 신호가 정상적으로 받아들여지지 않는 것을 발견함. 콘솔에 문제가 있다고 예상되어 확인하던 중, 버튼D가 고장이 난것이 확인됨. 버튼D 관련 코드를 수정하여 버튼D의 영향을 없애며 콘솔에서 보내는 신호가 정상적으로 수집됨.
 ## 문제 2 : 비선점 방식을 이용하여 어떻게 isTxDone 함수에서 FALSE를 반환하게 처리할 수 있을까?
  - 해결방안 : 명령을 작성하는 부분을 하나의 Task로 만들고, 전역변수 byte를 통해 명령의 몇번째 순서를 작성할지 표시함. 만약 현재 byte가 표시하는 위치의 명령을 작성하고 싶은데 tx함수가 아직 종료되지 않았을시에는, post가 작성하는 작업을 일정 기간 후에 작성함. 만약 작성이 성공적으로 완성됬을 시에는 전역변수 byte++를 하고, 계쏙해서 다음 byte위치의 명령을 작성한다. 8개의 byte가 전부 작성되면 byte 변수의 값을 1로 만들고, USB를 통해 리소스를 전달함.





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
