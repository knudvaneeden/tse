#ifdef _PROJDLL_H
#error _PROJDLL_H already defined!
#else
#define _PROJDLL_H
#endif



#define STRICT

#include <windows.h>
#include <shellapi.h>

#include <windowsx.h>

#include <stdio.h>
#include <stdlib.h>
#include <memory.h>
#include <dos.h>
#include <limits.h>


#ifdef DEBUG
#include <typeinfo.h>
#endif



enum {
	minIntVar = 1,
	iDatabaseId = minIntVar,
	iProjectId,
	iPathListId,
	iFListEnsured,
	iFNeedToEnsure,
	iFFirstRun,
	iCPrompts,
	iFDoingMenu,
	iFEverIdle,
	iFAutoLoad,
	iFOpenLast,
	iFPromptForProject,
	iFProjectTags,
	iFTimeoutHooked,
	iFAbandonEditor,
	iFInStartup,
	iFLocalProjects,
	iFIgnoreCase,
	iFAutoSave,
	maxIntVar };

enum {
	minStrVar = 101,
	iProjectFilename = minStrVar,
	iProjectTitle,
	iProjectExtensions,
	iTagsLocation,
	iProjDir,
	iTagFile,
	iBscFile,
	maxStrVar };



extern "C" __declspec(dllexport) long Get_Int(long iIntVar);


