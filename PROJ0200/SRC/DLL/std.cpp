// Standard stuff

#ifndef _STD_H
#define DEFINE_STRING_CONSTANTS
#define IMPL_GLOBALS
#include "std.h"
#else
#error std.h already included, but we need to DEFINE_STRING_CONSTANTS and IMPL_GLOBALS
#endif


#undef THIS_FILE
#define THIS_FILE __FILE__



///////////////////////////////////////////////////////////////////////////
// Critical Section

#ifdef DEBUG
CRITICAL_SECTION CritSec::s_csDebug;
CritSec *CritSec::s_pHead = 0;
const char *CritSec::s_rg[] =
	{
	c_szCSFlatFileList,
	c_szCSTagsFileList,
	};
#endif


CritSec::CritSec(IfDebug(LPCSTR pszName))
{
#ifdef DEBUG
	// verify name
	Assert(pszName);
	for (m_iName = DimensionOf(s_rg); m_iName--;)
		if (cmp(s_rg[m_iName], pszName) == 0)
			break;
	Assert1(m_iName >= 0, "CritSec name \"%s\" not found in s_rg!", pszName);

	// link
	if (!s_pHead)
		InitializeCriticalSection(&s_csDebug);
	EnterCriticalSection(&s_csDebug);
	m_pPrev = 0;
	m_pNext = s_pHead;
	s_pHead = this;
	LeaveCriticalSection(&s_csDebug);
#endif

	Init();
}


CritSec::~CritSec()
{
	Delete();

#ifdef DEBUG
	// unlink
	EnterCriticalSection(&s_csDebug);
	if (m_pNext)
		m_pNext->m_pPrev = m_pPrev;
	if (m_pPrev)
		m_pPrev->m_pNext = m_pNext;
	else
		s_pHead = m_pNext;
	LeaveCriticalSection(&s_csDebug);
	if (!s_pHead)
		DeleteCriticalSection(&s_csDebug);
#endif
}


void CritSec::Init()
{
	Assert(!m_fInitialized);

	InitializeCriticalSection(&m_cs);

#ifdef DEBUG
	m_fInitialized = fTrue;
	m_c = 0;
#endif
}


void CritSec::Delete()
{
	Assert(m_fInitialized);
	Assert(m_c == 0);

	DeleteCriticalSection(&m_cs);

#ifdef DEBUG
	m_fInitialized = fFalse;
#endif
}


void CritSec::Enter()
{
#ifdef DEBUG
	EnterCriticalSection(&s_csDebug);
	for (CritSec *pcs = s_pHead; pcs; pcs = pcs->m_pNext)
		if (pcs != this &&
			pcs->m_dwThreadId == GetCurrentThreadId() &&
			pcs->m_iName >= m_iName)
			{
			char sz[512];

			wsprintf(sz, "DANGER WILL ROBINSON!  DEADLOCK ALERT!\n\n"
					 "Order violation.  Entering CritSec \"%s\" (%d), "
					 "but CritSec \"%s\" (%d) has already been entered!",
					 s_rg[m_iName], m_iName, s_rg[pcs->m_iName], pcs->m_iName);

			if (m_c > 0)
				{
				char sz2[256];

				wsprintf(sz2, "\n\nNOTE: the former has %d locks on it; "
						 "you can try just asserting FLocked() instead of "
						 "actually locking it.", m_c);
				lstrcat(sz, sz2);
				}

			PanicSz(sz);
			}
	LeaveCriticalSection(&s_csDebug);
#endif

	// enter the actual critical section
	EnterCriticalSection(&m_cs);

#ifdef DEBUG
	EnterCriticalSection(&s_csDebug);
	// increment AFTER entering the critical section, otherwise Leave can
	// decrement m_c after we've prematurely incremented it, causing
	// m_dwThreadId to not get cleared.  (ideally this whole function would
	// just be an atomic operation).
	m_c++;
	if (m_dwThreadId != GetCurrentThreadId())
		{
		Assert(!m_dwThreadId);
		m_dwThreadId = GetCurrentThreadId();
		}
	LeaveCriticalSection(&s_csDebug);
#endif
}


#ifdef NOT_WIN95
BOOL CritSec::TryEnter()
{
#ifdef DEBUG
	EnterCriticalSection(&s_csDebug);
	for (CritSec *pcs = s_pHead; pcs; pcs = pcs->m_pNext)
		if (pcs != this &&
			pcs->m_dwThreadId == GetCurrentThreadId() &&
			pcs->m_iName >= m_iName)
			{
			char sz[512];

			wsprintf(sz, "DANGER WILL ROBINSON!  DEADLOCK ALERT!\n\n"
					 "Order violation.  Entering CritSec \"%s\" (%d), "
					 "but CritSec \"%s\" (%d) has already been entered!",
					 s_rg[m_iName], m_iName, s_rg[pcs->m_iName], pcs->m_iName);

			if (m_c > 0)
				{
				char sz2[256];

				wsprintf(sz2, "\n\nNOTE: the former has %d locks on it; "
						 "you can try just asserting FLocked() instead of "
						 "actually locking it.", m_c);
				lstrcat(sz, sz2);
				}

			PanicSz(sz);
			}
	LeaveCriticalSection(&s_csDebug);
#endif

	// try to enter the actual critical section
	if (TryEnterCriticalSection(&m_cs))
		{
#ifdef DEBUG
		EnterCriticalSection(&s_csDebug);
		// increment AFTER entering the critical section, otherwise Leave can
		// decrement m_c after we've prematurely incremented it, causing
		// m_dwThreadId to not get cleared.  (ideally this whole function would
		// just be an atomic operation).
		m_c++;
		if (m_dwThreadId != GetCurrentThreadId())
			{
			Assert(!m_dwThreadId);
			m_dwThreadId = GetCurrentThreadId();
			}
		LeaveCriticalSection(&s_csDebug);
#endif
		return fTrue;
		}
	return fFalse;
}
#endif


void CritSec::Leave()
{
#ifdef DEBUG
	EnterCriticalSection(&s_csDebug);
	Assert(m_c > 0);
	if (--m_c == 0)
		m_dwThreadId = 0;
	LeaveCriticalSection(&s_csDebug);
#endif

	LeaveCriticalSection(&m_cs);
}


void ScopedCritSec::Init(CritSec *pcs)
{
	Init(pcs, fTrue);
}


void ScopedCritSec::Init(CritSec *pcs, BOOL fNow)
{
	Assert(pcs);

	m_fEntered = fFalse;
	m_pcs = pcs;

	if (fNow)
		Enter();
}


void ScopedCritSec::Enter()
{
	Assert(!m_fEntered);

	m_fEntered = fTrue;
	m_pcs->Enter();
}


void ScopedCritSec::Leave()
{
	if (m_fEntered)
		{
		m_pcs->Leave();
		m_fEntered = fFalse;
		}
}



///////////////////////////////////////////////////////////////////////////
// RefCount

ULONG RefCount::Release(void *pobj)
{
	if (m_cRef > 1)
		{
		return --m_cRef;
		}
	else
		{
		delete pobj;
		return 0;
		}
}


#if 0
void StripFileNameFromWz(WCHAR *wz)
{
	WCHAR *pwz;

	for (pwz = wz + MsoCchWzLen(wz); pwz >= wz; pwz--)
		{
		if (*pwz == WCHAR('\\'))
			{
			*pwz = WCHAR('\0');
			break;
			}
		}
}

void EnsureTrailingBackSlash(WCHAR *wz)
{
	Assert(wz && *wz);
	int cch = MsoCchWzLen(wz);

	if (cch && wz[cch-1] == L'\\')
		return;
	MsoWzAppend(L"\\", wz);	// STRING_OK [chrisant]
}
#endif



///////////////////////////////////////////////////////////////////////////
// Helper functions

HRESULT HrLoadString(int ids, LPSTR psz, UINT cch)
{
	HRESULT hr = hrOK;
	if (!LoadString(g_hInst, ids, psz, cch))
		//$ review: (chrisant) LoadString returns 0 on error, else # of
		// characters copied not including null terminator; so what happens if
		// the string is an empty string?
		hr = HrFromWin32(GetLastError());
	return hr;
}



///////////////////////////////////////////////////////////////////////////
// String class

int cmp(LPCSTR psz1, LPCSTR psz2)
{
	while (TRUE)
		{
		if (*psz1 > *psz2)
			return 1;
		if (*psz1 < *psz2)
			return -1;

		if (!*psz1)
			return 0;

		++psz1;
		++psz2;
		}
}


int cmpi(LPCSTR psz1, LPCSTR psz2)
{
	char ch1;
	char ch2;

	while (TRUE)
		{
		ch1 = ChCaseless(*psz1);
		ch2 = ChCaseless(*psz2);

		if (ch1 > ch2)
			return 1;
		if (ch1 < ch2)
			return -1;

		if (!ch1)
			return 0;

		++psz1;
		++psz2;
		}
}


LPSTRING TSE(LPCSTR psz, long cch)
{
	static STRING255 strSAL;

	if (!psz)
		strSAL.m_cLen = 0;
	else
		{
		if (cch == -1)
			cch = lstrlen(psz);

		// truncates to 255 if necessary
		if (cch > MAXSALSTR)
			cch = MAXSALSTR;

		strSAL.m_cLen = (short unsigned int) cch;
		lstrcpyn(strSAL.m_sz, psz, MAXSALSTR);
		}
	return &strSAL;
}


String::String()
{
	Zero();
}


String::~String()
{
	if (!m_cAlloc)
		// zero this out so the base class destructor doesn't try to free
		// g_szNull (optimization when pass an empty string to HrDup).
		m_p = 0;
}


void String::Free()
{
	if (!m_cAlloc)
		// zero this out so the base class Free doesn't try to free
		// g_szNull (optimization when pass an empty string to HrDup).
		m_p = 0;
	Zero();
	SPSZ::Free();
}


#if 0
LPSTR String::Transfer()
{
	LPSTR psz = 0;

	if (!m_cAlloc)
		{
		// String is optimized so empty strings aren't allocated, but in this
		// case it's safer to allocate an empty string to return.  Transfer()
		// is rarely used so this should not present a performance problem.
		if (m_p)
			//$ WARNING: (chrisant) caller STILL must handle the null return
			// value case because this allocation could fail!
			psz = SzMemDup(m_p);
		}
	else
		psz = SPSZ::Transfer();
	Zero();
	return psz;
}
#endif


LPSTR String::Transfer()
{
	LPSTR psz = SPSZ::Transfer();
	Zero();
	return psz;
}


LPCSTR String::SetConst(LPCSTR p)
{
	Free();
	m_p = (LPSTR)p;
	Zero();
	return m_p;
}


LPSTR String::Attach(LPSTR p)
{
	Free();
	m_p = p;
	Resync();
	return m_p;
}


ULONG String::Length()
{
	EnsureLength();
	return m_cLen;
}


ULONG String::cb()
{
	// return total size of string in bytes, including null terminator
	EnsureLength();
	return (m_cLen + 1)*sizeof(char);
}


void String::MakeSafeSz()
{
	if (!m_p)
		{
		Zero();
		m_p = (LPSTR)(LPCSTR)g_szNull;
		}
}


#if 0
inline BOOL IsWhite(char ch)
{
	return (ch == ' ' || ch == '\t' || ch == '\r' || ch == '\n');
}


ULONG TrimString(char* pszIn)
{
	char *psz = pszIn;
	char *pszBeg;
	char *pszEnd;
	ULONG cch;

	// find first non-white character
	while (IsWhite(*psz))
		++psz;
	pszBeg = psz;
	// find last non-white character
	for (pszEnd = psz; *psz; ++psz)
		{
		if (!IsWhite(*psz))
			pszEnd = psz;
		}
	// truncate right
	if (*pszEnd)
		*(++pszEnd) = 0;
	// remember length
	cch = (pszEnd - pszBeg);
	// truncate left
	if (pszBeg > pszIn)
		memcpy(pszIn, pszBeg, (cch + 1)*sizeof(*pszIn));
	return cch;
}


void String::Trim()
{
	if (m_p && m_cAlloc)	// don't have to EnsureAlloc() to use m_cAlloc
							// here because we just want to make sure we're
							// not pointing to g_szNull.
		{
		EnsureAlloc();
		m_cLen = TrimString(m_p);
		}
}
#endif


#if 0
#define CHAR_FUDGE 2	// two bytes for DBCS last character
HRESULT String::HrLoadString(UINT ids)
{
	char sz[256];		// try w/static buffer first, avoid heap fragmentation
	int nLen;
	HRESULT hr = hrNoMem;

	Free();
	nLen = LoadString(g_hInst, ids, sz, DimensionOf(sz));
	//$ review: (chrisant) how should we handle the 0-length string vs. the
	// string-not-found case?
	if (DimensionOf(sz) - nLen > CHAR_FUDGE)
		{
		hr = HrDup(sz);
		}
	else
		{
		// try 512 buffer, growing by 256 until entire string is retrieved
		int nSize = 256;
		LPSTR psz = 0;

		do
			{
			nSize += 256;
			delete psz;
			psz = New char[nSize];
			if (!psz)
				{
				Zero();
				goto Error;
				}
			// don't have to worry about psz b/c we delete it above, and we
			// can't fail once it's allocated.
			nLen = LoadString(g_hInst, ids, psz, nSize);
			}
		while (nSize - nLen <= CHAR_FUDGE);
		m_p = psz;
		m_cLen = nLen;
		m_cAlloc = nSize;
		hr = hrOK;
		}

Error:
	return hr;
}
#endif


#if 0
HRESULT String::HrRegQueryValue(HKEY hkey, LPCSTR pszValue, LPCSTR pszDefault)
{
	CONTEXT_("String::HrRegQueryValue");
	HRESULT hr = hrOK;
	DWORD dwError;
	DWORD dwType = 0;
	char sz[256];
	DWORD cbLen = sizeof(sz);
	LPSTR psz = 0;

	Assert(!m_p);

	// try once with small fixed size buffer
	dwError = RegQueryValueEx(hkey, pszValue, 0, &dwType, (LPBYTE)sz, &cbLen);

	if (dwError == ERROR_MORE_DATA && dwType == REG_SZ)
		{
		// buffer not big enough.  allocate correct size and try again
		psz = New char[cbLen];
		CPRg(psz);
		CWRg(RegQueryValueEx(hkey, pszValue, 0, &dwType, (LPBYTE)psz, &cbLen));
		m_p = psz;
		m_cAlloc = (short)(cbLen/sizeof(char));
		m_cLen = m_cAlloc - 1;
		psz = 0;
		}

	if (dwType != REG_SZ || dwError != ERROR_SUCCESS)
		{
		// error, use the default value
		if (!pszDefault)
			pszDefault = g_szNull;
		CORg(HrDup(pszDefault));
		}
	else
		{
		// success
		Assert(dwError == ERROR_SUCCESS);
		CORg(HrDup(sz));
		}

Error:
	delete psz;
	return hr;
}


HRESULT String::HrRegSetValue(HKEY hkey, LPCSTR pszValue)
{
	CONTEXT_("String::HrRegSetValue");

	MakeSafeSz();
	return HrFromWin32(RegSetValueEx(hkey, pszValue, 0, REG_SZ, (LPBYTE)(LPSTR)m_p, cb()));
}
#endif


HRESULT String::HrDup(LPCSTR psz)
{
	ULONG cch = 0;

	Free();
	if (psz)
		cch = lstrlen(psz);
	if (!cch)
		{
		// if we're trying to dup an empty string, let's optimize to avoid
		// actually following through on such a silly act.
		Zero();
		m_p = (LPSTR)(LPCSTR)g_szNull;
		}
	else
		{
		m_p = New char[cch + 1];
		if (!m_p)
			{
			Zero();
			return hrNoMem;
			}
		lstrcpy(m_p, psz);			// don't need lstrcpyn

		Assert(((cch + 1) >> (sizeof(m_cLen) * 8)) == 0);

		m_cLen = (unsigned short)cch;
		m_cAlloc = (unsigned short)(cch + 1);
		}
	return hrOK;
}


HRESULT String::HrAppend(LPCSTR psz, ULONG cchSlack)
{
	HRESULT hr = hrNoMem;
	LPSTR p = 0;

	// it is valid to call HrAppend even if m_p == 0
	if (psz)
		{
		unsigned short cch;

		EnsureLength();
		EnsureAlloc();

		AssertSz(!(m_p && !m_cAlloc), "cannot append to a constant string");

		if (m_cAlloc)
			p = m_p;

		cch = lstrlen(psz);
		if (m_cLen + cch >= m_cAlloc)
			{
			if (cchSlack)
				m_cAlloc = m_cLen + cch + (unsigned short)cchSlack;
			else
				{
				// this ensures O(n) performance when appending repeatedly
				if (cch > m_cLen)
					m_cAlloc = m_cLen + cch;
				else
					m_cAlloc = m_cLen * 2;
				}
			m_cAlloc++;		// null terminator
			m_p = New char[m_cAlloc];
			}
		else
			p = 0;
		if (!m_p)
			{
			Zero();
			goto Error;
			}
		if (p)
			lstrcpy(m_p, p);			// don't need lstrcpyn
		lstrcpy(m_p + m_cLen, psz);		// don't need lstrcpyn
		m_cLen += cch;
		}
	hr = hrOK;

Error:
	delete p;
	return hr;
}


HRESULT String::HrAppend(const char ch)
{
	char sz[2];

	sz[0] = ch;
	sz[1] = 0;
	return HrAppend(sz, 0);
}


LPSTRING String::TSE()
{
	return ::TSE(GetSafeSz(), Length());
}



///////////////////////////////////////////////////////////////////////////
// Preferences

#ifdef DEBUG
	enum {_prefI4, _prefSTRING, _prefMAX};
	#define BOOL_PREF(pref, str, def)		{str, (DWORD)(BOOL)def, pref, _prefI4},
	#define LONG_PREF(pref, str, def)		{str, (DWORD)(long)def, pref, _prefI4},
	#define ULONG_PREF(pref, str, def)		{str, (DWORD)(ULONG)def, pref, _prefI4},
	#define STRING_PREF(pref, str, def)		{str, (DWORD)(const WCHAR*)def, pref, _prefSTRING},
#else
	#define BOOL_PREF(pref, str, def)		{str, (DWORD)(BOOL)def},
	#define LONG_PREF(pref, str, def)		{str, (DWORD)(long)def},
	#define ULONG_PREF(pref, str, def)		{str, (DWORD)(ULONG)def},
	#define STRING_PREF(pref, str, def)		{str, (DWORD)(const WCHAR*)def},
#endif


#if 0
struct PrefRecord
{
	const char *pstr;
	DWORD dwDef;
	IfDebug(int pref;)
	IfDebug(int dbgPrefType;)
};

const PrefRecord c_rgPrefs[] =
{
};


void GetI4Pref(int pref, DWORD& dw)
{
	Assert(pref >= 0 && pref < prefMAX);
	Assert(c_rgPrefs[pref].pref == pref);
	Assert(c_rgPrefs[pref].dbgPrefType == _prefI4);

	dw = c_rgPrefs[pref].dwDef;

	//$ todo: (chrisant) look up in registry
}


void SetI4Pref(int pref, DWORD dw)
{
	//$ todo: (chrisant) set in registry
}


BOOL GetPref(int pref)
{
	BOOL f;
	GetI4Pref(pref, *(DWORD*)&f);
	return f;
}


//$ review: (chrisant) should these be HrGetPref?  what if allocating a string fails?
void GetPref(int pref, String &st)
{
	Assert(pref >= 0 && pref < prefMAX);
	Assert(c_rgPrefs[pref].pref == pref);
	Assert(c_rgPrefs[pref].dbgPrefType == _prefSTRING);

	//$ todo: (chrisant) look up in registry

	// default value
	st.HrDup((LPCSTR)c_rgPrefs[pref].dwDef);
}


void SetPref(int pref, LPCSTR psz)
{
	//$ todo: (chrisant) set in registry
}
#endif



///////////////////////////////////////////////////////////////////////////
// Memory

#undef new


LPSTR SzMemDupRaw(LPCSTR pszFrom _MEM_TRACK_ARGS)
{
	DWORD	cch = lstrlen(pszFrom)+1;
	LPSTR	psz = new MEM_TRACK_THROUGH_ALL char[cch];
	if (psz)
		memcpy(psz, pszFrom, (size_t)(cch*sizeof(char)));
	return psz;
}


void* _cdecl operator new(size_t nSize, HRESULT *phr _MEM_TRACK_ARGS)
{
	void *pv;
	pv = DbgAlloc(nSize _MEM_TRACK_THROUGH);

	if (phr)
		*phr = (pv ? hrOK : hrNoMem);
	if (pv)
		memset(pv, 0, nSize);
	return pv;
}


void* _cdecl operator new(size_t nSize _MEM_TRACK_ARGS)
{
	void *pv;
	pv = DbgAlloc(nSize _MEM_TRACK_THROUGH);
	if (pv)
		memset(pv, 0, nSize);
	return pv;
}


#ifdef DEBUG
void* _cdecl operator new(size_t nSize)
{
	Panic0("bad.  use New or NewHr instead of new.");
	return 0;
}


void _cdecl operator delete(void* pv)
{
	DbgFree(pv);
}
#endif


