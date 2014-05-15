#ifndef SCANNER_H
#define SCANNER_H

#include <stdbool.h>
#include <stdio.h>

#define MAX_INCLUDE_DEPTH 10

typedef struct yy_extra_type
{
	int include_stack_ptr;
	char *literal;
	bool include;
	bool error;
} yy_extra_type;

typedef void *yyscan_t;

extern yyscan_t scanner_init(FILE *filename, yy_extra_type *yyext);
extern int scanner_finish(yyscan_t *scanner);
//extern int yylex(YYSTYPE *lvalp, YYLTYPE *llocp, yyscan_t yyscanner);

#endif /* !SCANNER_H */
