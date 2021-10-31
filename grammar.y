// Submitted By - ASRA JAWAID (18COB264)

%{
void yyerror (char* s);
#include <string.h>
#include <stdio.h>  /* C declaration used in actions */
#include <stdlib.h>

/* 
Variables needed for internal opeartions.
*/
int symbols[52]; // to store the varibales value
char stack[50][10]; // stack for intermediate code
int sp = -1; // stack pointer
char temporary[2] = "t"; // for temporary variable generted for 3-address code
int labelIndex = 0; // to define the label for code
int suffix = 0; // for temporary variable

int stackTrace = 0; // for debugging

/* 
All helper functions. 
*/
int symbolVal( char symbol);
void insert(char*);
void reset();
void popTop();
void input_prompt();
void insertInt(int);
void intermediateCodeGen();
void showLabel();
void addLabel();
void resetLabel();
void removeLastLabel();
void ifCodeGen();
void uniaryCodeGen();
void assignmentCodeGen(char*);
void updateSymbolVal(char symbol,  int val );
%}

/* Yacc definition. */

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
/* Descriptions of expected inputs  -->   corresponding actions (in C). */

line    : assignment ';' 		{reset(); resetLabel(); printf("assignment accepted\n"); input_prompt(); }
	| line assignment ';' 		{reset(); resetLabel(); printf("assignment accepted\n"); input_prompt(); }
	| exit_command 	';'			{reset(); resetLabel(); exit(EXIT_SUCCESS); }
	| print exp ';'				{reset(); resetLabel(); printf("Printing %d\n", $2); input_prompt(); }
	| line print exp ';'        {reset(); resetLabel(); printf("Printing %d\n", $3); input_prompt(); }  
	| shorthand ';'    			{reset(); resetLabel(); printf("shorthand opeartor accepted\n"); input_prompt(); }
	| line shorthand ';'    	{reset(); resetLabel(); printf("shorthand opeartor accepted\n"); input_prompt(); }
	| condition					{reset(); resetLabel(); printf("condition accepted\n"); input_prompt(); }
	| line condition    		{reset(); resetLabel(); printf("condition accepted\n"); input_prompt(); }
	| function					{reset(); resetLabel(); printf("Function statement accepted\n"); input_prompt(); }
	| line function				{reset(); resetLabel(); printf("Function statement accepted\n"); input_prompt(); }
	| forLoop					{reset(); resetLabel(); printf("For loop statement accepted\n"); input_prompt(); }
	| line forLoop				{reset(); resetLabel(); printf("For loop statement accepted\n"); input_prompt(); }
	| whileLoop					{reset(); resetLabel(); printf("while loop statement accepted\n"); input_prompt(); }
	| line whileLoop			{reset(); resetLabel(); printf("while loop statement accepted\n"); input_prompt(); }
	| line exit_command ';'   	{reset(); resetLabel(); printf("Successful Exit"); exit(0);}
;

assignment : identifier '=' exp  
			{ updateSymbolVal($1,$<num>3); 
			assignmentCodeGen(&$1);
			}
			| identifier '=' '(' exp ')'  '+' {insert("+");}  '(' exp ')'	
			{ updateSymbolVal($1,$<num>4 + $<num>9); 
			intermediateCodeGen(); 
			assignmentCodeGen(&$1); 
			}
			| identifier '=' '(' exp ')'  '-' {insert("-");}  '(' exp ')'	
			{ updateSymbolVal($1,$<num>4 - $<num>9); 
			intermediateCodeGen(); 
			assignmentCodeGen(&$1); 
			}
			| identifier '=' '(' exp ')'  '*' {insert("*");}  '(' exp ')'	
			{ updateSymbolVal($1,$<num>4 * $<num>9); 
			intermediateCodeGen(); 
			assignmentCodeGen(&$1); 
			}
			| identifier '=' '(' exp ')'  '/' {insert("/");}  '(' exp ')'	
			{ updateSymbolVal($1,$<num>4 / $<num>9); 
			intermediateCodeGen(); 
			assignmentCodeGen(&$1); 
			}
			| identifier '=' '(' exp ')'  '%' {insert("%");}  '(' exp ')'	
			{ updateSymbolVal($1,$<num>4 % $<num>9); 
			intermediateCodeGen(); 
			assignmentCodeGen(&$1); 
			}
			| identifier '=' '(' exp ')'  '+' {insert("+");}  term
			{ updateSymbolVal($1,$<num>4 + $<num>8); 
			intermediateCodeGen(); 
			assignmentCodeGen(&$1); 
			}
			| identifier '=' '(' exp ')'  '-' {insert("-");}  term	
			{ updateSymbolVal($1,$<num>4 - $<num>8); 
			intermediateCodeGen(); 
			assignmentCodeGen(&$1); 
			}
			| identifier '=' '(' exp ')'  '*' {insert("*");}  term
			{ updateSymbolVal($1,$<num>4 * $<num>8); 
			intermediateCodeGen(); 
			assignmentCodeGen(&$1); 
			}
			| identifier '=' '(' exp ')'  '/' {insert("/");}  term	
			{ updateSymbolVal($1,$<num>4 / $<num>8); 
			intermediateCodeGen(); 
			assignmentCodeGen(&$1); 
			}
			| identifier '=' '(' exp ')'  '%' {insert("%");}  term	
			{ updateSymbolVal($1,$<num>4 % $<num>8); 
			intermediateCodeGen(); 
			assignmentCodeGen(&$1); 
			}
	  		;

shorthand : identifier { insert(&$1); } '+=' { insert("+"); } exp    	
	{ updateSymbolVal($1, symbolVal($1)+$<num>5); 
	intermediateCodeGen();  
	assignmentCodeGen(&$1);
	}
	| identifier { insert(&$1); } '-=' { insert("-"); } exp   		
	{ updateSymbolVal($1, symbolVal($1)-$<num>5); 
	intermediateCodeGen(); 
	assignmentCodeGen(&$1);
	}
    | identifier { insert(&$1); } '*=' { insert("*"); } exp    		
	{ updateSymbolVal($1, symbolVal($1)*$<num>5); 
	intermediateCodeGen(); 
	assignmentCodeGen(&$1);
	}
    | identifier { insert(&$1); } '/=' { insert("/"); } exp    		
	{ updateSymbolVal($1, symbolVal($1)/$<num>5); 
	intermediateCodeGen(); 
	assignmentCodeGen(&$1);
	}
    | identifier { insert(&$1); } '%=' { insert("%"); } exp    		
	{ updateSymbolVal($1, symbolVal($1)%$<num>5); 
	intermediateCodeGen(); 
	assignmentCodeGen(&$1);
	}
	;
	
exp : term             						
	{ $$ = $1; }
	| exp '+' {insert("+");} exp          	
	{ $$ = $<num>1 + $<num>4; intermediateCodeGen(); }
    | exp '-' {insert("-");} exp          	
	{ $$ = $<num>1 - $<num>4; intermediateCodeGen(); }
	| exp '*' {insert("*");} exp		   	
	{ $$ = $<num>1 * $<num>4; intermediateCodeGen(); }
	| exp '/' {insert("/");} exp     		
	{ $$ = $<num>1 / $<num>4; intermediateCodeGen(); }
	| exp '%' {insert("%");} exp			
	{ $$ = $<num>1 % $<num>4; intermediateCodeGen(); }
	| exp'+''+' { insert("++"); uniaryCodeGen(); }
	| exp'-''-' { insert("--"); uniaryCodeGen(); }
	;

term   	: number                {$$ = $1; insertInt($1);}
	| identifier				{$$ = symbolVal($1); insert(&$1);}
        ;

/* parser code for if-then-else statement */
condition : IF exp1 THEN 
	{ ifCodeGen(); } 
	statement ELSE  
	{ showLabel(); }  
	statement 
	| IF exp1 THEN 
	{ ifCodeGen(); } 
	'{' block '}' ELSE  
	{ showLabel(); }  
	'{' block '}'  
	;

exp1 : exp '<' { insert("<"); } exp						{ intermediateCodeGen(); }
     | exp '>' { insert(">"); } exp						{ intermediateCodeGen(); }
     | exp LE { insert("<="); } exp						{ intermediateCodeGen(); }
     | exp GE { insert(">="); } exp						{ intermediateCodeGen(); }
     | exp NE { insert("!="); } exp						{ intermediateCodeGen(); }
     | exp EQ { insert("=="); } exp						{ intermediateCodeGen(); }
     | exp OR { insert("||"); } exp						{ intermediateCodeGen(); }
     | exp AND { insert("&&"); } exp					{ intermediateCodeGen(); }
     | term
	;
	
statement : condition			{  }
	  | exp 		';'			{  }
	  | assignment 	';'			{  }
	  | forLoop					{  }
	  | whileLoop				{  }
	  ;   
	  
/* parser for function definition */
function : TYPE identifier '(' parameter ')' '{' block '}' {printf("goto calling function\n"); }
	 ;

parameter  : parameter ',' TYPE identifier
	   | TYPE identifier
	   |
	   ;

/* parser code for loop statement using for */
forLoop : FOR '(' TYPE assignment ';' {addLabel(); showLabel();} exp1 {ifCodeGen();} ';' exp ')' '{' block '}' 
	{ 
	removeLastLabel(); 
	printf("goto Label %d\n", labelIndex);
	addLabel(); 
	showLabel();
	}
	;

block : 
      | statement block
     ;

/* parser code for loop statement using while */
whileLoop : WHILE '(' {addLabel(); showLabel();} exp1 {ifCodeGen();} ')' '{' block '}'
		{ 
		removeLastLabel(); 
		showLabel();
		removeLastLabel();
		printf("goto Label %d\n", labelIndex);
		}
	  ;

%%                    
 /* C code */

/**
Helper functions.
*/

void reset() {
	sp = -1;
	suffix = 0;
}

void resetLabel() {
	labelIndex = 0;
}

/* Function dedicated to assignment and shorthand operators. */
void assignmentCodeGen(char *ch) {
	printf("---------------------------------------\n");
	printf("%s = %s\n", ch, stack[sp--]);
	printf("---------------------------------------\n");
	sp--;
}

/* Function dedicated to uniary operators. */
void uniaryCodeGen() {
	printf("---------------------------------------\n");
	printf("%s%s\n", stack[sp-1], stack[sp]);
	printf("---------------------------------------\n");
	sp -= 2;
}

/* Function responsible to generate 3-address intermediate code. */
void intermediateCodeGen() {
	printf("---------------------------------------\n");
	char str[10]; 
	strcpy(temporary, "t");
	sprintf(str,"%d", suffix);
	strcat(temporary, str);
	printf("%s = ", temporary);
	int to = sp-2;
	int p = sp;
	while(p >= to) {
		printf("%s ", stack[to++]);
		sp--;
	} 
	printf("\n---------------------------------------\n");
	insert(temporary);
	// increment suffix
	suffix = (suffix+1)%3;
}

/* Function to remove from the top of stack. */
void popTop() {
	char str[10]; 	
	strcpy(temporary, "t");
	sprintf(str,"%d", suffix);
	strcat(temporary, str);
	printf("%s = %s", temporary, stack[sp--]);
	insert(temporary);
}

/* Function to insert a string in the stack. */
void insert(char *val) {
	if(stackTrace == 1)
	printf("Inserting %s at %d\n", val, sp+1);
	strcpy(stack[++sp], val);
}

/* Function to insert an integer in the stack. */
void insertInt(int num) {
	char str[10]; 
	sprintf(str,"%d", num);
	insert(str);
}

/* Basic Hash Function. */
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


/* All the helper function for label genration
   starts here.
*/

void addLabel() {	
	labelIndex++;
}

void ifCodeGen() {
	addLabel();
	printf("if not %s then goto Label %d\n", temporary, labelIndex);
}

void showLabel() {
	printf("Label %d:\n", labelIndex);
}

void removeLastLabel() {
	labelIndex--;
}

/* Returns the value of a given symbol. */
int symbolVal(char symbol)
{
	int bucket = computeSymbolIndex(symbol);
	return symbols[bucket];
}

/* Updates the value of a given symbol. */
void updateSymbolVal(char symbol, int val)
{
	/*char *temp = "";
	strncat(temp, &symbol, 1);
	insert(temp);
	*/
	int bucket = computeSymbolIndex(symbol);
	symbols[bucket] = val;
}

void input_prompt() {
	printf("\nEnter an expression or 'exit cmd' to exit: \n");
}

int main (void) {
	/* init symbol table */
	int i;
	for(i=0; i<52; i++) {
		symbols[i] = 0;
	}
	printf("To turn on stack trace enter 1 : ");
	scanf("%d", &stackTrace);
	printf("\nEnter an expression or 'exit cmd' to exit: \n");
	return yyparse ( );
}

void yyerror (char *s) {fprintf (stderr, "%s\n", s);} 
