// Standard stuff

#ifndef _STD_H
#define _STD_H
#else
#error std.h already included
#endif

#ifndef _PROJDLL_H
#include "projdll.h"
#endif

#ifndef _DBG_H
#include "dbg.h"
#endif

#ifndef _ARRAYS_H
#include "arrays.h"
#endif


#undef THIS_FILE
#define THIS_FILE __FILE__



///////////////////////////////////////////////////////////////////////////
// Types

#define cexport extern "C" __declspec(dllexport)


typedef ULONG ulong;
typedef unsigned char boolean;


struct STRING
	{
	unsigned short m_cLen;
	char m_sz[1];
	};
typedef FAR STRING *LPSTRING;


struct STRING255
	{
	LPSTRING operator&() { return (STRING*)(STRING255*)this; }

	unsigned short m_cLen;
	char m_sz[255];
	};
typedef FAR STRING255 *LPSTRING255;



///////////////////////////////////////////////////////////////////////////
// Constants

#define MAXPATH 256
#define MAXSALSTR 255

#define fFalse			0
#define fTrue			1
#define IMPL

#define hrOK			HRESULT(0)
#define hrTrue			HRESULT(0)
#define hrFalse			ResultFromScode(S_FALSE)
#define hrFail			ResultFromScode(E_FAIL)
#define hrNotImpl		ResultFromScode(E_NOTIMPL)
#define hrNoInterface	ResultFromScode(E_NOINTERFACE)
#define hrNoMem			ResultFromScode(E_OUTOFMEMORY)
#define hrAbort			ResultFromScode(E_ABORT)

#define MAX_ASCII_CLSID	40

const LARGE_INTEGER liZero = { 0, 0 };
const ULARGE_INTEGER c_uliZero = { 0, 0 };
const ULARGE_INTEGER c_uliNegOne = { -1, -1 };

const char c_chDiv = 1;


enum { lookFirst, lookPrev, lookNext, lookLast, lookExact = 0x8000 };



///////////////////////////////////////////////////////////////////////////
// Globals

#ifdef IMPL_GLOBALS
#define GLOBAL(var) var
#define GLOBAL_(var, value) var = value
#else
#define GLOBAL(var) extern var
#define GLOBAL_(var, value) extern var
#endif

GLOBAL(HINSTANCE g_hInst);

GLOBAL_(STRING g_strNull, {0});



///////////////////////////////////////////////////////////////////////////
// General Macros

void* _cdecl operator new(size_t nSize, HRESULT *phr _MEM_TRACK_ARGS);
void* _cdecl operator new(size_t nSize _MEM_TRACK_ARGS);

#define NewHr(phr) new(phr _MEM_TRACK_IN)
#define New new MEM_TRACK_IN_ALL

void _cdecl operator delete(void* pv);

#define OffsetOf(s,m)		(size_t)( (char *)&(((s *)0)->m) - (char *)0 )
#define EmbeddorOf(C,m,p)	((C *)(((char *)p) - OffsetOf(C,m)))
#define DimensionOf(x)		(sizeof(x)/sizeof(*(x)))

class String;
class Object;



///////////////////////////////////////////////////////////////////////////
// Error handling

inline HRESULT HrFromWin32(ULONG l) { return HRESULT_FROM_WIN32(l); }
#undef HRESULT_FROM_WIN32
#define HRESULT_FROM_WIN32 PleaseUseHrFromWin32
#define CWRg(l) CORg(HrFromWin32(l))
#define CFRg(fResult) CORg(fResult ? hrOK : hrFail)
#define CPRg(fResult) CORg(fResult ? hrOK : hrNoMem)

#define CORg(hResult)\
	do\
		{\
		hr = (hResult);\
		if (FAILED(hr))\
			{\
			AssertSz(hr != 0xcccccccc, "Uninitialized hr!");\
			Trace("ERROR 0x%08x at line %d of %s.", hr, __LINE__, THIS_FILE);\
			goto Error;\
			}\
		}\
	while (fFalse)

#define CORg2(hResult)\
	do\
		{\
		hr = (hResult);\
		if (FAILED(hr))\
			{\
			AssertSz(hr != 0xcccccccc, "Uninitialized hr!");\
			Trace("ERROR 0x%08x at line %d of %s.", hr, __LINE__, THIS_FILE);\
			goto Error_2;\
			}\
		}\
	while (fFalse)



///////////////////////////////////////////////////////////////////////////
// String Helpers

#if 0
void StripFileNameFromTz(LPSTR psz);
void EnsureTrailingBackSlash(LPSTR psz);
#endif

LPSTR SzMemDupRaw(LPCSTR pszFrom _MEM_TRACK_ARGS);
#define SzMemDup(szFrom) SzMemDupRaw(szFrom _MEM_TRACK_IN)



///////////////////////////////////////////////////////////////////////////
// Smart Pointers

#define DeclareSP(TAG,Type)  DeclareSmartPointer(SP##TAG,Type,delete m_p)

#define DeclareSPBasic(TAG,Type) \
	DeclareSPPrivateBasic(SP##TAG,Type,delete m_p)

#define DeclareSPCore(klass, Type, free)\
class klass \
{\
public:\
	klass(Type *p = 0)		{ m_p = p; }\
	~klass()				{ free; }\
	operator Type*() const	{ return m_p; }\
	Type &operator*() const	{ return *m_p; }\
	Type &operator[](ULONG i) const	{ return m_p[i]; }\
	Type **operator &()		{ Assert1(!m_p,"Non-empty %s as out param.",#klass); return &m_p; }\
	Type *operator=(Type *p){ Assert1(!m_p,"Non-empty %s in assignment.",#klass); return m_p = p; }\
	Type *Transfer()		{ Type *p = m_p; m_p = 0; return p; }\
	void Free()				{ free; m_p = 0; }\
protected:\
	Type *m_p;

#define DeclareSPPrivateBasic(klass, Type, free)\
	DeclareSPCore(klass, Type, free)\
};

#define DeclareSmartPointer(klass, Type, free)\
	DeclareSPCore(klass, Type, free)\
public:\
	Type *operator->() const	{ return m_p; }\
};

// some basic smart pointers.
DeclareSPBasic(SZ, char)		// #define SPSZ, class SPSZ



#define FHr SUCCEEDED
#define FHrSucceeded SUCCEEDED
#define FHrFailed FAILED
inline BOOL FHrOK(HRESULT hr) { return hr == hrOK; }
inline BOOL FHrTrue(HRESULT hr) { return hr == hrTrue; }
inline BOOL FHrFalse(HRESULT hr) { return hr == hrFalse; }



///////////////////////////////////////////////////////////////////////////
// Critical Section

class CritSec
{
public:
	CritSec(IfDebug(LPCSTR pszName));
	~CritSec();

	void Init();
	void Delete();

	void Enter();
#ifdef NOT_WIN95
	BOOL TryEnter();
#endif
	void Leave();

#ifdef DEBUG
	BOOL FEntered() { return (m_c > 0); }
#endif

private:
	CRITICAL_SECTION	m_cs;

#ifdef DEBUG
	unsigned			m_c;
	DWORD				m_dwThreadId;
	unsigned			m_fInitialized : 1;
	unsigned			m_iName;

	CritSec				*m_pNext;
	CritSec				*m_pPrev;
#endif

private:
#ifdef DEBUG
	static CRITICAL_SECTION		s_csDebug;
	static CritSec				*s_pHead;
	static const char			*s_rg[];
#endif
};


class ScopedCritSec
{
public:
	ScopedCritSec(CritSec& cs)					{ Init(&cs); }
	ScopedCritSec(CritSec& cs, BOOL fNow)		{ Init(&cs, fNow); }
	ScopedCritSec(CritSec *pcs)					{ Init(pcs); }
	ScopedCritSec(CritSec *pcs, BOOL fNow)		{ Init(pcs, fNow); }
	~ScopedCritSec()							{ Leave(); }

	void Enter();
#ifdef NOT_WIN95
	BOOL TryEnter();
#endif
	void Leave();

private:
	void Init(CritSec *pcs);
	void Init(CritSec *pcs, BOOL fNow);

	CritSec				*m_pcs;
	unsigned char		m_fEntered : 1;
};



///////////////////////////////////////////////////////////////////////////
// RefCount

class RefCount
{
public:
	RefCount();
	~RefCount();
	ULONG AddRef();
	ULONG Release(void *pobj);
	ULONG m_cRef;
};

inline RefCount::RefCount() : m_cRef(1)
{
}

inline RefCount::~RefCount()
{
	Assert(m_cRef == 1);
}

inline ULONG RefCount::AddRef()
{
	return ++m_cRef;
}



///////////////////////////////////////////////////////////////////////////
// Helper Functions

HRESULT HrLoadString(int ids, LPSTR psz, UINT cch);



///////////////////////////////////////////////////////////////////////////
// Global Strings

#ifdef DEFINE_STRING_CONSTANTS
#define STR_GLOBAL_ANSI(x,y)		extern "C" CDECL const char x[] = y
#define STR_GLOBAL_WIDE(x,y)		extern "C" CDECL const WCHAR x[] = L##y
#else
#define STR_GLOBAL_ANSI(x,y)		extern "C" CDECL const char x[]
#define STR_GLOBAL_WIDE(x,y)		extern "C" CDECL const WCHAR x[]
#endif

#ifdef UNICODE
#define STR_GLOBAL STR_GLOBAL_WIDE
#else
#define STR_GLOBAL STR_GLOBAL_ANSI
#endif


STR_GLOBAL(g_szNull, "");


#ifdef DEBUG
STR_GLOBAL(c_szCSFlatFileList, "FlatFileList");
STR_GLOBAL(c_szCSTagsFileList, "TagsFileList");
STR_GLOBAL(c_szCSTagThreads, "TagThreads");
#endif



///////////////////////////////////////////////////////////////////////////
// String class

int cmp(LPCSTR psz1, LPCSTR psz2);
int cmpi(LPCSTR psz1, LPCSTR psz2);

ULONG TrimString(WCHAR* pwz);
ULONG TrimString(char* psz);

LPSTRING TSE(LPCSTR psz, long cch);

class String : public SPSZ
{
public:
	String();
	~String();

	void Free();
	LPSTR Transfer();		// transfers ownership, returns NULL for empty string

	LPSTRING TSE();

	LPCSTR GetSafeSz() const { return m_p ? m_p : g_szNull; }
	void MakeSafeSz();
	ULONG Length();
	ULONG cb();

	char &operator[](ULONG i) const { Assert(m_p); return m_p[i]; }
	char **operator&() { AssertSz(!m_p, "Non-empty String as out param."); Resync(); return &m_p; }
	String *PString() { return this; }

	LPCSTR operator=(LPCSTR p) { return SetConst(p); }
	LPSTR operator=(LPSTR p) { return Attach(p); }
	LPSTR Attach(LPSTR p);
	LPCSTR SetConst(LPCSTR p);

	void Resync() { m_cLen = m_cAlloc = -1; }

#if 0
	void Trim();
	void CopyTo(LPSTR psz) { lstrcpy(psz, GetSafeSz()); }
#endif
	void CopyToN(LPSTR psz, ULONG cchMax) { lstrcpyn(psz, GetSafeSz(), cchMax-1); }
	BOOL IsEmpty() { return ((LPSTR)m_p && *(LPSTR)m_p) ? fFalse : fTrue; }
	HRESULT HrDup(LPCSTR psz);
	HRESULT HrAppend(LPCSTR psz, ULONG cchSlack = 0);
	HRESULT HrAppend(const char ch);
#if 0
	HRESULT HrLoadString(UINT ids);
	HRESULT HrRegQueryValue(HKEY hkey, LPCSTR psz, LPCSTR pszDefault = 0);
	HRESULT HrRegSetValue(HKEY hkey, LPCSTR psz);
#endif

	int Compare(LPCSTR psz) { return cmp(GetSafeSz(), psz); }
	int CompareI(LPCSTR psz) { return cmpi(GetSafeSz(), psz); }

private:
	void EnsureLength() { if (m_cLen == -1) m_cLen = lstrlen(GetSafeSz()); }
	void EnsureAlloc() { if (m_cAlloc == -1) m_cAlloc = lstrlen(GetSafeSz())+1; }
	void Zero() { m_cLen = m_cAlloc = 0; }

	short unsigned int m_cLen;
	short unsigned int m_cAlloc;
};



///////////////////////////////////////////////////////////////////////////
// Arrays

DEFINE_GENARRAY_CLASS(String)



///////////////////////////////////////////////////////////////////////////
// Inline helpers

inline char ChCaseless(char ch)
{
	// lstrcmpi apparently uses lower case for caseless comparisons, so we
	// must also.
	return (ch >= 'A' && ch <= 'Z') ? (ch | 0x20) : ch;
}



///////////////////////////////////////////////////////////////////////////
// Preferences

#if 0
enum {
	prefDockEdge,
	prefMAX
	};


// do not use these directly, use the accessors below
void GetI4Pref(int pref, DWORD &dw);
void SetI4Pref(int pref, DWORD dw);


// preference accessors
BOOL GetPref(int pref);
inline void GetPref(int pref, long &l)		{ GetI4Pref(pref, (*(DWORD*)&l)); }
inline void GetPref(int pref, ULONG &ul)	{ GetI4Pref(pref, (*(DWORD*)&ul)); }
void GetPref(int pref, String &st);

inline void SetPref(int pref, BOOL f)		{ SetI4Pref(pref, (DWORD)f); }
inline void SetPref(int pref, long l)		{ SetI4Pref(pref, (DWORD)l); }
inline void SetPref(int pref, ULONG ul)		{ SetI4Pref(pref, (DWORD)ul); }
void SetPref(int pref, LPCSTR psz);
#endif


