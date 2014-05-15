#ifndef SCANNER_H
#define SCANNER_H

/*typedef union
{
	int		ival;
	char	*str;
} YYSTYPE;*/

typedef void *yyscan_t;

extern yyscan_t scanner_init(char *str);
extern void scanner_finish(yyscan_t scanner);
//extern int yylex(YYSTYPE *lvalp, YYLTYPE *llocp, yyscan_t yyscanner);

#endif /* !SCANNER_H */
