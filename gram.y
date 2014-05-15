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
%type <list>		segment_list
%type <node>		segment cdata_segment /*var_segment*/ tag_segment stmt

%token <str>	IDENT FCONST SCONST
%token <ival>	ICONST
%token			VSTART VEND TSTART TEND

%%

template:
			segment_list
				{
					
				}

segment_list:
			segment_list segment
				{
					if ($2 != NULL) {
						$$ = $2;
					} else {
						$$ = $1;
					}
				}
			| segment
				{
					if ($1 != NULL) {
						$$ = $1;
					} else {
						$$ = NULL;
					}
				}
		;

segment:
			cdata_segment
				{
					$$ = $1;
				}/*
			| var_segment
				{
					$$ = $1;
				}*/
			| tag_segment
				{
					$$ = $1;
				}
		;

cdata_segment:
			SCONST
				{
					$$ = (Node *) $1;
				}
		;

/*var_segment:
			VSTART VEND*/

tag_segment:
			TSTART stmt TEND
				{
					$$ = (Node *) $2;
				}
		;

stmt:
			SCONST
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
