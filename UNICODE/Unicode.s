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





// Compatibility restrictions and mitigations

#ifdef LINUX
  #define WIN32 FALSE
#endif

#ifdef WIN32
#else
   16-bit versions of TSE are not supported. You need at least TSE 4.0.
#endif

#ifdef EDITOR_VERSION
#else
   Editor Version is older than TSE 3.0. You need at least TSE 4.0.
#endif

#if EDITOR_VERSION < 4000h
   Editor Version is older than TSE 4.0. You need at least TSE 4.0.
#endif

#ifndef INTERNAL_VERSION
  #define INTERNAL_VERSION 0
#endif

#define INTERNAL_VERSION_V4_41_44 12348



#if EDITOR_VERSION < 4400h
  /*
    isAutoLoaded() 1.0

    This proc implements TSE 4.4's isAutoLoaded() function for older TSE
    versions. This proc differs in that here no parameter is allowed,
    so it can only examine the currently running macro's autoload status.
  */
  integer autoload_id           = 0
  string  file_name_chrset [44] = "- !#$%&'()+,.0-9;=@A-Z[]^_`a-z{}~\d127-\d255"
  integer proc isAutoLoaded()
    string  autoload_name [255] = ''
    string  old_wordset    [32] = Set(WordSet, ChrSet(file_name_chrset))
    integer org_id              = GetBufferId()
    integer result              = FALSE
    if autoload_id
      GotoBufferId(autoload_id)
    else
      autoload_name = SplitPath(CurrMacroFilename(), _NAME_) + ':isAutoLoaded'
      autoload_id   = GetBufferId(autoload_name)
      if autoload_id
        GotoBufferId(autoload_id)
      else
        autoload_id = CreateTempBuffer()
        ChangeCurrFilename(autoload_name, _DONT_PROMPT_|_DONT_EXPAND_|_OVERWRITE_)
      endif
    endif
    LoadBuffer(LoadDir() + 'tseload.dat')
    result = lFind(SplitPath(CurrMacroFilename(), _NAME_), "giw")
    Set(WordSet, old_wordset)
    GotoBufferId(org_id)
    return(result)
  end isAutoLoaded
#endif



#if EDITOR_VERSION < 4400h
  /*
    StartPgm()  1.0

    Below the line is StartPgm's TSE v4.4 documentation.

    When you make your macro backwards compatible downto TSE v4.0,
    then all four parameters become mandatory for all calls to StartPgm().

    If you do not need the 2nd, 3rd and 4th parameter, then you must use
    their default values: '', '' and _DEFAULT_.

    Tip:
      A practical use for StartPgm is that it lets you "start" a data file too,
      *if* Windows knows what program to run for the file's file type.

      For instance, you can "start" a URL, and StartPgm will start your default
      web browser for that URL.

    ---------------------------------------------------------------------------

    StartPgm

    Runs a program using the Windows ShellExecute function.

    Syntax:     INTEGER StartPgm(STRING pgm_name [, STRING args
                        [, STRING start_dir [, INTEGER startup_flags]]])

                - pgm_name is the name of the program to run.

                - args are optional command line arguments that should be passed
                  to pgm_name.

                - start_dir is an optional starting directory.

                - startup_flags are optional flags that control how pgm_name is
                  started.  Values can be: _START_HIDDEN_, _START_MINIMIZED_,
                  _START_MAXIMIZED_.

    Returns:    Non-zero if successful; zero (FALSE) on failure.

    Notes:      This function is the preferred way to run Win32 GUI programs
                from the editor.

    Examples:

                //Cause the editor to run g32.exe, editing the file "some.file"
                StartPgm("g32.exe", "some.file")

    See Also:   lDos(), Dos(), Shell()
  */
  #define SW_HIDE             0
  #define SW_SHOWNORMAL       1
  #define SW_NORMAL           1
  #define SW_SHOWMINIMIZED    2
  #define SW_SHOWMAXIMIZED    3
  #define SW_MAXIMIZE         3
  #define SW_SHOWNOACTIVATE   4
  #define SW_SHOW             5
  #define SW_MINIMIZE         6
  #define SW_SHOWMINNOACTIVE  7
  #define SW_SHOWNA           8
  #define SW_RESTORE          9
  #define SW_SHOWDEFAULT      10
  #define SW_MAX              10

  dll "<shell32.dll>"
    integer proc ShellExecute(
      integer h,          // handle to parent window
      string op:cstrval,  // specifies operation to perform
      string file:cstrval,// filename string
      string parm:cstrval,// specifies executable-file parameters
      string dir:cstrval, // specifies default directory
      integer show)       // whether file is shown when opened
      :"ShellExecuteA"
  end

  integer proc StartPgm(string  pgm_name,
                        string  args,
                        string  start_dir,
                        integer startup_flags)
    integer result              = FALSE
    integer return_code         = 0
    integer shell_startup_flags = 0
    case startup_flags
      when _DEFAULT_
        shell_startup_flags = SW_SHOWNORMAL
      when _START_HIDDEN_
        shell_startup_flags = SW_HIDE
      when _START_MAXIMIZED_
        shell_startup_flags = SW_SHOWMAXIMIZED
      when _START_MINIMIZED_
        shell_startup_flags = SW_SHOWMINIMIZED
      otherwise
        shell_startup_flags = SW_SHOWNORMAL
    endcase
    return_code = ShellExecute(0, 'open', pgm_name, args, start_dir,
                               shell_startup_flags)
    result = (return_code > 32)
    return(result)
  end StartPgm
#endif



#if EDITOR_VERSION < 4400h
  /*
    StrReplace() 1.0

    If you have TSE Pro 4.0 or 4.2, then this proc almost completely implements
    the built-in StrReplace() function of TSE Pro 4.4.
    The StrReplace() function replaces a string (pattern) inside a string.
    It works for strings like the Replace() function does for files, so read
    the Help for the Replace() function for the usage of the options, but apply
    these differences while reading:
    - Where Replace() refers to "file" and "line", StrReplace() refers to
      "string".
    - The options "g" ("global", meaning "from the start of the string")
      and "n" ("no questions", meaning "do not ask for confirmation on
      replacements") are implicitly always active, and can therefore be omitted.
    Notable differences between the procedure below with TSE 4.4's built-in
    function are, that here the fourth parameter "options" is mandatory
    and that the fifth parameter "start position" does not exist.
  */
  integer strreplace_id = 0
  string proc StrReplace(string needle, string haystack, string replacer, string options)
    integer i                      = 0
    integer org_id                 = GetBufferId()
    string  result  [MAXSTRINGLEN] = haystack
    string  validated_options [20] = 'gn'
    for i = 1 to Length(options)
      if (Lower(SubStr(options, i, 1)) in '0'..'9', 'b', 'i','w', 'x', '^', '$')
        validated_options = validated_options + SubStr(options, i, 1)
      endif
    endfor
    if strreplace_id == 0
      strreplace_id = CreateTempBuffer()
    else
      GotoBufferId(strreplace_id)
      EmptyBuffer()
    endif
    InsertText(haystack, _INSERT_)
    lReplace(needle, replacer, validated_options)
    result = GetText(1, CurrLineLen())
    GotoBufferId(org_id)
    return(result)
  end StrReplace
#endif



/*
  compare_versions()  v2.0

  This proc compares two version strings version1 and version2, and returns
  -1, 0 or 1 if version1 is smaller, equal, or greater than/to version2.

  For the comparison a version string is split into parts:
  - Explicitly by separating parts by a period.
  - Implicitly:
    - Any uninterrupted sequence of digits is a "number part".
    - Any uninterrupted sequence of other characters is a "string part".

  Spaces are mostly ignored. They are only significant:
  - Between two digits they signify that the digits belong to different parts.
  - Between two "other characters" they belong to the same string part.

  If the first version part is a single "v" or "V" then it is ignored.

  Two version strings are compared by comparing their respective version parts
  from left to right.

  Two number parts are compared numerically, e.g: "1" < "2" < "11" < "012".

  Any other combination of version parts is case-insensitively compared as
  strings, e.g: "12" < "one" < "three" < "two", or "a" < "B" < "c" < "d".

  Examples: See the included unit tests further on.

  v2.0
    Out in the wild there is an unversioned version of compare_versions(),
    that is more restricted in what version formats it can recognize,
    therefore here versioning of compare_versions() starts at v2.0.
*/

// compare_versions_standardize() is a helper proc for compare_versions().

string proc compare_versions_standardize(string p_version)
  integer char_nr                  = 0
  string  n_version [MAXSTRINGLEN] = Trim(p_version)

  // Replace any spaces between digits by one period. Needs two StrReplace()s.
  n_version = StrReplace('{[0-9]} #{[0-9]}', n_version, '\1.\2', 'x')
  n_version = StrReplace('{[0-9]} #{[0-9]}', n_version, '\1.\2', 'x')

  // Remove any spaces before and after digits.
  n_version = StrReplace(' #{[0-9]}', n_version, '\1', 'x')
  n_version = StrReplace('{[0-9]} #', n_version, '\1', 'x')

  // Remove any spaces before and after periods.
  n_version = StrReplace(' #{\.}', n_version, '\1', 'x')
  n_version = StrReplace('{\.} #', n_version, '\1', 'x')

  // Separate version parts by periods if they aren't yet.
  char_nr = 1
  while char_nr < Length(n_version)
    case n_version[char_nr:1]
      when '.'
        NoOp()
      when '0' .. '9'
        if not (n_version[char_nr+1:1] in '0' .. '9', '.')
          n_version = n_version[1:char_nr] + '.' + n_version[char_nr+1:MAXSTRINGLEN]
        endif
      otherwise
        if (n_version[char_nr+1:1] in '0' .. '9')
          n_version = n_version[1:char_nr] + '.' + n_version[char_nr+1:MAXSTRINGLEN]
        endif
    endcase
    char_nr = char_nr + 1
  endwhile
  // Remove a leading 'v' if it is by itself, i.e not part of a non-numeric string.
  if  (n_version[1:2] in 'v.', 'V.')
    n_version = n_version[3:MAXSTRINGLEN]
  endif
  return(n_version)
end compare_versions_standardize

integer proc compare_versions(string version1, string version2)
  integer result                 = 0
  string  v1_part [MAXSTRINGLEN] = ''
  string  v1_str  [MAXSTRINGLEN] = ''
  string  v2_part [MAXSTRINGLEN] = ''
  string  v2_str  [MAXSTRINGLEN] = ''
  integer v_num_parts            = 0
  integer v_part_nr              = 0
  v1_str      = compare_versions_standardize(version1)
  v2_str      = compare_versions_standardize(version2)
  v_num_parts = Max(NumTokens(v1_str, '.'), NumTokens(v2_str, '.'))
  repeat
    v_part_nr = v_part_nr + 1
    v1_part   = Trim(GetToken(v1_str, '.', v_part_nr))
    v2_part   = Trim(GetToken(v2_str, '.', v_part_nr))
    if  v1_part == ''
    and isDigit(v2_part)
      v1_part = '0'
    endif
    if v2_part == ''
    and isDigit(v1_part)
      v2_part = '0'
    endif
    if  isDigit(v1_part)
    and isDigit(v2_part)
      if     Val(v1_part) < Val(v2_part)
        result = -1
      elseif Val(v1_part) > Val(v2_part)
        result =  1
      endif
    else
      result = CmpiStr(v1_part, v2_part)
    endif
  until result    <> 0
     or v_part_nr >= v_num_parts
  return(result)
end compare_versions

// End of compatibility restrictions and mitigations





#ifndef LINUX
  /*
    Windows APIs.
  */

  dll "<user32.dll>"
    integer proc GetDC(integer hWnd)
    integer proc ReleaseDC(integer hWnd, integer hDC)
  end

  dll "<gdi32.dll>"
    integer proc TextOutW(integer dc, integer x, integer y, integer s, integer len)
  end
#endif



// #include ['get_process_id.inc']

// Start of get_process_id() implementations

#ifdef LINUX
  integer proc get_process_id()
    #if INTERNAL_VERSION >= INTERNAL_VERSION_V4_41_44
      // I have implemented two methods for getting the editor's process id
      // from Linux. Both methods work on my Linux distros.
      string  cmd       [MAXSTRINGLEN] = ''
      string  cmd_shell [MAXSTRINGLEN] = '/bin/bash'
      integer process_id               = 0
      integer rc                       = 0
      // Try Method 1, with a shell
      if not FileExists(cmd_shell)
        cmd_shell = GetEnvStr('SHELL')
        if not FileExists(cmd_shell)
          cmd_shell = ''
        endif
      endif
      if cmd_shell <> ''
        PushLocation()
        EmptyBuffer(Query(CaptureId))
        Capture(cmd_shell + ' -c "ps -p $$ --no-headers -o ppid"')
        rc = DosIOResult()
        if      LoByte(rc)
        and not HiByte(rc)
        and     NumLines() == 1
          process_id = Val(Trim(GetText(1, MAXSTRINGLEN)))
        endif
        PopLocation()
      endif
      if process_id == 0
        // Try method 2, without a shell
        PushLocation()
        EmptyBuffer(Query(CaptureId))
        Capture('ps T --no-headers -o pid,cmd')
        rc = DosIOResult()
        if      LoByte(rc)
        and not HiByte(rc)
        and     NumLines()
          BegFile()
          repeat
            if lFind('^[ \d009]*[0-9]#[ \d009]#\c', 'cgx')
              cmd = GetText(CurrPos(), MAXSTRINGLEN)
              cmd = GetFileToken(cmd, 1)
              cmd = GetToken(cmd, '/', NumTokens(cmd, '/'))
              if SplitPath(LoadDir(TRUE), _NAME_|_EXT_) == cmd
                process_id = Val(GetToken(GetText(1, MAXSTRINGLEN), ' ', 1))
              endif
            endif
          until not Down()
        endif
        PopLocation()
      endif
      return(process_id)
    #else
      return(0)
    #endif
  end get_process_id
#else
  dll "<Kernel32.dll>"
    integer proc GetCurrentProcessId(integer void)
  end

  integer proc get_process_id()
    return(GetCurrentProcessId(0))
  end get_process_id
#endif

// End of get_process_id() implementations



// Start of low-level windows clipboard functions.

#ifndef LINUX

/*
  Windows Clipboard API documentation:
    https://docs.microsoft.com/en-us/windows/win32/dataxchg/using-the-clipboard#pasting-information-from-the-clipboard
*/

#define CF_TEXT         1
#define CF_UNICODETEXT 13
#define CF_OEMTEXT      7
#define GMEM_MOVEABLE   2
#define MAXINT_MINUS_2  MAXINT - 2

dll "<User32.dll>"
  integer proc CloseClipboard()
  integer proc EmptyClipboard()
  integer proc GetClipboardData(integer requested_format)
  integer proc IsClipboardFormatAvailable(integer requested_format)
  integer proc OpenClipboard(integer window_handle)
  integer proc SetClipboardData(integer uFormat, integer hMem)
end

dll "<Kernel32.dll>"
  integer proc GlobalAlloc(integer uFlags, integer dwBytes)
  integer proc GlobalLock(integer object_handle)
  integer proc GlobalUnlock(integer object_handle)
end

/*
  paste_unicode_from_winclip()
    Pre-conditions:
      The current buffer, which must be an empty binary buffer.
      Optionally the Windows clipboard containing text, which may encoded
      as OEM, ANSI or Unicode.
    Post-conditions:
      The binary buffer filled with the Windows clipboard's text
      in raw UTF-16LE format,
      i.e. mostly 2 bytes per character with each least-significant byte first,
      i.e. most characters are a non-zero byte followed by a zero byte,
      including a carriage return and line feed character for each new line.
*/
integer proc paste_unicode_from_winclip(integer old_MsgLevel)
  integer binary_mode         = BinaryMode()
  integer chars               = 0
  integer clipboard_handle    = 0
  integer ok                  = TRUE
  integer old_Insert          = Set(Insert, ON)
  integer text_pointer        = 0
  integer text_pointer_offset = 0
  integer time_started        = 0
  string  warn_prefix    [32] = 'PasteUnicodeFromWinClip: Could not '
  integer word                = 0
  if binary_mode > 0
    if  NumLines() <= 1
    and CurrLineLen() == 0
      if IsClipboardFormatAvailable(CF_UNICODETEXT)
        if OpenClipboard(GetWinHandle())
          clipboard_handle = GetClipboardData(CF_UNICODETEXT)
          if clipboard_handle
            text_pointer = GlobalLock(clipboard_handle)
            if text_pointer
              time_started = GetTime()
              InsertText(Chr(255) + Chr(254)) // Add BOM for UTF-16LE.
              chars = 2
              word = PeekWord(text_pointer)
              while word                <> 0
              and   chars <  MAXINT_MINUS_2 // Any limit.
                chars = chars + 2
                if  chars mod 1000000        == 0
                and GetTime() - time_started >= 100
                and old_MsgLevel             == _ALL_MESSAGES_
                  Message('Pasting UTF-16LE from Windows clipboard ...';
                          chars / 1000000; 'MB ...')
                endif
                if CurrPos() > binary_mode
                  AddLine()
                  BegLine()
                endif
                InsertText(Chr(LoByte(Word)) + Chr(HiByte(Word)))
                text_pointer_offset = text_pointer_offset + 2
                word = PeekWord(AdjPtr(text_pointer, text_pointer_offset))
              endwhile
              GlobalUnlock(clipboard_handle)
            endif
          else
            Warn(warn_prefix, 'access Unicode-compatible text on clipbord.')
            ok = FALSE
          endif
          if not CloseClipboard()
            Warn(warn_prefix, 'close clipbord.')
            ok = FALSE
          endif
        else
          Warn(warn_prefix, 'open clipbord.')
          ok = FALSE
        endif
      else
        Warn(warn_prefix, 'find Unicode-compatible text on clipbord.')
        ok = FALSE
      endif
    else
      Warn(warn_prefix, 'find empty buffer.')
      ok = FALSE
    endif
  else
    Warn(warn_prefix, 'find valid binary mode.')
    ok = FALSE
  endif
  Set(Insert, old_Insert)
  return(ok)
end paste_unicode_from_winclip

/*
  copy_unicode_to_winclip()
    Pre-conditions:
      The current buffer is in binary mode and contains UTF-16LE encoded text.
    Post-conditions:
      The buffer's content is copied as-is to the Windows clipboard.
      The Windows clipboard has the standard CF_UNICODETEXT clipboard format.
*/
integer proc copy_unicode_to_winclip(integer old_MsgLevel)
  integer buffer_size            = 0
  integer clipboard_handle       = 0
  integer ok                     = TRUE
  integer percentage_denominator = 0
  integer text_pointer           = 0
  integer time_started           = 0
  string  warn_prefix       [32] = 'CopyUnicodeToWinClip: Could not '
  integer word                   = 0
  integer word_pointer           = 0

  if OpenClipboard(GetWinHandle())
    if EmptyClipboard()
      BegFile()
      repeat
        buffer_size = buffer_size + CurrLineLen()
      until not Down()
      if buffer_size
        percentage_denominator = buffer_size / 100
        percentage_denominator = iif(percentage_denominator, percentage_denominator, 1)
        clipboard_handle = GlobalAlloc(GMEM_MOVEABLE, buffer_size + 2)
        if clipboard_handle
          text_pointer = GlobalLock(clipboard_handle)
          if text_pointer
            time_started = GetTime()
            BegFile()
            repeat
              word = CurrChar()
              if word <> _AT_EOL_
                NextChar()
                word = CurrChar() * 256 + word
                PokeWord(AdjPtr(text_pointer, word_pointer), word)
                word_pointer = word_pointer + 2
              endif
              NextChar()
              if  word_pointer mod 1000000 == 0
              and GetTime() - time_started >= 100
              and old_MsgLevel             == _ALL_MESSAGES_
                KeyPressed()
                Message('Copying UTF-16LE to Windows clipboard ...';
                        word_pointer / percentage_denominator; '% ...')
              endif
            until CurrChar() == _AT_EOL_
              and CurrLine() == NumLines()
            PokeWord(AdjPtr(text_pointer, word_pointer), 0)
            GlobalUnlock(clipboard_handle)
            if not SetClipboardData(CF_UNICODETEXT, clipboard_handle)
              Warn(warn_prefix, 'link allocated memory to clipboard.')
              ok = FALSE
            endif
          else
            Warn(warn_prefix, 'lock the allocated memory.')
            ok = FALSE
          endif
        else
          Warn(warn_prefix, 'allocate memory.')
          ok = FALSE
        endif
      endif
    else
      Warn(warn_prefix, 'empty the Windows clipboard.')
      ok = FALSE
    endif
    if not CloseClipboard()
      Warn(warn_prefix, 'close the clipboard.')
      ok = FALSE
    endif
  else
    Warn(warn_prefix, 'open the Windows clipboard.')
    ok = FALSE
  endif
  return(ok)
end copy_unicode_to_winclip


#endif

// End of low-level windows clipboard functions.




/*
  Start of copy of code of v1.0.1 of the eList macro.
*/

integer eList_lst_linenos_id        = 0
integer eList_lst_text_id           = 0
integer eList_org_id                = 0
string  eList_typed  [MAXSTRINGLEN] = ''

/*
  The following function determines the minimum amount of characters that a
  given regular expression can match. For the practical purpose that they are
  valid matches too, "^" and "$" are pretended to have length 1.
  The purpose of this procedure is, to be able to beforehand avoid searching
  for an empty string, which is logically pointless because it always succeeds
  (with one exception: past the end of the last line).
  Searching for an empty string in a loop makes it infinate and hangs a macro.
  Properly applied, using this procedure can avoid that.
*/
integer proc eList_minimum_regexp_length(string s)
  integer addition           = 0
  integer i                  = 0
  integer NEXT_TIME          = 2
  integer orred_addition     = 0
  integer prev_addition      = 0
  integer prev_i             = 0
  integer result             = 0
  integer tag_level          = 0
  integer THIS_TIME          = 1
  integer use_orred_addition = FALSE
  // for each character.
  for i = 1 to Length(s)
    // Ignore this zero-length "character".
    if Lower(SubStr(s,i,2)) == "\c"
      i = i + 1
    else
      // Skip index for all these cases so they will be counted as one
      // character.
      case SubStr(s,i,1)
        when "["
          while i < Length(s)
          and   SubStr(s,i,1) <> "]"
            i = i + 1
          endwhile
        when "\"
          i = i + 1
          case Lower(SubStr(s,i,1))
            when "x"
              i = i + 2
            when "d", "o"
              i = i + 3
          endcase
      endcase
      // Now start counting.
      if use_orred_addition == NEXT_TIME
         use_orred_addition =  THIS_TIME
      endif
      // Count a Literal character as one:
      if SubStr(s,i-1,1) == "\" // (Using the robustness of SubStr!)
        addition = 1
      // Count a tagged string as the Length of its subexpression:
      elseif SubStr(s,i,1) == "{"
        prev_i = i
        tag_level = 1
        while i < Length(s)
        and   (tag_level <> 0 or SubStr(s,i,1) <> "}")
          i = i + 1
          if SubStr(s,i,1) == "{"
            tag_level = tag_level + 1
          elseif SubStr(s,i,1) == "}"
            tag_level = tag_level - 1
          endif
        endwhile
        addition = eList_minimum_regexp_length(SubStr(s,prev_i+1,i-prev_i-1))
      // for a "previous character or tagged string may occur zero
      // times" operator: since it was already counted, subtract it.
      elseif SubStr(s,i,1) in "*", "@", "?"
        addition = -1 * Abs(prev_addition)
      // This is a tough one: the "or" operator.
      // for now subtract the Length of the previous character or
      // tagged string, but remember doing so, because you might have
      // to add it again instead of the Length of the character or
      // tagged string after the "or" operator.
      elseif SubStr(s,i,1) == "|"
        addition           = -1 * Abs(prev_addition)
        orred_addition     = Abs(prev_addition)
        use_orred_addition = NEXT_TIME
      else
      // Count ordinary characters as 1 character.
        addition = 1
      endif
      if use_orred_addition == THIS_TIME
        if orred_addition < addition
          addition = orred_addition
        endif
        use_orred_addition = FALSE
      endif
      result        = result + addition
      prev_addition = addition
    endif
  endfor
  return(result)
end eList_minimum_regexp_length

proc eList_after_nonedit_command()
  string  find_options [3] = 'gix'
  integer last_key                = Query(Key)
  integer old_ilba                = Query(InsertLineBlocksAbove)
  integer old_uap                 = Query(UnMarkAfterPaste)
  integer old_msglevel            = Query(MsgLevel)
  integer org_lineno              = 0
  integer org_num_lines           = 0
  integer resized                 = FALSE
  if last_key in 32 .. 126
    eList_typed = eList_typed + Chr(last_key)
    resized     = TRUE
  elseif last_key == <BackSpace>
    if Length(eList_typed) > 0
      eList_typed = SubStr(eList_typed, 1, Length(eList_typed) - 1)
      resized     = TRUE
    endif
  endif
  if resized
    EmptyBuffer()
    GotoBufferId(eList_lst_linenos_id)
    EmptyBuffer()
    GotoBufferId(eList_org_id)
    PushPosition()
    PushBlock()
    UnMarkBlock()
    if Length(eList_typed) == 0
      Message('Start typing letters and digits or a TSE regular expression to shrink this list.')
      org_num_lines = NumLines()
      MarkLine(1, org_num_lines)
      Copy()
      GotoBufferId(eList_lst_text_id)
      Paste()
      GotoBufferId(eList_org_id)
    else
      Message('Lines matching with (reg exp) "', eList_typed,
              '".          Type more or <Backspace>.')
      old_ilba     = Set(InsertLineBlocksAbove, FALSE)
      old_msglevel = Set(MsgLevel             , _NONE_)
      old_uap      = Set(UnMarkAfterPaste     , TRUE)
      if eList_minimum_regexp_length(eList_typed) <= 0
        BegFile()
        EndLine()
        find_options = 'ix+'
      endif
      while lFind(eList_typed, find_options)
        org_lineno = CurrLine()
        MarkLine(org_lineno, org_lineno)
        Copy()
        GotoBufferId(eList_lst_text_id)
        Paste()
        Down()
        GotoBufferId(eList_lst_linenos_id)
        AddLine(Str(org_lineno))
        GotoBufferId(eList_org_id)
        EndLine()
        find_options = 'ix+'
      endwhile
      Set(InsertLineBlocksAbove, old_ilba)
      Set(MsgLevel             , old_msglevel)
      Set(UnMarkAfterPaste     , old_uap)
    endif
    PopPosition()
    PopBlock()
    GotoBufferId(eList_lst_text_id)
    BegFile()
  endif
end eList_after_nonedit_command

integer proc eList(string eList_title)
  integer lst_selected_lineno = 0
  integer org_selected_lineno = 0
  eList_org_id = GetBufferId()
  eList_typed  = ''
  PushPosition()
  PushBlock()
  MarkLine(1, NumLines())
  Copy()
  if eList_lst_linenos_id
    GotoBufferId(eList_lst_linenos_id)
    EmptyBuffer()
  else
    eList_lst_linenos_id = CreateTempBuffer()
    ChangeCurrFilename(SplitPath(CurrMacroFilename(), _NAME_) + ':lst_linenos',
                       _DONT_PROMPT_|_DONT_EXPAND_|_OVERWRITE_)
  endif
  if eList_lst_text_id
    GotoBufferId(eList_lst_text_id)
    EmptyBuffer()
  else
    eList_lst_text_id = CreateTempBuffer()
    ChangeCurrFilename(SplitPath(CurrMacroFilename(), _NAME_) + ':lst_text',
                       _DONT_PROMPT_|_DONT_EXPAND_|_OVERWRITE_)
  endif
  Paste()
  UnMarkBlock()
  Message('Start typing letters and digits or a TSE regular expression to shrink this list.')
  Set(Y1, 3)
  Hook(_AFTER_NONEDIT_COMMAND_, eList_after_nonedit_command)
  if lList(eList_title, LongestLineInBuffer(), Query(ScreenRows) - 3, _ENABLE_HSCROLL_)
    lst_selected_lineno = CurrLine()
  endif
  UnHook(eList_after_nonedit_command)
  if lst_selected_lineno <> 0
    GotoBufferId(eList_lst_linenos_id)
    GotoLine(lst_selected_lineno)
    org_selected_lineno = Val(GetText(1, MAXSTRINGLEN))
    if org_selected_lineno == 0
      org_selected_lineno = lst_selected_lineno
    endif
  endif
  GotoBufferId(eList_org_id)
  PopPosition()
  PopBlock()
  if org_selected_lineno
    GotoLine(org_selected_lineno)
    ScrollToCenter()
    BegLine()
    if eList_typed <> ''
      lFind(eList_typed, 'cgix')
      // in case of a regexp it can be nice to see what it actually matched:
      MarkFoundText()
    endif
    UpdateDisplay()
  endif
  Message('')
  return(org_selected_lineno)
end eList

/*
  End of copy of code of v1.0.1 of the eList macro.
*/





// COMPILER DIRECTIVES

#define DEBUG_LOG FALSE





// GLOBAL CONSTANTS

// Numbers are left-justified (!) on position n * 5, 1 <= n <= 27.
// The four leading spaces are vital. This odd format facilitates a simple
// and fast search-and-retrieve algorithm.
string ansi_codepoints [138] = '    8364 8218 402  8222 8230 8224 8225 ' +
                                   '710  8240 352  8249 338  381  8216 ' +
                                   '8217 8220 8221 8226 8211 8212 732  ' +
                                   '8482 353  8250 339  382  376 '
string ansi_codes      [138] = '    128  130  131  132  133  134  135  ' +
                                   '136  137  138  139  140  142  145  ' +
                                   '146  147  148  149  150  151  152  ' +
                                   '153  154  155  156  158  159 '

// This is both the parameter for BinaryMode() when reading UTF-16 and UTF-32
// files, and what the code uses to process a read binary file.
// For example, set it to 32 or 64 when debugging to see short lines,
// and set it as high as possible for production.
// A low value slows processing.
// To cover even the extremest of use and edge cases, this parameter must be:
// - at least 4,
// - a multiple of 4,
// - at least 4 smaller than MAXLINELEN / 8.
// TSE v4 thru v4.4  have MAXLINELEN 16,000,
// Higher TSE versions have MAXLINELEN 30,000.
#if EDITOR_VERSION <= 4400h
  #define BINARYMODE_LINE_LENGTH 1996
#else
  #define BINARYMODE_LINE_LENGTH 3744
#endif

string BOM_UTF8     [3] = Chr(239) + Chr(187) + Chr(191)            // EF BB BF
string BOM_UTF16_BE [2] = Chr(254) + Chr(255)                       // FE FF
string BOM_UTF16_LE [2] = Chr(255) + Chr(254)                       // FF FE
string BOM_UTF32_BE [4] = Chr(  0) + Chr(  0) + Chr(254) + Chr(255) // 00 00 FE FF
string BOM_UTF32_LE [4] = Chr(255) + Chr(254) + Chr(0  ) + Chr(0  ) // FF FE 00 00

#define CCF_OPTIONS _DONT_PROMPT_|_DONT_EXPAND_|_OVERWRITE_

string character_code_formats [157] = ' ASCII       '
                                    + ' ANSI        '
                                    + ' UTF-8       '
                                    + ' UTF-8+BOM   '
                                    + ' UTF-16BE    '
                                    + ' UTF-16BE+BOM'
                                    + ' UTF-16LE    '
                                    + ' UTF-16LE+BOM'
                                    + ' UTF-32BE    '
                                    + ' UTF-32BE+BOM'
                                    + ' UTF-32LE    '
                                    + ' UTF-32LE+BOM'
                                    + ' '

#define DOS_ASYNC_CALL_FLAGS _DONT_PROMPT_|_DONT_CLEAR_|_START_HIDDEN_|_RETURN_CODE_|_RUN_DETACHED_|_DONT_WAIT_
#define DOS_SYNC_CALL_FLAGS  _DONT_PROMPT_|_DONT_CLEAR_|_START_HIDDEN_|_RETURN_CODE_

string EOLTYPE_MACRO_NAME           [7] = 'EolType'
string EOLTYPE_MACRO_USABLE_VERSION [1] = '7'

string FIND_ANSI_CODEPOINT           [22] = '\d127[0-9A-Fa-f]#\d127'
string FIND_NON_ASCII                [13] = '[\d128-\d255]'
string FIND_POSSIBLE_UTF8_MULTI_BYTE [11] = '[\xC0-\xFF]'   // >= 11000000b
string FIND_UNICODE_IN_ANSI          [13] = '[\d127-\d255]'

#define FIRST_OLDER_THAN_SECOND -1
#define FIRST_EQUAL_TO_SECOND    0
#define FIRST_NEWER_THAN_SECOND  1

#define MAXLINELEN_DIVIDED_BY_4 MAXLINELEN / 4
#define MAXLINELEN_MINUS_2      MAXLINELEN - 2
#define MAXLINELEN_MINUS_4      MAXLINELEN - 4

string MY_MACRO_VERSION [5] = '2.6'

#ifdef LINUX
  string SLASH [1] = '/'
#else
  string SLASH [1] = '\'
#endif

string QUOTED_DELETE_CODEPOINT [4] = Chr(127) + '7F' + Chr(127)

string status_macro_name             [6] = 'Status'
string status_macro_required_version [3] = '1.2'

#define THAT_THE_CURSOR_IS_ON_ANYWHERE TRUE
#define THAT_STARTS_AT_THE_CURSOR      FALSE

string THREE_NULL_BYTES [3] = Chr(0) + Chr(0) + Chr(0)

#define UTF16BE 1
#define UTF16LE 2
#define UTF32BE 3
#define UTF32LE 4

string utf8_first_byte_filters [33] = '1111111b 11111b 1111b 111b 11b 1b'

string UPGRADE_URL [40] = 'https://ecarlo.nl/tse/index.html#Unicode'





// GLOBAL VARIABLES

integer abort                                     = FALSE
integer afterwards_restore_status_line            = FALSE
integer backup_id                                 = 0
string  cfg_ansi_upgrade_action              [13] = ''
string  cfg_ascii_upgrade_action             [13] = ''
string  cfg_char_descriptions                [13] = ''
integer cfg_check_bom_correctness                 = FALSE
integer cfg_convert_unicode_files                 = FALSE
integer cfg_max_bytes_to_check                    = 10000000
integer cfg_show_char_code_format                 = FALSE
string  cfg_values_char_descriptions         [30] = 'All          Unprintables None'
string  cfg_version                          [13] = ''
string  clp_fqn                    [MAXSTRINGLEN] = ''
string  cmd_fqn                    [MAXSTRINGLEN] = ''
integer current_char                              = 0
integer current_column                            = 0
integer current_id                                = 0
integer current_line                              = 0
integer g_org_converted                           = FALSE
integer g_org_filechanged                         = FALSE
string  g_org_fqn                  [MAXSTRINGLEN] = ''
integer g_org_id                                  = 0
integer g_org_line                                = 0
integer g_org_pos                                 = 0
integer g_org_row                                 = 0
integer g_org_undomode                            = FALSE
integer g_org_xoffset                             = 0
integer menu_history_number                       = 0
integer msg_window_is_open                        = FALSE
string  my_macro_name              [MAXSTRINGLEN] = ''
integer nameslist_id                              = 0
integer profile_error                             = FALSE
integer selection_list_id                         = 0
integer status_refresh_period                     = 36
integer status_refresh_timer                      = 0
string  tmp_fqn                    [MAXSTRINGLEN] = ''
integer unicodedata_id                            = 0
string  varname_cfg_section        [MAXSTRINGLEN] = ''
string  varname_character_encoding [MAXSTRINGLEN] = ''
string  varname_conversion_flag    [MAXSTRINGLEN] = ''
string  varname_first_edited       [MAXSTRINGLEN] = ''
string  varname_loaded_eoltype     [MAXSTRINGLEN] = ''

#ifndef LINUX
  string  cfg_char_previews                     [13] = ''
  integer cfg_unicode_x                              = 3
  string  cfg_values_char_displays              [30] = 'All          Non-ANSI     None'
  integer cfg_unicode_y                              = 3
  integer device_context_handle                      = 0
  integer unicode_character_is_displayed             = TRUE
  integer window_handle                              = 0
#endif





proc gigo()
  // By occurring and doing nothing this procedure indicates known places
  // where "garbage in" will produce "garbage out".
  integer dummy = 0
  dummy = dummy
end gigo

proc write_profile_error()
  if not profile_error
    Alarm()
    Warn('ERROR writing Unicode configuration to file "tse.ini": Unicode will stop ASAP.')
    profile_error = TRUE
  endif
  PurgeMacro(my_macro_name)
  abort = TRUE
end write_profile_error

/*
integer proc write_profile_int(string  section_name,
                               string  item_name,
                               integer item_value)
  integer result = WriteProfileInt(section_name, item_name, item_value, ".\unicode.ini" )
  if not result
    write_profile_error()
  endif
  return(result)
end write_profile_int
*/

integer proc write_profile_str(string section_name,
                               string item_name,
                               string item_value)
  integer result = WriteProfileStr(section_name, item_name, item_value, ".\unicode.ini" )
  if not result
    write_profile_error()
  endif
  return(result)
end write_profile_str

proc programming_error(integer error_no)
  Alarm()
  Warn('Report this programming error in the Unicode macro: ', error_no,
       Chr(13), Chr(13),
       'Your Unicode file might be corrupted: Do not save it!',
       Chr(13), Chr(13),
       'The Unicode macro now stops for the duration of this TSE session.')
  PurgeMacro(my_macro_name)
  abort = TRUE
end programming_error

proc beeper()
  // Follow TSE's beep configuration for Find/Replace failures.
  if Query(Beep)
    Alarm()
  endif
end beeper

proc antifreeze()
  /*
    Modern Windows versions "freeze" an application (or TSE macro) that has no
    active user interaction. The application keeps running, but the its window
    is no longer updated. The cursor stops blinking and messages are no longer
    shown.
    A regular KeyPressed() makes Windows think that there is active user
    interaction, and either keeps its window from freezing or thaws it.
  */
  KeyPressed()
end antifreeze

proc msg(string s)
  antifreeze()
  if s == ''
    if msg_window_is_open
      PopWinClose()
      msg_window_is_open = FALSE
    endif
  else
    if not msg_window_is_open
      PopWinOpen(25, 5, 29 +Length(s), 7, 1, 'Converting', Query(MenuTextAttr))
      msg_window_is_open = TRUE
    endif
    VGotoXY(1, 1)
    Set(Attr, Query(MenuTextAttr))
    ClrScr()
    Write('  ', s)
  endif
  antifreeze()
end msg

string proc unformat_integer(string s)
  /*
    This function converts a string that starts with a valid integer
    to the minimum TSE string for the closest valid TSE integer.
    Any other string is converted to '0'.

    This function is more user oriented than TSE's Str(Val(s)) functionality.

    Specific functionality:
      It removes superfluous leading signs, including double minus signs.
      It removes leading zeros.
      It removes grouping commas.
      It removes spaces before the first number.
      It removes a decimal point and anything after it.
      It removes anything after the first number.
      A number > MAXINT is converted to MAXINT.
      A number < MININT is converted to MININT.
  */
  string  c               [1] = ''
  integer i                   = 0
  integer ignore_rest         = FALSE
  integer ignore_spaces       = TRUE
  integer interpret_signs     = TRUE
  string  r    [MAXSTRINGLEN] = ''
  integer is_positive_number  = TRUE
  for i = 1 to Length(s)
    if not ignore_rest
      c = SubStr(s, i, 1)
      case c
        when '0' .. '9'
          r               = r + c
          ignore_spaces   = FALSE
          interpret_signs = FALSE
        when ' '
          if not ignore_spaces
            i = Length(s)
          endif
        when '+'
          if not interpret_signs
            i = Length(s)
          endif
        when '-'
          if interpret_signs
            is_positive_number = not is_positive_number
          else
            i = Length(s)
          endif
        when ','
          c = c
        otherwise
          i = Length(s)
      endcase
    endif
  endfor
  while SubStr(r, 1, 1) == '0'
    r = SubStr(r, 2, MAXSTRINGLEN)
  endwhile
  // Now r is empty or just digits without a sign.
  if r == ''
    r = '0'
  else
    if is_positive_number
      if     Length(r) >  10
      or (   Length(r) == 10
         and r > Str(MAXINT))
        r = Str(MAXINT)
      endif
    else
      r = '-' + r
      if     Length(r) >  11
      or (   Length(r) == 11
         and r > Str(MININT))
        r = Str(MININT)
      endif
    endif
  endif
  return(r)
end unformat_integer

string proc format_integer(string s)
  integer i           = 0
  string  result [13] = ''
  for i = 1 to Length(s)
    result = result + SubStr(s, i, 1)
    if  (Length(s) - i) mod 3 == 0
    and i <> Length(s)
      result = result + ','
    endif
  endfor
  return(result)
end format_integer

/*
  Conversions happen in parts.
  Each part has its own progress percentage.
  These parts and their individual speed are of technical interest (that is
  what logging is for), but they are of no interest to the user.
  So to the user we only show the overall progress percentage.
  Based on Unicode v2.3 tests the duration of parts as part of the whole is
  as follows in percentages:
    UTF-16 loads in 3 parts of 15, 76 and 9:  0 - 15, 15 - 91, 91 - 100.
    UTF-32 loads in 3 parts of 26, 66 and 8:  0 - 26, 26 - 92, 92 - 100.
    UTF-16 saves in 3 parts of  1, 93 and 6:  0 -  1,  1 - 94, 94 - 100.
    UTF-32 saves in 3 parts of  1, 90 and 9:  0 -  1,  1 - 91, 91 - 100.
  Here we convert the part progress (0% - 100%) to what progress range
  (from% - to%) they cover in the total progress (0% - 100%).

*/
integer proc percentage_to_range(integer percentage,
                                 integer range_from,
                                 integer range_to  )
  integer result = 0
  result = (percentage * (range_to - range_from) / 100) + range_from
  return(result)
end percentage_to_range

proc config_the_autoload()
  // The value of cfg_ascii_upgrade_action is irrelevant.
  #ifdef LINUX
    string cfg_char_previews [4] = 'None'
  #endif
  if cfg_char_descriptions <> 'None'
  or cfg_char_previews     <> 'None'
  or cfg_convert_unicode_files
  or cfg_show_char_code_format
    if not isAutoLoaded()
      AddAutoLoadMacro(my_macro_name)
    endif
  else
    if isAutoLoaded()
      DelAutoLoadMacro(my_macro_name)
    endif
  endif
end config_the_autoload



/*
  An ExecMacro that eventually stops this macro if the Status macro is not
  installed, thereby avoiding an infinite loop.
*/
proc exec_macro(string macro_cmd_line)
  string  status_macro_current_version [MAXSTRINGLEN] = ''
  string  extra_version_text           [MAXSTRINGLEN] = ''
  integer ok                                          = TRUE
  ok = ExecMacro(macro_cmd_line)
  if ok
    status_macro_current_version = GetGlobalStr(status_macro_name + ':Version')
    if compare_versions(status_macro_current_version,
                        status_macro_required_version)
                        == FIRST_OLDER_THAN_SECOND
      ok                 = FALSE
      extra_version_text = 'at least version ' +
                           status_macro_required_version + ' of '
    endif
  endif
  if not ok
    Alarm()
    Warn(my_macro_name, ' macro stops: It needs ', extra_version_text,
         'the "', status_macro_name, '" macro to be installed!')
    PurgeMacro(my_macro_name)
    abort = TRUE
  endif
end exec_macro

integer proc is_normal_file()
  return(BufferType() == _NORMAL_ and not BinaryMode())
end is_normal_file

string proc get_font(string property)
  // Property may be "name" or "type".
  // The property "type" will return "OEM" or "".
  string  result    [MAXSTRINGLEN] = ''
  string  font_name [MAXSTRINGLEN] = ''
  integer font_pointsize           = 0
  integer font_flags               = 0
  GetFont(font_name, font_pointsize, font_flags)
  case property
    when 'name'
      result = font_name
    when 'type'
      if font_flags & _FONT_OEM_
        result = 'OEM'
      endif
  endcase
  return(result)
end get_font

string proc get_character_code_format()
  /*
    This proc only checks a limited number of bytes by pre-reading the beginning
    of the file from disc.
    The assumption is that UTF-16 and UTF-32 are quickly recognized here
    because UTF-16 and UTF-32 characters are very recognizable.
    That here the difference between an ANSI and UTF-8 file may not be
    recognized yet, will and can be remedied at a later stage when the whole
    file has been loaded.
  */
  integer ascii_possible                  = TRUE
  integer byte                            = 0
  integer byte_modulus                    = -1
  string  byte_order_mark  [MAXSTRINGLEN] = ''
  string  content_format   [MAXSTRINGLEN] = ''
  integer display_updated                 = FALSE
  string  file_block       [MAXSTRINGLEN] = ''
  integer file_block_size                 = 0
  integer handle                          = 0
  integer ignore_read_utf8_bytes          = 0
  integer num_bytes                       = 0
  integer possible_utf8_bytes             = 0
  string  result           [MAXSTRINGLEN] = ''
  string  stream_block     [MAXSTRINGLEN] = ''
  integer stream_block_pos                = 0
  integer stream_block_size               = 0
  integer stream_size                     = 0
  integer stream_size_curr_mb             = 0
  integer stream_size_prev_mb             = 0
  integer utf8_possible                   = TRUE
  integer zeros_on_mod_0                  = 0
  integer zeros_on_mod_1                  = 0
  integer zeros_on_mod_2                  = 0
  integer zeros_on_mod_3                  = 0

  PushPosition()   // xx   Why?

  handle = fOpen(CurrFilename(), _OPEN_READONLY_)
  if handle == -1
    // xx   Possible get_character_code_format() error?
    // Have to reexamine this, because this proc is also called _ON_FILE_LOAD_,
    // so before the target file is loaded. What is the current buffer?

    // Here the lFind is usually OK, because called for already loaded but
    // not yet saved file, but theoretically wrong for opening a
    // non-existing file.
    if lFind(FIND_NON_ASCII, 'gx')
      content_format = 'ANSI'
    else
      content_format = 'ASCII'
    endif
  else
    file_block_size = fRead(handle, file_block, MAXSTRINGLEN)
    stream_block = file_block
    stream_block_size = iif(file_block_size > 0, file_block_size, 0)
    stream_block_pos = 1
    stream_size = stream_block_size
    if file_block_size > 0
      if     SubStr(file_block, 1, 4) == BOM_UTF32_BE
        byte_order_mark = 'UTF-32BE'
      elseif SubStr(file_block, 1, 4) == BOM_UTF32_LE
        byte_order_mark = 'UTF-32LE'
      elseif SubStr(file_block, 1, 3) == BOM_UTF8
        byte_order_mark = 'UTF-8'
      elseif SubStr(file_block, 1, 2) == BOM_UTF16_BE
        byte_order_mark = 'UTF-16BE'
      elseif SubStr(file_block, 1, 2) == BOM_UTF16_LE
        byte_order_mark = 'UTF-16LE'
      endif
    endif
    if byte_order_mark == ''
    or cfg_check_bom_correctness
      repeat
        if  stream_block_pos + 4 - 1 > stream_block_size
        and file_block_size > 0
          file_block_size = fRead(handle, file_block, MAXSTRINGLEN - 4)
          if file_block_size > 0
            stream_size = stream_size + file_block_size
            stream_size_curr_mb = stream_size / 1000000
            if  stream_size_curr_mb >  25
            and stream_size_curr_mb <> stream_size_prev_mb
            and GetClockTicks() mod 18 == 0
              if not display_updated
                UpdateDisplay(_ALL_WINDOWS_REFRESH_)
                display_updated = TRUE
              endif
              antifreeze()
              Message('Unicode checking character encoding ... ', stream_size_curr_mb, ' MB ...')
              antifreeze()
              stream_size_prev_mb = stream_size_curr_mb
            endif
            stream_block = SubStr(stream_block, stream_block_pos, MAXSTRINGLEN)
                         + file_block
            stream_block_size = Length(stream_block)
            stream_block_pos  = 1
          endif
        endif
        if stream_block_pos <= stream_block_size
          byte = Asc(SubStr(stream_block, stream_block_pos, 1))
          num_bytes = num_bytes + 1
          byte_modulus = (byte_modulus + 1) mod 4
          case byte
            when 10, 13
              byte = byte
            when 0
              case byte_modulus
                when 0 zeros_on_mod_0 = zeros_on_mod_0 + 1
                when 1 zeros_on_mod_1 = zeros_on_mod_1 + 1
                when 2 zeros_on_mod_2 = zeros_on_mod_2 + 1
                when 3 zeros_on_mod_3 = zeros_on_mod_3 + 1
              endcase
            when 128 .. 255
              ascii_possible = FALSE
              if utf8_possible
                if ignore_read_utf8_bytes > 0
                  ignore_read_utf8_bytes = ignore_read_utf8_bytes - 1
                else
                  if byte shr 3 == 30
                    if  Asc(SubStr(stream_block, stream_block_pos + 1, 1)) shr 6 == 2
                    and Asc(SubStr(stream_block, stream_block_pos + 2, 1)) shr 6 == 2
                    and Asc(SubStr(stream_block, stream_block_pos + 3, 1)) shr 6 == 2
                      possible_utf8_bytes = possible_utf8_bytes + 1
                      ignore_read_utf8_bytes = 3
                    else
                      utf8_possible = FALSE
                    endif
                  elseif byte shr 4 == 14
                    if  Asc(SubStr(stream_block, stream_block_pos + 1, 1)) shr 6 == 2
                    and Asc(SubStr(stream_block, stream_block_pos + 2, 1)) shr 6 == 2
                      possible_utf8_bytes = possible_utf8_bytes + 1
                      ignore_read_utf8_bytes = 2
                    else
                      utf8_possible = FALSE
                    endif
                  elseif byte shr 5 == 6
                    if Asc(SubStr(stream_block, stream_block_pos + 1, 1)) shr 6 == 2
                      possible_utf8_bytes = possible_utf8_bytes + 1
                      ignore_read_utf8_bytes = 1
                    else
                      utf8_possible = FALSE
                    endif
                  endif
                endif
              endif
          endcase
        endif
        stream_block_pos = stream_block_pos + 1
      until stream_block_pos > stream_block_size
         or stream_size      > cfg_max_bytes_to_check
      if num_bytes > 0
        if     ((zeros_on_mod_0 + zeros_on_mod_1 + zeros_on_mod_2) * 10) / num_bytes >= 7
          content_format = 'UTF-32BE'
        elseif ((zeros_on_mod_1 + zeros_on_mod_2 + zeros_on_mod_3) * 10) / num_bytes >= 7
          content_format = 'UTF-32LE'
        elseif ((zeros_on_mod_0 + zeros_on_mod_2) * 10) / num_bytes >= 4
          content_format = 'UTF-16BE'
        elseif ((zeros_on_mod_1 + zeros_on_mod_3) * 10) / num_bytes >= 4
          content_format = 'UTF-16LE'
        elseif  utf8_possible
        and     possible_utf8_bytes > 0
          content_format = 'UTF-8'
        elseif ascii_possible
          content_format = 'ASCII'
        else
          content_format = 'ANSI'
        endif
      endif
    else
      content_format = byte_order_mark
    endif
    fClose(handle)
  endif
  PopPosition()   // xx   Why?
  if content_format == ''
    if byte_order_mark == ''
      result = ''
    else
      result = byte_order_mark + '+BOM'
    endif
  else
    if     byte_order_mark == ''
      result = content_format
    elseif byte_order_mark == content_format
      result = content_format + '+BOM'
    else
      result = content_format + '!BOM'
      beeper()
      UpdateDisplay(_ALL_WINDOWS_REFRESH_)
      Warn("Unicode error: The file's byte order mark (BOM) does not match its actual character encoding!")
    endif
  endif
  if result <> ''
    SetBufferStr(varname_character_encoding, result)
  endif
  return(result)
end get_character_code_format

integer proc is_current_loaded_file_utf8()
  integer byte                   = 0
  string  find_options       [3] = 'gx'
  integer possible_utf8_chars    = 0
  integer progress_counter       = 0
  integer result                 = FALSE
  integer utf8_possible          = TRUE
  PushPosition()
  while utf8_possible
  and   lFind(FIND_POSSIBLE_UTF8_MULTI_BYTE, find_options)
    progress_counter = progress_counter + 1
    if progress_counter mod 100 == 0
      antifreeze()
      Message('Checking if this is a UTF-8 file ... ', CurrLine() * 100 / NumLines(), '% ... ')
      antifreeze()
    endif
    byte = CurrChar()
    if byte shr 5 == 6
      if CurrChar(CurrPos() + 1) shr 6 == 2
        possible_utf8_chars = possible_utf8_chars + 1
        NextChar()
      else
        utf8_possible = FALSE
      endif
    elseif byte shr 4 == 14
      if  CurrChar(CurrPos() + 1) shr 6 == 2
      and CurrChar(CurrPos() + 2) shr 6 == 2
        possible_utf8_chars = possible_utf8_chars + 1
        NextChar(2)
      else
        utf8_possible = FALSE
      endif
    elseif byte shr 3 == 30
      if  CurrChar(CurrPos() + 1) shr 6 == 2
      and CurrChar(CurrPos() + 2) shr 6 == 2
      and CurrChar(CurrPos() + 3) shr 6 == 2
        possible_utf8_chars = possible_utf8_chars + 1
        NextChar(3)
      else
        utf8_possible = FALSE
      endif
    endif
    find_options = 'x+'
  endwhile
  PopPosition()
  if  utf8_possible
  and possible_utf8_chars > 0
    result = TRUE
  endif
  return(result)
end          is_current_loaded_file_utf8

proc codepoint_to_ansi(integer codepoint, var string ansi_string)
  integer ansi_code = -1
  case codepoint
    when    0 .. 126
      ansi_code = codepoint
    when  160 .. 255
      ansi_code = codepoint
    otherwise
      ansi_code = Val(SubStr(ansi_codes,
                             Pos(' ' + Str(codepoint) + ' ',
                                 ansi_codepoints           ) + 1,
                             3))
      if ansi_code == 0
        ansi_code = -1
      endif
  endcase
  if ansi_code >= 0
    ansi_string = Chr(ansi_code)
  else
    ansi_string = Chr(127) + Upper(Str(codepoint, 16)) + Chr(127)
  endif
end codepoint_to_ansi

integer proc utf8_to_codepoint(var integer utf8_length)
  integer codepoint              = 0
  integer length_bits_filter     = 11100000b
  integer bits_indicating_length = 11000000b
  integer offset                 = 0
  if CurrChar() < 128
    utf8_length = 1
    codepoint   = CurrChar()
  else
    // Determine utf8-character's length in bytes based on first byte.
    utf8_length            = 2
    while utf8_length      < 5
    and   (CurrChar() & length_bits_filter) <> bits_indicating_length
      utf8_length            = utf8_length + 1
      length_bits_filter     = (length_bits_filter     shr 1) + 10000000b
      bits_indicating_length = (bits_indicating_length shr 1) + 10000000b
    endwhile
    if utf8_length == 5
      gigo()
      utf8_length = 1
      codepoint   = CurrChar()
    else
      codepoint = CurrChar() & Val(GetToken(utf8_first_byte_filters,
                                            ' ', utf8_length))
      offset = 1
      while offset < utf8_length
        if (CurrChar(CurrPos() + offset) & 11000000b) == 10000000b
          codepoint = (codepoint shl 6) +
                      (CurrChar(CurrPos() + offset) & 00111111b)
        else
          gigo()
          utf8_length = 1
          codepoint   = CurrChar()
        endif
        offset = offset + 1
      endwhile
    endif
  endif
  return(codepoint)
end utf8_to_codepoint

proc utf8_to_ansi()
  string  ansi_string  [14] = ''
  integer codepoint         = 0
  string  find_options  [3] = 'gx'
  integer old_filechanged   = FileChanged()
  integer old_undomode      = UndoMode()
  integer progress_counter  = 0
  integer utf8_length       = 0
  SetUndoOff()
  PushPosition()
  PushBlock()
  UnMarkBlock()
  Message('Loading'; CurrFilename())
  BegFile()
  if  Pos('BOM', GetBufferStr(varname_character_encoding)) > 0
  and GetText(1,3) == BOM_UTF8
    MarkColumn(1, 1, 1, 3)
    KillBlock()
  endif
  while lFind(FIND_POSSIBLE_UTF8_MULTI_BYTE, find_options)
    progress_counter = progress_counter + 1
    if progress_counter mod 100 == 0
      msg(Format('UTF-8 to ANSI …'; CurrLine() / (NumLines() / 100):3, '%'))
      afterwards_restore_status_line = TRUE
    endif
    codepoint = utf8_to_codepoint(utf8_length)
    codepoint_to_ansi(codepoint, ansi_string)
    if        utf8_length  <> 1
    or Length(ansi_string) <> 1
      MarkChar()
      Right(utf8_length)
      KillBlock()
      InsertText(ansi_string, _INSERT_)
      PrevChar()
    endif
    find_options = 'x+'
  endwhile
  msg('')
  PopBlock()
  PopPosition()
  FileChanged(old_filechanged)
  if old_undomode
    SetUndoOn()
  endif
end utf8_to_ansi

proc codepoint_to_utf32be(integer codepoint, var string utf32be_char)
  integer chopped_codepoint = codepoint
  utf32be_char = ''
  repeat
    utf32be_char      = Chr(chopped_codepoint mod 256) + utf32be_char
    chopped_codepoint = chopped_codepoint / 256
  until Length(utf32be_char) == 4
end codepoint_to_utf32be

proc codepoint_to_utf32le(integer codepoint, var string utf32le_char)
  string utf32be_char [4] = ''
  codepoint_to_utf32be(codepoint, utf32be_char)
  utf32le_char = utf32be_char[4:1] +
                 utf32be_char[3:1] +
                 utf32be_char[2:1] +
                 utf32be_char[1:1]
end codepoint_to_utf32le

proc codepoint_to_utf16be(integer codepoint, var string utf16be_char)
  integer high_6x          = 0
  integer high_surrogate   = 0
  integer low_10x          = 0
  integer low_surrogate    = 0
  integer uuuuu            = 0
  integer wwww             = 0
  if     codepoint <= 0xD7FF
  or (   codepoint >= 0xE000
     and codepoint <= 0xFFFF)
    utf16be_char = Chr(codepoint / 256) + Chr(codepoint mod 256)
  elseif codepoint >    0xFFFF
  and    codepoint <= 0x10FFFF
    low_10x =  codepoint &            1111111111b
    high_6x = (codepoint &      1111110000000000b) shr 10
    uuuuu   = (codepoint & 111110000000000000000b) shr 16
    wwww    = (uuuuu - 1                         ) shl  6

    high_surrogate = 1101100000000000b + wwww + high_6x
    low_surrogate  = 1101110000000000b +        low_10x

    utf16be_char = Chr(high_surrogate  /  256) +
                   Chr(high_surrogate mod 256) +
                   Chr( low_surrogate  /  256) +
                   Chr( low_surrogate mod 256)
  else
    gigo()
    utf16be_char = Chr(0) + '?'
  endif
end codepoint_to_utf16be

proc codepoint_to_utf16le(integer codepoint, var string utf16le_char)
  string utf16be_char [4] = ''
  codepoint_to_utf16be(codepoint, utf16be_char)
  if Length(utf16be_char) == 2
    utf16le_char = utf16be_char[2:1] +
                   utf16be_char[1:1]
  else
    utf16le_char = utf16be_char[2:1] +
                   utf16be_char[1:1] +
                   utf16be_char[4:1] +
                   utf16be_char[3:1]
  endif
end codepoint_to_utf16le

#ifndef LINUX

  proc display_unicode_character(integer codepoint)
    string utf16le_char [255] = Format('':255:Chr(0))
    utf16le_char = Chr(255) + Chr(254) +
                   Chr( 32) + Chr(  0) +
                   Chr( 32) + Chr(  0) +
                   Chr( 32) + Chr(  0) +
                   Chr(  0) + Chr(  0)
    TextOutw( device_context_handle,
              cfg_unicode_x,
              cfg_unicode_y,
              AdjPtr(Addr(utf16le_char), 2),
              4)
    codepoint_to_utf16le(codepoint, utf16le_char)
    utf16le_char = Chr(255) + Chr(254) +
                   Chr( 32) + Chr(  0) +
                   utf16le_char        +
                   Chr( 32) + Chr(  0) +
                   Chr(  0) + Chr(  0)
    TextOutw( device_context_handle,
              cfg_unicode_x,
              cfg_unicode_y,
              AdjPtr(Addr(utf16le_char), 2),
              4)
  end display_unicode_character

#endif

proc utf32be_to_codepoint(string utf32be_char, var integer codepoint)
  codepoint = Asc(utf32be_char[1:1]) * 256 * 256 * 256 +
              Asc(utf32be_char[2:1]) * 256 * 256       +
              Asc(utf32be_char[3:1]) * 256             +
              Asc(utf32be_char[4:1])
end utf32be_to_codepoint

proc utf32le_to_codepoint(string utf32le_char, var integer codepoint)
  codepoint = Asc(utf32le_char[1:1])                   +
              Asc(utf32le_char[2:1]) * 256             +
              Asc(utf32le_char[3:1]) * 256 * 256       +
              Asc(utf32le_char[4:1]) * 256 * 256 * 256
end utf32le_to_codepoint

proc utf16be_to_codepoint(string utf16be_char, var integer codepoint)
  integer high_4w        = 0
  integer high_6x        = 0
  integer high_surrogate = 0
  integer low_10x        = 0
  integer low_surrogate  = 0
  integer uuuuu          = 0
  codepoint = Asc(utf16be_char[1:1]) * 256 +
              Asc(utf16be_char[2:1])
  if (codepoint in 0xD800 .. 0xDBFF)
    high_surrogate   = codepoint
    low_surrogate    = Asc(utf16be_char[3:1]) * 256  +
                       Asc(utf16be_char[4:1])
    if (low_surrogate in 0xDC00 .. 0xDFFF)
      high_6x   = (high_surrogate &     111111b) shl 10
      high_4w   = (high_surrogate & 1111000000b) shr  6
      low_10x   =  low_surrogate  & 1111111111b
      uuuuu     = (high_4w + 1                 ) shl 16
      codepoint = uuuuu + high_6x + low_10x
    else
      gigo()
    endif
  endif
end utf16be_to_codepoint

proc utf16le_to_codepoint(string utf16le_char, var integer codepoint)
  string  utf16be_char [4] = utf16le_char[2:1] +
                             utf16le_char[1:1] +
                             utf16le_char[4:1] +
                             utf16le_char[3:1]
  utf16be_to_codepoint(utf16be_char, codepoint)
end utf16le_to_codepoint

integer proc defuse(string character_encoding)
  integer result = ( Pos(SubStr(character_encoding, 1, 8),
                         'UTF-16BE UTF-16LE UTF-32BE UTF-32LE')
                     + 8) / 9
  return(result)
end defuse

proc binary_lines_to_text_lines(string  character_encoding,
                                integer percentage_range_from)
  integer concatenated_line_length  = 0
  integer found_text_length         = 0
  string  line_search_options   [2] = 'gx'
  integer old_curr_line             = 0
  integer old_num_lines             = NumLines()
  integer progress_counter          = FALSE
  integer split_warned              = FALSE
  BegFile()
  // UpdateDisplay(_STATUSLINE_REFRESH_|_REFRESH_THIS_ONLY_)
  while lFind('{\d013\d010}|\d013|\d010|$', line_search_options)
    found_text_length = Length(GetFoundText())
    if found_text_length
      if  found_text_length ==  1
      and CurrChar()        == 13
        PushLocation()
        if Down()
          if CurrChar(1) == 10
            BegLine()
            DelChar()
          endif
          PopLocation()
        else
          KillLocation()
        endif
      endif
      DelChar(found_text_length)
      if CurrChar() <> _AT_EOL_
        SplitLine()
      endif
      line_search_options = 'x+'
    else
      progress_counter = progress_counter + 1
      if progress_counter == 1000
        progress_counter = 0
         old_curr_line = old_curr_line + 1000
         Msg(Format(character_encoding; 'to ANSI …';
                    percentage_to_range(old_curr_line / (old_num_lines / 100),
                                        percentage_range_from,
                                        100):3,
                    '% '))
      endif
      if not split_warned
        concatenated_line_length = CurrLineLen()
        if Down()
          concatenated_line_length = concatenated_line_length + CurrLineLen()
          Up()
        endif
        if  concatenated_line_length > MAXLINELEN
          Alarm()
          UpdateDisplay(_ALL_WINDOWS_REFRESH_)
          Warn('Unicode conversion had to split lines too long for TSE.'
               + Chr(13)
               + 'The created buffer will be a corrupted version of the file.')
          split_warned = TRUE
        endif
      endif
      if split_warned
      or CurrLine() == NumLines()
        line_search_options = 'x+'
      else
        JoinLine()
        line_search_options = 'x'
      endif
    endif
  endwhile
  msg('')
end binary_lines_to_text_lines

proc show_utf_to_ansi_char_progress(string  bomless_utf_name,
                                    integer percentage_range_to)
  Msg(Format(bomless_utf_name; 'to ANSI …';
             percentage_to_range(CurrLine() / (NumLines() / 100),
                                 0,
                                 percentage_range_to):3,
             '% '))
end show_utf_to_ansi_char_progress

proc binary_utf16be_to_normal_ansi(string  character_encoding,
                                   integer percentage_range_to)
  string  ansi_char         [8] = ''
  integer codepoint             = 0
  integer i                     = 0
  string  low_surrogate     [2] = ''
  string  nulled_ansi_char [16] = ''
  integer progress_counter      = 0
  string  utf16be_char      [4] = ''

  BegFile()
  repeat
    if CurrChar() == _AT_EOL_
      PrevChar()
      progress_counter = progress_counter + 1
      if progress_counter == 1000
        progress_counter = 0
        show_utf_to_ansi_char_progress(character_encoding, percentage_range_to)
      endif
    else
      if CurrChar()              <> 0
      or CurrChar(CurrPos() + 1) >= 128
        utf16be_char = GetText(CurrPos(), 2)
        if (CurrChar() in 0xD8 .. 0xDB)
          if  CurrChar(CurrPos() + 2) == _AT_EOL_
          and CurrLine() < NumLines()
            PushLocation()
            Down()
            low_surrogate = GetText(1, 2)
            BegLine()
            DelChar(2)
            Up()
            EndLine()
            InsertText(low_surrogate)
            PopLocation()
          endif
          utf16be_char = GetText(CurrPos(), 4)
        endif
        utf16be_to_codepoint(utf16be_char, codepoint)
        codepoint_to_ansi(codepoint, ansi_char)
        nulled_ansi_char = ''
        for i = 1 to Length(ansi_char)
          nulled_ansi_char = nulled_ansi_char + Chr(0) + ansi_char[i]
        endfor
        DelChar(Length(utf16be_char))
        InsertText(nulled_ansi_char)
        PrevChar(2)
      endif
    endif
  until not NextChar(2)
end binary_utf16be_to_normal_ansi

proc binary_utf16le_to_normal_ansi(string  character_encoding,
                                   integer percentage_range_to)
  string  ansi_char         [8] = ''
  integer codepoint             = 0
  integer i                     = 0
  string  low_surrogate     [2] = ''
  string  nulled_ansi_char [16] = ''
  integer progress_counter      = 0
  string  utf16le_char      [4] = ''

  BegFile()
  repeat
    if CurrChar() == _AT_EOL_
      PrevChar()
      progress_counter = progress_counter + 1
      if progress_counter == 1000
        progress_counter = 0
        show_utf_to_ansi_char_progress(character_encoding, percentage_range_to)
      endif
    else
      if CurrChar()              >= 128
      or CurrChar(CurrPos() + 1) <> 0
        utf16le_char = GetText(CurrPos(), 2)
        if (CurrChar(CurrPos() + 1) in 0xD8 .. 0xDB)
          if  CurrChar(CurrPos() + 2) == _AT_EOL_
          and CurrLine() < NumLines()
            PushLocation()
            Down()
            low_surrogate = GetText(1, 2)
            BegLine()
            DelChar(2)
            Up()
            EndLine()
            InsertText(low_surrogate)
            PopLocation()
          endif
          utf16le_char = GetText(CurrPos(), 4)
        endif
        utf16le_to_codepoint(utf16le_char, codepoint)
        codepoint_to_ansi(codepoint, ansi_char)
        nulled_ansi_char = ''
        for i = 1 to Length(ansi_char)
          nulled_ansi_char = nulled_ansi_char + ansi_char[i] + Chr(0)
        endfor
        DelChar(Length(utf16le_char))
        InsertText(nulled_ansi_char)
        PrevChar(2)
      endif
    endif
  until not NextChar(2)
end binary_utf16le_to_normal_ansi

proc binary_utf32be_to_normal_ansi(string  character_encoding,
                                   integer percentage_range_to)
  string  ansi_char         [8] = ''
  integer codepoint             = 0
  integer i                     = 0
  string  nulled_ansi_char [32] = ''
  integer progress_counter      = 0
  string  utf32be_char      [4] = ''

  BegFile()
  repeat
    if CurrChar() == _AT_EOL_
      PrevChar(3)
      progress_counter = progress_counter + 1
      if progress_counter == 1000
        progress_counter = 0
        show_utf_to_ansi_char_progress(character_encoding, percentage_range_to)
      endif
    else
      if GetText( CurrPos() , 3) <> THREE_NULL_BYTES
      or CurrChar(CurrPos() + 3) >= 128
        utf32be_char = GetText(CurrPos(), 4)
        utf32be_to_codepoint(utf32be_char, codepoint)
        codepoint_to_ansi(codepoint, ansi_char)
        nulled_ansi_char = ''
        for i = 1 to Length(ansi_char)
          nulled_ansi_char = nulled_ansi_char + THREE_NULL_BYTES + ansi_char[i]
        endfor
        DelChar(4)
        InsertText(nulled_ansi_char)
        PrevChar(4)
      endif
    endif
  until not NextChar(4)
end binary_utf32be_to_normal_ansi

proc binary_utf32le_to_normal_ansi(string  character_encoding,
                                   integer percentage_range_to)
  string  ansi_char         [8] = ''
  integer codepoint             = 0
  integer i                     = 0
  string  nulled_ansi_char [32] = ''
  integer progress_counter      = 0
  string  utf32le_char      [4] = ''

  BegFile()
  repeat
    if CurrChar() == _AT_EOL_
      PrevChar(3)
      progress_counter = progress_counter + 1
      if progress_counter == 1000
        progress_counter = 0
        show_utf_to_ansi_char_progress(character_encoding, percentage_range_to)
      endif
    else
      if CurrChar(CurrPos() + 3   ) >= 128
      or GetText (CurrPos() + 1, 3) <> THREE_NULL_BYTES
        utf32le_char = GetText(CurrPos(), 4)
        utf32le_to_codepoint(utf32le_char, codepoint)
        codepoint_to_ansi(codepoint, ansi_char)
        nulled_ansi_char = ''
        for i = 1 to Length(ansi_char)
          nulled_ansi_char = nulled_ansi_char + ansi_char[i] + THREE_NULL_BYTES
        endfor
        DelChar(4)
        InsertText(nulled_ansi_char)
        PrevChar(4)
      endif
    endif
  until not NextChar(4)
end binary_utf32le_to_normal_ansi

proc binary_utf1632_to_normal_ansi()
  integer bomless_character_encoding   = 0
  string  bytes_replace_string     [6] = ''
  string  character_encoding      [13] = ''
  integer line_block_size              = 0
  integer line_from                    = 0
  integer line_to                      = 0
  integer old_FileChanged              =     FileChanged()
  integer old_Insert                   = Set(Insert             , ON )
  integer old_RemoveTrailingWhite      = Set(RemoveTrailingWhite, OFF)
  integer old_UndoMode                 =     UndoMode(            OFF)
  integer part_2_percentage_range_from = 0
  integer part_2_percentage_range_to   = 0

  #if DEBUG_LOG
    integer t0 = GetTime()
    integer t1 = 0
    integer t2 = 0
    integer t3 = 0
  #endif

  character_encoding         = GetBufferStr(varname_character_encoding)
  bomless_character_encoding = defuse(character_encoding)

  if NumLines()   // Not an empty buffer?
    PushBlock()

    if Pos('BOM', character_encoding)
      if SubStr(character_encoding, 5, 2) == '16'
        MarkColumn(1, 1, 1, 2)
      else
        MarkColumn(1, 1, 1, 4)
      endif
      KillBlock()
    endif

    // Loading: Conversion part 1/3: UTF characters to ANSI characters.

    BegFile()
    Message('Loading'; CurrFilename())
    msg(Format(character_encoding; 'to ANSI …   0% '))

    case bomless_character_encoding
      when UTF16LE
        binary_utf16le_to_normal_ansi(character_encoding, 15)

        bytes_replace_string         = '{.}.'
        part_2_percentage_range_from = 15
        part_2_percentage_range_to   = 91
      when UTF16BE
        binary_utf16be_to_normal_ansi(character_encoding, 15)

        bytes_replace_string         = '.{.}'
        part_2_percentage_range_from = 15
        part_2_percentage_range_to   = 91
      when UTF32LE
        binary_utf32le_to_normal_ansi(character_encoding, 26)

        bytes_replace_string         = '{.}...'
        part_2_percentage_range_from = 26
        part_2_percentage_range_to   = 92
      when UTF32BE
        binary_utf32be_to_normal_ansi(character_encoding, 26)

        bytes_replace_string         = '...{.}'
        part_2_percentage_range_from = 26
        part_2_percentage_range_to   = 92
      otherwise
        programming_error(7)
    endcase
    msg('')

    #if DEBUG_LOG
      t1 = GetTime()
    #endif

    // Loading: Conversion part 2/3: Replacing each 2 or 4 bytes with 1 byte.

    BegFile()
    // UpdateDisplay(_STATUSLINE_REFRESH_|_REFRESH_THIS_ONLY_)

    line_block_size = NumLines() / 100
    line_block_size = iif(line_block_size < 1000, 1000, line_block_size)
    line_from       = 1
    line_to         = line_from + line_block_size - 1
    line_to         = iif(line_to > NumLines(), NumLines(), line_to)

    repeat
      msg(Format(character_encoding; 'to ANSI …';
                 percentage_to_range(line_from / (NumLines() / 100),
                                     part_2_percentage_range_from  ,
                                     part_2_percentage_range_to    ):3,
                 '% '))
      MarkLine(line_from, line_to)
      lReplace(bytes_replace_string, '\1', 'glnx')
      UnMarkBlock()
      line_from = line_from + line_block_size
      line_to   = line_from + line_block_size - 1
      line_to   = iif(line_to > NumLines(), NumLines(), line_to)
    until line_from > NumLines()

    msg('')

    #if DEBUG_LOG
      t2 = GetTime()
    #endif

    // Loading: Conversion part 3/3: Converting binary lines to text lines.
    // (Part 3's percentage_range_from is part 2's percentage_range_to.)

    binary_lines_to_text_lines(character_encoding, part_2_percentage_range_to)

    #if DEBUG_LOG
      t3 = GetTime()
      ExecMacro('Log open D:\Zest\Log_Unicode3.txt')
      ExecMacro('Log write Loading ' + QuotePath(CurrFilename()))
      ExecMacro('Log write ' + character_encoding + ' to ANSI by ' + my_macro_name)
      ExecMacro('Log write Converted characters: ' + Str(t1 - t0))
      ExecMacro('Log write Each '
                + iif(character_encoding[1:6] == 'UTF-16', '2', '4')
                + ' bytes to 1 byte: ' + Str(t2 - t1))
      ExecMacro('Log write Binary lines to text lines: ' + Str(t3 - t2))
      ExecMacro('Log write Total: '                      + Str(t3 - t0))
      ExecMacro('Log close')
    #endif

    BegFile()
    antifreeze()
    Message('')
    antifreeze()

    BegFile()
    PopBlock()
  endif

  BinaryMode(0)

      FileChanged        ( old_FileChanged        )
  Set(Insert             , old_Insert             )
  Set(RemoveTrailingWhite, old_RemoveTrailingWhite)
      UndoMode           ( old_UndoMode           )
end binary_utf1632_to_normal_ansi

proc on_file_load()
  string character_encoding [13] = ''
  if is_normal_file()
    character_encoding = get_character_code_format()
    if (SubStr(character_encoding, 1, 6) in 'UTF-16', 'UTF-32')
      BinaryMode(BINARYMODE_LINE_LENGTH)
      SetBufferInt(varname_conversion_flag, TRUE)
    endif
  endif
end on_file_load

proc on_first_edit()
  /*
    Note about a TSE bug:
      Contrary to what its documentation states, the _ON_FIRST_EDIT_ hook
      is also called when changing an already loaded file's name.
    Note about character encoding detection:
      The _on_file_load_ only parsed the first few bytes of the file to detect
      its character encoding, and it therefore might not have detected yet
      that an ASCII or ANSI file is actually an ANSI or UTF-8 file.
      Here in _on_first_edit_ we have the advantage that we already have the
      whole file in memory, and can do a fast complete check.
  */
  string character_encoding [13] = ''
  if not GetBufferInt(varname_first_edited)
    SetBufferInt(varname_first_edited, TRUE)
    afterwards_restore_status_line = FALSE
    if is_normal_file()
      character_encoding = GetBufferStr(varname_character_encoding)
      if character_encoding == 'ASCII'
        PushPosition()
        if lFind(FIND_NON_ASCII, 'gx')
          PopPosition()
          character_encoding = 'ANSI'
          SetBufferStr(varname_character_encoding, character_encoding)
        else
          KillPosition()
        endif
      endif
      if character_encoding == 'ANSI'
        if is_current_loaded_file_utf8()
          character_encoding = 'UTF-8'
          SetBufferStr(varname_character_encoding, character_encoding)
        endif
      endif
      if not (character_encoding in 'ANSI', 'ASCII', '')
        if  cfg_convert_unicode_files
        and SubStr(character_encoding, 1, 5) == 'UTF-8'
          utf8_to_ansi()
        endif
      endif
    else
      // - The file is already loaded in binary mode.
      if GetBufferInt(varname_conversion_flag)
        DelBufferVar(varname_conversion_flag)
        binary_utf1632_to_normal_ansi()
      endif
    endif
    if afterwards_restore_status_line
      UpdateDisplay(_STATUSLINE_REFRESH_|_REFRESH_THIS_ONLY_)
    endif
  endif
end on_first_edit

proc codepoint_to_utf8(integer codepoint, var string utf8_bytes)
  integer first_byte_upper_bits           = 0
  integer lower_6_bits                    = 0
  integer placeable_amount_1st_byte_bits  = 0
  integer upper_bits                      = 0
  if codepoint <= 127
    utf8_bytes                     = Chr(codepoint)
  else
    utf8_bytes                     = ''
    upper_bits                     = codepoint
    first_byte_upper_bits          = 128
    placeable_amount_1st_byte_bits = 6
    repeat
      first_byte_upper_bits          = 128 + (first_byte_upper_bits shr 1)
      placeable_amount_1st_byte_bits = placeable_amount_1st_byte_bits - 1
      lower_6_bits                   = upper_bits mod 64
      upper_bits                     = upper_bits  /  64
      utf8_bytes                     = Chr(128 + lower_6_bits) + utf8_bytes
    until placeable_amount_1st_byte_bits == 0
       or Length(Str(upper_bits, 2))     <= placeable_amount_1st_byte_bits
    if placeable_amount_1st_byte_bits == 0
      gigo()
      utf8_bytes = '<codepoint>' + Upper(Str(codepoint, 16)) + '</codepoint>'
    else
      utf8_bytes = Chr(first_byte_upper_bits + upper_bits) + utf8_bytes
    endif
  endif
//  ExecMacro('log write Codepoint="' + Str(codepoint) + '" Utf8_bytes="' + utf8_bytes + '".')
end codepoint_to_utf8

proc ansi_to_codepoint(string ansi_char, var integer codepoint)
  integer byte      = 0
  if Length(ansi_char) == 1
    byte = Asc(ansi_char)
    case byte
      when 0 .. 127
        codepoint = byte
      when 160 .. 255
        codepoint = byte
      otherwise
        codepoint = Val(SubStr(ansi_codepoints,
                               Pos(' ' + Str(byte) + ' ',
                                   ansi_codes             ) + 1,
                               4))
        if codepoint == 0
          gigo()
          codepoint = byte
        endif
    endcase
  elseif Length(ansi_char)                     >  1
  and           ansi_char[1:1]                 == Chr(127)
  and           ansi_char[Length(ansi_char):1] == Chr(127)
    codepoint = Val(ansi_char[2:Length(ansi_char) - 2], 16)
  else
    gigo()
    codepoint = Asc(ansi_char)
  endif
end ansi_to_codepoint

/*
  Given that a Unicode text may contain characters that are a codepoint between
  chr(127) delimiters, this function can also retrieve such a string including
  the delimiters.
  "go_left = FALSE" assumes that the cursor is always at the start of a
  character, which allows faster processing of whole lines of characters.
  "go_left = TRUE" also retrieves a delimited codepoint string when the cursor
  is not at the beginning of that string, and is more useful when you only want
  the current character.
  At or past the end of a line the function returns an empty string.
  The function does not advance the cursor.
*/
string proc get_text_char(integer go_left)
  string  text_char [9] = ''
  integer old_pos       = CurrPos()
  integer delimiter_pos = FALSE
  if     go_left == THAT_STARTS_AT_THE_CURSOR
    if CurrChar() == 127
      delimiter_pos = CurrPos()
    endif
  elseif go_left == THAT_THE_CURSOR_IS_ON_ANYWHERE
    Right()
    if lFind('\d127', 'bcx')
      delimiter_pos = CurrPos()
    endif
  endif
  if  delimiter_pos
  and lFind(FIND_ANSI_CODEPOINT, 'cx')
  and CurrPos() == delimiter_pos
  and Length(GetFoundText()) <= 8
    text_char = GetFoundText()
  else
    text_char = GetText(old_pos, 1)
  endif
  GotoPos(old_pos)
  return(text_char)
end         get_text_char

proc ansi_to_utf8()
  string  ansi_char       [9] = ''
  integer codepoint           = 0
  string  find_options    [3] = 'gx'
  integer old_filechanged     = FileChanged()
  integer old_undomode        = UndoMode()
  integer progress_counter    = 0
  string  utf8_char       [5] = ''
  SetUndoOff()
  PushPosition()
  PushBlock()
  UnMarkBlock()
  BegFile()
  if Query(MsgLevel) == _ALL_MESSAGES_
    Message('Saving me'; CurrFilename())
  endif
  while lFind(FIND_UNICODE_IN_ANSI, find_options)
    progress_counter = progress_counter + 1
    if progress_counter mod 100 == 0
      msg(Format('ANSI to UTF-8 …'; CurrLine() / (NumLines() / 100):3, '%'))
      afterwards_restore_status_line = TRUE
    endif
    ansi_char = get_text_char(THAT_STARTS_AT_THE_CURSOR)
    ansi_to_codepoint(ansi_char, codepoint)
    codepoint_to_utf8(codepoint, utf8_char)
    if Length(ansi_char) > 1
    or Length(utf8_char) > 1
      MarkChar()
      Right(Length(ansi_char))
      KillBlock()
      InsertText(utf8_char, _INSERT_)
      PrevChar()
    endif
    find_options = 'x+'
  endwhile
  msg('')
  BegFile()
  if Pos('BOM', GetBufferStr(varname_character_encoding)) > 0
  and GetText(1,3) <> BOM_UTF8
    InsertText(BOM_UTF8, _INSERT_)
  endif
  PopBlock()
  PopPosition()
  FileChanged(old_filechanged)
  if old_undomode
    SetUndoOn()
  endif
end ansi_to_utf8

proc strip_nulls(string s, integer byte_in_char_position, integer char_size,
                 var string result)
  integer i = 0
  result = ''
  for i = byte_in_char_position to Length(s) by char_size
    result = result + s[i]
  endfor
end strip_nulls

proc ansi_to_utf1632(integer bomless_character_encoding,
                     string  character_encoding        )
  string  ansi_char                [8] = ''
  integer byte_in_nulled_char_offset   = 0
  integer byte_in_nulled_char_position = 0
  integer char_pos                     = 0
  integer codepoint                    = 0
  integer default_char_size            = 0
  integer default_char_size_minus_1    = 0
  string  nulled_ansi_char        [32] = ''
  integer percentage_range_from        = 0
  integer progress_counter             = 0
  integer progress_report_step_size    = 0
  integer remaining_bytes_offset       = 0
  string  utf_char                 [4] = ''

  progress_report_step_size = NumLines() / 100
  if progress_report_step_size < 1000
    progress_report_step_size = 1000
  endif

  case bomless_character_encoding
    when UTF16LE
      byte_in_nulled_char_offset   =  0
      byte_in_nulled_char_position =  1
      default_char_size            =  2
      default_char_size_minus_1    =  1
      remaining_bytes_offset       =  1
      percentage_range_from        = 94
    when UTF16BE
      byte_in_nulled_char_offset   =  1
      byte_in_nulled_char_position =  2
      default_char_size            =  2
      default_char_size_minus_1    =  1
      remaining_bytes_offset       =  0
      percentage_range_from        = 94
    when UTF32LE
      byte_in_nulled_char_offset   =  0
      byte_in_nulled_char_position =  1
      default_char_size            =  4
      default_char_size_minus_1    =  3
      remaining_bytes_offset       =  3
      percentage_range_from        = 91
    when UTF32BE
      byte_in_nulled_char_offset   =  3
      byte_in_nulled_char_position =  4
      default_char_size            =  4
      default_char_size_minus_1    =  3
      remaining_bytes_offset       =  0
      percentage_range_from        = 91
  endcase

  BegFile()
  // UpdateDisplay(_STATUSLINE_REFRESH_|_REFRESH_THIS_ONLY_)
  repeat
    if CurrChar() == _AT_EOL_
      PrevChar(default_char_size_minus_1)
      progress_counter = progress_counter + 1
      if progress_counter == progress_report_step_size
        progress_counter = 0
        Msg(Format('ANSI to'; character_encoding; '…';
                   percentage_to_range(CurrLine() / (NumLines() / 100),
                                       percentage_range_from          ,
                                       100                            ):3,
                   '% '))
      endif
    else
      if CurrChar(CurrPos() + byte_in_nulled_char_offset) >= 127
        nulled_ansi_char = GetText(CurrPos(), default_char_size)
        ansi_char        = nulled_ansi_char[1 + byte_in_nulled_char_offset]
        if ansi_char == Chr(127)
          char_pos = CurrPos()
          Right(default_char_size)
          if lFind(Chr(127), 'c')
            nulled_ansi_char = GetText(char_pos,
                                       CurrPos() + remaining_bytes_offset
                                       - char_pos + 1)
            // Tests showed that in the following statement strip_nulls()
            // is roughly 11 times faster than a StrReplace() could do it.
            strip_nulls(nulled_ansi_char , byte_in_nulled_char_position,
                        default_char_size, ansi_char)
          else
            gigo()
          endif
          GotoPos(char_pos)
        endif
        ansi_to_codepoint(ansi_char, codepoint)
        // Performance consideration: Of these four Windows favours UTF-16LE.
        case bomless_character_encoding
          when UTF16LE
            codepoint_to_utf16le(codepoint, utf_char)
          when UTF16BE
            codepoint_to_utf16be(codepoint, utf_char)
          when UTF32LE
            codepoint_to_utf32le(codepoint, utf_char)
          when UTF32BE
            codepoint_to_utf32be(codepoint, utf_char)
        endcase
        // Performance tests showed:
        // - Buffer-editing operations are very expensive compared to
        //   calculations and comparisons. Here the run time of the
        //   if-condition is negligeable compared to either of its branches.
        // - The following if-statement's TRUE branch is roughly 13 times
        //   faster than its FALSE branch.
        // Given that typically the TRUE branch will occur a lot more often,
        // the following construct is more code but saves a lot of run time.
        if Length(nulled_ansi_char) == default_char_size
          InsertText(utf_char, _OVERWRITE_)
        else
          DelChar(Length(nulled_ansi_char))
          InsertText(utf_char)
        endif
        PrevChar(default_char_size)
      endif
    endif
  until not NextChar(default_char_size)
  msg('')
end ansi_to_utf1632

proc normal_ansi_to_binary_utf1632()
  integer bomless_character_encoding   = 0
  string  character_encoding      [13] = GetBufferStr(varname_character_encoding)
  string  eoltype_current_version [16] = ''
  integer eoltype_version_comparison   = -1
  integer line_block_size              = 0
  integer line_from                    = 0
  integer line_to                      = 0
  string  newline_chars            [2] = Chr(13) + Chr(10)
  integer new_line_length              = 0
  integer ok                           = TRUE
  integer old_insert                   = Set(Insert, ON)
  integer old_undomode                 = UndoMode(OFF)
  integer percentage_range_to          = 0
  integer save_eol_type                = Query(EOLType)

  #if DEBUG_LOG
    integer t0 = GetTime()
    integer t1 = 0
    integer t2 = 0
    integer t3 = 0
    integer t4 = 0
    integer t5 = 0
  #endif

  PushBlock()
  UnMarkBlock()

  bomless_character_encoding = defuse(character_encoding)
  BinaryMode(BINARYMODE_LINE_LENGTH)

  if NumLines()
    // Determine what newline characters to add: CR, LF or CR+LF.
    if not (save_eol_type in 1, 2, 3)
      // Only use EolType version 7 or above.
      eoltype_current_version = GetBufferStr(EOLTYPE_MACRO_NAME + ':Version')
      eoltype_version_comparison =
        compare_versions(eoltype_current_version, EOLTYPE_MACRO_USABLE_VERSION)
      if eoltype_version_comparison <> FIRST_OLDER_THAN_SECOND
        save_eol_type = Val(GetBufferStr('EolType:new_eoltype'))
      endif
      if not (save_eol_type in 1, 2, 3)
        if eoltype_version_comparison <> FIRST_OLDER_THAN_SECOND
          save_eol_type = Val(GetBufferStr('EolType:old_eoltype'))
        endif
        if not (save_eol_type in 1, 2, 3)
          save_eol_type = GetBufferInt(varname_loaded_eoltype)
          if not (save_eol_type in 1, 2, 3)
            save_eol_type = 3
          endif
        endif
      endif
    endif
    newline_chars = iif(    save_eol_type == 1, Chr(13),
                        iif(save_eol_type == 2, Chr(10),
                                                Chr(13) + Chr(10)))

    // Part 1/3: Add newline character(s) at the end of each text line.

    // This first conversion step happens within 1% of the total time,
    // so there is no need for a progress percentage within the loop(s).

    #if DEBUG_LOG
      t1 = GetTime()
    #endif

    // UpdateDisplay(_STATUSLINE_REFRESH_|_REFRESH_THIS_ONLY_)
    Message('Saving'; CurrFilename())
    msg(Format('ANSI to'; character_encoding; '…   0% '))

    BegFile()
    repeat
      if CurrLineLen() > MAXLINELEN_MINUS_2
        AddLine()
      endif
      EndLine()
      InsertText(newline_chars)
    until not Down()

    // The following steps are typically of negligible duration,
    // because they do no or hardly any changes.
    // Coversion might quadruple the binary line sizes. Make sure that post-
    // conversion binary line sizes fit within TSE's maximum line size.
    BegFile()
    repeat
      if CurrLineLen() > MAXLINELEN_DIVIDED_BY_4
        new_line_length = 255
        // Do not split a quoted codepoint.
        while new_line_length > 240
        and   NumTokens(GetText(1, new_line_length), Chr(127)) mod 2 == 0
          new_line_length = new_line_length - 1
        endwhile
        GotoPos(new_line_length + 1)
        SplitLine()
      endif
    until not Down()

    msg('')

    #if DEBUG_LOG
      t2 = GetTime()
    #endif

    // Part 2/3: Prefix or postfix one or three null bytes to each ANSI byte.

    // UpdateDisplay(_STATUSLINE_REFRESH_|_REFRESH_THIS_ONLY_)

    line_block_size = iif(NumLines() / 100 < 1000,
                          1000,
                          NumLines() / 100)
    line_from       = 1
    line_to         = iif (line_from + line_block_size - 1 > NumLines(),
                           NumLines(),
                           line_from + line_block_size - 1)
    case bomless_character_encoding
      when UTF16LE, UTF16BE
        percentage_range_to = 94
      otherwise
        percentage_range_to = 91
    endcase

    repeat
      msg(Format('ANSI to'; character_encoding; '…';
                 percentage_to_range(line_from / (CurrLine() / 100),
                                     1, percentage_range_to):3,
                 '% '))
      MarkLine(line_from, line_to)
      case bomless_character_encoding
        when UTF16BE
          lReplace('{.}', Chr(0) + '\1', 'glnx')
        when UTF16LE
          lReplace('{.}', '\1' + Chr(0), 'glnx')
        when UTF32BE
          lReplace('{.}', THREE_NULL_BYTES + '\1', 'glnx')
        when UTF32LE
          lReplace('{.}', '\1' + THREE_NULL_BYTES, 'glnx')
        otherwise
          programming_error(6)
      endcase
      UnMarkBlock()
      line_from = line_from + line_block_size
      line_to   = iif (line_from + line_block_size - 1 > NumLines(),
                       NumLines(),
                       line_from + line_block_size - 1)
    until line_from > NumLines()

    msg('')

    #if DEBUG_LOG
      t3 = GetTime()
    #endif

    // Part 3/3: Convert ANSI characters to UTF characters.

    ansi_to_utf1632(bomless_character_encoding, character_encoding)

    #if DEBUG_LOG
      t4 = GetTime()
    #endif

  endif

  if  ok
  and Pos('BOM', character_encoding)
    BegFile()
    if CurrLineLen() > MAXLINELEN_MINUS_4
      InsertLine()
    endif
    case bomless_character_encoding
      when UTF16LE
        InsertText(BOM_UTF16_LE)
      when UTF16BE
        InsertText(BOM_UTF16_BE)
      when UTF32LE
        InsertText(BOM_UTF32_LE)
      when UTF32BE
        InsertText(BOM_UTF32_BE)
      otherwise
        programming_error(4)
    endcase
  endif

  if not ok
    // The conversion failed, either by a specifically tested for problem
    // or because TSE ran out of memory.
    // Divert the scheduled Save to the temp file that the scheduled
    // restore_current_buffer() knows about.
    UpdateDisplay(_ALL_WINDOWS_REFRESH_)
    beeper()
    Warn('ERROR: Could not convert this file.')
    SetHookState(FALSE)
    ChangeCurrFilename(tmp_fqn, CCF_OPTIONS)
    SetHookState(TRUE)
  endif

  #if DEBUG_LOG
    t5 = GetTime()
    ExecMacro('Log open D:\Zest\Log_Unicode3.txt')
    ExecMacro('Log write Saving ' + QuotePath(CurrFilename()))
    ExecMacro('Log write ANSI to ' + character_encoding + ' by ' + my_macro_name)
    ExecMacro('Log write Text lines to binary lines: ' + Str(t2 - t1))
    ExecMacro('Log write Each 1 byte to '
              + iif(character_encoding[1:6] == 'UTF-16', '2', '4')
              + ' bytes: ' + Str(t3 - t2))
    ExecMacro('Log write Characters to characters: ' + Str(t4 - t3))
    ExecMacro('Log write Total: '                    + Str(t5 - t0))
    ExecMacro('Log close')
  #endif

  PopBlock()
  Set(Insert, old_insert)
  UndoMode(old_undomode)
end normal_ansi_to_binary_utf1632

integer proc backup_current_buffer()
  g_org_converted   = TRUE
  g_org_filechanged = FileChanged()
  g_org_fqn         = CurrFilename()
  g_org_id          = GetBufferId()
  g_org_line        = CurrLine()
  g_org_pos         = CurrPos()
  g_org_row         = CurrRow()
  g_org_undomode    = UndoMode()
  g_org_xoffset     = CurrXoffset()
  SetUndoOff()
  // Backup buffer should be empty, but make sure to free up memory early.
  GotoBufferId(backup_id)
  if NumLines()
    g_org_converted = EmptyBuffer()
  endif
  GotoBufferId(g_org_id)
  if g_org_converted
    PushBlock()
    MarkLine(1, NumLines())
    GotoBufferId(backup_id)
    if CopyBlock() // Tested: 1/3 less memory than copy/paste.
      UnMarkBlock()
    else
      g_org_converted = FALSE
    endif
    GotoBufferId(g_org_id)
    PopBlock()
  endif
  if not g_org_converted
    UpdateDisplay(_ALL_WINDOWS_REFRESH_)
    beeper()
    if MsgBoxEx('Choose',
                'Could not save this file in Unicode format.' +
                Chr(13) + Chr(13) +
                'What to do instead?',
                '[Do &not save];[Save as &ANSI]') <= 1
      SetHookState(FALSE)
      ChangeCurrFilename(tmp_fqn, CCF_OPTIONS)
      SetHookState(TRUE)
    endif
  endif
  return(g_org_converted)
end backup_current_buffer

proc restore_current_buffer()
  integer after_save_filechanged = FileChanged()
  integer org_id                 = GetBufferId()
  integer restored = TRUE
  if org_id == g_org_id
    if CurrFilename() == tmp_fqn
      SetHookState(FALSE)
      ChangeCurrFilename(g_org_fqn, CCF_OPTIONS)
      SetHookState(TRUE)
      FileChanged(g_org_filechanged)
      UpdateDisplay(_ALL_WINDOWS_REFRESH_)
      Warn('This file is not saved.')
    endif
    if g_org_converted
      SetUndoOff()
      PushBlock()
      // Free up memory early
      if NumLines()
        restored = EmptyBuffer()
      endif
      if restored
        GotoBufferId(backup_id)
        MarkLine(1, NumLines())
        GotoBufferId(g_org_id)
        if MoveBlock()
          UnMarkBlock()
          GotoLine(g_org_line)
          GotoPos (g_org_pos )
          if CurrRow() > g_org_row
            ScrollDown(CurrRow() - g_org_row)
          elseif CurrRow() < g_org_row
            ScrollUp(g_org_row - CurrRow())
          endif
          GotoXoffset(g_org_xoffset)
          FileChanged(after_save_filechanged)
        else
          restored = FALSE
        endif
      endif
      PopBlock()
      if g_org_undomode
        SetUndoOn()
      endif
      if not restored
        UpdateDisplay(_ALL_WINDOWS_REFRESH_)
        Warn('ERROR: Conversion failed. Do not try to save this Unicode file again. It might be corrupt.')
      endif
    endif
  else
    programming_error(5)
  endif
end restore_current_buffer

proc on_file_save()
  string character_encoding [13] = GetBufferStr(varname_character_encoding)
  if is_normal_file()
    if SubStr(character_encoding, 1, 3) == 'UTF'
      if backup_current_buffer()
        SetBufferInt(varname_conversion_flag, TRUE)
        if SubStr(character_encoding, 1, 5) == 'UTF-8'
          ansi_to_utf8()
        elseif (SubStr(character_encoding, 1, 6) in 'UTF-16', 'UTF-32')
          normal_ansi_to_binary_utf1632()
        endif
      endif
    endif
  endif
end on_file_save

proc after_file_save()
  string character_encoding [13] = GetBufferStr(varname_character_encoding)
  if GetBufferInt(varname_conversion_flag)
    DelBufferVar(varname_conversion_flag)
    if (SubStr(character_encoding, 1, 6) in 'UTF-16', 'UTF-32')
      BinaryMode(0)
    endif
    restore_current_buffer()
  endif
end after_file_save

menu default_ascii_upgrade_menu()
  title   = 'When non-ASCII character, then upgrade to format:'
  history = menu_history_number
  x       = 10
  y       = 5
  '&1 - Ask each time'               ,,_MF_CLOSE_AFTER_|_MF_ENABLED_,'What should happen when you add a non-ASCII character to an ASCII file.'
  '&2 - Upgrade to ANSI'             ,,_MF_CLOSE_AFTER_|_MF_ENABLED_,'What should happen when you add a non-ASCII character to an ASCII file.'
  '&3 - Upgrade to UTF-8'            ,,_MF_CLOSE_AFTER_|_MF_ENABLED_,'What should happen when you add a non-ASCII character to an ASCII file.'
  '&4 - Upgrade to UTF-8 with BOM'   ,,_MF_CLOSE_AFTER_|_MF_ENABLED_,'What should happen when you add a non-ASCII character to an ASCII file.'
  '&5 - Upgrade to UTF-16BE'         ,,_MF_CLOSE_AFTER_|_MF_ENABLED_,'What should happen when you add a non-ASCII character to an ASCII file.'
  '&6 - Upgrade to UTF-16BE with BOM',,_MF_CLOSE_AFTER_|_MF_ENABLED_,'What should happen when you add a non-ASCII character to an ASCII file.'
  '&7 - Upgrade to UTF-16LE'         ,,_MF_CLOSE_AFTER_|_MF_ENABLED_,'What should happen when you add a non-ASCII character to an ASCII file.'
  '&8 - Upgrade to UTF-16LE with BOM',,_MF_CLOSE_AFTER_|_MF_ENABLED_,'What should happen when you add a non-ASCII character to an ASCII file.'
  '&9 - Upgrade to UTF-32BE'         ,,_MF_CLOSE_AFTER_|_MF_ENABLED_,'What should happen when you add a non-ASCII character to an ASCII file.'
  '&A - Upgrade to UTF-32BE with BOM',,_MF_CLOSE_AFTER_|_MF_ENABLED_,'What should happen when you add a non-ASCII character to an ASCII file.'
  '&B - Upgrade to UTF-32LE'         ,,_MF_CLOSE_AFTER_|_MF_ENABLED_,'What should happen when you add a non-ASCII character to an ASCII file.'
  '&C - Upgrade to UTF-32LE with BOM',,_MF_CLOSE_AFTER_|_MF_ENABLED_,'What should happen when you add a non-ASCII character to an ASCII file.'
end default_ascii_upgrade_menu

menu default_ansi_upgrade_menu()
  title   = 'When non-ANSI character, then upgrade to format:'
  history = menu_history_number
  x       = 10
  y       = 5
  '&1 - Ask each time'               ,,_MF_CLOSE_AFTER_|_MF_ENABLED_,'What should happen when you add a non-ANSI character to an ANSI file.'
  '&2 - Upgrade to ANSI'             ,,_MF_SKIP_|_MF_GRAYED_        ,'What should happen when you add a non-ANSI character to an ANSI file.'
  '&3 - Upgrade to UTF-8'            ,,_MF_CLOSE_AFTER_|_MF_ENABLED_,'What should happen when you add a non-ANSI character to an ANSI file.'
  '&4 - Upgrade to UTF-8 with BOM'   ,,_MF_CLOSE_AFTER_|_MF_ENABLED_,'What should happen when you add a non-ANSI character to an ANSI file.'
  '&5 - Upgrade to UTF-16BE'         ,,_MF_CLOSE_AFTER_|_MF_ENABLED_,'What should happen when you add a non-ANSI character to an ANSI file.'
  '&6 - Upgrade to UTF-16BE with BOM',,_MF_CLOSE_AFTER_|_MF_ENABLED_,'What should happen when you add a non-ANSI character to an ANSI file.'
  '&7 - Upgrade to UTF-16LE'         ,,_MF_CLOSE_AFTER_|_MF_ENABLED_,'What should happen when you add a non-ANSI character to an ANSI file.'
  '&8 - Upgrade to UTF-16LE with BOM',,_MF_CLOSE_AFTER_|_MF_ENABLED_,'What should happen when you add a non-ANSI character to an ANSI file.'
  '&9 - Upgrade to UTF-32BE'         ,,_MF_CLOSE_AFTER_|_MF_ENABLED_,'What should happen when you add a non-ANSI character to an ANSI file.'
  '&A - Upgrade to UTF-32BE with BOM',,_MF_CLOSE_AFTER_|_MF_ENABLED_,'What should happen when you add a non-ANSI character to an ANSI file.'
  '&B - Upgrade to UTF-32LE'         ,,_MF_CLOSE_AFTER_|_MF_ENABLED_,'What should happen when you add a non-ANSI character to an ANSI file.'
  '&C - Upgrade to UTF-32LE with BOM',,_MF_CLOSE_AFTER_|_MF_ENABLED_,'What should happen when you add a non-ANSI character to an ANSI file.'
end default_ansi_upgrade_menu


integer proc character_encoding_flag(string menu_character_encoding)
  integer found_a_quoted_codepoint = FALSE
  integer result                   = FALSE
  string  search_options       [2] = 'gx'
  // string current_character_code_format [13] = GetBufferStr(varname_character_encoding)
  //
  // Note: Quoted Unicode codepoints cannot be converted to ASCII and ANSI
  //       with the exception of a delete-quoted 7F string.
  if (menu_character_encoding in 'UTF-8',
                                 'UTF-8+BOM',
                                 'UTF-16BE',
                                 'UTF-16BE+BOM',
                                 'UTF-16LE',
                                 'UTF-16LE+BOM',
                                 'UTF-32BE',
                                 'UTF-32BE+BOM',
                                 'UTF-32LE',
                                 'UTF-32LE+BOM')
    result = _MF_CLOSE_AFTER_|_MF_ENABLED_
  endif
  if  not result
  and menu_character_encoding == 'ASCII'
    PushLocation()
    if lFind(FIND_NON_ASCII, 'gx')
      PopLocation()
      result = _MF_SKIP_|_MF_GRAYED_
    else
      KillLocation()
    endif
  endif
  if  not result
  and (menu_character_encoding in 'ASCII', 'ANSI')
    PushLocation()
    while not found_a_quoted_codepoint
    and   lFind(FIND_ANSI_CODEPOINT, search_options)
      if GetFoundText() <> QUOTED_DELETE_CODEPOINT
        found_a_quoted_codepoint = TRUE
      endif
      search_options = 'x+'
    endwhile
    if found_a_quoted_codepoint
      result = _MF_SKIP_|_MF_GRAYED_
    else
      result = _MF_CLOSE_AFTER_|_MF_ENABLED_
      lReplace(QUOTED_DELETE_CODEPOINT, Chr(127), 'gn')
    endif
    PopLocation()
  endif
  if not result
    result = _MF_SKIP_|_MF_GRAYED_
  endif
  return(result)
end character_encoding_flag

menu character_code_format_menu()
  title   = 'Select a new character encoding'
  history = menu_history_number
  x       = 10
  y       = 5
  '&1 - ASCII'            ,,character_encoding_flag('ASCII'       ),'Current file will use ASCII character codes.'
  '&2 - ANSI'             ,,character_encoding_flag('ANSI'        ),'Current file will use ANSI character codes.'
  '&3 - UTF-8'            ,,character_encoding_flag('UTF-8'       ),'Current file will use UTF-8 character codes.'
  '&4 - UTF-8 with BOM'   ,,character_encoding_flag('UTF-8+BOM'   ),'Current file will use UTF-8 character codes and a Byte Order Mark.'
  '&5 - UTF-16BE'         ,,character_encoding_flag('UTF-16BE'    ),'Current file will use UTF-16 Big Endian character codes.'
  '&6 - UTF-16BE with BOM',,character_encoding_flag('UTF-16BE+BOM'),'Current file will use UTF-16 Big Endian character codes and a Byte Order Mark.'
  '&7 - UTF-16LE'         ,,character_encoding_flag('UTF-16LE'    ),'Current file will use UTF-16 Little Endian character codes.'
  '&8 - UTF-16LE with BOM',,character_encoding_flag('UTF-16LE+BOM'),'Current file will use UTF-16 Little Endian character codes and a Byte Order Mark.'
  '&9 - UTF-32BE'         ,,character_encoding_flag('UTF-32BE'    ),'Current file will use UTF-32 Big Endian character codes.'
  '&A - UTF-32BE with BOM',,character_encoding_flag('UTF-32BE+BOM'),'Current file will use UTF-32 Big Endian character codes and a Byte Order Mark.'
  '&B - UTF-32LE'         ,,character_encoding_flag('UTF-32LE'    ),'Current file will use UTF-32 Little Endian character codes.'
  '&C - UTF-32LE with BOM',,character_encoding_flag('UTF-32LE+BOM'),'Current file will use UTF-32 Little Endian character codes and a Byte Order Mark.'
end character_code_format_menu

string proc menu_option_2_char_code_format(integer menu_option)
  string result [13] = ''
  if menu_option in 1 .. 12
    result = Trim(SubStr(character_code_formats,
                         2 + (menu_option - 1) * 13,
                         12))
  endif
  return(result)
end menu_option_2_char_code_format

integer proc char_code_format_2_menu_option(string character_encoding)
  return(1 + Pos(' ' + character_encoding + ' ', character_code_formats) / 13)
end char_code_format_2_menu_option

proc load_unicodedata()
  integer old_msglevel                   = 0
  string  unicodedata_fqn [MAXSTRINGLEN] = ''
  GotoBufferId(unicodedata_id)
  if not NumLines()
    old_msglevel    = Set(MsgLevel, _WARNINGS_ONLY_)
    unicodedata_fqn = SplitPath(CurrMacroFilename(), _DRIVE_|_PATH_) + 'UnicodeData.txt'
    if not LoadBuffer(unicodedata_fqn)
      Warn('ERROR: File missing: ', unicodedata_fqn, Chr(13),
           'No Unicode character descriptions will be shown. ')
      InsertText('No UnicodeData.txt file available.')
    endif
    Set(MsgLevel, old_msglevel)
  endif
  BegFile()
end load_unicodedata

proc load_nameslist()
  string  nameslist_fqn [MAXSTRINGLEN] = ''
  integer old_msglevel                 = 0
  GotoBufferId(nameslist_id)
  if not NumLines()
    old_msglevel  = Set(MsgLevel, _WARNINGS_ONLY_)
    nameslist_fqn = SplitPath(CurrMacroFilename(), _DRIVE_|_PATH_) + 'NamesList.txt'
    if not LoadBuffer(nameslist_fqn)
      Warn('ERROR: File missing: ', nameslist_fqn, Chr(13),
           'Unicode character descriptions will be incomplete or absent.')
      InsertText('No NamesList.txt file available.')
    endif
    Set(MsgLevel, old_msglevel)
  endif
  BegFile()
end load_nameslist

proc show_char_description(string character_encoding)
  string  char_description [MAXSTRINGLEN] = ''
  integer char_pos_from                   = 0
  integer char_pos_to                     = 0
  integer codepoint                       = 0
  string  curr_char [9]                   = GetText(CurrPos(), 1)
  integer curr_pos                        = 0
  integer org_id                          = 0
  string  search_string    [MAXSTRINGLEN] = ''
  integer show                            = FALSE
  if  curr_char                           <> Chr(127)
  and SubStr(character_encoding, 1, 3) == 'UTF'
    curr_pos = CurrPos()
    if lFind('\d127', 'bcx')
      char_pos_from = CurrPos()
      if lFind('\d127', 'cx+')
        char_pos_to = CurrPos()
        if  curr_pos >= char_pos_from
        and curr_pos <= char_pos_to
          curr_char = GetText(char_pos_from + 1, char_pos_to - char_pos_from - 1)
        endif
      endif
      GotoPos(curr_pos)
    endif
  endif
  if  Length(curr_char)
  and cfg_char_descriptions <> 'None'
    if cfg_char_descriptions == 'All'
      show = TRUE
    elseif cfg_char_descriptions in 'Unprintables'
      if Length(curr_char) == 1
        if Asc(curr_char) in 0..32, 127, 129, 141, 143, 144, 157, 160
          show = TRUE
        endif
      else
        show = TRUE
      endif
    endif
  endif
  if show
    if Length(curr_char) == 1
      if Asc(curr_char) in 128 .. 159
        codepoint = Val(SubStr(ansi_codepoints,
                        Pos(' ' + Str(Asc(curr_char)) + ' ',
                            ansi_codes                     ) + 1,
                        4))
        if codepoint
          search_string = Format(codepoint:4:'0':16)
        else
          search_string = Format(Asc(curr_char):4:'0':16)
        endif
      else
        search_string = Format(Asc(curr_char):4:'0':16)
      endif
    elseif Length(curr_char) < 4
      search_string = Format(curr_char:4:'0')
    else
      search_string = curr_char
    endif
    search_string = search_string + ';'
    org_id = GetBufferId()
    load_unicodedata()
    if lFind(search_string, '^gi')
      char_description = GetToken(GetText(1, MAXSTRINGLEN), ';', 11)
      if char_description == ''
        char_description = GetToken(GetText(1, MAXSTRINGLEN), ';', 2)
      endif
      if char_description == '<control>'
        char_description = 'CHR ' + Str(Asc(curr_char))
      endif
      exec_macro(status_macro_name + ' ' + my_macro_name +
                 ':CharacterDescription,callback ' + char_description)
    endif
    GotoBufferId(org_id)
  else
    exec_macro(status_macro_name + ' ' + my_macro_name +
               ':CharacterDescription')
  endif
end show_char_description

proc idle()
  string  character_encoding [13] = ''
#ifndef LINUX
  string  ansi_char           [9] = ''
  integer codepoint               = 0
#endif
  if status_refresh_timer > 0
    if  GetBufferId() == current_id
    and CurrLine()    == current_line
    and CurrCol()     == current_column
    and CurrChar()    == current_char
      status_refresh_timer = status_refresh_timer - 1
    else
      current_id           = GetBufferId()
      current_line         = CurrLine()
      current_column       = CurrCol()
      current_char         = CurrChar()
      status_refresh_timer = 1  // ASAP update because there was an action.
    endif
  else
    status_refresh_timer = status_refresh_period
    if is_normal_file()
      character_encoding = GetBufferStr(varname_character_encoding)
      if character_encoding == '' // Possibly a newly created unsaved file.
        if NumLines()
          character_encoding = get_character_code_format()
        endif
      endif
      if character_encoding == 'ASCII'
        PushPosition()
        if lFind('{' + FIND_NON_ASCII + '}|{' + FIND_ANSI_CODEPOINT + '}', 'gx')
          PopPosition()
          if cfg_ascii_upgrade_action == 'Ask'
            Message('You added a non-ASCII character to the current ASCII file.')
            beeper()
            menu_history_number = 2
            character_code_format_menu()
            if MenuOption()
              character_encoding = menu_option_2_char_code_format(MenuOption())
              SetBufferStr(varname_character_encoding, character_encoding)
            endif
          else
            character_encoding = cfg_ascii_upgrade_action
            SetBufferStr(varname_character_encoding, character_encoding)
            Message('Current file: ASCII -> ', character_encoding)
            beeper()
            Delay(36)
          endif
        else
          KillPosition()
        endif
      endif
      if character_encoding == 'ANSI'
        PushPosition()
        if lFind(FIND_ANSI_CODEPOINT, 'gx')
          PopPosition()
          if cfg_ansi_upgrade_action == 'Ask'
            Message('You added a non-ANSI character to the current ANSI file.')
            beeper()
            menu_history_number = 3
            character_code_format_menu()
            if MenuOption()
              character_encoding = menu_option_2_char_code_format(MenuOption())
              SetBufferStr(varname_character_encoding, character_encoding)
            endif
          else
            character_encoding = cfg_ansi_upgrade_action
            SetBufferStr(varname_character_encoding, character_encoding)
            Message('Current file: ANSI -> ', character_encoding)
            beeper()
            Delay(36)
          endif
        else
          KillPosition()
        endif
      endif
      #ifndef LINUX
        if cfg_char_previews                   == 'All'
        or SubStr(character_encoding, 1, 3) == 'UTF'
          if unicode_character_is_displayed
            display_unicode_character(32)
            unicode_character_is_displayed = FALSE
          endif
          ansi_char = get_text_char(THAT_THE_CURSOR_IS_ON_ANYWHERE)
          if cfg_char_previews == 'All'
          or Length(ansi_char) > 1
            ansi_to_codepoint(ansi_char, codepoint)
            display_unicode_character(codepoint)
            unicode_character_is_displayed = TRUE
          endif
        endif
      #endif
      if cfg_show_char_code_format
        if character_encoding <> ''
          exec_macro(status_macro_name + ' ' + my_macro_name
                     + ':CharacterCodeFormat,callback ' + character_encoding)
        endif
      endif
      if cfg_char_descriptions <> 'None'
        show_char_description(character_encoding)
      endif
    endif
  endif
end idle

proc show_help()
  string  full_macro_source_name [MAXSTRINGLEN] = SplitPath(CurrMacroFilename(), _DRIVE_|_PATH_|_NAME_) + '.s'
  string  help_file_name         [MAXSTRINGLEN] = '*** ' + my_macro_name + ' Help ***'
  integer hlp_id                                = GetBufferId(help_file_name)
  integer org_id                                = GetBufferId()
  integer tmp_id                                = 0
  if hlp_id
    GotoBufferId(hlp_id)
    UpdateDisplay()
  else
    tmp_id = CreateTempBuffer()
    if LoadBuffer(full_macro_source_name)
      // Separate characters, otherwise my SynCase macro gets confused.
      if lFind('/' + '*', 'g')
        PushBlock()
        UnMarkBlock()
        Right(2)
        MarkChar()
        if not lFind('*' + '/', '')
          EndFile()
        endif
        MarkChar()
        Copy()
        CreateTempBuffer()
        Paste()
        UnMarkBlock()
        PopBlock()
        BegFile()
        ChangeCurrFilename(help_file_name, CCF_OPTIONS)
        BufferType(_NORMAL_)
        FileChanged(FALSE)
        BrowseMode(TRUE)
        UpdateDisplay()
      else
        GotoBufferId(org_id)
        Warn('File "', full_macro_source_name, '" has no multi-line comment block.')
      endif
    else
      GotoBufferId(org_id)
      Warn('File "', full_macro_source_name, '" not found.')
    endif
    AbandonFile(tmp_id)
  endif
end show_help

proc select_new_char_code_format()
  string new_character_code_format [13] = ''
  string old_character_code_format [13] = GetBufferStr(varname_character_encoding)
  menu_history_number = char_code_format_2_menu_option(old_character_code_format)
  character_code_format_menu()
  if MenuOption()
    new_character_code_format = menu_option_2_char_code_format(MenuOption())
    SetBufferStr(varname_character_encoding, new_character_code_format)
    exec_macro(status_macro_name + ' ' + my_macro_name +
               ':CharacterCodeFormat,callback ' + new_character_code_format)
    if new_character_code_format <> old_character_code_format
      FileChanged(TRUE)
    endif
  endif
end select_new_char_code_format

proc stop_processing_my_key()
  PushKey(-1)
  GetKey()
end stop_processing_my_key

#ifndef LINUX

  proc display_elist_unicode_character()
    if lFind('^[0-9A-Fa-f]#', 'cgx')
      display_unicode_character(Val(GetFoundText(), 16))
    endif
  end  display_elist_unicode_character

#endif

proc insert_character()
  string  ansi_char                             [15] = ''
  string  description_token           [MAXSTRINGLEN] = ''
  integer i                                          = 0
  string  nameslist_description       [MAXSTRINGLEN] = ''
  integer org_id                                     = GetBufferId()
  string  selected_codepoint                     [7] = ''
  string  selection_description       [MAXSTRINGLEN] = ''
  string  separator                              [3] = ''
  string  unicodedata_1st_description [MAXSTRINGLEN] = ''
  string  unicodedata_2nd_description [MAXSTRINGLEN] = ''
  string  unicodedata_codepoint                  [7] = ''
  string  unicodedata_line            [MAXSTRINGLEN] = ''
  GotoBufferId(selection_list_id)
  if not NumLines()
    load_unicodedata()
    load_nameslist()
    PushBlock()
    GotoBufferId(unicodedata_id)
    repeat
      if lFind('^[0-9A-F][0-9A-F][0-9A-F][0-9A-F]#;', 'cgx')
        separator                   = '  '
        unicodedata_line            = GetText(1, MAXSTRINGLEN)
        unicodedata_codepoint       = GetToken(unicodedata_line, ';',  1)
        unicodedata_1st_description = GetToken(unicodedata_line, ';',  2)
        unicodedata_2nd_description = GetToken(unicodedata_line, ';', 11)
        selection_description       = unicodedata_codepoint + separator +
                                      unicodedata_1st_description
        if unicodedata_2nd_description <> ''
          selection_description = selection_description + ';'
          for i = 1 to NumTokens(unicodedata_2nd_description, ' ')
            description_token = GetToken(unicodedata_2nd_description, ' ', i)
            if not Pos(description_token, unicodedata_1st_description)
              selection_description = selection_description + ' ' +
                                      description_token
            endif
          endfor
        endif
        GotoBufferId(nameslist_id)
        if lFind('^' + unicodedata_codepoint + '[ \d009]', 'x')
          while Down()
          and   not lFind('^[0-9A-F][0-9A-F][0-9A-F][0-9A-F]#[ \d009]', 'cgx')
            if lFind('^[ \d009]#=[ \d009]#', 'cgx')
              nameslist_description = GetText(Length(GetFoundText()) + 1,
                                              MAXSTRINGLEN)
              if not Pos(nameslist_description, selection_description)
                selection_description = selection_description + separator +
                                        '(' + nameslist_description + ')'
                separator = ' '
              endif
            endif
          endwhile
          Up()
        endif
        AddLine(selection_description, selection_list_id)
        GotoBufferId(unicodedata_id)
      endif
    until not Down()
    PopBlock()
  endif
  GotoBufferId(selection_list_id)
  #ifndef LINUX
    Hook(_AFTER_NONEDIT_COMMAND_, display_elist_unicode_character)
  #endif
  if elist('Select a Unicode character')
    selected_codepoint = GetToken(GetText(1, 7), ' ', 1)
  endif
  #ifndef LINUX
    UnHook(display_elist_unicode_character)
  #endif
  // When called back from the status and selecting a character by left-clicking
  // near the top left corner but not where the TSE menu would, then still the
  // TSE menu is opened as if the mousclick is echoed on the TSE menu.
  // The following procedure prevents that somehow.
  stop_processing_my_key()
  GotoBufferId(org_id)
  UpdateDisplay()
  if selected_codepoint <> ''
    codepoint_to_ansi(Val(selected_codepoint, 16), ansi_char)
    InsertText(ansi_char, _INSERT_)
  endif
end insert_character



#ifndef LINUX

proc copy_or_cut_to_win_clip(integer copy_selected)
  integer clp_id         = 0
  integer old_EOFType    = 0
  integer old_MsgLevel   = Set(MsgLevel, _WARNINGS_ONLY_)
  integer result         = 0
  // Initially just copy or cut it as ANSI.
  if copy_selected
    PushBlock() // Circumvent CopyToWinClip()'s block unmarking.
    result = CopyToWinClip()
  else
    result = CutToWinClip()
  endif
  if result
    PushLocation()
    clp_id = CreateBuffer(clp_fqn, _NORMAL_)
    if clp_id
      SetBufferStr(varname_character_encoding, 'UTF-16LE')
      if PasteFromWinClip()
        EraseDiskFile(clp_fqn) // Avoid overwrite question.
        old_EOFType = Set(EOFType , 0)
        if SaveFile() // Saving as normal file triggers conversion to UTF-16LE.
          Set(EOFType, old_EOFType )
          BufferType(_SYSTEM_)
          LoadBuffer(clp_fqn, BINARYMODE_LINE_LENGTH)
          copy_unicode_to_winclip(old_MsgLevel)
          EraseDiskFile(clp_fqn)
        else
          Set(EOFType, old_EOFType )
          programming_error(10)
        endif
      else
        programming_error(9)
      endif
    else
      programming_error(8)
    endif
    PopLocation()
    AbandonFile(clp_id)
  endif
  if copy_selected
    // This PopBlock() restores the marked block, but if the block was marked
    // with CUAmark, then after this proc CUAmark will unmark it again.   :-(
    PopBlock()
  endif
  Set(MsgLevel, old_MsgLevel)
end copy_or_cut_to_win_clip

proc paste_replace_from_win_clip()
  integer old_ClipBoardId        = Query(ClipBoardId)
  integer tse_clp_alt_id         = 0
  integer clp_id                 = 0
  integer old_MsgLevel           = Set(MsgLevel, _WARNINGS_ONLY_)
  integer old_EOFType            = Set(EOFType, 0)
  PushLocation()
  clp_id = CreateTempBuffer()
  BinaryMode(BINARYMODE_LINE_LENGTH)
  if paste_unicode_from_winclip(old_MsgLevel)
    if SaveAs(clp_fqn, _DONT_PROMPT_|_OVERWRITE_)
      PopLocation()
      AbandonFile(clp_id)
      PushLocation()
      // Opening a file in a normal buffer triggers converting it to ANSI.
      #if EDITOR_VERSION >= 4200h
        clp_id = EditThisFile(clp_fqn       , _DONT_PROMPT_)
      #else
        clp_id = EditFile(QuotePath(clp_fqn), _DONT_PROMPT_)
      #endif
      if clp_id
        // Preserve the user's TSE clipboard contents by temporarily making TSE
        // use an alternate TSE clipboard buffer.
        PushLocation()
        tse_clp_alt_id = CreateTempBuffer()
        PopLocation()
        Set(ClipBoardId, tse_clp_alt_id)

        PushBlock()
        BegFile()
        MarkBlockBegin()
        EndFile()
        MarkBlockEnd()
        Copy()
        PopLocation()
        PopBlock()
        if isCursorInBlock()
          KillBlock()
        endif
        Paste()

        // Restore the default TSE clipboard with the user's content.
        Set(ClipBoardId, old_ClipBoardId)
        AbandonFile(tse_clp_alt_id)
      else
        PopLocation()
        programming_error(12)
      endif
      EraseDiskFile(clp_fqn)
    else
      PopLocation()
      programming_error(11)
    endif
  else
    PopLocation()
    if old_MsgLevel
      Warn('Nothing to paste.')
    endif
  endif
  AbandonFile(clp_id)
  Set(EOFType , old_EOFType )
  Set(MsgLevel, old_MsgLevel)
end paste_replace_from_win_clip

#endif



#ifndef LINUX

  proc repaint_screen()
    // This is crude but UpdateDisplay(_ALL_WINDOWS_REFRESH_) does not work here.
    PushKey(<Escape>)
    Help()
  end repaint_screen

  proc position_the_unicode_location()
    integer user_key          = 0
    integer new_cfg_unicode_x = cfg_unicode_x
    integer new_cfg_unicode_y = cfg_unicode_y
    integer old_cfg_unicode_x = cfg_unicode_x
    integer old_cfg_unicode_y = cfg_unicode_y
    Warn('You can now configure where the Unicode character will be shown ...'
         + Chr(13)  + Chr(13) +
         'You can later repeat this by selecting the same configuration option again.'
         + Chr(13)  + Chr(13) +
         'Known display errors! Showing a Unicode character works imperfectly.'
        )
    Delay(9)
    Message('  Use Home and Arrows to position X; Enter=save, Escape=quit, AnyKey=repaint')
    repeat
      display_unicode_character(88)
      user_key = GetKey()
      case user_key
        when <Escape>
          new_cfg_unicode_x = old_cfg_unicode_x
          new_cfg_unicode_y = old_cfg_unicode_y
        when <Enter>, <GreyEnter>
          write_profile_str(varname_cfg_section, 'CharPreviewX', Str(cfg_unicode_x))
          write_profile_str(varname_cfg_section, 'CharPreviewY', Str(cfg_unicode_y))
        when <Home>, <GreyHome>
          new_cfg_unicode_x = 3
          new_cfg_unicode_y = 3
        when <CursorUp>, <GreyCursorUp>
          display_unicode_character(32)
          new_cfg_unicode_y = iif(new_cfg_unicode_y, new_cfg_unicode_y - 1, new_cfg_unicode_y)
        when <CursorDown>, <GreyCursorDown>
          display_unicode_character(32)
          new_cfg_unicode_y = new_cfg_unicode_y + 1
        when <CursorLeft>, <GreyCursorLeft>
          display_unicode_character(32)
          new_cfg_unicode_x = iif(new_cfg_unicode_x, new_cfg_unicode_x - 1, new_cfg_unicode_x)
        when <CursorRight>, <GreyCursorRight>
          display_unicode_character(32)
          new_cfg_unicode_x = new_cfg_unicode_x + 1
        otherwise
          repaint_screen()
      endcase
      cfg_unicode_x = new_cfg_unicode_x
      cfg_unicode_y = new_cfg_unicode_y
      display_unicode_character(88)
    until user_key in <Escape>, <Enter>, <GreyEnter>
    Message('')
    repaint_screen()
    Delay(9)
    Message('You are back in the main menu.')
    Delay(9)
  end position_the_unicode_location

#endif

string proc profile_get(string item)
  string new_value [13] = ''
  string old_value [13] = GetProfileStr(varname_cfg_section, item, 'Default', ".\unicode.ini" )
  case item
    when 'AnsiUpgradeAction'
      new_value = iif((old_value in 'Ask', 'UTF-8', 'UTF-8+BOM',
                                    'UTF-16BE', 'UTF-16BE+BOM',
                                    'UTF-16LE', 'UTF-16LE+BOM',
                                    'UTF-32BE', 'UTF-32BE+BOM',
                                    'UTF-32LE', 'UTF-32LE+BOM'),
                       old_value,
                       'Ask')
    when 'AsciiUpgradeAction'
      new_value = iif((old_value in 'Ask', 'ANSI', 'UTF-8', 'UTF-8+BOM',
                                    'UTF-16BE', 'UTF-16BE+BOM',
                                    'UTF-16LE', 'UTF-16LE+BOM',
                                    'UTF-32BE', 'UTF-32BE+BOM',
                                    'UTF-32LE', 'UTF-32LE+BOM'),
                       old_value,
                       'Ask')
    when 'CharPreviewX'
      new_value = iif((old_value <> ''),
                       old_value,
                       '3')
    when 'CharPreviewY'
      new_value = iif((old_value <> ''),
                       old_value,
                       '3')
    when 'CheckBomCorrectness'
      new_value = iif((old_value in 'Enabled', 'Disabled'),
                       old_value,
                       'Disabled')
    when 'ConvertUnicodeFiles'
      new_value = iif((old_value in 'Enabled', 'Disabled'),
                       old_value,
                       'Enabled')
    when 'MaxBytesToCheck'
      new_value = iif(isDigit(old_value), old_value, '4000')
      if        Val(new_value) < 255
      or     Length(new_value) >  10
      or (   Length(new_value) == 10
         and new_value > Str(MAXINT - 1000))
        new_value = '4000'
      endif
    when 'ShowCharCodeFormat'
      new_value = iif((old_value in 'Enabled', 'Disabled'),
                       old_value,
                       'Enabled')
    when 'WhichCharDescriptions'
      new_value = iif((old_value in 'All', 'Unprintables', 'None'),
                       old_value,
                       'All')
    when 'WhichCharPreviews'
      new_value = iif((old_value in 'All', 'Non-ANSI', 'None'),
                       old_value,
                       'None')
    otherwise
      new_value = old_value   // E.g. for Version.
  endcase
  if old_value <> new_value
    write_profile_str(varname_cfg_section, item, new_value)
  endif
  return(new_value)
end profile_get

proc change_status_color()
  exec_macro(status_macro_name + ' ConfigureStatusColor')
end change_status_color

proc browse_website()
  #ifdef LINUX
    // Reportedly this is the most cross-Linux compatible way.
    // It worked out of the box for me: No Linux configuration was necessary.
    // Of course it will only work for Linux installations with a GUI.
    Dos('python -m webbrowser "' + UPGRADE_URL + '"',
        _DONT_PROMPT_|_DONT_CLEAR_|_RUN_DETACHED_)
  #else
    StartPgm(UPGRADE_URL, '', '', _DEFAULT_)
  #endif
end browse_website

menu char_description_menu()
  title   = 'Show descriptions for which characters:'
  x       = 10
  y       = 5
  history = menu_history_number
  '&All'         ,,_MF_CLOSE_AFTER_|_MF_ENABLED_, 'Show Unicode descriptions for all characters.'
  '&Unprintables',,_MF_CLOSE_AFTER_|_MF_ENABLED_, 'Show Unicode descriptions for unprintable characters (incl. both space chars).'
  '&None'        ,,_MF_CLOSE_AFTER_|_MF_ENABLED_, 'Never show Unicode descriptions.'
end char_description_menu

#ifndef LINUX

  menu char_preview_menu()
    title   = 'Preview a Unicode character for which characters:'
    x       = 10
    y       = 5
    history = menu_history_number
    '&All'     ,,_MF_CLOSE_AFTER_|_MF_ENABLED_, 'Preview a Unicode character for all characters.'
    'Non-ANS&I',,_MF_CLOSE_AFTER_|_MF_ENABLED_, 'Only preview a Unicode character for non-ANSI characters.'
    '&None'    ,,_MF_CLOSE_AFTER_|_MF_ENABLED_, 'Never preview a Unicode character.'
  end char_preview_menu

#endif

proc profile_set(string item)
  string new_value           [13] = ''
  string new_value_formatted [13] = ''
  string old_value           [13] = GetProfileStr(varname_cfg_section, item, 'NoValue', ".\unicode.ini" )
  case item
    when 'ConvertUnicodeFiles'
      new_value = iif(old_value == 'Enabled', 'Disabled', 'Enabled')
      cfg_convert_unicode_files = (new_value == 'Enabled')
    when 'ShowCharCodeFormat'
      new_value = iif(old_value == 'Enabled', 'Disabled', 'Enabled')
      cfg_show_char_code_format = (new_value == 'Enabled')
    when 'CheckBomCorrectness'
      new_value = iif(old_value == 'Disabled', 'Enabled', 'Disabled')
      cfg_check_bom_correctness = (new_value == 'Enabled')
    when 'WhichCharDescriptions'
      menu_history_number = Pos(cfg_char_descriptions,
                                cfg_values_char_descriptions) / 13 + 1
      char_description_menu()
      if MenuOption()
        new_value = Trim(SubStr(cfg_values_char_descriptions,
                                1 + (MenuOption() - 1) * 13, 12))
        cfg_char_descriptions = new_value
      endif
#ifndef LINUX
    when 'WhichCharPreviews'
      if (old_value in 'NoValue', 'None', '')
        Warn('WARNING:' + Chr(13) +
             'Previewing a Unicode character works badly!' + Chr(13) +
             'Set this option to NONE or live with the imperfections.')
      endif
      menu_history_number = Pos(cfg_char_previews,
                                cfg_values_char_displays) / 13 + 1
      char_preview_menu()
      if MenuOption()
        new_value = Trim(SubStr(cfg_values_char_displays,
                                1 + (MenuOption() - 1) * 13, 12))
        cfg_char_previews = new_value
        if (new_value in 'All', 'Non-ANSI')
          position_the_unicode_location()
        endif
      endif
#endif
    when 'AsciiUpgradeAction'
      menu_history_number = 1
      default_ascii_upgrade_menu()
      if MenuOption()
        new_value = menu_option_2_char_code_format(MenuOption())
        // Repair the slight misuse of menu_option_2_char_code_format():
        new_value = iif(new_value == 'ASCII', 'Ask', new_value)
        cfg_ascii_upgrade_action = new_value
      endif
    when 'AnsiUpgradeAction'
      menu_history_number = 1
      default_ansi_upgrade_menu()
      if MenuOption()
        new_value = menu_option_2_char_code_format(MenuOption())
        // Repair the slight misuse of menu_option_2_char_code_format():
        new_value = iif(new_value == 'ASCII', 'Ask', new_value)
        cfg_ansi_upgrade_action = new_value
      endif
    when 'MaxBytesToCheck'
      new_value = GetProfileStr(varname_cfg_section, 'MaxBytesToCheck', Str(MAXINT - 1000), ".\unicode.ini" )
      new_value_formatted = format_integer(new_value)
      if Ask('Max bytes to check to determine character encoding [255 - '
             + format_integer(Str(MAXINT - 1000)) + ']:',
             new_value_formatted)
      endif
      new_value = unformat_integer(new_value_formatted)
      if Val(new_value) < 255
        beeper()
        Warn('"Max bytes to check" has been set to its lowest allowed value.')
        new_value = '255'
      elseif Val(new_value) > MAXINT - 1000
        beeper()
        Warn('"Max bytes to check" has been set to its highest allowed value.')
        new_value = Str(MAXINT - 1000)
      endif
      cfg_max_bytes_to_check = Val(new_value)
  endcase
  if not (new_value in old_value, '')
    write_profile_str(varname_cfg_section, item, new_value)
  endif
  // config_the_autoload() // new [kn, ri, su, 11-12-2022 15:35:50]
end profile_set

integer proc get_windows_or_linux_menu_flag()
  // return(_MF_GRAYED_|_MF_SKIP_)
  return(_MF_CLOSE_ALL_BEFORE_|_MF_ENABLED_)
end get_windows_or_linux_menu_flag

menu main_menu()
  title       = 'Unicode'
  x           = 5
  y           = 5
  history     = menu_history_number

  '&Escape', NoOp(),, 'Exit this menu'
  '&Help ...'  , show_help(),, 'Read the documentation'
  '&Status color ...'  , change_status_color(),,
    'Change the status text color ...'
  '&Version ...' [profile_get('Version'):13], browse_website(),
    get_windows_or_linux_menu_flag(),
    'Check the website for a newer version ...'
  'Actions',, _MF_DIVIDE_
  '&Insert a Unicode character ...',
    insert_character(),,
    'Select a Unicode character by typing part of its codepoint, name or description'
  "Chan&ge current file's character encoding"
    [GetBufferStr(varname_character_encoding):13],
    select_new_char_code_format(),,
    "Change the current file's charcter encoding."
#ifndef LINUX
  'Copy  to   Windows clipboard   <&c>',
    copy_or_cut_to_win_clip(TRUE),
    iif(isBlockInCurrFile(),
        _MF_ENABLED_|_MF_CLOSE_ALL_BEFORE_,
        _MF_GRAYED_|_MF_SKIP_),
    'Copy marked text to the Windows clipboard as UTF-8.'
  'Cut   to   Windows clipboard   <&x>',
    copy_or_cut_to_win_clip(FALSE),
    iif(isBlockInCurrFile(),
        _MF_ENABLED_|_MF_CLOSE_ALL_BEFORE_,
        _MF_GRAYED_|_MF_SKIP_),
    'Cut marked text to the Windows clipboard as UTF-8.'
  'Paste from Windows clipboard   <&v>',
    paste_replace_from_win_clip(),
    iif(IsClipboardFormatAvailable(CF_UNICODETEXT),
        _MF_ENABLED_|_MF_CLOSE_ALL_BEFORE_,
        _MF_GRAYED_|_MF_SKIP_),
    'Paste any character encoding from the Windows clipboard as ANSI into the text.'
#endif
  'Configuration',, _MF_DIVIDE_
  'Convert Unicode files' [profile_get('ConvertUnicodeFiles'):13],
    profile_set('ConvertUnicodeFiles'), _MF_DONT_CLOSE_|_MF_ENABLED_,
    "Temporarily converting Unicode files to ANSI makes them editable in TSE."
  "Show a file's character encoding" [profile_get('ShowCharCodeFormat'):13],
    profile_set('ShowCharCodeFormat'), _MF_DONT_CLOSE_|_MF_ENABLED_,
    "Show the current file's character encoding as a status."
  'Show character descriptions for' [profile_get('WhichCharDescriptions'):13],
    profile_set('WhichCharDescriptions'), _MF_DONT_CLOSE_|_MF_ENABLED_,
    "Show the current character's Unicode description as a status."
#ifndef LINUX
  'Preview a Unicode character for' [profile_get('WhichCharPreviews'):13],
    profile_set('WhichCharPreviews'), _MF_DONT_CLOSE_|_MF_ENABLED_,
    'Preview which current characters at the configured screen location.'
#endif
  'Default ASCII upgrade action' [profile_get('AsciiUpgradeAction'):13],
    profile_set('AsciiUpgradeAction'), _MF_DONT_CLOSE_|_MF_ENABLED_,
    'New character format when you add a non-ASCII character to an ASCII file.'
  'Default ANSI upgrade action' [profile_get('AnsiUpgradeAction'):13],
    profile_set('AnsiUpgradeAction'), _MF_DONT_CLOSE_|_MF_ENABLED_,
    'New character format when you add a non-ANSI character to an ANSI file.'
  'Check BOM correctness' [profile_get('CheckBomCorrectness'):13],
    profile_set('CheckBomCorrectness'), _MF_DONT_CLOSE_|_MF_ENABLED_,
    "Slows loading when enabled: Check a file's byte order mark against its content."
  'Max bytes to check' [format_integer(profile_get('MaxBytesToCheck')):13],
    profile_set('MaxBytesToCheck'), _MF_DONT_CLOSE_|_MF_ENABLED_,
    "Choose load speed vs correctly recognizing the character encoding."
end main_menu

proc upgrade_old_configuration()
  string cfg_value [MAXSTRINGLEN] = ''
  if compare_versions(cfg_version, '1.6') == FIRST_OLDER_THAN_SECOND
    if GetProfileStr(varname_cfg_section, 'ShowUTFwarnings', '', ".\unicode.ini" ) <> ''
      RemoveProfileItem(varname_cfg_section, 'ShowUTFwarnings')
    endif
    cfg_value = GetProfileStr(varname_cfg_section, 'WhichCharDisplays', '', ".\unicode.ini" )
    if cfg_value <> ''
      write_profile_str(varname_cfg_section, 'WhichCharPreviews', cfg_value)
      RemoveProfileItem(varname_cfg_section, 'WhichCharDisplays')
    endif
    cfg_value = GetProfileStr(varname_cfg_section, 'CharDisplayX', '', ".\unicode.ini" )
    if cfg_value <> ''
      write_profile_str(varname_cfg_section, 'CharPreviewX', cfg_value)
      RemoveProfileItem(varname_cfg_section, 'CharDisplayX')
    endif
    cfg_value = GetProfileStr(varname_cfg_section, 'CharDisplayY', '', ".\unicode.ini" )
    if cfg_value <> ''
      write_profile_str(varname_cfg_section, 'CharPreviewY', cfg_value)
      RemoveProfileItem(varname_cfg_section, 'CharDisplayY')
    endif
    cfg_value = GetProfileStr(varname_cfg_section, 'MaxBytesToCheck', '', ".\unicode.ini" )
    write_profile_str(varname_cfg_section, 'MaxBytesToCheck', '4000')
    beeper()
    Warn("Unicode's configuration of ",
         '"Max bytes to check" can be set much lower than in previous ',
         'versions of this macro. It has been set to the new advised value: ',
         '4,000.')
    cfg_value = GetProfileStr(varname_cfg_section, 'AsciiUpgradeAction', '', ".\unicode.ini" )
    if cfg_value == 'Ask'
      write_profile_str(varname_cfg_section, 'AsciiUpgradeAction', 'ANSI')
      Warn('Unicode configuration change: When using a non-ASCII character ',
           'in an ASCII only file, the new default is to first make it an ANSI ',
           'file, and then check if that sufficed.')
    endif
    write_profile_str(varname_cfg_section, 'AnsiUpgradeAction', 'Ask')
    Warn('New Unicode configuration option: When using a non-ANSI character ',
         'in an ANSI file, the default is to ask for a new character code ',
         'format.')
  endif
  if compare_versions(cfg_version, '2.1') == FIRST_OLDER_THAN_SECOND
    cfg_value =  GetProfileStr(varname_cfg_section, 'ConvertUnicodeFiles', '', ".\unicode.ini" )
    if cfg_value == 'Default'
      write_profile_str(varname_cfg_section, 'ConvertUnicodeFiles', 'Disabled')
      Warn('Unicode configuration change: Whether or not to convert Unicode';
           'files was changed from "Default" to the less ambiguous';
           'but equivalent value "Disabled".')
    endif
    cfg_value = GetProfileStr(varname_cfg_section, 'ShowCharCodeFormat', '', ".\unicode.ini" )
    if cfg_value == 'Default'
      write_profile_str(varname_cfg_section, 'ShowCharCodeFormat', 'Disabled')
      Warn("Unicode configuration change: Whether or not to show a file's";
           'character encoding as a status was changed from "Default" to the';
           'less ambiguous but equivalent value "Disabled".')
    endif
  endif
end upgrade_old_configuration


proc WhenPurged()
  // Note:
  //   Theoretically this proc was vulnerable to the TSE GUI bug, that the
  //   _ON_ABANDON_EDITOR_ hook was not called if the editor's close button was
  //   used.
  //   The impact in this macro was, that after abort situations the tmp_fqn
  //   file might remain, but would be cleaned up by a next TSE session.
  //   Based on that low impact, and because Semware fixed the "GUI close
  //   button bug" in TSE 4.41.46 upwards, I am not going to implement the
  //   work-around for the bug in this macro.

  // ExecMacro('log close')

  // Steps necessary when the macro is purged and optional when the editor is
  // closed:
  AbandonFile(backup_id)
  AbandonFile(unicodedata_id)
  #ifndef LINUX
    ReleaseDC(window_handle, device_context_handle)
  #endif

  // Just to be sure always clean up all the temporary files.
  EraseDiskFile(clp_fqn)
  EraseDiskFile(cmd_fqn)
  EraseDiskFile(tmp_fqn)
end WhenPurged

proc WhenLoaded()
  integer org_id = GetBufferId()

  my_macro_name = SplitPath(CurrMacroFilename(), _NAME_)

  // ExecMacro('log open C:\users\carlo\log\tse\Unicode_' + Str(GetTime()) + '.txt')

  #ifdef LINUX
    if compare_versions(VersionStr(), '4.41.35') == FIRST_OLDER_THAN_SECOND
      Alarm()
      Warn('ERROR: In Linux the Unicode extension needs at least TSE v4.41.35.')
      PurgeMacro(my_macro_name)
      abort = TRUE
    endif
  #endif

  if not abort
    varname_cfg_section           = my_macro_name + ':Config'
    varname_character_encoding = my_macro_name + ':CharacterCodeFormat'
    varname_conversion_flag       = my_macro_name + ':ToBeConverted'
    varname_first_edited          = my_macro_name + ':FirstEdited'
    varname_loaded_eoltype        = my_macro_name + ':LoadedEolType'

    backup_id         = CreateTempBuffer()
    ChangeCurrFilename(my_macro_name + ':file_backup'  , CCF_OPTIONS)
    unicodedata_id    = CreateTempBuffer()
    ChangeCurrFilename(my_macro_name + ':UnicodeData'  , CCF_OPTIONS)
    nameslist_id      = CreateTempBuffer()
    ChangeCurrFilename(my_macro_name + ':NamesList'    , CCF_OPTIONS)
    selection_list_id = CreateTempBuffer()
    ChangeCurrFilename(my_macro_name + ':SelectionList', CCF_OPTIONS)
    GotoBufferId(org_id)

    tmp_fqn = GetEnvStr('TMP')
    if tmp_fqn == ''
    or not (FileExists(tmp_fqn) & _DIRECTORY_)
      tmp_fqn = GetEnvStr('TEMP')
      if tmp_fqn == ''
      or not (FileExists(tmp_fqn) & _DIRECTORY_)
        tmp_fqn = ''
      endif
    endif
    if  tmp_fqn == ''
    and not WIN32
    and (FileExists('/tmp') & _DIRECTORY_)
      tmp_fqn = '/tmp'
    endif
    if tmp_fqn == ''
      Alarm()
      Warn(my_macro_name, ' macro stops: No valid folder in TMP or TEMP environment variable.')
      PurgeMacro(my_macro_name)
      abort = TRUE
    else
      tmp_fqn = RemoveTrailingSlash(tmp_fqn)
      tmp_fqn = tmp_fqn + SLASH + 'Tse_' + my_macro_name + '_'
                + Str(get_process_id()) + '.tmp'
    endif

    clp_fqn = SplitPath(tmp_fqn, _DRIVE_|_PATH_|_NAME_) + '.clp'
    cmd_fqn = SplitPath(tmp_fqn, _DRIVE_|_PATH_|_NAME_) + '.cmd'

    cfg_version               =     profile_get('Version')
    if cfg_version <> MY_MACRO_VERSION
      if  cfg_version <> 'Default'
      and compare_versions(cfg_version, MY_MACRO_VERSION) <> FIRST_EQUAL_TO_SECOND
        upgrade_old_configuration()
      endif
      cfg_version             =     MY_MACRO_VERSION
      write_profile_str(varname_cfg_section, 'Version', MY_MACRO_VERSION)
    endif
    cfg_ascii_upgrade_action  =     profile_get('AsciiUpgradeAction'   )
    cfg_ansi_upgrade_action   =     profile_get('AnsiUpgradeAction'    )
    cfg_char_descriptions     =     profile_get('WhichCharDescriptions')
  #ifndef LINUX
    cfg_char_previews         =     profile_get('WhichCharPreviews'    )
    cfg_unicode_x             = Val(profile_get('CharPreviewX'         )             )
    cfg_unicode_y             = Val(profile_get('CharPreviewY'         )             )
  #endif
    cfg_check_bom_correctness =    (profile_get('CheckBomCorrectness'  ) == 'Enabled')
    cfg_convert_unicode_files =    (profile_get('ConvertUnicodeFiles'  ) == 'Enabled')
    cfg_max_bytes_to_check    = Val(profile_get('MaxBytesToCheck'      )             )
    cfg_show_char_code_format =    (profile_get('ShowCharCodeFormat'   ) == 'Enabled')
    cfg_version               =     profile_get('Version')

    // config_the_autoload() // new [kn, ri, su, 11-12-2022 15:35:59]

    if WhichOS() == _WINDOWS_
      Alarm()
      Warn(my_macro_name,
           ' macro stops: It does not support your operating system.')
      PurgeMacro(my_macro_name)
      abort = TRUE
    elseif WIN32
    and    not isGUI()
      if GetProfileStr(varname_cfg_section, 'GiveConsoleWarning', 'n', ".\unicode.ini" ) <> 'y'
        Alarm()
        PushKey(<CursorRight>)
        if MsgBox('Skip this warning the next time?',
                 my_macro_name +
                 ' macro stops: It does not support the Console version of TSE.',
                 _YES_NO_) == 1
          write_profile_str(varname_cfg_section, 'GiveConsoleWarning', 'y')
        endif
      endif
      PurgeMacro(my_macro_name)
      abort = TRUE
    elseif WIN32
    and    (    get_font('type') == 'OEM'
            or (get_font('name') in 'Courier',
                                    'Fixedsys',
                                    'System',
                                    'Terminal'))
      Alarm()
      Warn(my_macro_name, ' macro stops: Font "', get_font('name'),
           '" with type "', get_font('type'),
           '" is not ANSI compatible.')
      PurgeMacro(my_macro_name)
      abort = TRUE
    else
      Hook(_AFTER_FILE_SAVE_  , after_file_save)
      Hook(_IDLE_             , idle           )
      Hook(_ON_ABANDON_EDITOR_, WhenPurged     )
      Hook(_ON_FILE_LOAD_     , on_file_load   )
      Hook(_ON_FILE_SAVE_     , on_file_save   )
      Hook(_ON_FIRST_EDIT_    , on_first_edit  )
    endif
    #ifndef LINUX
      window_handle         = GetWinHandle()
      device_context_handle = GetDC(window_handle)
    #endif
  endif
end WhenLoaded

proc Main()
  string key_name [26] = ''
  if not abort
    // Is this a callback from the Status macro?
    case Lower(GetToken(Query(MacroCmdLine), ' ', 1))
      when 'callback'
        if Lower(GetToken(Query(MacroCmdLine), ' ', 2)) == 'status'
          // Yes, the user interacted while the cursor was on the status,
          // so now the status macro calls us back reporting the specific action.
          // Note that a KeyName may contain a space, so also get any 5th parameter.
          key_name = Trim(GetToken(Query(MacroCmdLine), ' ', 4) + ' ' +
                          GetToken(Query(MacroCmdLine), ' ', 5))
          case key_name
            when 'F1'
              stop_processing_my_key()
              show_help()
              stop_processing_my_key()
            when 'RightBtn', 'F10', 'Shift F10'
              stop_processing_my_key()
              menu_history_number = 5
              main_menu()
              stop_processing_my_key()
            otherwise
              NoOp() // Not my key: Let the editor or some other macro process it.
          endcase
        endif
      when 'insertcharacter'
        insert_character()
#ifndef LINUX
      when 'copy'
        copy_or_cut_to_win_clip(TRUE)
      when 'cut'
        copy_or_cut_to_win_clip(FALSE)
      when 'paste'
        paste_replace_from_win_clip()
#endif
      otherwise
        // No, the user executed the macro.
        menu_history_number = 1
        main_menu()
    endcase
  endif
end Main

