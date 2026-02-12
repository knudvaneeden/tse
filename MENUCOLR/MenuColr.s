/*
   Macro:      MenuColr
   Author:     Carlo.Hogeveen@xs4all.nl
   Date:        2 sep 2003
   Version 2:  31 jan 2004

   This macro sets the two colors used as background colors in TSE menu's
   to the Windows menu background colors.

   These two colors are:
      The text          menu background color.
      The selected line menu background color.

   If these colors are used elsewhere in TSE, then they are changed there too.

   The result can be beautiful or horrible depending on your Windows- and TSE
   colors.

   An exception is made to reduce some horrible color combnations: the macro
   doesn't adjust a menu background color if it matches the text background
   color.

   It only works in a GUI version of TSE and therefore at least TSE 4.0.
   In the console mode version of TSE it does nothing if it is at least 4.0e.
   There is a free upgrade from TSE 4.0 to TSE 4.0e on Semware's website.

   Install:
      Put this macro in TSE's "mac" directory, compile it,
      and put it in TSE's Macro AutoloadList.
      It does its thing after each restart of TSE.

   Uninstall:
      Remove the macro from TSE's Macro AtoloadList.

   Notes for macro programmers:
      The undocumented TSE command SetSystemInfo was never intended for public
      use, and only works in TSE 4.0.

      TSE can show only 16 colors at once. TSE assigns those 16 colors to
      attributes, for instance to MenuTextAttr. The value of an attribute
      has the size of a byte: the upper 4 bits designate the background
      color and the lower 4 bits the foreground color. So an attribute has
      a value that says: <color1> letters on a <color2> background.
      This macro doesn't change the values of attributes. It changes the
      colors those attributes point to. And those colors can come from a
      range of 16,777,216 colors.
      The drawback for this macro is, that there are currently 79 attributes
      and still only 16 colors to point to, so multiple attributes will point
      to the same colors. So, changing the colors used for the menu background
      may have side-effects.

   History:
      Version 1,  2 sep 2003.
         Initial version for the GUI version of TSE 4.0.
         Was published in the TSE PRo mailing list as WinColr2.
      Version 2, 31 jan 2004.
         Adapted the macro to also work with the GUI version
         of higher versions of TSE, like TSE 4.2.
*/

#ifdef EDITOR_VERSION
   #if EDITOR_VERSION - 3000h
      #define EDITOR_VERSION_OK TRUE   // TSE version >= 4.00
   #else
      #define EDITOR_VERSION_OK FALSE  // TSE version == 3.00
   #endif
#else
   #define EDITOR_VERSION_OK FALSE     // TSE version <  3.00
#endif

#if EDITOR_VERSION_OK
   // TSE version >= 4.0

   //      Windows.H Definition  Value  Description
   // -------------------------------------------------------
   #define COLOR_SCROLLBAR         0   // Scroll-bar gray area
   #define COLOR_BACKGROUND        1   // Desktop
   #define COLOR_ACTIVECAPTION     2   // Active Window caption
   #define COLOR_INACTIVECAPTION   3   // Inactive Window caption
   #define COLOR_MENU              4   // menu background
   #define COLOR_WINDOW            5   // Window background
   #define COLOR_WINDOWFRAME       6   // Window frame
   #define COLOR_MENUTEXT          7   // Text in menus
   #define COLOR_WINDOWTEXT        8   // Text in windows
   #define COLOR_CAPTIONTEXT       9   // Text in caption, size box,
                                       //    scroll bar arrow box
   #define COLOR_ACTIVEBORDER      10  // Active Window border
   #define COLOR_INACTIVEBORDER    11  // Inactive Window border
   #define COLOR_APPWORKSPACE      12  // Background Color of multiple
                                       //    document interface (MDI)
                                       //    applications
   #define COLOR_HIGHLIGHT         13  // Items selected item in a control
   #define COLOR_HIGHLIGHTTEXT     14  // Text of item selected in a control
   #define COLOR_BTNFACE           15  // Face shading ON push button
   #define COLOR_BTNSHADOW         16  // Edge shading ON push button
   #define COLOR_GRAYTEXT          17  // Grayed (disabled) text. This
                                       //    color is set to 0 if the
                                       //    current display driver does not
                                       //    support a solid gray color.
   #define COLOR_BTNTEXT           18  // Text ON push buttons

   dll "<user32.dll>"
       integer proc GetSysColor(integer windows_object)
   end


   #if EDITOR_VERSION - 4000h
      // TSE version >= 4.2
      integer proc bgr_to_rgb(integer bgr)
         integer b   = bgr  / (256 * 256)
         integer bg  = bgr  /  256
         integer g   = bg  mod 256
         integer r   = bgr mod 256
         integer rgb = r * 256 * 256 + g * 256 + b
         return(rgb)
      end
   #else
      // TSE version == 4.0
   #endif

   proc WhenLoaded()
      if isGUI()
         #if EDITOR_VERSION - 4000h
            // TSE version >= 4.2
            if Query(MenuTextAttr) / 16 <> Query(TextAttr) / 16
               SetColorTableValue(_BACKGROUND_, Query(MenuTextAttr)   / 16 , bgr_to_rgb(GetSysColor(COLOR_MENU)))
               SetColorTableValue(_foreground_, Query(MenuTextAttr)   / 16 , bgr_to_rgb(GetSysColor(COLOR_MENU)))
            endif
            if Query(MenuSelectAttr) / 16 <> Query(TextAttr) / 16
               SetColorTableValue(_BACKGROUND_, Query(MenuSelectAttr) / 16 , bgr_to_rgb(GetSysColor(COLOR_HIGHLIGHT)))
               SetColorTableValue(_foreground_, Query(MenuSelectAttr) / 16 , bgr_to_rgb(GetSysColor(COLOR_HIGHLIGHT)))
            endif
         #else
            // TSE version == 4.0
            if Query(MenuTextAttr) / 16 <> Query(TextAttr) / 16
               SetSystemInfo(0, 1, Query(MenuTextAttr)   / 16 , GetSysColor(COLOR_MENU))
               SetSystemInfo(0, 2, Query(MenuTextAttr)   / 16 , GetSysColor(COLOR_MENU))
            endif
            if Query(MenuSelectAttr) / 16 <> Query(TextAttr) / 16
               SetSystemInfo(0, 1, Query(MenuSelectAttr) / 16 , GetSysColor(COLOR_HIGHLIGHT))
               SetSystemInfo(0, 2, Query(MenuSelectAttr) / 16 , GetSysColor(COLOR_HIGHLIGHT))
            endif
         #endif
         UpdateDisplay(_ALL_WINDOWS_REFRESH_)
      endif
      PurgeMacro(SplitPath(CurrMacroFilename(), _NAME_))
   end
#else
   // TSE version < 4.0
   proc WhenLoaded()
      string macro_name [255] = SplitPath(CurrMacroFilename(), _NAME_)
      Warn("Macro ", macro_name, " needs at least TSE 4.0 ")
      PurgeMacro(macro_name)
   end
#endif

