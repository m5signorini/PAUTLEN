;D:	main
;D:	{
;D:	int
;R10:	<tipo> ::= int
;R9:	<clase_escalar> ::= <tipo>
;R5:	<clase> ::= <clase_escalar>
;D:	x
;R108:	<identificador> ::= TOK_IDENTIFICADOR
;D:	,
;D:	y
;R108:	<identificador> ::= TOK_IDENTIFICADOR
;D:	;
;R18:	<identificadores> ::= <identificador>
;R19:	<identificadores> ::= <identificador> , <identificadores>
;R4:	<declaracion> ::= <clase> <identificadores> ;
;D:	scanf
;R2:	<declaraciones> ::= <declaracion>

segment .data
  _msg_div_error db "Error: division por cero", 0
  _msg_index_range_error db "Error: Indice fuera de rango", 0

segment .bss
  __esp resd 1
  _x resd 1
  _y resd 1

segment .text
  global main
  extern scan_int, scan_boolean
  extern print_int, print_boolean, print_string, print_blank, print_endofline
;R21:	<funciones> ::=

main:
; guarda el puntero de pila en su variable
  mov [__esp], esp
;D:	x
 push dword _x
  call scan_int
  add esp, 4
;R54:	<lectura> ::= scanf <identificador>
;R35:	<sentencia_simple> ::= <lectura>
;D:	;
;R32:	<sentencia> ::= <sentencia_simple> ;
;D:	y
;D:	=
;D:	x
;D:	+
  push dword _x
;R80:	<exp> ::= <identificador>
;D:	1
;R104:	<constante> ::= <numero>
;R100:	<constante> ::= <constante_entera>
  mov edx, 1
  push dword edx
;R81:	<exp> ::= <constante>
;D:	;
; cargar el segundo operando en edx
  pop dword edx
; cargar el primer operando en eax
  pop dword eax
  mov dword eax, [eax]
; realizar la suma y dejar el resultado en eax 
  add eax, edx
; apilar el resultado
  push dword eax
;R72:	<exp> ::= <exp> + <exp>
; obtenemos cima de la pila y asignamos la variable
  pop dword edx
  mov dword [_y], edx
;R43:	<asignacion> ::= <identificador> = <exp>
;R34:	<sentencia_simple> ::= <asignacion>
;R32:	<sentencia> ::= <sentencia_simple> ;
;D:	printf
;D:	y
;D:	;
  push dword _y
;R80:	<exp> ::= <identificador>
; introduce la variable en la pila
  pop dword edx
  push dword [edx]
; si no es variable, el dato ya viene introducido en la pila
  call print_int
  add esp, 4
  call print_endofline
;R56:	<escritura> ::= printf <exp>
;R36:	<sentencia_simple> ::= <escritura>
;R32:	<sentencia> ::= <sentencia_simple> ;
;D:	}
;R30:	<sentencias> ::= <sentencia>
;R31:	<sentencias> ::= <sentencia> <sentencias>
;R31:	<sentencias> ::= <sentencia> <sentencias>
  jmp near fin

error_div_cero:
  push dword _msg_div_error
  call print_string
  add esp, 4
  call print_endofline
  jmp near fin

fin_indice_fuera_rango:
  push dword _msg_index_range_error
  call print_string
  add esp, 4
  call print_endofline
  jmp near fin

fin:
  mov esp, [__esp]
  ret
;R1:	<programa> ::= main { <declaraciones> <funciones> <sentencias> }