#include <stdio.h>
#include "tokens.h"

extern int yylex(), yylineno;
extern char* yytext;

int main(void) {
        int token;
        // token mapper
        char token_map[17][50] = {
        	"Integer Value",
        	"Float point Value",
        	"Boolean Value",
        	"Arithmetic Operator",
        	"Logical Operator",
        	"Assignment Operator",
        	"Relational Operator",
        	"Shorthand Operator",
        	"Conditional Operator",
        	"Comparator",
        	"Funtion Signature",
        	"Looping Keyword",
        	"Conditional Statement",
        	"Delimeter",
        	"Identifier",
        	"Keyword",
        	"String"
		};
        token = yylex();
        while(token) {
        		printf("Token (%s) is ", yytext);
                printf("%s\n", token_map[token-1]);
                token = yylex();
        }
        return 0;
}
