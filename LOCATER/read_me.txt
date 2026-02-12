                         LocateNear / LocateNextTo

    While many use Tse to edit program source code, I suspect many use it
    to edit plain text files filled with words, sentences, and lines.
    These two macros tackle the age-old problem of searching for
    multiple words in a text file, where those words may be separated by
    a line break, or even by other words or punctuation.  DOS EOLs do
    not allow searches to span line breaks.  But with the new 16,000
    column line length available in TsePro 4.0 nearly any paragraph can
    be re-wrapped to a single line.  For that matter, even the shorter
    limits of previous versions will handle most paragraphs.

    For a long time, I would open a file, reset the margins to the
    maximum, then do the searching.  Then, hopefully, I would not forget
    and save the file with long-line format.  I also had to do a lot of
    scrolling to view the lines that contained the targets, or put them
    into a new buffer and re-wrap them to the original width.

    These two macros represent my attempt at eliminating all the extra
    steps, as well as the potential for messing up the original file.

    The reason for two separate macros is this: sometimes I want to
    find, for example, the two words "new" and "year" with no other text
    between them.  But I do want to find any occurrences of "new" as the
    last word on one line, and "year" as the first word on the next
    line.  For this type of search, use the "LocateNextTo" macro, which
    is contained in "LocNxtTo.s" in case any 2.5 users want to try it.

    There may be other occasions when I want to find the words "new" and
    "year" within the same paragraph, but with any combination of text,
    punctuation, or space characters between them.  Use "LocateNear" to
    find, for example, "the new policy goes into effect next year."  The
    macro is contained in "LocNear.s" and can be altered to suit your
    particular needs, or your version of Tse, then compiled.

    The first and second targets may contain more than one word.  If
    necessary, adjust the [40] string size to handle your needs.

    Both macros work by re-wrapping the original text into single-line
    paragraphs for searching purposes.  All work is done on a COPY of
    the original file in a temporary buffer.  No changes are made to the
    original file.  Each find is appended to a file named "Found.txt" in
    the current directory

    You may assign these macros to a key combination if you wish, make
    them available through the potpourri, or execute either one by name
    from the macro menu.

    If you can re-work this to make it more professinal and more
    efficient, go right ahead.  I'm not much of a programmer, just a
    great lover of Tessie!

    Ed Marsh
    edmarsh@mountain.net

