
/*


    Gedcom - Edit GEDCOM genealogical databases

    See Gedcom.txt for usage.

    v0.9.2 - Jun 19, 2002

    
    Copyright (c) 2002 - Michael Graham <magmac@occamstoothbrush.com>

    This program is Free Software - you may use it, modify it and
    distribute it under the the terms of the Perl Artistic License,
    which you may find at:

          http://www.perl.com/CPAN/doc/misc/license/Artistic

    In particular, note that you use this software at your own risk!

    The latest version of my TSE macros can be found at:

        http://www.occamstoothbrush.com/tsemac/



*/

/*

    TODO (don't hold your breath)
    =============================

    Single link editing:
    -------------------
    * When Cursor on Link:
        * follow link
        * edit link
            * menu with current value selected and 'new...' option

    Date parsing and picking:
    ------------------------
    * When Cursor in DATE line:
        * pick date
    * Change link menus so that children and siblings are sorted by date

    General:
    -------
    * Edit block of text in new window ???
    * Continuation of text tags from line to line?
    * Word wrapping sensitive to text blocks?
    * Caching of names and family descriptions

*/



// Change this if you want your files to be indented by something
// other than two spaces per level

constant Indent_Multiplier      = 2

// ************************************************************

#ifndef MAXSTRINGLEN
    #define MAXSTRINGLEN 255
#endif

constant FORMAT_FULL            = 0
constant FORMAT_ABBREVIATE      = 1
constant FORMAT_FIRST_NAME_ONLY = 2

constant SCOPE_GLOBAL           = 0
constant SCOPE_LOCAL            = 1

constant LM_HELP                = 1
constant LM_JUMP                = 2
constant LM_SELECT              = 2
constant LM_EDIT                = 4
constant LM_DELETE              = 8
constant LM_ADD_CHILD           = 16
constant LM_ADD_SIBLING         = 32
constant LM_ADD_WIFE            = 64
constant LM_ADD_HUSBAND         = 128
constant LM_NEW_INDIVIDUAL      = 256
constant LM_NEW_FAMILY          = 512
constant LM_SHOW_MENU           = 1024
constant LM_JUMP_TO_INDIVIDUAL  = 2048
constant LM_JUMP_TO_FAMILY      = 4096

forward proc current_links_menu()
forward menu global_function_menu()
forward proc pick_and_jump_to_individual()
forward proc pick_and_jump_to_family()

#include ['gedkeys.si']

forward menu pick_individual_function_menu()
forward menu pick_family_function_menu()
forward menu individual_function_menu()
forward menu family_function_menu()

// ************************************************************
// * Utility routines - general

// in_gedcom_file()
// returns true if the current file is a gedcom file,
// false otherwise.

integer proc in_gedcom_file ()
    string curr_ext[4] = CurrExt()
    if isMacroLoaded('CurrExt')
        ExecMacro('CurrExt')
        curr_ext = GetGlobalStr('CurrExt')
    endif

    if curr_ext == '.ged'
        return(1)
    endif

    return(0)
end


// PrepTempBuffer
// creates a temp buffer, or empties the contents of the
// given buffer if it already exists

integer proc PrepTempBuffer(integer existing_buffer_id)
    integer buffer_id = existing_buffer_id

    if buffer_id
        EmptyBuffer(buffer_id)
    else
        buffer_id = CreateTempBuffer()
    endif

    return(buffer_id)
end


// ************************************************************
// * Utility routines - marking

// mark_individual:
//     marks with a line block the entire definition for the
//     given individual

proc mark_individual (integer individual_id)
    integer start_indent_level
    UnmarkBlock()
    if lFind('^[ \t]*{[0-9]}[ \t]+\@I'+ Str(individual_id) +'\@[ \t]+INDI[ \t]*$', 'gxi')
        start_indent_level = Val(GetFoundText(1))
        MarkLine()
        Down()
        // Search for same level number at start of line (or else end of file)
        if lFind('^[ \t]*' + Str(start_indent_level), 'x') or EndFile()
            Up()
            while CurrLineLen() == 0 and CurrLine() > 1
                Up()
            endwhile
            MarkLine()
        else
            UnmarkBlock()
        endif
    endif
end

// mark_family:
//     marks with a line block the entire definition for
//     the given family

proc mark_family (integer family_id)
    integer start_indent_level
    UnmarkBlock()
    if lFind('^[ \t]*{[0-9]}[ \t]+\@F'+ Str(family_id) +'\@[ \t]+FAM[ \t]*$', 'gxi')
        start_indent_level = Val(GetFoundText(1))
        MarkLine()
        Down()
        // Search for same level number at start of line (or else end of file)
        if lFind('^' + Str(start_indent_level), 'x') or EndFile()
            Up()
            while CurrLineLen() == 0 and CurrLine() > 1
                Up()
            endwhile
            MarkLine()
        else
            UnmarkBlock()
        endif
    endif
end

// ************************************************************
// * Utility routines - finding what's currently selected

// current_individual_id:
//     returns the ID for the individual that is currently selected (i.e.
//     the cursor is within the definition for the individual)

integer proc current_individual_id ()
    integer individual_id = 0

    PushPosition()
    while not lFind('^[ \t]*0', 'gxic')
        if CurrLine() == 1
            PopPosition()
            return(0)
        endif
        Up()
    endwhile

    if lFind('^[ \t]*[0-9][ \t]+\@I{[0-9]+}\@[ \t]+INDI[ \t]*$', 'gxic')
        individual_id = Val(GetFoundText(1))
    endif

    PopPosition()
    return(individual_id)
end

// current_family_id:
//     returns the FAM ID for the family that is currently selected (i.e.
//     the cursor is within the definition for the family)

integer proc current_family_id ()
    integer family_id = 0

    PushPosition()
    while not lFind('^[ \t]*0', 'gxic')
        if CurrLine() == 1
            PopPosition()
            return(0)
        endif
        Up()
    endwhile

    if lFind('^[ \t]*[0-9][ \t]+\@F{[0-9]+}\@[ \t]+FAM[ \t]*$', 'gxic')
        family_id = Val(GetFoundText(1))
    endif

    PopPosition()
    return(family_id)

end


// ************************************************************
// * Utility routines - useful regexes

// link_regex
//     returns a regular expression that searches for a link
//     based on the given tag.
//
//     For instance the following code will return the husband id
//     of the current family.
//
//         mark_family(current_family_id())
//         if lFind(link_regex('HUSB'), 'lgx')
//             return(Val(GetFoundText(1))
//         endif
//
//     The following code will return the husband id
//     if the current line contains a HUSB @Inn@ line:
//
//         if lFind(link_regex('HUSB'), 'gcx')
//             return(Val(GetFoundText(1))
//         endif
//
//     The following code will return the value of the
//     link on the current line, regardless of the link type:
//
//         if lFind(link_regex('[A-ZA-ZA-ZA-Z]'), 'gcx')
//             return(Val(GetFoundText(1))
//         endif
//

string proc link_regex (string tag_name)
    return('^[ \t]*[0-9][ \t]+'+tag_name+'[ \t]+\@[IF]{[0-9]+}\@')
end

// name_regex
//     returns a regular expression that can be used to search for
//     the value of a name tag.
//
//     For instance, the following code returns the name of the current individual:
//         mark_individual(current_individual_id())
//         if lFind(name_regex(), 'lgx')
//             return(GetFoundText(1))
//         endif
//

string proc name_regex ()
    return('^[ \t]*[0-9][ \t]+NAME[ \t]+{.#}')
end


// tag_value_regex
//     returns a regular expression that can be used to search for
//     the value of the given tag.
//
//     For instance, the following code returns the value of the DATE tag,
//     if one exists on the current line:
//         if lFind(tag_value_regex('DATE'), 'gcix')
//             return(GetFoundText(1))
//         endif
string proc tag_value_regex (string tag_name)
    return('^[ \t]*[0-9][ \t]+' + tag_name + '[ \t]+{.#}')
end

// ************************************************************
// * Utility routines - lookup data

// individual_name:
//     returns the value of the NAME tag for the
//     given individual

string proc individual_name (integer individual_id)
    string name[MAXSTRINGLEN]
    PushPosition()
    PushBlock()

    mark_individual(individual_id)
    if lFind(name_regex(), 'lgx')
        name = GetFoundText(1)
        PopBlock()
        PopPosition()
        return(name)
    endif

    PopBlock()
    PopPosition()
    return('')
end


// individual_sex:
//     returns the gender ('M' or 'F') of the individual
//     (from the SEX tag)

string proc individual_sex (integer individual_id)
    string sex[1]
    PushPosition()
    PushBlock()

    mark_individual(individual_id)
    if lFind(tag_value_regex('SEX'), 'lgx')
        sex = Trim(GetFoundText(1))
        PopBlock()
        PopPosition()
        return(Upper(sex))
    endif

    PopBlock()
    PopPosition()
    return('')
end



// family_husb_id:
//     returns the HUSB individual ID for the given family

integer proc family_husb_id (integer family_id)
    integer husb_id
    PushPosition()
    PushBlock()

    mark_family(family_id)
    if lFind(link_regex('HUSB'), 'lgx')
        husb_id = Val(GetFoundText(1))
        PopBlock()
        PopPosition()
        return(husb_id)
    endif

    PopBlock()
    PopPosition()
    return(0)
end

// family_wife_id:
//     returns the WIFE individual ID for the given family.

integer proc family_wife_id (integer family_id)
    integer wife_id
    PushPosition()
    PushBlock()

    mark_family(family_id)
    if lFind(link_regex('WIFE'), 'lgx')
        wife_id = Val(GetFoundText(1))
        PopBlock()
        PopPosition()
        return(wife_id)
    endif

    PopBlock()
    PopPosition()
    return(0)
end

// family_children_ids:
//     returns a whitespace separated list of
//     individual ids representing the children of
//     for the given family

string proc family_children_ids (integer family_id)
    string children_ids[MAXSTRINGLEN] = ''

    PushPosition()
    PushBlock()

    mark_family(family_id)
    GotoBlockBegin()

    while Down() and CurrLine() <= Query(BlockEndLine)
        if lFind(link_regex('CHIL'), 'gcix')
            children_ids = children_ids + GetFoundText(1) + ' '
        endif
    endwhile

    GotoBlockBegin()

    PopBlock()
    PopPosition()
    return(children_ids)
end

// as_child_family_ids:
//     returns a whitespace separated list of
//     family ids that the given individual belongs to
//     as a child

string proc as_child_family_ids (integer individual_id)
    string family_ids[MAXSTRINGLEN] = ''

    PushPosition()
    PushBlock()

    mark_individual(individual_id)
    GotoBlockBegin()

    while Down() and CurrLine() <= Query(BlockEndLine)
        if lFind(link_regex('FAMC'), 'gcix')
            family_ids = family_ids + GetFoundText(1) + ' '
        endif
    endwhile

    PopBlock()
    PopPosition()
    return(family_ids)
end

// as_spouse_family_ids:
//     returns a whitespace separated list of
//     family ids that the given individual belongs to
//     as a spouce

string proc as_spouse_family_ids (integer individual_id)
    string family_ids[MAXSTRINGLEN] = ''

    PushPosition()
    PushBlock()

    mark_individual(individual_id)
    GotoBlockBegin()

    while Down() and CurrLine() <= Query(BlockEndLine)
        if lFind(link_regex('FAMS'), 'gcix')
            family_ids = family_ids + GetFoundText(1) + ' '
        endif
    endwhile

    PopBlock()
    PopPosition()
    return(family_ids)
end


// individual_sibling_ids:
//     returns a whitespace separated list of
//     individual ids that are siblings of the currently
//     selected individual

string proc individual_sibling_ids (integer individual_id, integer within_specific_family_id)
    integer i
    integer family_id
    integer child_id
    string sibling_ids[MAXSTRINGLEN] = ''
    string family_ids[MAXSTRINGLEN]

    if within_specific_family_id
        family_ids = Str(within_specific_family_id)
    else
        family_ids = as_child_family_ids(individual_id)
    endif

    PushPosition()
    PushBlock()

    for i = 1 to NumTokens(family_ids, ' ')
        family_id = Val(GetToken(family_ids, ' ', i))

        mark_family(family_id)

        GotoBlockBegin()

        while Down() and CurrLine() <= Query(BlockEndLine)
            if lFind(link_regex('CHIL'), 'gcix')
                child_id = Val(GetFoundText(1))
                if child_id <> individual_id
                    sibling_ids = sibling_ids + Str(child_id) + ' '
                endif
            endif
        endwhile
    endfor

    PopBlock()
    PopPosition()
    return(sibling_ids)
end

// individual_spouse_ids:
//     returns a whitespace separated list of
//     individual ids that are the spouse of the currently
//     selected individual

string proc individual_spouse_ids (integer individual_id, integer within_specific_family_id)
    integer i
    integer family_id
    integer spouse_id
    string spouse_ids[MAXSTRINGLEN] = ''
    string family_ids[MAXSTRINGLEN]

    if within_specific_family_id
        family_ids = Str(within_specific_family_id)
    else
        family_ids = as_spouse_family_ids(individual_id)
    endif

    PushPosition()
    PushBlock()

    for i = 1 to NumTokens(family_ids, ' ')
        family_id = Val(GetToken(family_ids, ' ', i))

        mark_family(family_id)

        GotoBlockBegin()

        while Down() and CurrLine() <= Query(BlockEndLine)
            if lFind(link_regex('WIFE'), 'gcix')
                spouse_id = Val(GetFoundText(1))
                if spouse_id <> individual_id
                    spouse_ids = spouse_ids + Str(spouse_id) + ' '
                endif
            elseif lFind(link_regex('HUSB'), 'gcix')
                spouse_id = Val(GetFoundText(1))
                if spouse_id <> individual_id
                    spouse_ids = spouse_ids + Str(spouse_id) + ' '
                endif
            endif
        endwhile

    endfor

    PopBlock()
    PopPosition()
    return(spouse_ids)
end


// individual_children_ids:
//     returns a whitespace separated list of
//     individual ids that are children of the currently
//     selected individual

string proc individual_children_ids (integer individual_id, integer within_specific_family_id)
    integer i
    integer family_id
    integer child_id
    string children_ids[MAXSTRINGLEN] = ''
    string family_ids[MAXSTRINGLEN]

    if within_specific_family_id
        family_ids = Str(within_specific_family_id)
    else
        family_ids = as_spouse_family_ids(individual_id)
    endif

    PushPosition()
    PushBlock()

    for i = 1 to NumTokens(family_ids, ' ')
        family_id = Val(GetToken(family_ids, ' ', i))

        mark_family(family_id)

        GotoBlockBegin()

        while Down() and CurrLine() <= Query(BlockEndLine)
            if lFind(link_regex('CHIL'), 'gcix')
                child_id = Val(GetFoundText(1))
                if child_id <> individual_id
                    children_ids = children_ids + Str(child_id) + ' '
                endif
            endif
        endwhile
    endfor

    PopBlock()
    PopPosition()
    return(children_ids)
end


// individual_father_id:
//     returns the individual id of the father of the given
//     individual
//
integer proc individual_father_id (integer individual_id)
    return(family_husb_id(Val(GetToken(as_child_family_ids(individual_id), ' ', 1))))
end

// individual_mother_id:
//     returns the individual id of the mother of the given
//     individual
//
integer proc individual_mother_id (integer individual_id)
    return(family_wife_id(Val(GetToken(as_child_family_ids(individual_id), ' ', 1))))
end


// ************************************************************
// * Utility routines - formatting

// formatted_name
//     returns a formatted name from a canonical name.
//     Some examples:
//          William Arthur Philip/Windsor/      => William Arthur Phillip WINDSOR
//          Diana Frances /Spencer/             => Diana Frances SPENCER
//          Elizabeth Alexandra Mary/Windsor/II => Elizabeth Alexandra Mary WINDSOR II
//
//     if the flag is FORMAT_ABBREVIATE, then the middle names and
//          suffixes are removed:
//          William Arthur Philip/Windsor/      => William WINDSOR
//          Diana Frances /Spencer/             => Diana SPENCER
//          Elizabeth Alexandra Mary/Windsor/II => Elizabeth WINDSOR
//
//     if the flag is FORMAT_FIRST_NAME_ONLY, then only the first name is returned:
//          William Arthur Philip/Windsor/      => William
//          Diana Frances /Spencer/             => Diana
//          Elizabeth Alexandra Mary/Windsor/II => Elizabeth

string proc formatted_name (string canonical_name, integer format_flag)

    string formatted_name[MAXSTRINGLEN] = ''
    string character[1]

    integer in_surname      = false
    integer need_space      = false
    integer seen_whitespace = false

    integer name_already_has_trailing_whitespace  = false

    integer i

    for i = 1 to Length(canonical_name)
        if Length(formatted_name) > 1 and isWhite(formatted_name[Length(formatted_name)-1:1])
            name_already_has_trailing_whitespace = true
        else
            name_already_has_trailing_whitespace = false
        endif

        if format_flag & FORMAT_FIRST_NAME_ONLY and (not isWhite(formatted_name)) and (isWhite(canonical_name[i:1]))
            return(formatted_name)
        endif

        character = canonical_name[i:1]

        if isWhite(character)
            seen_whitespace = true
            need_space = true
        elseif character == '/'
            if in_surname
                in_surname = false
            else
                in_surname = true
            endif
            need_space = true
        else
            if need_space and (not name_already_has_trailing_whitespace)
                if (not format_flag & FORMAT_ABBREVIATE) or (not seen_whitespace) or (in_surname)
                    formatted_name = formatted_name + ' '
                    need_space = false
                endif
            endif
            if (not isWhite(character)) or (not name_already_has_trailing_whitespace)
                if in_surname
                    formatted_name = formatted_name + Upper(character)
                else
                    if (not format_flag & FORMAT_ABBREVIATE) or (not seen_whitespace)
                        formatted_name = formatted_name + character
                    endif
                endif
            endif
        endif
    endfor
    return(formatted_name)
end


// id_list_to_name_list:
//     accepts a whitespace separated list of individual
//     ids and returns a comma separated list first names

string proc id_list_to_name_list (string id_list, integer format_flag)
    integer individual_id
    integer i
    string name_list[MAXSTRINGLEN] = ''

    for i = 1 to NumTokens(id_list, ' ')
        individual_id = Val(GetToken(id_list, ' ', i))
        if Length(name_list)
            name_list = name_list + ', '
        endif
        name_list = name_list + formatted_name(individual_name(individual_id), format_flag)
    endfor
    return (name_list)
end


// family_description:
//     provides a one line description of the given family,
//     suitable for displaying in picklists.
//     e.g.:
//         FAMS @F36@ - Husb: Jeremy LASCELLES; Wife: Julie BAYLISS; Children: Ellen LASCELLES, Patricia TUCKWELL
//

string proc family_description (integer family_id)
    integer individual_id
    string name_list[MAXSTRINGLEN] = ''
    string children_list[MAXSTRINGLEN] = ''

    individual_id = family_husb_id(family_id)
    if individual_id
        if Length(name_list)
            name_list = name_list + '; '
        endif
        name_list = name_list + 'Husband: ' + formatted_name(individual_name(individual_id), FORMAT_ABBREVIATE)
    endif

    individual_id = family_wife_id(family_id)
    if individual_id
        if Length(name_list)
            name_list = name_list + '; '
        endif
        name_list = name_list + 'Wife: ' + formatted_name(individual_name(individual_id), FORMAT_ABBREVIATE)
    endif

    children_list = family_children_ids(family_id)
    if Length(children_list)
        if Length(name_list)
            name_list = name_list + '; '
        endif
        name_list = name_list + 'Children: ' + id_list_to_name_list(children_list, FORMAT_ABBREVIATE)
    endif

    return (name_list)
end

// short_family_description:
//     provides a one line description of the given family,
//     suitable for displaying in picklists.
//     e.g.:
//         Jeremy LASCELLES = Julie BAYLISS >> Ellen, Patricia
//

string proc short_family_description (integer family_id)
    integer individual_id
    string name_list[MAXSTRINGLEN] = ''
    string children_list[MAXSTRINGLEN] = ''

    individual_id = family_husb_id(family_id)
    if individual_id
        name_list = name_list + formatted_name(individual_name(individual_id), FORMAT_FIRST_NAME_ONLY)
    endif

    if Length(name_list)
        name_list = name_list + ' = '
    endif

    individual_id = family_wife_id(family_id)
    if individual_id
        name_list = name_list + formatted_name(individual_name(individual_id), FORMAT_FIRST_NAME_ONLY)
    endif

    if Length(name_list)
        name_list = '[' + name_list + ']'
    endif

    children_list = family_children_ids(family_id)
    if Length(children_list)
        name_list = name_list + ' >> ' + id_list_to_name_list(children_list, FORMAT_FIRST_NAME_ONLY)
    endif
    return (name_list)
end



// indent_file
// Indents the entire file, putting spaces in front of
// each line, according to its outline level.  (Actually
// it multiplies the line's outline level by the global
// Indent_Multiplier, and puts that many spaces.)
//
// For each line beginning with 0 @, this routine inserts
// a blank line before, unless the preceding line is already
// blank.

proc format_gedcom_data(integer scope_flag)
    integer outline_level = 0
    string scope_option[1] = ''

    if scope_flag & SCOPE_LOCAL
        scope_option = 'l'
    endif
    // Indent entire file
    PushPosition()
    BegFile()
    while lFind('^{[\t ]@}{[0-9]#}[ \t]\c', 'x' + scope_option)
        outline_level = Val(GetFoundText(2))
        BegLine()
        do Length(GetFoundText(1)) times
            DelChar()
        enddo
        BegLine()
        do outline_level * Indent_Multiplier times
            InsertText(' ', _INSERT_)
        enddo
        if Down()
            BegLine()
        else
            break
        endif
    endwhile

    // Insert blank lines
    BegFile()
    while lFind('^[\t ]@0[ \t]\@\c', 'x')
        if Up()
            if CurrLineLen()
                if (CurrLineLen() < MAXSTRINGLEN and not IsWhite(GetText(1,CurrLineLen())))
                    AddLine()
                    Down()
                endif
            endif
            Down()
            Down()
        endif
    endwhile
    PopPosition()

end

// ************************************************************
// * Creation routines

// new_individual:
//     adds a new individual to the database
//     returns the id of that individual


integer proc new_individual()
    integer individual_id = 1

    PushPosition()

    // Find max individual id in database
    BegFile()
    while lFind('^[ \t]*0[ \t]*\@I{[0-9]@}\@[ \t]*INDI\c', 'x+')
        individual_id = Max(individual_id, Val(GetFoundText(1)))
    endwhile

    individual_id = individual_id + 1

    // Find first family in database
    if lFind('^[ \t]*0[ \t]*\@F[0-9]@\@[ \t]FAM', 'xg')
        InsertLine()
    else
        EndFile()
        AddLine()
    endif

    if CurrLineLen()
        AddLine()
    endif

    AddLine('0 @I' + Str(individual_id) + '@ INDI')
    AddLine('1 NAME')
    AddLine('1 SEX')
    AddLine('1 BIRT')
    AddLine('2 DATE')
    AddLine('2 PLAC')
    AddLine('1 DEAT')
    AddLine('2 DATE')
    AddLine('2 PLAC')
    AddLine()

    PushBlock()
    mark_individual(current_individual_id())
    format_gedcom_data(SCOPE_LOCAL)
    PopBlock()

    PopPosition()

    return(individual_id)
end

// new_family:
//     adds a new family to the database
//     returns the id of that family
//
integer proc new_family ()
    integer family_id = 1

    PushPosition()

    // Find max family id in database
    BegFile()
    while lFind('^[ \t]*0[ \t]*\@F{[0-9]@}\@[ \t]*FAM\c', 'x+')
        family_id = Max(family_id, Val(GetFoundText(1)))
    endwhile

    family_id = family_id + 1

    // Find '0 TRLR' line in database
    if lFind('^[ \t]*0[ \t]*TRLR', 'xg')
        Up()
        Up()
        AddLine()
    else
        EndFile()
        AddLine()
    endif

    AddLine('0 @F' + Str(family_id) + '@ FAM')
    AddLine('1 WIFE @I0@')
    AddLine('1 HUSB @I0@')
    AddLine('1 MARR')
    AddLine('2 DATE')
    AddLine('2 PLAC')
    AddLine()

    PushBlock()
    mark_family(current_family_id())
    format_gedcom_data(SCOPE_LOCAL)
    PopBlock()

    PopPosition()

    return(family_id)
end


// ************************************************************
// * Navigation routines

// jump_to_individual:
//     jump to the individual indicated by individual_id

proc jump_to_individual (integer individual_id)
    lFind('^[ \t]*{[0-9]}[ \t]+\@I'+ Str(individual_id) +'\@[ \t]+INDI[ \t]*$', 'gxi')
end

// jump_to_family:
//     jump to the family indicated by family_id

proc jump_to_family (integer family_id)
    lFind('^[ \t]*{[0-9]}[ \t]+\@F'+ Str(family_id) +'\@[ \t]+FAM[ \t]*$', 'gxi')
end


// ************************************************************
// * Utility routines - change relationships

// delete_individual_link
// delete one of the links in an individual section
// link_value is optional.  If present, then only links
// with the value of link_value will be deleted.
//
proc delete_individual_link (integer individual_id, string link_type, integer link_value)
    PushBlock()
    PushPosition()
    mark_individual(individual_id)
    GotoBlockBegin()
    while lFind(link_regex(link_type) + '\c', 'lx')
        if (not link_value) or (link_value == Val(GetFoundText(1)))
            DelLine()
        endif
    endwhile
    PopPosition()
    PopBlock()
end

// delete_family_link
// delete one of the links in a family section
// link_value is optional.  If present, then only links
// with the value of link_value will be deleted.
//
proc delete_family_link (integer family_id, string link_type, integer link_value)
    PushBlock()
    PushPosition()
    mark_family(family_id)
    GotoBlockBegin()
    while lFind(link_regex(link_type) + '\c', 'lx')
        if (not link_value) or (link_value == Val(GetFoundText(1)))
            DelLine()
        endif
    endwhile
    PopPosition()
    PopBlock()
end


// change_individual_link()
//  change the value of one of the family links in an individual section to a
//  new family.
//
//  old_link_value is optional. If present, only links whose value
//  is currently old_link_value will be changed to the new family.
//

proc change_individual_link (integer individual_id, string link_type, integer old_link_value, integer new_family_id)
    integer found_link = 0

    PushBlock()
    PushPosition()
    mark_individual(individual_id)
    GotoBlockBegin()
    while lFind(link_regex(link_type) + '\c', 'lx')
        if (not old_link_value) or (old_link_value == Val(GetFoundText(1)))
            PushBlock()
            PushPosition()
            MarkFoundText(1)
            GotoBlockBegin()
            KillBlock()
            InsertText(Str(new_family_id), _INSERT_)
            PopPosition()
            PopBlock()
            found_link = 1
        endif
    endwhile
    if not found_link
        GotoBlockBegin()
        if AddLine()
            Do Indent_Multiplier times
                InsertText(' ')
            enddo
            InsertText('1 ' + link_type + ' @F' + Str(new_family_id) + '@', _INSERT_)
        endif
    endif
    PopPosition()
    PopBlock()
end

// change_family_link()
//  change the value of one of the links in a family section to a
//  new individual.
//
//  old_link_value is optional. If present, only links whose value
//  is currently old_link_value will be changed to the new individual.
//

proc change_family_link (integer family_id, string link_type, integer old_link_value, integer new_individual_id)
    integer found_link = 0

    PushBlock()
    PushPosition()
    mark_family(family_id)
    GotoBlockBegin()
    while lFind(link_regex(link_type) + '\c', 'lx')
        if (not old_link_value) or (old_link_value == Val(GetFoundText(1)))
            PushBlock()
            PushPosition()
            MarkFoundText(1)
            GotoBlockBegin()
            KillBlock()
            InsertText(Str(new_individual_id), _INSERT_)
            PopPosition()
            PopBlock()
            found_link = 1
        endif
    endwhile
    if not found_link
        GotoBlockBegin()
        if AddLine()
            Do Indent_Multiplier times
                InsertText(' ')
            enddo
            InsertText('1 ' + link_type + ' @I' + Str(new_individual_id) + '@', _INSERT_)
        endif
    endif
    PopPosition()
    PopBlock()
end

// add_family_link()
//  add a new link in a family section unless it already exists
//

proc add_family_link (integer family_id, string link_type, integer link_value)

    PushBlock()
    PushPosition()
    mark_family(family_id)
    GotoBlockBegin()
    while lFind(link_regex(link_type) + '\c', 'lx')
        if link_value and link_value == Val(GetFoundText(1))
            return()
        endif
    endwhile

    GotoBlockBegin()
    Down()

    if InsertLine()
        BegLine()
        Do Indent_Multiplier times
            InsertText(' ')
        enddo
        InsertText('1 ' + link_type + ' @I' + Str(link_value) + '@', _INSERT_)
    endif

    PopPosition()
    PopBlock()
end


// ************************************************************
// * Utility routines - cleanup

proc delete_invalid_links ()
    integer current_family
    integer current_individual
    integer link_is_valid
    string links[MAXSTRINGLEN]
    integer i

    PushPosition()
    PushBlock()

    // First go through every individual looking for bad
    // FAMS and FAMC links

    BegFile()
    BegLine()

    while lFind('^[0-9][ \t]+\@I{[0-9]+}\@[ \t]+INDI\c', 'x')
        current_individual = Val(GetFoundText(1))

        links = Trim(as_child_family_ids(current_individual))
              + ' '
              + Trim(as_spouse_family_ids(current_individual))

        for i = 1 to NumTokens(links, ' ')
            current_family = Val(GetToken(links, ' ', i))
            PushPosition()
            link_is_valid = lFind('^[0-9][ \t]+\@F' + Str(current_family) + '\@[ \t]+FAM\c', 'gx')
            PopPosition()
            if not link_is_valid
                delete_individual_link(current_individual, 'FAM[CS]', current_family)
            endif
        endfor
    endwhile

    BegFile()
    BegLine()

    while lFind('^[0-9][ \t]+\@F{[0-9]+}\@[ \t]+FAM\c', 'x')
        current_family = Val(GetFoundText(1))

        links = Trim(family_children_ids(current_family))
              + ' '
              + Str(family_husb_id(current_family))
              + ' '
              + Str(family_wife_id(current_family))

        for i = 1 to NumTokens(links, ' ')
            current_individual = Val(GetToken(links, ' ', i))
            PushPosition()
            link_is_valid = lFind('^[0-9][ \t]+\@I' + Str(current_individual) + '\@[ \t]+INDI\c', 'gx')
            PopPosition()
            if not link_is_valid
                delete_family_link(current_family, '[CHILHUSBWIFE]*', current_individual)
            endif
        endfor
    endwhile

    PopBlock()
    PopPosition()
end



// ************************************************************
// * Picklist routines

integer menu_flag                 = 0

constant MENU_FLAG_CLEAR              = 0
constant MENU_FLAG_ADD_CHILD          = 1
constant MENU_FLAG_ADD_SIBLING        = 2
constant MENU_FLAG_NEW_INDIVIDUAL     = 4
constant MENU_FLAG_NEW_FAMILY         = 8
constant MENU_FLAG_JUMP_TO_INDIVIDUAL = 16
constant MENU_FLAG_JUMP_TO_FAMILY     = 32

proc set_menu_flag (integer new_flag)
    menu_flag = menu_flag | new_flag
end

constant POPT_NONE         = 0
constant POPT_EXCLUDE_NEW  = 1
constant POPT_DISABLE_MENU = 2

proc pick_individual_helper ()
    if Enable(pick_individual_keys)
        ListFooter(PICK_FOOTER)
    endif
    Unhook(pick_individual_helper)
    BreakHookChain()
end

// pick_individual:
//     brings up a picklist of all individuals in the database.
//     returns the id of the individual chosen
//     returns 0 on cancel
//     returns -1 for "new individual"

forward integer proc pick_family (integer initial_family, integer exclude_family, integer options, string picklist_title)

integer proc pick_individual (integer initial_individual, integer exclude_individual, integer options, string picklist_title)
    integer current_buffer      = 0
    integer names_buffer        = 0
    integer ids_buffer          = 0
    integer selected_individual = 0
    integer selected_line       = 0
    integer longest_line        = 1
    integer show_picklist       = 1
    integer list_action         = 1
    integer temp_id             = 0
    integer picklist_width      = 0

    integer individual_id
    string  name[MAXSTRINGLEN]

    PushPosition()

    current_buffer      = GetBufferId()

    while show_picklist
        show_picklist = 0 // By default, close the picklist after first selection

        names_buffer = PrepTempBuffer(names_buffer)
        ids_buffer   = PrepTempBuffer(ids_buffer)

        if names_buffer and ids_buffer

            if not (options & POPT_EXCLUDE_NEW)
                GotoBufferId(names_buffer)
                AddLine('New...')
                GotoBufferId(ids_buffer)
                AddLine('-1')
            endif

            GotoBufferId(current_buffer)
            BegFile()

            while lFind('^[0-9][ \t]+\@I{[0-9]+}\@[ \t]+INDI\c', 'x')
                individual_id = Val(GetFoundText(1))
                if individual_id <> exclude_individual
                    if individual_id == initial_individual
                        selected_line = CurrLine()
                    endif
                    name = formatted_name(individual_name(individual_id), FORMAT_FULL)
                    GotoBufferId(names_buffer)
                    AddLine(name)
                    if individual_id == initial_individual
                        selected_line = CurrLine()
                    endif
                    longest_line = Max(longest_line, Length(name))
                    GotoBufferId(ids_buffer)
                    AddLine(Str(individual_id))

                    GotoBufferId(current_buffer)
                endif
            endwhile
        endif

        GotoBufferId(names_buffer)

        GotoLine(selected_line)

        if not (options & POPT_DISABLE_MENU)
            Hook(_LIST_STARTUP_, pick_individual_helper)
            picklist_width = Min( Max(Length(PICK_FOOTER), longest_line), Query(ScreenCols))
        else
            picklist_width = Min( longest_line, Query(ScreenCols))
        endif

        list_action = List(iif(Length(picklist_title), picklist_title, 'Choose Individual'), picklist_width)

        if list_action
            selected_line = CurrLine()

            if selected_line > 0
                GotoBufferId(ids_buffer)
                GotoLine(selected_line)
                selected_individual = Val(GetText(1,CurrLineLen()))
            endif

            if options & POPT_DISABLE_MENU
                list_action = LM_SELECT
            endif

            if list_action == LM_HELP
                    QuickHelp(pick_individual_help)
                    show_picklist = 1

            elseif list_action == LM_SHOW_MENU
                menu_flag = 0

                pick_individual_function_menu()

                if menu_flag & MENU_FLAG_NEW_INDIVIDUAL
                    list_action = LM_NEW_INDIVIDUAL
                elseif menu_flag & MENU_FLAG_NEW_FAMILY
                    list_action = LM_NEW_FAMILY
                elseif menu_flag & MENU_FLAG_JUMP_TO_FAMILY
                    list_action = LM_JUMP_TO_FAMILY
                else
                    // Menu cancelled, or "format gedcom data" chosen
                    // we can redisplay the picklist after updating the display
                    GotoBufferId(current_buffer)
                    UpdateDisplay()
                    show_picklist = 1
                endif

            endif

            if list_action == LM_DELETE
                PushBlock()
                GotoBufferId(current_buffer)
                mark_individual(selected_individual)
                KillBlock()
                PopBlock()
                show_picklist = 1

            elseif list_action == LM_SELECT
                show_picklist = 0

            elseif list_action == LM_NEW_INDIVIDUAL
                GotoBufferId(current_buffer)
                jump_to_individual(new_individual())
                lFind('NAME','')
                EndLine()
                Right()
                KillPosition()
                PushPosition()

            elseif list_action == LM_NEW_FAMILY
                GotoBufferId(current_buffer)
                jump_to_family(new_family())
                lFind('WIFE','')
                EndLine()
                Left()
                Left()
                KillPosition()
                PushPosition()

            elseif list_action == LM_JUMP_TO_FAMILY
                GotoBufferId(current_buffer)
                temp_id = pick_family(0, 0, POPT_EXCLUDE_NEW | POPT_DISABLE_MENU,'Jump to Family')
                if temp_id
                    jump_to_family(temp_id)
                    KillPosition()
                    PushPosition()
                else
                    show_picklist = 1
                endif
            endif
        endif

    endwhile

    AbandonFile(names_buffer)
    AbandonFile(ids_buffer)

    delete_invalid_links()

    PopPosition()
    return(selected_individual)
end

proc pick_family_helper ()
    if Enable(pick_family_keys)
        ListFooter(PICK_FOOTER)
    endif
    Unhook(pick_family_helper)
    BreakHookChain()
end

// pick_family:
//     brings up a picklist of all families in the database.
//     returns the id of the family chosen
//     returns 0 on cancel
//     returns -1 for "new family"
integer proc pick_family (integer initial_family, integer exclude_family, integer options, string picklist_title)
    integer current_buffer  = 0
    integer names_buffer    = 0
    integer ids_buffer      = 0
    integer selected_family = 0
    integer selected_line   = 0
    integer longest_line    = 1
    integer show_picklist   = 1
    integer list_action     = 1
    integer temp_id         = 0
    integer picklist_width  = 0

    integer family_id
    string  name[MAXSTRINGLEN]

    PushPosition()

    current_buffer      = GetBufferId()

    while show_picklist
        show_picklist = 0 // By default, close the picklist after first selection

        names_buffer = PrepTempBuffer(names_buffer)
        ids_buffer   = PrepTempBuffer(ids_buffer)

        if names_buffer and ids_buffer

            if not (options & POPT_EXCLUDE_NEW)
                GotoBufferId(names_buffer)
                AddLine('New...')
                GotoBufferId(ids_buffer)
                AddLine('-1')
            endif

            GotoBufferId(current_buffer)
            BegFile()

            while lFind('^[0-9][ \t]+\@F{[0-9]+}\@[ \t]+FAM\c', 'x')
                family_id = Val(GetFoundText(1))
                if family_id <> exclude_family
                    if family_id == initial_family
                        selected_line = CurrLine()
                    endif
                    name = family_description(family_id)
                    GotoBufferId(names_buffer)
                    AddLine(name)
                    if family_id == initial_family
                        selected_line = CurrLine()
                    endif
                    longest_line = Max(longest_line, Length(name))
                    GotoBufferId(ids_buffer)
                    AddLine(Str(family_id))

                    GotoBufferId(current_buffer)
                endif
            endwhile
        endif

        GotoBufferId(names_buffer)

        GotoLine(selected_line)

        if not (options & POPT_DISABLE_MENU)
            Hook(_LIST_STARTUP_, pick_family_helper)
            picklist_width = Min( Max(Length(PICK_FOOTER), longest_line), Query(ScreenCols))
        else
            picklist_width = Min( longest_line, Query(ScreenCols))
        endif

        list_action = List(iif(Length(picklist_title), picklist_title, 'Choose Family'), picklist_width)

        if list_action
            selected_line = CurrLine()

            if selected_line > 0
                GotoBufferId(ids_buffer)
                GotoLine(selected_line)
                selected_family = Val(GetText(1,CurrLineLen()))
            endif

            if options & POPT_DISABLE_MENU
                list_action = LM_SELECT
            endif

            if list_action == LM_HELP
                QuickHelp(pick_family_help)
                show_picklist = 1

            elseif list_action == LM_SHOW_MENU
                menu_flag = 0

                pick_family_function_menu()

                if menu_flag & MENU_FLAG_NEW_INDIVIDUAL
                    list_action = LM_NEW_INDIVIDUAL
                elseif menu_flag & MENU_FLAG_NEW_FAMILY
                    list_action = LM_NEW_FAMILY
                elseif menu_flag & MENU_FLAG_JUMP_TO_INDIVIDUAL
                    list_action = LM_JUMP_TO_INDIVIDUAL
                else
                    // Menu cancelled, or "format gedcom data" chosen
                    // we can redisplay the picklist after updating the display
                    GotoBufferId(current_buffer)
                    UpdateDisplay()
                    show_picklist = 1
                endif

            endif

            if list_action == LM_DELETE
                PushBlock()
                GotoBufferId(current_buffer)
                mark_family(selected_family)
                KillBlock()
                PopBlock()
                show_picklist = 1

            elseif list_action == LM_SELECT
                show_picklist = 0

            elseif list_action == LM_NEW_INDIVIDUAL
                GotoBufferId(current_buffer)
                jump_to_individual(new_individual())
                lFind('NAME','')
                EndLine()
                Right()
                KillPosition()
                PushPosition()

            elseif list_action == LM_NEW_FAMILY
                GotoBufferId(current_buffer)
                jump_to_family(new_family())
                lFind('WIFE','')
                EndLine()
                Left()
                Left()
                KillPosition()
                PushPosition()

            elseif list_action == LM_JUMP_TO_INDIVIDUAL
                GotoBufferId(current_buffer)
                temp_id = pick_individual(0, 0, POPT_EXCLUDE_NEW | POPT_DISABLE_MENU,'Jump to Individual')
                if temp_id
                    jump_to_individual(temp_id)
                    KillPosition()
                    PushPosition()
                else
                    show_picklist = 1
                endif
            endif
        endif

    endwhile

    AbandonFile(names_buffer)
    AbandonFile(ids_buffer)

    delete_invalid_links()

    PopPosition()
    return(selected_family)
end

proc individual_links_menu_helper()
    if Enable(individual_links_menu_keys)
        ListFooter(LM_FOOTER)
    endif
    Unhook(individual_links_menu_helper)
    BreakHookChain()
end

// Individual Links Menu
//
// individual_links_menu
// display a list of the relationships for this individual,
// and allow the user to follow, edit or delete these links.
//

constant SELECTED_NONE             = 0
constant SELECTED_INDIVIDUAL       = 1
constant SELECTED_FAMILY           = 2
constant SELECTED_MOTHER           = 4
constant SELECTED_FATHER           = 8
constant SELECTED_WIFE             = 16
constant SELECTED_HUSBAND          = 32
constant SELECTED_SIBLING          = 64
constant SELECTED_CHILD            = 128
constant SELECTED_SPOUSE           = 256
constant SELECTED_FAMILY_AS_CHILD  = 512
constant SELECTED_FAMILY_AS_SPOUSE = 1024

proc individual_links_menu (integer current_individual)
    integer current_buffer
    integer picklist_buffer = 0
    integer ids_buffer      = 0
    integer list_action
    integer longest_line = 1
    integer temp_id
    integer new_id
    integer selected_line
    integer primary_famc = Val(GetToken(as_child_family_ids(current_individual), ' ', 1))
    integer primary_fams = Val(GetToken(as_spouse_family_ids(current_individual), ' ', 1))

    integer selection
    integer show_picklist = 1

    integer i

    string  name[MAXSTRINGLEN]
    string  relations[MAXSTRINGLEN]

    PushPosition()

    current_buffer  = GetBufferId()

    while show_picklist
        show_picklist = 0 // By default, close the picklist after first selection

        if picklist_buffer
            EmptyBuffer(picklist_buffer)
        else
            picklist_buffer = CreateTempBuffer()
        endif
        if ids_buffer
            EmptyBuffer(ids_buffer)
        else
            ids_buffer = CreateTempBuffer()
        endif

        if picklist_buffer and ids_buffer

            GotoBufferId(current_buffer)

            temp_id = individual_father_id(current_individual)
            name = formatted_name(individual_name(temp_id), FORMAT_FULL)
            GotoBufferId(picklist_buffer)
            AddLine('Father: ' + name)

            GotoBufferId(ids_buffer)
            AddLine('IF:' + Str(temp_id))

            GotoBufferId(current_buffer)
            temp_id = individual_mother_id(current_individual)
            name = formatted_name(individual_name(temp_id), FORMAT_FULL)
            GotoBufferId(picklist_buffer)
            AddLine('Mother: ' + name)

            GotoBufferId(ids_buffer)
            AddLine('IM:' + Str(temp_id))
            GotoBufferId(current_buffer)

            relations = individual_spouse_ids(current_individual, 0)

            for i = 1 to NumTokens(relations, ' ')
                temp_id = Val(GetToken(relations, ' ', i))
                name = formatted_name(individual_name(temp_id), FORMAT_FULL)
                GotoBufferId(picklist_buffer)
                AddLine('Spouse: ' + name)

                GotoBufferId(ids_buffer)
                AddLine('IP:' + Str(temp_id))
                GotoBufferId(current_buffer)
            endfor

            relations = individual_sibling_ids(current_individual, 0)

            for i = 1 to NumTokens(relations, ' ')
                temp_id = Val(GetToken(relations, ' ', i))
                name = formatted_name(individual_name(temp_id), FORMAT_FULL)
                GotoBufferId(picklist_buffer)
                AddLine('Sibling: ' + name)

                GotoBufferId(ids_buffer)
                AddLine('IS:' + Str(temp_id))
                GotoBufferId(current_buffer)
            endfor

            relations = individual_children_ids(current_individual, 0)

            for i = 1 to NumTokens(relations, ' ')
                temp_id = Val(GetToken(relations, ' ', i))
                name = formatted_name(individual_name(temp_id), FORMAT_FULL)
                GotoBufferId(picklist_buffer)
                AddLine('Child: ' + name)

                GotoBufferId(ids_buffer)
                AddLine('IC:' + Str(temp_id))
                GotoBufferId(current_buffer)
            endfor

            relations = as_child_family_ids(current_individual)
            for i = 1 to NumTokens(relations, ' ')
                temp_id = Val(GetToken(relations, ' ', i))
                name = short_family_description(temp_id)
                GotoBufferId(picklist_buffer)
                AddLine('Family (as child): ' + name)

                GotoBufferId(ids_buffer)
                AddLine('FC:' + Str(temp_id))
                GotoBufferId(current_buffer)
            endfor

            relations = as_spouse_family_ids(current_individual)
            for i = 1 to NumTokens(relations, ' ')
                temp_id = Val(GetToken(relations, ' ', i))
                name = short_family_description(temp_id)
                GotoBufferId(picklist_buffer)
                AddLine('Family (as spouse): ' + name)

                GotoBufferId(ids_buffer)
                AddLine('FS:' + Str(temp_id))
            endfor

        endif

        GotoBufferId(picklist_buffer)
        BegFile()
        do NumLines() times
            longest_line = Max(longest_line, CurrLineLen())
            Down()
        enddo

        GotoBufferId(current_buffer)
        name = formatted_name(individual_name(current_individual), FORMAT_ABBREVIATE)
             + ' (' + Str(current_individual) + ')'

        Hook(_LIST_STARTUP_, individual_links_menu_helper)
        GotoBufferId(picklist_buffer)

        BegFile()

        list_action = List('Links for ' + name, Min( Max(Length(LM_FOOTER), longest_line), Query(ScreenCols)))

        if list_action == LM_HELP
            QuickHelp(individual_links_menu_help)
            show_picklist = 1

        else

            if list_action == LM_SHOW_MENU
                menu_flag = 0

                individual_function_menu()
                warn('menu_flag: ' + str(menu_flag))

                if menu_flag & MENU_FLAG_ADD_CHILD
                    list_action = LM_ADD_CHILD
                elseif menu_flag & MENU_FLAG_ADD_SIBLING
                    list_action = LM_ADD_SIBLING
                elseif menu_flag & MENU_FLAG_NEW_INDIVIDUAL
                    list_action = LM_NEW_INDIVIDUAL
                elseif menu_flag & MENU_FLAG_NEW_FAMILY
                    list_action = LM_NEW_FAMILY
                elseif menu_flag & MENU_FLAG_JUMP_TO_INDIVIDUAL
                    list_action = LM_JUMP_TO_INDIVIDUAL
                elseif menu_flag & MENU_FLAG_JUMP_TO_FAMILY
                    list_action = LM_JUMP_TO_FAMILY
                else
                    // Menu cancelled, or "format gedcom data" chosen
                    // we can redisplay the picklist after updating the display
                    GotoBufferId(current_buffer)
                    UpdateDisplay()
                    show_picklist = 1
                endif

            endif

            selected_line = CurrLine()
            GotoBufferId(ids_buffer)
            GotoLine(selected_line)
            temp_id = Val(GetText(4, CurrLineLen() - 3))

            selection = SELECTED_NONE

            case GetText(1,1)
                when 'I'
                    selection = selection | SELECTED_INDIVIDUAL
                    case GetText(2,1)
                        when 'F'
                            selection = selection | SELECTED_FATHER
                        when 'M'
                            selection = selection | SELECTED_MOTHER
                        when 'S'
                            selection = selection | SELECTED_SIBLING
                        when 'C'
                            selection = selection | SELECTED_CHILD
                        when 'P'
                            selection = selection | SELECTED_SPOUSE
                    endcase
                when 'F'
                    selection = selection | SELECTED_FAMILY
                    case GetText(2,1)
                        when 'C'
                            selection = selection | SELECTED_FAMILY_AS_CHILD
                        when 'S'
                            selection = selection | SELECTED_FAMILY_AS_SPOUSE
                    endcase
            endcase

            GotoBufferId(current_buffer)

            if list_action == LM_JUMP

                if temp_id
                    if selection & SELECTED_INDIVIDUAL
                        jump_to_individual(temp_id)
                        KillPosition()
                        PushPosition()
                    elseif selection & SELECTED_FAMILY
                        jump_to_family(temp_id)
                        KillPosition()
                        PushPosition()
                    endif
                else
                    list_action = LM_EDIT
                endif
            endif

            if list_action == LM_EDIT

                if selection & SELECTED_INDIVIDUAL

                    if selection & SELECTED_FATHER
                        new_id = pick_individual(temp_id, current_individual, POPT_DISABLE_MENU, 'Pick Father')
                        if new_id == -1
                            new_id = new_individual()
                            jump_to_individual(new_id)
                            KillPosition()
                            PushPosition()
                        else
                            show_picklist = 1
                        endif
                        if new_id
                            if primary_famc
                                delete_family_link(primary_famc, 'CHIL', current_individual)
                            else
                                primary_famc = new_family()
                                change_individual_link(current_individual, 'FAMC', 0, primary_famc)
                            endif
                            change_family_link(primary_famc, 'HUSB', temp_id, new_id)
                            add_family_link(primary_famc, 'CHIL', current_individual)
                        endif

                    elseif selection & SELECTED_MOTHER
                        new_id = pick_individual(temp_id, current_individual, POPT_DISABLE_MENU, 'Pick Mother')
                        if new_id == -1
                            new_id = new_individual()
                            jump_to_individual(new_id)
                            KillPosition()
                            PushPosition()
                        else
                            show_picklist = 1
                        endif
                        if new_id
                            if primary_famc
                                delete_family_link(primary_famc, 'CHIL', current_individual)
                            else
                                primary_famc = new_family()
                                change_individual_link(current_individual, 'FAMC', 0, primary_famc)
                            endif
                            change_family_link(primary_famc, 'WIFE', temp_id, new_id)
                            add_family_link(primary_famc, 'CHIL', current_individual)
                        endif
                    elseif selection & SELECTED_SIBLING
                        new_id = pick_individual(temp_id, current_individual, POPT_DISABLE_MENU, 'Pick Mother')
                        if new_id == -1
                            new_id = new_individual()
                            jump_to_individual(new_id)
                            KillPosition()
                            PushPosition()
                        else
                            show_picklist = 1
                        endif
                        if new_id
                            if not primary_famc
                                primary_famc = new_family()
                                change_individual_link(current_individual, 'FAMC', 0, primary_famc)
                            endif
                            delete_family_link(primary_famc, 'CHIL', temp_id)
                            add_family_link(primary_famc, 'CHIL', new_id)
                        endif

                    elseif selection & SELECTED_CHILD
                        new_id = pick_individual(temp_id, current_individual, POPT_DISABLE_MENU, 'Pick Child')
                        if new_id == -1
                            new_id = new_individual()
                            jump_to_individual(new_id)
                            KillPosition()
                            PushPosition()
                        else
                            show_picklist = 1
                        endif
                        if new_id
                            if not primary_fams
                                primary_fams = new_family()
                                change_individual_link(current_individual, 'FAMS', 0, primary_fams)
                            endif
                            delete_family_link(primary_fams, 'CHIL', temp_id)
                            add_family_link(primary_fams, 'CHIL', new_id)
                        endif

                    elseif selection & SELECTED_SPOUSE
                        new_id = pick_individual(temp_id, current_individual, POPT_DISABLE_MENU, 'Pick Spouse')
                        if new_id == -1
                            new_id = new_individual()
                            jump_to_individual(new_id)
                            KillPosition()
                            PushPosition()
                        else
                            show_picklist = 1
                        endif
                        if new_id
                            if not primary_fams
                                primary_fams = new_family()
                                change_individual_link(current_individual, 'FAMS', 0, primary_fams)
                            endif
                            delete_family_link(primary_fams, 'WIFE', temp_id)
                            delete_family_link(primary_fams, 'HUSB', temp_id)

                            if individual_sex(new_id) == 'F'
                                add_family_link(primary_fams, 'WIFE', new_id)
                            else
                                add_family_link(primary_fams, 'HUSB', new_id)
                            endif
                        endif
                    endif

                elseif selection & SELECTED_FAMILY_AS_CHILD
                    new_id = pick_family(temp_id, 0, POPT_DISABLE_MENU, 'Change Family (as child)')
                    if new_id == -1
                        new_id = new_family()
                        jump_to_family(new_id)
                        KillPosition()
                        PushPosition()
                    else
                        show_picklist = 1
                    endif
                    if new_id
                        change_individual_link(current_individual, 'FAMC', temp_id, new_id)
                        add_family_link(new_id, 'CHIL', current_individual)
                    endif

                elseif selection & SELECTED_FAMILY_AS_SPOUSE
                    new_id = pick_family(temp_id, 0, POPT_DISABLE_MENU, 'Change Family (as spouse)')
                    if new_id == -1
                        new_id = new_family()
                        jump_to_family(new_id)
                        KillPosition()
                        PushPosition()
                    else
                        show_picklist = 1
                    endif
                    if new_id
                        change_individual_link(current_individual, 'FAMS', temp_id, new_id)
                        if individual_sex(current_individual) == 'M'
                            change_family_link(new_id, 'HUSB', 0, current_individual)
                        elseif individual_sex(current_individual) == 'F'
                            change_family_link(new_id, 'WIFE', 0, current_individual)
                        endif
                    endif
                endif
            endif

            if list_action == LM_DELETE

                if selection & SELECTED_INDIVIDUAL
                    if selection & SELECTED_FATHER
                        delete_family_link(primary_famc, 'HUSB', 0)

                    elseif selection & SELECTED_MOTHER
                        delete_family_link(primary_famc, 'WIFE', 0)

                    elseif selection & SELECTED_SIBLING
                        delete_family_link(primary_famc, 'CHIL', temp_id)

                    elseif selection & SELECTED_CHILD
                        delete_family_link(primary_fams, 'CHIL', temp_id)
                    endif

                elseif selection & SELECTED_FAMILY_AS_CHILD
                    delete_individual_link(current_individual, 'FAMC', temp_id)

                elseif selection & SELECTED_FAMILY_AS_SPOUSE
                    delete_individual_link(current_individual, 'FAMS', temp_id)

                endif

                show_picklist = 1

            endif
            if list_action == LM_ADD_CHILD
                new_id = pick_individual(temp_id, current_individual, POPT_DISABLE_MENU, 'Add Child')
                if new_id == -1
                    new_id = new_individual()
                    jump_to_individual(new_id)
                    KillPosition()
                    PushPosition()
                else
                    show_picklist = 1
                endif
                if new_id
                    if not primary_fams
                        primary_fams = new_family()
                        change_individual_link(current_individual, 'FAMS', 0, primary_fams)
                    endif
                    add_family_link(primary_fams, 'CHIL', new_id)
                endif
            endif
            if list_action == LM_ADD_SIBLING
                new_id = pick_individual(temp_id, current_individual, POPT_DISABLE_MENU, 'Add Sibling')
                if new_id == -1
                    new_id = new_individual()
                    jump_to_individual(new_id)
                    KillPosition()
                    PushPosition()
                else
                    show_picklist = 1
                endif
                if new_id
                    if not primary_famc
                        primary_famc = new_family()
                        change_individual_link(current_individual, 'FAMC', 0, primary_famc)
                    endif
                    add_family_link(primary_famc, 'CHIL', current_individual)
                    add_family_link(primary_famc, 'CHIL', new_id)
                endif
            endif

            if list_action == LM_ADD_WIFE
                new_id = pick_individual(temp_id, current_individual, POPT_DISABLE_MENU, 'Add Wife')
                if new_id == -1
                    new_id = new_individual()
                    jump_to_individual(new_id)
                    KillPosition()
                    PushPosition()
                else
                    show_picklist = 1
                endif
                if new_id
                    if not primary_fams
                        primary_fams = new_family()
                        change_individual_link(current_individual, 'FAMS', 0, primary_fams)
                    endif
                    change_family_link(primary_fams, 'WIFE', 0, new_id)
                endif
            endif

            if list_action == LM_ADD_HUSBAND
                new_id = pick_individual(temp_id, current_individual, POPT_DISABLE_MENU, 'Add Husband')
                if new_id == -1
                    new_id = new_individual()
                    jump_to_individual(new_id)
                    KillPosition()
                    PushPosition()
                else
                    show_picklist = 1
                endif
                if new_id
                    if not primary_fams
                        primary_fams = new_family()
                        change_individual_link(current_individual, 'FAMS', 0, primary_fams)
                    endif
                    change_family_link(primary_fams, 'HUSB', 0, new_id)
                endif
            endif

            if list_action == LM_NEW_INDIVIDUAL
                jump_to_individual(new_individual())
                lFind('NAME','')
                EndLine()
                Right()
                KillPosition()
                PushPosition()
            endif

            if list_action == LM_NEW_FAMILY
                jump_to_family(new_family())
                lFind('WIFE','')
                EndLine()
                Left()
                Left()
                KillPosition()
                PushPosition()
            endif

            if list_action == LM_JUMP_TO_INDIVIDUAL
                temp_id = pick_individual(0,0, POPT_EXCLUDE_NEW | POPT_DISABLE_MENU,'Jump to Individual')
                if temp_id
                    jump_to_individual(temp_id)
                    KillPosition()
                    PushPosition()
                else
                    show_picklist = 1
                endif
            endif
            if list_action == LM_JUMP_TO_FAMILY
                temp_id = pick_family(0,0,POPT_EXCLUDE_NEW | POPT_DISABLE_MENU,'Jump to Family')
                if temp_id
                    jump_to_family(temp_id)
                    KillPosition()
                    PushPosition()
                else
                    show_picklist = 1
                endif
            endif
        endif

    endwhile

    AbandonFile(picklist_buffer)
    AbandonFile(ids_buffer)

    delete_invalid_links()

    PopPosition()
end


proc family_links_menu_helper()
    if Enable(family_links_menu_keys)
        ListFooter(LM_FOOTER)
    endif
    Unhook(family_links_menu_helper)
    BreakHookChain()
end

// Family Links Menu
//
// family_links_menu
// display a list of the relationships for the given family,
// and allow the user to follow, edit or delete these links.
//

proc family_links_menu (integer current_family)
    integer current_buffer
    integer picklist_buffer = 0
    integer ids_buffer      = 0
    integer list_action
    integer longest_line = 1
    integer temp_id
    integer new_id
    integer selected_line

    integer selection
    integer show_picklist = 1

    integer i

    string  name[MAXSTRINGLEN]
    string  relations[MAXSTRINGLEN]

    PushPosition()

    current_buffer  = GetBufferId()

    while show_picklist
        show_picklist = 0 // By default, close the picklist after first selection

        if picklist_buffer
            EmptyBuffer(picklist_buffer)
        else
            picklist_buffer = CreateTempBuffer()
        endif
        if ids_buffer
            EmptyBuffer(ids_buffer)
        else
            ids_buffer = CreateTempBuffer()
        endif

        if picklist_buffer and ids_buffer

            GotoBufferId(current_buffer)
            UpdateDisplay()

            temp_id = family_husb_id(current_family)
            name = formatted_name(individual_name(temp_id), FORMAT_FULL)
            GotoBufferId(picklist_buffer)
            AddLine('Husband: ' + name)

            GotoBufferId(ids_buffer)
            AddLine('IH:' + Str(temp_id))

            GotoBufferId(current_buffer)
            temp_id = family_wife_id(current_family)
            name = formatted_name(individual_name(temp_id), FORMAT_FULL)
            GotoBufferId(picklist_buffer)
            AddLine('Wife: ' + name)

            GotoBufferId(ids_buffer)
            AddLine('IW:' + Str(temp_id))
            GotoBufferId(current_buffer)

            relations = family_children_ids(current_family)

            for i = 1 to NumTokens(relations, ' ')
                temp_id = Val(GetToken(relations, ' ', i))
                name = formatted_name(individual_name(temp_id), FORMAT_FULL)
                GotoBufferId(picklist_buffer)
                AddLine('Child: ' + name)

                GotoBufferId(ids_buffer)
                AddLine('IC:' + Str(temp_id))
                GotoBufferId(current_buffer)
            endfor

        endif

        GotoBufferId(picklist_buffer)
        BegFile()
        do NumLines() times
            longest_line = Max(longest_line, CurrLineLen())
            Down()
        enddo

        GotoBufferId(current_buffer)
        name = 'Family #' + Str(current_family)

        Hook(_LIST_STARTUP_, family_links_menu_helper)
        GotoBufferId(picklist_buffer)

        BegFile()

        list_action = List('Links for ' + name, Min( Max(Length(LM_FOOTER), longest_line), Query(ScreenCols)))

        if list_action == LM_HELP
            QuickHelp(family_links_menu_help)
            show_picklist = 1
        else

            if list_action == LM_SHOW_MENU
                menu_flag = 0

                family_function_menu()

                if menu_flag & MENU_FLAG_ADD_CHILD
                    list_action = LM_ADD_CHILD
                elseif menu_flag & MENU_FLAG_NEW_INDIVIDUAL
                    list_action = LM_NEW_INDIVIDUAL
                elseif menu_flag & MENU_FLAG_NEW_FAMILY
                    list_action = LM_NEW_FAMILY
                elseif menu_flag & MENU_FLAG_JUMP_TO_INDIVIDUAL
                    list_action = LM_JUMP_TO_INDIVIDUAL
                elseif menu_flag & MENU_FLAG_JUMP_TO_FAMILY
                    list_action = LM_JUMP_TO_FAMILY
                else
                    // Menu cancelled, or "format gedcom data" chosen
                    // we can redisplay the picklist after updating the display
                    GotoBufferId(current_buffer)
                    UpdateDisplay()
                    show_picklist = 1
                endif

            endif

            selected_line = CurrLine()
            GotoBufferId(ids_buffer)
            GotoLine(selected_line)
            temp_id = Val(GetText(4, CurrLineLen() - 3))

            selection = SELECTED_NONE

            case GetText(1,1)
                when 'I'
                    selection = selection | SELECTED_INDIVIDUAL
                    case GetText(2,1)
                        when 'W'
                            selection = selection | SELECTED_WIFE
                        when 'H'
                            selection = selection | SELECTED_HUSBAND
                        when 'C'
                            selection = selection | SELECTED_CHILD
                    endcase
            endcase

            GotoBufferId(current_buffer)

            if list_action == LM_JUMP

                if temp_id
                    if selection & SELECTED_INDIVIDUAL
                        jump_to_individual(temp_id)
                        KillPosition()
                        PushPosition()
                    endif
                else
                    list_action = LM_EDIT
                endif
            endif

            if list_action == LM_EDIT

                if selection & SELECTED_INDIVIDUAL

                    if selection & SELECTED_HUSBAND
                        new_id = pick_individual(temp_id, 0, POPT_DISABLE_MENU, 'Pick Husband')
                        if new_id == -1
                            new_id = new_individual()
                            jump_to_individual(new_id)
                            KillPosition()
                            PushPosition()
                        else
                            show_picklist = 1
                        endif
                        if new_id
                            change_family_link(current_family, 'HUSB', temp_id, new_id)
                        endif

                    elseif selection & SELECTED_WIFE
                        new_id = pick_individual(temp_id, 0, POPT_DISABLE_MENU, 'Pick Wife')
                        if new_id == -1
                            new_id = new_individual()
                            jump_to_individual(new_id)
                            KillPosition()
                            PushPosition()
                        else
                            show_picklist = 1
                        endif
                        if new_id
                            change_family_link(current_family, 'WIFE', temp_id, new_id)
                        endif

                    elseif selection & SELECTED_CHILD
                        new_id = pick_individual(temp_id, 0, POPT_DISABLE_MENU, 'Pick CHild')
                        if new_id == -1
                            new_id = new_individual()
                            jump_to_individual(new_id)
                            KillPosition()
                            PushPosition()
                        else
                            show_picklist = 1
                        endif
                        if new_id
                            delete_family_link(current_family, 'CHIL', temp_id)
                            add_family_link(current_family, 'CHIL', new_id)
                        endif
                    endif

                endif

            endif

            if list_action == LM_DELETE

                if selection & SELECTED_INDIVIDUAL
                    if selection & SELECTED_HUSBAND
                        delete_family_link(current_family, 'HUSB', 0)
                    elseif selection & SELECTED_WIFE
                        delete_family_link(current_family, 'WIFE', 0)
                    elseif selection & SELECTED_CHILD
                        delete_family_link(current_family, 'CHIL', temp_id)
                    endif

                endif

                show_picklist = 1

            endif
            if list_action == LM_ADD_CHILD
                new_id = pick_individual(temp_id, 0, POPT_DISABLE_MENU, 'Add Child')
                if new_id == -1
                    new_id = new_individual()
                    jump_to_individual(new_id)
                    KillPosition()
                    PushPosition()
                else
                    show_picklist = 1
                endif
                if new_id
                    add_family_link(current_family, 'CHIL', new_id)
                endif
            endif

            if list_action == LM_NEW_INDIVIDUAL
                jump_to_individual(new_individual())
                lFind('NAME','')
                EndLine()
                Right()
                KillPosition()
                PushPosition()
            endif

            if list_action == LM_NEW_FAMILY
                jump_to_family(new_family())
                lFind('WIFE','')
                EndLine()
                Left()
                Left()
                KillPosition()
                PushPosition()
            endif
        endif

    endwhile

    AbandonFile(picklist_buffer)
    AbandonFile(ids_buffer)

    delete_invalid_links()

    PopPosition()
end

proc current_links_menu()
    integer id

    id = current_individual_id()
    if id
        individual_links_menu(id)
    else
        id = current_family_id()
        if id
            family_links_menu(id)
        endif
    endif
end

proc smart_format_gedcom_data()
    if isBlockMarked() and isBlockInCurrFile()
        format_gedcom_data(SCOPE_LOCAL)
    else
        format_gedcom_data(SCOPE_GLOBAL)
    endif
end

proc pick_and_jump_to_individual()
    integer id = pick_individual(0,0,POPT_EXCLUDE_NEW,'Jump to Individual')
    if id
        jump_to_individual(id)
    endif
end

proc pick_and_jump_to_family()
    integer id = pick_family(0,0,POPT_EXCLUDE_NEW,'Jump to Family')
    if id
        jump_to_family(id)
    endif
end

menu global_function_menu()
    title = 'GEDCOM functions'
    history
    'Jump to Individual' , pick_and_jump_to_individual()        , , 'Pick an individual and jump to it'
    'Jump to Family'     , pick_and_jump_to_family()            , , 'Pick a family and jump to it'
    'New Individual'     , jump_to_individual(new_individual()) , , 'Create a new individual'
    'New Family'         , jump_to_family(new_family())         , , 'Create a new family'
    'Indent Block/File'  , smart_format_gedcom_data()           , , 'Nicely format the block (if marked) or the whole file'
    'Repair Links'       , delete_invalid_links()               , , 'Remove Invalid Links from records'
end

menu pick_individual_function_menu()
    title = 'GEDCOM functions'
    history
    'Jump to Family'     , set_menu_flag(MENU_FLAG_JUMP_TO_FAMILY) , , 'Pick a family and jump to it'
    'New Individual'     , set_menu_flag(MENU_FLAG_NEW_INDIVIDUAL) , , 'Create a new individual'
    'New Family'         , set_menu_flag(MENU_FLAG_NEW_FAMILY)     , , 'Create a new family'
    'Indent Block/File'  , smart_format_gedcom_data()              , , 'Nicely format the block (if marked) or the whole file'
end

menu pick_family_function_menu()
    title = 'GEDCOM functions'
    history
    'Jump to Individual' , set_menu_flag(MENU_FLAG_JUMP_TO_INDIVIDUAL)  , , 'Pick an individual and jump to it'
    'New Individual'     , set_menu_flag(MENU_FLAG_NEW_INDIVIDUAL)      , , 'Create a new individual'
    'New Family'         , set_menu_flag(MENU_FLAG_NEW_FAMILY)          , , 'Create a new family'
    'Indent Block/File'  , smart_format_gedcom_data()                   , , 'Nicely format the block (if marked) or the whole file'
end

menu individual_function_menu()
    title = 'GEDCOM functions'
    history
    'Add Child'          , set_menu_flag(MENU_FLAG_ADD_CHILD)          , , "Add a child to this individual's primary family"
    'Add Sibling'        , set_menu_flag(MENU_FLAG_ADD_SIBLING)        , , "Add a sibling to this individual's primary family"
    'Jump to Individual' , set_menu_flag(MENU_FLAG_JUMP_TO_INDIVIDUAL) , , 'Pick an individual and jump to it'
    'Jump to Family'     , set_menu_flag(MENU_FLAG_JUMP_TO_FAMILY)     , , 'Pick a family and jump to it'
    'New Individual'     , set_menu_flag(MENU_FLAG_NEW_INDIVIDUAL)     , , 'Create a new individual'
    'New Family'         , set_menu_flag(MENU_FLAG_NEW_FAMILY)         , , 'Create a new family'
    'Indent Block/File'  , smart_format_gedcom_data()                  , , 'Nicely format the block (if marked) or the whole file'
end

menu family_function_menu()
    title = 'GEDCOM functions'
    history
    'Add Child'          , set_menu_flag(MENU_FLAG_ADD_CHILD)          , , 'Add a child to this family'
    'Jump to Individual' , set_menu_flag(MENU_FLAG_JUMP_TO_INDIVIDUAL) , , 'Pick an individual and jump to it'
    'Jump to Family'     , set_menu_flag(MENU_FLAG_JUMP_TO_FAMILY)     , , 'Pick a family and jump to it'
    'New Individual'     , jump_to_individual(new_individual())        , , 'Create a new individual'
    'New Family'         , jump_to_family(new_family())                , , 'Create a new family'
    'Indent Block/File'  , smart_format_gedcom_data()                  , , 'Nicely format the block (if marked) or the whole file'
end

// This is hooked via _ON_CHANGING_FILES_
proc keydef_handler ()
    if in_gedcom_file()
        Enable(gedcom_keybindings)
    else
        Disable(gedcom_keybindings)
    endif
end

proc WhenLoaded()
    // Set(BREAK, ON)
    Hook(_ON_CHANGING_FILES_, keydef_handler)
    keydef_handler()
end



