
###############################################
#	MAKEFILE - PAUTLEN PRACTICA 4
###############################################
#
#	Autores:
#		Pablo Ruiz
#		Cesar Ramirez
#		Martin Sanchez
#
###############################################
CC = gcc
CFLAGS = -g -ansi -pedantic -std=c99 -Wall -c
EXE = prueba_tabla
###############################################

all: $(EXE)

prueba_tabla: hash.o main.o
	$(CC) -o $@ $^

hash.o: hash.c hash.h
	$(CC) $(CFLAGS) -o $@ $<

main.o: main.c hash.h
	$(CC) $(CFLAGS) -o $@ $<

run:
	./prueba_tabla entrada.txt turbo-salida.txt
	diff -bB salida.txt turbo-salida.txt

clean:
	rm -r -f *.o