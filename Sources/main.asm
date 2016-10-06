           INCLUDE 'MC9S08JM16.inc'
LONG1 EQU 0
LONG2 EQU 1
LAT1 EQU 2
LAT2 EQU 3
FLAGADD EQU 4 ; Add or Substraction
Z EQU 5
            XDEF START
            ABSENTRY START

            ORG     0B0H          ; Insert your data definition here
longitude1 DS 4 
latitude1 DS 4
longitude2 DS 4
latitude2 DS 4
delta_lat DS 4
delta_long DS 4
signos DS 1	
magnitud DS 6
media_lat DS 4
tmp	DS 4
tmp_1 DS 4
tmp_2 DS 4
tmp_3 DS 4
temp DS 6
counter DS 1
ascii_dist DS 12
arctan DS 4
sin DS 4
cos DS 4
x_1 DS 4
y DS 4
z DS 4

            ORG    0C000H
		 
;****************************COORDINATES****************************** 
LONGITUDE_1: FCB '0.00000',0;  
LATITUDE_1:  FCB '90.00000',0;
LONGITUDE_2: FCB '0.00000',0;
LATITUDE_2:  FCB '0.00000',0;

            
START:	
			CLRA 
            STA  	SOPT1  ; Disenable COP
            LDHX   #RAMEnd+1  ; initialize the stack pointer
            TXS

main:
		JSR fetch_coordinates 
		JSR calc_delta_lat ;Phi
		JSR calc_delta_long ;Lamda
		JSR calc_media_lat
		JSR calc_trig
		JSR calc_magnitude ; Magnitude/0.60725
		;JSR calc_dist
		JSR hex_2ascii
		JMP main
		
;*********************************TRIGONOMETRIC FUCTION CALCULATION***********************************
calc_trig:
		CLRA 
		STA counter ; initializing counter
		STA y+0 ; initial y
		STA y+1
		STA y+2
		STA y+3
		STA x_1+0 ; initial x
		STA x_1+1
		LDA #0EDH
		STA x_1+2
		LDA #35H
		STA x_1+3
		LDA media_lat+0 ;initial z
		STA z+0
		LDA media_lat+1
		STA z+1
		LDA media_lat+2
		STA z+2
		LDA media_lat+3
		STA z+3
		BCLR Z,signos  ; initial sign of z
		
rsta:		BRSET Z,signos,PT1 ;
PT2:
;**********************************************CALC  Yi	
	LDA x_1 ; tmp = x
	STA tmp+0
	LDA x_1+1
	STA tmp+1
	LDA x_1+2
	STA tmp+2
	LDA x_1+3
	STA tmp+3	
	LDA counter
rot11:	CBEQA #0,cal_mag11	
	LSR tmp+0 ; x/2
	ROR tmp+1
	ROR tmp+2
	ROR tmp+3
	DECA 
	BRA rot11
PT1: JMP PT11	
cal_mag11:	 			 			
	LDA tmp+0 ; x/2 > y
	CMP y+0
	BEQ cmy21 
	BHI xgy ; x/2 > y
	JMP ygx
cmy21:LDA tmp+1
	CMP y+1
	BEQ cmy31       
	BHI xgy ;  x/2 > y
	BRA ygx ;  x/2 < y
cmy31:LDA tmp+2
	CMP y+2
	BEQ cmy41       
	BHI xgy;  x/2 > y
	BRA ygx ;  x/2 < y	
cmy41:LDA tmp+3
	CMP y+3
	BEQ xgy ;  x/2 = y	
	BHI xgy ;  x/2 > y
	BRA ygx ;  x/2 < y	
	 			
xgy:
	;magnitud/2 - tmp_2
	LDA y+0
	STA tmp_1+0
	STA tmp_3+0
	LDA y+1
	STA tmp_1+1
	STA tmp_3+1
	LDA y+2
	STA tmp_1+2
	STA tmp_3+2
	LDA y+3
	STA tmp_1+3
	STA tmp_3+3
	JSR sub_32bit 
	LDA tmp+0 ; load new data  
	STA y+0
	LDA tmp+1
	STA y+1
	LDA tmp+2
	STA y+2
	LDA tmp+3
	STA y+3
	JSR xxcal 
	JMP new_z
	
ygx:
	;y - x/2 
	LDA tmp+0  
	STA tmp_1+0
	LDA tmp+1
	STA tmp_1+1
	LDA tmp+2
	STA tmp_1+2
	LDA tmp+3
	STA tmp_1+3
	
	LDA y+0 
	STA tmp+0
	STA tmp_3+0
	LDA y+1
	STA tmp+1
	STA tmp_3+1
	LDA y+2
	STA tmp+2
	STA tmp_3+2
	LDA y+3
	STA tmp+3	
	STA tmp_3+3 			
	JSR sub_32bit	
	LDA tmp+0 ; load new data  
	STA y+0
	LDA tmp+1
	STA y+1
	LDA tmp+2
	STA y+2
	LDA tmp+3
	STA y+3
	JSR xxcal
	JMP new_z
	
PT11:
	LDA y ; tmp = x
	STA tmp+0
	LDA y+1
	STA tmp+1
	LDA y+2
	STA tmp+2
	LDA y+3
	STA tmp+3	
	LDA counter
rot111:	CBEQA #0,cal_mag111	
	LSR tmp+0 ; x/2
	ROR tmp+1
	ROR tmp+2
	ROR tmp+3
	DECA 
	BRA rot111

cal_mag111:	 			 			
	LDA tmp+0 ; x/2 > y
	CMP x_1+0
	BEQ cmy211 
	BHI xgy1 ; x/2 > y
	JMP ygx1
cmy211:LDA tmp+1
	CMP x_1+1
	BEQ cmy311       
	BHI xgy1 ;  x/2 > y
	BRA ygx1 ;  x/2 < y
cmy311:LDA tmp+2
	CMP x_1+2
	BEQ cmy411       
	BHI xgy1;  x/2 > y
	BRA ygx1 ;  x/2 < y	
cmy411:LDA tmp+3
	CMP x_1+3
	BEQ xgy1 ;  x/2 = y	
	BHI xgy1 ;  x/2 > y
	BRA ygx1 ;  x/2 < y	
	 			
xgy1:
	;magnitud/2 - tmp_2
	LDA x_1+0
	STA tmp_1+0
	STA tmp_3+0
	LDA x_1+1
	STA tmp_1+1
	STA tmp_3+1
	LDA x_1+2
	STA tmp_1+2
	STA tmp_3+2
	LDA x_1+3
	STA tmp_1+3
	STA tmp_3+3
	JSR sub_32bit 
	LDA tmp+0 ; load new data  
	STA x_1+0
	LDA tmp+1
	STA x_1+1
	LDA tmp+2
	STA x_1+2
	LDA tmp+3
	STA x_1+3
	JSR xx1cal 
	BRA new_z
	
ygx1:
	;y - x/2 
	LDA tmp+0  
	STA tmp_1+0
	LDA tmp+1
	STA tmp_1+1
	LDA tmp+2
	STA tmp_1+2
	LDA tmp+3
	STA tmp_1+3
	
	LDA x_1+0 
	STA tmp+0
	STA tmp_3+0
	LDA x_1+1
	STA tmp+1
	STA tmp_3+1
	LDA x_1+2
	STA tmp+2
	STA tmp_3+2
	LDA x_1+3
	STA tmp+3	
	STA tmp_3+3 			
	JSR sub_32bit	
	LDA tmp+0 ; load new data  
	STA x_1+0
	LDA tmp+1
	STA x_1+1
	LDA tmp+2
	STA x_1+2
	LDA tmp+3
	STA x_1+3
	JSR xx1cal
	BRA new_z

new_z:
	JSR OBTTAN
	JSR CALCZ
	INC counter
	LDA counter
	CMP #23
	BEQ	aoeu
	JMP rsta 
aoeu: JMP FIN	
CALCZ: ; SUBROUTINE TO SUBSTRACT Z TO ARCTAN
calsz:	 			 			
	LDA z+0 ; z > arctan
	CMP arctan+0 
	BEQ cz1 
	BHI zma ; 
	JMP amz
cz1:LDA z+1
	CMP arctan+1
	BEQ cz2       
	BHI zma ; 
	BRA amz ; 
cz2:LDA z+2
	CMP arctan+2
	BEQ cz3       
	BHI zma;  
	BRA amz ; 	
cz3:LDA z+3
	CMP arctan+3
	BEQ zma ; 	
	BHI zma ;  
	BRA amz ;  	

zma:
	;BCLR Z,signos
	LDA arctan+0  
	STA tmp_1+0
	LDA arctan+1
	STA tmp_1+1
	LDA arctan+2
	STA tmp_1+2
	LDA arctan+3
	STA tmp_1+3

	LDA z+0 
	STA tmp+0
	LDA z+1
	STA tmp+1
	LDA z+2
	STA tmp+2
	LDA z+3
	STA tmp+3	
	JSR sub_32bit	
	LDA tmp+0 ; load new data  
	STA z+0
	LDA tmp+1
	STA z+1
	LDA tmp+2
	STA z+2
	LDA tmp+3
	STA z+3
	RTS
amz:
	COM signos
	
	LDA arctan+0  
	STA tmp+0
	LDA arctan+1
	STA tmp+1
	LDA arctan+2
	STA tmp+2
	LDA arctan+3
	STA tmp+3

	LDA z+0 
	STA tmp_1+0
	LDA z+1
	STA tmp_1+1
	LDA z+2
	STA tmp_1+2
	LDA z+3
	STA tmp_1+3	
	JSR sub_32bit	
	LDA tmp+0 ; load new data  
	STA z+0
	LDA tmp+1
	STA z+1
	LDA tmp+2
	STA z+2
	LDA tmp+3
	STA z+3
	RTS
		
FIN:LDA x_1+0
	STA cos+0
	LDA x_1+1
	STA cos+1
	LDA x_1+2
	STA cos+2
	LDA x_1+3
	STA cos+3 
	LDA y+0
	STA sin+0
	LDA y+1
	STA sin+1
	LDA y+2
	STA sin+2
	LDA y+3
	STA sin+3 
	RTS	
	
xxcal:		; x calc 
	LDA tmp_3+0 
	STA tmp+0
	LDA tmp_3+1
	STA tmp+1
	LDA tmp_3+2
	STA tmp+2
	LDA tmp_3+3
	STA tmp+3
	
	LDA counter
roty:	CBEQA #0,here2
	LSR tmp+0 ; x/2
	ROR tmp+1
	ROR tmp+2
	ROR tmp+3
	DECA 
	BRA roty
here2:	
	LDA x_1+0 
	STA tmp_1+0
	LDA x_1+1
	STA tmp_1+1
	LDA x_1+2
	STA tmp_1+2
	LDA x_1+3
	STA tmp_1+3
	
	JSR add_32bit
	LDA tmp+0 ; load new data  
	STA x_1+0
	LDA tmp+1
	STA x_1+1
	LDA tmp+2
	STA x_1+2
	LDA tmp+3
	STA x_1+3	
	RTS	
xx1cal:		; x calc 
	LDA tmp_3+0 
	STA tmp+0
	LDA tmp_3+1
	STA tmp+1
	LDA tmp_3+2
	STA tmp+2
	LDA tmp_3+3
	STA tmp+3
	
	LDA counter
rotx1:	CBEQA #0,here1	
	LSR tmp+0 ; x/2
	ROR tmp+1
	ROR tmp+2
	ROR tmp+3
	DECA 
	BRA rotx1
here1:		
	LDA y+0 
	STA tmp_1+0
	LDA y+1
	STA tmp_1+1
	LDA y+2
	STA tmp_1+2
	LDA y+3
	STA tmp_1+3
	
	JSR add_32bit
	LDA tmp+0 ; load new data  
	STA y+0
	LDA tmp+1
	STA y+1
	LDA tmp+2
	STA y+2
	LDA tmp+3
	STA y+3	
	RTS				
				
;****************************************to obtain arctan		
OBTTAN:		LDHX #ARCTAN ; Load initial direction of ARCTAN
    	LDA counter
		STA tmp_2 ;counter=tmp
		
t10:	LDA tmp_2
		CMP #00
		BEQ loadtan ;0=?
		
ti1:	AIX #1
		LDA ,X ; A=mem(hx)
		CMP #00 ;
		BHI ti1
		DEC tmp_2
		AIX #1
		BRA t10 
		
loadtan:	JSR fetch_xy     	
		LDA tmp_1+0			
		STA arctan+0
		LDA tmp_1+1
		STA arctan+1
		LDA tmp_1+2
		STA arctan+2
		LDA tmp_1+3
		STA arctan+3
		RTS		
	
;*********************************HEX TO ASCII CON****************************************************
hex_2ascii:
	LDA magnitud+0 ; BYTE 0
	STA tmp+0
	JSR conversion
	LDA tmp+1
	STA ascii_dist+0
	LDA tmp+0
	STA ascii_dist+1
	
	LDA magnitud+1 ; BYTE 1
	STA tmp+0
	JSR conversion
	LDA tmp+1
	STA ascii_dist+2
	LDA tmp+0
	STA ascii_dist+3
	
	LDA magnitud+2 ; BYTE 2
	STA tmp+0
	JSR conversion
	LDA tmp+1
	STA ascii_dist+4
	LDA tmp+0
	STA ascii_dist+5
	
	LDA magnitud+3 ; BYTE 3
	STA tmp+0
	JSR conversion
	LDA tmp+1
	STA ascii_dist+6
	LDA tmp+0
	STA ascii_dist+7	

	LDA magnitud+4 ; BYTE 4
	STA tmp+0
	JSR conversion
	LDA tmp+1
	STA ascii_dist+8
	LDA tmp+0
	STA ascii_dist+9
	
	LDA magnitud+5 ; BYTE 5
	STA tmp+0
	JSR conversion
	LDA tmp+1
	STA ascii_dist+10
	LDA tmp+0
	STA ascii_dist+11			
	RTS

conversion:
	LDA tmp+0 ; High nibble
	NSA 
	AND #0FH
	CMP #9
	BHI ascii_letter
	ORA #30H ; to ascii 
	STA tmp+1
	BRA low_nibble
ascii_letter:
	SUB #9
	ORA #60H
	STA tmp+1
low_nibble:
	LDA tmp+0 ; High nibble
	AND #0FH
	CMP #9
	BHI ascii_letter1
	ORA #30H ; to ascii 
	STA tmp+0
	RTS
ascii_letter1:
	SUB #9
	ORA #60H
	STA tmp+0
	RTS
	

;**********************************MEDIA LAT CALC*****************************************************
calc_media_lat:
	
	LDA latitude1+0
	STA tmp+0
	LDA latitude1+1
	STA tmp+1
	LDA latitude1+2
	STA tmp+2
	LDA latitude1+3
	STA tmp+3
	
	LDA latitude2+0
	STA tmp_1+0
	LDA latitude2+1
	STA tmp_1+1
	LDA latitude2+2
	STA tmp_1+2
	LDA latitude2+3
	STA tmp_1+3
	
	BRCLR LAT1,signos,tla1
	BRSET LAT1,signos,tla2
tla1:	BRCLR LAT2,signos,add_lat
	BRA sub_lat
tla2: BRSET LAT2,signos,add_lat
	BRA sub_lat	

add_lat:	
	JSR add_32bit
	BRA rolat
	
sub_lat:

cal_mlat1:	 			 			
	LDA tmp+0 ;  
	CMP tmp_1+0
	BEQ cmlat2 
	BHI calcmlat ; LAT1 > LAT2
	JMP s1
cmlat2:LDA tmp+1
	CMP tmp_1+1
	BEQ cmlat3       
	BHI calcmlat ;  LAT1 > LAT2
	BRA s1 ;  LAT1 < LAT2
cmlat3:LDA tmp+2
	CMP tmp_1+2
	BEQ cmlat4       
	BHI calcmlat ;   LAT1 > LAT2
	BRA s1 ;  LAT1 < LAT2	
cmlat4:LDA tmp+3
	CMP tmp_1+3
	BEQ calcmlat ;  LAT1 = LAT2	
	BHI calcmlat ;   LAT1 > LAT2
	BRA s1 ;   LAT1 < LAT2	

s1:
	LDA latitude2+0
	STA tmp+0
	LDA latitude2+1
	STA tmp+1
	LDA latitude2+2
	STA tmp+2
	LDA latitude2+3
	STA tmp+3
	
	LDA latitude1+0
	STA tmp_1+0
	LDA latitude1+1
	STA tmp_1+1
	LDA latitude1+2
	STA tmp_1+2
	LDA latitude1+3
	STA tmp_1+3	

calcmlat:	
	JSR sub_32bit
		
rolat:	LSR tmp+0 ; phi_m/2
	ROR tmp+1
	ROR tmp+2
	ROR tmp+3
	
	LDA tmp+0 ;load new phi_/m/2
	STA media_lat+0
	LDA tmp+1
	STA media_lat+1
	LDA tmp+2
	STA media_lat+2
	LDA tmp+3
	STA media_lat+3
	RTS
;**********************************MAGNITUD VECTOR SUBROUTINE******************************************
;X0=magnitud <=delta_lat ; Y0=tmp_2 <= delta_long
calc_magnitude:
	LDA delta_lat+0 
	STA magnitud+0 ; Initializing X
	LDA delta_lat+1
	STA magnitud+1
	LDA delta_lat+2
	STA magnitud+2
	LDA delta_lat+3
	STA magnitud+3
	
	LDA delta_long+0 
	STA tmp_2+0 ; Initializing Y
	LDA delta_long+1
	STA tmp_2+1
	LDA delta_long+2
	STA tmp_2+2
	LDA delta_long+3
	STA tmp_2+3
	
	CLRA ; Initializing i
	STA counter 
	
cycle:	JSR calc_xi ; calculate new x_i
	LDA tmp+0 ; Load new x_i 
	STA magnitud+0
	LDA tmp+1
	STA magnitud+1
	LDA tmp+2
	STA magnitud+2
	LDA tmp+3
	STA magnitud+3
		
	JSR calc_yi ; Calculate new y_i
	LDA tmp+0 ; Load new y_i 
	STA tmp_2+0
	LDA tmp+1
	STA tmp_2+1
	LDA tmp+2
	STA tmp_2+2
	LDA tmp+3
	STA tmp_2+3
	
	INC counter
	LDA #32
	CBEQ counter,xyfin
	BRA cycle
xyfin:
		
	LDA magnitud+3
	STA magnitud+5
	LDA magnitud+2
	STA magnitud+4
	LDA magnitud+1
	STA magnitud+3
	LDA magnitud+0
	STA magnitud+2
	CLRA 
	STA magnitud+0
	STA magnitud+1
	JSR mult32_16 	
	LDA temp+5
	STA magnitud+5
	LDA temp+4
	STA magnitud+4
	LDA temp+3
	STA magnitud+3
	LDA temp+2
	STA magnitud+2
	LDA temp+1
	STA magnitud+1
	LDA temp+0
	STA magnitud+0
	RTS
;*****************************************multiplication subroutine***********
mult32_16:
	   CLRA 
	   STA temp+5 ; initialization 
	   STA temp+4
	   STA temp+3
	   STA temp+2
	   STA temp+1
	   STA temp+0
	   
       LDX magnitud+5 
	   LDA #35H				
	   MUL  			;byte 6
	   STA temp+5
	   TXA  ; X=A
	   STA temp+4
	   
	   LDX magnitud+4 ; byte 5 
	   LDA #35H
	   MUL ; tmp2
	   ADD temp+4
	   STA temp+4
	   TXA ; A=X
	   ADC temp+3 ; add carry
	   STA temp+3
	   CLRA 
	   ADC temp+2 ; add carry
	   STA temp+2
	   CLRA 
	   ADC temp+1 ; add carry
	   STA temp+1
	   CLRA 
	   ADC temp+0 ; add carry
	   STA temp+0
	   	   			   
	   LDX magnitud+3 ; byte 4
	   LDA #35H
	   MUL 
       ADD temp+3
	   STA temp+3
	   TXA ; A=X
	   ADC temp+2 ; add carry
	   STA temp+2
	   CLRA 
	   ADC temp+1 ; add carry
	   STA temp+1
	   CLRA 
	   ADC temp+0 ; add carry
	   STA temp+0

	   LDX magnitud+2 ; byte 3
	   LDA #35H
	   MUL 
       ADD temp+2
	   STA temp+2
	   TXA ; A=X
	   ADC temp+1 ; add carry
	   STA temp+1
	   CLRA 
	   ADC temp+0 ; add carry
	   STA temp+0
;;;;mul f
	   LDX magnitud+5 ; byte 6 
	   LDA #0EDH
	   MUL ; tmp2
	   ADD temp+4
	   STA temp+4
	   TXA ; A=X
	   ADC temp+3 ; add carry
	   STA temp+3
	   CLRA 
	   ADC temp+2 ; add carry
	   STA temp+2
	   CLRA 
	   ADC temp+1 ; add carry
	   STA temp+1
	   CLRA 
	   ADC temp+0 ; add carry
	   STA temp+0

	   LDX magnitud+4 ; byte 5 
	   LDA #0EDH
	   MUL ; tmp2
	   ADD temp+3
	   STA temp+3
	   TXA ; A=X
	   ADC temp+2 ; add carry
	   STA temp+2
	   CLRA 
	   ADC temp+1 ; add carry
	   STA temp+1
	   CLRA 
	   ADC temp+0 ; add carry
	   STA temp+0
	   
	   LDX magnitud+3 ; byte 4 
	   LDA #0EDH
	   MUL ; tmp2
	   ADD temp+2
	   STA temp+2
	   TXA ; A=X
	   ADC temp+1 ; add carry
	   STA temp+1
	   CLRA 
	   ADC temp+0 ; add carry
	   STA temp+0
	   
	   LDX magnitud+2 ; byte 4 
	   LDA #0EDH
	   MUL ; tmp2
	   ADD temp+1
	   STA temp+1
	   TXA ; A=X
	   ADC temp+0 ; add carry
	   STA temp+0	      
	   RTS

;*******************************************Xi SUBROUTINE**********************	
calc_xi:
	LDA tmp_2+0 ; tmp = magnitud 
	STA tmp+0
	LDA tmp_2+1
	STA tmp+1
	LDA tmp_2+2
	STA tmp+2
	LDA tmp_2+3
	STA tmp+3	
	
	LDA counter
rot:	CBEQA #0,cal_mag
	LSR tmp+0 ; yi/2
	ROR tmp+1
	ROR tmp+2
	ROR tmp+3
	DECA 
	BRA rot
		
cal_mag:	LDA magnitud+0 ; tmp = magnitud 
	STA tmp_1+0
	STA tmp_3+0
	LDA magnitud+1
	STA tmp_1+1
	STA tmp_3+1 
	LDA magnitud+2
	STA tmp_1+2
	STA tmp_3+2
	LDA magnitud+3
	STA tmp_1+3
	STA tmp_3+3
	JSR add_32bit ; add the numbehs 
	RTS

;**********************************************CALC  Yi SUBROUTINE	
calc_yi:	
	LDA tmp_3+0 ; tmp = magnitud 
	STA tmp+0
	LDA tmp_3+1
	STA tmp+1
	LDA tmp_3+2
	STA tmp+2
	LDA tmp_3+3
	STA tmp+3	
	
	LDA counter
rot1:	CBEQA #0,cal_mag1	
	LSR tmp+0 ; magnitud /2
	ROR tmp+1
	ROR tmp+2
	ROR tmp+3
	DECA 
	BRA rot1
	
cal_mag1:	 			 			
	LDA tmp+0 ; Magnitud/2 > tmp_2
	CMP tmp_2+0
	BEQ cmy2 
	BHI magngtmp2 ; Magnitud/2 > tmp_2
	JMP tmp2gmagn
cmy2:LDA tmp+1
	CMP tmp_2+1
	BEQ cmy3       
	BHI magngtmp2 ;  Magnitud/2 > tmp_2
	BRA tmp2gmagn ;  Magnitud/2 < tmp_2
cmy3:LDA tmp+2
	CMP tmp_2+2
	BEQ cmy4       
	BHI magngtmp2 ;  Magnitud/2 > tmp_2
	BRA tmp2gmagn ;  Magnitud/2 < tmp_2	
cmy4:LDA tmp+3
	CMP tmp_2+3
	BEQ magngtmp2 ;  Magnitud/2 = tmp_2	
	BHI magngtmp2 ;  Magnitud/2 > tmp_2
	BRA tmp2gmagn ;  Magnitud/2 < tmp_2	
	 			
magngtmp2:
	;magnitud/2 - tmp_2
	LDA tmp_2+0
	STA tmp_1+0
	LDA tmp_2+1
	STA tmp_1+1
	LDA tmp_2+2
	STA tmp_1+2
	LDA tmp_2+3
	STA tmp_1+3
	JSR sub_32bit ; substraction magnitud/2 - tmp 2
	RTS
	
tmp2gmagn:
	;tmp_2 - magnitud/2 
	LDA tmp+0  ;tmp_1 = magnitud/2
	STA tmp_1+0
	LDA tmp+1
	STA tmp_1+1
	LDA tmp+2
	STA tmp_1+2
	LDA tmp+3
	STA tmp_1+3
	
	LDA tmp_2+0 ;tmp = tmp_2
	STA tmp+0
	LDA tmp_2+1
	STA tmp+1
	LDA tmp_2+2
	STA tmp+2
	LDA tmp_2+3
	STA tmp+3	 			
	
	JSR sub_32bit	
	RTS
		
;**********************************DELTA LONGITUDES SUBROUTINE*****************************************
calc_delta_long:
	LDA longitude1+0
	CMP longitude2+0
	BEQ cmo2 
	BHI long1glong2 ; lat1 > lat2
	BRA long2glong1
cmo2:LDA longitude1+1
	CMP longitude2+1
	BEQ cmo3       
	BHI long1glong2 ; lat1 > lat2
	BRA long2glong1 ; lat2 > lat1
cmo3:LDA longitude1+2
	CMP longitude2+2
	BEQ cmo4       
	BHI long1glong2 ; lat1 > lat2
	BRA long2glong1 ; lat2 > lat1	
cmo4:LDA longitude1+3
	CMP longitude2+3
	BEQ long1glong2 ; lat1=lat2
	BHI long1glong2 ; lat1 > lat2
	BRA long2glong1 ; lat2 > lat1	 
	
;tmp=lat1 and tmp_1=lat2
long1glong2:	 
	LDA longitude1+0 ;Latitude 1 to tmp
	STA tmp+0
	LDA longitude1+1
	STA tmp+1
	LDA longitude1+2
	STA tmp+2
	LDA longitude1+3
	STA tmp+3
	
	LDA longitude2+0 ;Latitude 2 to tmp_1 
	STA tmp_1+0
	LDA longitude2+1
	STA tmp_1+1
	LDA longitude2+2
	STA tmp_1+2
	LDA longitude2+3
	STA tmp_1+3
	JSR operationlon
	BRA load_delta_long

;tmp=lat2 and tmp_1=lat1
long2glong1:	 
	LDA longitude2+0 ;Latitude 1 to tmp
	STA tmp+0
	LDA longitude2+1
	STA tmp+1
	LDA longitude2+2
	STA tmp+2
	LDA longitude2+3
	STA tmp+3
	
	LDA longitude1+0 ;Latitude 2 to tmp_1 
	STA tmp_1+0
	LDA longitude1+1
	STA tmp_1+1
	LDA longitude1+2
	STA tmp_1+2
	LDA longitude1+3
	STA tmp_1+3
	JSR operationlon
	BRA load_delta_long
	
load_delta_long: ; Subroutine to charge the result in the final register
	LDA tmp+0
	STA delta_long+0
	LDA tmp+1
	STA delta_long+1
	LDA tmp+2
	STA delta_long+2
	LDA tmp+3
	STA delta_long+3
	RTS	
	

;**********************************DELTA LATITUDES SUBROUTINE******************************************
calc_delta_lat:
	LDA latitude1+0
	CMP latitude2+0
	BEQ cm2 
	BHI lat1glat2 ; lat1 > lat2
	BRA lat2glat1
cm2:LDA latitude1+1
	CMP latitude2+1
	BEQ cm3       
	BHI lat1glat2 ; lat1 > lat2
	BRA lat2glat1 ; lat2 < lat1
cm3:LDA latitude1+2
	CMP latitude2+2
	BEQ cm4       
	BHI lat1glat2 ; lat1 > lat2
	BRA lat2glat1 ; lat2 < lat1	
cm4:LDA latitude1+3
	CMP latitude2+3
	BEQ lat1glat2 ; lat1=lat2
	BHI lat1glat2 ; lat1 > lat2
	BRA lat2glat1 ; lat2 < lat1	 
	
;tmp=lat1 and tmp_1=lat2
lat1glat2:	 
	LDA latitude1+0 ;Latitude 1 to tmp
	STA tmp+0
	LDA latitude1+1
	STA tmp+1
	LDA latitude1+2
	STA tmp+2
	LDA latitude1+3
	STA tmp+3
	
	LDA latitude2+0 ;Latitude 2 to tmp_1 
	STA tmp_1+0
	LDA latitude2+1
	STA tmp_1+1
	LDA latitude2+2
	STA tmp_1+2
	LDA latitude2+3
	STA tmp_1+3
	JSR operation
	BRA load_delta_lat

;tmp=lat2 and tmp_1=lat1
lat2glat1:	 
	LDA latitude2+0 ;Latitude 1 to tmp
	STA tmp+0
	LDA latitude2+1
	STA tmp+1
	LDA latitude2+2
	STA tmp+2
	LDA latitude2+3
	STA tmp+3
	
	LDA latitude1+0 ;Latitude 2 to tmp_1 
	STA tmp_1+0
	LDA latitude1+1
	STA tmp_1+1
	LDA latitude1+2
	STA tmp_1+2
	LDA latitude1+3
	STA tmp_1+3
	JSR operation
	BRA load_delta_lat
	
load_delta_lat: ; Subroutine to charge the result in the final register
	LDA tmp+0
	STA delta_lat+0
	LDA tmp+1
	STA delta_lat+1
	LDA tmp+2
	STA delta_lat+2
	LDA tmp+3
	STA delta_lat+3
	RTS	
operation:	;signo(LAT1) = signo(LAT2)
	BRCLR LAT1,signos,t1
	BRSET LAT1,signos,t2
t1:	BRCLR LAT2,signos,sub_32bit
	BRA add_32bit
t2: BRSET LAT2,signos,sub_32bit
	BRA add_32bit	
	
operationlon:	;signo(LAT1) = signo(LAT2)
	BRCLR LONG1,signos,t1l
	BRSET LONG1,signos,t2l
t1l: BRCLR LONG2,signos,sub_32bit
	JMP add_32bit
t2l: BRSET LONG2,signos,sub_32bit
	JMP add_32bit		
;****************************ADDITION AND SUBTRACTION (32bit) SUBROUTINES*********************	
add_32bit: ; tmp + tmp_1
	LDA tmp+3
	ADD tmp_1+3
	STA tmp+3
	LDA tmp+2
	ADC tmp_1+2		
	STA tmp+2
	LDA tmp+1
	ADC tmp_1+1		
	STA tmp+1
	LDA tmp+0
	ADC tmp_1+0		
	STA tmp+0	
	RTS
sub_32bit: ; tmp - tmp_1
	LDA tmp+3
	SUB tmp_1+3
	STA tmp+3
	LDA tmp+2
	SBC tmp_1+2		
	STA tmp+2
	LDA tmp+1
	SBC tmp_1+1		
	STA tmp+1
	LDA tmp+0
	SBC tmp_1+0		
	STA tmp+0	
	RTS
	
;*************SUBROUTINE TO OBTAIN COORDINATES*********************************************************  
fetch_coordinates:		
		CLRA 
		STA signos
		
		LDHX #LONGITUDE_1   ; Load direction of LONGITUDE_1
		JSR fetch_xy     	; obtaining data 
		LDA tmp_1+0			; charging data
		STA longitude1+0
		LDA tmp_1+1
		STA longitude1+1
		LDA tmp_1+2
		STA longitude1+2
		LDA tmp_1+3
		STA longitude1+3
		BRCLR 7,signos,zl1 ; setting sing of longitude 1
		BSET LONG1,signos
	zl1: BRSET 7,signos,ol1
		BCLR LONG1,signos
	ol1:	
		LDHX #LATITUDE_1    ; Load direction of LATITUDE_1
		JSR fetch_xy     	; obtaining data 
		LDA tmp_1+0			; charging data
		STA latitude1+0
		LDA tmp_1+1
		STA latitude1+1
		LDA tmp_1+2
		STA latitude1+2
		LDA tmp_1+3
		STA latitude1+3
		BRCLR 7,signos,zla1 ; setting sing of latitude 1
		BSET LAT1,signos
	zla1: BRSET 7,signos,ola1
		BCLR LAT1,signos
	ola1:		
		
		LDHX #LONGITUDE_2   ; Load direction of LONGITUDE_2
		JSR fetch_xy     	; obtaining data 
		LDA tmp_1+0			; charging data
		STA longitude2+0
		LDA tmp_1+1
		STA longitude2+1
		LDA tmp_1+2
		STA longitude2+2
		LDA tmp_1+3
		STA longitude2+3
		BRCLR 7,signos,zl2 ; setting sing of longitude 2
		BSET LONG2,signos
	zl2: BRSET 7,signos,ol2
		BCLR LONG2,signos
	ol2:		

		LDHX #LATITUDE_2    ; Load direction of LATITUDE_2
		JSR fetch_xy     	; obtaining data 
		LDA tmp_1+0			; charging data
		STA latitude2+0
		LDA tmp_1+1
		STA latitude2+1
		LDA tmp_1+2
		STA latitude2+2
		LDA tmp_1+3
		STA latitude2+3	
		BRCLR 7,signos,zla2 ; setting sing of latitude 2
		BSET LAT2,signos
	zla2: BRSET 7,signos,ola2
		BCLR LAT2,signos
	ola2:			
        RTS
            
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
		;BCLR 7,signos ;clear signos
		LDA ,X ; dereferencing pointer
 		CBEQA #'-',Negative ; if is negative branch
Positive:  BCLR 7,signos ; it has been detected a positive number
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
Fin:   ;JMP Fin	   
	   RTS ; return from subroutine 



;*******************************ARCTAN********************************
ARCTAN: FCB '45.00000',0,'26.56505',0,'14.03624',0,'7.12501',0,'3.57635',0,'1.78991',0,'0.89517',0,'0.44761',0
		FCB '0.22381',0,'0.11191',0,'0.05595',0,'0.02798',0,'0.01398',0,'0.00699',0,'0.00350',0,'0.00175',0
		FCB '0.00087',0,'0.00044',0,'0.00022',0,'0.00011',0,'0.00005',0,'0.00003',0,'0.00001',0 
		;22 datos
			
            ORG	0FFFEH
			FCB START			; Reset
