
# TinyOS
 - UC 버클리에서 개발된 센서 네트워크를 위한 오픈소스 운영체제이며, 현재 세계에서 가장 큰 센서 네트워크 커뮤니티를 형성중.
 - nesC라는 C 기반의 프로그래밍 언어를 사용한 이벤트 기반의 운용체계.
 - 센싱 노드와 같은 초저전력, 초소형, 저가의 노드에 저전력, 적은 코드 사이즈, 최소한의 하드웨어 리소스를 사용하는 내장형 OS를 목표로 함.
 - 매우 작은 크기여서 익히기 쉽고, 높은 수준의 모듈 구조로 되어 있어 확장이 용이함.
 - 전원 소모와 메모리 소모가 많이 발생하게 되는 이유때문에 한 번에 하나의 애플리케이션만 실행. 여러 기능을 동시에 동작시키고자 할 경우에는 한 개의 애플리케이션에 아주 작은 단위로 동작을 세분화하여 태스크(Task) 형태로 동작.
 - FIFO(First In First Out)형태의 스케쥴러(Scheduler)로 동작하며, 전원이 꺼질 때 까지 무한 루프(loop)에서 동작.
 - 프로세스들은 크게 태스크와 이벤트로 나뉘며, 스케쥴링의 간편성을 위해 2-level scheduling 기법을 사용. 태스크를 다른 태스크에 의해 선점되지 않지만, 이벤트에 의해서는 선점됨.
 - 이벤트는 특정 하드웨어 인터럽트나 특정 조건을 만족했을 경우 호출되는 프로세스이고, 태스크보다 먼저 실행됨.
 
 ![Alt text](C:\Users\dlwog\Desktop\1461_654_1057.jpg)
 
# NesC(Network embedded system C)
 - 구조적 개념과 TinyOS 실행 모델을 구체화하기 위해 디자인 된 C의 확장.
 - 여러 컴포넌트들을 연결(Wiring)하여 하나의 애플리케이션 형태로 조합.
 - 구성은 **Application**, **Interface**, **Component**로 나뉨.
 - **Application** : 하나 이상의 컴포넌트로 구성되고, 실제 노드에서 실행 가능한 하나의 프로그램을 뜻함.
 - **Interface** : 두 컴포넌트를 연결하는 포트의 역할을 수행하며 양방향성을 가짐. Command와 Event를 이용.
 - **Component** : 자신이 사용할 하위 컴포넌트들을 선언하고, 그들 간의 연결을 정의하는 Configuration과 자신의 구현 내용을 기술하고 있는 Module로 나뉨.
 - Component에서는 Task와 Event가 사용되고, Task보다 Event가 먼저 선점되어 작동한다.
 - Configuration은 다른 컴포넌트와의 연결에 대한 내용을 정의함. 연결에 사용할 컴포넌트를 나열하고 그들간의 연결을 기술함. 이때 컴포넌트 사이의 연결을 와이어링(Wiring)이라 하는데, '->', '<-', '=' 세가지 방법이 있음.
 - component1.interface = component2.interface : 두개의 interface가 모두 제공자나 사용자로써 사용될 수 있는 경우
 - component1.interface -> component2.interface : component1.interface에서 사용한 함수가 component2.interface에 구현되어 있음을 나타냄. 즉 component1.interface가 사용자고 component2.interface가 제공자.
 - component1.interface <- component2.interface : 반대로 component1.interface가 제공자고 component2.interface가 사용자
 - Module은 해당 컴포넌트의 실제 구현에 대한 내용이 기술되어 있음.1
 - 출처 : https://terms.naver.com/entry.nhn?docId=864096  
 	https://terms.naver.com/entry.nhn?docId=3435121  
	https://usn-pioneer.tistory.com/17  
	https://yongjun86.tistory.com/entry/TinyOS-NesC
	
# 프로젝트 설명
 - 로봇 차량에는 STM32 시스템이 탑재돼있고, 해당 시스템이 로봇 차량의 컨트롤을 담당. Telosb 노드에서 TinyOS 시스템이 실행되며, 콘솔에서 발송하는 신호를 Telosb 노드에서 받아서 해당 노드에 달려있는 USB을 통해 로봇 차량에 데이터를 전송해 로봇 차량을 작동시킴. 이번 프로젝트에서 구현해야 하는 것은, 콘솔에서 보내는 버튼 및 조이스틱 신호에 따라 각기 다른 로봇 차량 조작을 구현시키는 코드를 작성하는 것.

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


'''

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
'''

## 문제 3 : 위의 방법을 통해 처리 할때, 8개의 byte가 다 작성된 후 다음 명령이 작성된다는 것을 어떻게 보장할 수 있나?
 - 해결방안 : busy_write라는 변수를 통해 post 명령을 제한하기로 함. busy_write가 FALSE 값을 가질때에만 post에서 명령을 작성할 수 있게 만들고, 8byte의 명령이 다 작성되면 busy_write를 TRUE로 만듦. 해당 명령의 8byte가 전부다 발송되면 다시 busy_write를 FALSE로 만들어서 명령을 작성할 수 있게 만듦.
 

# 느낀점
 - 비록 이번 프로젝트를 통해 간단한 기능밖에 구현하지 못했지만 임베디드 프로그래밍에 대한 기초적인 이해를 얻을 수 있었음.
