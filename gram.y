%{

#include "parser.h"
#include "scanner.h"
#include "gramparse.h"

#include <stddef.h>

%}

%define api.pure full
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
%type <list>		expr_list list
					basic_expr_list basic_list


%type <node>		expr basic_expr
					tag include
					autoescape
					block
					comment
					csrf_token
					cycle
					debug
					extends

%type <boolean>		toggle opt_silent
%type <str>			any_ident
%type <keyword>		any_keyword

%token <str>	IDENT SCONST
%token <ival>	ICONST
%token			TSTART TEND

%token <keyword> AND_P AS_P AUTOESCAPE_P BLOCK_P BY_P COMMENT_P CSRF_TOKEN_P
		CYCLE_P DEBUG_P ELIF_P ELSE_P EMPTY_P END_AUTOESCAPE_P END_BLOCK_P
		END_COMMENT_P END_FILTER_P END_FOR_P END_IF_P END_IFCHANGED_P
		END_IFEQUAL_P END_IFNOTEQUAL_P END_SPACELESS_P END_VERBATIM_P
		END_WITH_P EXTENDS_P FILTER_P FIRSTOF_P FOR_P FROM_P IN_P IF_P
		IFCHANGED_P IFEQUAL_P IFNOTEQUAL_P INCLUDE_P LOAD_P NOT_P NOW_P OFF_P
		ON_P ONLY_P OR_P PARSED_P REGROUP_P SILENT_P SPACELESS_P SSI_P
		TEMPLATETAG_P URL_P VERBATIM_P WIDTHRATIO_P WITH_P

%%

template:
			basic_expr_list
				{}
			| basic_expr_list extends expr_list
				{}
			| basic_expr_list tag_expr expr_list
				{}

basic_expr_list:
			basic_expr_list basic_expr
				{
					$$ = $2;
				}
			| /* EMPTY */
				{
					$$ = NULL;
				}

extends:	EXTENDS_P SCONST
				{
					$$ = (Node *) $1;
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

tag_expr:
			include
			| tag
		;

basic_expr:
			SCONST
				{
					$$ = (Node *) $1;
				}
			| ICONST
				{
					$$ = NULL;
				}
			| IDENT
				{
					$$ = (Node *) $1;
				}
			| basic_list
				{
					$$ = (Node *) $1;
				}
			| '(' basic_expr ')'
				{
					$$ = $2;
				}
		;

expr:
			SCONST
				{
					$$ = (Node *) $1;
				}
			| ICONST
				{
					$$ = NULL;
				}
			| IDENT
				{
					$$ = (Node *) $1;
				}
			| list
				{
					$$ = (Node *) $1;
				}
			| include
			| tag
			| '(' expr ')'
				{
					$$ = $2;
				}
		;

basic_list:
			'['	basic_expr_list ']'
				{
					$$ = $2;
				}
		;

list:
			'[' expr_list ']'
				{
					$$ = $2;
				}
		;

include:
			TSTART template TEND
				{
					$$ = NULL;
				}
		;

tag:
			autoescape
			| block
			| comment
			| csrf_token
			| cycle
			| debug
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

comment:	COMMENT_P expr_list END_COMMENT_P
				{
					$$ = NULL;
				}
		;

csrf_token:	CSRF_TOKEN_P
				{
					$$ = (Node *) $1;
				}
		;

cycle:	CYCLE_P list
				{
					$$ = (Node *) $2;
				}
		| CYCLE_P list AS_P any_ident opt_silent
				{
					$$ = (Node *) $2;
				}
		;

debug:	DEBUG_P
				{
					$$ = (Node *) $1;
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

opt_silent:
			SILENT_P
				{
					$$ = true;
				}
			| /* EMPTY */
				{
					$$ = false;
				}
		;

any_keyword:
			AND_P
			| AS_P
			| AUTOESCAPE_P
			| BLOCK_P
			| BY_P
			| COMMENT_P
			| CSRF_TOKEN_P
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
			| SILENT_P
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
