// Threaded Flat File Namespace

#ifndef _FLATFILE_H
#define _FLATFILE_H
#else
#error flatfile.h already included
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



#define		apSubDirs			0x00000001
#define		apExclude			0x00000002


cexport void FlatFile_Free();



