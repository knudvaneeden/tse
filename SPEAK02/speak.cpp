//////////
//
// speak.cpp
//
//////
//
// SPEAK.DLL
// ---------
//
//     Written:  December 15, 2024
//      Author:  Rick C. Hodgin
//               rick.c.hodgin@gmail.com
//
// -----
// See speak.s for an example of how to use this DLL.
// Please email Rick with any questions.  Please reference
// the speak.dll in the subject when emailing.
//
// Thank you.  Enjoy!
// Luke 6:37
//
//


#include "stdafx.h"
#include "speak.h"


//////////
// Structures
//////
	struct SVoice
	{
		s32			index;
		wchar_t*	name;
		s32			nameLength;
	};

	struct SAPI
	{
		wchar_t*	api;
		s32			apiLength;
	};

	struct SAsync
	{
		// For housekeeping
		bool				isActive;								// Active when playing in parallel, inactive otherwise

		// For asynchronous playing
		HANDLE				hThread;								// The thread this one is in
		DWORD				nThreadId;								// It's thread id

		// For speaking
		CComPtr<ISpVoice>	spVoice;								// SAPI interface
		ULONG				streamNumber;							// When speaking, it assigns this number
		s32					voice;									// Voice when started
		s32					volume;									// Volume when started

		// From the user
		s32					uid;									// uid for referencing
		s8*					text;									// Copy of their text
		s32					textLength;								// Their text length
	};


//////////
// Globals
//////
	bool							glSpeakInitialized					= false;
	CLSID							clsid;
	IDispatch*						pSapi								= NULL;			// sapi.spvoice

	// Version 2
	ULONG							voiceCount							= 0;			// Number of voices available
	s32								lastVoice							= 0;			// Last voice set
	s32								lastVolume							= 35;			// Last volume set
	CComPtr<ISpVoice>				spVoice;											// Pointer to Microsoft Speech API
	CComPtr<IEnumSpObjectTokens>	cpEnum;												// For enumerating
	CComPtr<ISpObjectToken>			cpToken;											// For individual entries
	std::list<SVoice*>*				voice_list							= new std::list<SVoice*>;
	std::list<SAPI*>*				api_list							= new std::list<SAPI*>;

	// For asynchronous playback
	CRITICAL_SECTION				cs_async_list;
	std::list<SAsync*>*				async_list							= new std::list<SAsync*>;



//////////
//
// Speak functions
//
//////
	// Initialize our COM engine at startup
	//
	// Note:  We capture all voice information, and the full public API exposed by this install of SAPI.
	// Note:  The users can get voice information with speak_get_voice_info(), but there is currently
	//        no function to return the SAPI exposed API.  It could be added with a speak_get_voice_api()
	//        function which returns each line of the API until there are now more.
	//
	BOOL iSpeak_dll_initialize(void)
	{
		bool					llShow, llFoundRetVal, llSkip;
		s32						lnJ, lnPass;
		ULONG					lnI;
		HRESULT					hr;
		UINT					cNames;
		ELEMDESC				paramDesc;
		CComHeapPtr<WCHAR>		description;
		std::wstring			builder = L"";
		SVoice*					v;
		SAPI*					a;
		ITypeInfo*				pTypeInfo = NULL;
		TYPEATTR*				pTypeAttr = NULL;
		FUNCDESC*				pFuncDesc = NULL;
		wchar_t					buffer[4096];


		//////////
		// Initialize
		//////
			if (FAILED(hr = ::CoInitialize(NULL)))
				return FALSE;

			InitializeCriticalSection(&cs_async_list);


		//////////
		// pSapi
		//////
			// Get our root COM object
			if (FAILED(hr = ::CLSIDFromProgID(L"sapi.spvoice", &clsid)))
				return FALSE;

			// Get our interface
			if (FAILED(hr = ::CoCreateInstance(CLSID_SpVoice, NULL, CLSCTX_ALL, IID_IDispatch, (void**)&pSapi)))
				return FALSE;


		//////////
		// spVoice
		//////
			if (FAILED(hr = ::CoCreateInstance(CLSID_SpVoice, NULL, CLSCTX_ALL, IID_ISpVoice, (void**)&spVoice)))
				return FALSE;


		//////////
		// Load the voices
		//////
			if (FAILED(hr = SpEnumTokens(SPCAT_VOICES, NULL, NULL, &cpEnum)))
				return FALSE;

			if (FAILED(hr = cpEnum->GetCount(&voiceCount)))
				return FALSE;

			// Iterate for each voice, adding it to our list
			for (lnI = 0; lnI < voiceCount; ++lnI)
			{
				if (SUCCEEDED(hr = cpEnum->Next(1, &cpToken, NULL)))
				{
					if (SUCCEEDED(hr = SpGetDescription(cpToken, &description)) && (v = (SVoice*)calloc(1, sizeof(SVoice))))
					{
						// Build the voice info
						v->index		= lnI;
						v->name			= _wcsdup(description);
						v->nameLength	= wcslen(v->name);

						// Add it to the list
						voice_list->push_back(v);
					}
				}
			}


		//////////
		// Load the public API
		//////
			// Type info
			if (FAILED(hr = pSapi->GetTypeInfo(0, LOCALE_USER_DEFAULT, &pTypeInfo)))
				return FALSE;

			// Type attributes
			if (FAILED(hr = pTypeInfo->GetTypeAttr(&pTypeAttr)))
			{
				pTypeInfo->Release();
				return FALSE;
			}

			// Enumerate all functions
			for (lnI = 0; lnI < pTypeAttr->cFuncs; ++lnI)
			{
				pFuncDesc = NULL;
				if (SUCCEEDED(hr = pTypeInfo->GetFuncDesc(lnI, &pFuncDesc)))
				{
					BSTR* bstrName = new BSTR[pFuncDesc->cParams + 1];
					cNames   = 0;
					if (SUCCEEDED(hr = pTypeInfo->GetNames(pFuncDesc->memid, bstrName, pFuncDesc->cParams + 1, &cNames)))
					{
						if (pFuncDesc->cParams > 0 && cNames == pFuncDesc->cParams + 1)
						{
							// Make sure we're not on an internal function
							llSkip  = false;
							llSkip |= (_wcsicmp(bstrName[0], L"QueryInterface")		== 0);
							llSkip |= (_wcsicmp(bstrName[0], L"GetTypeInfoCount")	== 0);
							llSkip |= (_wcsicmp(bstrName[0], L"GetTypeInfo")		== 0);
							llSkip |= (_wcsicmp(bstrName[0], L"GetIDsOfNames")		== 0);
							llSkip |= (_wcsicmp(bstrName[0], L"Invoke")				== 0);

							if (!llSkip)
							{
								// pass-1 -- Return parameters
								// pass-2 -- Other parameters
								for (lnPass = 1, llFoundRetVal = false; lnPass <= 2; ++lnPass)
								{
									// Show the function name at the start of pass 2
									if (lnPass == 2)
									{
										wsprintf(buffer, L"%s%s(", ((llFoundRetVal) ? L" = " : L""), bstrName[0]);
										builder += buffer;
									}

									// Show the parameters
									for (lnJ = 0; lnJ < pFuncDesc->cParams; ++lnJ)
									{
										// Get the description
										paramDesc = pFuncDesc->lprgelemdescParam[lnJ];

										if (lnPass == 1)
										{
											// We only show return parameters on pass-1
											if (paramDesc.paramdesc.wParamFlags & PARAMFLAG_FRETVAL)
											{
												// Show this one
												builder			+= L"[retval] ";
												llFoundRetVal	 = true;
												llShow			 = true; 

											} else {
												// Do not show this one
												llShow = false;
											}

										} else {
											// Add a comma between parameters
											if (lnJ != 0)
												builder += L", ";

											// Is it an input or output parameter?
											llShow = true;
											//if (paramDesc.paramdesc.wParamFlags & PARAMFLAG_FIN)		builder += L"[input] ";
											if (paramDesc.paramdesc.wParamFlags & PARAMFLAG_FOUT)		builder += L"[output] ";
											if (paramDesc.paramdesc.wParamFlags & PARAMFLAG_FRETVAL)	llShow   = false;
										}

										if (llShow)
										{
											// Show the type
											switch (paramDesc.tdesc.vt)
											{
												case VT_EMPTY:				builder += L"empty";							break;
												case VT_NULL:				builder += L"null";								break;
												case VT_I2:					builder += L"i2";								break;
												case VT_I4:					builder += L"i4";								break;
												case VT_I8:					builder += L"i8";								break;
												case VT_R4:					builder += L"r4";								break;
												case VT_R8:					builder += L"r8";								break;
												case VT_BSTR:				builder += L"bstr";								break;
												case VT_BOOL:				builder += L"bool";								break;
												case VT_DISPATCH:			builder += L"dispatch";							break;
												case VT_VARIANT:			builder += L"variant";							break;
												case VT_CY:					builder += L"cy";								break;
												case VT_DATE:				builder += L"date";								break;
												case VT_ERROR:				builder += L"error";							break;
												case VT_UNKNOWN:			builder += L"unknown";							break;
												case VT_DECIMAL:			builder += L"decimal";							break;
												case VT_I1:					builder += L"i1";								break;
												case VT_UI1:				builder += L"ui1";								break;
												case VT_UI2:				builder += L"ui2";								break;
												case VT_UI4:				builder += L"ui4";								break;
												case VT_UI8:				builder += L"ui8";								break;
												case VT_INT:				builder += L"int";								break;
												case VT_UINT:				builder += L"uint";								break;
												case VT_VOID:				builder += L"void";								break;
												case VT_HRESULT:			builder += L"hresult";							break;
												case VT_PTR:				builder += L"ptr";								break;
												case VT_SAFEARRAY:			builder += L"safearray";						break;
												case VT_CARRAY:				builder += L"carray";							break;
												case VT_USERDEFINED:		builder += L"userdefined";						break;
												case VT_LPSTR:				builder += L"lpstr";							break;
												case VT_LPWSTR:				builder += L"lpwstr";							break;
												case VT_RECORD:				builder += L"record";							break;
												case VT_INT_PTR:			builder += L"int_ptr";							break;
												case VT_UINT_PTR:			builder += L"uint_ptr";							break;
												case VT_FILETIME:			builder += L"filetime";							break;
												case VT_BLOB:				builder += L"blob";								break;
												case VT_STREAM:				builder += L"stream";							break;
												case VT_STORAGE:			builder += L"storage";							break;
												case VT_STREAMED_OBJECT:	builder += L"streamed_object";					break;
												case VT_STORED_OBJECT:		builder += L"stored_object";					break;
												case VT_BLOB_OBJECT:		builder += L"blob_object";						break;
												case VT_CF:					builder += L"cf";								break;
												case VT_CLSID:				builder += L"clsid";							break;
												case VT_VERSIONED_STREAM:	builder += L"versioned_stream";					break;
												case VT_BSTR_BLOB:			builder += L"bstr_blob";						break;
												case VT_VECTOR:				builder += L"vector";							break;
												case VT_ARRAY:				builder += L"array";							break;
												case VT_BYREF:				builder += L"byref";							break;
												case VT_RESERVED:			builder += L"reserved";							break;
												case VT_ILLEGAL:			builder += L"illegal";							break;
												default:					builder += L"Other %d" + paramDesc.tdesc.vt;	break;
											}

											// Add in the physical name of the parameter
											builder += L" ";
											if ((UINT)lnJ + 1 < cNames)
											{
												// Use the provided name
												builder += bstrName[lnJ + 1];

											} else {
												// An unknown name
												builder += L"unk";
											}
										}
									}

									// At the end of pass 2, we add this API entry to the list
									if (lnPass == 2)
									{
										// Finish out the syntax
										builder += L")";

										// Append it
										if ((a = (SAPI*)calloc(1, sizeof(SAPI))))
										{
											// Add this one
											a->api			= _wcsdup(builder.c_str());
											a->apiLength	= (s32)wcslen(a->api);
											api_list->push_back(a);
										}

										// Reset for next API function
										builder = L"";
									}
								}
							}
						}

						// Clean up
						pTypeInfo->ReleaseFuncDesc(pFuncDesc);
					}
				}
			}

			// Clean up
			pTypeInfo->Release();


		//////////
		// All done
		//////
			// We're good
			glSpeakInitialized = true;

			// Signify
			return TRUE;

	}


	// Returns the number of voices if successful, -1 if fail
	SPEAK_API s32 speak_initialize(void)
	{
		// Are we good?
		if (glSpeakInitialized)
			return (s32)voiceCount;

		// We're not there
		return -1;
	}




	// Returns the length of the string created for the voice text in output
	// -1 -- Not initialized
	// -2 -- Invalid voice #
	SPEAK_API s32 speak_get_voice_info(s32 voice, s8* output1024)
	{
		s32			lnI;
		SVoice*		v;
		s8*			ascii;

		std::list<SVoice*>::iterator	vi;


		// Are we good?
		if (!glSpeakInitialized)
			return -1;

		// Is the voice in range?
		if (voice >= 0 && voice <= (s32)voiceCount)
		{
			// Iterate through the linked list
			for (lnI = 0, vi = voice_list->begin(); vi != voice_list->end(); ++vi, ++lnI)
			{
				// If this is our index, then copy it
				if (lnI == voice && (v = *vi) && (ascii = (s8*)calloc(1, v->nameLength)))
				{
					// Convert content to ASCII
					wcstombs(ascii, v->name, v->nameLength);
					memcpy(output1024, ascii, min(1024, v->nameLength));
					free(ascii);
					return v->nameLength;
				}
			}
		}

		// Invalid
		return -2;
	}




	SPEAK_API s32 speak_text(const s8* text, s32 textLength)
	{
		wchar_t*	speechText;


		//////////
		// Are we good?
		//////
			if (!glSpeakInitialized)
				return -1;
			if (!text || textLength <= 0)
				return -2;


		//////////
		// Translate to unicode
		//////
			// Create our output variable
			if (!(speechText = (wchar_t*)calloc(1, (textLength + 2) * sizeof(wchar_t))))
				return -3;

			// Convert for speaking
			mbstowcs(speechText, text, textLength);


		//////////
		// Speak
		//////
			spVoice->Speak(speechText, SPF_DEFAULT, NULL);


		//////////
		// Clean up
		//////
			free(speechText);
			return textLength;

	}

	SPEAK_API s32 speak_text_file(const s8* filename)
	{
		s32		textLength, readLength;
		FILE*	fh;
		s8*		text;


		// See if the file exists
		fh = _fsopen(filename, "rb+", SH_DENYNO);
		if (fh == NULL)
			return -1;

		// Get the file size
		fseek(fh, 0, SEEK_END);
		textLength = ftell(fh);
		fseek(fh, 0, SEEK_SET);

		// Allocate memory for the text
		if (!(text = (s8*)calloc(1, textLength)))
		{
			fclose(fh);
			return -2;
		}

		// Read in the content
		readLength = fread(text, 1, textLength, fh);
		fclose(fh);
		if (readLength != textLength)
			return -3;

		// Speak
		speak_text(text, textLength);

		// Clean up
		free(text);

		// Signify how many characters were spoken
		return textLength;
	}




//////////
//
// Speaks text asynchronously in a separate thread
//
//////
	SPEAK_API s32 speak_text_async(const s8* text, s32 textLength, s32 uid)
	{
		SAsync*		a;


		// Are we good?
		if (!text || textLength <= 0)
			return -1;

		// Create an async structure
		if ((a = (SAsync*)calloc(1, sizeof(SAsync))))
		{
			if ((a->text = (s8*)calloc(1, textLength + 1)))
			{
				// Copy
				memcpy(a->text, text, textLength);
				a->isActive		= true;
				a->textLength	= textLength;
				a->uid			= uid;
				a->voice		= lastVoice;
				a->volume		= lastVolume;

				// Add it to our list
				EnterCriticalSection(&cs_async_list);
				{
					async_list->push_back(a);
				}
				LeaveCriticalSection(&cs_async_list);

				// Launch the thread to handle it in parallel
				a->hThread = CreateThread(NULL, 0, iiSpeak_text_async_thread, a, NULL, &a->nThreadId);
			}
		}

		// If we get here, error
		return -2;
	}

	SPEAK_API s32 speak_text_async_file(const s8* filename, s32 uid)
	{
		s32		textLength, readLength;
		FILE*	fh;
		s8*		text;


		// See if the file exists
		fh = _fsopen(filename, "rb+", SH_DENYNO);
		if (fh == NULL)
			return -1;

		// Get the file size
		fseek(fh, 0, SEEK_END);
		textLength = ftell(fh);
		fseek(fh, 0, SEEK_SET);

		// Allocate memory for the text
		if (!(text = (s8*)calloc(1, textLength)))
		{
			fclose(fh);
			return -2;
		}

		// Read in the content
		readLength = fread(text, 1, textLength, fh);
		fclose(fh);
		if (readLength != textLength)
			return -3;

		// Speak
		speak_text_async(text, textLength, uid);

		// Signify how many characters were spoken
		return textLength;
	}

	DWORD WINAPI iiSpeak_text_async_thread(LPVOID p)
	{
		HRESULT		hr;
		SAsync*		a;
		wchar_t*	speechText;


		// Get our pointer
		a = (SAsync*)p;

		// Create our instance
		if (SUCCEEDED(hr = ::CoInitialize(NULL)))
		{
			if (SUCCEEDED(hr = ::CoCreateInstance(CLSID_SpVoice, NULL, CLSCTX_ALL, IID_ISpVoice, (void**)&a->spVoice)))
			{
				// Convert the text to unicode
				if ((speechText = (wchar_t*)calloc(1, (a->textLength + 2) * sizeof(wchar_t))))
				{
					// Convert
					mbstowcs(speechText, a->text, a->textLength);

					// Setup the parameters
					iSpeak_setVoice(a->spVoice, a->voice);
					iSpeak_setVolume(a->spVoice, a->volume);

					// Begin speaking
					a->spVoice->Speak(speechText, SPF_DEFAULT, &a->streamNumber);
				}
			}
		}

		// When we get here, we're done
		iiSpeak_async_free(a);
		return 0;
	}

	SPEAK_API s32 speak_text_async_pause(s32 uid)
	{
		SAsync*		a;


		// See if it exists
		if ((a = iiSpeak_async_find(uid)) && a->isActive)
		{
			SuspendThread(a->hThread);
			return uid;
		}

		// If we get here, not found
		return -1;
	}

	SPEAK_API s32 speak_text_async_resume(s32 uid)
	{
		SAsync*		a;


		// See if it exists
		if ((a = iiSpeak_async_find(uid)) && a->isActive)
		{
			ResumeThread(a->hThread);
			return uid;
		}

		// If we get here, not found
		return -1;
	}

	SPEAK_API s32 speak_text_async_stop(s32 uid)
	{
		SAsync*		a;


		// See if it exists
		if ((a = iiSpeak_async_find(uid)) && a->isActive)
		{
			// Will stop when it is done
			TerminateThread(a->hThread, 0);
			iiSpeak_async_free(a, false);
			return uid;
		}

		// If we get here, not found
		return -1;
	}

	SAsync* iiSpeak_async_find(s32 uid)
	{
		bool		llFound;
		SAsync*		a;

		std::list<SAsync*>::iterator	ai;


		// Lock for the search
		EnterCriticalSection(&cs_async_list);
		{
			// Iterate through each entry
			for (llFound = false, ai = async_list->begin(); ai != async_list->end(); ++ai)
			{
				// Dereference
				a = *ai;
				if (a->isActive && a->uid == uid)
				{
					llFound = true;
					break;
				}
			}
		}
		LeaveCriticalSection(&cs_async_list);

		// Signify
		return ((llFound) ? a : NULL);
	}

	void iiSpeak_async_free(SAsync* a, bool tlSkipToEnd)
	{
		DWORD		lnSkipped;


		// Shut it off
		if (tlSkipToEnd)
			a->spVoice->Skip(L"SENTENCE", 999999, &lnSkipped);

		// And shut it down
		a->isActive = false;
		free(a->text);
	}




//////////
//
// Set the voice (from 0 to voiceCount)
//
//////
	SPEAK_API s32 speak_set_voice(s32 voice)
	{
		return iSpeak_setVoice(spVoice, voice);
	}

	s32 iSpeak_setVoice(CComPtr<ISpVoice> spVoice, s32 voice)
	{
		ULONG						count;
		HRESULT						hr;
		ISpObjectTokenCategory*		pCategory;
		IEnumSpObjectTokens*		pEnum;
		ISpObjectToken*				pVoiceToken;


		// Initialize
		pCategory = NULL;
		if (SUCCEEDED(hr = ::SpGetCategoryFromId(SPCAT_VOICES, &pCategory)))
		{
			pEnum = NULL;
			if (SUCCEEDED(hr = pCategory->EnumTokens(NULL, NULL, &pEnum)))
			{
				count = 0;
				pEnum->GetCount(&count);
				if (count > 0)
				{
					pVoiceToken = NULL;
					if (SUCCEEDED(hr = pEnum->Item(voice, &pVoiceToken)))
					{
						if (SUCCEEDED(hr = spVoice->SetVoice(pVoiceToken)))
						{
							lastVoice = voice;
							return voice;
						}
					}
				}
			}
		}

		// If we get here, invalid
		return -1;
	}




//////////
//
// Set the volume (from 0 to 100)
//
//////
	SPEAK_API s32 speak_set_volume(s32 volume_0_to_100)
	{
		return iSpeak_setVolume(spVoice, volume_0_to_100);
	}

	s32 iSpeak_setVolume(CComPtr<ISpVoice>spVoice, s32 volume)
	{
		USHORT	volumeNow;


		// Are we good?
		if (!glSpeakInitialized)
			return -1;

		// Set the volume, and get it back (the SAPI engine will truncate volume to ranges)
		spVoice->SetVolume(volume);
		spVoice->GetVolume(&volumeNow);
		lastVolume = volumeNow;

		// Signify
		return (s32)volumeNow;
	}
