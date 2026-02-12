#include <windows.h>
#include "ScriptObject.h"

void WINAPI CallActX(HWND hCtrlWnd)
{
	LPTSTR lptstrCopy;
	HGLOBAL hglbCopy;

	// TODO: Test ScriptObject function
    CScriptObject m_ScriptObj;

	// Pass feedback to TSE via the clipboard
	OpenClipboard(hCtrlWnd);
	EmptyClipboard();
	hglbCopy = GlobalAlloc(GMEM_MOVEABLE, 17);
	lptstrCopy = (LPTSTR) GlobalLock(hglbCopy);
	memcpy(lptstrCopy, "Error Msg to TSE", 16);
	lptstrCopy[16] = (TCHAR) 0;
	GlobalUnlock(hglbCopy);
	SetClipboardData(CF_TEXT, hglbCopy);
	CloseClipboard();
}

/******************************** DllMain() ********************************
 * Automatically called by Win32 when the DLL is loaded or unloaded.
 */

extern "C"
BOOL WINAPI DllMain(HINSTANCE hinstDLL, DWORD fdwReason, LPVOID lpvReserved)
{
    switch(fdwReason)
	{
		/* ============================================================== */
		case DLL_PROCESS_ATTACH:
		{
			/*
			 * Here you would do any initialization that you want to do when
			 * the DLL loads. The OS calls this every time another program
			 * runs which uses this DLL. You should put some complementary
			 * cleanup code in the DLL_PROCESS_DETACH case.
			 */

            /* Initialize the OLE interface */
			if (OleInitialize(NULL)) return(0);
			break;
		}

		/* ============================================================== */
		case DLL_THREAD_ATTACH:
		{
			/* We don't need to do any initialization for each thread of
			 * the program which uses this DLL, so disable thread messages.
			 */
			DisableThreadLibraryCalls(hinstDLL);
			break;
		}

/*
		case DLL_THREAD_DETACH:
		{
			break;
		}
*/
		/* ============================================================== */
		case DLL_PROCESS_DETACH:
		{
			OleUninitialize();
		}
	}

	/* Success */
	return(1);
}
