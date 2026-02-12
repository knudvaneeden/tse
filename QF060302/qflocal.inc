/*
Program....: qflocal.inc
Version....: 3.5
Author.....: Randy Wallin & Ryan Katri
Date.......: 07/16/95  05:20 pm  Last Modified: 08/30/95 @ 08:10 am
Notice.....: Copyright 1995 COB System Designs, Inc., All Rights Reserved.
QFRestore..: ¯1,1®
Compiler...: TSE v2.5
Abstract...: Localization strings
Changes....:
ÛßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßÛ
Û This program is a part of a series of macros written by COB System DesignsÛ
Û for TSE/*Base users...these are not public domain but are for sale at a   Û
Û reasonable price of $69.00. Please support the work involved in writing   Û
Û these programs.                                                           Û
Û For sales information and technical support, call SEMWARE Corporation:    Û
Û                                                                           Û
Û MAIL: SemWare Corporation               FAX: (770) 640-6213               Û
Û       730 Elk Cove Court                                                  Û
Û       Kennesaw, GA  30152-4047  USA                                       Û
Û                                         InterNet: sales@semware.com       Û
Û                                                   qf.support@semware.com  Û
Û PHONE (SALES ONLY): (800) 467-3692      OTHER VOICE CALLS: (770) 641-9002 Û
Û          Inside USA, 9am-5pm ET                              9am-5pm ET   Û
ÛÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÛ
*/

// --- USED IN QF.S ---

string DECL_ADDED_LOC[] = "Added",
       DECL_DUPL_LOC[] = "Duplicate",
       NO_BLANKS_LOC[]  = "No more blanks to fill in",
       NO_FILEEXT_LOC[] = "File extension not supported",
       COMMENTED_LOC[]  = "Commented out",
       AT_LOC[]         = "at",
       NO_COMMENT_LOC[] = "Comment area must be marked first!",
       INIT_ROW_LOC[]   = "Initialize at row:",
       INIT_COL_LOC[]   = "Initialize at column:",
       CURR_POS_LOC[]   = "ð Current Row, Current Column",
       EXIT_LOC[]       = "Exited.",
       CHANGED_LOC[]    = "Changed on",
       NO_PROC_LOC[]    = "Not active in any procedure",
       NEW_FILE_LOC[]   = "Editing new file",
       OPEN_FILE_LOC[]  = "Open File",
       SAVED_LOC[]      = "Saved.",
       NO_SAVE_LOC[]    = "No need to save - unchanged.",
       NOT_SAVED_LOC[]  = "has not been saved to disk yet.",
       CFG_ENABLE_LOC[]   = "To enable Modifications, Save, Press Alt+F12",
       CFG_NOTFOUND_LOC[] = "not found. Please set QFPATH environment variable.",
       POS_RESTORED_LOC[] = "Position Restored"


// --- USED IN QFFLOW.S ---

string PROCESS_LINE_LOC[] = "Processing line",
       FINISHED_LOC[]     = "Finished Flowing!"



// --- USED IN QFDBF.S ---

string LOAD_LOC[]           = "Loading DBF structure. . .",
       NO_ACCESS_LOC[]      = "could not be accessed!",
       BAD_FORMAT_LOC[]     = "not a DBF format!",
       LOAD_DBF_LOC[]       = "DBF Structure for:",
       CANCEL_OPT_LOC[]     = "&Cancel",
       SCREEN_DBFOPT_LOC[]  = "&Screen Output",
       PRINTER_DBFOPT_LOC[] = "&Printer Output",
       FIELD_DBFOPT_LOC[]   = "Build &Field List",
       SQL_DBFOPT_LOC[]     = "Build SQL &Table",
       NONE_DBFFLD_LOC[]     = "&None",
       MDOT_DBFFLD_LOC[]     = "&M. Prefix",
       MARROW_DBFFLD_LOC[]   = "M-> &Prefix",
       ALIAS_DBFFLD_LOC[]    = "&Alias",
       USER_DBFFLD_LOC[]     = "&User Defined"

// --- USED IN QFEXPHLP.S ---

string EDIT_SAVE_EXPHLP_LOC[]   = "To enable Modifications, *Edit, Save*, Press Alt+F12",
       REINIT_EXPHLP_LOC[]      = "reinitialized",
       ERR_EXPHLP_LOC[]         = "QF.INI not found. Please set QFPATH environment variable.",
       NOINI_EXPHLP_LOC[]       = "No Qf.INI to evaluate.",
       BANNER_EXPHLP_LOC[]      = " þþþþþ Configuration Information Stored in QF.INI, select here to Edit þþþþþ",
       ASSIST_EXPHLP_LOC[]      = "þ Expansion - Abbreviation + [Space] or Alt+Backspace. á = Cursor Location.",
       GENERAL_EXPHLP_LOC[]     = "þ General Expansions -  Enter Abbreviation then press Alt+Backspace.",
       QFABBR_EXPHLP_LOC[]      = "QF Abbreviation Help For ",
       NOEXP_EXPHLP_LOC[]       = "No Expansion Help Found For This Extension."
