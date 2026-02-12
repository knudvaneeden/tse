// PROJDLL.C

// TO COMPILE AND LINK, using Microsoft C v10:
// cl -W3 -GD -LD projdll.c projdll.def user32.lib


// WARNING!!  Be extremely careful if you modify this file.  This is a
// multithreaded DLL, and if extreme care is not taken, you can easily
// introduce deadlocks (too much or incorrect thread synchronization) or
// crashes (not enough thread synchronization).



//#define DEBUG

#ifndef _STD_H
#include "std.h"
#endif

#ifndef _FLATFILE_H
#include "flatfile.h"
#endif

#ifndef _TAGS_H
#include "tags.h"
#endif

#ifndef _BSCUTIL_H
#include "bscutil.h"
#endif



///////////////////////////////////////////////////////////////////////////
// Types

#define MAXNAME			128



///////////////////////////////////////////////////////////////////////////
// Globals

static long s_rgIntVar[maxIntVar - minIntVar] = {0};
static String s_rgStrVar[maxStrVar - minStrVar];



///////////////////////////////////////////////////////////////////////////
// Accessors

cexport
long Get_Int(long iIntVar)
{
	Assert(iIntVar >= minIntVar && iIntVar < maxIntVar);
	return s_rgIntVar[iIntVar - minIntVar];
}


cexport
void Set_Int(long iIntVar, long n)
{
	Assert(iIntVar >= minIntVar && iIntVar < maxIntVar);
	s_rgIntVar[iIntVar - minIntVar] = n;
}


cexport
LPSTRING Get_Str(long iStrVar)
{
	Assert(iStrVar >= minStrVar && iStrVar < maxStrVar);
	return s_rgStrVar[iStrVar - minStrVar].TSE();
}


cexport
void Set_Str(long iStrVar, LPCSTR psz)
{
	Assert(iStrVar >= minStrVar && iStrVar < maxStrVar);
	s_rgStrVar[iStrVar - minStrVar].HrDup(psz);
}


void FreeAllStrings()
{
	for (long i = maxStrVar - minStrVar; i--; )
		s_rgStrVar[i].Free();
}



///////////////////////////////////////////////////////////////////////////
// Exported Helper Functions

#if 0
cexport
void InitProjectVars()
{
	SetProjectId(0);
	SetPathListId(0);

	//$ todo: (chrisant) string accessors

	SetFListEnsured(FALSE);
	SetFNeedToEnsure(FALSE);
}


	static long id1;
	static long id2;
	static char sz1[MAXPATH];
	static char sz2[MAXPATH];
	static char sz3[MAXPATH];
	static BOOL f1;
	static BOOL f2;


cexport
void _PushProjectBuffers()
{
	id1 = GetProjectId();
	id2 = GetPathListId();
	//$ todo: (chrisant) string accessors
	f1 = FListEnsured();
	f2 = FNeedToEnsure();
}


cexport
void _PopProjectBuffers()
{
	SetProjectId(id1);
	SetPathListId(id2);
	//$ todo: (chrisant) string accessors
	SetFListEnsured(f1);
	SetFNeedToEnsure(f2);
}
#endif



///////////////////////////////////////////////////////////////////////////
// Functions

void RetailCleanup()
{
	CloseBrowseFile();
}


cexport
void DLL_WhenPurged()
{
	RetailCleanup();

	FreeAllStrings();
	FlatFile_Free();
	Tags_FreeAll();
}



///////////////////////////////////////////////////////////////////////////
// DllEntryPoint

BOOL WINAPI DllMain(HINSTANCE hinstDLL,	// handle of DLL module
					DWORD dwReason,		// reason for calling function
					LPVOID pvReserved	// reserved
					)
{
	CONTEXT_("DllMain");

	if (dwReason == DLL_PROCESS_ATTACH)
		{
		Trace("DLL_PROCESS_ATTACH");

		// init
		g_hInst = hinstDLL;
		DisableThreadLibraryCalls(hinstDLL);
		}
	else if (dwReason == DLL_PROCESS_DETACH)
		{
		Trace("DLL_PROCESS_DETACH");

#ifndef DEBUG
		RetailCleanup();	// in retail, let OS do fast memory reclamation
#else
		DLL_WhenPurged();	// only need to rigorously free in debug
		DbgCheck();
#endif
		}

	return TRUE;
}

