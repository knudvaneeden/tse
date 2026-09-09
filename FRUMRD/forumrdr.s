/**********************************************************************
procedure==>  vmForumReader () 1.1 <==by Volker Multhopp  05/27/93

    A suite of procedures to read (and edit) CompuServe forum messages which
    have been captured to the current file.

    IMPORTANT NOTE!     FOR SUCCESSFUL OPERATION, THIS PROGRAM EXPECTS THAT
    <ALT V> CALLS MCOMPRESSVIEW.  SEE COMMENTS BELOW.


    returns: 0 for problem with procedure, otherwise 1.  Details depend on
             sub-procedure.


    A.  Table of Contents
              ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
              ³ B.  The Help Screen                            ³
              ³ C.  Short Description of Options / Instructions³
              ³ D.  Comments                                   ³
              ³     1. Compressed Views                        ³
              ³     2. Threads                                 ³
              ³     3. Composing replies off-line              ³
              ³     4. One Procedure ?                         ³
              ³ E.  Caveats                                    ³
              ³ F.  Attributions                               ³
              ³ G.  Revision History                           ³
              ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ



    B.  The Help Screen

        ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ vmForumReader 1.1 help ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        ³    Press <centercursor> then . . .                         ³
        ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
        ³ <Home>    Find ultimate origin of this msg.                ³
        ³  <>      Find msg. to which this msg. is replying.        ³
        ³  <>      Find 1st reply to this msg.                      ³
        ³ <End>     Declare this msg. origin of current thread.      ³
        ³  <>      Find next msg. in declared thread.               ³
        ³ <PgUp>    Previous msg.  ³  <>   To start of this msg.    ³
        ³ <PgDn>    Next msg.      ³ <Del>  Delete this msg.         ³
        ³  <F1>     This help.     ³  <R>   Reply to this msg.       ³
        ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Compressed Views ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
        ³ <N>  #:/Sec. lines.³ <^N>    Current section.              ³
        ³ <S>    Sb: lines.  ³ <^S>    Same subject-  Sb: lines.     ³
        ³ <F>    Fm: lines.  ³ <^F>    References to Fm:person's id. ³
        ³ <T>    To: lines.  ³ <^T>    References to To:person's id. ³
        ³            <W>    the Word at the cursor.                  ³
        ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ



    C.  Short Description of Options / Instructions

        Load your CIS capture file into the TSE editor, and load the FORUMRDR
    macro (order unimportant).

      THIS PROGRAM DOES NOT INTERFERE WITH ANY NORMAL EDITING FUNCTIONS,
              EXCEPT THAT IT TAKES OVER THE <CENTERCURSOR> KEY.

    Always press <centercursor> first to initiate any action.  Then press:

      -key-                     -action-
      <Home>    Finds the ultimate origin of this message.  Like repeatedly
                    using the <> option.
       <>      Finds the message to which this message is replying.
       <>      Finds 1st reply to this message.

      <End>     Declares this message to be origin of current thread.  See the
                    discussion on threads in the Comments section.
       <>      Next message in declared thread.  See Comments.
      <PgUp>    Previous message.
      <PgDn>    Next message.
       <F1>     The help screen.
       <>      To start of this message. I.e. see header if scrolled off.
      <Del>     Delete this message.
       <R>      Reply to this message off-line.  See discussion below.

         ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Compressed Views ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
      ( see the discussion on Compressed Views in the Comments section )
       <N>      #:/Sec. lines.
       <S>      Sb: lines.
       <F>      Fm: lines.
       <T>      To: lines.
       <^N>     Current section.
       <^S>     Same subject-  Sb: lines.
       <^F>     References to Fm:person's id.
       <^T>     References to To:person's id.
       <W>      the Word at the cursor.



    D.  Comments

         1. Compressed Views

            The program expects to be able to call mCompressView(0) with the
        <alt v> key.  If you have re-assigned that call to another key, find
        the line of code containing <alt v>, and change the key designation to
        the key which does make the mCompressView(0) call.  If the call is
        assigned to a two-key, you'll have to have another pushkey(), and
        enter the key designations in reverse order!

            If you are not familiar with mCompressView, it is worthwhile
        getting acquainted with this powerful little feature.  When called, it
        creates a visible buffer of all lines in the calling file which
        contain a given string.  You can move the highlight bar through the
        buffer, hit <enter>, and you are released back to the calling file at
        that line.  You can move the highlight, either with cursor keys, or
        you can start typing, and the procedure will do an incremental search
        for the string you are typing.

            Incidently, it is not hard to modify mCompressView().  Originally
        it only comes with  two "views" depending on the calling argument-- 0
        or 1.  With a little tinkering you can add options 2, 3,... .   Perhaps
        add a compressed view of the word at cursor like this program does.



         2. Threads

            Thread is an unfortunate word, understandable in terms of picking
        up the "thread" of a conversation, but inapt for describing what is an
        upside-down tree.  Going up a thread is an unambiguous activity; every
        message can be responding (officially) to only one other message.  On
        the other hand, one message can provoke plenty of replies.  Going down
        a thread, one is ideally confronted by a maze-like series of branching
        opportunities.  This program (I hope I got it right!) deals with each
        branching opportunity by going down the 'first' unexplored branch
        first.  When it can go no further by this means, it crawls back up
        until it comes to another unexplored branch, where it once again goes
        downward.  This continues until all branches have been explored, and
        the tree is exhausted.

            This program requires that you "DECLARE" the start of a thread
        with the <end> key.  If you want to start at the 'begining' of the
        thread that you are currently reading, use the <home> option first.
        Using the <> option will go to the next untraced msg. in the declared
        thread, regardless of where the cursor is currently!

            Note:  You can move messages around in the file without disturbing
        threads; the program uses global searches in all its traces.  This
        great flexibility comes at the cost of a certain slowness of
        operation.

            If your thread is broken, using the <ctrl S> option may help you
        pick up on the conversation.

            NOTE:  You should go to the Options area of the forum, and make
        sure you do NOT skip messages you left-- otherwise the threads will be
        broken at the most critical locations, namely there, where you,
        auteur extraordinaire, left your little gems.



         3. Composing replies off-line

            Many users will find this a useless benefit, but some may want to
        use it and not fully understand how this works, so I'll explain--

            When the <R> option is chosen, a new file is opened.  Jot down the
        name of the new file.  It will be something short like 'R1' or 'R2'.
        Write your reply to the current message between the 'reply nnn' and
        '/exit' lines.  Save the file.  When you are back on-line with
        CompuServe, and in the correct forum, tell your communications
        software that you want to send (or upload) an ASCII file.  Often this
        is done by pressing the <PgUp> key.  The program may ask for the
        protocol (ASCII), and will ask for the filename of the file to be
        sent.  Give the name you jotted down.  Lines will start appearing on
        the screen.  CompuServe may seem like it's hopelessly garbled.

            ( If unexpected line numbers appear, you are using CIS's LINEDIT,
        that's ok, but slow and clumsy.  You should go to the forum's Options
        area, or GO PROFILE and select CIS's EDIT as your on-line editor. )

            ( Your comm. software must be able to 'find' the Rn file.  That
        may mean that you'll have to adjust its "Upload Directory", or move
        the "Rn" files. )

            ( If you're working in a multitasking or windowed environment like
        Desqview, don't forget that you have to save the Rn file in one
        window, before sending it in another. )

            ( You can reduce the the degree to which CIS seems to fall behind
        during an ASCII upload-- if your software allows adjusting something
        called ASCII line pacing.  Usually you give a bigger number to slow
        down output.  Actually CIS loads all your output into a buffer, then
        deals with it at its own leisurely pace.  It will (almost always) get
        things straight. )

            ( Don't forget that you have to be in the correct forum, before
        you upload the Rn file! )

            Anyway, eventually CIS will finish digesting your output, and will
        post your msg. to the correct party with the correct subject and
        section.

            How does this work?  The first line, "mes", of the Rn file tells
        the forum that you want to go the message board area.  The "reply nnn"
        line says you want to compose a reply to message number nnn.  Then
        comes your text.  And, of course, the "/exit" signals that you've
        finished composing.

            You should delete your "Rn" files after you've used them, so the
        program won't waste too much time looking for good, unused filenames.

            One more thing.  The message to which you're replying must still
        exist, otherwise CIS will get really confused.  On a busy board, you
        might want to do a "RI nnn" command (Read Individual) first, where nnn
        is the number of the message to which you're replying, just to make
        sure the msg. hasn't scrolled off or been deleted.



         4. One Procedure ?

            Aside from the unimportant WhenLoaded() procedure, this is all
        just one procedure.  That isn't good practice, but for me it became
        something of mental challenge, or maybe an interesting puzzle.



    E.  Caveats

         1.  Be careful using the <del> option.  Everything from the current
        msg. header to the next msg. header will be deleted without warning.
        It cannot recognize that intervening text may not be msg. material.
        However, the UnDelete command should restore any lost material.

         2.  If your capture file contains messages from several different
        forums, there is a small but real chance that when tracing threads,
        you'll get cross-linked, and end up in different forum.  No bodily
        harm.

         3.  If the header data in a message has been altered, the program
        probably will not recognize it as such.  The program will treat the
        message and damaged header as part of the text of the preceding
        message.

         4.  Threads may be broken in the likely event you haven't captured
        every message in the thread.  The program will not be able to span the
        missing links as it tries to follow a thread.  But if you use the <^S>
        option, you may well be able to find where a lost thread re-continues.

          5.  If you use the reply off-line feature, be sure to read the
         special caveats listed in the appropriate Comments section.


    F.  Attributions

        CIS and CompuServe refer to CompuServe Inc.
        TSE is a product of SemWare Inc.
        This program, vmForumReader, aka FORUMRDR and FRUMRD, may be copied
            for free only; all other rights retained by author,
                                      --Volker Multhopp, cis id 71161,2044.

    G.  Revision History

        1.0 Uploaded to CIS

        1.1 Fixed problem (more or less) where the ^S option wouldn't work
        properly if there were regular expression special characters imbedded
        in the message subject.


**********************************************************************/
/**********************************************************************
    Extra-procedural variables.
     Since vmForumReader recursively calls itself, there are
     a large number of non-in-procedure variables.
**********************************************************************/
integer
flag = 0,
xflag = 0,
tree = 0,
capfile = 0,
headerline = 0,
saveline = 0

string
msgno[9] = '',      // current msg. no
savemsgno[9] = '',
subject[36] = '',   //    "     "   subject
section[15] = '',
fmid[13] = '',    // cis id of sender of current msg.
toid[13] = '',      // cis id of addressee (to person) of curr msg.
parentno[9] = '',    // no of msg. to which the current msg. is replying
xparentno[9] = '',
warnstr[42] = ''


/**********************************************************************
    The Help screen.
**********************************************************************/

menu vmForumReaderhelp()
    title = "vmForumReader 1.1 help"
    "   Press <centercursor> then . . ."
    "",,divide
    "<Home>    Find ultimate origin of this msg."
    " <>      Find msg. to which this msg. is replying."
    " <>      Find 1st reply to this msg."
    "<End>     Declare this msg. origin of current thread."
    " <>      Find next msg. in declared thread."
    "<PgUp>    Previous msg.  ³  <>   To start of this msg."
    "<PgDn>    Next msg.      ³ <Del>  Delete this msg."
    " <F1>     This help.     ³  <R>   Reply to this msg."
    "Compressed Views",,divide
    "<N>  #:/Sec. lines.³ <^N>    Current section."
    "<S>    Sb: lines.  ³ <^S>    Same subject-  Sb: lines."
    "<F>    Fm: lines.  ³ <^F>    References to Fm:person's id."
    "<T>    To: lines.  ³ <^T>    References to To:person's id."
    "           <W>    the Word at the cursor."

end


/**********************************************************************
    At last!  The coding finally begins.
**********************************************************************/

integer  proc vmForumReader (string CallingArg)

    integer
    i

    string
    arg[2] = CallingArg,
    cis_id[13] = '[0-9]#,[0-9]#',
    findstr[40] = '',
    findops[5] = '',
    nomore[42] =    'No more valid messages in this direction. ',
    notfound[37] =  'Sought msg. not found / not existent.',
    badbuff[26] =   'Bad buffer / System error.',
    trcing[20] =    'Tracing thread . . .'

    if arg == ''    // user calling
        message
        ('vmForumReader:  Home   End  PgUp PgDn  F1 Del  R W [^:] N S F T')

        case getkey()               // find out what he wants
            when <pgup>             arg = 'pu'
            when <pgdn>             arg = 'pd'
            when <home>             arg = 'ho'
            when <end>              arg = 'en'
            when <cursorup>         arg = 'up'
            when <cursordown>       arg = 'dn'
            when <cursorright>      arg = 'rt'
            when <cursorleft>       arg = 'al'
            when <w>, <W>           arg = 'w'
            when <n>, <N>           arg = 'n'
            when <r>, <R>           arg = 're'
            when <s>, <S>           arg = 'Sb'
            when <f>, <F>           arg = 'Fm'
            when <t>, <T>           arg = 'To'
            when <del>              arg = 'de'
            when <ctrl n>           arg = '^n'
            when <ctrl s>           arg = '^s'
            when <ctrl t>           arg = '^t'
            when <ctrl f>           arg = '^f'
            when <i>                arg = 'i'
            when <f1>, <h>, <H>, <centercursor>
                                    arg = 'f1'
            otherwise
                updatedisplay()
                return(0)
        endcase
        updatedisplay (_statusline_refresh_)
    endif

    // Save some user stuff
    pushposition()
    pushblock()
    if isBlockMarked()
        unmarkBlock()
    endif
    // all exits must clear the values off the stacks.

    // this is the great re-direction
    // lots of sub-procedures here, some are only for internal use.
    case arg
        when 'f1'   vmForumReaderhelp()
        when 'al'   goto align
        when 'dr'   goto dressout
        when 'v'    goto verify
        when 'en'   goto anchorthread
        when 'rt'   goto followthread
        when 'pm'   goto prev
        when 'nm'   goto next
        when 'fp'   goto findparent
        when 'fr'   goto findreply
        when 're'   goto composereply

        when 'pu', 'pd'   //
            if iif( arg == 'pu', vmForumReader ('pm'), vmForumReader ('nm') )
                goto dressout
            endif
            warnstr = nomore
            goto warnout

        when 'de'
            if vmForumReader ('v')
                saveline = headerline
                while 1
                    if lfind ('^\#: ','x+')
                        if vmForumReader ('v')
                            up()
                            break
                        endif
                    else
                        endfile()
                        break
                    endif
                endwhile
                markline()
                gotoline(saveline)
                begline()   //uf
                delblock()
                goto standardout
            endif
            goto warnout

        when 'ho'
            xflag = 0
            message (trcing)
            while vmForumReader ('fp')
                xflag = 1
                killposition()
                pushposition()
            endwhile
            updatedisplay(_statusline_refresh_)
            if xflag
                goto dressout
            endif
            goto warnout

        when 'up'
            if vmForumReader('fp')
                goto dressout
            endif
            goto warnout

        when 'dn'
            if vmForumReader('fr')
                goto dressout
            endif
            goto warnout

        when 'n'
            findstr = '^\#: '
            findops = 'gx'
            goto callcompressview

        when 'w'
            markword()
            findstr = getMarkedText()
            findops = 'giw'
            goto callcompressview

        when 'To', 'Fm', 'Sb'
            findstr = '^' + arg + ': '
            findops = 'gx'
            goto callcompressview

        when '^t', '^f', '^n'
            if vmForumReader ('v')
                case arg
                    when '^n'   findstr = section
                    when '^t'   findstr = toid
                    when '^f'   findstr = fmid
                endcase
                findops = 'gi'
                goto callcompressview
            endif
            goto warnout

        when '^s'
            if vmForumReader ('v')
                i = 1
                while i <= length (subject)
                    // is there one of the reg ex special characters
                    // in the subj?
                    if pos ( substr ( subject, i, 1), ".^$|?[]*+@#{}\")
                        // then nullify it with a '\'
                        subject = substr ( subject, 1, i-1) + '\'
                            + substr ( subject, i, length(subject) + 1 - i)
                        i = i + 1   // the subject is longer now
                    endif
                    i = i + 1
                endwhile
                findstr = '^Sb:.#' + subject + '$'
                findops = 'gxi'
                goto callcompressview
            endif
            goto warnout

        when 'i' goto info

        otherwise
            warnstr = 'Program error.'
            goto warnout
    endcase
    goto standardout

    align:
    if vmForumReader ('v')
        goto dressout
    endif
    goto warnout

    findparent:
    // find the parent of the current msg.
    // return 0 if fail
    if not vmForumReader ('v')
        goto errorout
    endif
    flag = 0
    if not (parentno == '')
        begfile()
        xparentno = parentno
        while lfind ('^\#: \c' + xparentno, 'x' )
            saveline = currline()
            if vmForumReader ('v')
                if saveline == headerline
                    flag = 1
                    break
                endif
            endif
        endwhile
    endif
    if flag
        goto nohomeout
    endif
    warnstr = notfound
    goto errorout

    findreply:
    // find the "1st" reply to the current msg.
    // return 0 on failure
    if not vmForumReader ('v')
        goto errorout
    endif
    flag = 0
    begfile()
        while lfind ('^Sb: \#\c' + msgno, 'x')
            saveline = currline()
            if vmForumReader('v')
                if saveline == headerline + 2
                    flag = 1
                    break
                endif
            endif
        endwhile
    if flag
        goto nohomeout
    endif
    warnstr = notfound
    goto errorout

    composereply:
    if not vmForumReader('v')
        goto warnout
    endif
    flag = 1
    while 1
        xparentno = 'r' + str(flag)
        if not fileexists(xparentno)
            if not getbufferid(xparentno)
                warnstr = badbuff
                if not editfile(xparentno)
                    break
                endif
                flag = 0
                break
            endif
        endif
        flag = flag + 1
    endwhile
    if flag
        goto warnout
    endif
    insertline('mes')
    addline('reply ' + msgno)
    addline('/exit')
    insertline()
    begfile()   // make start vis.
    down(2)
    goto nohomeout
    // end of composereply

    next:
    // find next msg. from current cursor pos.
    // return 0 if fail, else 1
    pushposition()
    flag = 0
    while lfind ('^\#: ', 'x+')
        saveline = currline()
        vmForumReader ('v')
        if saveline == headerline
            flag = 1
            break
        endif
    endwhile
    if flag
        killposition()
        goto standardout
    endif
    popposition()
    goto errorout

    prev:
    // find the msg. before the current one
    // return 0 if failure
    if not vmForumReader ('v')
        goto errorout
    endif
    pushposition()
    gotoline(headerline)
    if up()
        if vmForumReader ('v')
            killposition()
            goto standardout
        endif
    endif
    popposition()
    goto errorout

    info:
    // debug
    popwinopen(40,8,70,24,1,'info',48)
    vgotoxy (2,2)
    clrscr()
    writeline('-before-')
    flag = 1
    while 1
        writeline('headerline=',headerline)
        writeline('msgno=',msgno)
        writeline('Section=',section)
        writeline('Sb=',subject)
        writeline('Fm:',fmid)
        writeline('To:',toid)
        if flag
            writeline('-after-')
            vmForumReader ('v')
            flag = 0
        else
            break
        endif
    endwhile
    getkey()
    popwinclose()
    goto standardout


    verify:
    // v
    /**********************************************************************
    This is a fairly rigorous routine to get data about the current msg.
    It backs up until it gets a proper msg header.  It then resets the
    strings:  msgno, section, subject, fmid, toid.  These strings may be
    garbled if the call was unsucessful.

        returns: 1 if sucessful, cursor at msg header.
            else 0, cursor back home, there was no msg.

            does not use flag, saveline
    **********************************************************************/

    warnstr = ' This is not a valid forum message. '
    pushposition()  // save place for error

    findheader:
    if isBlockMarked()
        unMarkBlock()
    endif
    headerline = 0
    msgno = ''
    parentno = ''
    subject = ''
    section = ''
    toid = ''
    fmid = ''
    endline()   // draw back so the backward look works.
    if not lfind('^\#:\c [0-9]# .#/','xb')  // find a msg no. (#: nnn   /)
        popposition()   // back home
        goto errorout   // no more possible msg.s
    endif
    // got a possible msg header.

    /**********************************************************************
    The #: line has two pieces of information.
        1.  The msg. number.
        2.  The section identification, which is doulbly encoded,
            once as a number 'Sn', then again as a string.
    **********************************************************************/
    headerline = currline()
    right()
    markchar()   // should be msgno, start marking
    lfind(' ','')   // find the space after msg. number
    msgno = getmarkedtext()
    unmarkblock()

    right() // get on the 'Sn/' of section no.
    markchar()
    endline()
    section = getmarkedText()
    unmarkblock()

    // get to the 'Sb' line
    down()  // I'm not dealing with date and time.
    down()
    markline()
    /**********************************************************************
    the Sb: line contains 3 pieces of information:
        1. The trailing string is the Subject.
        2. If that string is preceded by '#', then there was a reply to _this_
            msg.
        3. If the above is preceded by '#nnn-', then this msg is a reply to
            msg. nnn.
    We need to bear in mind, however, that the replies and the parent (ie nnn)
    may not be in this file.
    On the other hand, since the messages were captured, new replies could have
    been entered, and may yet be in this file.
    **********************************************************************/
    if not lfind('^Sb: \c','xlg')    // find Sb: starter,
        // and put cursor after space.
        goto badheader
    endif
    // is this a reply to another msg?
    if lfind('\#[0-9]#-','xl')      // #nnn-
        unmarkblock()
        right()     // get off #
        markchar()
        lfind('-','')
        parentno = getMarkedText()
        nextchar()  // get off the hyphen.
    else
        parentno = ''
    endif

    if currchar() == asc('#')   // lose pound sign
        nextchar()
    endif
    unmarkblock()
    markchar()
    endline()
    subject = getmarkedText()
    unmarkblock()

    //FROM data
    down()
    markline()
    if not lfind('^Fm: \c','lgx')
        goto badheader
    endif
    if not lfind(cis_id,'lx')
        goto badheader
    endif
    unmarkblock()
    markchar()
    endline()
    fmid = getMarkedText()
    unmarkblock()


    down()
    markline()
    /**********************************************************************
        TO data
    there may be no cis,id.
    there may be fm:'s idea of what to:'s name is-- which is useless.
    there may be a (X) indicating To:person had received msg.-- which we
        can't really use.
    **********************************************************************/
    if not lfind('^To: \c','lxg')
        goto badheader
    endif
    pushposition()      // save start
    if lfind(cis_id,'lx')
        killposition()
        pushposition()      // reset start
        if not lfind(' (X)','lx')
            endline()
        endif
    else    // no cis_id, could be 'sysop' , 'all' or whatever.
        endline()
    endif
    unmarkblock()
    markchar()
    popposition()   // return to start
    toid = getMarkedText()
    unmarkblock()

    // Hurray!  If we got this far, then everything's assumed ok.
    gotoline(headerline)  // back to headerline
    begline()
    killposition()  // lose home
    goto standardout

    badheader:
    // there was something wrong in the header
    gotoline(headerline)    // back to start of trouble
    if not up()     // go higher
        headerline = 0  // if not, quit
        popposition()   // return home
        goto errorout
    endif
    goto findheader // try again

    // end of VERIFY



    CallCompressView:
    // cv
    /**********************************************************************
     this sub-routine calls mCompressView(0)
     findstr and findops must be preset by the caller.

     This code is ugly-- in defense I can only say it works.

     push everything (strings, crs) onto keyboard stack
     since lifo, everything is entered backwards
     return to editor.
    **********************************************************************/
    message ('Gathering lines . . .')
    pushkey(<enter>)
    i = length (findops)
    while i
        pushkey(asc(substr(findops,i,1)))
        i = i - 1
    endwhile
    pushkey(<enter>)
    i = length (findstr)
    while i
        pushkey(asc(substr(findstr,i,1)))
        i = i - 1
    endwhile

    // Important! The next pushed key must call mCompressView(0).
    pushkey( <alt v> )          // alt v is the standard tse.key binding.

    goto standardout  // this must exit back to the editor.



    anchorthread:
    // <end>
    /**********************************************************************
    anchorthread
        construct a buffer containing all msg.s spawned by the current msg.
        Primogeniture rules!
    **********************************************************************/
    if not vmForumReader('v')
        goto warnout
    endif
    message (trcing)
    pushposition()
    warnstr = badbuff
    capfile = getbufferid()
    tree = getbufferid('<tree>')
    if tree
        gotobufferid(tree)
        abandonfile()
    endif
    tree = createbuffer('<tree>',_system_)
    if not tree
        popposition()
        goto warnout
    endif
    addline ('x' + msgno )
    while 1
        gotobufferid (tree)
        // find the first undone msg.
        if lfind ('^x', 'gx' )
            delchar()   // remove the x
            markline()
            savemsgno = getmarkedtext()
            unmarkblock()
            // now go back to the file,
            // and get the msgno.s of all children of this guy,
            // and add them to the buffer.
            gotobufferid(capfile)
            begfile()
            while 1
                if lfind ('^Sb: \#' + savemsgno + '-', 'x+')
                    saveline = currline()
                    if vmForumReader ('v')
                        if headerline + 2 == saveline
                            // we got one.
                            gotobufferid (tree)
                            addline ( 'x' + msgno )
                            // and back.
                            gotobufferid (capfile)
                        endif
                    endif
                else    // no more children this msg.
                    break   // look in tree
                endif
                // look for next child
            endwhile
        else    // no more undone
            break
        endif   // loop for next undone
    endwhile

    // the tree's been built.
    popposition()   // back home
    vmForumReader ('v')
    gotobufferid(tree)
    endfile()
    flag = currline()   // count msgs
    begfile()       // we always want to be at the start.
    delLine()    // remove top msg no, which the user will see again imm.
    gotobufferid(capfile)
    if flag > 1
        warnstr = 'New thread: ' + str(flag) + ' messages.'
    else
        warnstr = nomore
    endif
    message ( warnstr )
    goto dressout


    // follow the thread
    followthread:
    if not tree
        warnstr = 'No thread declared.'
        goto warnout
    endif
    if not gotobufferid(tree)
        warnstr = badbuff
        goto warnout
    endif
    markline()
    savemsgno = getmarkedtext()
    if savemsgno == ''
        warnstr = 'Thread exhausted.'
        goto warnout
    endif
    delLine()
    if not gotobufferid(capfile)
        warnstr = badbuff
        goto warnout
    endif
    begfile()
    flag = 1
    while lfind ('^\#: ' + savemsgno + '\c ', '+x' )
        saveline = currline()
        if vmForumReader ('v')
            if saveline == headerline
                flag = 0
                break
            endif
        endif
    endwhile
    if flag
        warnstr = notfound
        goto warnout
    endif
    goto dressout

    /**********************************************************************
    exit routines
    **********************************************************************/

    warnout:
    message (warnstr)

    errorout:
    popblock()
    popposition()
    return(0)

    dressout:
    // 'v' had been called, and we like where we are,
    // dress up display, and show user the current msg.
    gotoline(headerline)
    scrolltorow(1)
    down(5)
    begline()
    nohomeout:
    killposition()  // lose home
    pushposition()  // insert dummy

    standardout:
    popposition()
    popblock()
    return(1)

end  // of vmForumReader ().


/**********************************************************************
whenLoaded--
    Show help screen.
    This procedure can be deleted without affecting
    the operation of vmForumReader.
**********************************************************************/
/**********************************************************************
proc whenLoaded ()
    vmForumReader('f1')
end  // of whenLoaded ().
**********************************************************************/


/**********************************************************************
(the only) Key binding.
**********************************************************************/
<centercursor>  vmForumReader('')
