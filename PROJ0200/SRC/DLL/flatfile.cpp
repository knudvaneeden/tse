// Threaded Flat File Namespace

#ifndef _PROJDLL_H
#include "projdll.h"
#endif

#ifndef _FLATFILE_H
#include "flatfile.h"
#endif


#undef THIS_FILE
#define THIS_FILE __FILE__



///////////////////////////////////////////////////////////////////////////
// Types

#define		diSubDirs		0x00000001


struct DirInfo
	{
	String			m_stPath;
	ULONG			m_ulFlags;
	};
DEFINE_GENARRAY_CLASS(DirInfo)


struct FileInfo
	{
	String			m_stFile;
	String			m_stPath;		//$ todo: (chrisant) inefficient to store same path multiple times, maybe index into a list of paths?
	};
DEFINE_GENARRAY_CLASS(FileInfo)


struct FlatFileTraversal
	{
	Rg<DirInfo>		m_rgdiInclude;
	Rg<DirInfo>		m_rgdiExclude;
	Rg<String>		m_rgstWild;
	};


struct InsertInfo
	{
	LPCSTR			pszFile;
	LPCSTR			pszPath;
	};



///////////////////////////////////////////////////////////////////////////
// Globals

#ifdef DEBUG
static BOOL					s_fInitialized = fFalse;
#endif

static BOOL					s_fAbort;
static BOOL					s_fReload = fFalse;

static FlatFileTraversal	*s_pfft = 0;
static Rg<FileInfo>			*s_prgfiFiles = 0;
static ULONG				s_cchLongest = 0;
static ULONG				s_cFound = 0;

static HANDLE				s_hThread = 0;

CritSec						g_csFlatFile IfDebug((c_szCSFlatFileList));



///////////////////////////////////////////////////////////////////////////
// FlatFile Thread

static int cmpsorti(LPCSTR psz1, int cch1, LPCSTR psz2, int cch2)
{
	CONTEXT_("cmpsorti");

	static const unsigned char c_rgCharsInOrder[256] =
	{
		0x00,	//	^@	//
		0x01,	//	^A	//
		0x02,	//	^B	//
		0x03,	//	^C	//
		0x04,	//	^D	//
		0x05,	//	^E	//
		0x06,	//	^F	//
		0x07,	//	^G	//
		0x08,	//	^H	//
		0x09,	//	^I	//
		0x0a,	//	^J	//
		0x0b,	//	^K	//
		0x0c,	//	^L	//
		0x0d,	//	^M	//
		0x0e,	//	^N	//
		0x0f,	//	^O	//
		0x10,	//	^P	//
		0x11,	//	^Q	//
		0x12,	//	^R	//
		0x13,	//	^S	//
		0x14,	//	^T	//
		0x15,	//	^U	//
		0x16,	//	^V	//
		0x17,	//	^W	//
		0x18,	//	^X	//
		0x19,	//	^Y	//
		0x1a,	//	^Z	//
		0x1b,	//	^[	//
		0x1c,	//	^\	//
		0x1d,	//	^]	//
		0x1e,	//	^^	//
		0x1f,	//	^_	//
		0x20,	//	SPC	//
		0x2e,	//	.	//
		0x2c,	//	,	//
		0x21,	//	!	//
		0x22,	//	"	//
		0x23,	//	#	//
		0x24,	//	$	//
		0x25,	//	%	//
		0x26,	//	&	//
		0x27,	//	'	//
		0x28,	//	(	//
		0x29,	//	)	//
		0x2a,	//	*	//
		0x2b,	//	+	//
		0x2f,	//	/	//
		0x3a,	//	:	//
		0x3b,	//	;	//
		0x3c,	//	<	//
		0x3d,	//	=	//
		0x3e,	//	>	//
		0x3f,	//	?	//
		0x5b,	//	[	//
		0x5c,	//	\	//
		0x5d,	//	]	//
		0x5e,	//	^	//
		0x60,	//	`	//
		0x40,	//	@	//
		0x7b,	//	{	//
		0x7c,	//	|	//
		0x7d,	//	}	//
		0x5f,	//	_	//
		0x7e,	//	~	//
		0x41,	//	A	//
		0x61,	//	a	//
		0x42,	//	B	//
		0x62,	//	b	//
		0x43,	//	C	//
		0x63,	//	c	//
		0x44,	//	D	//
		0x64,	//	d	//
		0x45,	//	E	//
		0x65,	//	e	//
		0x46,	//	F	//
		0x66,	//	f	//
		0x47,	//	G	//
		0x67,	//	g	//
		0x48,	//	H	//
		0x68,	//	h	//
		0x49,	//	I	//
		0x69,	//	i	//
		0x4a,	//	J	//
		0x6a,	//	j	//
		0x4b,	//	K	//
		0x6b,	//	k	//
		0x4c,	//	L	//
		0x6c,	//	l	//
		0x4d,	//	M	//
		0x6d,	//	m	//
		0x4e,	//	N	//
		0x6e,	//	n	//
		0x4f,	//	O	//
		0x6f,	//	o	//
		0x50,	//	P	//
		0x70,	//	p	//
		0x51,	//	Q	//
		0x71,	//	q	//
		0x52,	//	R	//
		0x72,	//	r	//
		0x53,	//	S	//
		0x73,	//	s	//
		0x54,	//	T	//
		0x74,	//	t	//
		0x55,	//	U	//
		0x75,	//	u	//
		0x56,	//	V	//
		0x76,	//	v	//
		0x57,	//	W	//
		0x77,	//	w	//
		0x58,	//	X	//
		0x78,	//	x	//
		0x59,	//	Y	//
		0x79,	//	y	//
		0x5a,	//	Z	//
		0x7a,	//	z	//
		0x30,	//	0	//
		0x31,	//	1	//
		0x32,	//	2	//
		0x33,	//	3	//
		0x34,	//	4	//
		0x35,	//	5	//
		0x36,	//	6	//
		0x37,	//	7	//
		0x38,	//	8	//
		0x39,	//	9	//
		0x2d,	//	-	//
		0x7f,	//		//
		0x80,	//	Ä	//
		0x81,	//	Å	//
		0x82,	//	Ç	//
		0x83,	//	É	//
		0x84,	//	Ñ	//
		0x85,	//	Ö	//
		0x86,	//	Ü	//
		0x87,	//	á	//
		0x88,	//	à	//
		0x89,	//	â	//
		0x8a,	//	ä	//
		0x8b,	//	ã	//
		0x8c,	//	å	//
		0x8d,	//	ç	//
		0x8e,	//	é	//
		0x8f,	//	è	//
		0x90,	//	ê	//
		0x91,	//	ë	//
		0x92,	//	í	//
		0x93,	//	ì	//
		0x94,	//	î	//
		0x95,	//	ï	//
		0x96,	//	ñ	//
		0x97,	//	ó	//
		0x98,	//	ò	//
		0x99,	//	ô	//
		0x9a,	//	ö	//
		0x9b,	//	õ	//
		0x9c,	//	ú	//
		0x9d,	//	ù	//
		0x9e,	//	û	//
		0x9f,	//	ü	//
		0xa0,	//	†	//
		0xa1,	//	°	//
		0xa2,	//	¢	//
		0xa3,	//	£	//
		0xa4,	//	§	//
		0xa5,	//	•	//
		0xa6,	//	¶	//
		0xa7,	//	ß	//
		0xa8,	//	®	//
		0xa9,	//	©	//
		0xaa,	//	™	//
		0xab,	//	´	//
		0xac,	//	¨	//
		0xad,	//	≠	//
		0xae,	//	Æ	//
		0xaf,	//	Ø	//
		0xb0,	//	∞	//
		0xb1,	//	±	//
		0xb2,	//	≤	//
		0xb3,	//	≥	//
		0xb4,	//	¥	//
		0xb5,	//	µ	//
		0xb6,	//	∂	//
		0xb7,	//	∑	//
		0xb8,	//	∏	//
		0xb9,	//	π	//
		0xba,	//	∫	//
		0xbb,	//	ª	//
		0xbc,	//	º	//
		0xbd,	//	Ω	//
		0xbe,	//	æ	//
		0xbf,	//	ø	//
		0xc0,	//	¿	//
		0xc1,	//	¡	//
		0xc2,	//	¬	//
		0xc3,	//	√	//
		0xc4,	//	ƒ	//
		0xc5,	//	≈	//
		0xc6,	//	∆	//
		0xc7,	//	«	//
		0xc8,	//	»	//
		0xc9,	//	…	//
		0xca,	//	 	//
		0xcb,	//	À	//
		0xcc,	//	Ã	//
		0xcd,	//	Õ	//
		0xce,	//	Œ	//
		0xcf,	//	œ	//
		0xd0,	//	–	//
		0xd1,	//	—	//
		0xd2,	//	“	//
		0xd3,	//	”	//
		0xd4,	//	‘	//
		0xd5,	//	’	//
		0xd6,	//	÷	//
		0xd7,	//	◊	//
		0xd8,	//	ÿ	//
		0xd9,	//	Ÿ	//
		0xda,	//	⁄	//
		0xdb,	//	€	//
		0xdc,	//	‹	//
		0xdd,	//	›	//
		0xde,	//	ﬁ	//
		0xdf,	//	ﬂ	//
		0xe0,	//	‡	//
		0xe1,	//	·	//
		0xe2,	//	‚	//
		0xe3,	//	„	//
		0xe4,	//	‰	//
		0xe5,	//	Â	//
		0xe6,	//	Ê	//
		0xe7,	//	Á	//
		0xe8,	//	Ë	//
		0xe9,	//	È	//
		0xea,	//	Í	//
		0xeb,	//	Î	//
		0xec,	//	Ï	//
		0xed,	//	Ì	//
		0xee,	//	Ó	//
		0xef,	//	Ô	//
		0xf0,	//		//
		0xf1,	//	Ò	//
		0xf2,	//	Ú	//
		0xf3,	//	Û	//
		0xf4,	//	Ù	//
		0xf5,	//	ı	//
		0xf6,	//	ˆ	//
		0xf7,	//	˜	//
		0xf8,	//	¯	//
		0xf9,	//	˘	//
		0xfa,	//	˙	//
		0xfb,	//	˚	//
		0xfc,	//	¸	//
		0xfd,	//	˝	//
		0xfe,	//	˛	//
		0xff,	//	ˇ	//
	};

	static BOOL s_fOrder = fFalse;
	static unsigned char s_rgOrder[sizeof(c_rgCharsInOrder)];
	CASSERT(sizeof(s_rgOrder) == 256);

	if (!s_fOrder)
		{
		Assert(c_rgCharsInOrder[0xff] == 0xff);
		Assert(c_rgCharsInOrder[0xfe] == 0xfe);
		for (unsigned ii = 0; ii < sizeof(c_rgCharsInOrder); ii++)
			{
			if (ii)
				{
				Assert2(s_rgOrder[c_rgCharsInOrder[ii]] != ii,
						"BUG: duplicate char %u at index %u.",
						c_rgCharsInOrder[ii], ii);
				}
			s_rgOrder[c_rgCharsInOrder[ii]] = ii;
			}
		s_fOrder = fTrue;
		}

	char n = 0;
	int cch;

	if (cch1 < 0)
		cch1 = lstrlen(psz1) + 1;
	if (cch2 < 0)
		cch2 = lstrlen(psz2) + 1;

	cch = min(cch1, cch2);

	Trace("[%s]/%d vs [%s]/%d == ", psz1, cch1, psz2, cch2);

	if (cch)
		{
		do
			{
			char ch1 = s_rgOrder[(unsigned)ChCaseless(*psz1)];
			char ch2 = s_rgOrder[(unsigned)ChCaseless(*psz2)];
			n = ch1 - ch2;
			if (!*psz1)
				break;
			psz1++;
			psz2++;
			}
		while (!n && --cch);
		}

	Trace("%d\n", (int)(signed char)n);

	return (int)(signed char)n;
}


static int Cmp_NoCase(LPCSTR psz1, LPCSTR psz2)
{
	return cmpsorti(psz1, -1, psz2, -1);
}


LPCSTR FindExt(LPCSTR psz)
{
	// find the last dot in a string
	for (LPCSTR pszDot = 0; *psz; psz++)
		if ('.' == *psz)
			pszDot = psz;
	return pszDot ? pszDot : psz;	// return dot or end of string (not null!)
}


BOOL FMatchSegment(LPCSTR pszWild, LPCSTR pszWildEnd, LPCSTR pszFile, LPCSTR pszFileEnd)
{
	while (pszWild < pszWildEnd)
		{
		Assert(*pszFile != '*' && *pszFile != '?' && *pszFile != '\\' && *pszFile != '/');

		if (ChCaseless(*pszWild) == ChCaseless(*pszFile))
			{
			pszWild++;
			pszFile++;
			}
		else if ('*' == *pszWild)
			return fTrue;
		else if ('?' == *pszWild)
			{
			pszWild++;
			if (pszFile < pszFileEnd)
				// don't go past end
				pszFile++;
			}
		else
			return fFalse;
		}
	return (pszWild == pszWildEnd && pszFile == pszFileEnd);
}


BOOL FMatchWildcard(LPCSTR pszWild, LPCSTR pszFile)
{
	CONTEXT_("FMatchWildcard");
	LPCSTR pszWildEnd;
	LPCSTR pszFileEnd;
	BOOL fMatch = fFalse;

	Assert(pszWild);
	Assert(pszFile);

	pszWildEnd = FindExt(pszWild);
	pszFileEnd = FindExt(pszFile);
	if (FMatchSegment(pszWild, pszWildEnd, pszFile, pszFileEnd))
		{
		if ('.' == *pszWildEnd)
			++pszWildEnd;
		if ('.' == *pszFileEnd)
			++pszFileEnd;
		pszWild = pszWildEnd;
		pszFile = pszFileEnd;
		pszWildEnd = FindExt(*pszWild ? pszWild + 1 : pszWild);
		pszFileEnd = FindExt(*pszFile ? pszFile + 1 : pszFile);
		fMatch = FMatchSegment(pszWild, pszWildEnd, pszFile, pszFileEnd);
		}
	return fMatch;
}


static BOOL FExclude(Rg<DirInfo> *prgdi, LPCSTR psz)
{
	CONTEXT_("FExclude");
	Assert(lstrlen(psz));
	Assert1(psz[lstrlen(psz)-1] == '\\', "psz missing trailing backslash \"%s\"", psz);

	for (int i = prgdi->GetSize(); i--;)
		if (Cmp_NoCase(prgdi->PElm(i)->m_stPath, psz) == 0)
			return fTrue;

	return fFalse;
}


static BOOL FInclude(Rg<String> *prgst, LPCSTR psz)
{
	CONTEXT_("FInclude");
	Assert(lstrlen(psz));		// not strictly required, but strange otherwise

	for (int i = prgst->GetSize(); i--;)
		if (FMatchWildcard(*prgst->PElm(i), psz))
			return fTrue;

	return fFalse;
}


static int Cmp_Insert(InsertInfo *pii, FileInfo *pfi)
{
	CONTEXT_("Cmp_Insert");
	int n;

	n = Cmp_NoCase(pii->pszFile, pfi->m_stFile);
	if (!n)
		n = Cmp_NoCase(pii->pszPath, pfi->m_stPath);
	return n;
}


ULONG __stdcall Thread_EnumerateFiles(void *pParam)
{
	CONTEXT_("Thread_EnumerateFiles");
	HRESULT				hr;
	FlatFileTraversal	*pfft = (FlatFileTraversal*)pParam;
	Rg<FileInfo>		*prgfiFiles;
	ULONG				iPath;
	HANDLE				hFind;
	String				st;
	WIN32_FIND_DATA		fd;
	LPCSTR				pszCurPath;
	ULONG				ulFlags;
	DirInfo				*pdiNew;
	FileInfo			*pfiNew;
	ULONG				cchLongest = 0;

	Trace("(id %08.8x) - Thread_EnumerateFiles starting", GetCurrentThreadId());
	Assert(pfft);

	s_fAbort = fFalse;

	prgfiFiles = New Rg<FileInfo>;
	CPRg(prgfiFiles);

	// walk paths (path array can grow during loop, hence the less efficient loop condition)
	for (iPath = 0; !s_fAbort && iPath < pfft->m_rgdiInclude.GetSize(); ++iPath)
		{
		Trace("(id %08.8x) > iPath == %d, GetSize() == %d", GetCurrentThreadId(), iPath, pfft->m_rgdiInclude.GetSize());

		// concatenate path and wildcard
		pszCurPath = pfft->m_rgdiInclude[iPath].m_stPath.GetSafeSz();
		ulFlags = pfft->m_rgdiInclude[iPath].m_ulFlags;
		CORg(st.HrDup(pszCurPath));
		Assert(st.Length());
		Assert1(st[st.Length()-1] == '\\', "st missing trailing backslash \"%s\"", st.GetSafeSz());
		CORg(st.HrAppend("*.*"));
		Trace("(id %08.8x) - searching \"%s\"", GetCurrentThreadId(), st.GetSafeSz());

		// find files
		hFind = FindFirstFile(st, &fd);
		if (hFind != INVALID_HANDLE_VALUE)
			{
			do
				{
				// ignore hidden and system files
				if (!(fd.dwFileAttributes & (FILE_ATTRIBUTE_HIDDEN|FILE_ATTRIBUTE_SYSTEM)))
					{
					if (fd.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY)
						{
						// directory, ignore if . or ..
						if ((ulFlags & diSubDirs) &&
								lstrcmp(fd.cFileName, ".") &&
								lstrcmp(fd.cFileName, ".."))
							{
							// append to include list
							CORg(pfft->m_rgdiInclude.HrAppend(&pdiNew));
							Assert(pdiNew->m_stPath.IsEmpty());
							CORg(pdiNew->m_stPath.HrDup(pszCurPath));
							CORg(pdiNew->m_stPath.HrAppend(fd.cFileName));
							CORg(pdiNew->m_stPath.HrAppend("\\"));
							pdiNew->m_ulFlags = ulFlags;

							// exclude it?  (we check after building the path
							// string, as an optimization since the FExclude
							// function would otherwise need to build the path
							// string itself, too)
							if (FExclude(&pfft->m_rgdiExclude, pdiNew->m_stPath))
								CORg(pfft->m_rgdiInclude.HrRemove(1, pfft->m_rgdiInclude.GetSize()-1));

							Trace("(id %08.8x) -   DIRECTORY added \"%s%s\"", GetCurrentThreadId(), pszCurPath, fd.cFileName);
							}
						else
							Trace("(id %08.8x) -     skipping directory \"%s%s\"", GetCurrentThreadId(), pszCurPath, fd.cFileName);
						}
					else
						{
						// file, append to file list
						if (FInclude(&pfft->m_rgstWild, fd.cFileName))
							{
							InsertInfo ii;
							ULONG iIndex;

							ii.pszPath = pszCurPath;
							ii.pszFile = fd.cFileName;
							if (!prgfiFiles->FSearch((CompareFn)Cmp_Insert, &ii, &iIndex))
								{
								CORg(prgfiFiles->HrInsert(iIndex, &pfiNew));
								CORg(pfiNew->m_stPath.HrDup(pszCurPath));
								CORg(pfiNew->m_stFile.HrDup(fd.cFileName));
								s_cFound++;
								cchLongest = max(cchLongest,
												 ULONG(pfiNew->m_stFile.Length() +
													   pfiNew->m_stPath.Length()));
								Trace("(id %08.8x) -   FILE inserted \"%s%s\"", GetCurrentThreadId(), pszCurPath, fd.cFileName);
								}
							else
								Trace("(id %08.8x) -     duplicate file \"%s%s\"", GetCurrentThreadId(), pszCurPath, fd.cFileName);
							}
						else
							Trace("(id %08.8x) -     skipping file \"%s%s\"", GetCurrentThreadId(), pszCurPath, fd.cFileName);
						}
					}
				else
					Trace("(id %08.8x) -     skipping hidden/system file \"%s\"", GetCurrentThreadId(), fd.cFileName);
				}
			while (!s_fAbort && FindNextFile(hFind, &fd));

			FindClose(hFind);
			}
		else
			Trace("(id %08.8x) - FindFirstFile returned INVALID_HANDLE_VALUE", GetCurrentThreadId());
		}

	{
	ScopedCritSec cs(g_csFlatFile);

	if (!s_fAbort)
		{
		// let go of old list, hold on to new list
		delete s_prgfiFiles;
		s_prgfiFiles = prgfiFiles;
		prgfiFiles = 0;

		s_cchLongest = cchLongest;
		}
	else
		Trace("(id %08.8x) - ABORTED", GetCurrentThreadId());
	}

Error:
	delete prgfiFiles;
	delete pfft;

#if 0
//#ifdef DEBUG
	if (FHrSucceeded(hr) && s_prgfiFiles)
		{
		Trace("(id %08.8x) - FILES FOUND --------", GetCurrentThreadId());
		for (ULONG i = 0; i < s_prgfiFiles->GetSize(); i++)
			Trace("(id %08.8x) -   %s  (%s)", GetCurrentThreadId(),
				  s_prgfiFiles->PElm(i)->m_stFile.GetSafeSz(),
				  s_prgfiFiles->PElm(i)->m_stPath.GetSafeSz());
		Trace("(id %08.8x) - END of FILES FOUND --------", GetCurrentThreadId());
		}
#endif

	if (FHrSucceeded(hr))
		{
		// signal client needs to reload (do it very last, so the matches
		// windows doesn't get stuck with count of files found).
		s_fReload = fTrue;
		}
	Trace("(id %08.8x) - Thread_EnumerateFiles ENDED", GetCurrentThreadId());
	return 0;
}



///////////////////////////////////////////////////////////////////////////
// FlatFile Control Methods

cexport
ULONG FlatFile_GetCount()
{
	CONTEXT_("FlatFile_GetCount");
	ULONG c = (ULONG)-1;	// flat file list not ensured

	ScopedCritSec cs(g_csFlatFile);

	if (s_prgfiFiles)
		c = s_prgfiFiles->GetSize();
	return c;
}


cexport
ULONG FlatFile_CFound()
{
	return s_cFound;
}


cexport
ULONG FlatFile_CchLongestPath()
{
	CONTEXT_("FlatFile_CchLongestPath");
	Assert(s_prgfiFiles);
	return s_cchLongest;
}


cexport
LPSTRING FlatFile_GetFilename(ULONG index)
{
	CONTEXT_("FlatFile_GetFilename");
	HRESULT hr = E_UNEXPECTED;
	String st;

	ScopedCritSec cs(g_csFlatFile);

	Assert(s_prgfiFiles);
	if (s_prgfiFiles)
		{
//		Assert(0 <= index && index < s_prgfiFiles->GetSize());
		if (0 <= index && index < s_prgfiFiles->GetSize())
			{
			CORg(st.HrDup((*s_prgfiFiles)[index].m_stFile));
			CORg(st.HrAppend(c_chDiv));
			CORg(st.HrAppend((*s_prgfiFiles)[index].m_stPath));
			}
		}

Error:
	if (FHrFailed(hr))
		st.Free();
	return st.TSE();
}


static int Cmp_Lookup(LPCSTR pszPartialFile, FileInfo *pfi)
{
	CONTEXT_("Cmp_Lookup");
	LPCSTR psz1 = pszPartialFile;
	LPCSTR psz2 = pfi->m_stFile;
	int n = lstrlen(psz1);
	return cmpsorti(psz1, n, psz2, n);
}


static BOOL FLinearSearch(LPCSTR pszFile, LPCSTR pszPath, ULONG i, ULONG *piFound, BOOL fNext)
{
	CONTEXT_("FLinearSearch");
	String *pst;
	ULONG cchPath = lstrlen(pszPath);

	*piFound = (ULONG)-1;

	while (fNext ? (i < s_prgfiFiles->GetSize()) : ((ULONG)-1 != i))
		{
		AssertSz(*pszPath, "pszPath is empty, so why are you calling FLinearSearch?");

		// compare end of paths
		if (cchPath <= ULONG(s_prgfiFiles->PElm(i)->m_stPath.Length()))
			{
			pst = s_prgfiFiles->PElm(i)->m_stPath.PString();
			if (0 == Cmp_NoCase(pszPath, pst->GetSafeSz() + (pst->Length() - cchPath)))
				{
				// compare beginning of filenames
				if (0 == Cmp_Lookup(pszFile, s_prgfiFiles->PElm(i)))
					{
					*piFound = i;
					return fTrue;
					}
				}
			}

		if (fNext)
			i++;
		else
			i--;
		}
	return fFalse;
}


cexport
ULONG FlatFile_Lookup(LPCSTR pszFile, LPCSTR pszPath, ULONG iStart, ULONG ulFlags)
{
	CONTEXT_("FlatFile_Lookup");
	BOOL fPath = (pszPath && *pszPath);

	Assert1(lookFirst == ulFlags ||
			lookNext == ulFlags ||
			lookPrev == ulFlags ||
			lookLast == ulFlags,
			"what kind of silly flag is %d??", ulFlags);

	if (s_prgfiFiles)
		{
		ScopedCritSec cs(g_csFlatFile);

		if (fPath)
			{
			// path specified, so must do linear search
			//$ review: (chrisant) could have list doubly indexed, but would
			// be more work; is it worth it?
			if (lookFirst == ulFlags)
				iStart = 0;
			else if (lookLast == ulFlags)
				iStart = s_prgfiFiles->GetSize()-1;
			FLinearSearch(pszFile, pszPath, iStart, &iStart, (lookFirst == ulFlags || lookNext == ulFlags));
			}
		else
			{
			// binary search
			if (0 <= iStart && iStart < s_prgfiFiles->GetSize())
				{
				if (lookFirst == ulFlags || lookLast == ulFlags)
					{
					// find a match
					if (!s_prgfiFiles->FSearch((CompareFn)Cmp_Lookup, pszFile, &iStart))
						{
						Trace("FlatFile_Lookup, no match.\n");
						iStart = -1;
						}

					// linear search to find first/last match
					if (iStart != ULONG(-1))
						{
						if (lookLast == ulFlags)
							{
							while (iStart + 1 < s_prgfiFiles->GetSize() &&
								   Cmp_Lookup(pszFile,
								   s_prgfiFiles->PElm(iStart + 1)) == 0)
								iStart++;
							Trace("FlatFile_Lookup, last match is %u, %s.\n",
								  iStart, s_prgfiFiles->PElm(iStart)->m_stFile);
							}
						else
							{
							while (iStart > 0 && Cmp_Lookup(pszFile,
									s_prgfiFiles->PElm(iStart - 1)) == 0)
								iStart--;
							Trace("FlatFile_Lookup, first match is %u, %s.\n",
								  iStart, s_prgfiFiles->PElm(iStart)->m_stFile);
							}
						}
					}
				else if (Cmp_Lookup(pszFile, s_prgfiFiles->PElm(iStart)))
					iStart = ULONG(-1);
				}
			else
				// out of bounds, return not found
				iStart = ULONG(-1);
			}
		}
	else
		iStart = ULONG(-1);

	return iStart;
}


#if 0
cexport
LPSTRING FlatFile_LookupFirst(LPCSTR pszFile, LPCSTR pszPath)
{
	CONTEXT_("FlatFile_LookupFirst");
	HRESULT hr;
	LPSTRING pstr = &g_strNull;

	CORg(s_stPartialFile.HrDup(pszFile));
	CORg(s_stPartialPath.HrDup(pszPath));
	s_iIndex = (ULONG)-1;

	if (s_prgfiFiles)
		{
		ScopedCritSec cs(g_csFlatFile);

		if (!pszPath || !*pszPath)
			{
			// binary search
			s_prgfiFiles->FSearch((CompareFn)Cmp_Lookup, pszFile, &s_iIndex);
			}
		else
			{
			// linear search
			FLinearSearch(0, &s_iIndex, fTrue);
			}

		pstr = FlatFile_GetFilename(s_iIndex);
		}

Error:
	return pstr;
}


cexport
LPSTRING FlatFile_LookupNext()
{
	CONTEXT_("FlatFile_LookupNext");
	LPSTRING pstr = &g_strNull;

	Assert(s_prgfiFiles);

	ScopedCritSec cs(g_csFlatFile);

	if (s_stPartialPath.IsEmpty())
		{
		// continue from binary search, so just check next index
		if (s_iIndex+1 >= s_prgfiFiles->GetSize() ||
				Cmp_Lookup(s_stPartialFile, s_prgfiFiles->PElm(s_iIndex+1)))
			s_iIndex = (ULONG)-1;
		else
			s_iIndex++;
		}
	else
		{
		// continue from linear search
		FLinearSearch(s_iIndex+1, &s_iIndex, fTrue);
		}

	pstr = FlatFile_GetFilename(s_iIndex);

	return pstr;
}


cexport
LPSTRING FlatFile_LookupPrev()
{
	CONTEXT_("FlatFile_LookupPrev");
	LPSTRING pstr = &g_strNull;

	Assert(s_prgfiFiles);

	ScopedCritSec cs(g_csFlatFile);

	if (s_stPartialPath.IsEmpty())
		{
		// continue from binary search, so just check next index
		if (0 == s_iIndex ||
				Cmp_Lookup(s_stPartialFile, s_prgfiFiles->PElm(s_iIndex-1)))
			s_iIndex = (ULONG)-1;
		else
			s_iIndex--;
		}
	else
		{
		// continue from linear search
		FLinearSearch(s_iIndex-1, &s_iIndex, fFalse);
		}

	pstr = FlatFile_GetFilename(s_iIndex);

	return pstr;
}
#endif


cexport
BOOL FlatFile_FReload()
{
	BOOL fReload = s_fReload;

	s_fReload = fFalse;
	return fReload;
}


cexport
BOOL FlatFile_FBuilding()
{
	if (s_hThread)
		{
		if (WaitForSingleObject(s_hThread, 0) == WAIT_OBJECT_0)
			{
			CloseHandle(s_hThread);
			s_hThread = 0;
			}
		}
	return (s_hThread != 0);
}


cexport
void FlatFile_Abort(BOOL fWait)
{
	CONTEXT_("FlatFile_Abort");

	// abort threaded searching
	s_fAbort = fTrue;

	if (fWait && FlatFile_FBuilding())
		{
		WaitForSingleObject(s_hThread, INFINITE);
		CloseHandle(s_hThread);
		s_hThread = 0;
		s_fAbort = fFalse;
		}
}


cexport
void FlatFile_Free()
{
	// ensure thread has terminated
	FlatFile_Abort(fTrue);

	// free all flatfile info
	delete s_prgfiFiles;
	s_prgfiFiles = 0;
}


cexport
BOOL FlatFile_PrepareToBuild(LPCSTR pszExts)
{
	CONTEXT_("FlatFile_PrepareToBuild");
	HRESULT hr;
	FlatFileTraversal *pfft = 0;
	SPSZ spsz;
	LPSTR psz;
	LPSTR pszNext;
	BOOL fContinue;
	String *pst;

	// if we're already processing, drop what we're doing and get ready to do
	// something else.
	FlatFile_Abort(fFalse);

	// allocate struct to receive info for building file list
	pfft = New FlatFileTraversal;
	CPRg(pfft);

	// parse pszExts, space delimited, quotes are not supported
	spsz = SzMemDup(pszExts);
	psz = spsz;
	while (*psz)
		{
		for (pszNext = psz; *pszNext && *pszNext != ' '; ++pszNext);
		fContinue = !!*pszNext;
		*pszNext = 0;

		CORg(pfft->m_rgstWild.HrAppend(&pst));
		if (*FindExt(psz) != '.')
			CORg(pst->HrAppend("*."));
		CORg(pst->HrAppend(psz));

		if (!fContinue)
			break;

		for (psz = pszNext + 1; *psz == ' '; ++psz);
		if (!*psz)
			break;
		}

#ifdef DEBUG
	{
	for (int c = pfft->m_rgstWild.GetSize(); c--;)
		Trace("Wild %03d: \"%s\"", c, pfft->m_rgstWild.PElm(c)->GetSafeSz());
	}
#endif

	s_pfft = pfft;
	pfft = 0;

Error:
	delete pfft;
	return FHrSucceeded(hr);
}


cexport
BOOL FlatFile_AddPath(LPCSTR pszPath, ULONG ulFlags)
{
	CONTEXT_("FlatFile_AddPath");
	HRESULT hr;
	DirInfo *pdiNew;

	Assert(s_pfft);

	if (ulFlags & apExclude)
		CORg(s_pfft->m_rgdiExclude.HrAppend(&pdiNew));
	else
		CORg(s_pfft->m_rgdiInclude.HrAppend(&pdiNew));

	CORg(pdiNew->m_stPath.HrDup(pszPath));
	pdiNew->m_ulFlags = (ulFlags & apSubDirs) ? diSubDirs : 0;

Error:
	return FHrSucceeded(hr);
}


cexport
BOOL FlatFile_ThreadedBuild()
{
	CONTEXT_("FlatFile_ThreadedBuild");
	DWORD dwId;

	// ensure thread has terminated
	FlatFile_Abort(fTrue);

	// kick off thread
	Assert(!s_hThread);
	s_cFound = 0;
	s_hThread = CreateThread(0,						// security
							 cbThreadMinStack,		// stack size
							 Thread_EnumerateFiles,	// start routine
							 s_pfft,				// parameter
							 0,						// creation flags
							 &dwId					// thread id
							 );

	// if thread creation failed, don't leak s_pfft
	if (!s_hThread)
		delete s_pfft;

	// ownership of s_pfft has been transferred to the thread routine
	s_pfft = 0;

	return (s_hThread != 0);
}


cexport
BOOL FlatFile_PrepareToLoad()
{
	CONTEXT_("FlatFile_PrepareToLoad");

	ScopedCritSec cs(g_csFlatFile);

	FlatFile_Abort(fFalse);
	delete s_prgfiFiles;
	s_cchLongest = 0;
	s_prgfiFiles = New Rg<FileInfo>;

	return (s_prgfiFiles != 0);
}


cexport
BOOL FlatFile_Load(LPCSTR pszFile, LPCSTR pszPath)
{
	CONTEXT_("FlatFile_Load");
	HRESULT hr;
	FileInfo *pfi;

	Assert(s_prgfiFiles);

	CORg(s_prgfiFiles->HrAppend(&pfi));

	CORg2(pfi->m_stFile.HrDup(pszFile));
	CORg2(pfi->m_stPath.HrDup(pszPath));

	s_cchLongest = max(s_cchLongest,
					   ULONG(pfi->m_stFile.Length() +
							 pfi->m_stPath.Length()));

Error:
	return FHrSucceeded(hr);

Error_2:
	//CORg(s_prgfiFiles->HrRemove(1, s_prgfiFiles->GetSize()-1));
	delete s_prgfiFiles;
	s_prgfiFiles = 0;
	goto Error;
}


