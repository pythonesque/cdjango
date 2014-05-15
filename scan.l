%{

%}

%option reentrant
%option bison-bridge
%option bison-locations
%option 8bit
%option never-interactive
%option nodefault
%option noinput
%option nounput
%option noyy_scan_buffer
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
%x xv

cdata		[^{]*

xtstart \{\%
xtstop \%\}

xvstart \{\{
xvstop \}\}

space			[ \t\n\r\f]
newline			[\n\r]
non_newline		[^\n\r]

comment			("#"{non_newline}*)

whitespace		({space}+|{comment})

/*
 * dquote			'
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

xqstart			{quote}
xqstop			{quote}
xqinside		[^']+

digit			[0-9]
ident_start		[A-Za-z\200-\377_]
ident_cont		[A-Za-z\200-\377_0-9\$]

identifier		{ident_start}{ident_cont}

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

{cdata}		{	return SCONST; }

%%

/*
 * Called before any actual parsing is done
 */
yyscan_t
scanner_init(char *str)
{
	//Size		slen = strlen(str);
	size_t		slen = strlen(str);
	yyscan_t	scanner;

	if (yylex_init(&scanner) != 0) {
		exit(-1);
		//elog(ERROR, "yylex_init() failed: %m");
	}

	/*core_yyset_extra(yyext, scanner);

	yyext->keywords = keywords;
	yscanbuflen = slen;
	memcpy(yyext->scanbuf, str, slen);
	yyext->scanbuf[slen] = yyext->scanbuf[slen + 1] = YY_END_OF_BUFFER_CHAR;
	yy_scan_buffer(yyext->scanbuf, slen + 2, scanner); */
	yy_scan_buffer(str, slen + 2, scanner);

	/* initialize literal buffer to a reasonable but expansible size */
	/*yyext->literalalloc = 1024;
	yyext->literalbuf = (char *) palloc(yyext->literalalloc);
	yyext->literallen = 0;*/

	return scanner;
}


/*
 * Called after parsing is done to clean up after scanner_init()
 */
void
scanner_finish(yyscan_t yyscanner)
{
	/*
	 * We don't bother to call yylex_destroy(), because all it would do
	 * is pfree a small amount of control storage.  It's cheaper to leak
	 * the storage until the parsing context is destroyed.  The amount of
	 * space involved is usually negligible compared to the output parse
	 * tree anyway.
	 *
	 * We do bother to pfree the scanbuf and literal buffer, but only if they
	 * represent a nontrivial amount of space.  The 8K cutoff is arbitrary.
	 */
	/*if (yyextra->scanbuflen >= 8192)
		pfree(yyextra->scanbuf);
	if (yyextra->literalalloc >= 8192)
		pfree(yyextra->literalbuf);*/
}


