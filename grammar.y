%{
void yyerror (char* s);
#include <stdio.h>  /* C declaration used in actions */
#include <stdlib.h>
int symbols[52];
int symbolVal( char symbol);
void updateSymbolVal(char symbol,  int val );
%}

/* yacc definition */

%union {int num; char id; }
%token print
%token exit_command
%token <num> number
%token <id> identifier
%token IF THEN ELSE 
%token LE GE EQ NE OR AND
%token TYPE
%token FOR WHILE
%type <num> line exp term
%type <id> assignment
%left '+''-'
%left '*''/''%'
%left AND OR
%left '<''>'LE GE EQ NE
%% 
/* descriptions of expected inputs     corresponding actions (in C) */

line    : assignment ';' 		{printf("assignment accepted\n");}
	| exit_command 	';'	{exit(EXIT_SUCCESS);}
	| print exp ';'		{printf("Printing %d\n", $2);}
	| line print exp ';'         	{printf("Printing %d\n", $3);}  
	| shorthand ';'    		{printf("shorthand opeartor accepted\n");}
	| condition			{printf("condition accepted\n");}
	| line condition    		{printf("condition accepted\n");}
	| function			{printf("Function statement accepted\n");}
	| line function			{printf("Function statement accepted\n");}
	| forLoop			{printf("For loop statement accepted\n");}
	| line forLoop			{printf("For loop statement accepted\n");}
	| whileLoop			{printf("while loop statement accepted\n");}
	| line whileLoop		{printf("while loop statement accepted\n");}
	| line exit_command ';'          {printf("Successful Exit"); exit(0);}
;

assignment : identifier '=' exp  { updateSymbolVal($1,$3); }
	   ;

shorthand : identifier '+=' exp    { updateSymbolVal($1, $1+$3); }
	   | identifier '-=' exp   { updateSymbolVal($1, $1-$3); }
           | identifier '*=' exp    { updateSymbolVal($1, $1*$3); }
           | identifier '/=' exp    { updateSymbolVal($1, $1/$3); }
           | identifier '%=' exp    { updateSymbolVal($1, $1%$3); }
	   			;
exp    	: term                  {$$ = $1;}
	| exp '+' exp          {$$ = $1 + $3;}
    | exp '-' exp          {$$ = $1 - $3;}
	| exp '*' exp		{$$ = $1 * $3;}
	| exp '/' exp     	{$$ = $1 / $3;}
	| exp '%' exp		{$$ = $1 % $3;}
	| exp'+''+'
	| exp'-''-'
	;

term   	: number                {$$ = $1;}
	| identifier		{$$ = symbolVal($1);}
        ;

/* parser code for if-then-else statement */
condition : IF exp1 THEN statement';' ELSE statement';'  
	  | IF exp1 THEN statement';' 
	  ;

exp1 : exp '<' exp
     | exp '>' exp
     | exp LE exp
     | exp GE exp
     | exp NE exp
     | exp EQ exp
     | exp OR exp
     | exp AND exp
     | term
	;
statement : condition
	  | exp 
	  | assignment 
	  ;
/* parser for function definition */
function : TYPE identifier '(' parameter ')' '{' block '}'
	 ;

parameter  : parameter ',' TYPE identifier
	   | TYPE identifier
	   |
	   ;

/* parser code for loop statement using for */
forLoop : FOR '(' TYPE assignment ';' exp1 ';' exp ')' '{' block '}'
	;

block : 
      | statement ';' block
     ;

/* parser code for loop statement using while */
whileLoop : WHILE '(' exp1 ')' '{' block '}'
	  ;

%%                    
 /* C code */

int computeSymbolIndex(char token)
{
	int idx = -1;
	if(islower(token)) {
		idx = token - 'a' + 26;
	} else if(isupper(token)) {
		idx = token - 'A';
	}
	return idx;
} 

/* returns the value of a given symbol */
int symbolVal(char symbol)
{
	int bucket = computeSymbolIndex(symbol);
	return symbols[bucket];
}

/* updates the value of a given symbol */
void updateSymbolVal(char symbol, int val)
{
	int bucket = computeSymbolIndex(symbol);
	symbols[bucket] = val;
}

int main (void) {
	/* init symbol table */
	int i;
	for(i=0; i<52; i++) {
		symbols[i] = 0;
	}
	printf("Enter an expression : \n");
	return yyparse ( );
}

void yyerror (char *s) {fprintf (stderr, "%s\n", s);} 
