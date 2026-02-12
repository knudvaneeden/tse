===

1. -To install

     1. -Take the file bfind_knud.zip

     2. -And unzip it in any arbitrary directory

     3. -Then run the file zipinstallbfind.bat

     4. -That will create a new file bfind_knud.zip
         in that directory

     5. -Unzip that latest file in a new arbitrary directory

     6. -Then run the file

          bfind.mac

2. -The .ini file is the local file 'bfind.ini'
    (thus not using tse.ini)

===

/*
   Macro          bFind
   Compatibility  TSE Pro 2.5e upwards
   Author         Carlo.Hogeveen@xs4all.nl
   Date           28 February 2006
   Version        1.02
   Date           7 March 2006

   A boolean/logical Find command, which allows you to combine quoted
   search-strings with the boolean operators AND, OR, NOT and brackets
   into a logical search-expression.

   Istallation:
      Copy this macro source to TSE's "mac" directory.
      Compile the macro either from the command-line or by opening the source
      in TSE and compiling it from the menu.
      Optionally add the macro to the Potpourri menu and/or assign a key
      to 'ExecMacro("bFind")'.
      Execute the macro from the Macro Execute menu or the Potpourri menu
      or press the key you assigned to it.

   The latest beta versions of my macros can be found at:
      http://www.xs4all.nl/~hyphen/tse

   Logical find expressions; explanation by example:
      not " "
      not ' '
      not a a
      not $ $
      not $\d032$
         All these expressions find all lines not containing a space.
      "cat" and "dog"
         Finds all lines containing both "cat" and "dog" in no particular
         order.
      "cat" or "dog"
         Finds all lines containing either "cat" or "dog" or both.
      not ("cat" or "dog")
         Finds all lines not containing either "cat" or "dog" or both.
      not ("cat" and "dog")
         Finds all lines not containing both "cat" and "dog" in no particular
         order.
      (("dog" and "cat") or ("cat" and ("mouse" or "canary"))) and not "eats"
         You get the idea: just nest away as much as you like!
      "cat" and "dog" or "canary"
      "cat" and ("dog" or "canary")
         These two expressions have the same result,
         but do yourself a favour and use the bracketed expression.
      "cat" or "dog" and "canary"
      "cat" or ("dog" and "canary")
         These two expressions have the same result,
         but do yourself a favour and use the bracketed expression.

   This macro is not intended to exist permanently: at some point I intend to
   add its functionality to the eFind macro, but because that might be some
   time away, I offer bFind for the time being.
   Because bFind is just an intermediate macro, it has the following
   limitations:
   -  Search options "a" and "c" do not work.
   -  Search options "g" and "v" are implicit.
   -  The ViewFinds buffer is immediately shown as an editable file.

   Rules for the logical search-expressions:
   -  The logical operators are "and", "or", "not", "(" and ")".
   -  When without brackets, "and" and "or" are processed left to right
      with equal precedence and with boolean short-circuiting.
   -  An empty logical expression is illegal syntax.
   -  Except for the size of the prompt box, there is no limit on the size
      of the logical expression.
   -  There is no limit on the depth of bracket nesting.
   -  Terminology: a logical search-expression is a single search-string or
      combines search-strings with logical operators.
   -  Each search-string is what TSE's standard find-command thinks is a
      search-string, except it must be quoted.
   -  The quoting character can be any non-whitespace character.
   -  The same search-options apply to all search-strings in the logical
      search-expression.

   History:

   v1.00    2 March 2006
   -  Initial version, despite the version number still a prototype.

   v1.01    5 March 2006
   -  Added syntax checking.
   -  Instead of always presenting an editable viewfinds buffer,
      now we get a List first, just like with TSE's standard Find command.
   -  Added awareness of the NoLines macro.

   v1.01    7 March 2006
   -  Solved bug: the "quoting character X not closed" error message
      caused TSE to loop almost infinitely.
   -  Took the opportunity to change this error message to the probably more
      understandable "missing quoting character(s)".
*/

/*

File: Source: FILE_ID.DIZ]

(Mar 7, 2006) - bFind 1.02 for TSE Pro 2.5e upwards.

A boolean/logical Find command.

Find all lines containing a logical combination of quoted search-strings.

Search-strings can be logically combined with the boolean operators AND, OR,
NOT and brackets.

Simple uses: Find lines not containing a string.

Find lines that contain two strings in no particular order.

Complex uses: no limit on nesting AND, OR and NOT with brackets.

Author: Carlo Hogeveen

*/
