
#######################################
# AUTORES:
# Pablo Ruiz Revilla
# César Ramírez Martínez
# Martín Sánchez Signorini
#######################################
CC = gcc
CFLAGS = -ansi -g -c
EXE = alfa
OUTPREFIX = io/out
INPUT = io/in.alfa
OUTPUT = $(OUTPREFIX).asm

ELF = -f elf32
MM = -m32
OBJECT = $(OUTPREFIX).o
COMPILED = $(OUTPREFIX).exe
#######################################

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


#######################################
# TESTS DE COMPILACION
#######################################

# Colores
COL_RESET	= \033[0m
COL_BLINK	= \033[5m
COL_GREEN	= \033[32m
COL_YELLOW	= \033[33m
COL_MAGENTA	= \033[35m
COL_RED		= \033[31m

FORMAT_INFO	= "$(COL_MAGENTA)"
FORMAT_TITLE= "$(COL_MAGENTA)"
FORMAT_PROC	= "$(COL_YELLOW)"
FORMAT_VAR	= "$(COL_GREEN)"
FORMAT_RESET= "$(COL_RESET)"
FORMAT_OK	= "$(COL_GREEN)$(COL_BLINK)"
FORMAT_ERROR= "$(COL_RED)$(COL_BLINK)"

# Nombres de ficheros relativos a T_DIR
# Usar el mismo en toda subcarpeta
T_DIRS 	= io/test_compile
TO_TEST = test
T_ALFA 	= $(TO_TEST).alfa
T_ASM	= $(TO_TEST).asm
T_OBJ	= $(TO_TEST).o
T_EXE	= $(TO_TEST).exe
T_CMP	= expected.txt
T_INP	= input.txt
T_OUT	= out.txt

# No se puede incluir T_ASM pues el wildcard no encuentra
W_DIRS	= $(wildcard $(T_DIRS)/*/)
W_ALFA	= $(foreach f, $(W_DIRS), $(f)$(T_ALFA))
W_ASMS	= $(foreach f, $(W_DIRS), $(f)$(T_ASM))
W_EXES	= $(foreach f, $(W_DIRS), $(f)$(T_EXE))
W_OBJS	= $(foreach f, $(W_DIRS), $(f)$(T_OBJ))
W_OUTS	= $(foreach f, $(W_DIRS), $(f)$(T_OUT))


tests_comp: pre_t_asm $(W_ASMS) pos_t_asm pre_t_exe $(W_EXES) pos_t_exe

pre_t_asm:
	@echo $(FORMAT_INFO)
	@echo Running all tests
	@echo Starting ALFA compilation to ASM
	@echo Now checking syntax and semantics
	@echo -------------------------------- $(FORMAT_RESET)

pos_t_asm:
	@echo $(FORMAT_INFO)
	@echo Finished checking syntax and semantics 
	@echo -------------------------------- $(FORMAT_RESET)

pre_t_exe:
	@echo $(FORMAT_INFO)
	@echo Starting ASM compilation to EXE
	@echo Now checking correct execution
	@echo -------------------------------- $(FORMAT_RESET)

pos_t_exe:
	@echo $(FORMAT_INFO)
	@echo Finished checking correct execution
	@echo -------------------------------- $(FORMAT_RESET)
	@touch $(W_ALFA)

# TEST ASM
$(T_DIRS)/%/$(T_ASM): $(T_DIRS)/%/$(T_ALFA) $(EXE)
	@echo
	@echo $(FORMAT_PROC):: Alfa compilation of: $(FORMAT_VAR) $< $(FORMAT_RESET)
	./$(EXE) $< $@

# TEST EXE
# Compilar y ejecutar exe
$(T_DIRS)/%/$(T_EXE): $(T_DIRS)/%/$(T_OBJ)
	@echo $(FORMAT_PROC):: ASM compilation of: $(FORMAT_VAR) $< $(FORMAT_RESET)
	gcc $(MM) -o $@ $< alfalib.o

	@echo $(FORMAT_PROC):: Execution of $(FORMAT_VAR) $@ $(FORMAT_RESET)

	@(echo "" | cat $(wildcard $(T_DIRS)/$*/$(T_INP)) | ./$@ > $(T_DIRS)/$*/$(T_OUT))|| true

	@echo $(FORMAT_PROC):: Verification of $(FORMAT_VAR) $@ $(FORMAT_RESET)

	@echo "diff -bB $(T_DIRS)/$*/$(T_OUT) $(T_DIRS)/$*/$(T_CMP)"
	@( \
	diff -bB $(T_DIRS)/$*/$(T_OUT) $(T_DIRS)/$*/$(T_CMP) || \
	(echo $(FORMAT_PROC):: Result: $(FORMAT_ERROR) ERROR  $(FORMAT_RESET); \
	exit 1; ) && \
	echo $(FORMAT_PROC):: Result: $(FORMAT_OK) OK  $(FORMAT_RESET)) || true\

	@echo $(FORMAT_PROC):::::::::::::::::::::$(FORMAT_RESET)

# Compilar o
$(T_DIRS)/%/$(T_OBJ): $(T_DIRS)/%/$(T_ASM)
	@echo
	@echo $(FORMAT_PROC):: Starting test: $(FORMAT_VAR) $* $(FORMAT_RESET)
	nasm -g -o $@ $(ELF) $<

#######################################
# TESTS DE ANALISIS
#######################################

A_DIR_OK = io/test_ok
A_DIR_ER = io/test_error

A_NAME_OK	= $(wildcard $(A_DIR_OK)/*.alfa)
A_NAME_ER	= $(wildcard $(A_DIR_ER)/*.alfa)

A_OUT_OK	= $(foreach f, $(A_NAME_OK), $(f).asm)
A_OUT_ER	= $(foreach f, $(A_NAME_ER), $(f).asm)


tests_anal: $(EXE) pre_anal_error $(A_OUT_ER) pos_anal_error pre_anal_ok $(A_OUT_OK) pos_anal_ok

pre_anal_error:
	@echo $(FORMAT_INFO)
	@echo Starting to verify expected semantic errors
	@echo -------------------------------- $(FORMAT_RESET)

pos_anal_error:
	@echo $(FORMAT_INFO)
	@echo Finished verifying expected semantic errors
	@echo -------------------------------- $(FORMAT_RESET)

pre_anal_ok:
	@echo $(FORMAT_INFO)
	@echo Starting to verify correct semantics
	@echo -------------------------------- $(FORMAT_RESET)

pos_anal_ok:
	@echo $(FORMAT_INFO)
	@echo Finished verifying correct semantics
	@echo -------------------------------- $(FORMAT_RESET)
	@touch $(A_NAME_OK) $(A_NAME_ER)

$(A_DIR_OK)/%.asm: $(A_DIR_OK)/%
	@echo
	@echo $(FORMAT_PROC):: Alfa compilation of: $(FORMAT_VAR) $< $(FORMAT_RESET)
	@echo $(FORMAT_PROC):: Expected: $(FORMAT_OK) OK $(FORMAT_RESET)
	
	@echo "./$(EXE) $< $@"
	@(./$(EXE) $< $@ || (\
	echo $(FORMAT_PROC):: Result: $(FORMAT_ERROR) ERROR $(FORMAT_RESET); \
	exit 1 )) && \
	echo $(FORMAT_PROC):: Result: $(FORMAT_OK) OK $(FORMAT_RESET) \
	|| true

$(A_DIR_ER)/%.asm: $(A_DIR_ER)/%
	@echo
	@echo $(FORMAT_PROC):: Alfa compilation of: $(FORMAT_VAR) $< $(FORMAT_RESET)
	@echo $(FORMAT_PROC):: Expected: $(FORMAT_ERROR) ERROR $(FORMAT_RESET)

	@echo "./$(EXE) $< $@"
	@(./$(EXE) $< $@ || (\
	echo $(FORMAT_PROC):: Result: $(FORMAT_ERROR) ERROR $(FORMAT_RESET); \
	exit 1 )) && \
	echo $(FORMAT_PROC):: Result: $(FORMAT_OK) OK $(FORMAT_RESET) \
	|| true

# CLEAN TESTS
test_clean:
	rm -rf $(W_ASMS)
	rm -rf $(W_OBJS)
	rm -rf $(W_EXES)
	rm -rf $(A_OUT_OK) $(A_OUT_ER)

turbo_test: clean test_clean tests_comp