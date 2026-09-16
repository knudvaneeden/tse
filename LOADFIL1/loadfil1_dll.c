/*
 * LOADFIL1.DLL 1.0.0.0.5 - 2026-09-16
 * Win32 drive enumeration adapter for the TSE LOADFILE macro.
 * Build target: Borland C++ 5.5.1, 32-bit Windows.
 */

#include <windows.h>

#define LOADFIL1_VERSION "1.0.0.0.5"

static DWORD driveMask = 0;
static int nextDriveNumber = 1;
static char volumeLabel[64];
static int nextLabelPosition = 0;

int __pascal LFResetDriveScan(void)
{
    driveMask = GetLogicalDrives();
    nextDriveNumber = 1;
    volumeLabel[0] = '\0';
    nextLabelPosition = 0;
    return driveMask != 0;
}

int __pascal LFNextDrive(void)
{
    char rootPath[4];
    DWORD oldErrorMode;
    int driveNumber;

    while (nextDriveNumber <= 26)
    {
        driveNumber = nextDriveNumber;
        ++nextDriveNumber;

        if (driveMask & (1UL << (driveNumber - 1)))
        {
            rootPath[0] = (char)('A' + driveNumber - 1);
            rootPath[1] = ':';
            rootPath[2] = '\\';
            rootPath[3] = '\0';
            volumeLabel[0] = '\0';
            nextLabelPosition = 0;

            oldErrorMode = SetErrorMode(SEM_FAILCRITICALERRORS |
                                        SEM_NOOPENFILEERRORBOX);
            GetVolumeInformationA(rootPath, volumeLabel,
                                  sizeof(volumeLabel), NULL, NULL,
                                  NULL, NULL, 0);
            SetErrorMode(oldErrorMode);

            return driveNumber;
        }
    }

    volumeLabel[0] = '\0';
    nextLabelPosition = 0;
    return 0;
}

int __pascal LFNextLabelChar(void)
{
    unsigned char character;

    character = (unsigned char)volumeLabel[nextLabelPosition];
    if (character == 0)
        return 0;

    ++nextLabelPosition;
    return (int)character;
}

BOOL WINAPI DllEntryPoint(HINSTANCE instance, DWORD reason, LPVOID reserved)
{
    (void)instance;
    (void)reason;
    (void)reserved;
    return TRUE;
}
