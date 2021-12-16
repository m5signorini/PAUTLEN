
#########
# AUTORES:
# Pablo Ruiz Revilla
# César Ramírez Martínez
# Martín Sánchez Signorini
#########
CC = gcc
CFLAGS = -ansi -pedantic -c
EXE = pruebaSintactica
#########

all: $(EXE)

pruebaSintactica: y.tab.o alfa.o main.o
	$(CC) -o $@ $^

main.o: main.c
	$(CC) -Wall $(CFLAGS) -o $@ $<

# FLEX
alfa.o: lex.yy.c
	$(CC) $(CFLAGS) -o $@ $<

lex.yy.c: alfa.l y.tab.h
	flex $<

# BISON
y.tab.o: y.tab.c
	$(CC) $(CFLAGS) -o $@ $<

y.tab.c: alfa.y
	bison -dyv $<

y.tab.h: alfa.y
	bison -dyv $<

# CLEAN

clean:
	rm -rf *.o
	rm -rf $(EXE)
	rm -rf lex.yy.c
	rm -rf y.tab.h y.tab.c y.output

# Utilizar ./ejecutable <entrada.txt> <salida.txt>
