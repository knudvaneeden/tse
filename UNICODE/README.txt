Created by Carlo Hogeveen (http://ecarlo.nl/tse)

===

1. -To install

     1. -Take the file unicode_knud.zip

     2. -And unzip it in any arbitrary directory

     3. -Then run the file zipinstallunicode.bat

     4. -That will create a new file unicode_knud.zip
         in that directory

     5. -Unzip that latest file in a new arbitrary directory

     6. -Then run the file

          unicode_main.mac

2. -The .ini file is the local file 'unicode.ini'
    (thus not using tse.ini)

===

/*
  Macro           Unicode
  Author          Carlo Hogeveen
  Website         eCarlo.nl/tse
  Compatibility   Windows GUI TSE v4       upwards with an ANSI compatible font,
                  Linux       TSE v4.41.35 upwards
  Version         v2.6   24 Sep 2022



  PURPOSE

    Extends TSE with the ability to view and edit Unicode files.

    It supports all major Unicode character encodings (UTF-8, UTF-16, UTF-32)
    and their variants; big endian (BE) and little endian (LE),
    either with or without a byte order mark (BOM).

    Given that TSE at best is still only capable of showing ANSI characters, it
    works by converting Unicode to ANSI and back when you load and save a file,
    substituting quoted codepoints for ANSI-incompatible characters.

    So for Unicode characters that do have an ANSI equivalent the TSE editing
    text contains the ANSI character.
    Assuming you are viewing now with an ANSI compatible TSE version,
    this means that beside the basic ASCII characters the following characters
    can now be edited WYSIWYG for Unicode files too:
      € ‚ ƒ „ … † ‡ ˆ ‰ Š ‹ Œ Ž ‘ ’ “ ” • – — ˜ ™ š › œ ž Ÿ ¡
      ¢ £ ¤ ¥ ¦ § ¨ © ª « ¬ ­ ® ¯ ° ± ² ³ ´ µ ¶ · ¸ ¹ º » ¼ ½ ¾ ¿
      À Á Â Ã Ä Å Æ Ç È É Ê Ë Ì Í Î Ï Ð Ñ Ò Ó Ô Õ Ö × Ø Ù Ú Û Ü Ý Þ ß
      à á â ã ä å æ ç è é ê ë ì í î ï ð ñ ò ó ô õ ö ÷ ø ù ú û ü ý þ ÿ

    Non-ANSI Unicode characters are shown as quoted hexadecimal Unicode
    codepoints, using the DELETE character (dec 127, hex 7F, shown as a white
    square or a black diamond) as the quoting character. Additionally the
    current codepoint's character description is shown as a status. In Windows
    you can optionally preview the current character, but this is default
    turned OFF because it works imperfectly.

    All possible character encoding conversions are lossless.

    The current file's ASCII, ANSI or Unicode encoding is shown as a status.

    By right-clicking (Windows only) or
    by pressing [Shift] F10 on the Unicode status or charcter description or
    by executing this macro extension, you can:
    - Get this Help.
    - Select and insert any Unicode character from a shrink-as-you-type list.
    - Change the current file's character encoding.
    - Configure statusses, default actions, warnings.
    - Windows only: Configure previewing one non-ANSI character at a time.



  INSTALLATION INSTRUCTIONS

    Read on past the terminology topics and the extensive (dis)claimers!



  TERMINOLOGY

    Codepoint
      A codepoint is the Unicode *administrative* number to identify a
      character independent of how that character is encoded in bytes.
      So a character's codepoint is the same for UTF-8, UTF-16 and UTF-32,
      either big endian or little endian, and can informally even be used for
      identifying ASCII and ANSI characters.
      For instance "é" ("LATIN SMALL LETTER E WITH ACUTE") is always uniquely
      identified by codepoint 233 (hexadecimal: E9) independent of what bytes
      are used for it in an actual text file.

    Character encoding (character code format)
      Character encoding is the official term as found on unicode.org.
      Character code format is an unofficial and maybe even incorrect term for
      the same thing, that occasionally may still occur in this file.
      The documentation and interface now use the Unicode term.
      BYTE
        A byte is the smallest number a computer can address in its memory, and
        it can have values 0 through 255. A character encoding defines what
        bytes (one or more) are used to encode a character in a text file.
      ASCII
        The oldest character encoding TSE understands is ASCII, a 1 byte encoding
        that only uses the values 0 through 127. You can view them in what TSE's
        menu incorrectly calls its "ASCII Chart". Incorrectly because this chart
        also contains another 128 characters (128 - 255).
      ANSI
        ANSI is an informal name for the Windows-1252 character encoding,
        sometimes also referenced as "CP1252".
        There are many 1 byte standards (implemented in "codepages") that
        define different characters for byte values 128 through 255, but for
        originally Western European languages the ANSI standard is the most
        common. ANSI is a superset of ASCII: it adds characters with
        diacritical marks and some other typical characters for its language
        group.
        ANSI is still supported by Windows (APIs), and Windows can do automatic
        conversions from and to it.
        ANSI is supported by the Windows GUI version of TSE if TSE uses an ANSI
        compatible font like Courier New" (which it default does).
        ANSI is default supported by the Linux beta of TSE from version
        v.4.41.31 upwards.
        Note that ANSI does not define printable characters for ASCII's control
        characters 0 - 31, nor for characters 127, 129, 141, 143, 144 and 157,
        so ANSI's 1-byte character encoding defines 218 printable characters.
      UNICODE
        Unicode supports more than 100.000 characters and it often uses several
        bytes per character.
        Ther term "Unicode" refers to a group of (five main) character
        encodings (ways to encode characters), which all share the same
        codepoints (an administrative character number), characters and
        character descriptions, but which each have their own algorithm
        to convert a codepoint to bytes and back.
        In files those bytes are used, not the codepoints.
        There is no default Unicode character encoding.
        Unicode has five main character encodings:
          UTF-8, UTF-16LE, UTF-16BE, UTF-32LE and UTF-32BE.
          UTF-16LE and UTF-16BE are the same except for their endianness.
          UTF-32LE and UTF-32BE are the same except for their endianness.
        Endianness:
          For us humans endianness refers to the *LEFT END* (!) of a number.
          In a file endianness refers to the first byte of a number.
          In computer memory endianness refers to the byte with the lowest
          memory address of a sequence of bytes representing a number.
          We call a (number/character) encoding "big endian" if the
          left-most/first byte is the most significant one, and "little endian"
          if the left-most/first byte is the least significant one.
          For example, in English we humans write our numbers big endian, e.g.
          we *start* the number 1234 with the "big" digit 1, which is the most
          significant digit because it stands for the value one thousand.
          Not literally but for demonstration's sake; a file or computer that
          uses little endian would write that number as 4321, *starting* with
          the "little" digit 4, which is the least significant digit because
          it only stands for the value four.
        UTF-8
          uses one byte for ASCII characters (with the same byte value),
          because those are the most used, and two to four bytes for
          increasingly less used characters.
        UTF-16
          usually uses two bytes, and occasionally four bytes.
          Warning: While the bytes of UTF-16 are often just a transposition
          from their codepoint, that is totally untrue for the occasionally
          occurring codepoints that are implemented by four bytes.
          ( UCS-2 is an obsolete version of UTF-16 that only implemented the
            characters that need two bytes. As such it does not cover full
            Unicode. So this TSE extension can open a file that elsewhere was
            saved as UCS-2, and it will see and report it as a UTF-16 file. )
        UTF-32
          always uses four bytes.
        Combining it all, here is an example of the character encodings for the
        characters "LATIN SMALL LETTER E WITH ACUTE" and "EURO SIGN", that do
        not exist in ASCII, and that have these properties across ANSI and the
        the various Unicode character encodings:
          "LATIN SMALL LETTER E WITH ACUTE"   "EURO SIGN"
          ---------------------------------   ---------------------------------
          Character  Unicode    Bytes used    Character  Unicode    Bytes used
          encoding   codepoint  in a file     encoding   codepoint  in a file
          ---------  ---------  ----------    ---------  ---------  ----------
          ANSI                  E9            ANSI                  80
          UTF-8      E9         C3 A9         UTF-8      20AC       E2 82 AC
          UTF-16BE   E9         00 E9         UTF-16BE   20AC       20 AC
          UTF-16LE   E9         E9 00         UTF-16LE   20AC       AC 20
          UTF-32BE   E9         00 00 00 E9   UTF-32BE   20AC       00 00 20 AC
          UTF-32LE   E9         E9 00 00 00   UTF-32LE   20AC       AC 20 00 00
        So if you were to open a UTF-8 file containing the letter "LATIN SMALL
        LETTER E WITH ACUTE" using TSE without this Unicode extension, then you
        would see the bytes C3 and A9 as the two characters "Ã" and "©" instead
        of the single character "é".
        This Unicode extension can not magically show the "pictures" of
        characters that ANSI does not support, but upon loading and saving
        a Unicode file it can convert the byte codes for those characters
        that ANSI and Unicode have in common, and it can substitute other
        characters with a code representation in the text and a desciption
        for the current code representation as a status.

    BOM
      The term "BOM" stands for "byte order mark".
      A Unicode file can start with a hidden character.
      Unicode names this character "ZERO WIDTH NO-BREAK SPACE".
      Because this character naturally does not appear at the start of text,
      and because the newer Unicode standards say it that can not appear
      there to mean a space, and because it naturally consists of a different
      sequence of bytes in UTF-8, UTF-16BE, UTF-16LE, UTF-32BE, and UTF-32LE,
      it can instead be used at the start of a Unicode file to explicitly
      indicate a file's Unicode format.

    Formal Unicode encoding name (a.k.a. label) vs displayed encoding name
      Formally Unicode has rules to externally name a text's character encoding,
      but those rules are stupid, because they define imprecise names.
      A text editor on the other hand can usually make a very precise
      determination of the actual Unicode encoding used in a file.
      Most other tools use the formal, imprecise naming convention, but in this
      case I choose practical usefulness over formal correctness.

      Instead of the formal shortened imprecise encoding name this macro
      displays a full precise encoding name as a status:
        Formal
        external
        Unicode
        name     (without this description)         Displayed name
        ---------------------------------------     --------------
        UTF-8    (without a BOM)                    UTF-8
        UTF-8    (with    a BOM)                    UTF-8+BOM
        UTF-16   (without a BOM, big    endian)     UTF-16BE
        UTF-16   (with    a BOM, big    endian)     UTF-16BE+BOM
        UTF-16   (with    a BOM, little endian)     UTF-16LE+BOM
        UTF-16BE (without a BOM, big    endian)     UTF-16BE
        UTF-16LE (without a BOM, little endian)     UTF-16LE
        UTF-32   (without a BOM, big    endian)     UTF-32BE
        UTF-32   (with    a BOM, big    endian)     UTF-32BE+BOM
        UTF-32   (with    a BOM, little endian)     UTF-32LE+BOM
        UTF-32BE (without a BOM, big    endian)     UTF-32BE
        UTF-32LE (without a BOM, little endian)     UTF-32LE



  CLAIMER
    I use this macro myself, and have taken some care that it will meet its
    described functionality. At the time of its release it will contain no
    errors that I perceived as such and are not described here.



  DISCLAIMER
    This macro is provided "as is". I cannot and do not garantee, that the
    macro is error free, nor that my intentions will meet your expectations.
    The macro may contain errors and it may damage files you edit and thereby
    damage anything depending on those files.
    Either use the macro at your own risk, or simply do not use it at all.



  KNOWN ERRORS
    The upgrade action when you add a non-ASCII character to an ASCII file or
    a non-ANSI character to an ANSI file happens with a delay of up to two
    seconds. If you are really quick and unlucky, you can therefore save a
    former ASCII or ANSI file with an erroneous non-UTF character encoding
    within that delay.

    You can configure that the current character can be previewed at some fixed
    location. Theoretically most Unicode characters can be previewed one at a
    time this way. In practice this feature has several known display errors.



  KNOWN LIMITATIONS

    The detection of Unicode files without a BOM has natural limitations.
    In some cases the required information just is not there.
    For empty files detection is impossible: They are shown as ASCII files.
    For UTF-16 and UTF-32 files without a BOM detection is near perfect
    for (originally) "Western European" languages.
    And the big one:
      "UTF-8 files without a BOM that only contain ASCII characters" are
      indistinguishable from "ASCII files"!
      In practice this is not a problem because they really are the same.
      We just need to wrap our heads around that when we save a UTF-8 file
      witout a BOM, and close and reopen it, it might open as an ASCII file.
    This macro mitigates these limitations by detecting when you start using
    non-ASCII characters in an ASCII file, or non-ANSI characters in an ASCII
    or ANSI file, and then performing a configurable upgrade-action. The
    default is to ask you for a new character encoding.

    A file's character encoding is not shown when there is not sufficiant
    empty space on the right hand side of the window.
    Likewise a characters description won't be shown under those conditions.



  KNOWN DISADVANTAGES
    With the exception of saving ASCII and ANSI files, the loading and saving
    of files will be slower depending on their size and the presence of a BOM.
    - Firstly and minorly, when opening a file its character encoding must be
      detected by preloading a part of the file in binary format. If the file
      is a Unicode file with a byte order mark (BOM) then the preloaded part
      can remain tiny, making this step's overhead negligible. Otherwise the
      size of the preloaded part is determined by a configuration option, so
      you can choose between loading speed and correct character encoding
      recognition. Note that even ASCII and ANSI files go through this step,
      and they cannot have a BOM. That said, since version v1.5 of this macro
      the preloaded part can be small and this step has become very fast.
    - Secondly and mainly, Unicode <-> ANSI conversions take time.
      UTF-8 <-> ANSI conversions are very fast.
      UTF-16/32 <-> ANSI conversions are very slow. Their main time-consumer is
      the simple replacement of each one-byte character by a two-byte or
      four-byte character or the other way around: In v2.3 of this macro I
      found a way to make UTF-16/32 conversion 3 times faster for loading and
      4½ times faster for saving a file. I spotted a yet theoretical way to
      make these faster by yet another factor, but that is for some future
      version, that will come closer if someone asks for it.


  KNOWN ISSUES
    If you mark a block with CUAmark keys and use one of the Unicode Copy
    or Cut actions, then CUAmark will unmark the block.   :-(



  CAVEAT
    Many other "Unicode compatible" applications and tools do not understand
    *all* of the major Unicode encodings, are vague about which specific ones
    they do support, and some even report it as a "Unicode error" if you do
    not offer them one of their supported Unicode encodings.
    In general they tend to favour UTF-8 and UTF-16(LE), and (with the
    exception of compilers) they tend to favour the encodings with a
    byte order mark (BOM).
    The bright side:
    - TSE will understand and identify their specific Unicode encoding.
    - TSE can change any Unicode format to any other Unicode format.

    A special warning for TSE macro programmers about macro source files:
    - There are only downsides to making a TSE macro a Unicode file:
      - Anything other than UTF-8 will not compile at all.
      - It can not have a byte order mark (BOM): The macro compiler will see it
        as an invalid character at line 1 column 1.
      - TSE procedure and variable names only support ASCII.
      - TSE's interactive commands expect ANSI parameters at best, and produce
        garbage for Unicode characters.
      - When used in comments Unicode will show as unreadable characters for
        other users who do not use the Unicode extension.



  INSTALLATION INSTRUCTIONS

    STEP 1
      This version of the Unicode macro needs at least version 1.2
      of the Status macro to be pre-installed. You should be able
      to download it from eCarlo.nl/tse too.

    STEP 2
      If right now you are reading this file in TSE, and you see this "…"
      character as a smaller version of "...", then you are already using
      a GUI version of TSE and your TSE font setting is probably
      already ANSI compatible, so you can skip step 2 and go to step 3.

      Otherwise you need to change to a GUI version of TSE and you need to
      change TSE's font setting to an ANSI compatible font for this extension
      to work, for example to "Courier New".

      No, this macro does not work for the Windows Console version of TSE
      (e32.exe), and setting the font to Courier New does not work there.

      In Windows you can change TSE's font by clicking on the top left TSE icon
      or by pressing <Alt Space>.
      After changing the font you need to make the change permanent by applying
      the TSE menu "Options -> Save Current Settings".

      Examples of TSE GUI plus ANSI compatible Windows fonts:
        Consolas
        Courier New
        Lucinda Console
        Lucida Sans Typewriter

      Examples of not ANSI compatible fonts:
        Courier
        Fixedsys
        Terminal

    STEP 3
      Copy the files
        Unicode.s
        UnicodeData.txt
        NamesList.txt
      to TSE's "mac" folder.

      Compile the Unicode.s file in TSE's "mac" folder, for instance by opening
      it in TSE and using the "Macro -> Compile" menu.

      Execute the macro at least once to activate it,
      for instance by using the menu Macro -> Execute -> "Unicode".

      By executing the macro you have configured its default options.
      Any further configuration is optional.
      Just press <escape> to leave the configuration menu.

      You should now see the current file's character encoding roughly
      in the top right corner of the screen, for instance "ASCII" or "ANSI".

      In Windows right-click on it if you want to change the character encoding
      or if you want to insert a Unicode character in your text
      or if you want to change the macro's configuration.

    STEP 5   (Only for EolType users)
      The EolType macro is not required for the Unicode macro to work.
      However, if you already are a user of the EolType macro, then you must
      upgrade it to at least version 7, because older versions can not reliably
      determine the end-of-line-type for UTF-16 and UTF-32 files.

    STEP 6   (Optional)
      In your TSE user interface (.ui) file you can configure TSE keys
      for the following Unicode actions
      - Insert a selected Unicode character into your text.
      - Copy marked text to the Windows clipboard as UTF-8.
      - Cut  marked text to the Windows clipboard as UTF-8.
      - Paste ASCII/ANSI/Unicode text from the Windows clipboard.

      You can already do these actions
      - From the Unicode menu after right-clicking a Unicode status
        or pressing <F10> or <Shift F10> when the cursor is on the status.
      - From the Unicode menu after executing the Unicode macro.

      But you can also assign them a key in your .ui file, recompile the .ui
      file as a macro, and restart TSE.
      For example:
        <CtrlShift I>   ExecMacro('Unicode InsertCharacter')
        <CtrlShift C>   ExecMacro('Unicode Copy')
        <CtrlShift X>   ExecMacro('Unicode Cut')
        <CtrlShift V>   ExecMacro('Unicode Paste')

      Considerations for replacing the standard <Ctrl C>, <Ctrl X>,
      and <Ctrl V> keys:
      - You might need to disable these keys in the CUAmark extension
        by executing the macro "CUAmark".
      - The Unicode Copy, Cut and Paste are slower, but not horribly so.
        IMHO this is only an issue for very large blocks/clipboards.



  BACKGROUND INFORMATION

    https://www.unicode.org/faq/utf_bom.html
    https://en.wikipedia.org/wiki/UTF-8
    https://en.wikipedia.org/wiki/Unicode
    https://unicode-table.com/en/
    http://www.alanwood.net/demos/ansi.html
    https://unicode.org/Public/UNIDATA/NamesList.txt

    For codepoint to/from UTF-16 conversion I used definition "D91" from:
      http://www.unicode.org/versions/Unicode11.0.0/ch03.pdf#G7404

    The Unicode v14.0.0 data files for character names and descriptions
      UnicodeData.txt
      NamesList.txt
    were downloaded on 10 Oct 2021 from
      https://www.unicode.org/Public/UCD/latest/ucd/
    No garantee, but future versions of these files downloaded from there
    will have a reasonable chance of working with this macro too.



  MACRO PROGRAMMER DOCUMENTATION

  No TSE debugging mode.
    The Unicode macro is much too big to be run in TSE's debugging mode.
    A solution would be to split the macro in smaller debuggable parts,
    but that would make it harder to install for end users.

  Garbage in, garbage out
    There are lots of opportunities to encounter garbage.
    A unicode file might be corrupt (Formal term: "ill formed"), the user might
    have edited a codepoint to become illegal, or I might have made a
    programming error.
    Because we do not want the Unicode macro to crash in the first two cases,
    and because I do want a way to debug any errors, I did the following.
    Whenever the macro encounters an illegal condition it does not crash,
    but it does call gigo(), makes a best guess to recover, and continues.
    gigo() is a function that normally does nothing, but is already in place
    where it can be used for signalling and debugging illegal conditions.

  UTF-16 and UTF-32 conversion:
    Letting TSE itself load a UTF-16/32 file "as is" has these disadvantages:
    - We can not use the loaded file: It lost needed conversion information
      because byte values 13 and 10 are not always a carriage return and a line
      feed in UTF-16/32.
    - TSE itself interrupts loading a UTF-16LE file to give a warning that
      waits for a key press.
    - Loading an unusable file wastes a significant amount of time.
    So the method to open a UTF16/32 file is:
    - In the _ON_FILE_LOAD_ hook:
      - Set the yet unloaded file to binary mode. (*2)
      - Set a buffer flag.
    - In the _ON_FIRST_EDIT_ hook, if the buffer flag is set:
      - The file is already loaded in binary mode.
      - Delete the buffer flag.
      - Convert the buffer content from UTF and binary to ANSI and normal.
    The method to save a UTF-16/32 file is:
    - In the _ON_FILE_SAVE_ hook:
      - Backup the current ANSI buffer to a buffer or file.
      - Set the current buffer from normal to binary mode.
      - Convert the current buffer from normal ANSI to binary UTF-16/32.
        Solve the end-of-line-type problem (*3) by optionally using
        the EolType macro.
    - In the _AFTER_FILE_SAVE_ hook:
      - Set the current buffer from binary to normal mode.
      - Empty the current buffer.
      - Restore the backup ANSI buffer or file to the current buffer.

    (*2)
      TSE's BinaryMode() is counter-intuitive and a pain to work with, but once
      its oddities are understood they can be worked around.
      These are the tricky parts:
      - In binary mode TSE still works with lines, which is a major pain
        whenever something needs to be done with consecutive bytes.
        Unfortunately TSE's maximum line size still applies.
      - Setting a buffer in binary mode with BinaryMode(N) where N > 0
        only impacts future loads and saves of the buffer:
        During loading it loads carriage returns and line feeds as characters
        instead of using them to split the file into lines, and it will create
        buffer lines with length N (except for the last buffer line).
        During saves it will not add a carriage return and/or line feed to the
        end of each buffer line.
      - BinaryMode(N > 0) has no impact on editing whatsoever: Deleting or
        inserting a character shortens and lengthens its line without any
        impact on the next line. You can insert and delete empty lines without
        any impact on the future saved file.
      - When saving a normal buffer (one not in binary mode) the editor adds a
        newline after each buffer line.
        When saving a buffer in binary mode no such newlines are added.
        The type of binary mode is irrelevant when saving; each buffer line is
        written to the file with its actual length in the buffer, which can be
        anything from 0 to MAXLINELEN.

    (*3)
      The end-of-line-type problem.
      - In a stored file each line ends with an invisible "carriage return" or
        "line feed" character or both. In Windows the default is both, in
        unix/Linux-derived operating systems it is just a line feed, and in
        old Apple computers it was just a carriage return.
        E.g. when software on a (Linux?) file system is maintained from Windows
        using TSE, then it is important that TSE saves an edited file back with
        the same end-of-line characters as it originally had.
      - In a normal in TSE loaded file the end-of-line characters have been
        stripped: TSE internally maintains each line's length. When TSE saves
        the file it uses its "EolType" configuration option, which tells TSE
        to either always save a file with a fixed end-of-line-type :-(
        or to use the same end-of-line type it found when it loaded the file.
      - TSE keeps its found end-of-line-type secret. In TSE we have no access
        to what a file's end-of-line-type is. That can already be annoying for
        a normal text file, but at least we can expect TSE to save it back
        with the same end-of-line-type.
      - In this macro's context ASCII, ANSI and UTF-8 are normal text files.
        The are loaded and saved as normal text files, where any UTF-8
        conversions happen in the normal text itself.
        This means that here TSE's standard end-of-line-type strategy works.
      - In this macro's context UTF-16 and UTF-32 files are not normal text
        files: If TSE loaded them as text then encoding information would be
        lost and we could not convert them to a viewable and editable ANSI
        format.
        So this macro has to load and save UTF-16 and UTF-32 files in binary
        format before and after doing a conversion to and from ANSI.
      - Here is the problem: Binary files have no end-of-line-type.
        In TSE's representation of binary file the "text" is initially
        presented in chunks with a fixed "line" length, and carriage returns
        and line feeds are just like any other characters and can occur
        anywhere in a chunk.
      - Here is the chosen solution :
        - If TSE's "EOLType" setting is 1, 2 or 3, then that determines the
          end-of-line-type characters for saving a UTF-16/UTF-32 file too.
        - If TSE's "EOLType" setting is 0 ("AS LOADED"), which is the default
          value, then:
          - If the EolType macro is installed, then this macro will ask
            the EolType macro what a file's end-of-line-type is or should be.
            The advantages of the EolType macro are:
            - It can make smarter decisions based on user-configured rules.
            - It shows the (new) end-of-line-type: What you see is what you get!
          - Otherwise this macro will use its own implementation of TSE's
            EOLType setting the same as TSE does. This means it will check and
            remember which end-of-line-type characters it found when loading
            the file, determine one end-of-line-type from that, and use that
            when saving the file.

  Performance optimizations for UTF-16 and UTF-32 conversions in Unicode v3.
    The main performance gain came from splitting the 1-pass conversion into 3
    passes, the last two of which can make better use of TSE's faster built-in
    commands:
    1 Instead of passing all characters to a conversion routine, a loop
      through all characters now preselects non-ASCII characters and only
      passes those to the conversion routine.
    2 One lReplace() command can be used to convert UTF-16/32's 2-byte
      or 4-byte characters into ANSI's 1-byte characters and back.
    3 The binary line to text line conversion was optimized by using an lFind()
      loop to only process line endings.
    Obviously the first pass works best when a Unicode text mainly consists of
    characters that also occur in ASCII, which should typically be true for TSE
    users. For example, besides for English, tests showed this to be true for
    a French, Norwegian and Swedish text too.

    A little performance gain came from using faster TSE commands:
    - For a proc, returning a result through a var parameter is about twice as
      fast as returning the result as the proc's return value.
      For instance this second example is about twice as fast as the first:
        result = do_something(input)
        do_something(input, var result)
    - String slices are about 10% faster than SubStr() commands.
      For instance the second example is slightly faster than the first:
        letter = Substr(word, letter_position, 1)
        letter = word[letter_position:1]

  TODO
    MUST
    - No topics.
    SHOULD
    - No topics.
    COULD
    - Splitting the macro up to make it debugger-compatible.
      Currently the macro is much too big for TSE's debugger.
      Splitting off eList would be an obvious candidate, but not be enough.
    - Improve not recognizing binary files as a Unicode file.
    - UTF-16/32 <-> ANSI conversion might be sped up by yet another factor by
      using file-based instead of buffer-based conversion.
    - When saving a UTF-16/32 file, improve the temporary backup mechanism to
      allow the loading and saving of larger files.
      This feature might more easily be implemented depending on the
      implementation of the previous  feature, so definitely do that one first.
    - Optionally convert Unicode's "combining" characters.
      Pro:
      - It would make them readable.
      Cons:
      - Each such character conversion would create a non-user file change.
      - I have never actually encountered an ANSI compatible combining
        character in the content of a file yet. I only did in file names when
        they came from iOS, and TSE and this extension do not handle non-ANSI
        folder and file names.
    - Add strategies for (semi?) automatically changing the character
      encoding for new and possibly even some existing files.
      E.g:
      - Recognition of explicitly declared character encoding
        in a document type declaration in HTML and XML documents.
      - Default character encoding for certain file extensions.
    - Implement copy/paste from/to external Unicode sources/destinations.
      This might maybe perhaps be possible for Windows. No clue about Linux.
    - Revisit error handling of illegal ANSI and Unicode character codes.
    - Mitigate memory problem for very large files.
      When saving a Unicode file, it is first converted from ANSI to its new
      character format in memory. That alone doubles the memory requirement.
      But worse, the larger character encodings of UTF-16 and UTF-32 take up
      twice and quadruple as much memory as the ASCII, ANSI and UTF-8 formats.
      This is a problem when saving very large files, because a looping memory
      error might occur when the conversion has already run a long time, and
      the only way to stop it is to end TSE with Window's Task Manager.
      Testing shows the macro can not catch the memory error during the
      conversion.
    WON'T
    - Open a folder or file with a non-ANSI name.
    - Display Unicode characters in the editing text.


  HISTORY
  1.0.0    4 Nov 2013
    Initial version that lets you view UTF-8 files.
  1.0.1 - 21 Jan 2014
    Solves an incorrect codepoint being shown for characters that can't be
    converted to ANSI. Thanks to John Kopp for the report and the solution.
  1.0.2   12 Apr 2015
    The viewing mode for UTF-8 has been removed, anticipating that
    saving back in UTF-8 format will be soon be added.
    Rewritten the UTF-8 loading to be a tiny bit faster, and a lot more
    robust and aware of errors. Aware does not mean it fixes them, it
    means that the places where "garbage in [then] garbage out" applies
    are more explicit.
  1.0.3   13 Apr 2015
    Disable saving of loaded UTF-8 file, because it was converted to ANSI.
  1.0.4   19 Apr 2015
    Added saving a loaded UTF-8 file.
    So effectively we can now edit an existing UTF-8 file.
  1.0.5   20 Apr 2015
    Now handles a UTF-8 byte order mark (BOM).
  1.0.6    9 May 2015
    Three bugs solved thanks to John Kopp:
    - Character 127 was not correctly converted back to UTF-8 when it
      already occurred in the original UTF-8 file.
    - UTF-8 character "LATIN CAPITAL LETTER A WITH TILDE" was not
      correctly converted to ANSI.
    - There were two erroneous comments after the BOM definitions.
    Now hexadecimal instead of decimal codepoints are shown for UTF-8
    characters that cannot be converted to ANSI.
  1.1 beta versions   April 2018
    - Show current file's character encoding as a status.
    - Facilitate upgrading an ASCII file when it becomes a non-ASCII file.
    - Show character descriptions as a status.
    - Explicitly change the current file's character encoding.
  1.2   9 May 2018
    Release.
  1.2.2   12 May 2018
    Bug mitigated for gigabyte files:
      Opening a gigabyte file was extremely slow, which made the editor
      appear to hang. The culprit is my programming choice, that determining
      the character encoding of a file is allowed to be slow in favour of
      small memory usage. In hindsight I would have made the other choice
      since gigabyte files should not be the norm, and I might still do so in
      the future, but that would just shift the problem for gigabyte files.
      For now the bug is mitigated in three ways:
      - A new configuration option default says that a Unicode file with a byte
        order mark (BOM) will no longer be checked: The BOM is assumed to be
        correct.
      - Another new configuration option default says that only the first 25 MB
        of a file will be checked to determine its character encoding.
        Formerly the whole file was checked. There is a downside to this speed
        increase that is specific to BOM-less UTF-8 files: They will not be
        recognized if the first non-ANSI character occurs past the 25th MB.
        You can set this option ("Max bytes to check") from 1 MB to about 2 GB
        to choose between speed and the chance of not detecting a very large
        UTF-8 file with a far occurring first non-ANSI character.
      - If you check more than 25 MB, then a counter will be shown,
        so that the editor does not appear to hang any more.
  1.2.4   16 May 2018
    Bug fixed:
      When the user changed the current file's character encoding, then the
      file's status did not change to "changed" (get an asterisk before the
      name), so when quitting the file the user got no question to save it.
    Problem mitigated:
      When opening and saving a UTF-8 file it is converted from UTF-8 to ANSI
      and from ANSI to UTF-8. For very large files these conversions can be so
      slow, that you might think the editor is frozen. To mitigate that now a
      progress indicator of the conversions is shown per 1 MB of converted
      characters.
    Bug fixed:
      A programming error caused the conversion from ANSI to UTF-8 to be about
      10 times slower than it needed to be, which made saving a UTF-8 file
      about 10 times slower too, and the error wasted a lot of memory on
      unnecessary undo/redo history.
  1.2.6   6 Nov 2018
    Bug fixed:
      Some UTF-8 files were not recognized as such,
      but were recognized and loaded as ANSI files.
    Bug fixed:
      Corrected and improved some menu's helplines' texts.
  1.2.8   19 Nov 2018
    Only documentation updated: Versioned the isAutoLoaded procedure.
  1.3     16 Jan 2019
    Bug fixed:
      No data file was distributed with v1.2.8.
      (But it was distributed with older versions.)
    Improvement:
      Codepoints are now shown in upper case to conform to what is usual.
    Feature added:
      Insert any Unicode character by typing part of its Unicode description.
      Note:
        While this is a huge improvement, it is still confusion-prone.
        For example, when inserting the euro character this way, do not select
        the misleadingly named "EURO-CURRENCY SIGN" (which looks like a
        connected "C" and "E"), but select the "EURO SIGN" (which looks like a
        "C" with an "=" through it).
        If you selected the correct one, then you will see a euro character in
        your text, otherwise you will see "20A0" quted with DELETE-characters.
        Blame the Unicode Consortium: This macro uses their character names and
        descriptions for external compatibility.
    Data file updated and data file added:
      UnicodeData.txt
        The old file was for Unicode 10, the new one is updated for Unicode 11.
      NamesList.txt
        This new file is used for its additional annotations of characters.
        When inserting characters, you will see any annotations in lower-case
        between parentheses at the end of a line.
      Installation:
        Copy these two data files to TSE's "mac" folder too.
      These newer data files were downloaded from
        https://www.unicode.org/Public/UCD/latest/ucd/
      No garantee, but future Unicode versions of these files downloaded from
      there will have a reasonable chance of working with this macro too.
  1.4     27 Jan 2019
    Added displaying a Unicode character.
      Also display the current character on some fixed position on the screen
      where we are able to display a Unicode character without messing up the
      text.
      NOTA BENE:
      This works badly, so it has a configuration option that is default OFF.
    GUI check reenabled.
      As documented the Unicode macro only works for the GUI version of TSE.
      Its check whether it runs in the console version and giving the user a
      warning was disabled. No idea why, so I turned it back on again.
    Some internal variable names standardized at some places.
      This was needed to keep better track of data types.
      Especially strings can hold all kinds of data types.
      See the "macro programmer information".
  1.5     2 Feb 2019
    Opening files and saving UTF-8 files is dramatically faster.
      By far the biggest performance improvement comes from the assumption that
      non-ASCII characters are still sparse in Unicode files and by using
      low-level TSE commands to specifically find only those characters.
    "Max bytes to check" can be much lower.
      The latter configuration option says, that when you open a file, how
      many bytes should be pre-read to determine the file's character
      encoding format. The default was 25 MB, and is now 4 kB, while 255 B
      would probably work well too. I made the default 4 kB, because that is
      extremely likely to be already cached after reading the file's first
      byte, so performance-wise pre-reading and checking a whole 4 kB is as
      good as free.
    Limit for saving extremely large UTF-8 files is a bit lower.
      This was a choice for save speed in favour of editable file size, and a
      judgement that it is better to optimize for common than for extreme use
      cases.
      In my tests I can still edit and save a 500 MB UTF-8 file.
      I could open and edit a 1 GB UTF-8 file, but not save it as UTF-8.
      When TSE runs out of memory when saving an extremely large UTF-8 file,
      then you now get the option to NOT save it (the default) or to save it
      in ANSI format.
    KeepUndoBeyondSave no longer works for Unicode files.
      This was also a choice for save speed in favour of editable file size,
      and a solution to avoid the horrible possibility that the user could
      in steps "undo" a to ANSI converted UTF-8 file.
      You can still undo editing-changes in a Unicode file, but no longer to
      before the last save.
  2       8 Feb 2019
    Added all standard UTF-16 and UTF-32 character encodings.
  2.0.1   10 Feb 2019
    Work around the TSE bug of processing the _on_first_edit_ hook again
    when the user only changes an already being edited file's name.
  2.0.2   22 Feb 2019
    Major bug fixed:
      Some non-ASCII ANSI characters were no longer converted to/from UTF-8.
      This bug was introduced :-( 20 days ago together with the speed
      optimizations in v1.5.
      For example "é" ("latin small letter e with acute") was no longer
      converted from ANSI to UTF-8.
      Incorrect UTF-8 files created this way will automatically get corrected
      once they are opened and saved again with this version of the macro.
  2.0.3   26 Feb 2019
    Minor bug fixed:
      When inserting a non-ANSI character in an ASCII file, the automatic
      upgrade menu allowed us to select ASCII as the new character encoding.
  2.0.4   30 Apr 2019
    Improved the documentation a bit.
    Minor bug fixed:
      The macro was no longer backwards compatible with TSE Pro v4.0.
  2.0.5   8 Jun 2019
    Only updated the supplemental files from Unicode 11 to Unicode 12.1.
  2.0.6   5 Oct 2019
    Significant bug in reading UTF-16BE and UTF-32BE files > 8k.
    To give a very rough guesstimate: For every multiple of 8k in size,
    there was a 15% chance of garbage and loss of characters when reading
    UTF-16BE and UTF-32BE files.
    I found specific references that Windows and JavaScript use UTF-16LE, and
    guestimate thereby that UTF-16BE must be less common.
    UTF-32 is rare in any form.
    This might explain why nobody found and reported this bug.
  2.1     30 Apr 2020
    - Added Linux TSE Beta v4.41.35 upwards compatibility.
      Unicode now needs at least version 1.2 of the Status macro installed.
    - Updated UnicodeData.txt and NamesList.txt to Unicode standard 13.0.0.
    - Bug fix: An initial installation of Unicode did set two of its
      configuration variables to "Default" instead of "Enabled" or "Disabled"
      with confusing results. It could be remedied by configuring them to
      "Enabled" or "Disabled", but a user should not have to, and now does not.
    - Bug fix:
        Context:
          In a loaded Unicode file codepoints are quoted with character 127,
          and if character 127 itself occurs in the text then it is represented
          as quoted codepoint 7F.
        Problem:
          You could not convert a loaded text with any quoted codepoints
          to ANSI or ASCII, but an exception should be made for if the only
          quoted codepoints are for character 127 itself.
        Fixed.
    - Bug fix: When opening a Unicode file in some cases the conversion progress
      line remained shown after the conversion, which might be mistaken for the
      conversion not finishing.
  2.2     24 Jul 2020
    Now allows disabling the warning if this macro is started in the Console
    version of TSE. This is useful for users who use both the GUI and Console
    versions of TSE from the same installation folder.
  2.3     14 Sep 2020
    When loading or saving any Unicode file, show the filename as a statusline
    message and the conversion progress indicator in a pop-up window below it.
    Loading a UTF-16 or UTF-32 file is 3 times faster and saving one is 4½
    times faster.
    Fixed: Opening a UTF-16 or UTF-32 file added an empty line at the end.
  2.3.1   15 Sep 2020
    Fixed: The progress percentage was only partially displayed when loading
    and saving a Unicode file with a byte order mark (BOM).
  2.3.2   29 Nov 2020
    Fixed:
    Opening a "Unicode" file not ending with a newline caused the
    conversion and thereby TSE to hang.
    "Unicode" between quotes, because in practice this typically happened
    when a file
    - AND was opened in normal mode (without the "-b" prefix),
    - AND was a binary file (not readable text),
    - AND was misidentified as a Unicode file.

  2.4     10 Oct 2021
    - Updated the data files UnicodeData.txt and NamesList.txt
      to Unicode standard 14.0.0.

  2.4.1   21 Nov 2021
    Bug fix:
      When opening one specific binary file as a normal file (that is, without
      the -b option), the Unicode extension thought it was a UTF-32LE file,
      which in turn revealed an infinite program loop in the Unicode extension,
      causing TSE to hang.
      The infinite loop has been fixed.
      That specific binary file now loads as a corrupted UTF-32LE file.
      That is acceptable to me for now, because binary files should typically
      be opened with the -b option anyway, in which case they are ignored by
      the Unicode extension.

  2.5     26 Jan 2022
    Implements copy, cut and paste of Unicode encoded files.

  2.5.1   17 Sep 2022
    Fixed incompatibility with TSE's '-i' command line option
    and the TSELOADDIR environment variable.

  2.6     24 Sep 2022
    Updated the data files to Unicode 15, which was released 13 Sep 2022.
      https://home.unicode.org/announcing-the-unicode-standard-version-15-0/

    Fixed, that text copied to the Windows clipboard could not be pasted
    in VirtualBox guest systems.

*/



