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
%type <list>		stmt_list
%type <node>		stmt
%type <boolean>		toggle

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
			| AUTOESCAPE_P toggle stmt_list END_AUTOESCAPE_P
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

%%

void
parser_init(void)
{
}

#include "scan.c"
