#include "gramparse.h"

#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>

#define NTIMES 100

int
main(void)
{
	yy_extra_type yyextra;
	int res;
	int fd2;
	for (int i = 0; i < NTIMES; ++i) {
		yyscan_t scanner = scanner_init(stdin, &yyextra, ScanKeywords,
										NumScanKeywords);
		parser_init();
		yyparse(scanner);
		res = scanner_finish(scanner);
		if (res < 0) {
			return(res);
		}
		if (fseek(stdin, 0, SEEK_SET) < 0) {
			return(0);
		}
		if (i == 0) {
			if ((fd2 = open("/dev/null", O_WRONLY)) < 0) {
				perror("open");
				return(-1);
			}
			if (dup2(fd2,1) < 0) {
				perror("dup2");
				return(-1);
			}
			close(fd2);
		}
	}
	return(0);
}

void
yyerror(YYLTYPE *llocp, yyscan_t yyscanner, char const *message)
{
	(void)(yyscanner);
	fprintf(stderr, "%p %s\n", (void *) llocp, message);
}
