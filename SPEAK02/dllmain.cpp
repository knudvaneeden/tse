//////////
//
// dllmain.cpp
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
//
// Main program entry point
//
//////
	//
	// If compiling using DbgExe
	#ifdef _USREXE
		int main(int argc, char* argv[])
		{
			int		voices;
			s8		buffer[1024] = { };

			const s8 cgcTestSpeech[] = "This is a test of the emergency broadcast system.";

			iSpeak_dll_initialize();
			voices = speak_initialize();
			speak_get_voice_info(0, buffer);
			speak_set_volume(100);
			speak_set_voice(0);
			speak_text(cgcTestSpeech, sizeof(cgcTestSpeech) - 1);
			printf("%d", voices);
		}
	#endif


	// If compiling using Debug or Release
	#ifdef _USRDLL
		BOOL APIENTRY DllMain( HMODULE hModule,
							   DWORD  ul_reason_for_call,
							   LPVOID lpReserved
							 )
		{
			switch (ul_reason_for_call)
			{
				case DLL_PROCESS_ATTACH:
					return iSpeak_dll_initialize();
					break;

				case DLL_THREAD_ATTACH:
				case DLL_THREAD_DETACH:
				case DLL_PROCESS_DETACH:
					break;
			}
			return TRUE;
		}
	#endif