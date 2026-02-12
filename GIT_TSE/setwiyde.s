FORWARD INTEGER PROC FNWindowGetScreenWidthI()
FORWARD PROC Main()
FORWARD PROC PROCWindowSetXY( INTEGER i1, INTEGER i2 )
FORWARD PROC PROCWindowSetXYDefault()


// --- MAIN --- //

PROC Main()
 PROCWindowSetXYDefault()
END

<F12> Main()

// --- LIBRARY --- //

// library: default <description></description> <version>1.0.0.0.19</version> <version control></version control> (filenamemacro=setwiyde.s) [<Program>] [<Research>] [kn, am, we, 23-02-2011 12:54:22]
PROC PROCWindowSetXYDefault()
 // e.g. PROC Main()
 // e.g.  PROCWindowSetXYDefault()
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 // PROCWindowSetXY( 10, 10 )
 //
 // PROCWindowSetXY( FNWindowGetScreenWidthI() / 2, FNWindowGetScreenHeightI() / 2 ) // old [kn, ri, we, 02-05-2012 11:36:51]
 //
 // PROCWindowSetXY( FNWindowGetScreenWidthI() / 3, FNWindowGetScreenHeightI() / 2 ) // new, translating it more central in the horizontal x-direction [kn, ri, we, 02-05-2012 11:36:57]
 //
 // PROCWindowSetXY( FNWindowGetScreenWidthI() / 3, FNWindowGetScreenHeightI() / 3 ) // new, translating it more central in the horizontal x-direction, translating it more upwards in the y-direction // new [kn, ri, we, 02-05-2012 11:36:57]
 //
 // PROCWindowSetXY( 29, 1 ) // new [kn, ri, fr, 06-01-2017 15:37:57]
 // PROCWindowSetXY( 98 * FNWindowGetScreenWidthI() / 100, FNWindowGetScreenHeightI() / 3 ) // new, translating it more central in the horizontal x-direction, translating it more upwards in the y-direction // new [kn, vo, we, 02-01-2019 12:54:20]
 // PROCWindowSetXY( 98 * FNWindowGetScreenWidthI() / 100, 0 ) // new [kn, ri, th, 02-01-2020 00:28:49]
 // using 'Center Popups' instead (in menu 'Options' > 'Full configuration' > 'Display/Color options' > 'Center popups'). Then save the configuration, otherwise you will have to redo it next restart of TSE.
 // do nothing
 //
 PROCWindowSetXY( 98 * FNWindowGetScreenWidthI() / 100, 1 ) // new [kn, ri, th, 02-04-2020 11:04:50]
 //
END

// library: window: set: x: y <description></description> <version>1.0.0.0.4</version> <version control></version control> (filenamemacro=setwixy.s) [<Program>] [<Research>] [kn, am, we, 23-02-2011 12:48:46]
PROC PROCWindowSetXY( INTEGER xI, INTEGER yI )
 // e.g. PROC Main()
 // e.g.  PROCWindowSetXY( 10, 10 )
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 INTEGER x1I = xI
 INTEGER y1I = yI
 //
 IF ( x1I <= 0 )
  x1I = 0
 ENDIF
 //
 IF ( y1I <= 0 )
  y1I = 0
 ENDIF
 //
 Set( X1, x1I )
 //
 Set( Y1, y1I )
 //
END

// library: window: get: screen: width: list <description></description> <version control></version control> <version>1.0.0.0.3</version> (filenamemacro=getwiwli.s) [<Program>] [<Research>] [kn, ri, su, 25-07-2010 14:18:53]
INTEGER PROC FNWindowGetScreenWidthI()
 // e.g. PROC Main()
 // e.g.  Message( FNWindowGetScreenWidthI() ) // gives e.g. 80
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( Query( windowCols ) - 2 )
 //
END
