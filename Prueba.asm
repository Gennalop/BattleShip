TITLE BATTLESHIP

include 'emu8086.inc'

.model small ;Tamano del programa
.stack
.data ;Directiva para declarar variables

; ==========================
;º DECLARACION DE VARIABLES º    
; ========================== 

DISPAROS DB '20'
DISPARO_ACTUAL DB '1'

NAVIOS DB 'P','D','S'
NAVIO_ACTUAL DB ?
NAVIO_DIR DB ?
NAVIO_POS DB ?

TAM_PORTAVIONES DB 5
TAM_DESTRUCTOR DB 3 
TAM_SUBMARINO DB 3

TABLERO DB 36 DUP('0')
TABLERO_COPY DB 36 DUP('0')
TABLERO_JUGADOR DB 36 DUP(' ');necesario?

POSX_TABLERO DB 36 DUP(0);Columnas
POSY_TABLERO DB 36 DUP(0);Filas
                                                      
COLUMNAS DB ' ','A','B','C','D','E','F','a','b','c','d','e','f' 
FILAS DB '1','2','3','4','5','6'

MENU DB 3 DUP(10),34 DUP(32),'E M U 8 0 8 6',13,10
     DB 3 DUP(32),' ___   ____  _____  ____  _    _    ____    _   _  ____  _   _  ____  _   ',13,10
     DB 3 DUP(32),'| _ \ ( __ )|_   _|( __ )| |  | |  ( __ )  | \ | |( __ )| | | |( __ )| |  ',13,10
     DB 3 DUP(32),'| |) ||(__)|  | |  |(__)|| |  | |  |(__)|  |  \| ||(__)|| | | ||(__)|| |  ',13,10
     DB 3 DUP(32),'| _ < | __ |  | |  | __ || |  | |  | __ |  | \ \ || __ || | | || __ || |  ',13,10
     DB 3 DUP(32),'| |) |||  ||  | |  ||  ||| |_ | |_ ||  ||  | |\  |||  || \ V / ||  ||| |_ ',13,10
     DB 3 DUP(32),'|___/ |/  \|  |_|  |/  \||___||___||/  \|  |_| \_||/  \|  \_/  |/  \||___|',13,4 DUP(10)
     DB 39 DUP(32),'MENU',13,2 DUP(10)
     DB 31 DUP(32),'1) Jugar (ENTER)',13,10
     DB 31 DUP(32),'2) Salir (CTRL+E)',13,4 DUP(10)
     DB 3 DUP(32),'Introduzca una opcion [1],[2]: $',13,10
     
BORDE DB 250,3 DUP(196),'$',13 ;Disenos para mostrar el tablero (estetico)

INSTR DB 10,7 DUP(32),'Introduce una coordenada para disparar al barco enemigo. (Ej: E5)',13,2 DUP(10),'$'
INSTR_P1 DB 7 DUP(32),'Misil $',13 
INSTR_P2 DB ', ingrese la celda a atacar: $'

TXT_IMPACTO DB ' ..........Impacto Confirmado',2 DUP(10),'$'
TXT_FALLO DB ' ..........Sin Impacto',2 DUP(10),'$'
TXT_POS_INVALIDO DB 13,2 DUP(10),7 DUP(32),'ERROR! Coordenada no valida. Fila = [A-F], Columna = [1-6]',10,'$' 
TXT_CONTINUAR DB 13,7 DUP(32),'(Presiona cualquier tecla para continuar) $'
TXT_VACIO DB 36 DUP(9),13,10,'$'

POSX_MSG DB ?
POSY_MSG DB ?

POSX_CONT_DISP DB ?
POSY_CONT_DISP DB ?

JUGADA_C DB ' '
JUGADA_F DB ' '
;JUGADA DB ?

NUEVA_LINEA DB 10,13,'$'
RT DB '$',13

.code
.start up

; =========================
;º   CODIGO DEL PROGRAMA   º    
; ========================= 

PRESENTAR_MENU: ;PRESENTA EL TITULO DEL JUEGO Y EL MENU DE OPCIONES

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
JE SALIR
;Tratamiento de opciones invalidas
JMP SALIR


JUGAR: ;LIMPIA LA PANTALLA E INCIA LA LOGICA PARA UBICAR NAVIOS
  
CALL CLEAR_SCREEN
JMP UBICAR_NAVIOS


UBICAR_NAVIOS:

MOV CX,36
MOV BX,0000h

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
JNE MOSTRAR_TABLERO  

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
MOV DH,NAVIOS[BX]
MOV BL,NAVIO_POS
MOV CH,6
MOV TABLERO_COPY[BX],DH

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
    JNE MOSTRAR_BORDE
    MOV AH,02h
    MOV DX,250
    INT 21h
    MOV AH,09h
    LEA DX,NUEVA_LINEA
    INT 21h
    CMP BX,0000h
    JE MOSTRAR_COLUMNAS
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
    MOV CL,7
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
    CMP CH,0
    JE MOSTRAR_COLUMNAS
    JNE MOSTRAR_CONT    

    MOSTRAR_FILAS:

    CMP CH,0
    JNE MOSTRAR_NUM
    MOV BX,-1

        MOSTRAR_NUM: ;MUESTRA LA PARTE NUMERICA DE LAS FILAS DEL TABLERO POR CONSOLA
    
        CMP BX,35
        JE MOSTRAR_INFO_PARTIDA;TEMPORAL
        MOV AX,BX
        MOV BH,00h
        MOV BL,CH
        MOV CL,FILAS[BX]
        MOV CH,BL
        MOV BX,AX
        INC CH 
        JMP MOSTRAR_CASILLA
    
        MOSTRAR_CONT:
        CMP BX,35
        JA IMPRIMIR_CONT;TEMPORAL
        GUARDAR_POS:
        MOV AL,CH 
        MOV AH,03h
        INT 10h
        MOV CH,AL
        ADD DL,2
        MOV POSX_TABLERO[BX],DL
        MOV POSY_TABLERO[BX],DH
        MOV CL,TABLERO_JUGADOR[BX]
        IMPRIMIR_CONT:
        MOV AX,BX
        MOV DX,6
        DIV DL
        CMP AL,CH 
        JNE MOSTRAR_CASILLA
        MOV AH,02h
        MOV DL,179
        INT 21h
        MOV AH,09h
        LEA DX,NUEVA_LINEA
        INT 21h
        DEC BX
        MOV CL,7
        JMP MOSTRAR_BORDE

MOSTRAR_INFO_PARTIDA:

MOV AH,09h
LEA DX,INSTR
INT 21h
LEA DX,INSTR_P1
INT 21h
MOV AH,03h
INT 10h
MOV POSX_CONT_DISP,DL
MOV POSY_CONT_DISP,DH
MOV AH,02h
MOV DL,DISPARO_ACTUAL
INT 21h
MOV AH,09h
LEA DX,INSTR_P2
INT 21h
MOV AH,03h
INT 10h
MOV POSX_MSG,DL
MOV POSY_MSG,DH
;Pide al usuario el ingreso de una columna
MOV AH,01h
INT 21h
MOV CX,1

PEDIR_COLUMNA:

MOV BX,CX
CMP AL,COLUMNAS[BX]
JE PEDIR_FILA
INC CL
CMP CX,13
JNE PEDIR_COLUMNA
JE POSICION_INVALIDA

PEDIR_FILA:

MOV JUGADA_C,AL
MOV AH,01h
INT 21h
CMP AL,'1'
JB POSICION_INVALIDA
CMP AL,'6'
JA POSICION_INVALIDA
MOV JUGADA_F,AL
JMP MOSTRAR_COOR

POSICION_INVALIDA:

MOV AH,09h
LEA DX,TXT_POS_INVALIDO
INT 21h
LEA DX,TXT_CONTINUAR
INT 21h
MOV AH,01h
INT 21h
JMP LIMPIAR_MSG

LIMPIAR_MSG:      
;MOV AH,01h
;INT 21h
CMP AX,0 ;VERIFICAR
JE ACTUALIZAR_DISPAROS

MOV DH,POSY_MSG
MOV DL,POSX_MSG
MOV AH,02h
INT 10h
MOV AH,09h
LEA DX,TXT_VACIO
INT 21h
MOV DH,POSY_MSG
MOV DL,POSX_MSG
MOV AH,02h
INT 10h
MOV AH,01h
INT 21h
MOV CX,1
JMP PEDIR_COLUMNA

ACTUALIZAR_DISPAROS:
INC DISPARO_ACTUAL
MOV BL,DISPAROS
CMP BL,DISPARO_ACTUAL
JA SALIR;TEMPORALLL
MOV DH,POSY_CONT_DISP
MOV DL,POSX_CONT_DISP
MOV AH,02h
INT 10h
;MOV AH,02h
MOV DL,DISPARO_ACTUAL;OJO
INT 21h

JMP LIMPIAR_MSG

MOSTRAR_COOR:

MOV BX,0000h
MOV CX,0000h
SUB JUGADA_C,41h;Transformo los literales a numeros 'A'->0, 'B'->1, ...
SUB JUGADA_F,31h
CMP JUGADA_F,0
JE COMPROBAR_ACIERTO
;MOV BL,JUGADA_C
;MOV JUGADA,BL
MOV CL,JUGADA_F 

TRANSF_POS_A_COORD:

ADD JUGADA_C,6
LOOP TRANSF_POS_A_COORD;COMPROBAR
;MOV BL,JUGADA_C
;MOV JUGADA,BL

COMPROBAR_ACIERTO:
MOV BL,JUGADA_C
CMP TABLERO[BX],'0'
JE IMPRIMIR_FALLO
JNE IMPRIMIR_ACIERTO

IMPRIMIR_FALLO:
MOV BL,JUGADA_C
MOV DH,POSY_TABLERO[BX]
MOV DL,POSX_TABLERO[BX]
MOV AH,02h
INT 10h
MOV AH,02h
MOV DX,'0'
INT 21h
MOV DH,POSY_MSG
MOV DL,POSX_MSG
ADD DL,2
MOV AH,02h
INT 10h
MOV AH,09h
LEA DX,TXT_FALLO
INT 21h
LEA DX,TXT_CONTINUAR
INT 21h
MOV AH,01h
INT 21h
MOV AX,0000h
JMP LIMPIAR_MSG

IMPRIMIR_ACIERTO:
MOV BL,JUGADA_C
MOV DH,POSY_TABLERO[BX]
MOV DL,POSX_TABLERO[BX]
MOV AH,02h
INT 10h
MOV AH,02h
MOV DX,'1'
INT 21h
MOV DH,POSY_MSG
MOV DL,POSX_MSG
ADD DL,2
MOV AH,02h
INT 10h
MOV AH,09h
LEA DX,TXT_IMPACTO
INT 21h
LEA DX,TXT_CONTINUAR
INT 21h
MOV AH,01h
INT 21h
MOV AX,0000h
JMP LIMPIAR_MSG


SALIR:
.exit

DEFINE_CLEAR_SCREEN
end
