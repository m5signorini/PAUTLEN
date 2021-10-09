# makefile para los ejemplos de la practica 1

CC = gcc
CFLAGS = -g

ej1: generacion.o main_ej1.o
	$(CC) $(CFLAGS) -o ej1 generacion.o main_ej1.o

ej2: generacion.o main_ej2.o
	$(CC) $(CFLAGS) -o ej2 generacion.o main_ej2.o

ej3: generacion.o main_ej3.o
	$(CC) $(CFLAGS) -o ej3 generacion.o main_ej3.o

generacion.o: generacion.c generacion.h
	$(CC) $(CFLAGS) -c generacion.c

main_ej1.o: main_ej1.c generacion.h
	$(CC) $(CFLAGS) -c main_ej1.c

main_ej2.o: main_ej2.c generacion.h
	$(CC) $(CFLAGS) -c main_ej2.c

main_ej3.o: main_ej3.c generacion.h
	$(CC) $(CFLAGS) -c main_ej3.c

generate_ej1_asm:
	./ej1 ej1.asm
	nasm -g -o ej1.o -f elf32 ej1.asm
	gcc -m32 -o ej1 ej1.o alfalib.o

generate_ej2_asm:
	./ej2 ej2.asm
	nasm -g -o ej2.o -f elf32 ej2.asm
	gcc -m32 -o ej2 ej2.o alfalib.o

generate_ej3_asm:
	./ej3 ej3.asm
	nasm -g -o ej3.o -f elf32 ej3.asm
	gcc -m32 -o ej3 ej3.o alfalib.o

clean:
	@rm -rf generacion.o main_ej1.o ej1.asm ej1 ej1.o main_ej2.o ej2.asm ej2 ej2.o main_ej3.o ej3.asm ej3 ej3.o
