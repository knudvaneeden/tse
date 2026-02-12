// Threaded Tags Support

#ifndef _PROJDLL_H
#include "projdll.h"
#endif

#ifndef _TAGS_H
#include "tags.h"
#endif


#undef THIS_FILE
#define THIS_FILE __FILE__



//#define VERBOSE_TAG_TRACES

#ifdef VERBOSE_TAG_TRACES
#define TagTrace Trace
#else
#define TagTrace
#endif



///////////////////////////////////////////////////////////////////////////
// Constants

const DWORD cchBufferSize = 4096 * 16;



///////////////////////////////////////////////////////////////////////////
// Types

class TagInfo;


struct TagFile
	{
#ifdef DEBUG
	TagFile();
#endif
	~TagFile();

	TagFile			*m_pNext;
	TagFile			*m_pPrev;

	String			m_stTagFile;
	Rg<TagInfo>		m_rgti;

	ULONG			m_cchLongest;

	Rg<String>		m_rgstSymbols;
	HRESULT HrAddSymbol(LPCSTR pszSymbol, String **ppst);
	};


class TagInfo
{
public:
	TagInfo() { Assert(!m_psz); }
	~TagInfo() { MemFree(m_psz); }

	HRESULT	HrInit(LPCSTR pszSymbol, LPCSTR pszFile, ULONG ulLine,
				   LPCSTR pszSearchLine, char type, BOOL fAnchorToEnd);

	LPCSTR	SzSymbol() { return m_pszSymbol; }
	LPCSTR	SzFile() { return m_pszFile; }
	ULONG	Line() { return m_ulLine; }
	LPCSTR	SzSearchLine() { return m_pszSearchLine; }
	char	Type() { return m_type; }
	BOOL	FAnchorToEnd() { return m_fAnchorToEnd; }

private:
	LPCSTR			m_pszSymbol;
	LPCSTR			m_pszFile;
	ULONG			m_ulLine;
	LPCSTR			m_pszSearchLine;
	char			m_type;
	unsigned		m_fAnchorToEnd : 1;

	LPSTR			m_psz;

	TagInfo(const TagInfo&) { Panic(); }
};
DEFINE_GENARRAY_CLASS(TagInfo)


struct TagThreadInfo
	{
	HANDLE			hThread;
	String			stTagFile;
	BOOL			fCompleted;
	BOOL			fAbort;
	long			lRet;
	};


typedef int (*CompareFn2)(LPCSTR pszExactTag, TagInfo *pti);



///////////////////////////////////////////////////////////////////////////
// Globals

#ifdef DEBUG
static BOOL					s_fInitialized = fFalse;
#endif

#if 0
static BOOL					s_fReload = fFalse;
static ULONG				s_cLoaded;
#endif

static TagFile				*s_ptfHead = 0;
static TagFile				*s_ptfCurrent = 0;
static CritSec				s_csTags IfDebug((c_szCSTagsFileList));

static Rg<TagThreadInfo*>	s_rgThreads;
static CritSec				s_csTagThreads IfDebug((c_szCSTagThreads));



///////////////////////////////////////////////////////////////////////////
// Tags Functions

static TagFile *FindTagFile(LPCSTR psz)
{
	for (TagFile *ptf = s_ptfHead;
		 ptf && ptf->m_stTagFile.CompareI(psz) != 0;
		 ptf = ptf->m_pNext);
	return ptf;
}


static int Cmp_Exact(LPCSTR pszExactTag, TagInfo *pti)
{
	CONTEXT_("Cmp_Exact");
	return cmp(pszExactTag, pti->SzSymbol());
}


static int CmpI_Exact(LPCSTR pszExactTag, TagInfo *pti)
{
	CONTEXT_("CmpI_Exact");
	return cmpi(pszExactTag, pti->SzSymbol());
}


static int Cmp_Lookup(LPCSTR pszPartialTag, TagInfo *pti)
{
	CONTEXT_("Cmp_Lookup");
	LPCSTR psz1 = pszPartialTag;
	LPCSTR psz2 = pti->SzSymbol();
	char ch1;
	char ch2;
	BOOL fIgnore = Get_Int(iFIgnoreCase);

	while (TRUE)
		{
		ch1 = *psz1;
		ch2 = *psz2;
		if (fIgnore)
			{
			ch1 = ChCaseless(ch1);
			ch2 = ChCaseless(ch2);
			}

		if (!ch1)
			return 0;

		if (ch1 > ch2 || !ch2)
			return 1;
		if (ch1 < ch2)
			return -1;

		++psz1;
		++psz2;
		}
}


static int Cmp_String(LPCSTR psz, String *pst)
{
	CONTEXT_("Cmp_String");
	return cmp(psz, pst->GetSafeSz());
}


static int CmpI_String(LPCSTR psz, String *pst)
{
	CONTEXT_("CmpI_String");
	return cmpi(psz, pst->GetSafeSz());
}


static int CmpI_TagFile(LPCSTR psz, TagFile *ptf)
{
	CONTEXT_("CmpI_TagFile");
	return cmpi(psz, ptf->m_stTagFile.GetSafeSz());
}


LPSTR StrChr(LPSTR psz, const char ch)
{
	CONTEXT_("StrChr");
	if (psz)
		{
		for (; *psz; ++psz)
			if (*psz == ch)
				break;
		if (!*psz && ch != 0)
			psz = NULL;
		}
	return psz;
}



///////////////////////////////////////////////////////////////////////////
// TagFile struct

#ifdef DEBUG
TagFile::TagFile()
{
	Assert(!m_pPrev);
	Assert(!m_pNext);
	Assert(!m_cchLongest);
}
#endif


TagFile::~TagFile()
{
	CONTEXT_("TagFile::~TagFile");
	ScopedCritSec cs(s_csTags);

	if (this == s_ptfCurrent)
		s_ptfCurrent = 0;
	if (m_pPrev)
		m_pPrev->m_pNext = m_pNext;
	else
		s_ptfHead = m_pNext;
	if (m_pNext)
		m_pNext->m_pPrev = m_pPrev;
}


HRESULT TagFile::HrAddSymbol(LPCSTR pszSymbol, String **ppst)
{
	CONTEXT_("TagFile::HrAddSymbol");
	HRESULT		hr = hrOK;
	ulong		iIndex;
	String		*pst;

	if (Get_Int(iFIgnoreCase))
		{
		if (m_rgstSymbols.FSearch((CompareFn)CmpI_String, pszSymbol, &iIndex))
			{
			// insert AFTER the element we found
			iIndex++;
			}
		}
	else
		{
#ifdef DEBUG
		// assert symbols are in alphabetical order
		if (m_rgstSymbols.FSearch((CompareFn)Cmp_String, pszSymbol, &iIndex))
			iIndex++;
		Assert(iIndex == m_rgstSymbols.GetSize());
#endif
		iIndex = m_rgstSymbols.GetSize();
		}

	if (!iIndex || m_rgstSymbols[iIndex - 1].Compare(pszSymbol) != 0)
		{
#if 0
		Assert2(!iIndex || m_rgstSymbols[iIndex - 1].Compare(pszSymbol) < 0,
				"symbol [%s] should be greater than [%s]!",
				pszSymbol, m_rgstSymbols[iIndex - 1].GetSafeSz());
#endif

		CORg(m_rgstSymbols.HrInsert(iIndex, &pst));
		hr = pst->HrDup(pszSymbol);
		if (FHrFailed(hr))
			{
			m_rgstSymbols.HrRemove(iIndex);
			goto Error;
			}
		}
	else
		{
		pst = m_rgstSymbols[iIndex - 1].PString();
		Assert(iIndex != ulong(-1));
		}

	*ppst = pst;

Error:
	return hr;
}



///////////////////////////////////////////////////////////////////////////
// TagInfo class

HRESULT TagInfo::HrInit(LPCSTR pszSymbol, LPCSTR pszFile, ULONG ulLine,
						LPCSTR pszSearchLine, char type, BOOL fAnchorToEnd)
{
	CONTEXT_("TagInfo::HrInit");
	HRESULT	hr;
	long	cchFile;
	long	cchSearchLine;

	Assert(pszSymbol);
	Assert(pszFile);
	Assert(pszSearchLine);

	m_type = type;
	m_fAnchorToEnd = fAnchorToEnd;
	m_ulLine = ulLine;
	m_pszSymbol = pszSymbol;

	cchFile = lstrlen(pszFile) + 1;
	cchSearchLine = lstrlen(pszSearchLine) + 1;
	m_psz = (LPSTR)MemAlloc(cchFile + cchSearchLine);
	CPRg(m_psz);

	m_pszFile = m_psz;
	lstrcpy(m_psz, pszFile);

	m_pszSearchLine = m_psz + cchFile;
	lstrcpy(m_psz + cchFile, pszSearchLine);

Error:
	return hr;
}



///////////////////////////////////////////////////////////////////////////
// Thread Info

static long FindThread(LPCSTR pszTagFile)
{
	CONTEXT_("FindThread");
	long iRet = -1;
	ulong i;

	Assert(s_csTagThreads.FEntered());

	// remove zombies
	for (i = s_rgThreads.GetSize(); i--;)
		if (!s_rgThreads[i]->hThread)
			{
			delete *(s_rgThreads.PElm(i));
			s_rgThreads.HrRemove(i);
			}

	// look for match
	if (pszTagFile)
		{
		Trace("FindThread(%s)", pszTagFile);
		for (i = s_rgThreads.GetSize(); i--;)
			{
			Trace("  comparing to (%s)", s_rgThreads[i]->stTagFile);
			if (s_rgThreads[i]->stTagFile.CompareI(pszTagFile) == 0)
				{
#ifdef DEBUG
				// in debug, we verify there is only one thread that matches
				Assert1(iRet == -1, "more than one thread is loading %s!", pszTagFile);
#endif

				iRet = i;

#ifndef DEBUG
				// in retail, we bail as soon as we find a match
				break;
#endif
				}
			}
		}

	Trace("  returns %d", iRet);
	return iRet;
}



///////////////////////////////////////////////////////////////////////////
// Buffered File Input

static HANDLE s_hfile;
static LPSTR s_psz;
static LPSTR s_pszCur;
static ULONG s_cchRead;
static ULONG s_cchScanned;
static ULONG s_cchOffset;
static BOOL s_fEof;


void InitBuffering(HANDLE hfile, LPSTR pszBuffer)
{
	s_hfile = hfile;
	s_psz = pszBuffer;
	s_pszCur = pszBuffer;
	s_cchRead = 0;
	s_cchScanned = 0;
	s_cchOffset = 0;
	s_fEof = fFalse;
}


BOOL GetNextChunk()
{
	CONTEXT_("GetNextChunk");
	BOOL f;
	DWORD cbRead;

	Assert(!s_fEof);
	f = ReadFile(s_hfile,
				 s_psz + s_cchOffset * sizeof(char),
				 (cchBufferSize - s_cchOffset) * sizeof(char),
				 &cbRead, NULL);
	if (f)
		{
		Trace("(id %08.8x) - read %d bytes, total of %d bytes to scan",
			  GetCurrentThreadId(), cbRead, cbRead + s_cchOffset * sizeof(char));
		s_fEof = (cbRead == 0);
		s_cchScanned = 0;
		s_cchRead = cbRead / sizeof(char) + s_cchOffset;
		s_pszCur = s_psz;
		s_cchOffset = 0;
		}
	return f;
}


LPSTR GetNextLine()
{
	CONTEXT_("GetNextLine");
	LPSTR psz = 0;
	LPSTR pszBeg = 0;
	LPSTR pszRet = 0;
	BOOL fSkipLine = fFalse;

	if (s_fEof)
		goto Error;

EnsureChunk:
	// ensure chunk has been read
	if (s_cchScanned == s_cchRead)
		{
		if (!GetNextChunk() || s_fEof)
			goto Error;
		}

SkipLine:
	fSkipLine = fFalse;
	// find beginning of line
	psz = s_pszCur;
	while (*psz == '\r' || *psz == '\n')
		{
		psz++;
		s_cchScanned++;
		if (s_cchScanned == s_cchRead)
			{
			if (!GetNextChunk() || s_fEof)
				goto Error;
			psz = s_pszCur;
			}
		}
	pszBeg = psz;

	// find end of line
	while (*psz != '\r' && *psz != '\n')
		{
		psz++;
		s_cchScanned++;
		if (s_cchScanned == s_cchRead)
			{
			if (s_psz == s_pszCur)
				{
				if (!GetNextChunk())
					goto Error;
				psz = s_pszCur;
				fSkipLine = fTrue;
				break;
				}

			if (s_fEof)
				break;

			s_cchOffset = (s_psz + cchBufferSize - pszBeg);
			Trace("(id %08.8x) - OFFSET:  %d", GetCurrentThreadId(), s_cchOffset);
			memmove(s_psz, pszBeg, s_cchOffset * sizeof(char));
			goto EnsureChunk;
			}
		}
	s_pszCur = psz + 1;
	s_cchScanned++;
	*psz = 0;
	if (fSkipLine)
		goto SkipLine;

	pszRet = pszBeg;

Error:
	return pszRet;
}



///////////////////////////////////////////////////////////////////////////
// Thread

ULONG __stdcall Thread_LoadTags(void *pParam)
{
	CONTEXT_("Thread_LoadTags");
	HRESULT				hr = E_FAIL;
	long				lRet = loadError;
	String				stTagFile;
	TagThreadInfo		*pthreadinfo = reinterpret_cast<TagThreadInfo*>(pParam);
	TagFile				*ptf = 0;
	Rg<TagInfo>			*prgti;
	TagInfo				*ptiNew;
	ULONG				cchLongest = 0;
	HANDLE				hfile = INVALID_HANDLE_VALUE;
	LPSTR				pszBuffer = 0;
	LPSTR				psz;

	String				*pstSymbol;
	LPCSTR				pszSymbol;
	LPCSTR				pszFile;
	ULONG				nLine;
	LPCSTR				pszSearchLine;
	char				type;
	LPCSTR				pszInfo;
	int					iOffset;
	BOOL				fAnchorToEnd;
	BOOL				fBadFormat = fTrue;
	BOOL				fUnsorted = fTrue;

	Trace("(id %08.8x) - Thread_LoadTags starting", GetCurrentThreadId());
	Assert(pParam);

	pthreadinfo->fAbort = fFalse;
	CORg(stTagFile.HrDup(pthreadinfo->stTagFile));

	// open file
	hfile = CreateFile(pthreadinfo->stTagFile, GENERIC_READ, FILE_SHARE_READ,
					   NULL, OPEN_EXISTING, FILE_FLAG_SEQUENTIAL_SCAN, NULL);
	if (hfile == INVALID_HANDLE_VALUE)
		goto Error;

	ptf = New TagFile;
	CPRg(ptf);
	prgti = &(ptf->m_rgti);

	pszBuffer = (LPSTR)MemAlloc(cchBufferSize * sizeof(char));
	CPRg(pszBuffer);

	// read file
	InitBuffering(hfile, pszBuffer);
	while (!pthreadinfo->fAbort && (psz = GetNextLine()))
		{
		TagTrace("(id %08.8x) - parse:  \"%s\"", GetCurrentThreadId(), psz);

		nLine = 0;
		pszSearchLine = 0;
		fAnchorToEnd = fFalse;

		// parse symbol name
		pszSymbol = psz;
		if (!*pszSymbol)
			// ignore blank lines
			continue;
		if (*pszSymbol == '!')
			{
			// handle comment lines
			if (cmp(pszSymbol, "!_TAG_FILE_FORMAT	2	/extended format; --format=1 will not append ;\" to lines/") == 0)
				fBadFormat = fFalse;
			if (cmp(pszSymbol, "!_TAG_FILE_SORTED	1	/0=unsorted, 1=sorted/") == 0)
				fUnsorted = fFalse;
			continue;
			}
		psz = StrChr(psz, '\t');
		Assert(psz);
		if (!psz)
			continue;
		*psz = 0;
		psz++;
		if (!*psz)
			continue;

		// CTags has a bug where it can generate 0-length symbol names which
		// it sorts before the comment lines; in order to be robust, the
		// simplest thing to do is just ignore them.
		if (!*pszSymbol)
			continue;

		// if unknown format or unsorted, abort
		if (fBadFormat)
			{
			lRet = loadBadFormat;
			break;
			}
		if (fUnsorted)
			{
			lRet = loadUnsorted;
			break;
			}

		// parse file name
		pszFile = psz;
		psz = StrChr(psz, '\t');
		Assert(psz);
		if (!psz)
			continue;
		*psz = 0;
		psz++;
		if (!*psz)
			continue;

		if (*psz == '/')
			{
			// parse search line
			Assert(*psz == '/');
			++psz;
			Assert(*psz == '^');
			++psz;
			pszSearchLine = psz;
			for (iOffset = 0; *psz; ++psz)
				{
				if (*psz == '\\')
					{
					// get rid of the escape characters
					iOffset++;
					++psz;
					}
				else if (*psz == '/')
					{
					if (*(psz-1) == '$')
						{
						iOffset++;
						fAnchorToEnd = fTrue;
						}

					Assert(*(psz+1) == ';');
					Assert(*(psz+2) == '"');
					Assert(*(psz+3) == '\t');

					*(psz - iOffset) = 0;
					psz = StrChr(psz+1, '\t');
					Assert(psz);
					break;
					}
				if (iOffset)
					*(psz - iOffset) = *psz;
				}
			}
		else if (*psz >= '0' && *psz <= '9')
			{
			// parse line numbers for things like #defines
			while (*psz >= '0' && *psz <= '9')
				{
				nLine *= 10;
				nLine += *psz - '0';
				++psz;
				}

			Assert(*(psz+0) == ';');
			Assert(*(psz+1) == '"');
			Assert(*(psz+2) == '\t');
			psz = StrChr(psz, '\t');
			Assert(psz);
			}
		if (!psz)
			continue;
		if (*psz)
			psz++;

		// parse symbol type
		Assert2(*psz == 'c' ||
				*psz == 'd' ||
				*psz == 'e' ||
				*psz == 'f' ||
				*psz == 'g' ||
				*psz == 'm' ||
				*psz == 'p' ||
				*psz == 's' ||
				*psz == 't' ||
				*psz == 'u' ||
				*psz == 'v' ||
				!*psz, "unrecognized type '%c' (0x%02.2x)",
				(char)*psz, (char)*psz);
		type = *psz;
		psz = StrChr(psz, '\t');
		if (psz)
			{
			// parse info
			psz++;
			if (*psz)
				// assume the rest of the line is info
				pszInfo = psz;
			}

		// append to tag info
		if (Get_Int(iFIgnoreCase))
			{
			ULONG iIndex;
			if (prgti->FSearch((CompareFn)CmpI_Exact, pszSymbol, &iIndex))
				{
				// insert AFTER the element we found
				iIndex++;
				}
			CORg(prgti->HrInsert(iIndex, &ptiNew));
			}
		else
			CORg(prgti->HrAppend(&ptiNew));
		CORg(ptf->HrAddSymbol(pszSymbol, &pstSymbol));
		CORg(ptiNew->HrInit(*pstSymbol, pszFile, nLine, pszSearchLine, type, fAnchorToEnd));

#if 0
		s_cLoaded++;
#endif
		TagTrace("(id %08.8x) - tag:  (%c)  \"%s\"", GetCurrentThreadId(), type, pszSymbol);

		// calculate longest symbol name
		cchLongest = max(cchLongest, pstSymbol->Length());
		}

	Trace("(id %08.8x) - finished scanning file, %d tags loaded",
		  GetCurrentThreadId(), prgti->GetSize());

#ifdef DEBUG
	{
	for (ULONG ii = 0; ii < ptf->m_rgstSymbols.GetSize(); ii++)
		Trace("%s", ptf->m_rgstSymbols[ii].GetSafeSz());
	}
#endif

	{
	ScopedCritSec cs(s_csTags);

	if (!pthreadinfo->fAbort)
		{
		ptf->m_cchLongest = cchLongest;
		ptf->m_pNext = s_ptfHead;
		ptf->m_stTagFile.Attach(stTagFile.Transfer());
		s_ptfHead = ptf;
		ptf = 0;
		pParam = 0;

		//$ todo: (chrisant) DANGER WILL ROBINSON!  this is not
		// background-friendly.
		s_ptfCurrent = s_ptfHead;
		lRet = s_ptfCurrent->m_rgti.GetSize();
		}
	else
		Trace("(id %08.8x) - ABORTED", GetCurrentThreadId());
	}

Error:
	if (hfile != INVALID_HANDLE_VALUE)
		CloseHandle(hfile);
	delete ptf;
	delete pszBuffer;

	pthreadinfo->lRet = lRet;
	pthreadinfo->fCompleted = fTrue;

#if 0
	if (FHrSucceeded(hr))
		// signal client needs to reload
		s_fReload = fTrue;
#endif

	Trace("(id %08.8x) - Thread_LoadTags ENDED", GetCurrentThreadId());
	return 0;
}



///////////////////////////////////////////////////////////////////////////
// Tags Control Methods

cexport
LPSTRING Tags_CurrentTagFile()
{
	Assert(s_ptfCurrent);
	return s_ptfCurrent->m_stTagFile.TSE();
}


cexport
ULONG Tags_CchLongest()
{
	Assert(s_ptfCurrent);
#if 0
	if (!s_ptfCurrent)
		return 0;
#endif
	return s_ptfCurrent->m_cchLongest;
}


cexport
BOOL Tags_FLoaded()
{
	return !!s_ptfCurrent;
}


cexport
LPSTRING Tags_GetSymbol(ULONG iIndex)
{
	Assert(s_ptfCurrent);
	Assert(0 <= iIndex && iIndex < s_ptfCurrent->m_rgti.GetSize());
	return TSE(s_ptfCurrent->m_rgti[iIndex].SzSymbol(), -1);
}


cexport
LPSTRING Tags_GetFilename(ULONG iIndex)
{
	Assert(s_ptfCurrent);
	Assert(0 <= iIndex && iIndex < s_ptfCurrent->m_rgti.GetSize());
	return TSE(s_ptfCurrent->m_rgti[iIndex].SzFile(), -1);
}


cexport
LPSTRING Tags_GetSearchLine(ULONG iIndex)
{
	Assert(s_ptfCurrent);
	Assert(0 <= iIndex && iIndex < s_ptfCurrent->m_rgti.GetSize());
	return TSE(s_ptfCurrent->m_rgti[iIndex].SzSearchLine(), -1);
}


cexport
ULONG Tags_GetLine(ULONG iIndex)
{
	Assert(s_ptfCurrent);
	Assert(0 <= iIndex && iIndex < s_ptfCurrent->m_rgti.GetSize());
	return s_ptfCurrent->m_rgti[iIndex].Line();
}


cexport
ULONG Tags_GetType(ULONG iIndex)
{
	Assert(s_ptfCurrent);
	Assert(0 <= iIndex && iIndex < s_ptfCurrent->m_rgti.GetSize());
	return s_ptfCurrent->m_rgti[iIndex].Type();
}


cexport
BOOL Tags_FAnchorToEnd(ULONG iIndex)
{
	Assert(s_ptfCurrent);
	Assert(0 <= iIndex && iIndex < s_ptfCurrent->m_rgti.GetSize());
	return s_ptfCurrent->m_rgti[iIndex].FAnchorToEnd();
}


#if 0
cexport
LPSTRING Tags_GetInfo(ULONG iIndex)
{
	Assert(s_ptfCurrent);
	Assert(0 <= iIndex && iIndex < s_ptfCurrent->m_rgti.GetSize());
	return s_ptfCurrent->m_rgti[iIndex].m_stInfo.TSE();
}
#endif


cexport
ULONG Tags_Lookup(LPCSTR pszTag, ULONG iStart, ULONG ulFlags)
{
	CONTEXT_("Tags_Lookup");
	CompareFn2 pfn;
	Rg<TagInfo> *prgti;

	ulFlags &= ~lookExact;

	Assert1(lookFirst == ulFlags ||
			lookNext == ulFlags ||
			lookPrev == ulFlags ||
			lookLast == ulFlags,
			"what kind of silly flag is %d??", ulFlags);

	if (ulFlags & lookExact)
		pfn = Get_Int(iFIgnoreCase) ? CmpI_Exact : Cmp_Exact;
	else
		pfn = Cmp_Lookup;

	if (s_ptfCurrent)
		{
		ScopedCritSec cs(s_csTags);

		prgti = &(s_ptfCurrent->m_rgti);

		// binary search
		if (0 <= iStart && iStart < prgti->GetSize())
			{
			if (lookFirst == ulFlags || lookLast == ulFlags)
				{
				// find a match
				if (!prgti->FSearch((CompareFn)pfn, pszTag, &iStart))
					iStart = -1;

				// linear search to find first/last match
				if (iStart != ULONG(-1))
					{
					if (lookLast == ulFlags)
						{
						while (iStart + 1 < prgti->GetSize() &&
							   (pfn)(pszTag,
							   prgti->PElm(iStart + 1)) == 0)
							iStart++;
						}
					else
						{
						while (iStart > 0 && (pfn)(pszTag,
								prgti->PElm(iStart - 1)) == 0)
							iStart--;
						}
					}
				}
			else if ((pfn)(pszTag, prgti->PElm(iStart)))
				iStart = ULONG(-1);
			}
		else
			// out of bounds, return not found
			iStart = ULONG(-1);
		}
	else
		iStart = ULONG(-1);

	return iStart;
}


#if 0
cexport
BOOL Tags_FReload()
{
	BOOL fReload = s_fReload;

	s_fReload = fFalse;
	return fReload;
}


cexport
BOOL Tags_CTags()
{
	return s_cLoaded;
}
#endif


cexport
void Tags_Abort(BOOL fWait, LPCSTR psz)
{
	CONTEXT_("Tags_Abort");
	ScopedCritSec cs(s_csTagThreads);
	ulong i;
	TagThreadInfo *pthreadinfo;

	if (!psz)
		{
		for (i = s_rgThreads.GetSize(); i--;)
			Tags_Abort(fWait, s_rgThreads[i]->stTagFile);
		FindThread(0);
		s_rgThreads.Free();
		return;
		}

	// abort threaded load
	i = FindThread(psz);
	if (i != ulong(-1))
		{
		pthreadinfo = s_rgThreads[i];
		pthreadinfo->fAbort = fTrue;

		if (fWait)
			{
			WaitForSingleObject(pthreadinfo->hThread, INFINITE);
			CloseHandle(pthreadinfo->hThread);
			pthreadinfo->hThread = 0;
			}
		}
}


cexport
void Tags_FreeCurrent()
{
	CONTEXT_("Tags_FreeCurrent");

	if (s_ptfCurrent)
		{
		ScopedCritSec cs(s_csTags);

		// ensure thread has terminated
		Tags_Abort(fTrue, s_ptfCurrent->m_stTagFile);

		// free tags info
		delete s_ptfCurrent;
		s_ptfCurrent = 0;
		}
}


cexport
void Tags_FreeFile(LPCSTR psz)
{
	CONTEXT_("Tags_FreeFile");

	// ensure thread has terminated
	Tags_Abort(fTrue, psz);

	// free tags info for specified file
	delete FindTagFile(psz);
}


cexport
void Tags_FreeAll()
{
	CONTEXT_("Tags_FreeAll");
	ScopedCritSec cs(s_csTags);

	// ensure thread has terminated
	Tags_Abort(fTrue, 0);

	// free all tags info
	while (s_ptfHead)
		delete s_ptfHead;
}


static TagFile *s_ptfReturn;

cexport
LPSTRING Tags_GetNextTagFile()
{
	CONTEXT_("Tags_GetNextTagFile");
	String st;

	if (s_ptfReturn)
		{
		if (FHrFailed(st.HrDup(s_ptfReturn->m_stTagFile)))
			{
			// this will force a Leave() below, and behaves as though we hit
			// the last tag file.
			s_ptfReturn = 0;
			}
		else
			s_ptfReturn = s_ptfReturn->m_pNext;
		}

	if (!s_ptfReturn)
		s_csTags.Leave();

	return st.TSE();
}
cexport
LPSTRING Tags_GetFirstTagFile()
{
	CONTEXT_("Tags_GetFirstTagFile");
	s_csTags.Enter();

	s_ptfReturn = s_ptfHead;
	return Tags_GetNextTagFile();
}


/*!-------------------------------------------------------------------------
	::Tags_Load
		Returns:
			loadError		= error occurred
			loadBadFormat	= bad tag file format
			loadUnsorted	= correct tag file format, but is unsorted
			loadNotFound	= tag file not found
			n >= 0			= fEnsure was FALSE, or zero tags loaded

	Author: chrisant
  --------------------------------------------------------------------------*/
cexport
long Tags_Load(LPCSTR pszTagFile, BOOL fEnsure)
{
	CONTEXT_("Tags_Load");
	DWORD dwId;
	TagThreadInfo **ppthreadinfo = 0;
	TagThreadInfo *pthreadinfo = 0;
	long lRet = loadError;
	long ii;
	TagFile *ptf;

	// is the file already loaded?
	{
	ScopedCritSec cs(s_csTags);

	lRet = loadNotFound;
	ptf = FindTagFile(pszTagFile);
	if (ptf)
		{
		s_ptfCurrent = ptf;
		lRet = s_ptfCurrent->m_rgti.GetSize();
		Trace("[%s] already loaded", pszTagFile);
		{
		ScopedCritSec cs(s_csTagThreads);
		FindThread(0);					// cleanup zombies
		}
		goto Error;
		}
	}
	Trace("[%s] not loaded yet", pszTagFile);

	// does file exist?
	if (GetFileAttributes(pszTagFile) == DWORD(-1))
		{
		lRet = loadNotFound;
		goto Error;
		}

	// create a new thread if necessary
	s_csTagThreads.Enter();
	ii = FindThread(pszTagFile);
	if (ii != -1)
		pthreadinfo = *(s_rgThreads.PElm(ii));
	s_csTagThreads.Leave();
	if (ii == -1)
		{
		pthreadinfo = New TagThreadInfo;
		if (!pthreadinfo)
			goto Error;
		memset(pthreadinfo, 0, sizeof(*pthreadinfo));
		pthreadinfo->lRet = loadError;
		if (FHrFailed(pthreadinfo->stTagFile.HrDup(pszTagFile)))
			goto Error;
		Assert(!pthreadinfo->hThread);

		{
		ScopedCritSec cs(s_csTagThreads);
		if (FHrFailed(s_rgThreads.HrAppend(&ppthreadinfo)))
			goto Error;
		if (ppthreadinfo)
			*ppthreadinfo = pthreadinfo;
		}

		// kick off thread
		pthreadinfo->hThread = CreateThread(0,					// security
											cbThreadMinStack,	// stack size
											Thread_LoadTags,	// start routine
											(void*)pthreadinfo,	// parameter
											0,					// creation flags
											&dwId				// thread id
											);
		}

	if (pthreadinfo->hThread != 0)
		{
		DWORD dw = fEnsure ? INFINITE : 0;

		dw = WaitForSingleObject(pthreadinfo->hThread, dw);
		if (dw == WAIT_OBJECT_0)
			{
			CloseHandle(pthreadinfo->hThread);
			lRet = pthreadinfo->lRet;
			pthreadinfo->hThread = 0;	// make it a zombie
			}
		else
			lRet = loadInProgress;
		}
	else
		lRet = pthreadinfo->lRet;

Error:
	// (chrisant) note, FindThread does the lazy deletion of zombie
	// pthreadinfos (where hThread == 0).
	return lRet;
}



