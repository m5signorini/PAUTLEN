;Ejercicio opcional 23/09
;Autores:
; -Pablo Ruiz Revilla
; -Martin Sanchez Signorini
; -Cesar Ramirez Martinez

extern print_int, print_endofline, scan_int

section .data
  _x dd 0 ;_x es una variable con 4 bytes de tamaño con valor inicial 0
  _y dd 0 ;_y es una variable con 4 bytes de tamaño con valor inicial 0

section .bss
  _z resd 1 ;_z es una variable con una sola posicion de 4 bytes de tamaño sin inicializar

section .text
global main

main:
  mov ebx, [_y] ;ebx almacenara el valor de la variable y
  mov edx, [_x] ;edx almacenara el valor de la variable x
  mov ecx, 10 ;ecx almacenara el entero 10

while:
  cmp ebx, ecx ;comparacion de la variable y con 10
  jge fin ;si y >= 10 fin del programa
  inc dword ebx ;y = y + 1
  push dword _z
  call scan_int ;leemos el valor introducido por el usuario y lo guardamos en la variable z
  add esp, 4
  cmp [_z], edx ;comparacion del valor introducido con el valor de x
  jle while
  mov edx, [_z] ;si el valor introducido es mayor que x, x tomara este nuevo valor
  jmp while

fin:
  call print_endofline ;simplemente para ver claramente el numero que finalmente se imprime
  push dword edx
  call print_int
  add esp, 4
  call print_endofline ;simplemente para ver claramente el numero que finalmente se imprime

  ret
