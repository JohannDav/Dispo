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
    GOTO INICIO
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
    CLRF    ADCON0,a            ; Limpia ADCON0 para deshabilitar o reiniciar la configuración del módulo ADC
    MOVLW   0X0F                ; Carga el literal 0x0F en el registro de trabajo W
    MOVWF   ADCON1,a            ; Escribe 0x0F en ADCON1 para configurar los pines analógicos como digitales
    MOVLW   00000111B           ; Carga el valor binario 00000111 en W
    MOVWF   CMCON,A             ; Configura CMCON para deshabilitar los comparadores analógicos
    ;MOVLW  1111111B
    ;MOVWF  OSCCON,a
    MOVLW   00000000B           ; Carga el valor binario 00000000 en W
    MOVWF   TRISA,0             ; Configura todos los pines de PORTA como salidas
    CLRF    PORTA,a             ; Apaga inicialmente todas las salidas de PORTA
    MOVLW   00000000B           ; Carga nuevamente el valor binario 00000000 en W
    MOVWF   TRISB,0             ; Configura todos los pines de PORTB como salidas
    CLRF    PORTB,a             ; Apaga inicialmente todas las salidas de PORTB
    GOTO    MAIN                ; Salta a MAIN para comenzar la ejecución principal

TABLA:
    ADDWF   PCL,F,a             ; Suma W al contador de programa bajo para saltar a la entrada correspondiente de la tabla
    RETLW   0X3F                ; Devuelve en W el patrón correspondiente al dígito 0
    RETLW   0X06                ; Devuelve en W el patrón correspondiente al dígito 1
    RETLW   0X5B                ; Devuelve en W el patrón correspondiente al dígito 2
    RETLW   0X4F                ; Devuelve en W el patrón correspondiente al dígito 3
    RETLW   0X66                ; Devuelve en W el patrón correspondiente al dígito 4
    RETLW   0X6D                ; Devuelve en W el patrón correspondiente al dígito 5
    RETLW   0X7D                ; Devuelve en W el patrón correspondiente al dígito 6
    RETLW   0X47                ; Devuelve en W el patrón asignado al dígito 7 en esta tabla
    RETLW   0X7F                ; Devuelve en W el patrón correspondiente al dígito 8
    RETLW   0X67                ; Devuelve en W el patrón correspondiente al dígito 9

MAIN:
    CLRF    CON_U,a             ; Inicializa el contador de unidades en cero
    CLRF    CON_D,a             ; Inicializa el contador de decenas en cero

MAIN_1:
    MOVF    CON_U,W,a            ; Copia el contenido de CON_U al registro W
    CALL    TABLA                ; Llama a TABLA para obtener el patrón del display de unidades
    MOVWF   PORTA,a              ; Envía el patrón obtenido al puerto A para mostrar las unidades
    MOVF    CON_D,W,a             ; Copia el contenido de CON_D al registro W
    CALL    TABLA                 ; Llama a TABLA para obtener el patrón del display de decenas
    MOVWF   PORTB,a               ; Envía el patrón obtenido al puerto B para mostrar las decenas
    CALL    RET_1SEG              ; Llama a la subrutina que genera un retardo aproximado de un segundo
    MOVLW   0X12                  ; Carga 0x12 (18 decimal) en W, valor usado como índice máximo para el dígito 9
    CPFSEQ  CON_U,a               ; Compara CON_U con W; si son iguales, omite la siguiente instrucción
    GOTO    INCRE                 ; Si CON_U no es igual a 0x12, salta a INCRE
    MOVLW   0X12                  ; Carga nuevamente 0x12 en W para comparar el contador de decenas
    CPFSEQ  CON_D,a               ; Compara CON_D con W; si son iguales, omite la siguiente instrucción
    GOTO    INCRE                 ; Si CON_D no es igual a 0x12, salta a INCRE
    CLRF    CON_U,a               ; Reinicia el contador de unidades a cero
    CLRF    CON_D,a               ; Reinicia el contador de decenas a cero
    GOTO    MAIN_1                ; Regresa al ciclo principal para mostrar 00

INCRE:
    MOVLW   0X12                 ; Carga 0x12 en W para comprobar si las unidades llegaron al índice del 9
    CPFSEQ  CON_U,a              ; Compara CON_U con W; si son iguales, omite la siguiente instrucción
    GOTO    INC                  ; Si las unidades todavía no llegaron a 0x12, salta a INC
    CLRF    CON_U,a              ; Reinicia las unidades a cero cuando llegan al valor máximo
    INCF    CON_D,F,a            ; Incrementa CON_D en uno y guarda el resultado en el propio registro
    INCF    CON_D,F,a            ; Incrementa CON_D otra vez para avanzar al siguiente índice de la tabla
    GOTO    MAIN_1               ; Regresa al ciclo principal para actualizar los displays

INC:
    INCF    CON_U,F,a            ; Incrementa CON_U en uno y guarda el resultado en el propio registro
    INCF    CON_U,F,a            ; Vuelve a incrementar CON_U para avanzar dos posiciones en el índice de la tabla
    GOTO    MAIN_1               ; Regresa al ciclo principal para mostrar el nuevo valor

RET_1SEG:
    MOVLW   1000                 ; Carga el literal 1000 en W
    MOVWF   L,A                  ; Guarda el contenido de W en el registro L

OPERA1:
    MOVLW   498                  ; Carga el literal 498 en W para establecer el contador interno
    MOVWF   K,a                  ; Guarda el valor de W en el contador K

OPERA2:
    NOP                          ; No realiza ninguna operación; consume tiempo de ejecución
    DECFSZ  K,F,a                ; Decrementa K y omite la siguiente instrucción si el resultado es cero
    GOTO    OPERA2               ; Si K no llegó a cero, repite el ciclo interior
    DECFSZ  L,F,a                ; Decrementa L y omite la siguiente instrucción si el resultado es cero
    GOTO    OPERA1               ; Si L no llegó a cero, reinicia K y repite el ciclo exterior
    RETURN                       ; Regresa al punto del programa que llamó a esta subrutina

END                              ; Indica el final del archivo de código fuente 