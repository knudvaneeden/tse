// BSC File Support

#ifndef _BSCUTIL_H
#define _BSCUTIL_H
#else
#error _BSCUTIL_H already defined
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

#ifndef __BSC_INCLUDED__
#include "bsc.h"
#endif


#undef THIS_FILE
#define THIS_FILE __FILE__



cexport long OpenBrowseFile(LPCSTR pszBscFile);
cexport long CloseBrowseFile();

cexport void DisposeDefinitions();
cexport void DisposeArray();

cexport long SetCurrentSymbol(LPCSTR pszSymbol);

cexport LPSTRING GetName(ULONG i, int *ptyp, int *patr);
cexport LPSTRING GetType(TYP typ);
cexport LPSTRING GetAttr(ATR atr);

cexport long GetDefinitions(ULONG i);
cexport LPSTRING GetDef(ULONG i, int *pnLine);



