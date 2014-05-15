#ifndef GRAMPARSE_H
#define GRAMPARSE_H

#include "nodes.h"
#include "scanner.h"

#include <stdbool.h>

#include "gram.h"

extern void parser_init(void);
extern int yyparse(yyscan_t yyscanner);
extern int yylex(YYSTYPE *lvalp, YYLTYPE *llocp, yyscan_t yyscanner);
extern void yyerror(YYLTYPE *llocp, yyscan_t yyscanner, char *message);

#endif /* !GRAMPARSE_H */
