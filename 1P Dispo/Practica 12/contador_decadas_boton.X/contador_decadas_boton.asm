    /*LO QUE TENEMOS EN EL PUERTO A LO VISUALIZAMOS EN EL PUERTO B*/
    PROCESSOR 18F4550 ; inicio
    ;CONFIG1L dir 300000h         20
        CONFIG PLLDIV=1           ;
        CONFIG CPUDIV=OSC1_PLL2   ; CUANDO SE USA
        CONFIG USBDIV=2

        ;CONFIG1H dir 300001h      08
        CONFIG FOSC=INTOSCIO_EC   ; OSCILADOR INTERNO, RA6 COMO PIN, USB USA OSC EC
        CONFIG FCMEN=OFF          ; DESHABILITADO EL MONITOREO DEL RELOJ
        CONFIG IESO=OFF
        ;CONFIG2L DIR 300002H      38
        CONFIG PWRT=ON            ; PWRT HABILITADO
        CONFIG BOR=OFF            ; BROWN OUT RESET DESHABILITADO
        CONFIG BORV=3             ; RESET AL MINIMO VOLTAJE NO UTILIZADO EN ESTE CASO
        CONFIG VREGEN=ON          ; REGULADOR DE USB ENCENDIDO
        ;CONFIG2H DIR 300003H     1E
        CONFIG WDT=OFF            ; WATCHDOG DESHABILITADO
        CONFIG WDTPS=32768        ; TIMER DEL WATCHDOG
        ;CONFIG3H DIR 300005H     81
        CONFIG CCP2MX=ON          ; CCP2 MULTIPLEXADAS CON RC1
        CONFIG PBADEN=OFF         ; PUERTO B PINES DEL 0 AL 4 ENTRADAS DIGITALES
        CONFIG LPT1OSC=OFF        ; TIMER1 CONFIGURADO PARA OPERAR EN BAJA POTENCIA
        CONFIG MCLRE=ON           ; MASTER CLEAR HABILITADO
        ;CONFIG4L DIR 300006H     81
        CONFIG STVREN=ON          ; SI EL STACK SE LLENA, CAUSA RESET
        CONFIG LVP=OFF            ; PROGRAMACION EN BAJO VOLTAJE APAGADA
        CONFIG ICPRT=OFF          ; REGISTRO ICPORT DESHABILITADO
        CONFIG XINST=OFF          ; SET DE EXTENSION Y DIRECCIONAMIENTO INDEXADO DESHABILITADO
        ;CONFIG5L DIR 300008H     0F
        CONFIG CP0=OFF            ; LOS BLOQUES DEL CODIGO DE PROGRAMA
        CONFIG CP1=OFF            ; NO ESTAN PROTEGIDOS
        CONFIG CP2=OFF
        CONFIG CP3=OFF
        ;CONFIG5H DR 300009H      80
        CONFIG CPB=ON             ; SECTOR BOOT PROTEGIDO
        CONFIG CPD=OFF            ; EEPROM NO PROTEGIDA
        ;CONFIG6L DIR 30000AH     0F
        CONFIG WRT0=OFF           ; BLOQUES NO PROTEGIDOS CONTRA ESCRITURA
        CONFIG WRT1=OFF
        CONFIG WRT2=OFF
        CONFIG WRT3=OFF

        ;CONFIG6H DIR 30000BH     A0
        CONFIG WRTC=OFF           ; CONFIGURACION DE REGISTROS NO PROTEGIDA
        CONFIG WRTB=ON            ; CONFIGURACION ORIGINAL CONSERVADA
        CONFIG WRTD=OFF           ; EEPROM DE DATOS NO PROTEGIDA

        ;CONFIG7L DIR 30000CH     0F
        CONFIG EBTR0=OFF          ; TABLAS DE LECTURA NO PROTEGIDAS
        CONFIG EBTR1=OFF
        CONFIG EBTR2=OFF
        CONFIG EBTR3=OFF

        ;CONFIG7H DIR 30000DH     40
        CONFIG EBTRB=OFF          ; TABLAS NO PROTEGIDAS

#include <xc.inc>

                /* declarar variables*/
                ;TODAS LAS ETIQUETAS VAN CON :
DECLARAR_VARIABLES:
PSECT udata_acs ; SECCION DE PROGRAMACION, variables guardadas en ACCESS BANK
    datoA: DS 1 ; El numero indica la cantidad de bytes
    datoB: DS 1

;PSECT udata ; VARIABLES EN EL BANCO QUE ELIJA MPLAB
;PSECT udata_bnk7 ; COLOCAR LA VARIABLE EN EL ACCESS BANK NUMERO 7
;-------------------------------------------------------
; instrucciones}

VECTOR_RESET:
PSECT CODE,RELOC=2,ABS
; ORG 0X00 PUEDE IR O NO EN COMENTARIO

REINICIO:
    GOTO INICIO             ; Salta al inicio del programa

;-------------------------------------------------
CONFIGURACION_SFR:
PSECT CODE,RELOC=2
ORG 0X20                    ; Para comenzar después del vector de reinicio

CON_U EQU 0X0D              ; Registro del contador de unidades
CON_D EQU 0X0E              ; Registro del contador de decenas
K     EQU 0X0F              ; Contador interno del retardo
L     EQU 0X10              ; Contador externo del retardo

;$Define UNI PORTA
;#Define DEC PORTB

INICIO:
    CLRF    ADCON0,a        ; Limpia el registro ADCON0
    MOVLW   0X0F            ; Carga 0x0F en W para seleccionar entradas digitales
    MOVWF   ADCON1,a        ; Copia W en ADCON1
    MOVLW   00000111B       ; Carga el valor binario 00000111 en W
    MOVWF   CMCON,a         ; Deshabilita los comparadores

    MOVLW   0X60            ; Selecciona el oscilador interno de 4 MHz
    MOVWF   OSCCON,a        ; Configura la frecuencia del oscilador

    MOVLW   00000000B       ; Carga cero en W
    MOVWF   TRISA,0         ; Configura PORTA como salida
    CLRF    PORTA,a         ; Limpia las salidas de PORTA

    MOVLW   00000000B       ; Carga cero en W
    MOVWF   TRISB,0         ; Configura PORTB como salida
    CLRF    PORTB,a         ; Limpia las salidas de PORTB

    BSF     TRISC,0,a       ; Configura RC0 como entrada para el boton

    GOTO    MAIN            ; Salta al programa principal

TABLA:
    RLNCF   WREG,W,a        ; Multiplica el digito por 2 para calcular el desplazamiento
    ADDWF   PCL,F,a          ; Salta a la entrada correspondiente de la tabla
    RETLW   0X3F             ; Devuelve el patron del digito 0
    RETLW   0X06             ; Devuelve el patron del digito 1
    RETLW   0X5B             ; Devuelve el patron del digito 2
    RETLW   0X4F             ; Devuelve el patron del digito 3
    RETLW   0X66             ; Devuelve el patron del digito 4
    RETLW   0X6D             ; Devuelve el patron del digito 5
    RETLW   0X7D             ; Devuelve el patron del digito 6
    RETLW   0X07             ; Devuelve el patron del digito 7
    RETLW   0X7F             ; Devuelve el patron del digito 8
    RETLW   0X6F             ; Devuelve el patron del digito 9

MAIN:
    CLRF    CON_U,a          ; Inicializa las unidades en cero
    CLRF    CON_D,a          ; Inicializa las decenas en cero
    GOTO    MOSTRAR          ; Muestra inicialmente 00

ESPERA_BOTON:
    BTFSS   PORTC,0,a        ; Comprueba si RC0 vale 1
    GOTO    ESPERA_BOTON     ; Si RC0 vale 0, sigue esperando
    CALL    RET_20MSEG       ; Espera para reducir el rebote del boton
    BTFSS   PORTC,0,a        ; Comprueba otra vez si RC0 vale 1
    GOTO    ESPERA_BOTON     ; Si ya vale 0, descarta esa deteccion

    INCF    CON_U,F,a        ; Incrementa las unidades en uno
    MOVLW   0X0A             ; Carga el limite decimal de las unidades: 10
    CPFSEQ  CON_U,a          ; Si CON_U es igual a 10, omite el siguiente GOTO
    GOTO    MOSTRAR          ; Si unidades no llego a 10, muestra el resultado

    CLRF    CON_U,a          ; Reinicia las unidades a cero al llegar a 10
    INCF    CON_D,F,a        ; Incrementa las decenas en uno
    MOVLW   0X0A             ; Carga el limite decimal de las decenas: 10
    CPFSEQ  CON_D,a          ; Si CON_D es igual a 10, omite el siguiente GOTO
    GOTO    MOSTRAR          ; Si decenas no llego a 10, muestra el resultado

    CLRF    CON_D,a          ; Reinicia las decenas a cero despues de 99
    GOTO    MOSTRAR          ; Muestra 00 al completar el ciclo

MOSTRAR:
    MOVF    CON_U,W,a        ; Copia el valor de unidades a W
    CALL    TABLA            ; Obtiene el patron de unidades
    MOVWF   PORTA,a          ; Envia el patron al display de unidades

    MOVF    CON_D,W,a        ; Copia el valor de decenas a W
    CALL    TABLA            ; Obtiene el patron de decenas
    MOVWF   PORTB,a          ; Envia el patron al display de decenas

ESPERA_SOLTAR:
    BTFSC   PORTC,0,a        ; Si RC0 vale 0, omite la siguiente instruccion
    GOTO    ESPERA_SOLTAR    ; Si sigue en 1, espera a que se suelte el boton
    CALL    RET_20MSEG       ; Espera para comprobar que la liberacion sea estable
    BTFSC   PORTC,0,a        ; Comprueba de nuevo que RC0 siga en cero
    GOTO    ESPERA_SOLTAR    ; Si regreso a 1, sigue esperando a que se suelte
    GOTO    ESPERA_BOTON     ; Espera la siguiente pulsacion

RET_20MSEG:
    MOVLW   20               ; Carga 20 repeticiones para el bucle exterior
    MOVWF   L,a              ; Guarda el contador exterior en L

OPERA1:
    MOVLW   250              ; Carga 250 repeticiones para el bucle interior
    MOVWF   K,a              ; Guarda el contador interior en K

OPERA2:
    NOP                      ; No ejecuta una operacion util; consume un ciclo
    DECFSZ  K,F,a             ; Decrementa K y omite la siguiente instruccion si llega a cero
    GOTO    OPERA2            ; Repite el bucle interior mientras K no sea cero
    DECFSZ  L,F,a             ; Decrementa L y omite la siguiente instruccion si llega a cero
    GOTO    OPERA1            ; Repite el bucle exterior mientras L no sea cero
    RETURN                   ; Regresa al punto posterior al CALL

END                          ; Fin del programa