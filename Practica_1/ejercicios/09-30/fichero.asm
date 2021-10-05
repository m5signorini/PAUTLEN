segment .data
_div_error db "Error: division por cero"
segment .bss
  __esp resd 1
_x resd 1
_y resd 1
segment .text
global main
extern scan_int, scan_boolean
extern print_int, print_boolean, print_string, print_blank, print_endofline
main:
; guarda el puntero de pila en su variable
mov esp, [__esp]
mov edx, 0
push dword edx


; obtenemos cima de la pila
pop dword edx
mov dword [_x], edx
mov edx, 0
push dword edx


; obtenemos cima de la pila
pop dword edx
mov dword [_y], edx
do_while_1:
push dword [_x]


push dword [_y]


; cargar el segundo operando en edx
pop dword edx
mov dword edx, [edx]
; cargar el primer operando en eax
pop dword eax
mov dword eax, [eax]
; realizar la suma y dejar el resultado en eax 
add eax, edx
; apilar el resultado
push dword eax
; obtenemos cima de la pila
pop dword edx
mov dword [_x], edx
push dword [_x]


pop dword edx
; introduce la variable en la pila
push dword [edx]
call print_int
add esp, 4
push dword [_x]


; cargar el segundo operando en edx
pop dword edx
; cargar el primer operando en eax
pop dword eax
mov dword eax, [eax]
cmp eax, edx
jl menor_1
; si no se cumple la comparacion
push dword 0
jmp fin_menor_1
; si se cumple la comparacion
menor_1:
push dword 1
fin_menor_1:; obtenemos el valor de la expresion del bucle
pop dword eax
cmp eax, 0
jne do_while_1
jmp fin_do_while_1
fin_do_while_1:
jmp near fin
error_div_cero:
  push dword _div_error
  call print_string
  add esp, 4
  call print_endofline
  jmp near fin
fin:
  mov esp, [__esp]
  ret
