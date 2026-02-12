// new/delete
// memory tracking

#ifndef _DBG_H
#define _DBG_H
#else
#error dbg.h included twice
#endif


#if defined(_DEBUG) && !defined(DEBUG)
#error _DEBUG defined, but not DEBUG
#endif


#undef THIS_FILE
#define THIS_FILE __FILE__



#define fFalse			0
#define fTrue			1


#ifdef DEBUG
long GetDbgPref(LPCSTR pszName, long lDefault = 0);
void SetDbgPref(LPCSTR pszName, long lValue);

const int cMaxThreads = 8;
const int cchDbgTraceMax = 2048;

enum {
	traceNever			= 0x0000,	// never trace
	traceFunctions		= 0x0001,	// HKCU/TraceFunctions
	traceInterfaces		= 0x0002,	// HKCU/TraceInterfaces
	traceExit			= 0x4000,	// trace in StackTrace destructor (if traceFunctions or traceInterfaces)
	traceAlways			= 0x8000,	// always trace
	};

struct StackTrace;

struct ThreadInfo
	{
	DWORD id;
	StackTrace *pHead;
	int cIndent;
	};

// stack context tracing
struct StackTrace
	{
	StackTrace(LPCSTR pszFile, ULONG nLine, LPCSTR pszFunction, DWORD dwFlags);
	~StackTrace();

	char m_szFile[17];
	ULONG m_nLine;
	char m_szFunction[49];
	DWORD m_dwFlags;

	StackTrace *m_pNext;
	StackTrace *m_pPrev;

	static BOOL s_fIndent;
	static BOOL s_fIndentingEnabled;	// HKCU\TraceIndent says whether to indent trace output

	static DWORD s_dwMaskEnabled;

	static LPCSTR DumpToStr(BOOL fOneLine);
	static void DbgTraceV(BOOL fNewLine, const char *pszFormat, char *pvargs);
	static void LoadSettings();
	static void SaveSettings();

private:
	static ThreadInfo s_rgThreads[cMaxThreads];

	static int GetThreadIndex();
	static ThreadInfo *GetThreadInfo() { return &s_rgThreads[GetThreadIndex()]; }
	static StackTrace *GetThreadHead() { return GetThreadInfo()->pHead; }
	static void SetThreadHead(StackTrace *pHead);

	static BOOL s_fInitialized;
	static CRITICAL_SECTION s_cs;
	static void Initialize();
	static void UnInitialize();
	static void Lock() { EnterCriticalSection(&s_cs); }
	static void Unlock() {LeaveCriticalSection(&s_cs); }
	};
#endif



#define Panic()								Assert0(0, "Panic")
#define PanicSz(szFmt)						Assert0(0, szFmt)
#define Panic0(szFmt)						Assert0(0, szFmt)
#define Panic1(szFmt, p1)					Assert1(0, szFmt, p1)
#define Panic2(szFmt, p1, p2)				Assert2(0, szFmt, p1, p2)
#define Panic3(szFmt, p1, p2, p3)			Assert3(0, szFmt, p1, p2, p3)
#define Panic4(szFmt, p1, p2, p3, p4)		Assert4(0, szFmt, p1, p2, p3, p4)
#define Panic5(szFmt, p1, p2, p3, p4, p5)	Assert5(0, szFmt, p1, p2, p3, p4, p5)
#define AssertSz(f, sz)						Assert0(f, sz)

#define TraceRect(prc) Trace(" (%d,%d)-(%d,%d).", (prc)->left,(prc)->top,(prc)->right,(prc)->bottom)


#ifdef DEBUG
#define MEM_TRACK_ARGS		const char *szFileName, ULONG nLine
#define MEM_TRACK_IN		THIS_FILE, __LINE__
#define MEM_TRACK_THROUGH	szFileName, nLine
#define _MEM_TRACK_ARGS		,MEM_TRACK_ARGS
#define _MEM_TRACK_IN		,MEM_TRACK_IN
#define MEM_TRACK_IN_ALL	(MEM_TRACK_IN)
#define _MEM_TRACK_THROUGH	,MEM_TRACK_THROUGH
#define MEM_TRACK_THROUGH_ALL (MEM_TRACK_THROUGH)
#else
#define MEM_TRACK_ARGS
#define MEM_TRACK_IN
#define MEM_TRACK_THROUGH
#define _MEM_TRACK_ARGS
#define _MEM_TRACK_IN
#define MEM_TRACK_IN_ALL
#define _MEM_TRACK_THROUGH
#define MEM_TRACK_THROUGH_ALL
#endif


#define CASSERT(x) extern int dummyarray[(x) ? 1 : -1];


#ifdef DEBUG

	const int cbThreadMinStack = cchDbgTraceMax+1024;

	// stack context ------------------------------------------------------
	#define CONTEXT() StackTrace _ctx_(THIS_FILE, __LINE__, 0, traceNever)
	#define CONTEXT_(f) StackTrace _ctx_(THIS_FILE, __LINE__, (f), traceFunctions)
	#define CONTEXT_i(f) StackTrace _ctx_(THIS_FILE, __LINE__, (f), traceInterfaces)
	#define CONTEXT_2(f, dw) StackTrace _ctx_(THIS_FILE, __LINE__, (f), (dw))

	// memory allocation --------------------------------------------------
	//void *operator new(size_t cbSize, LPCSTR pszFilename, ULONG nLine);
	//void *operator new(size_t cbSize);
	//#define DEBUG_NEW new(THIS_FILE, __LINE__)

	//void operator delete(void *pv);

	void DbgCheck();

	void *DbgAlloc(size_t cbSize _MEM_TRACK_ARGS);
	void *DbgReAlloc(void *pv, size_t cbSize _MEM_TRACK_ARGS);
	void DbgFree(void *pv);

	// traces -------------------------------------------------------------
	void CDECL DbgTrace_(const char *pszFormat, ...);
	void CDECL DbgTrace(const char *pszFormat, ...);
	#define Trace_ DbgTrace_
	#define Trace DbgTrace

	// asserts ------------------------------------------------------------
	BOOL DbgAssert(const char *pszFileName, int iLine, const char *pszFmt, ...);
	#define Verify(expr) Assert(expr)

	#define PreAssert(f)	do { static BOOL fDoIt = fTrue; if (!(f) && fDoIt) fDoIt =
	#define PostAssert		} while (0)

	#define Assert(f) \
		PreAssert(f) \
		DbgAssert(THIS_FILE, __LINE__, "%s", #f); \
		PostAssert
	#define Assert0(f, szFmt) \
		PreAssert(f) \
		DbgAssert(THIS_FILE, __LINE__, szFmt); \
		PostAssert
	#define Assert1(f, szFmt, p1) \
		PreAssert(f) \
		DbgAssert(THIS_FILE, __LINE__, szFmt, p1); \
		PostAssert
	#define Assert2(f, szFmt, p1, p2) \
		PreAssert(f) \
		DbgAssert(THIS_FILE, __LINE__, szFmt, p1, p2); \
		PostAssert
	#define Assert3(f, szFmt, p1, p2, p3) \
		PreAssert(f) \
		DbgAssert(THIS_FILE, __LINE__, szFmt, p1, p2, p3); \
		PostAssert
	#define Assert4(f, szFmt, p1, p2, p3, p4) \
		PreAssert(f) \
		DbgAssert(THIS_FILE, __LINE__, szFmt, p1, p2, p3, p4); \
		PostAssert
	#define AssertFL0(szFile, iLine, f, szFmt) \
		PreAssert(f) \
		DbgAssert(szFile, iLine, szFmt); \
		PostAssert

	// conditional --------------------------------------------------------
	#define IfDebug(x) x
	#define IfNotDebug(x)

#else

	const int cbThreadMinStack = 2048;

	#define syntax_safe do {} while (0)

	// stack context ------------------------------------------------------
	#define CONTEXT()
	#define CONTEXT_(f)
	#define CONTEXT_i(f)
	#define CONTEXT_2(f, dw)

	// memory allocation --------------------------------------------------
	//#define DEBUG_NEW new
	#define DbgCheck()
	#define DbgAlloc(cbSize) malloc(cbSize)
	#define DbgReAlloc(pv, cbSize) realloc(pv, cbSize)
	#define DbgFree(pv) free(pv)

	// traces -------------------------------------------------------------
	inline void CDECL DbgTrace(const char*, ...) {}
	#define Trace_ 1 ? (void)0 : DbgTrace
	#define Trace 1 ? (void)0 : DbgTrace

	// asserts ------------------------------------------------------------
	#define Verify(expr) expr
	#define Assert(fExpr) syntax_safe
	#define Assert0(fExpr, sz) syntax_safe
	#define Assert1(fExpr, sz, arg1) syntax_safe
	#define Assert2(fExpr, sz, arg1, arg2) syntax_safe
	#define Assert3(fExpr, sz, arg1, arg2, arg3) syntax_safe
	#define Assert4(fExpr, sz, arg1, arg2, arg3, arg4) syntax_safe

	// conditional --------------------------------------------------------
	#define IfDebug(x)
	#define IfNotDebug(x) x

#endif




///////////////////////////////////////////////////////////////////////////
// DbgStop

inline void DbgStop() { _asm {int 3 } }
inline void DbgSoftStop() { __try { DbgStop(); } __except (1) {} }


//#define new DEBUG_NEW

#define MemAlloc(cbSize)			DbgAlloc(cbSize _MEM_TRACK_IN)
#define MemReAlloc(pv, cbSize)		DbgReAlloc(pv, cbSize _MEM_TRACK_IN)
#define MemFree(pv)					DbgFree(pv)


