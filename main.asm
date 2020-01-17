.org 0x200 ; create 7SEG CODE TABLE at address 0x100 (word address, which will be byte address of 200)
data1:.DB 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R'

.org 0x300 ; create 7SEG CODE TABLE at address 0x100 (word address, which will be byte address of 200)
data2:.DB 0b01010011, 0b01010100, 0b01010101, 0b01010110, 0b01010111, 0b01011000, 0b01011001, 0b01011010, 0B00110000, 0B00110001, 0B00110010, 0B00110011, 0B00110100, 0B00110101, 0B00110110, 0B00110111, 0B00111000, 0B00111001
;            s       t            u          v           W           X            Y           Z           0           1           2           3           4           5           6           7           8           9

.ORG 0X00
JMP START
.ORG 0X02
JMP INT0ROUTINE

INT0ROUTINE:	
//	LDI R16,'H'
//	CALL DATAWRT
	IN R17,PINC
	CALL LOADZREGISTER1
	CALL DATAWRT
	CLR R17
RETI

LoadZRegister1:
	ldi ZL, low(2*data1)
	ldi ZH, high(2*data1)
	add zl,r17 ; add the BCD  value to be converted to low byte of 7SEG CODE TABLE to create an offset numerically equivalent to BCD value 
	lpm r16,z ; load z into r17 from program memory from7SEG CODE TABLE using modified z register as pointer
ret

LoadZRegister2:
	ldi ZL, low(2*data2)
	ldi ZH, high(2*data2)
	add zl,r16 ; add the BCD  value to be converted to low byte of 7SEG CODE TABLE to create an offset numerically equivalent to BCD value 
	lpm r16,z ; load z into r17 from program memory from7SEG CODE TABLE using modified z register as pointer
ret

START:

INITIALIZE_KEYPAD_INPUT:
    LDI R16, 0x00 ; load 0's into R16
	OUT DDRC, R16 ; output 1's to configure DDRc as "input" port
	OUT PORTC, R16 ; output 1's to configure DDRc as "input" port

CONFIGURE_INTERRUPTS:
	LDI R31,0X0A
	STS EICRA,R31
	LDI R31,0X03
	OUT EIMSK,R31
	LDI R31,0X00
	OUT DDRD,R31
	LDI R31,0X0C
	OUT PORTD,R31
	SEI

CONFIGURE_LCD:
	.EQU LCD_PRT = PORTB
	.EQU LCD_DDR = DDRB
	.EQU LCD_PIN = PINB
	.EQU LCD_RS = 0
	.EQU LCD_RW = 1
	.EQU LCD_EN = 2

INITIALIZE_STACK:
	LDI R21,HIGH(RAMEND)
	OUT SPH,R21 ; SET UP STACK
	LDI R21,LOW(RAMEND)
	OUT SPL,R21


INITIALIZE_LCD:
	LDI r21,0xFF;
	OUT LCD_DDR,R21
	OUT LCD_DDR,R21
	LDI R16,0X33
	CALL CMNDWRT
	CALL DELAY_2ms
	LDI R16,0X32
	CALL CMNDWRT
	CALL DELAY_2ms
	LDI R16,0X28
	CALL CMNDWRT
	CALL DELAY_2ms
	LDI R16,0X0E
	CALL CMNDWRT
	LDI R16,0X01
	CALL CMNDWRT
	CALL DELAY_2ms
	LDI R16,0X06
	CALL CMNDWRT


MAIN:
	RJMP MAIN ; WE CAN STILL BE INTERRUPTED, BUT WE WILL RETURN HERE



CMnDWRT:
	MOV R27,R16
	ANDI R27,0XF0  
	IN R26,LCD_PRT
	ANDI R26,0X0F
	OR R26,R27
	OUT Lcd_PRT,R26
	CBI LCD_PRT,LCD_RS
	CBI LCD_PRT,LCD_RW
	SBI LCD_PRT,LCD_EN
	CALL SDELAY
	CBI LCD_PRT,LCD_EN

	CALL DELAY_100us

	MOV R27,R16
	SWAP R27
	ANDI R27,0XF0
	IN R26,LCD_PRT
	ANDI R26,0X0F
	OR R26,R27
	OUT LCD_PRT,R26
	SBI LCD_PRT,LCD_EN
	CALL SDELAY
	CBI LCD_PRT,LCD_EN

	CALL DELAY_100us
RET


DATAWRT:
	MOV R27,R16
	ANDI R27,0XF0
	IN R26,LCD_PRT
	ANDI R26,0X0F
	OR R26,R27
	OUT Lcd_PRT,R26
	SBI LCD_PRT,LCD_RS
	CBI LCD_PRT,LCD_RW
	SBI LCD_PRT,LCD_EN
	CALL SDELAY
	CBI LCD_PRT,LCD_EN

	MOV R27,R16
	SWAP R27
	ANDI R27,0XF0
	IN R26,LCD_PRT
	ANDI R26,0X0F
	OR R26,R27
	OUT Lcd_PRT,R26
	SBI LCD_PRT,LCD_EN
	CALL SDELAY 
	CBI LCD_PRT,LCD_EN

	CALL DELAY_100us
RET

SDELAY:
	NOP ; NO OPERATION, JUST TAKES UP 1 CLOCK CYCLE
	NOP ; NO OPERATION, JUST TAKES UP 1 CLOCK CYCLE
RET

DELAY_100us: ; DELAY 100 MICRO SECONDS
	PUSH R17
	LDI R17,60

DR0: 
	CALL SDELAY  
	DEC R17
	BRNE DR0  ; LOOP THIS 60 TIMES
	POP R17
RET


DELAY_2ms: ; DELAY 2 MILLI SECONDS
	PUSH R17
	LDI R17,20

LDR0: 
	CALL DELAY_100us   
	DEC R17  
	BRNE LDR0   ; LOOP THIS 20 TIMES
	POP R17
RET
