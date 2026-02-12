
#ifndef _PROJDLL_H
#include "projdll.h"
#endif

#ifndef _STD_H
#include "std.h"
#endif

#ifndef _ARRAYS_H
#include "arrays.h"
#endif


//////////////////////////////////////////////////////////////////////
// Construction/Destruction

RgBase::RgBase(size_t cbSize, ULONG cElmGrow) :
	m_rgElm(NULL),
	m_cElm(0),
	m_cElmGrow(cElmGrow),
	m_cElmAlloc(0),
	m_cbElmSize(cbSize)
{
	Assert(cElmGrow > 0);
	Assert(cbSize > 0);
}


RgBase::~RgBase()
{
	// derived classes must call HrSetSize in its destructor for the the
	// proper DestructElms to be called.
	//HrSetSize(0);
	Assert(m_cElm == 0);
	MemFree(m_rgElm);
}


HRESULT RgBase::HrSetSize(ULONG cElm)
{
	HRESULT hr = S_OK;

	if (cElm > m_cElm)
		{
		// append (cElm - m_cElm) elements to the end of the array
		hr = HrBaseInsert(cElm - m_cElm, m_cElm, 0);
		}
	else if (cElm < m_cElm)
		{
		// remove (m_cElm - cElm) elements from the end of the array
		hr = HrBaseRemove(m_cElm - cElm, cElm);
		}

	return hr;
}


void RgBase::Free()
{
	MemFree(m_rgElm);
	m_rgElm = 0;
	m_cElm = 0;
	m_cElmAlloc = 0;
}


/*!-------------------------------------------------------------------------
	RgBase::FSearch
		Finds any matching occurrence.  No guarantee if the matching index is 
		the lowest or highest matching index.

	Args:
		pfn - [in] used to compare pElm against elements in the array.
		pElm - [in] is always passed as the FIRST parameter to pfn.
		pIndex - [out] optional location to store index of matching element.

	Return:
		TRUE - exact match was found, *pIndex is index of match.
		FALSE - *pIndex is index at which the element should be inserted.

 --------------------------------------------------------------------------*/
BOOL RgBase::FSearch(CompareFn pfn, const void* pElm, ULONG* pIndex)
{
	ULONG iLo;
	ULONG iMid;
	ULONG iHi;
	int n = 1;							// (any non-zero value will do)

	// binary search
	iLo = 0;
	iHi = GetSize();
	while (iLo < iHi)
		{
		iMid = (iHi + iLo) / 2;

		n = pfn((const void*)pElm, (const void*)PElmLoc(iMid));

		// this algorithm optimizes for expensive comparison functions, but
		// does not guarantee *which* matching element we return.
		if (n < 0)
			iHi = iMid;
		else if (n > 0)
			iLo = iMid + 1;
		else
			{
			iLo = iMid;
			break;
			}
		}

	if (pIndex)
		*pIndex = iLo;

	return (n == 0);
}


#ifndef NO_COPY_CONSTRUCTORS
HRESULT RgBase::HrBaseInsert(const ELM* rgElm, ULONG cElm, ULONG iElm, ELM** ppElmOut)
#else
HRESULT RgBase::HrBaseInsert(ULONG cElm, ULONG iElm, ELM** ppElmOut)
#endif
{
	HRESULT hr = S_OK;

	Assert(0 <= iElm && iElm <= m_cElm);

	if (cElm > 0)
		{
		ELM*	pElm;
		ULONG	cbSize;

		CORg(HrSetAllocation(m_cElm + cElm));

		pElm = PElmLoc(iElm);
		cbSize = (m_cElm - iElm) * m_cbElmSize;
		if (cbSize > 0)
			memmove(PElmLoc(iElm + cElm), pElm, cbSize);
		m_cElm += cElm;

#ifndef NO_COPY_CONSTRUCTORS
		if (rgElm == NULL)
			ConstructElms(cElm, pElm);
		else
			ConstructElms(cElm, pElm, const_cast<ELM*>(rgElm));
#else
		ConstructElms(cElm, pElm);
#endif

		if (ppElmOut && cElm == 1)
			*ppElmOut = pElm;
		}

Error:
	return hr;
}


HRESULT RgBase::HrBaseRemove(ULONG cElm, ULONG iElm)
{
	HRESULT hr = S_OK;

	Assert(cElm > 0);
	Assert(0 <= iElm && iElm < m_cElm);
	Assert(iElm + cElm <= m_cElm);

	if (cElm > 0)
		{
		ELM*	pElm;
		ULONG	cbSize;

		pElm = PElm(iElm);
		DestructElms(cElm, pElm);

		cbSize = (m_cElm - (iElm + cElm)) * m_cbElmSize;
		if (cbSize > 0)
			memmove(pElm, PElmLoc(iElm + cElm), cbSize);
		m_cElm -= cElm;

		CORg(HrSetAllocation(m_cElm));
		}

Error:
	return hr;
}


void RgBase::ConstructElms(ULONG cElm, void* rgElmNew) const
{
	memset(rgElmNew, 0, cElm * m_cbElmSize);
}


void RgBase::ConstructElms(ULONG cElm, void* rgElmNew, void* rgElmSrc) const
{
	memcpy(rgElmNew, rgElmSrc, cElm * m_cbElmSize);
}


void RgBase::DestructElms(ULONG /*cElm*/, void* /*rgElm*/) const
{
	// this gets called when using Rg<Foo> without using
	// DEFINE_GENARRAY_CLASS(Foo), which is useful for simple types that have
	// no constructor and destructor.
}


HRESULT RgBase::HrSetAllocation(ULONG cElm)
{
	HRESULT hr = S_OK;
	long cAlloc;

	if (cElm > m_cElmAlloc)
		// this ensures O(n) performance when appending repeatedly
		cAlloc = m_cElmAlloc ? (m_cElmAlloc << 1) : 8;
	else if (cElm > 0 && m_cElmAlloc - cElm >= max(m_cElmAlloc / 2, 64))
		// if the array has shrunk dramatically (but is not zero), release
		// some of the memory
		cAlloc = cElm + m_cElmGrow;
	else
		goto Error;

	if (!m_cElmAlloc)
		{
		Assert(!m_cElm);
		Assert(!m_rgElm);
		m_rgElm = (ELM*)MemAlloc(cAlloc * m_cbElmSize);
		CPRg(m_rgElm);
		}
	else
		{
		ELM* p = 0;
		Assert(m_rgElm);

		p = (ELM*)MemReAlloc(m_rgElm, cAlloc * m_cbElmSize);
		CPRg(p);
		m_rgElm = p;
		}
	Assert(m_rgElm);
	m_cElmAlloc = cAlloc;
	Assert(m_cElmAlloc >= cElm);

Error:
	return hr;
}

