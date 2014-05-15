%{

#include "parser.h"
#include "scanner.h"
#include "gramparse.h"

#include <stddef.h>

%}

%pure-parser
%expect 0
%locations

%parse-param {yyscan_t yyscanner}
%lex-param {yyscan_t yyscanner}

%union
{
	/* YYSTYPE 	yystype; */
	/* these fields must match YYSTYPE */
	int			ival;
	char const *str;

	char chr;
	bool boolean;
	void *list;
	Node *node;
}


%type <template>	template
%type <list>		stmt_list
%type <node>		stmt

%token <str>	IDENT FCONST SCONST
%token <ival>	ICONST

%%

template:
			stmt_list
				{
					
				}

stmt_list:
			stmt_list stmt
				{
					$1;
					$$ = $2;
				}
			| /* empty */
				{
					$$ = NULL;
				}

stmt:
			SCONST
				{
					$$ = (Node *) $1;
				}
			| ICONST
				{
					$$ = (Node *) $1;
				}
			| IDENT
				{
					$$ = (Node *) $1;
				}
		;

%%

void
parser_init(void)
{
}

#include "scan.c"
