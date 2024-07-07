TITLE BATTLESHIP

include 'emu8086.inc'

.model small ;Tamano del programa
.stack
.data ;Directiva para declarar variables

; ==========================
;º DECLARACION DE VARIABLES º    
; ========================== 

DISPAROS DB 20

NAVIOS DB 'P','D','S'
NAVIO_ACTUAL DB ?
NAVIO_DIR DB ?
NAVIO_POS DB ?

TAM_PORTAVIONES DB 5
TAM_DESTRUCTOR DB 3 
TAM_SUBMARINO DB 3

TABLERO DB 36 DUP('0')
TABLERO_COPY DB 36 DUP('0')
TABLERO_JUGADOR DB 36 DUP(' ')

POSX_TABLERO DB 36 DUP(0);Columnas
POSY_TABLERO DB 36 DUP(0);Filas

;Disenos para mostrar el tablero (estetico)
BORDE DB 250,3 DUP(196),'$',13 ;CAMBIAR DE LUGAR

NUEVA_LINEA DB 10,13,'$'

MENU DB 2 DUP(10),34 DUP(32),'E M U 8 0 8 6',13,10
     DB 3 DUP(32),' ___   ____  _____  ____  _    _    ____    _   _  ____  _   _  ____  _   ',13,10
     DB 3 DUP(32),'| _ \ ( __ )|_   _|( __ )| |  | |  ( __ )  | \ | |( __ )| | | |( __ )| |  ',13,10
     DB 3 DUP(32),'| |) ||(__)|  | |  |(__)|| |  | |  |(__)|  |  \| ||(__)|| | | ||(__)|| |  ',13,10
     DB 3 DUP(32),'| _ < | __ |  | |  | __ || |  | |  | __ |  | \ \ || __ || | | || __ || |  ',13,10
     DB 3 DUP(32),'| |) |||  ||  | |  ||  ||| |_ | |_ ||  ||  | |\  |||  || \ V / ||  ||| |_ ',13,10
     DB 3 DUP(32),'|___/ |/  \|  |_|  |/  \||___||___||/  \|  |_| \_||/  \|  \_/  |/  \||___|',13,4 DUP(10)
     DB 39 DUP(32),'MENU',13,2 DUP(10)
     DB 31 DUP(32),'1) Jugar',13,10
     DB 31 DUP(32),'2) Reglas del juego',13,10
     DB 31 DUP(32),'3) Salir (CTRL+E)',13,4 DUP(10)
     DB 3 DUP(32),'Introduzca una opcion [1],[2],[3]: $',13,10

COLUMNAS DB ' ','A','B','C','D','E','F'

.code
.start up

; =========================
;º   CODIGO DEL PROGRAMA   º    
; ========================= 

PRESENTAR_MENU:

MOV AX,0000h
;Imprime la variable MENU
MOV AH,09h 
LEA DX,MENU
INT 21h
;Solicita una opcion por pantalla
MOV AH,01h
INT 21h
;Compara la opcion ingresada
CMP AL,'1'
JE JUGAR
CMP AL,'2'
JE INFO
CMP AL,'3'
JE SALIR
;Tratamiento de opciones invalidas
JMP SALIR


JUGAR:  

CALL CLEAR_SCREEN
JMP UBICAR_NAVIOS


UBICAR_NAVIOS:

MOV CX,36

    RESTAURAR_TABLERO:;Cambiar de lugar
    
    MOV AL,TABLERO[BX]
    MOV TABLERO_COPY[BX],AL
    INC BX   
    LOOP RESTAURAR_TABLERO

CMP NAVIO_ACTUAL,0
JE UBICAR_PORTAVIONES
CMP NAVIO_ACTUAL,1
JE UBICAR_DESTRUCTOR
CMP NAVIO_ACTUAL,2
JE UBICAR_SUBMARINO
JNE MOSTRAR_TABLERO;REVISAR   

    UBICAR_PORTAVIONES:
    
    MOV NAVIO_ACTUAL,0
    CMP DL,00h
    JE GEN_UBICACION_ALEATORIA
    MOV CL,TAM_PORTAVIONES;El PORTAVIONES ocupa 5 celdas
    CMP NAVIO_DIR,1
    JE DIR_H
    JNE DIR_V 

    UBICAR_DESTRUCTOR:
    
    MOV NAVIO_ACTUAL,1
    CMP DL,00h
    JE GEN_UBICACION_ALEATORIA
    MOV CL,TAM_DESTRUCTOR;El DESTRUCTOR ocupa 3 celdas
    CMP NAVIO_DIR,1
    JE DIR_H
    JNE DIR_V
    
    UBICAR_SUBMARINO:
    
    MOV NAVIO_ACTUAL,2
    CMP DL,00h
    JE GEN_UBICACION_ALEATORIA
    MOV CL,TAM_DESTRUCTOR;El SUBMARINO ocupa 3 celdas
    CMP NAVIO_DIR,1
    JE DIR_H
    JNE DIR_V
    
     
SIGUIENTE_NAVIO:

MOV AX,0000h
MOV BX,0000h
MOV DX,0000h
MOV CX,36
INC NAVIO_ACTUAL;Marca el siguiente navio  

    ACTUALIZAR_TABLERO:;Cambiar de lugar
    
    MOV AL,TABLERO_COPY[BX]
    MOV TABLERO[BX],AL
    INC BX   
    LOOP ACTUALIZAR_TABLERO
             
JMP UBICAR_NAVIOS


DIR_H:

MOV DX,0000h 
MOV BX,0000h
MOV BL,NAVIO_ACTUAL
MOV DH,NAVIOS[BX];'P'
MOV BL,NAVIO_POS
MOV CH,6
MOV TABLERO_COPY[BX],DH;'P'

    MOVER_IZQ:;Restar  
    
    DEC CL
    CMP CL,0
    JE SIGUIENTE_NAVIO
    MOV AX,BX
    DIV CH
    CMP AH,0;Compara si la columna actual es A
    JE MOVER_H_ORIGEN
    SUB BX,1
    CMP TABLERO_COPY[BX],'0'
    JNE MOVER_H_ORIGEN
    MOV TABLERO_COPY[BX],DH
    JMP MOVER_IZQ
    
    MOVER_H_ORIGEN:
    
    MOV BL,NAVIO_POS

    MOVER_DER:;Sumar

    ADD BX,1
    CMP TABLERO_COPY[BX],'0'
    JNE GEN_UBICACION_ALEATORIA
    MOV TABLERO_COPY[BX],DH
    DEC CL
    CMP CL,0
    JE SIGUIENTE_NAVIO
    MOV AX,BX
    DIV CH
    CMP AH,5;Compara si la columna actual es F
    JE GEN_UBICACION_ALEATORIA
    JMP MOVER_DER


DIR_V:

MOV DX,0000h 
MOV BX,0000h
MOV BL,NAVIO_ACTUAL
MOV DH,NAVIOS[BX];'P'
MOV BL,NAVIO_POS
MOV CH,6
MOV TABLERO_COPY[BX],DH;'P'

    MOVER_ARR:;Restar  
    
    DEC CL
    CMP CL,0
    JE SIGUIENTE_NAVIO
    MOV AX,BX
    DIV CH
    CMP AL,0;Compara si la fila actual es 1
    JE MOVER_V_ORIGEN
    SUB BX,6
    CMP TABLERO_COPY[BX],'0'
    JNE MOVER_V_ORIGEN
    MOV TABLERO_COPY[BX],DH
    JMP MOVER_ARR
    
    MOVER_V_ORIGEN:  
    
    MOV BL,NAVIO_POS
    
    MOVER_ABJ:;Sumar  
    
    ADD BX,6
    CMP TABLERO_COPY[BX],'0'
    JNE GEN_UBICACION_ALEATORIA
    MOV TABLERO_COPY[BX],DH
    DEC CL
    CMP CL,0
    JE SIGUIENTE_NAVIO
    MOV AX,BX
    DIV CH
    CMP AL,5;Compara si la fila actual es 6
    JE GEN_UBICACION_ALEATORIA
    JMP MOVER_ABJ


GEN_UBICACION_ALEATORIA: ;GENERA DIRECCION Y POSICION ALEATORIAS, Y LAS GUARDA EN LAS VARIABLES NAVIO_DIR Y NAVIO_POS RESPECTIVAMENTE

MOV NAVIO_DIR,0 ;Configuramos por defecto una direccion Vertical (0)
;Uso de la interrupcion 21h/2Ah para obtener la hora del sistema.
;Con esa interrupcion DL guarda las centesimas de segundo, es decir, obtiene un valor entre 0-99 "aleatorio".
MOV AH,2Ch
INT 21h
MOV NAVIO_POS,DL
   
    POS_ALEATORIA:  
    ;Para un tablero de 6x6 se necesita un valor entre 0-35
    ;Restamos el valor 0-99 hasta obtener un valor entre 0-35
    ;MOV NAVIO_POS,DL
    CMP NAVIO_POS,36
    JB POS_VALIDA
    SUB NAVIO_POS,36
    JMP POS_ALEATORIA
    
    POS_VALIDA:
    ;Comprueba que el valor entre 0-35 no este ocupado por un navio
    MOV BX,0000h
    MOV BL,NAVIO_POS
    CMP TABLERO[BX],'0'
    JNE GEN_UBICACION_ALEATORIA         

    DIR_ALEATORIA: ;1=Horizontal,0=Vertical
    MOV AX,0000h
    MOV AL,DH
    MOV DL,2                                                       
    DIV DL
    CMP AH,0
    JE UBICAR_NAVIOS
    MOV NAVIO_DIR,1
    JMP UBICAR_NAVIOS


MOSTRAR_TABLERO:

MOV BX,0000h
MOV CX,7

MOSTRAR_BORDE:
    MOV AH,09h
    LEA DX,BORDE
    INT 21h
    DEC CL
    CMP CL,0
    JNE MOSTRAR_BORDE;VERIFICAR
    MOV AH,02h
    MOV DX,250
    INT 21h
    MOV AH,09h
    LEA DX,NUEVA_LINEA
    INT 21h
    CMP BX,0000h;EN VERIFICACION!!!!!!!
    JE MOSTRAR_COLUMNAS
    MOV NAVIO_POS,0
    JMP MOSTRAR_FILAS    

MOSTRAR_COLUMNAS: 

    MOV CL,COLUMNAS[BX]
    CMP CL,' '
    JE MOSTRAR_CASILLA
    CMP BX,7
    JB MOSTRAR_CASILLA
    MOV DL,179
    INT 21h
    MOV AH,09h
    LEA DX,NUEVA_LINEA
    INT 21h
    MOV CX,7
    JMP MOSTRAR_BORDE     

MOSTRAR_CASILLA: 

    INC BX
    MOV AH,02h
    MOV DL,179
    INT 21h
    MOV DL,' '
    INT 21h
    MOV DL,CL;AL define que se imprime dentro de la casilla
    INT 21h
    MOV DL,' '
    INT 21h
    CMP CH,0;EN VERIFICACION!!!!!!
    JE MOSTRAR_COLUMNAS
    JNE MOSTRAR_FILAS ;CAMBIAR    

MOSTRAR_FILAS:

INFO:

;===================================================================================================


SALIR:
.exit

DEFINE_CLEAR_SCREEN
end

