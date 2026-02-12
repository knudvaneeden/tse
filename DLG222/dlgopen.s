/****************************************************************************\

    DlgOpen.S

    Enhanced OpenFile command (compile wrapper).

    Version         v2.21/19.11.03
    Copyright       (c) 1995-2003 by DiK

    Overview:

    This macro implements EditFile as a Windows style dialog box.
    See ScOp16W.SI or ScOp32W.SI for details.

    History

    v2.21/19.11.03  adaption to TSE32 v4.2
    v2.20/25.02.02  adaption to TSE32 v4.0
    v2.10/30.11.00  adaption to TSE32 v3.0
    v2.02/07.01.99  optimization
    v2.00/24.10.96  first version (of wrapper)

\****************************************************************************/

#ifndef WIN32
    #include ["ScOp16W.SI"]
#else
    #include ["ScOp32W.SI"]
#endif

