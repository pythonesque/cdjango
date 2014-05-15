%{
#include "scanner.h"

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
%option noyyget_in
%option noyyset_in
%option noyyget_out
%option noyyset_out
%option noyyget_lval
%option noyyset_lval
%option noyyget_lloc
%option noyyset_lloc
%option noyyget_debug
%option noyyset_debug
%option noyywrap
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
			YY_FATAL_ERROR("include requires a filename\n");
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

<xt>{identifier}	{	yyextra->include = 0; printf("(IDENT: %s)", yytext); return IDENT; }

<xt>{integer}	{	printf("(ICONS: %s)", yytext); return ICONST; }

<xt>{other} {
	printf("(TOKEN: %c)", yytext[0]);
	return yytext[0];
}

<xt><<EOF>> { YY_FATAL_ERROR("unterminated tag block: expected %}\n"); }

<xq,xd>{other}	{
		/* \\ before EOF */
		printf("%s", yyextra->literal);
		yyfree(yyextra->literal, yyscanner);
		yyextra->literal = strndup(yytext, yyleng + 1);
	}

<xq,xd><<EOF>> { YY_FATAL_ERROR("unterminated quoted string\n"); }

<INITIAL><<EOF>>	{
		size_t const len = strlen(yyextra->literal);
		if (len > 0) {
			printf("%s", yyextra->literal);
		}
		yyfree(yyextra->literal, yyscanner);
		yyextra->literal = strdup("");
		if (yyextra->include_stack_ptr == 0) {
			if (len == 0) {
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

static FILE *
include_file(yyscan_t *yyscanner)
{
	yy_extra_type *yyext = yyget_extra(yyscanner);
	yyext->include = 0;
	if (yyext->include_stack_ptr++ == MAX_INCLUDE_DEPTH)
	{
		YY_FATAL_ERROR("max include depth exceeded\n");
	}

	FILE * const fin = fopen(yyext->literal, "r");

	if (fin == NULL) {
		perror("fopen");
		YY_FATAL_ERROR("could not include file\n");
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
scanner_init(char *str, yy_extra_type *yyext)
{
	size_t		slen = strlen(str);
	yyscan_t	scanner;

	if (yylex_init(&scanner) != 0) {
		exit(-1);
	}

	yyset_extra(yyext, scanner);

	yyext->include = false;
	yyext->include_stack_ptr = 0;
	yyext->literal = strdup("");

	str[slen] = YY_END_OF_BUFFER_CHAR;
	yy_scan_buffer(str, slen, scanner);

	return scanner;
}


/*
 * Called after parsing is done to clean up after scanner_init()
 */
void
scanner_finish(yyscan_t *yyscanner)
{
	yy_extra_type *yyext = yyget_extra(yyscanner);
	yyfree(yyext->literal, yyscanner);
	yylex_destroy(yyscanner);
}
