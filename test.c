#include "gramparse.h"

#include <stdio.h>

int main(void)
{
	char buf[] = "test";
	yyscan_t scanner = scanner_init(buf);
	parser_init();
	yyparse(scanner);
	scanner_finish(scanner);
}

void yyerror(YYLTYPE *llocp, yyscan_t yyscanner, char *message)
{
	fprintf(stderr, "%p %s\n", (void *) llocp, message);
}
