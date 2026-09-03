===

1. -To install

     1. -Take the file aftrocr_knud.zip

     2. -And unzip it in any arbitrary directory

     3. -Then run the file zipinstallaftrocr.bat

     4. -That will create a new file aftrocr_knud.zip
         in that directory

     5. -Unzip that latest file in a new arbitrary directory

     6. -Then run one or more of these 5 files:

          FuBookDu.mac:   Deletes duplicate scanned adjoining identical pages.

          Ocr_bl.mac  :   Using a massive list of word pairs, it replaces consistenly
                          badly scanned words with their correct counterparts without
                          any interaction from the user. At the end, the macro
                          generates a report, which can be consulted before the
                          text file is saved.

          2wrdlist.mac:   This is the macro to use, when the OCR software mixes up
                          two words, that by themselves are perfectly correct.
                          You add such word pairs to the 2wrdlist.wrd file, and let
                          the macro search for occurrences of these words in the text
                          file, giving the user the choice to easily swap each such
                          word in the text file.

          Goodcase.mac:   OCR software can have a problem determining the case of some
                          letters: this macro solves such mistaken cases, using the
                          surrounding letters to determine the correct case.

2. -The .ini file is the local file 'aftrocr.ini'
    (thus not using tse.ini)

===

   Four macroes to help solve OCR scanning errors.
   Tested with TSE Pro 2.50e en TSE Pro 2.80d.



   FuBookDu:   Deletes duplicate scanned adjoining identical pages.

   Ocr_bl  :   Using a massive list of word pairs, it replaces consistenly
               badly scanned words with their correct counterparts without
               any interaction from the user. At the end, the macro
               generates a report, which can be consulted before the
               text file is saved.

   2wrdlist:   This is the macro to use, when the OCR software mixes up
               two words, that by themselves are perfectly correct.
               You add such word pairs to the 2wrdlist.wrd file, and let
               the macro search for occurrences of these words in the text
               file, giving the user the choice to easily swap each such
               word in the text file.

   Goodcase:   OCR software can have a problem determining the case of some
               letters: this macro solves such mistaken cases, using the
               surrounding letters to determine the correct case.



   A more detailed description of these macro's can be found at the
   beginning of their sources.


   Note:
   The files 2wrdlist.wrd and ocr.lst are example files,
   and are intended to be modified by you to your own needs.


   Note for all users, but TSE 2.80 users especially:
   If your macroes do not reside in the directory c:\tse\mac,
   then you need to change the beginning of the source of the macroes
   2wrdlist.s and Ocr_bl.s: you need to change c:\tse\mac to the
   directory where your macroes reside, for example d:\tse32\mac.


   Note for TSE 2.80 users only:
   If your sort macro is older than 17 august 1998, then you need to
   replace it with the included sort macro.
