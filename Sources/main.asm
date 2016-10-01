           INCLUDE 'MC9S08JM16.inc'
LONG1 EQU 0
LONG2 EQU 1
LAT1 EQU 2
LAT2 EQU 3
            XDEF START
            ABSENTRY START

            ORG     0B0H          ; Insert your data definition here
longitud1 DS 4
latitud1 DS 4
longitud2 DS 4
latitud2 DS 4
signos DS 1	
tmp	DS 4
tmp_1	DS 4

            ORG    0C000H
START:	
			CLRA 
            STA  	SOPT1  ; Disenable COP
            LDHX   #RAMEnd+1  ; initialize the stack pointer
            TXS

main:
		LDHX #LONGITUDE_2

		JSR fetch_xy     
        BRA    main
            
;*************SUBROUTINE TO OBTAIN DATA FROM TABLES******************            
fetch_xy:  
		CLRA 
		STA tmp+3
		STA tmp+2 ;clear tmp+2
		STA tmp+1 ;clear tmp+1
		STA tmp+0 ;clear tmp+0
		STA tmp_1+3
		STA tmp_1+2 ;clear tmp+2
		STA tmp_1+1 ;clear tmp+1
		STA tmp_1+0 ;clear tmp+0
		STA signos ;clear signos
		LDA ,X ; dereferencing pointer
 		CBEQA #'-',Negative ; if is negative branch
Positive:  BCLR 5,signos ; it has been detected a positive number
 		BRA ascii2dec ; goto ascii to decimal conversion 	
Negative:  BSET 7,signos ; it has been detected a negative number 
		AIX #01H ; increment pointer	
		LDA ,X ; dereferencing the pointer
ascii2dec: AND #0FH ; ascii to decimal conversion
		STA tmp+3 ; Save data in a memory 
bucle:	AIX #01H ; increment pointer		
		LDA ,X ; dereferencing pointer
		CBEQA #00,Fin ; searching for the las element of the array
		CBEQA #'.',bucle ; Floating point detected
        PSHX;save X on stack
        PSHA
mul10:   LDX tmp+3 ; byte 1 * 10
	   LDA #10				
	   MUL ; tmp3*10
	   STA tmp+3
	   TXA  ; X=A
	   STA tmp+2
	   
	   LDX tmp_1+2 ; byte 2 * 10
	   LDA #10
	   MUL ; tmp2
	   ADD tmp+2
	   STA tmp+2
	   TXA ; A=X
	   ADC tmp+1 ; add carry
	   STA tmp+1
	   CLRA 
	   ADC tmp+0 ; add carry
	   STA tmp+0
	   
	   LDX tmp_1+1 ; byte 3 * 10
	   LDA #10
	   MUL 
	   ADD tmp+1
	   STA tmp+1
	   TXA 
	   ADC tmp+0 ; add carry
	   STA tmp+0
	   
   	   LDX tmp_1+0 ; byte 4 * 10
	   LDA #10
	   MUL 
	   ADD tmp+0
	   STA tmp+0

	   PULA ;  ADD The last digit 
	   AND #0FH
	   ADD tmp+3
	   STA tmp+3
	   CLRA 
	   ADC tmp+2
	   STA tmp+2
	   CLRA 
	   ADC tmp+1
	   STA tmp+1
	   CLRA 
	   ADC tmp+0
	   STA tmp+0
	   
	   ;tmp_1=tmp
	   LDA tmp+3
	   STA tmp_1+3
	   LDA tmp+2
	   STA tmp_1+2
	   LDA tmp+1
	   STA tmp_1+1
	   LDA tmp+0
	   STA tmp_1+0
	   ;reset var
	   CLRA 
	   STA tmp+2
	   STA tmp+1
	   STA tmp+0
	   PULX ; Restoring context
	   BRA bucle
Fin:   JMP Fin	   
	   RTS ; return from subroutine 

		 
;****************************COORDENADAS****************************** 
LONGITUDE_1: FCB '-15.58978',0;  
LATITUDE_1:  FCB '57.56321',0;
LONGITUDE_2: FCB '180.99999',0;
LATITUDE2_:  FCB '23.15974',0;

			
            ORG	0FFFEH
			FCB START			; Reset
