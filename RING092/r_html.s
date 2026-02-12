/*

    R_HTML - a plugin for the Ringlets system which shows
             HTML files by the contents of their
             <title></title> tags.

             Useful if you keep a ringlet for your
             browser's cache files.

*/


#define MAX_BUFFER_ID_WIDTH 12

#ifndef MAXSTRINGLEN
#define MAXSTRINGLEN 255
#endif

#include ['setcache.si']

integer Settings_Serial                        = 0

string proc GetBufferHTMLTitleCached()

    string  html_name[MAXSTRINGLEN] = ''
    integer html_settings_serial    = GetBufferInt('Ringlets::r_html::settings_serial')


    if isMacroLoaded('CurrExt')
        ExecMacro('currext')
        if GetGlobalStr('CurrExt') <> '.htm'
            return('')
        endif
    elseif CurrExt() <> '.pm'
        return('')
    endif

    if (Settings_Serial <= html_settings_serial) and Length(html_name)
        return(GetBufferStr('Ringlets::r_html::html_name'))
    endif

    SetBufferInt('Ringlets::r_html::settings_serial', Settings_Serial)

    // Try finding <title>...</title> text
    if not Length(html_name)
        PushPosition()
        PushBlock()

        UnMarkBlock()
        // if lFind('<title>{.*}</title>','ixg') or lFind('<title>{.*}$','ixg')
        //     html_name = GetFoundText(1)
        // endif

        if lFind('<title>\c', 'igx')

            // Found <title>.  Start marking and try finding </title>
            // on the same line
            MarkStream()

            if lFind('\c</title>', 'cix')
                MarkChar()
                html_name = Trim(GetMarkedText())
            else
                // Didn't find </title>, on same line.
                // let's try marking to the end of the line
                // and hoping we get some (non white) text.

                MarktoEOL()
                html_name = Trim(GetMarkedText())

                if not Length(html_name)

                    // Didn't find text on the first line,
                    // let's hope that there's text on the next line.

                    UnMarkBlock()

                    // Find the next non blank line

                    while 1
                        if not Down()
                            break
                        endif
                        if CurrLineLen() and (not isWhite(GetText(1, CurrLineLen())))
                            break
                        endif
                    endwhile

                    BegLine()

                    MarkStream()

                    // if this line contains </title>, stop marking there

                    if lFind('\c</title>', 'cix')
                        MarkChar()
                        html_name = Trim(GetMarkedText())
                    else

                        // No </title>, so mark until the end of the line

                        MarkToEol()
                        html_name = Trim(GetMarkedText())

                    endif
                endif
            endif
        endif
        PopBlock()
        PopPosition()
    endif

    if Length(html_name)
        html_name = '[' + html_name + ']'
    endif

    SetBufferStr('Ringlets::r_html::html_name', html_name)

    return(html_name)
end

proc Main()
    string cmd[128] = Query(MacroCmdLine)
    string buffer_name[MAXSTRINGLEN] = Query(MacroCmdLine)
    integer temp_ids_buffer   = Val(GetToken(cmd, ' ', 1))
    integer temp_names_buffer = Val(GetToken(cmd, ' ', 2))

    if (temp_ids_buffer)
        repeat
            GotoBufferId(temp_names_buffer)

            if not CurrLineLen()
                GotoBufferId(temp_ids_buffer)
                if GotoBufferId(Val(GetText(1, MAX_BUFFER_ID_WIDTH)))
                    buffer_name = GetBufferHTMLTitleCached()
                    GotoBufferId(temp_names_buffer)
                    BegLine()
                    InsertText(buffer_name, _OVERWRITE_)
                endif
            endif

            GotoBufferId(temp_names_buffer)
            Down()
            GotoBufferId(temp_ids_buffer)

        until not Down()
    endif
end




