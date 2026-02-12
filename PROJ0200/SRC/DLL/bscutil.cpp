// BSC File Support

#ifndef _STD_H
#include "std.h"
#endif

#ifndef _BSCUTIL_H
#include "bscutil.h"
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



///////////////////////////////////////////////////////////////////////////
// Types



///////////////////////////////////////////////////////////////////////////
// Globals

#ifdef DEBUG
static BOOL					s_fInitialized = fFalse;
#endif

static Bsc					*s_pbsc = 0;

static IINST				*s_prgInst = 0;
static ULONG				s_cInst = 0;

static IDEF					*s_prgDef = 0;
static ULONG				s_cDefs = 0;

static IREF					*s_prgRef = 0;
static ULONG				s_cRefs = 0;

static IINST				*s_prgUses = 0;
static ULONG				s_cUses = 0;

static IINST				*s_prgUby = 0;
static ULONG				s_cUby = 0;

static IINST				*s_prgBases = 0;
static ULONG				s_cBases = 0;

static IINST				*s_prgDervs = 0;
static ULONG				s_cDervs = 0;

static IINST				*s_prgMembers = 0;
static ULONG				s_cMembers = 0;



///////////////////////////////////////////////////////////////////////////
// BSC Functions

cexport
long OpenBrowseFile(LPCSTR pszBscFile)
{
	CONTEXT_("OpenBrowseFile");
	BOOL f;

	Assert(!s_pbsc);
	f = Bsc::open(pszBscFile, &s_pbsc);
	if (s_pbsc)
		s_pbsc->setCaseSensitivity(fFalse);
	return f;
}


static void dispose(void **ppAnyArray, ULONG *pc)
{
	CONTEXT_("dispose");

	if (*ppAnyArray)
		{
		Assert(s_pbsc);
		s_pbsc->disposeArray(*ppAnyArray);
		*ppAnyArray = 0;
		*pc = 0;
		}
	Assert(!*ppAnyArray);
	Assert(!*pc);
}


cexport
void DisposeDefinitions()
{
	CONTEXT_("DisposeDefinitions");
	dispose((void**)&s_prgDef, &s_cDefs);
}


cexport
void DisposeReferences()
{
	CONTEXT_("DisposeReferences");
	dispose((void**)&s_prgRef, &s_cRefs);
}


cexport
void DisposeUses()
{
	CONTEXT_("DisposeUses");
	dispose((void**)&s_prgUses, &s_cUses);
}


cexport
void DisposeUsedBy()
{
	CONTEXT_("DisposeUsedBy");
	dispose((void**)&s_prgUby, &s_cUby);
}


cexport
void DisposeBases()
{
	CONTEXT_("DisposeBases");
	dispose((void**)&s_prgBases, &s_cBases);
}


cexport
void DisposeDervs()
{
	CONTEXT_("DisposeDervs");
	dispose((void**)&s_prgDervs, &s_cDervs);
}


cexport
void DisposeMembers()
{
	CONTEXT_("DisposeMembers");
	dispose((void**)&s_prgMembers, &s_cMembers);
}


cexport
void DisposeArray()
{
	CONTEXT_("DisposeArray");
	dispose((void**)&s_prgInst, &s_cInst);
}


cexport
long CloseBrowseFile()
{
	CONTEXT_("CloseBrowseFile");
	Bsc *pbsc = s_pbsc;

	DisposeDefinitions();
	DisposeReferences();
	DisposeUses();
	DisposeUsedBy();
	DisposeBases();
	DisposeDervs();
	DisposeMembers();
	DisposeArray();
	s_pbsc = 0;
	return pbsc ? pbsc->close() : 0;
}


cexport
long SetCurrentSymbol(LPCSTR pszSymbol)
{
	CONTEXT_("SetCurrentSymbol");

	Assert(s_pbsc);
	Assert(pszSymbol);

	DisposeArray();
	if (pszSymbol)
		{
#if 0
		case '*':  mbf |= mbfAll;     break;
		case 'F':  mbf |= mbfFuncs;   break;
		case 'V':  mbf |= mbfVars;    break;
		case 'M':  mbf |= mbfMacros;  break;
		case 'T':  mbf |= mbfTypes;   break;
		case 'C':  mbf |= mbfClass;   break;
#endif
		s_pbsc->getOverloadArray((LPSTR)(LPCSTR)pszSymbol, mbfAll, &s_prgInst, &s_cInst);
		if (!s_prgInst)
			Assert(s_cInst == 0);
		}
	return s_cInst;
}


cexport
long GetSymbol(ULONG i)
{
	CONTEXT_("GetSymbol");

	Assert(s_pbsc);
	Assert(s_prgInst);
	i--;

	if (s_pbsc && i >= 0 && i < s_cInst)
		return s_prgInst[i] + 1;
	return 0;
}


cexport
LPSTRING GetName(ULONG i, int *ptyp, int *patr)
{
	CONTEXT_("GetName");
	LPSTR psz = 0;
	TYP typ;
	ATR atr;

	i--;
	if (s_pbsc && i >= 0)
		{
		if (s_pbsc->iinstInfo(i, &psz, &typ, &atr))
			{
			psz = s_pbsc->formatDname(psz);
			*ptyp = typ;
			*patr = atr;
			}
		else
			Assert(!psz);
		}
	return TSE(psz, -1);
}


cexport
LPSTRING GetType(TYP typ)
{
	CONTEXT_("GetType");
	LPSTR psz = 0;

	if (s_pbsc)
		psz = s_pbsc->szFrTyp(typ);
	return TSE(psz, -1);
}


cexport
LPSTRING GetAttr(ATR atr)
{
	CONTEXT_("GetAttr");
	LPSTR psz = 0;

	if (s_pbsc)
		psz = s_pbsc->szFrAtr(atr);
	return TSE(psz, -1);
}


cexport
long GetDefinitions(ULONG i)
{
	CONTEXT_("GetDefinitions");

	Assert(s_pbsc);
	i--;

	DisposeDefinitions();
	if (s_pbsc && i >= 0 && i < s_cInst)
		{
		s_pbsc->getDefArray(s_prgInst[i], &s_prgDef, &s_cDefs);
		if (!s_prgDef)
			Assert(!s_cDefs);
		}
	return s_cDefs;
}


cexport
LPSTRING GetDef(ULONG i, int *pnLine)
{
	CONTEXT_("GetDef");
	LPSTR psz = 0;
	LINE nLine;

	Assert(s_pbsc);
	Assert(s_prgDef);
	i--;

	if (s_pbsc && i >= 0 && i < s_cDefs)
		{
		if (s_pbsc->idefInfo(s_prgDef[i], &psz, &nLine))
			*pnLine = nLine + 1;
		else
			Assert(!psz);
		}
	return TSE(psz, -1);
}


cexport
long GetReferences(ULONG i)
{
	CONTEXT_("GetReferences");

	Assert(s_pbsc);
	i--;

	DisposeReferences();
	if (s_pbsc && i >= 0 && i < s_cInst)
		{
		s_pbsc->getRefArray(s_prgInst[i], &s_prgRef, &s_cRefs);
		if (!s_prgRef)
			Assert(!s_cRefs);
		}
	return s_cRefs;
}


cexport
LPSTRING GetRef(ULONG i, int *pnLine)
{
	CONTEXT_("GetRef");
	LPSTR psz = 0;
	LINE nLine;

	Assert(s_pbsc);
	Assert(s_prgRef);
	i--;

	if (s_pbsc && i >= 0 && i < s_cRefs)
		{
		if (s_pbsc->irefInfo(s_prgRef[i], &psz, &nLine))
			*pnLine = nLine + 1;
		else
			Assert(!psz);
		}
	return TSE(psz, -1);
}


cexport
long GetUses(ULONG i, DWORD mbf)
{
	CONTEXT_("GetUses");

	Assert(s_pbsc);
	i--;

	DisposeUses();
	if (s_pbsc && i >= 0 && i < s_cInst)
		{
		s_pbsc->getUsesArray(s_prgInst[i], mbf, &s_prgUses, &s_cUses);
		if (!s_prgUses)
			Assert(!s_cUses);
		}
	return s_cUses;
}


cexport
long GetUse(ULONG i)
{
	CONTEXT_("GetUse");

	Assert(s_pbsc);
	Assert(s_prgUses);
	i--;

	if (s_pbsc && i >= 0 && i < s_cUses)
		return s_prgUses[i] + 1;
	return 0;
}


cexport
long GetUbys(ULONG i, DWORD mbf)
{
	CONTEXT_("GetUbys");

	Assert(s_pbsc);
	i--;

	DisposeUsedBy();
	if (s_pbsc && i >= 0 && i < s_cInst)
		{
		s_pbsc->getUsedByArray(s_prgInst[i], mbf, &s_prgUby, &s_cUby);
		if (!s_prgUby)
			Assert(!s_cUby);
		}
	return s_cUby;
}


cexport
long GetUby(ULONG i)
{
	CONTEXT_("GetUby");

	Assert(s_pbsc);
	Assert(s_prgUby);
	i--;

	if (s_pbsc && i >= 0 && i < s_cUby)
		return s_prgUby[i] + 1;
	return 0;
}


cexport
long GetBases(ULONG i)
{
	CONTEXT_("GetBases");

	Assert(s_pbsc);
	i--;

	DisposeBases();
	if (s_pbsc && i >= 0 && i < s_cInst)
		{
		s_pbsc->getBaseArray(s_prgInst[i], &s_prgBases, &s_cBases);
		if (!s_prgBases)
			Assert(!s_cBases);
		}
	return s_cBases;
}


cexport
long GetBase(ULONG i)
{
	CONTEXT_("GetBase");

	Assert(s_pbsc);
	Assert(s_prgBases);
	i--;

	if (s_pbsc && i >= 0 && i < s_cBases)
		return s_prgBases[i] + 1;
	return 0;
}


cexport
long GetDervs(ULONG i)
{
	CONTEXT_("GetDervs");

	Assert(s_pbsc);
	i--;

	DisposeDervs();
	if (s_pbsc && i >= 0 && i < s_cInst)
		{
		s_pbsc->getDervArray(s_prgInst[i], &s_prgDervs, &s_cDervs);
		if (!s_prgDervs)
			Assert(!s_cDervs);
		}
	return s_cDervs;
}


cexport
long GetDerv(ULONG i)
{
	CONTEXT_("GetDerv");

	Assert(s_pbsc);
	Assert(s_prgDervs);
	i--;

	if (s_pbsc && i >= 0 && i < s_cDervs)
		return s_prgDervs[i] + 1;
	return 0;
}


cexport
long GetMembers(ULONG i, DWORD mbf)
{
	CONTEXT_("GetMembers");

	Assert(s_pbsc);
	i--;

	DisposeMembers();
	if (s_pbsc && i >= 0 && i < s_cInst)
		{
		s_pbsc->getMembersArray(s_prgInst[i], mbf, &s_prgMembers, &s_cMembers);
		if (!s_prgMembers)
			Assert(!s_cMembers);
		}
	return s_cMembers;
}


cexport
long GetMember(ULONG i)
{
	CONTEXT_("GetMember");

	Assert(s_pbsc);
	Assert(s_prgMembers);
	i--;

	if (s_pbsc && i >= 0 && i < s_cMembers)
		return s_prgMembers[i] + 1;
	return 0;
}





#if 0
#include "bsc.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void DumpModules();
void DumpAllInstInfo(IINST);
void DisplayInstName(IINST);
void DumpOneModule(SZ);
void DumpRefs(IINST iinst);
void DumpDefs(IINST iinst);
void DumpUses(IINST iinst);
void DumpUbys(IINST iinst);
void DumpBases(IINST iinst);
void DumpDervs(IINST iinst);

Bsc *pbsc;
MBF mbf = mbfAll;

void main(int argc, char **argv)
{
	if (argc == 2) {
		DumpModules();
		exit(0);
	}

		if (!strcmp(szOpt, "-all")) {
				for (ULONG i=0; i<cInst; i++) 
					DumpAllInstInfo(rgInst[i]);
		}
		else if (!strcmp(szOpt, "-ref")) {
				for (ULONG i=0; i<cInst; i++)
					DumpRefs(rgInst[i]);
		}
		else if (!strcmp(szOpt, "-def")) {
				for (ULONG i=0; i<cInst; i++)
					DumpDefs(rgInst[i]);
		}
		else if (!strcmp(szOpt, "-use")) {
				for (ULONG i=0; i<cInst; i++)
					DumpUses(rgInst[i]);
		}
		else if (!strcmp(szOpt, "-uby")) {
				for (ULONG i=0; i<cInst; i++)
					DumpUbys(rgInst[i]);
		}
		else if (!strcmp(szOpt, "-base")) {
				for (ULONG i=0; i<cInst; i++)
					DumpBases(rgInst[i]);
		}
		else if (!strcmp(szOpt, "-derv")) {
				for (ULONG i=0; i<cInst; i++)
					DumpDervs(rgInst[i]);
		}
		else if (!strcmp(szOpt, "-names")) {
				for (ULONG i=0; i<cInst; i++)
					DisplayInstName(rgInst[i]);
		}
		else if (!strcmp(szOpt, "-module")) {
			if (!argv[i+1])
				continue;

			SZ szStr = argv[++i];

			IMOD imod;
			if (!pbsc->getModuleByName(szStr, &imod)) {
				printf("no module matching '%s'\n", szStr);
			}
			else {
				printf("%s module contents:\n", szStr);
				if (!pbsc->getModuleContents(imod, mbf, &rgInst, &cInst) || cInst == 0) {
					printf("    no contents\n");
				}
				else {
					for (ULONG i = 0; i < cInst; i++) {
						printf("    "); DisplayInstName(rgInst[i]);
					}
					pbsc->disposeArray(rgInst);
				}
			}
		}

}

void DumpRefs(IINST iinst)
{
	DisplayInstName(iinst);

	IREF *rgiref;
	ULONG ciref;
	if (!pbsc->getRefArray(iinst, &rgiref, &ciref) || ciref == 0) {
		printf("references:\n    none\n");
	}
	else {
		printf("references:\n");

		for (ULONG i = 0; i < ciref; i++) {
			SZ sz; LINE line;
			pbsc->irefInfo(rgiref[i], &sz, &line);
			printf("    %s(%d)\n", sz, line+1);
		}
		pbsc->disposeArray(rgiref);
	}
}

void DumpDefs(IINST iinst)
{
	DisplayInstName(iinst);

	IDEF *rgidef;
	ULONG cidef;
	if (!pbsc->getDefArray(iinst, &rgidef, &cidef) || cidef == 0) {
		printf("definitions:\n    none\n");
	}
	else {
		printf("definitions:\n");

		for (ULONG i = 0; i < cidef; i++) {
			SZ sz; LINE line;
			pbsc->idefInfo(rgidef[i], &sz, &line);
			printf("    %s(%d)\n", sz, line+1);
		}
		pbsc->disposeArray(rgidef);
	}
}

void DumpUses(IINST iinst)
{
	DisplayInstName(iinst);

	IINST *rgiinst;
	ULONG ciinst;

	if (!pbsc->getUsesArray(iinst, mbf, &rgiinst, &ciinst) || ciinst == 0) {
		printf("uses:\n    nothing\n");
	}
	else {
		printf("uses:\n");
		for (int i = 0; i < ciinst; i++) {
			printf("    "); DisplayInstName(rgiinst[i]);
		}
		pbsc->disposeArray(rgiinst);
	}
}

void DumpUbys(IINST iinst)
{
	DisplayInstName(iinst);

	IINST *rgiinst;
	ULONG ciinst;

	if (!pbsc->getUsedByArray(iinst, mbf, &rgiinst, &ciinst) || ciinst == 0) {
		printf("used by:\n    nothing\n");
	}
	else {
		printf("used by:\n");
		for (int i = 0; i < ciinst; i++) {
			printf("    "); DisplayInstName(rgiinst[i]);
		}
		pbsc->disposeArray(rgiinst);
	}

}

void DumpBases(IINST iinst)
{
	DisplayInstName(iinst);

	IINST *rgiinst;
	ULONG ciinst;

	if (pbsc->getBaseArray(iinst, &rgiinst, &ciinst) && ciinst != 0) {
		printf("bases:\n");
		for (int i = 0; i < ciinst; i++) {
			printf("    "); DisplayInstName(rgiinst[i]);
		}
		pbsc->disposeArray(rgiinst);
	}
}

void DumpDervs(IINST iinst)
{
	DisplayInstName(iinst);

	IINST *rgiinst;
	ULONG ciinst;

	if (pbsc->getDervArray(iinst, &rgiinst, &ciinst) && ciinst != 0) {
		printf("derived classes:\n");
		for (int i = 0; i < ciinst; i++) {
			printf("    "); DisplayInstName(rgiinst[i]);
		}
		pbsc->disposeArray(rgiinst);
	}
}

void DumpAllInstInfo(IINST iinst)
{
	DisplayInstName(iinst);

	DumpDefs(iinst);
	DumpRefs(iinst);

	DumpUses(iinst);
	DumpUbys(iinst);

	DumpBases(iinst);
	DumpDervs(iinst);
}


void DumpModules()
{
	IMOD *rgimod;
	ULONG cimod;
	BSC_STAT bs;

	if (!pbsc->getAllModulesArray(&rgimod, &cimod) || cimod == 0) {
		printf("no modules\n");
	}
	else {
		printf("modules:\n\n", cimod);
		for (ULONG i = 0; i < cimod; i++) {
			SZ sz;
			if (pbsc->imodInfo(rgimod[i], &sz)) {
				printf("%s", sz);
				if (pbsc->getModuleStatistics(i, &bs)) 
					printf("  cInst:%d cDef:%d cRef:%d cUse:%d cBase:%d\n",
						bs.cInst, bs.cDef, bs.cRef, bs.cUseLink, bs.cBaseLink);
				else
					printf("\n");
			}
			
		}
		pbsc->disposeArray(rgimod);
	}
	if (pbsc->getStatistics(&bs)) 
		printf("Totals   cMod:%d cInst:%d cDef:%d cRef:%d cUse:%d cBase:%d\n",
			bs.cMod, bs.cInst, bs.cDef, bs.cRef, bs.cUseLink, bs.cBaseLink);
}
#endif



