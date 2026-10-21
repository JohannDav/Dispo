/* LO QUE TENEMOS EN EL PUERTO A LO VISUALIZAMOS EN EL PUERTO B */

PROCESSOR 18F4550 ; Microcontrolador que utilizaremos

; ================= CONFIGURACIÓN DEL PIC =================
CONFIG PLLDIV=1
CONFIG CPUDIV=OSC1_PLL2
CONFIG USBDIV=2

CONFIG FOSC=INTOSCIO_EC ; Configuración del oscilador
CONFIG FCMEN=OFF        ; Deshabilita el monitoreo del reloj
CONFIG IESO=OFF         ; Deshabilita el cambio de oscilador

CONFIG PWRT=ON          ; Habilita el temporizador de encendido
CONFIG BOR=OFF          ; Deshabilita el reset por bajo voltaje
CONFIG BORV=3
CONFIG VREGEN=ON        ; Habilita el regulador USB

CONFIG WDT=OFF          ; Deshabilita el Watchdog
CONFIG WDTPS=32768

CONFIG CCP2MX=ON
CONFIG PBADEN=OFF       ; Configura RB0-RB4 como digitales al iniciar
CONFIG LPT1OSC=OFF
CONFIG MCLRE=ON         ; Habilita el pin MCLR

CONFIG STVREN=ON
CONFIG LVP=OFF          ; Deshabilita la programación de bajo voltaje
CONFIG ICPRT=OFF
CONFIG XINST=OFF        ; Deshabilita el conjunto extendido de instrucciones

CONFIG CP0=OFF
CONFIG CP1=OFF
CONFIG CP2=OFF
CONFIG CP3=OFF
CONFIG CPB=ON
CONFIG CPD=OFF

CONFIG WRT0=OFF
CONFIG WRT1=OFF
CONFIG WRT2=OFF
CONFIG WRT3=OFF
CONFIG WRTC=OFF
CONFIG WRTB=ON
CONFIG WRTD=OFF

CONFIG EBTR0=OFF
CONFIG EBTR1=OFF
CONFIG EBTR2=OFF
CONFIG EBTR3=OFF
CONFIG EBTRB=OFF

#include <xc.inc>

; ================= DECLARACIÓN DE VARIABLES =================
DECLARAR_VARIABLES:
PSECT udata_acs
    datoA: DS 1 ; Reserva un byte para datoA
    datoB: DS 1 ; Reserva un byte para datoB

; ================= VECTOR DE RESET =================
VECTOR_RESET:
PSECT CODE,RELOC=2,ABS

REINICIO:
    GOTO INICIO ; Después del reset, saltar a INICIO

; ================= CONSTANTES DEL PROGRAMA =================
PSECT CODE,RELOC=2
ORG 0X20 ; Coloca el programa después del área inicial

CON EQU 0X0D ; Dirección utilizada para guardar el contador
K   EQU 0X0E ; Dirección utilizada como contador interno del retardo
L   EQU 0X0F ; Dirección utilizada como contador externo del retardo

; ================= INICIALIZACIÓN =================
INICIO:
    CLRF    ADCON0,a       ; Limpia ADCON0
    MOVLW   0X0F           ; Carga 0x0F en W
    MOVWF   ADCON1,a       ; Configura las entradas analógicas como digitales
    MOVLW   00000111B      ; Carga el valor binario 00000111 en W
    MOVWF   CMCON,a        ; Configura los comparadores

    ;MOVLW  1111111B
    ;MOVWF  OSCCON,a        ; Estas instrucciones están comentadas

    BSF     TRISA,0,a      ; Configura RA0 como entrada para el botón
    CLRF    PORTA,a        ; Limpia el registro PORTA

    MOVLW   00000000B      ; Carga cero en W
    MOVWF   TRISB,0        ; Configura todos los pines de PORTB como salidas
    CLRF    PORTB,a        ; Limpia las salidas de PORTB

    GOTO MAIN              ; Saltar al programa principal

; ================= TABLA DEL DISPLAY =================
TABLA:
    ADDWF   PCL,F,a        ; Utiliza W para seleccionar un patrón de la tabla

    RETLW   0X3F           ; Patrón para mostrar el número 0
    RETLW   0X06           ; Patrón para mostrar el número 1
    RETLW   0X5B           ; Patrón para mostrar el número 2
    RETLW   0X4F           ; Patrón para mostrar el número 3
    RETLW   0X66           ; Patrón para mostrar el número 4
    RETLW   0X6D           ; Patrón para mostrar el número 5
    RETLW   0X7D           ; Patrón para mostrar el número 6
    RETLW   0X47           ; Patrón para mostrar el número 7
    RETLW   0X7F           ; Patrón para mostrar el número 8
    RETLW   0X67           ; Patrón para mostrar el número 9

MAIN:
    CLRF    CON,a          ; Inicializa CON en cero
    MOVF    CON,W,a        ; Copia CON a W
    CALL    TABLA          ; Obtiene el patrón correspondiente al cero
    MOVWF   PORTB,a        ; Mueve lo de w a PORTB

PRE_MAIN:
    BTFSS   PORTA,0,a      ; Comprueba si RA0 vale 1, si vale 1 se salta el goto y va a call
    GOTO    PRE_MAIN       ; Si vale 0, continúa esperando

    CALL    RET_20MSEG     ; Espera aproximadamente 20 ms

    BTFSS   PORTA,0,a      ; Comprueba nuevamente el estado de RA0
    GOTO    PRE_MAIN       ; Si vale 0, regresa a esperar

    CALL    INCRE          ; Llama a la rutina que actualiza el contador

    
ES_BOT:
    BTFSC   PORTA,0,a      ; Comprueba si RA0 vale 0
    GOTO    ES_BOT         ; Si vale 1, continúa esperando
    GOTO    PRE_MAIN       ; Cuando se suelta, espera otra pulsación

INCRE:
    MOVLW   0X12           ; Carga el valor hexadecimal 0x12 en W
    CPFSEQ  CON,a          ; Compara CON con W; si son iguales, omite la siguiente
    GOTO    IMPRE          ; Si son diferentes, continúa en IMPRE

    CLRF    CON,a          ; Si son iguales, reinicia CON a cero
    GOTO    IMPRE_1        ; Salta a mostrar el valor reiniciado

IMPRE:
    INCF    CON,F,a        ; Incrementa CON en una unidad
    INCF    CON,F,a        ; Incrementa CON una segunda unidad

IMPRE_1:
    MOVF    CON,W,a        ; Copia el contador a W
    CALL    TABLA          ; Busca el patrón del número
    MOVWF   PORTB,a        ; Muestra el patrón en el display
    RETURN                  ; Regresa después del CALL INCRE

RET_20MSEG:
    MOVLW   20             ; Carga 20 en W para el contador externo
    MOVWF   L,a             ; Guarda 20 en L

OPERA1:
    MOVLW   498            ; Carga 498 en W para el contador interno
    MOVWF   K,a             ; Guarda el valor en K

OPERA2:
    NOP                    ; No realiza una operación útil; consume tiempo
    DECFSZ  K,F,a           ; Decrementa K; si llega a cero, omite la siguiente
    GOTO    OPERA2          ; Repite el ciclo interno mientras K no sea cero

    DECFSZ  L,F,a           ; Decrementa L; si llega a cero, omite la siguiente
    GOTO    OPERA1          ; Repite el ciclo externo mientras L no sea cero

    RETURN                  ; Regresa después del CALL RET_20MSEG

END                         ; Fin del código fuente