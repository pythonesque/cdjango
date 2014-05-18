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
	char	   *str;
	char const *keyword;

	char chr;
	bool boolean;
	void *list;
	Node *node;
}


%type <template>	template
%type <list>		expr_list

%type <node>		expr tag
					autoescape
					block

%type <boolean>		toggle
%type <str>			any_ident
%type <keyword>		any_keyword

%token <str>	IDENT SCONST
%token <ival>	ICONST

%token <keyword> AND_P AS_P AUTOESCAPE_P BLOCK_P BY_P COMMENT_P CSRF_P CYCLE_P
		DEBUG_P ELIF_P ELSE_P EMPTY_P END_AUTOESCAPE_P END_BLOCK_P END_COMMENT_P
		END_FILTER_P END_FOR_P END_IF_P END_IFCHANGED_P END_IFEQUAL_P
		END_IFNOTEQUAL_P END_SPACELESS_P END_VERBATIM_P END_WITH_P EXTENDS_P
		FILTER_P FIRSTOF_P FOR_P FROM_P IN_P IF_P IFCHANGED_P IFEQUAL_P
		IFNOTEQUAL_P INCLUDE_P LOAD_P NOT_P NOW_P OFF_P ON_P ONLY_P OR_P
		PARSED_P REGROUP_P SPACELESS_P SSI_P TEMPLATETAG_P URL_P VERBATIM_P
		WIDTHRATIO_P WITH_P

/* Precedence: lowest to highest */
%nonassoc IDENT
%nonassoc TAG

%%

template:
			expr_list
				{
					
				}

expr_list:
			expr_list expr
				{
					$$ = $2;
				}
			| /*EMPTY*/
				{
					$$ = NULL;
				}

expr:
			SCONST
				{
					$$ = (Node *) $1;
				}
			| ICONST
				{
					$$ = NULL;
				}
			| tag			%prec TAG
			| IDENT
				{
					$$ = (Node *) $1;
				}
		;

tag:
			autoescape
			| block
		;

autoescape: AUTOESCAPE_P toggle expr_list END_AUTOESCAPE_P
				{
					$$ = (Node *) $3;
				}
		;

block:		BLOCK_P any_ident expr_list END_BLOCK_P
				{
					$$ = (Node *) $3;
				}
		;

toggle:
			ON_P
				{
					$$ = true;
				}
			| OFF_P
				{
					$$ = false;
				}
		;

any_ident:
			any_keyword
				{
					$$ = (char *) $1;
				}
			| IDENT
				{
					$$ = $1;
				}
		;

any_keyword:
			AND_P
			| AS_P
			| AUTOESCAPE_P
			| BLOCK_P
			| BY_P
			| COMMENT_P
			| CSRF_P
			| CYCLE_P
			| DEBUG_P
			| ELIF_P
			| ELSE_P
			| EMPTY_P
			| END_AUTOESCAPE_P
			| END_BLOCK_P
			| END_COMMENT_P
			| END_FILTER_P
			| END_FOR_P
			| END_IF_P
			| END_IFCHANGED_P
			| END_IFEQUAL_P
			| END_IFNOTEQUAL_P
			| END_SPACELESS_P
			| END_VERBATIM_P
			| END_WITH_P
			| EXTENDS_P
			| FILTER_P
			| FIRSTOF_P
			| FOR_P
			| FROM_P
			| IN_P
			| IF_P
			| IFCHANGED_P
			| IFEQUAL_P
			| IFNOTEQUAL_P
			| INCLUDE_P
			| LOAD_P
			| NOT_P
			| NOW_P
			| OFF_P
			| ON_P
			| ONLY_P
			| OR_P
			| PARSED_P
			| REGROUP_P
			| SPACELESS_P
			| SSI_P
			| TEMPLATETAG_P
			| URL_P
			| VERBATIM_P
			| WIDTHRATIO_P
			| WITH_P
				{
					$$ = $1;
				}
		;

%%

void
parser_init(void)
{
}

#include "scan.c"
