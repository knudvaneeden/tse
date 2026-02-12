// new/delete
// memory tracking
// asserts

#ifndef _PROJDLL_H
#include "projdll.h"
#endif

#ifndef _STD_H
#include "std.h"
#endif

#ifndef _DBG_H
#include "dbg.h"
#endif


#undef THIS_FILE
#define THIS_FILE __FILE__



///////////////////////////////////////////////////////////////////////////
// Assert

const ULONG cbMaxSaneAlloc = 4096;
const ULONG cbMaxSaneReAlloc = 32*cbMaxSaneAlloc;

const char c_szAssertTitle[] = "ProjDll Assert";
const UINT c_grfMessageBox = MB_ICONHAND|MB_ABORTRETRYIGNORE|MB_DEFBUTTON3;

#ifdef DEBUG
void CDECL DbgTrace_(const char *pszFormat, ...)
{
	va_list args;
	va_start(args, pszFormat);
	StackTrace::DbgTraceV(fFalse, pszFormat, args);
	va_end(args);
}

void CDECL DbgTrace(const char *pszFormat, ...)
{
	va_list args;
	va_start(args, pszFormat);
	StackTrace::DbgTraceV(fTrue, pszFormat, args);
	va_end(args);
}

void CopyToClipboard(char *psz)
{
	char *pszError = 0;
	HGLOBAL hData;
	LPSTR lpstr;

	hData = GlobalAlloc(GMEM_MOVEABLE|GMEM_DDESHARE, lstrlenA(psz)+1);
	if (!hData)
		{
		pszError = "Not enough memory.";
		goto ClipError;
		}
	lpstr = (LPSTR)GlobalLock(hData);
	if (!lpstr)
		{
		pszError = "Error locking handle.";
		goto ClipError;
		}

	lstrcpyA(lpstr, psz);				// don't need lstrcpyn
	GlobalUnlock(hData);

	if (!OpenClipboard(0))
		{
		pszError = "Cannot access clipboard.";
		goto ClipError;
		}

	EmptyClipboard();
	// Windows takes ownership of hData
	SetClipboardData(CF_TEXT, hData);
	hData = 0;

ClipError:
	if (pszError)
		MessageBoxA(NULL, pszError, c_szAssertTitle, MB_OK);
	if (hData)
		GlobalFree(hData);
}

BOOL DbgAssert(const char *pszFileName, int iLine, const char *pszFmt, ...)
{
	static BOOL s_fInDbgAssert = fFalse;
	va_list	arg;
	char sz[2048];
	int	ival;
	char *pch = sz;
	char *pchEnd;
	BOOL fQuit;
	MSG	msgT;
	BOOL fRet = fTrue; // set to false to prevent this assert from firing

	pch += wsprintfA(pch, "%s @ line %d", pszFileName, iLine);

	if (pszFmt)
		{
		*pch++ = ':';
		*pch++ = ' ';
		*pch++ = '"';

		va_start(arg, pszFmt);
		pch += wvsprintfA(pch, pszFmt, arg);
		va_end(arg);
		// Remove trailing newlines...
		while (*(pch-1) == '\n')
			--pch;

		*pch++ = '"';
		*pch++ = '\r';
		*pch++ = '\n';
		}
	else
		*pch++ = ' ';

	if (s_fInDbgAssert)
		{
		*pch = 0;
		Trace("Arrgg! Recursive assert: %s", sz);
		MessageBeep(0);MessageBeep(0);
		return fRet;
		}

	s_fInDbgAssert = fTrue;

	// add stack context info
	pch += wsprintfA(pch, "\nContext:%s", StackTrace::DumpToStr(fFalse));

	*pch = '\0';
	pchEnd = pch;

	Trace("%s: %s", c_szAssertTitle, (LPSTR)sz);

	// add some help about using this assert
	const char szHelp[] = "\n\nShift-Ignore: Copies assert text to the clipboard."
						  "\nCtrl-Ignore: Ignores assert for this session.\n";
	lstrcpyA(pch, szHelp);				// don't need lstrcpyn (dest is 2048 bytes)

Retry:
	// Is there a WM_QUIT message in the queue, if so remove it.
	fQuit = ::PeekMessage(&msgT, NULL, WM_QUIT, WM_QUIT, PM_REMOVE);
	ival = MessageBoxA(NULL, sz, c_szAssertTitle, c_grfMessageBox);
	// If there was a quit message, add it back into the queue
	if (fQuit)
		::PostQuitMessage(msgT.wParam);

	switch (ival)
		{
		case 0:
			Trace("Failed to create message box on assert.");
			//	Fallthrough
		case IDRETRY:
			s_fInDbgAssert = fFalse;
			DbgStop();
			return fRet;
		case IDIGNORE:
			if ((GetKeyState(VK_SHIFT) & 0x8000) != 0)
				{
				*pchEnd = '\0';
				CopyToClipboard(sz);
				*pchEnd = '\n';
				goto Retry;
				}
			if ((GetKeyState(VK_CONTROL) & 0x8000) != 0)
				fRet = fFalse;

			s_fInDbgAssert = fFalse;
			return fRet;
		case IDABORT:
			ExitProcess(1);
			break;
		}

	Trace("Panic!  Dropping out of DbgAssert: %s", (LPSTR)sz);
	s_fInDbgAssert = fFalse;
	DbgStop();
	return fRet;
}
#endif



///////////////////////////////////////////////////////////////////////////
// Stack Tracing

#ifdef DEBUG
long GetDbgPref(LPCSTR pszName, long lDefault)
{
	DWORD dwType;
	DWORD dwValue;
	DWORD dwSize = sizeof(dwValue);
	long lRet = lDefault;

	if (RegQueryValueExA(HKEY_CURRENT_USER, pszName, 0, &dwType,
						 (LPBYTE)&dwValue, &dwSize) == ERROR_SUCCESS &&
						 dwType == REG_DWORD)
		lRet = dwValue;

	return lRet;
}


void SetDbgPref(LPCSTR pszName, long lValue)
{
	RegSetValueExA(HKEY_CURRENT_USER, pszName, 0, REG_DWORD, (const BYTE *)&lValue, sizeof(lValue));
}


const char c_szDbgIndenting[] = "TraceIndent";
const char c_szDbgFunctions[] = "TraceFunctions";
const char c_szDbgInterfaces[] = "TraceInterfaces";

ThreadInfo StackTrace::s_rgThreads[cMaxThreads] = {{0}};
BOOL StackTrace::s_fInitialized = fFalse;
CRITICAL_SECTION StackTrace::s_cs;
BOOL StackTrace::s_fIndent = fFalse;
BOOL StackTrace::s_fIndentingEnabled = fFalse;
DWORD StackTrace::s_dwMaskEnabled = traceAlways;
static char s_szDump[2048];

#define TRACE_INDENT_AMOUNT 2


StackTrace::StackTrace(LPCSTR pszFile, ULONG nLine, LPCSTR pszFunction, DWORD dwFlags)
{
	char szDrive[10];
	char szDir[128];
	char szName[17];
	char szExt[5];

	Initialize();
	Lock();

	m_dwFlags = dwFlags;
	AssertSz(pszFunction || !(dwFlags & (traceFunctions|traceInterfaces|traceExit)),
			 "can't specify traceFunctions/traceInterfaces/traceExit "
			 "without also passing pszFunction");

	if (GetThreadHead() && GetThreadHead() <= this)
		{
		// this can happen if a Win32 exception gets thrown by our
		// destructor and will result in random crashes if we don't
		// clean it up here.
		Trace("Cleaning up hosed stack.");
		SetThreadHead(0);
		}

	m_pNext = GetThreadHead();
	m_pPrev = 0;

	if (GetThreadHead())
		GetThreadHead()->m_pPrev = this;
	SetThreadHead(this);

	_splitpath(pszFile, szDrive, szDir, szName, szExt);
	lstrcatA(szName, szExt);
	lstrcpynA(m_szFile, szName, sizeof(m_szFile)-1);
	m_nLine = nLine;
	if (pszFunction)
		lstrcpynA(m_szFunction, pszFunction, sizeof(m_szFunction)-1);
	else
		*m_szFunction = 0;

	if (m_dwFlags & s_dwMaskEnabled)
		{
		//Trace_("ENTER: ");
		Trace(m_szFunction);
		}
	GetThreadInfo()->cIndent += TRACE_INDENT_AMOUNT;

	Unlock();
}


StackTrace::~StackTrace()
{
	Lock();

	GetThreadInfo()->cIndent -= TRACE_INDENT_AMOUNT;
	if ((m_dwFlags & traceExit) && (m_dwFlags & s_dwMaskEnabled))
		{
		//Trace_("leave: ");
		Trace_("leaving ");
		Trace(m_szFunction);
		}

	if (m_pPrev)
		m_pPrev->m_pNext = m_pNext;
	else
		SetThreadHead(m_pNext);
	if (m_pNext)
		m_pNext->m_pPrev = m_pPrev;

	Unlock();
	UnInitialize();
}


void StackTrace::SetThreadHead(StackTrace *pHead)
{
	ThreadInfo *pti = GetThreadInfo();

	pti->pHead = pHead;
	if (!pHead)
		{
		pti->id = 0;
		pti->cIndent = 0;
		}
}


void StackTrace::Initialize()
{
	if (!s_fInitialized)
		{
		InitializeCriticalSection(&s_cs);
		s_fInitialized = fTrue;
		}
}


void StackTrace::UnInitialize()
{
	if (s_fInitialized)
		{
		// bail if we're tracking any threads
		for (int i = cMaxThreads; i--;)
			if (s_rgThreads[i].pHead)
				return;

		DeleteCriticalSection(&s_cs);
		s_fInitialized = fFalse;
		}
}


int StackTrace::GetThreadIndex()
{
	DWORD dwId = GetCurrentThreadId();
	int iThread;

	// find thread
	for (iThread = cMaxThreads; iThread--;)
		if (s_rgThreads[iThread].id == dwId)
			goto Out;

	// add thread
	for (iThread = cMaxThreads; iThread--;)
		if (!s_rgThreads[iThread].id)
			break;
	Assert1(iThread >= 0, "thread overflow, more than %d threads", cMaxThreads);
	s_rgThreads[iThread].id = dwId;
	Assert(s_rgThreads[iThread].pHead == 0);
	Assert(s_rgThreads[iThread].cIndent == 0);

Out:
	return iThread;
}


void StackTrace::LoadSettings()
{
	s_fIndentingEnabled = GetDbgPref(c_szDbgIndenting, fFalse);
	s_fIndent = s_fIndentingEnabled;

	s_dwMaskEnabled = traceAlways;
	if (GetDbgPref(c_szDbgFunctions, fFalse))
		s_dwMaskEnabled |= traceFunctions;
	if (GetDbgPref(c_szDbgInterfaces, fFalse))
		s_dwMaskEnabled |= traceInterfaces;
}


void StackTrace::SaveSettings()
{
	SetDbgPref(c_szDbgIndenting, s_fIndentingEnabled);
	SetDbgPref(c_szDbgFunctions, !!(s_dwMaskEnabled & traceFunctions));
	SetDbgPref(c_szDbgInterfaces, !!(s_dwMaskEnabled & traceInterfaces));
}


void StackTrace::DbgTraceV(BOOL fNewLine, const char *pszFormat, char *pvargs)
{
	char szBuffer[cchDbgTraceMax];

	if (s_fInitialized)
		{
		Lock();

		if (s_fIndent && s_fIndentingEnabled)
			{
			if (GetThreadInfo()->cIndent >= DimensionOf(szBuffer)-1)
				OutputDebugStringA("SOMETHING HAS GONE HORRIBLY WRONG, I'm supposed to indent by a LOT of spaces...\r\n");
			else
				{
				memset(szBuffer, ' ', GetThreadInfo()->cIndent);
				szBuffer[GetThreadInfo()->cIndent] = 0;
				OutputDebugStringA(szBuffer);
				s_fIndent = fFalse;
				}
			}

		wvsprintfA(szBuffer, pszFormat, pvargs);
		OutputDebugStringA(szBuffer);

		if (fNewLine)
			{
			s_fIndent = s_fIndentingEnabled;
			OutputDebugStringA("\r\n");
			}

		Unlock();
		}
	else
		{
		if (s_fIndent && s_fIndentingEnabled)
			s_fIndent = fFalse;

		wvsprintfA(szBuffer, pszFormat, pvargs);
		OutputDebugStringA(szBuffer);

		if (fNewLine)
			{
			s_fIndent = s_fIndentingEnabled;
			OutputDebugStringA("\r\n");
			}
		}
}


LPCSTR StackTrace::DumpToStr(BOOL fOneLine)
{
	StackTrace *p;
	int cMax = 10;
	char *psz = s_szDump;
	const char *rgsz[2] = { "\n\t%s li%d [%s]", " / %s li%d" };

	if (s_fInitialized)
		{
		Lock();

		p = GetThreadHead();

		lstrcpyA(s_szDump, fOneLine ? "" : "\n");
		lstrcatA(s_szDump, "\t-- None --");

		// build stack string
		while (p && cMax--)
			{
			psz += wsprintfA(psz, rgsz[fOneLine ? 1 : 0],
							 p->m_szFile, p->m_nLine, p->m_szFunction);
			p = p->m_pNext;
			}

		Unlock();
		}
	else
		lstrcpyA(s_szDump, "\t-- None --");
	return s_szDump;
}
#endif



///////////////////////////////////////////////////////////////////////////
// Memory Tracking

#ifdef DEBUG

//#undef new

#if 0
void TraceV(LPSTR psz, ...)
{
	char szBuffer[512];

	va_list args;
	va_start(args, psz);

	wvsprintf(szBuffer, psz, args);
	OutputDebugString(szBuffer);

	va_end(args);
}
#endif


struct MemTracking
	{
	MemTracking *m_pPrev;
	MemTracking *m_pNext;
	const char *m_pszFilename;
	ULONG m_nLine;
	char *m_pszContext;
	size_t m_cbSize;
	};

static MemTracking *s_pHead = 0;
static BOOL s_fAllocatorInitialized = fFalse;
static BOOL s_fReallocating = fFalse;
static CRITICAL_SECTION s_csMem;


void InitAllocator()
{
	if (!s_fAllocatorInitialized)
		{
		InitializeCriticalSection(&s_csMem);
		s_fAllocatorInitialized = fTrue;
		}
}


void UnInitAllocator()
{
	if (s_fAllocatorInitialized && !s_pHead && !s_fReallocating)
		{
		DeleteCriticalSection(&s_csMem);
		s_fAllocatorInitialized = fFalse;
		}
}


void LockAllocator()
{
	if (s_fAllocatorInitialized)
		EnterCriticalSection(&s_csMem);
}


void UnlockAllocator()
{
	if (s_fAllocatorInitialized)
		LeaveCriticalSection(&s_csMem);
}


void *DbgAlloc(size_t cbSize, LPCSTR pszFilename, ULONG nLine)
{
	MemTracking *p;
	const char *pszContext;

	InitAllocator();
	LockAllocator();

	p = (MemTracking*)malloc(cbSize + sizeof(MemTracking));
	if (!p)
		{
		UnlockAllocator();
		return 0;
		}

	Assert1(cbSize <= cbMaxSaneAlloc || ((cbSize % 4096) == 0 && (cbSize / 4096) < 96),
			"Is this a bogus size?  (%u bytes)", cbSize);

	// new fill
	memset(p, 0, cbSize + sizeof(MemTracking));

	p->m_cbSize = cbSize;
	p->m_nLine = nLine;
	p->m_pszFilename = pszFilename;		// assume pointer to constant string

	pszContext = StackTrace::DumpToStr(fTrue);
	if (pszContext && *pszContext)
		{
		p->m_pszContext = (char*)malloc(lstrlenA(pszContext)+1);
		if (p->m_pszContext)
			lstrcpyA(p->m_pszContext, pszContext);		// don't need lstrcpyn
		}

	// link it
	p->m_pNext = s_pHead;
	if (s_pHead)
		s_pHead->m_pPrev = p;
	s_pHead = p;

	UnlockAllocator();
	return (LPVOID)(p+1);
}


void *DbgReAlloc(void *pv, size_t cbSize, LPCSTR pszFilename, ULONG nLine)
{
	MemTracking *p;
	MemTracking *p2 = (MemTracking *)((LPSTR)pv - sizeof(MemTracking));
	const char *pszContext;

	AssertSz(pv, "realloc can deal with pv being NULL, be DbgReAlloc can't");
	AssertSz(cbSize, "realloc can deal with cbSize being 0, but DbgReAlloc can't");

	LockAllocator();

	p = (MemTracking*)malloc(cbSize + sizeof(MemTracking));
	if (!p)
		{
		// confusing, but consistent with realloc
		UnlockAllocator();
		return 0;
		}

	Assert1(cbSize <= cbMaxSaneReAlloc, "Is this a bogus size?  (%u bytes)", cbSize);

	// new fill
	memset(p, 0, cbSize + sizeof(MemTracking));

	// copy from pv
	memcpy((LPVOID)(p+1), (LPVOID)(p2+1), p2->m_cbSize);

	// free pv
	Assert(!s_fReallocating);
	s_fReallocating = fTrue;
	DbgFree(pv);
	s_fReallocating = fFalse;

	p->m_cbSize = cbSize;
	p->m_nLine = nLine;
	p->m_pszFilename = pszFilename;		// assume pointer to constant string

	pszContext = StackTrace::DumpToStr(fTrue);
	if (pszContext && *pszContext)
		{
		p->m_pszContext = (char*)malloc(lstrlenA(pszContext)+1);
		if (p->m_pszContext)
			lstrcpyA(p->m_pszContext, pszContext);		// don't need lstrcpyn
		}

	// link it
	p->m_pNext = s_pHead;
	if (s_pHead)
		s_pHead->m_pPrev = p;
	s_pHead = p;

	UnlockAllocator();
	return (LPVOID)(p+1);
}


void DbgFree(void *pv)
{
	MemTracking *p = 0;
	MemTracking *pFind = 0;

	if (!pv)
		return;

	LockAllocator();

	p = (MemTracking *)((LPSTR)pv - sizeof(MemTracking));

	for (pFind = s_pHead; pFind && p != pFind; pFind = pFind->m_pNext);
	if (!pFind)
		{
		UnlockAllocator();
		Panic0("freeing dead/bogus memory");
		return;
		}

	// dead fill
	memset(p+1, 0xdd, p->m_cbSize);

	// unlink it
	if (p->m_pNext)
		p->m_pNext->m_pPrev = p->m_pPrev;
	if (p->m_pPrev)
		p->m_pPrev->m_pNext = p->m_pNext;
	else
		s_pHead = p->m_pNext;

	if (p->m_pszContext)
		free(p->m_pszContext);

	// dead fill
	memset((LPVOID)p, 0xde, sizeof(MemTracking));

	// free the memory
	free(p);

	UnlockAllocator();
	UnInitAllocator();
}


int ListLeaks()
{
	MemTracking *p;
	UINT nLeaks = 0;
	size_t cb = 0;

	LockAllocator();

	Trace("---- Checking for leaks ----");
	for (p = s_pHead; p; p = p->m_pNext, ++nLeaks)
		{
		cb += p->m_cbSize;
		Trace_("Leak:  %8.8d bytes,  %08.8x,  li %d,  file %s", p->m_cbSize, p+1, p->m_nLine, p->m_pszFilename);
		if (p->m_pszContext)
			Trace_(",  context:%s", p->m_pszContext);
		Trace("");
		}

	UnlockAllocator();

	Trace("---- %d leaks, %d bytes total ----", nLeaks, cb);
	return nLeaks;
}


void DbgCheck()
{
	UINT nLeaks = ListLeaks();

	if (nLeaks)
		{
		Assert1(fFalse, "%d leaks detected.", nLeaks);
		ListLeaks();
		}
}


#if 0
void *operator new(size_t cbSize)
{
	AssertSz(fFalse, "Debug build should not be able to call standard new() directly!!");
	return NULL;
}


void *operator new(size_t cbSize, LPCSTR pszFilename, ULONG nLine)
{
	return DbgAlloc(cbSize, pszFilename, nLine);
}


void operator delete(void *pv)
{
	DbgFree(pv);
}
#endif

#else

#if 0
void *operator new(size_t cbSize)
{
	void *pv = malloc(cbSize);
	memset(pv, 0, cbSize);
	return pv;
}
#endif

#endif


