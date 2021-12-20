
#########
# AUTORES:
# Pablo Ruiz Revilla
# César Ramírez Martínez
# Martín Sánchez Signorini
#########
CC = gcc
CFLAGS = -ansi -g -c
EXE = alfa
INPUT = ../ejemplos_compilador/ejemplo_funciones_vectores/funciones_vectores.alfa
OUTPREFIX = io/fv
OUTPUT = $(OUTPREFIX).asm

ELF = -f elf32
MM = -m32
OBJECT = $(OUTPREFIX).o
COMPILED = $(OUTPREFIX).exe
#########

all: $(EXE)

alfa: generacion.o hash.o y.tab.o alfa.o main.o
	$(CC) -o $@ $^

main.o: main.c hash.h types.h
	$(CC) -Wall $(CFLAGS) -o $@ $<

# FLEX
alfa.o: lex.yy.c
	$(CC) $(CFLAGS) -o $@ $<

lex.yy.c: alfa.l y.tab.h alfa.h types.h
	flex $<

# BISON
y.tab.o: y.tab.c
	$(CC) $(CFLAGS) -o $@ $<

y.tab.c: alfa.y alfa.h hash.h generacion.h types.h
	bison -dyv $<

y.tab.h: alfa.y alfa.h hash.h generacion.h types.h
	bison -dyv $<

# HASH
hash.o: hash.c hash.h types.h
	$(CC) -std=c99 -Wall $(CFLAGS) -o $@ $<

# GENERACION
generacion.o: generacion.c generacion.h types.h
	$(CC) $(CFLAGS) -c generacion.c

# CLEAN
clean: clear
	rm -rf $(EXE)

clear:
	mv alfalib.o alfalib.o.keep
	rm -rf *.o
	mv alfalib.o.keep alfalib.o

	rm -rf io/*.exe io/*.o io/*.asm
	rm -rf lex.yy.c
	rm -rf y.tab.h y.tab.c y.output

# Utilizar ./ejecutable <entrada.txt> <salida.txt>

# Usar --show-leak-kinds=all para comprobar que los errores son solo
# debidos a flex/bison reservando memoria para buffers
valgrind:
	valgrind --leak-check=full ./$(EXE) $(INPUT) $(OUTPUT)

run:
	./$(EXE) $(INPUT) $(OUTPUT)

# COMPILACION DE ASM A EXE
compile:
	nasm -g -o $(OBJECT) $(ELF) $(OUTPUT)
	gcc $(MM) -o $(COMPILED) $(OBJECT) alfalib.o
