%{
#include "tokens.h"
#include "y.tab.h" 
%}

alpha [a-zA-Z]
digit [0-9]

%%
"if"					{return IF;}
"then"					{return THEN;}
"else"					{return ELSE;}
"print"					{return print;}
"exit"					{return exit_command;}
"for"					{return FOR;}
"while"					{return WHILE;}
"integer"|"boolean"|"float"|"void"	{return TYPE;}
[a-zA-Z]		   		{yylval.id = yytext[0]; return identifier;}
[0-9]+					{yylval.num=atoi(yytext); return number;}
"+="|"-="|"*="|"/="|"%="		{return yytext[0];}
[+=\-/*;]				{return yytext[0];}
">="					{return GE;}
"<="					{return LE;}
"=="					{return EQ;}
"!="					{return NE;}
"||"					{return OR;}
"&&"					{return AND;}
[ \t\n]+				;
[{}()<>]					{return yytext[0];}
.					{ECHO; yyerror ("unexpected character");}

%%

int yywrap() {
        return 1;
}

