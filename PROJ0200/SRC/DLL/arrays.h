#ifdef _ARRAYS_H
#error _ARRAYS_H already defined!
#else
#define _ARRAYS_H
#endif

#ifndef _DBG_H
#include "dbg.h"
#endif


#undef THIS_FILE
#define THIS_FILE __FILE__


#define NO_COPY_CONSTRUCTORS
//#define TIME_ARRAY_DESTRUCTORS



///////////////////////////////////////////////////////////////////////////
// Base class for dynamic array

typedef int (*CompareFn)(const void *pElm1, const void *pElm2);


class RgBase
{
public:
	ULONG	GetSize() const;
	HRESULT	HrSetSize(ULONG cElm);

	BOOL	FSearch(CompareFn pfn, const void* pElm, ULONG* pIndex);

protected:
	typedef BYTE	ELM;

	RgBase(size_t cbElmSize, ULONG cElmGrow);
	virtual ~RgBase();

	void Free();

#ifndef NO_COPY_CONSTRUCTORS
	HRESULT	HrBaseInsert(const ELM* rgElm, ULONG cElm, ULONG iElm, ELM** ppElmOut);
#endif
	HRESULT	HrBaseInsert(ULONG cElm, ULONG iElm, ELM** ppElmOut);
	HRESULT	HrBaseRemove(ULONG cElm, ULONG iElm);

	//$ todo: (chrisant) sort

	ELM*	PElm(ULONG iElm) const;
	ELM*	PElmLoc(ULONG iElm) const;

	virtual void ConstructElms(ULONG cElm, void* rgElmNew) const;
	virtual void ConstructElms(ULONG cElm, void* rgElmNew, void* rgElmSrc) const;
	virtual void DestructElms(ULONG cElm, void* rgElm) const;

private:
	HRESULT	HrSetAllocation(ULONG cElm);

private:
#ifdef DEBUG
protected:
#endif
	ELM		*m_rgElm;
	ULONG	m_cElm;
	ULONG	m_cElmAlloc;
	ULONG	m_cElmGrow;
	ULONG	m_cbElmSize;
};


inline ULONG RgBase::GetSize() const
	{ return (m_cElm); }


inline RgBase::ELM *RgBase::PElm(ULONG iElm) const
	{
	Assert(iElm < m_cElm || (iElm == 0 && m_cElm == 0));
	return (m_cElm == 0 ? NULL : PElmLoc(iElm));
	}


inline RgBase::ELM *RgBase::PElmLoc(ULONG iElm) const
	{
	Assert(0 <= iElm);
	return (m_rgElm + iElm * m_cbElmSize);
	}


#ifndef NO_COPY_CONSTRUCTORS
inline HRESULT RgBase::HrBaseInsert(ULONG cElm, ULONG iElm, ELM** ppElmOut)
	{ return HrBaseInsert(0, cElm, iElm, ppElmOut); }
#endif



///////////////////////////////////////////////////////////////////////////
// Dynamic array - typed, searchable

template <class T>
class Rg : public RgBase
{
	typedef RgBase	super;

public:
	Rg(ULONG cElmGrow = 8);
	virtual ~Rg();

	void Free();

	T&	operator[](ULONG iElm) const;
	operator T*() const;
	T*	PElm(ULONG iElm) const;
	T*	PMax() const; 

#ifndef NO_COPY_CONSTRUCTORS
	HRESULT	HrInsert(const T* rgelm, ULONG cElm, ULONG iElm, T** ppElmOut = 0);
	HRESULT	HrInsert(const T& elm, ULONG iElm, T** ppElmOut = 0);
	HRESULT	HrInsert(const Rg<T>& rgT, ULONG iElm, T** ppElmOut = 0);
#endif
	HRESULT	HrInsert(ULONG iElm, T** ppElmOut = 0);

#ifndef NO_COPY_CONSTRUCTORS
	HRESULT	HrAppend(const T* rgelm, ULONG cElm, T** ppElmOut = 0);
	HRESULT	HrAppend(const T& elm, T** ppElmOut = 0);
	HRESULT	HrAppend(const Rg<T>& rgT, T** ppElmOut = 0);
#endif
	HRESULT	HrAppend(T** ppElmOut = 0);

	HRESULT	HrRemove(ULONG cElm, ULONG iElm);
	HRESULT	HrRemove(ULONG iElm) { return HrRemove(1, iElm); }	//$ review: (chrisant) should this be an actual function instead of inline?

protected:
	virtual void ConstructElms(ULONG cElm, void *rgElmNew) const;
#ifndef NO_COPY_CONSTRUCTORS
	virtual void ConstructElms(ULONG cElm, void *rgElmNew, void *rgElmSrc) const;
#endif
	virtual void DestructElms(ULONG cElm, void *rgElm) const;

#ifdef DEBUG
private:
	// to get a better view of the array in the debugger
	T**		m_ppT;
#endif
};


template <class T>
Rg<T>::Rg(ULONG cElmGrow) : super(sizeof(T), cElmGrow)
{
#ifdef DEBUG
	m_ppT = reinterpret_cast<T**>(&m_rgElm);
#endif
}


template <class T>
Rg<T>::~Rg()
{
#if defined(DEBUG) || defined(TIME_ARRAY_DESTRUCTORS)
	DWORD dw = GetTickCount();
#endif

	// have to call this here so that the correct DestructElms is called
	HrSetSize(0);

#if defined(DEBUG) || defined(TIME_ARRAY_DESTRUCTORS)
	Trace("Destructor for %s took %d milliseconds.", typeid(Rg<T>).name(), (GetTickCount()-dw));

#if 0
	char szBuf[512];
	wsprintf(szBuf, "destructor for array took %d milliseconds", (GetTickCount()-dw));
	MessageBox(0, szBuf, 0, MB_OK | MB_TASKMODAL);
#endif
#endif
}


template <class T>
void Rg<T>::Free()
{
	HrSetSize(0);
	RgBase::Free();

#ifdef DEBUG
	m_ppT = 0;
#endif
}


template <class T>
T&	Rg<T>::operator [](ULONG iElm) const
{
	return (*PElm(iElm));
}


template <class T>
Rg<T>::operator T*() const
{
	return (reinterpret_cast<T*>(super::PElm(0)));
}


template <class T>
T*	Rg<T>::PElm(ULONG iElm) const
{
	return (reinterpret_cast<T*>(super::PElm(iElm)));
}


template <class T>
T*	Rg<T>::PMax() const
{
	return (reinterpret_cast<T*>(super::PElmLoc(GetSize())));
}


#ifndef NO_COPY_CONSTRUCTORS
template <class T>
HRESULT	Rg<T>::HrInsert(const T* rgelm, ULONG cElm, ULONG iElm, T** ppElmOut)
{
	return (HrBaseInsert(reinterpret_cast<const ELM*>(rgelm), cElm, iElm,
						 reinterpret_cast<ELM**>(ppElmOut)));
}


template <class T>
HRESULT	Rg<T>::HrInsert(const T& elm, ULONG iElm, T** ppElmOut)
{
	return (HrBaseInsert(reinterpret_cast<const ELM*>(&elm), 1, iElm,
						 reinterpret_cast<ELM**>(ppElmOut)));
}


template <class T>
HRESULT	Rg<T>::HrInsert(const Rg<T>& rgT, ULONG iElm, T** ppElmOut)
{
	return (&rgT == this ? E_INVALIDARG :
					(rgT.GetSize() == 0 ? S_OK :
					 HrBaseInsert(reinterpret_cast<const ELM*>(rgT.PElm(0)),
								  rgT.GetSize(), iElm,
								  reinterpret_cast<ELM**>(ppElmOut))));
}
#endif


template <class T>
HRESULT	Rg<T>::HrInsert(ULONG iElm, T** ppElmOut)
{
	return (HrBaseInsert(1, iElm, reinterpret_cast<ELM**>(ppElmOut)));
}


#ifndef NO_COPY_CONSTRUCTORS
template <class T>
HRESULT	Rg<T>::HrAppend(const T* rgelm, ULONG cElm, T** ppElmOut)
{
	return (HrBaseInsert(reinterpret_cast<const ELM*>(rgelm), cElm, GetSize(),
						 reinterpret_cast<ELM**>(ppElmOut)));
}


template <class T>
HRESULT	Rg<T>::HrAppend(const T& elm, T** ppElmOut)
{
	return (HrBaseInsert(reinterpret_cast<const ELM*>(&elm), 1, GetSize(),
						 reinterpret_cast<ELM**>(ppElmOut)));
}


template <class T>
HRESULT	Rg<T>::HrAppend(const Rg<T>& rgT, T** ppElmOut)
{
	return (&rgT == this ? E_INVALIDARG :
					(rgT.GetSize() == 0 ? S_OK :
					 HrBaseInsert(reinterpret_cast<const ELM*>(rgT.PElm(0)),
								  rgT.GetSize(), GetSize(),
								  reinterpret_cast<ELM**>(ppElmOut))));
}
#endif


template <class T>
HRESULT	Rg<T>::HrAppend(T** ppElmOut)
{
	return (HrBaseInsert(1, GetSize(), reinterpret_cast<ELM**>(ppElmOut)));
}


template <class T>
HRESULT Rg<T>::HrRemove(ULONG cElm, ULONG iElm)
{
	return HrBaseRemove(cElm, iElm);
}


template <class T>
void Rg<T>::ConstructElms(ULONG cElm, void* rgElmNew) const
{
	super::ConstructElms(cElm, rgElmNew);
}


#ifndef NO_COPY_CONSTRUCTORS
template <class T>
void Rg<T>::ConstructElms(ULONG cElm, void* rgElmNew, void* rgElmSrc) const
{
	super::ConstructElms(cElm, rgElmNew, rgElmSrc);
}
#endif


template <class T>
void Rg<T>::DestructElms(ULONG cElm, void* rgElm) const
{
	super::DestructElms(cElm, rgElm);
}


template <class T>
void ConstructElms(ULONG /*cElm*/, T* /*rgElmNew*/)
{
	PanicSz("ConstructElms - Don't use implicit template!");
}


template <class T>
void ConstructElms(ULONG /*cElm*/, T* /*rgElmNew*/, T* /*rgElmSrc*/)
{
	PanicSz("ConstructElms - Don't use implicit template!");
}


template <class T>
void DestructElms(ULONG /*cElm*/, T* /*rgElm*/)
{
	PanicSz("DestructElms - Don't use implicit template!");
}


#define DEFINE_GENARRAY_CLASS(klass) \
	DEFINE_GENARRAY_CTOR(klass) \
	DEFINE_GENARRAY_DTOR(klass) \
	DEFINE_CLASS_HELPER(klass)

#ifdef NO_COPY_CONSTRUCTORS
#define DEFINE_GENARRAY_CTOR(klass) \
	DEFINE_GENARRAY_CTOR_NEW(klass)
#else
#define DEFINE_GENARRAY_CTOR(klass) \
	DEFINE_GENARRAY_CTOR_NEW(klass) \
	DEFINE_GENARRAY_CTOR_COPY(klass)
#endif

#define DEFINE_GENARRAY_CTOR_NEW(klass) \
	inline void Rg< klass >::ConstructElms(ULONG cElm, void* rgElmNew) const \
	{ \
		memset(rgElmNew, 0, cElm * sizeof(klass)); \
		::ConstructElms< klass >(cElm, reinterpret_cast< klass* >(rgElmNew)); \
	}

#ifndef NO_COPY_CONSTRUCTORS
#define DEFINE_GENARRAY_CTOR_COPY(klass) \
	inline void Rg< klass >::ConstructElms(ULONG cElm, void* rgElmNew, void* rgElmSrc) const \
	{ \
		memset(rgElmNew, 0, cElm * sizeof(klass)); \
		::ConstructElms< klass >(cElm, reinterpret_cast< klass* >(rgElmNew), \
								 reinterpret_cast< klass* >(rgElmSrc)); \
	}
#endif

#define DEFINE_GENARRAY_DTOR(klass) \
	inline void Rg< klass >::DestructElms(ULONG cElm, void* rgElm) const \
	{ ::DestructElms< klass >(cElm, reinterpret_cast< klass* >(rgElm)); }

#define DEFINE_CLASS_HELPER(klass) \
	DEFINE_CLASS_HELPER_CTOR(klass) \
	DEFINE_CLASS_HELPER_DTOR(klass)

#ifdef NO_COPY_CONSTRUCTORS
#define DEFINE_CLASS_HELPER_CTOR(klass) \
	DEFINE_CLASS_HELPER_CTOR_NEW(klass)
#else
#define DEFINE_CLASS_HELPER_CTOR(klass) \
	DEFINE_CLASS_HELPER_CTOR_NEW(klass) \
	DEFINE_CLASS_HELPER_CTOR_COPY(klass)
#endif

#define DEFINE_CLASS_HELPER_CTOR_NEW(klass) \
	inline void ConstructElms< klass >(ULONG cElm, klass* rgElmNew) \
	{																\
		while (cElm--)												\
			{														\
			rgElmNew->klass::klass();								\
			++rgElmNew;												\
			}														\
	}

#ifndef NO_COPY_CONSTRUCTORS
#define DEFINE_CLASS_HELPER_CTOR_COPY(klass) \
	inline void ConstructElms< klass >(ULONG cElm, klass* rgElmNew, klass* rgElmSrc) \
	{																\
		while (cElm--)												\
			{														\
			rgElmNew->klass::klass(*rgElmSrc);						\
			++rgElmNew;												\
			++rgElmSrc;												\
			}														\
	}
#endif

#define DEFINE_CLASS_HELPER_DTOR(klass) \
	inline void DestructElms< klass >(ULONG cElm, klass* rgElm) \
	{															\
		while (cElm--)											\
			{													\
			rgElm->klass::~klass();								\
			++rgElm;											\
			}													\
	}


