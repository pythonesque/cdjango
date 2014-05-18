#include "gramparse.h"

#include <stdio.h>

int main(void)
{
	yy_extra_type yyextra;
	yyscan_t scanner = scanner_init(stdin, &yyextra, ScanKeywords,
									NumScanKeywords);
	parser_init();
	yyparse(scanner);
	return scanner_finish(scanner);
}

void yyerror(YYLTYPE *llocp, yyscan_t yyscanner, char *message)
{
	fprintf(stderr, "%p %s\n", (void *) llocp, message);
}
