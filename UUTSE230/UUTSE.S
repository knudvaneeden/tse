/**************************************************************************/
/*                                                                        */
/*   UU/XX/MIME64 menu macro for TSE 2.50 Pro, TSE32 2.80                 */
/*                                                                        */
/*   version 2.30 - by Fabio Ferrero - 1997                               */
/*                                                                        */
/**************************************************************************/

// Uncomment next line to fast macro in-memory call!
//#define FAST    TRUE

#ifndef WIN32
menu selencdec()
    Title= "Select decode/encode"
    History= 1

    "&Decode",      execmacro("uudec.mac")
    "&Encode",      execmacro("uuenc.mac")
end
#else
menu selencdec()
    Title= "Select decode/encode"
    History= 1

    "&Decode",      execmacro("uudec32.mac")
    "&Encode",      execmacro("uuenc32.mac")
end
#endif

proc whenloaded()
    message("Ctrl-Shift-M call UUtse menu, Ctrl-Shift-E encode, Ctrl-Shift-D decode")
#ifdef FAST
#ifndef WIN32
    loadmacro("uudec.mac")
    loadmacro("uuenc.mac")
#else
    loadmacro("uudec32.mac")
    loadmacro("uuenc32.mac")
#endif
#endif
end

#ifndef WIN32
<ctrlshift e> execmacro("uudec.mac")
<ctrlshift d> execmacro("uuenc.mac")
#else
<ctrlshift e> execmacro("uudec32.mac")
<ctrlshift d> execmacro("uuenc32.mac")
#endif
<ctrlshift m> selencdec()

