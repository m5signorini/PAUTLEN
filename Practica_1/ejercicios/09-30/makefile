# makefile para el ejercicio opcional 9-30

CC = gcc
CFLAGS = -g

ejecutable: doWhile.o main_doWhile.o
	$(CC) $(CFLAGS) -o ejecutable doWhile.o main_doWhile.o

doWhile.o: doWhile.c doWhile.h
	$(CC) $(CFLAGS) -c doWhile.c

main_doWhile.o: main_doWhile.c doWhile.h
	$(CC) $(CFLAGS) -c main_doWhile.c

clean:
	@rm -rf doWhile.o main_doWhile.o ejecutable salida salida.o

generate_asm:
	./ejecutable salida.asm
	nasm -g -o salida.o -f elf32 salida.asm
	gcc -m32 -o salida salida.o alfalib.o
