/****************************************************************************
 *  FILENAME :  clist.s                                                     *
 *  VERSION  :  4.1 (for TSE 2.00)                                          *
 *  AUTHOR   :  Ray Asbury (rasbury@msmailpc01.saic.com)                    *
 *  DATE     :  Mon 09-26-1994 19:00:33                                     *
 *  PURPOSE  :  CallList is designed for application developers to use as   *
 *              an analysis tool when developing in either SAL or C.  See   *
 *              "CLIST.DOC" for usage instructions.                         *
 *                                                                          *
 *  Copyright 1994 E. Ray Asbury, Jr.           ALL RIGHTS RESERVED         *
 *                                                                          *
 *  REVISIONS:  WHO DATE        DESCRIPTION                                 *
 *              --- --------    ------------------------------------------  *
 *              ERA 01-22-93    Added gCL_MapFileAltLoc to allow specifying *
 *                                  an alternate location to search for MAP *
 *                                  files                                   *
 *                              Included proc/command arguments in calls,   *
 *                                  provided the proc/command name and args *
 *                                  does not exceed 37 characters in Length *
 *                              Bumped version to "2.0"                     *
 *              ERA 02-03-93    Re-compiled for use with TSE .65с           *
 *                              Bumped version to "2.1"                     *
 *              ERA 02-15-93    Fixed mismatching of calls with MAP file    *
 *                                  data where the name of the called proc/ *
 *                                  command was a subset of another which   *
 *                                  was found in the MAP file.              *
 *                              Bumped version to "2.2"                     *
 *              ERA 02-17-93    Fixed MAP file conflict when proc has the   *
 *                                  same name as the SAL file               *
 *                              Included ability for user to set whether to *
 *                                  consider case when sorting              *
 *                              Bumped version to "2.3"                     *
 *              ERA 03-03-93    Re-compiled for TSE .67с                    *
 *                              Bumped version to "2.4"                     *
 *              ERA 03-05-93    Re-compiled for TSE .68с                    *
 *                              Bumped version to "2.5"                     *
 *              ERA 03-24-93    Re-compiled for TSE .72с                    *
 *                              Bumped version to "2.6"                     *
 *              ERA 03-26-93    Re-compiled for TSE .73с                    *
 *                              Bumped version to "2.7"                     *
 *              ERA 03-26-93    Re-compiled for TSE 1.00x                   *
 *                              Bumped version to "2.8"                     *
 *              ERA 04-07-93    Added support for C language files          *
 *                              Bumped version to "2.9"                     *
 *              ERA 05-10-93    Re-wrote I/O between CHKSAL & CHKANSIC for  *
 *                                  consistency                             *
 *                              Bumped version to "3.0"                     *
 *              ERA 10-05-93    Re-compiled for TSE 1.00r                   *
 *                              Bumped version to "3.1"                     *
 *              ERA 10-13-93    Re-compiled for TSE 1.00u                   *
 *                              Bumped version to "3.2"                     *
 *              ERA 10-26-93    Re-compiled for TSE 1.00z                   *
 *                              Bumped version to "3.3"                     *
 *              ERA 05-04-94    Re-compiled for TSE 1.52b                   *
 *                              Bumped version to "3.4"                     *
 *              ERA 06-19-94    Re-compiled for TSE 1.53b                   *
 *                              Bumped version to "3.5"                     *
 *              ERA 08-04-94    Fix mis-spelling in prompt strings          *
 *                              Bumped version to "3.6"                     *
 *              ERA 08-08-94    Changed symbols to my conventions           *
 *                              Bumped version to "3.7"                     *
 *              ERA 09-04-94    Re-compiled for TSE 1.60a                   *
 *                              Bumped version to "3.8"                     *
 *              ERA 09-09-94    Add supported for nested function calls     *
 *                              Bumped version to "3.9"                     *
 *              ERA 09-16-94    Re-compiled for TSE 2.00                    *
 *                              Bumped version to "4.0"                     *
 *              ERA 09-26-94    Added section to remove DATADEF's,          *
 *                                  HELPDEF's and KEYDEF's before           *
 *                                  processing                              *
 *                              Re-wrote comment & quoted string sripper    *
 *                              Bumped version to "4.1"                     *
 ****************************************************************************/

CONSTANT    koCL_IGNORE_CASE = 1,
            koCL_DONT_IGNORE_CASE = 2

PROC Main()

    SetGlobalStr("giCL_WordSet", ChrSet("0-9A-Z_a-zА-ер-ю"))

        // MODIFY THE ABOVE LINE, IF NEEDED, AS NOTED ABOVE IN THE
        // DOCUMENTATION

        // MAXIMUM Length OF gCL_WordSet IS 255 CHARACTERS

    SetGlobalInt("giCL_UseMapFile", 2)

        // MODIFY THE ABOVE LINE TO DETERMINE WHETHER THE MAP FILE WILL BE
        // USED, WHERE gCL_UseMapFile = 0 FOR NO MAP FILE USAGE,
        //             gCL_UseMapFile = 1 FOR AUTOMATIC MAP FILE USAGE
        //             gCL_UseMapFile = 2 ASK WHETHER TO USE A MAP FILE EVERY
        //                                TIME CallList IS EXECUTED

    SetGlobalStr("giCL_MapFileAltLoc", "C:\")

        // MODIFY THE ABOVE LINE TO SPECIFY AN ALTERNATE LOCATION FOR MAP
        // FILES.  CALLLIST LOOKS FIRST IN THE SAME DIRECTORY AS THE SAL FILE
        // BEING, PROCESSED.  IF A MAP FILE ISN'T FOUND THERE, IT WILL THEN
        // LOOK IN THE DIRECTORY SPECIFIED ABOVE.

        // MAXIMUM Length OF gCL_MapFileAltLoc IS 68 CHARACTERS

    SetGlobalInt("giCL_SortSensitive", koCL_DONT_IGNORE_CASE)

        // MODIFY THE ABOVE LINE TO SPECIFY WHETHER SORTING SHOULD BE CASE
        // SENSITIVE (koCL_DONT_IGNORE_CASE) OR NOT (koCL_IGNORE_CASE)

    CASE SplitPath(CurrFileName(), _EXT_)
        WHEN ".c", ".cpp", ".h", ".pc"
            ExecMacro("CLIST2")
        WHEN ".s", ".ui"
            ExecMacro("CLIST3")
    ENDCASE

    // MODIFY THE ABOVE TO INCLUDE/EXCLUDE THE APPROPRIATE FILE
    // EXTENSIONS FOR YOUR C AND SAL SOURCE FILES

    PurgeMacro(CurrMacroFileName())
END Main