#ifndef KEYWORDS_H
#define KEYWORDS_H

#include <stdint.h>

typedef struct ScanKeyword
{
	char const *name;			/* in lower case */
	int16_t	value;				/* grammar's token code */
} ScanKeyword;

extern const ScanKeyword ScanKeywords[];
extern const uint16_t NumScanKeywords;

extern ScanKeyword const *ScanKeywordLookup(char const *text,
				  ScanKeyword const *keywords,
				  uint16_t num_keywords);

#endif   /* !KEYWORDS_H */
