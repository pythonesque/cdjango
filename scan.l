%{
#include "scanner.h"

#define YY_EXTRA_TYPE yy_extra_type *

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
/* %option noyy_scan_buffer */
%option noyy_scan_bytes
%option noyy_scan_string
%option noyyget_extra
/*%option noyyset_extra*/
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

cdata		[^{]*

xtstart \{\%
xtstop \%\}

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
 * xdinside		[^\\']+
 * xdescape		[\\][^0-7]
 * xxdoctesc		[\\][0-7]{1,3}
 * xxdhexesc		[\\]x[0-9A-Fa-f]{1,2}
 * xxdunicode		[\\](u[0-9A-Fa-f]{4}|U[0-9A-Fa-f]{8})
 * xxdunicodefail	[\\](u[0-9A-Fa-f]{0,3}|U[0-9A-Fa-f]{0,7})
 */

quote			'
quotestop		{quote}

xqstart			{quote}
xqinside		[^']+

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

{cdata}		{	printf("%s", yytext); return SCONST; }

{xtstart}	{	BEGIN(xt); }

<xt>{whitespace}	{	/* ignore */ }

<xt>{xtstop}	{	BEGIN(INITIAL); }

<xt>{xqstart}	{	yyextra->literal = ""; BEGIN(xq); }

<xt>include		{	yyextra->include = 1; }

<xt>{identifier}	{	yyextra->include = 0; printf("(IDENT: %s)", yytext); return IDENT; }

<xt>{integer}	{	printf("(ICONST: %s)", yytext); return ICONST; }

<xq>{quotestop} {
		BEGIN(xt);
		if (yyextra->include) {
			yyextra->include = 0;
			if (yyextra->include_stack_ptr++ == MAX_INCLUDE_DEPTH)
			{
				yyterminate();
			}

			*yytext = '\0';
			yyin = fopen(yyextra->literal, "r");

			if (yyin == NULL) {
				yyterminate();
			}

			yypush_buffer_state(yy_create_buffer(yyin, YY_BUF_SIZE, yyscanner),
				yyscanner);
			yy_push_state(INITIAL, yyscanner);
		}
	}

<xq>{xqinside}	{	if (!yyextra->include) { printf("%s", yytext); } yyextra->literal = yytext; return SCONST; }

<INITIAL><<EOF>>	{
		if (yyextra->include_stack_ptr-- == 0) {
			yyterminate();
		} else {
			yypop_buffer_state(yyscanner);
			yy_pop_state(yyscanner);
		}
	}

%%

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

	str[slen] = YY_END_OF_BUFFER_CHAR;
	yy_scan_buffer(str, slen, scanner);

	return scanner;
}


/*
 * Called after parsing is done to clean up after scanner_init()
 */
void
scanner_finish(yyscan_t yyscanner)
{
	yylex_destroy(yyscanner);
}
