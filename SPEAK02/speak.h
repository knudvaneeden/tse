//////////
//
// speak.h
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


struct SAsync;


//////////
// Simplified types
//////
	typedef char      s8;
	typedef short     s16;
	typedef int       s32;
	typedef long long s64;

	typedef unsigned char      u8;
	typedef unsigned short     u16;
	typedef unsigned int       u32;
	typedef unsigned long long u64;

	typedef float  f32;
	typedef double f64;


//////////
// Forward declarations
//////
	// Internal functions
	BOOL			iSpeak_dll_initialize				(void);
	DWORD WINAPI	iiSpeak_text_async_thread			(LPVOID p);
	SAsync*			iiSpeak_async_find					(s32 uid);
	void			iiSpeak_async_free					(SAsync* a, bool tlSkipToEnd = true);
	s32				iSpeak_setVoice						(CComPtr<ISpVoice> spVoice, s32 voice);
	s32				iSpeak_setVolume					(CComPtr<ISpVoice>spVoice, s32 volume);


//////////
// API exports
//////
	#define SPEAK_API __declspec(dllexport)
	extern "C"
	{

		//////////
		// BEGIN -- Publicly visible API functions for speak.s
		//////
			SPEAK_API s32		speak_initialize			(void);
			SPEAK_API s32		speak_get_voice_info		(s32 voice, s8* output1024);

			SPEAK_API s32		speak_text					(const s8* text, s32 textLength);
			SPEAK_API s32		speak_text_file				(const s8* filename);

			SPEAK_API s32		speak_text_async			(const s8* text, s32 textLength, s32 uid);
			SPEAK_API s32		speak_text_async_file		(const s8* filename, s32 uid);
			SPEAK_API s32		speak_text_async_pause		(s32 uid);
			SPEAK_API s32		speak_text_async_resume		(s32 uid);
			SPEAK_API s32		speak_text_async_stop		(s32 uid);

			SPEAK_API s32		speak_set_voice				(s32 voice);
			SPEAK_API s32		speak_set_volume			(s32 volume_0_to_100);
		//////
		// END -- Public API visible in speak.s
		//////////

	}; // extern "C"
