    LIST p=18f4550 ; Indica que el micocontrolador es el PIC 18F4550
	
		    ; EQU es un "=" de java
D1      EQU 0X0D    ; Asigna a D1 un valor simbolico de 0X0D. Nombra en direccion de memoria RAM del PIC
		    ; Le dice al ensamblador "Cada vez que veas D1 remplazalo con 0x0D" 
D2      EQU 0X0E
R_S     EQU 0X0F
R_R     EQU 0X10
R_AN    EQU 0X11
R_OR    EQU 0X12
R_XOR   EQU 0X13
R_NOT1  EQU 0X14
R_NOT2  EQU 0X15
  ORG 0		    ; El codigo empieza a ejecutarse desde aquí al encender el PIC
  
  MOVLW 0X28	    ; Mover un literal al registro W, Mueve el numero 0X34 (52) al registro W
		    ; W = 0x34 (52) , D1 = ?
  MOVWF D1,A	    ; Mueve lo de W a D1, "A," significa "Usa el Acces Bank", o sea la RAM
		    ; W = 0x34 (52) , D1 = 0x34 (52)
  MOVLW 0X65	    ; Mueve 0x12 a W
  MOVWF D2,A	    ; Carga el valor de W (0x12) a D2 usando la RAM
		    ; W = 0X12
  ADDWF D1,W,A	    ; Suma D1 mas W y lo guarda en W usando la RAM, 
		    ; W = 0X12 + 0X34
  MOVWF R_S,A	    ; Carga el valor de W en R_S usando la RAM
		    ; W = 0x46    D2 = 0x12
  MOVF D2,W,A	    ; Mueve el comtenido del registro D2 a W usando la RAM
		    ; W = 0x12    D2 = 0x12
		    ; W = 0x12    D1 = 0x34
  SUBWF D1,W,A	    ; Resta D1 - W y lo guarda en W
		    ; W = 0x22
  MOVWF R_R,A	    ; Copia el valor de W al cajon R_R
  

  
 /*
		    ; EJEMPLO PROPUESTO...
		    ; W = ? , D1 = ?
  MOVLW 0X34	    ; Mover un literal al registro W, Mueve el numero 0X34 (52) al registro W
		    ; W = 0x34 (52) , D1 = ?
  MOVWF D1,A	    ; Mueve lo de W a D1, "A," significa "Usa el Acces Bank", o sea la RAM
		    ; W = 0x34 (52) , D1 = 0x34 (52)
  MOVLW 0X12	    ; Mueve 0x12 a W
  MOVWF D2,A	    ; Carga el valor de W (0x12) a D2 usando la RAM
		    ; W = 0X12
  ADDWF D1,W,A	    ; Suma D1 mas W y lo guarda en W usando la RAM, 
		    ; W = 0X12 + 0X34
  MOVWF R_S,A	    ; Carga el valor de W en R_S usando la RAM
		    ; W = 0x46    D2 = 0x12
  MOVF D2,W,A	    ; Mueve el comtenido del registro D2 a W usando la RAM
		    ; W = 0x12    D2 = 0x12
		    ; W = 0x12    D1 = 0x34
  SUBWF D1,W,A	    ; Resta D1 - W y lo guarda en W
		    ; W = 0x22
  MOVWF R_R,A	    ; Copia el valor de W al cajon R_R
 */