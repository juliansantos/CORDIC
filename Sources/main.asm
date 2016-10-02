           INCLUDE 'MC9S08JM16.inc'
LONG1 EQU 0
LONG2 EQU 1
LAT1 EQU 2
LAT2 EQU 3
FLAGADD EQU 4 ; Add or Substraction
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
tmp	DS 4
tmp_1	DS 4

            ORG    0C000H
START:	
			CLRA 
            STA  	SOPT1  ; Disenable COP
            LDHX   #RAMEnd+1  ; initialize the stack pointer
            TXS

main:
		JSR fetch_coordinates
		JSR calc_delta_lat
		JSR calc_delta_long
;		LDA #5
		;STA signos
		;CLRA  
		;CMP signos

		;BGE main
		;nop
		;nop
		JMP main


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

		 
;****************************COORDINATES****************************** 
LONGITUDE_1: FCB '50.58978',0;  
LATITUDE_1:  FCB '157.56321',0;
LONGITUDE_2: FCB '80.99999',0;
LATITUDE_2:  FCB '179.15974',0;

;*******************************ARCTAN********************************
ARCTAN: FCB '45.00000',0,'26.56505',0,'14.03624',0,'7.12501',0
		FCB '3.57633',0,'1.78991',0,'0.89517',0,'0.44761',0
		FCB '0.22381',0,'0.11190',0,'0.05595',0,'0.02797',0
		FCB '0.01398',0,'0.00699',0,'0.003497',0,'0.00174',0 
			
            ORG	0FFFEH
			FCB START			; Reset
