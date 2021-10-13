# makefile para los ejemplos de la practica 1

CC = gcc
CFLAGS = -g
EXE = ej1_c ej2_c ej3_c ej4_c ej5_c ej6_c ej7_c generate_ej1_asm generate_ej2_asm generate_ej3_asm generate_ej4_asm generate_ej5_asm generate_ej6_asm generate_ej7_asm

all : $(EXE)

ej1_c: generacion.o main_ej1.o
	$(CC) $(CFLAGS) -o ej1_c generacion.o main_ej1.o

ej2_c: generacion.o main_ej2.o
	$(CC) $(CFLAGS) -o ej2_c generacion.o main_ej2.o

ej3_c: generacion.o main_ej3.o
	$(CC) $(CFLAGS) -o ej3_c generacion.o main_ej3.o

ej4_c: generacion.o main_ej4.o
	$(CC) $(CFLAGS) -o ej4_c generacion.o main_ej4.o

ej5_c: generacion.o main_ej5.o
	$(CC) $(CFLAGS) -o ej5_c generacion.o main_ej5.o

ej6_c: generacion.o main_ej6.o
	$(CC) $(CFLAGS) -o ej6_c generacion.o main_ej6.o

ej7_c: generacion.o main_ej7.o
	$(CC) $(CFLAGS) -o ej7_c generacion.o main_ej7.o

generacion.o: generacion.c generacion.h
	$(CC) $(CFLAGS) -c generacion.c

main_ej1.o: main_ej1.c generacion.h
	$(CC) $(CFLAGS) -c main_ej1.c

main_ej2.o: main_ej2.c generacion.h
	$(CC) $(CFLAGS) -c main_ej2.c

main_ej3.o: main_ej3.c generacion.h
	$(CC) $(CFLAGS) -c main_ej3.c

main_ej4.o: main_ej4.c generacion.h
	$(CC) $(CFLAGS) -c main_ej4.c

main_ej5.o: main_ej5.c generacion.h
	$(CC) $(CFLAGS) -c main_ej5.c

main_ej6.o: main_ej6.c generacion.h
	$(CC) $(CFLAGS) -c main_ej6.c

main_ej7.o: main_ej7.c generacion.h
	$(CC) $(CFLAGS) -c main_ej7.c

generate_ej1_asm:
	./ej1_c ej1.asm
	nasm -g -o ej1.o -f elf32 ej1.asm
	gcc -m32 -o ej1 ej1.o alfalib.o

generate_ej2_asm:
	./ej2_c ej2.asm
	nasm -g -o ej2.o -f elf32 ej2.asm
	gcc -m32 -o ej2 ej2.o alfalib.o

generate_ej3_asm:
	./ej3_c ej3.asm
	nasm -g -o ej3.o -f elf32 ej3.asm
	gcc -m32 -o ej3 ej3.o alfalib.o

generate_ej4_asm:
	./ej4_c ej4.asm
	nasm -g -o ej4.o -f elf32 ej4.asm
	gcc -m32 -o ej4 ej4.o alfalib.o

generate_ej5_asm:
	./ej5_c ej5.asm
	nasm -g -o ej5.o -f elf32 ej5.asm
	gcc -m32 -o ej5 ej5.o alfalib.o

generate_ej6_asm:
	./ej6_c ej6.asm
	nasm -g -o ej6.o -f elf32 ej6.asm
	gcc -m32 -o ej6 ej6.o alfalib.o

generate_ej7_asm:
	./ej7_c ej7.asm
	nasm -g -o ej7.o -f elf32 ej7.asm
	gcc -m32 -o ej7 ej7.o alfalib.o

clean:
	@rm -rf generacion.o main_ej1.o ej1.asm ej1_c ej1.o main_ej2.o ej2.asm ej2_c ej2.o main_ej3.o ej3.asm ej3_c ej3.o main_ej4.o ej4.asm ej4_c ej4.o main_ej5.o ej5.asm ej5_c ej5.o main_ej6.o ej6.asm ej6_c ej6.o main_ej7.o ej7.asm ej7_c ej7.o ej1 ej2 ej3 ej4 ej5 ej6 ej7
