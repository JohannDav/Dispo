	/*LO QUE TENEMOS EN EL PUERTO A LO VISUALIZAMOS EN EL PUERTO B*/
    PROCESSOR 18F4550 ; inicio 
    ;CONFIG1L dir 300000h 		20
		CONFIG	PLLDIV=1	 	; 
		CONFIG	CPUDIV=OSC1_PLL2 ;CUANDO SE USA 	
		CONFIG	USBDIV=2

		;CONFIG1H dir 300001h	   08
		CONFIG	FOSC=INTOSCIO_EC	;OSCILADOR INTERNO, RA6 COMO PIN, USB USA OSC EC
		CONFIG	FCMEN=OFF       ;DESHABILITDO EL MONITOREO DEL RELOJ
		CONFIG	IESO=OFF
		;CONFIG2L DIR 300002H	   	38
		CONFIG	PWRT=ON         ;PWRT HABILITADO
		CONFIG  BOR=OFF		 	;BROWN OUT RESET DESHABILITADO
		CONFIG BORV=3			;RESET AL MINIMO VOLTAJE NO UTILZADO EN ESTE CASO
		CONFIG	VREGEN=ON	 	;REULADOR DE USB ENCENDIDO
		;CONFIG2H DIR 300003H	   	1E
		CONFIG	WDT=OFF         ;WACH DOG DESHABILITADO
		CONFIG WDTPS=32768      ;TIMER DEL WATCHDOG 
		;CONFIG3H DIR 300005H 	   	81
		CONFIG	CCP2MX=ON	 	;CCP2 MULTIPLEXADAS CON RC1	
		CONFIG	PBADEN=OFF      ;PUERTO B PINES DEL 0 AL 4 ENTRADAS DIGITALES
		CONFIG  LPT1OSC=OFF	 	;TIMER1 CONFIURADO PARA OPERAR EN BAJA POTENCIA
		CONFIG	MCLRE=ON        ;MASTER CLEAR HABILITADO
		;CONFIG4L DIR 300006H	   	81
		CONFIG	STVREN=ON	 	;SI EL STACK SE LLENA CAUSE RESET		
		CONFIG	LVP=OFF		 	;PROGRAMACIÃƒÂ’N EN BAJO VOLTAJE APAGADO
		CONFIG	ICPRT=OFF	 	;REGISTRO ICPORT DESHABILITADO
		CONFIG	XINST=OFF  		;SET DE EXTENCION DE INSTRUCCIONES Y DIRECCIONAMIENTO INDEXADO DESHABILITADO
		;CONFIG5L DIR 300008H 		0F
		CONFIG	CP0=OFF		 	;LOS BLOQUES DEL CÃƒÂ’DIGO DE PROGRAMA
		CONFIG	CP1=OFF         ;NO ESTAN PROTEGIDOS
		CONFIG	CP2=OFF		 
		CONFIG	CP3=OFF
		;CONFIG5H DR 300009H  		80
		CONFIG	CPB=ON		 	;SECTOR BOOT ESTA PROTEGIDO
		CONFIG	CPD=OFF		 	;EEPROM N PROTEGIDA
		;CONFIG6L DIR 30000AH 		0F
		CONFIG	 WRT0=OFF	 	;BLOQUES NO PROTEGIDOS CONTRA ESCRITURA
		CONFIG	 WRT1=OFF
		CONFIG	 WRT2=OFF
		CONFIG	 WRT3=OFF

		;CONFIG6H DIR 30000BH		A0
		CONFIG	 WRTC=OFF	 	;CONFIGURACION DE REGISTROS NO PROTEGIDO
		CONFIG	 WRTB=ON	 	;BLOQUE BOOTEBLE NO PROTEGIDO
		CONFIG	 WRTD=OFF	 	;EEPROMDE DATOS NO PROTGIDA

		;CONFIG7L DIR 30000CH		0F
		CONFIG	 EBTR0=OFF	 	;TABLAS DE LETURA NO PROTEGIDAS
		CONFIG	 EBTR1=OFF
		CONFIG	 EBTR2=OFF
		CONFIG	 EBTR3=OFF

		;CONFIG7H DIR 30000DH		40
		CONFIG	 EBTRB=OFF	 	;TABLAS NO PROTEGIDAS
#include<xc.inc>
				/* declarar variables*/
				;TODAS LAS ETIQUETAS VAN CON :
DECLARAR_VARIABLES:
PSECT 	udata_acs ;SECCION DE PROGRAMACION, las variables que estan aqui guardalas en acces bank
	datoA: DS 1 ; el numero es el numero de bytes que contiene 
	datoB: DS 1
;PSECT	udata ;variables en el bnk que elija el mplab
;PSECT udata_bnk7 colocala variable en el acces bank numero 7
;-------------------------------------------------------
; instrucciones}
VECTOR_RESET:
PSECT CODE,RELOC=2,ABS
; ORG 0X00 PUEDE IR O NO EN COMENTARIO
REINICIO:
    GOTO INICIO             ; Salta al inicio del programa
;-------------------------------------------------
CONFIGURACION_SFR:; MAIN:
PSECT CODE,RELOC=2
ORG 0X20 ;PARA SALTAR COMPLETAMENTE EL VECTOR INTERRUPCION
CON_U	EQU 0X0D
CON_D	EQU 0X10
K	EQU 0X0F
L	EQU 0X10A
;$Define UNI PORTA
;#Define DEC PORTB
 
INICIO:
    CLRF    ADCON0,a         ; Limpia el registro ADCON0
    MOVLW   0X0F             ; Carga el valor 0x0F en W
    MOVWF   ADCON1,a         ; Copia W en el registro ADCON1
    MOVLW   00000111B        ; Carga el valor binario 00000111 en W
    MOVWF   CMCON,A           ; Copia W en el registro CMCON
    ;MOVLW  1111111B
    ;MOVWF  OSCCON,a
    MOVLW   00000000B        ; Carga cero en W
    MOVWF   TRISA,0           ; Configura los pines de PORTA como salidas
    CLRF    PORTA,a           ; Limpia el registro PORTA
    MOVLW   00000000B        ; Carga cero en W
    MOVWF   TRISB,0           ; Configura los pines de PORTB como salidas
    CLRF    PORTB,a           ; Limpia el registro PORTB
    GOTO    MAIN              ; Salta al bloque principal

TABLA:
    ADDWF   PCL,F,a
    RETLW   0X3F 
    RETLW   0X06
    RETLW   0X5B
    RETLW   0X4F
    RETLW   0X66
    RETLW   0X6D
    RETLW   0X7D
    RETLW   0X47
    RETLW   0X7F
    RETLW   0X67

MAIN:
    CLRF    CON_U,a           ; Inicializa el contador de unidades en cero
    CLRF    CON_D,a           ; Inicializa el contador de decenas en cero

MAIN_1:
    MOVF    CON_U,W,a
    CALL    TABLA
    MOVWF   PORTA,a           ; Envía el patrón de unidades a PORTA
    MOVF    CON_D,W,a
    CALL    TABLA
    MOVWF   PORTB,a           ; Envía el patrón de decenas a PORTB
    CALL    RET_1SEG
    MOVLW   0X12
    CPFSEQ  CON_U,a
    GOTO    INCRE
    MOVLW   0X12
    CPFSEQ  CON_D,a
    GOTO    INCRE
    CLRF    CON_U,a           ; Reinicia el contador de unidades
    CLRF    CON_D,a           ; Reinicia el contador de decenas
    GOTO    MAIN_1             ; Regresa al ciclo principal

INCRE:
    MOVLW   0X12
    CPFSEQ  CON_U,a
    GOTO    INC
    CLRF    CON_U,a           ; Reinicia el contador de unidades
    INCF    CON_D,F,a
    INCF    CON_D,F,a
    GOTO    MAIN_1             ; Regresa al ciclo principal

INC:
    INCF    CON_U,F,a
    INCF    CON_U,F,a
    GOTO    MAIN_1             ; Regresa al ciclo principal

RET_1SEG:
    MOVLW   1000
    MOVWF   L,A                ; Guarda W en el registro L

OPERA1:
    MOVLW   498
    MOVWF   K,a                ; Guarda W en el registro K

OPERA2:
    NOP
    DECFSZ  K,F,a
    GOTO    OPERA2             ; Regresa al bucle OPERA2
    DECFSZ  L,F,a
    GOTO    OPERA1             ; Regresa al bucle OPERA1
    RETURN                     ; Regresa al programa que llamó la subrutina

END