// Threaded Tags Support

#ifndef _TAGS_H
#define _TAGS_H
#else
#error tags.h already included
#endif

#ifndef _PROJDLL_H
#include "projdll.h"
#endif

#ifndef _DBG_H
#include "dbg.h"
#endif

#ifndef _STD_H
#include "std.h"
#endif

#ifndef _ARRAYS_H
#include "arrays.h"
#endif


#undef THIS_FILE
#define THIS_FILE __FILE__



cexport void Tags_FreeAll();


enum {
	symClass = 'c',
	symDefine = 'd',
	symEnumValue = 'e',
	symFunction = 'f',
	symEnum = 'g',
	symMember = 'm',
	symPrototype = 'p',
	symStruct = 's',
	symTypedef = 't',
	symUnion = 'u',
	symVariable = 'v',
	};


enum {
	loadBadFormat = -5,
	loadUnsorted = -4,
	loadError = -3,
	loadInProgress = -2,
	loadNotFound = -1,
	};



