#include "gramparse.h"

#define CD_KEYWORD(a,b) {a,b},


const ScanKeyword ScanKeywords[] = {
#include "kwlist.h"
};

const uint16_t NumScanKeywords = sizeof(ScanKeywords) / sizeof(ScanKeyword);
