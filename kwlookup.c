#include <ctype.h>
#include <string.h>

#include "keywords.h"

ScanKeyword const *
ScanKeywordLookup(char const *text,
				  ScanKeyword const *keywords,
				  uint16_t num_keywords)
{
	ScanKeyword const *low;
	ScanKeyword const *high;

	/*
	 * Do a binary search using plain strcmp() comparison.
	 */
	low = keywords;
	high = keywords + (num_keywords - 1);
	while (low <= high)
	{
		ScanKeyword const *middle;
		int16_t		difference;

		middle = low + (high - low) / 2;
		difference = strcmp(middle->name, text);
		if (difference == 0)
			return middle;
		else if (difference < 0)
			low = middle + 1;
		else
			high = middle - 1;
	}

	return NULL;
}
