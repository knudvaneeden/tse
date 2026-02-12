/****************************************************************************
 *  FILENAME :  mffind.inc                                                  *
 *  VERSION  :  5.8 (for TSE Pro 2.50a)                                     *
 *  AUTHOR   :  Ray Asbury (rasbury@msmailpc01.saic.com)                    *
 *  COPYRIGHT:  1995 E. Ray Asbury, Jr.  All Rights Reserved Worldwide.     *
 *  DATE     :  Mon 11-20-1995 09:38:34                                     *
 *  FILES    :  mffind.inc      mffind2.inc     mffind.ini                  *
 *              mffind.s        mffind2.s       mffind3.s                   *
 *              mffind4.s       mffind5.s       mffind6.s                   *
 *                                                                          *
 *  PURPOSE  :  Shared file scope constants and variables                   *
 *                                                                          *
 *  REVISIONS:  WHO DATE        DESCRIPTION                                 *
 *              --- --------    ------------------------------------------  *
 *              [SEE REVISIONS LIST IN MFFIND.S]                            *
 *                                                                          *
 ****************************************************************************/

/****************************************************************************
 *  SECTION --> GLOBAL      Constants                                       *
 ****************************************************************************/

CONSTANT    koDEBUG                         = OFF,
            koDEBUG_HISTORIES               = OFF,
            //koDEBUG_HISTORIES               = ON,
            koASK                           = MAXINT,
            koDELETE                        = MAXINT - 0x01,
            koFIND                          = MAXINT - 0x02,
            koHIST_OWN                      = MAXINT - 0x03,
            koHIST_STD                      = MAXINT - 0x04,
            koREPLACE                       = MAXINT - 0x05,
            koVERIFY                        = MAXINT - 0x06,
            koOPT_INI_CHK                   = MAXINT - 0x07,
            koOPT_INI_CREATED               = MAXINT - 0x08,
            koOPT_INI_READ                  = MAXINT - 0x09,
            koOPT_PICK_FILE                 = MAXINT - 0x0A,

            /* MARK - ERA Mon 02-13-1995 18:26:57 ***************************
             *  ANY CHANGES TO THE FOLLOWING CONSTANTS MUST BE PROPOGATED   *
             *  TO MFFIND.S                                                 *
             ****************************************************************/

            koNBR_MAC_FILES                 = 6,
            koOPT_CONFIG_MFFIND             = 0x01,
            koOPT_DEL_LINES_BLNKS           = 0x02,
            koOPT_DEL_LINES_DUPS            = 0x03,
            koOPT_DEL_LINES_EXCLX           = 0x04,
            koOPT_DEL_LINES_INCLX           = 0x05,
            koOPT_FIND_CMNTS_BOTH           = 0x06,
            koOPT_FIND_CMNTS_C              = 0x07,
            koOPT_FIND_CMNTS_CPP            = 0x08,
            koOPT_FIND_CUR_WORD             = 0x09,
            koOPT_FIND_FCNS                 = 0x0A,
            koOPT_FIND_LINE_BLNKS           = 0x0B,
            koOPT_FIND_LINE_DUPS            = 0x0C,
            koOPT_FIND_LINE_EXCLX           = 0x0D,
            koOPT_FIND_LINE_INCLX           = 0x0E,
            koOPT_FIND_STR                  = 0x0F,
            koOPT_HIT_NEXT                  = 0x10,
            koOPT_HIT_PREVIOUS              = 0x11,
            koOPT_INIT_MFFIND               = 0x12,
            koOPT_PICK_AGAIN                = 0x13,
            KoOPT_REPLACE_STR               = 0x14,
            koOPT_SET_HISTORIES             = 0x15,
            koOPT_SHOW_HELP                 = 0x16

/****************************************************************************
 *  SECTION --> GLOBAL      String Variables                                *
 ****************************************************************************/

 /* THIS FOLLOWING VALUES SHOULD BE REFLECTED IN EACH FILE'S HEADER, AS
    WELL AS IN THE HELPDEF hdText, FOUND IN MFFIND2.S ***********************/

STRING      fsIniFile[]                     = "mffind.ini",
            fsMsgPrefix[]                   = "MFFind: ",
            fsTseVer[]                      = "2.50a",
            fsVer[]                         = "5.8"

/****************************************************************************
 *  SECTION --> GLOBAL      Integer Variables                               *
 ****************************************************************************/

/****************************************************************************
 *  SECTION --> GLOBAL      Include Files                                   *
 ****************************************************************************/

/****************************************************************************
 *  SECTION --> GLOBAL      Forward Declarations                            *
 ****************************************************************************/

/****************************************************************************
 *  SECTION --> GLOBAL      Data Definitions                                *
 ****************************************************************************/

/****************************************************************************
 *  SECTION --> GLOBAL      Help Definitions                                *
 ****************************************************************************/

/****************************************************************************
 *  SECTION --> GLOBAL      Key Definitions                                 *
 ****************************************************************************/

/****************************************************************************
 *  SECTION --> SYSPROC     WhenLoaded                                      *
 ****************************************************************************/

/****************************************************************************
 *  SECTION --> SYSPROC     WhenPurged                                      *
 ****************************************************************************/

/****************************************************************************
 *  SECTION --> SYSPROC     Main                                            *
 ****************************************************************************/

/****************************************************************************
 *  SECTION --> SYSPROC     Hooked Procedures                               *
 ****************************************************************************/

/****************************************************************************
 *  SECTION --> PROCS       Support Procedures                              *
 ****************************************************************************/

/****************************************************************************
 *  SECTION --> PROCS       User Procedures                                 *
 ****************************************************************************/

/****************************************************************************
 *  SECTION --> MENU        The Menus                                       *
 ****************************************************************************/

/****************************************************************************
 *  SECTION --> KEYS        Key Bindings                                    *
 ****************************************************************************/

