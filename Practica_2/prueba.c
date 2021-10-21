#include <stdio.h>
#include <string.h>
#include "tok.h"

int yylex();

int main(int argc, char ** argv) {
    FILE * out = NULL;
    int ret;
    extern FILE * yyin;
    extern char * yytext;
    extern int yyleng;
    extern long yylin, yycol;
    yyin = fopen(argv[1], "r");
    if(yyin == NULL) {
        return 1;
    }
    out = fopen(argv[2], "w");
    if(out == NULL) {
        fclose(yyin);
        return 1;
    }
    while((ret = yylex()) != 0) {
        switch(ret) {
            case TOK_INICIO:
                fprintf(out, "%s\t%d\t%s\n", "TOK_INICIO", ret, yytext);
                break;
            case TOK_ENTERO:
                fprintf(out, "%s\t%d\t%s\n", "TOK_ENTERO", ret, yytext);
                break;
            case TOK_VECTOR:
                fprintf(out, "%s\t%d\t%s\n", "TOK_VECTOR", ret, yytext);
                break;
            case TOK_FIN:
                fprintf(out, "%s\t%d\t%s\n", "TOK_FIN", ret, yytext);
                break;
            case TOK_ID:
                fprintf(out, "%s\t%d\t%s\n", "TOK_ID", ret, yytext);
                break;
            case TOK_ERROR:
                if(yyleng == 1) {
                    fprintf(stderr, "****Error en [lin %ld, col %ld]: simbolo no permitido (%s)\n", yylin, yycol,
                            yytext);
                }
                fclose(yyin);
                fclose(out);
                return 1;
        }
    }
    fclose(yyin);
    fclose(out);
    return 0;
}
