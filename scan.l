%{
#include "scanner.h"

/* Avoid exit() on fatal scanner errors (a bit ugly -- see yy_fatal_error) */
#undef fprintf
#define fprintf(file, fmt, msg) yyerror(yyget_lloc(yyscanner), yyscanner, msg)

#define YY_EXTRA_TYPE yy_extra_type *

static FILE *include_file(yyscan_t *yyscanner);

%}

%option reentrant
%option bison-bridge
%option bison-locations
%option 8bit
%option never-interactive
%option stack
%option nodefault
%option noinput
%option nounput
%option noyy_top_state
%option noyy_scan_bytes
%option noyy_scan_string
%option noyyget_leng
%option noyyget_text
%option noyyget_lineno
%option noyyset_lineno
%option noyyget_out
%option noyyset_out
%option noyyget_lval
%option noyyset_lval
%option noyyset_lloc
%option noyyget_debug
%option noyyset_debug
%option noyywrap
	/* %option noyyfatal_error */
%option noyyalloc
%option noyyrealloc
%option noyyfree
%option warn

%x xt
%x xq
%x xd

cdata			[^{]*

xtstart			\{\%
xtstop			\%\}
xtfail			\{[^%]

space			[ \t\n\r\f]
newline			[\n\r]
non_newline		[^\n\r]

comment			("#"{non_newline}*)

whitespace		({space}+|{comment})

/*
 * dquote			"
 * dquotestop		{dquote}{whitespace}*
 * dquotecontinue	{dquote}{whitespace_with_newline}{dquote}
 *
 * xdstart			{dquote}
 * xdescape		[\\][^0-7]
 * xxdoctesc		[\\][0-7]{1,3}
 * xxdhexesc		[\\]x[0-9A-Fa-f]{1,2}
 * xxdunicode		[\\](u[0-9A-Fa-f]{4}|U[0-9A-Fa-f]{8})
 * xxdunicodefail	[\\](u[0-9A-Fa-f]{0,3}|U[0-9A-Fa-f]{0,7})
 */

quote			'
quotestop		{quote}

dquote			"\""

xqstart			{quote}
xqinside		[^\\']+
xqescape		\\([^\n]|\n)

xdstart			{dquote}
xdstop			{dquote}
xdinside		[^\\"]+

digit			[0-9]
ident_start		[A-Za-z\200-\377_]
ident_cont		[A-Za-z\200-\377_0-9\$]

identifier		{ident_start}{ident_cont}*

integer			{digit}+
/*
 * decimal			(({digit}*\.{digit}+)|({digit}+\.{digit}*))
 * decimalfail		{digit}+\.\.
 * real			({integer}|{decimal})[Ee][-+]?{digit}+
 * realfail1		({integer}|{decimal})[Ee]
 * realfail2		({integer}|{decimal})[Ee][-+]
*/

other			.

%%

<INITIAL>\{ |
<INITIAL>{cdata}		{
		printf("%s", yyextra->literal);
		yyfree(yyextra->literal, yyscanner);
		yyextra->literal = strndup(yytext, yyleng + 1);
	}

<INITIAL>{xtstart}	{
	printf("%s", yyextra->literal);
	BEGIN(xt);
	return SCONST;
}

<INITIAL>{xtfail}	{
		yyless(1);
		printf("%s", yyextra->literal);
		yyfree(yyextra->literal, yyscanner);
		yyextra->literal = strndup(yytext, yyleng + 1);
	}

<xt>{whitespace}	{
		/* ignore */
	}

<xt>{xtstop}	{
		if (yyextra->include) {
			yyextra->error = true;
			yyerror(yylloc, yyscanner, "include requires a filename\n");
			yyterminate();
		} else {
			yyfree(yyextra->literal, yyscanner);
			yyextra->literal = strdup("");
			BEGIN(INITIAL);
		}
	}

<xt>{xqstart}	{
		yyfree(yyextra->literal, yyscanner);
		yyextra->literal = strdup("");
		BEGIN(xq);
	}


<xt>{xdstart}	{
		yyfree(yyextra->literal, yyscanner);
		yyextra->literal = strdup("");
		BEGIN(xd);
	}

<xq>{quotestop} |
<xd>{xdstop}	{
		BEGIN(xt);
		if (yyextra->include) {
			yyin = include_file(yyscanner);
			if (yyin == NULL) {
				yyterminate();
			}
			yyfree(yyextra->literal, yyscanner);
			yyextra->literal = strdup("");
		} else {
			printf("%s", yyextra->literal);
			return SCONST;
		}
	}

<xq>{xqinside}	|
<xd>{xdinside}	{
		if (!yyextra->include) {
			printf("%s", yyextra->literal);
		}
		yyfree(yyextra->literal, yyscanner);
		yyextra->literal = strndup(yytext, yyleng + 1);
	}

<xq,xd>{xqescape}	{
		if (!yyextra->include) {
			printf("%s", yyextra->literal);
		}
		yytext[0] = yytext[1];
		yytext[1] = '\0';
		yyfree(yyextra->literal, yyscanner);
		yyextra->literal = strndup(yytext, yyleng + 1);
	}

<xt>include		{	yyextra->include = 1; }

<xt>{identifier}	{
	yyextra->include = 0;
	ScanKeyword const *keyword;

	/* Is it a keyword? */
	keyword = ScanKeywordLookup(yytext,
								yyextra->keywords,
								yyextra->num_keywords);

	if (keyword != NULL)
	{
		yylval->keyword = keyword->name;
		printf("(KEYWORD: %s)", keyword->name);
		return keyword->value;
	}

	printf("(IDENT: %s)", yytext);
	return IDENT;
}

<xt>{integer}	{	printf("(ICONS: %s)", yytext); return ICONST; }

<xt>{other} {
	printf("(TOKEN: %c)", yytext[0]);
	return yytext[0];
}

<xt><<EOF>> {
		yyextra->error = true;
		yyerror(yylloc, yyscanner, "unterminated tag block: expected %}\n");
		yyterminate();
	}

<xq,xd>{other}	{
		/* \\ before EOF */
		printf("%s", yyextra->literal);
		yyfree(yyextra->literal, yyscanner);
		yyextra->literal = strndup(yytext, yyleng + 1);
	}

<xq,xd><<EOF>> {
		yyextra->error = true;
		yyerror(yylloc, yyscanner, "unterminated quoted string\n");
		yyterminate();
	}

<INITIAL><<EOF>>	{
		size_t const len = strlen(yyextra->literal);
		if (len > 0) {
			printf("%s", yyextra->literal);
		}
		yyfree(yyextra->literal, yyscanner);
		yyextra->literal = strdup("");
		if (yyextra->include_stack_ptr == 0) {
			if (len == 0) {
				yyextra->error = false;
				yyterminate();
			}
		} else {
			fclose(yyin);
			--yyextra->include_stack_ptr;
			yypop_buffer_state(yyscanner);
			yy_pop_state(yyscanner);
		}
		return SCONST;
	}

%%

/*
 *http://stackoverflow.com/questions/3599160/unused-parameter-warnings-in-c-code
 */
#define UNUSED(x) (void)(x)

static FILE *
include_file(yyscan_t *yyscanner)
{
	yy_extra_type *yyext = yyget_extra(yyscanner);
	yyext->include = 0;
	if (yyext->include_stack_ptr++ == MAX_INCLUDE_DEPTH) {
		yyfree(yyext->literal, yyscanner);
		while (--yyext->include_stack_ptr) {
			fclose(yyget_in(yyscanner));
			yypop_buffer_state(yyscanner);
		}
		yylex_destroy(yyscanner);
		yyext->error = true;
		yyerror(yyget_lloc(yyscanner), yyscanner, "max include depth exceeded\n");
		return NULL;
	}

	FILE * const fin = fopen(yyext->literal, "r");

	if (fin == NULL) {
		yyext->error = true;
		yyerror(yyget_lloc(yyscanner), yyscanner, "could not include file\n");
		return NULL;
	}

	yypush_buffer_state(yy_create_buffer(fin, YY_BUF_SIZE, yyscanner),
		yyscanner);
	yy_push_state(INITIAL, yyscanner);
	return fin;
}

/*
 * Called before any actual parsing is done
 */
yyscan_t
scanner_init(FILE *file,
			 yy_extra_type *yyext,
			 ScanKeyword const *keywords,
			 uint16_t num_keywords)
{
	yyscan_t	scanner;

	if (yylex_init(&scanner) != 0) {
		return NULL;
	}

	yyset_extra(yyext, scanner);

	yyext->keywords = keywords;
	yyext->num_keywords = num_keywords;

	yyext->include = false;
	yyext->include_stack_ptr = 0;
	yyext->literal = strdup("");
	yyext->error = true;

	yyset_in(file, scanner);

	return scanner;
}


/*
 * Called after parsing is done to clean up after scanner_init()
 */
int
scanner_finish(yyscan_t *yyscanner)
{
	yy_extra_type *yyext = yyget_extra(yyscanner);
	yyfree(yyext->literal, yyscanner);
	yylex_destroy(yyscanner);
	return(yyext->error);
}

/* Redefinitions of some functions to eliminate warnings in generated code */

void *
yyalloc(yy_size_t  size , yyscan_t yyscanner)
{
	UNUSED(yyscanner);
	return (void *) malloc( size );
}

void *
yyrealloc(void * ptr, yy_size_t  size , yyscan_t yyscanner)
{
	/* The cast to (char *) in the following accommodates both
	 * implementations that use char* generic pointers, and those
	 * that use void* generic pointers.  It works with the latter
	 * because both ANSI C and C++ allow castless assignment from
	 * any pointer type to void*, and deal with argument conversions
	 * as though doing an assignment.
	 */
	UNUSED(yyscanner);
	return (void *) realloc( (char *) ptr, size );
}

void
yyfree (void * ptr , yyscan_t yyscanner)
{
	UNUSED(yyscanner);
	free( (char *) ptr );	/* see yyrealloc() for (char *) cast */
}
