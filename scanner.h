#ifndef SCANNER_H
#define SCANNER_H

#include <stdbool.h>

#define MAX_INCLUDE_DEPTH 10

/*typedef union
{
	int		ival;
	char	*str;
} YYSTYPE;*/

//#define YY_EXTRA_TYPE yy_extra_type *
typedef struct yy_extra_type
{
	/*YY_BUFFER_STATE include_stack[MAX_INCLUDE_DEPTH];*/
	int include_stack_ptr;
	char *literal;
	bool include;
} yy_extra_type;

typedef void *yyscan_t;

extern yyscan_t scanner_init(char *str, yy_extra_type *yyext);
extern void scanner_finish(yyscan_t *scanner);
//extern int yylex(YYSTYPE *lvalp, YYLTYPE *llocp, yyscan_t yyscanner);

#endif /* !SCANNER_H */
