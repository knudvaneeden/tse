===

1. -To install

     1. -Take the file atags_knud.zip

     2. -And unzip it in any arbitrary directory

     3. -Then run the file zipinstallatags.bat

     4. -That will create a new file atags_knud.zip
         in that directory

     5. -Unzip that latest file in a new arbitrary directory

     6. -Then run the file

          atags.mac

2. -The .ini file is the local file 'atags.ini'
    (thus not using tse.ini)

/*
  ATAGS.S     Assembly TAGs file support to TSE
  Author      LeChee.Lai

  Date:       July 29, 1999     - Preliminary Version

  Overview:

     This macro allows the use of TAG files like the ones used with VI etc.

  Keys:       <Ctrl F>    Active AsmTAG under cursor
              <Ctrl B>    Pop Last AsmTAG

  Usage notes:

    NOTE: This macro has been tested ONLY with Atags 1.29 by phoenix

  There is no warranty of any kind related to this file.
  If you don't like that, don't use it.

Requirements --------------------------------------------------------------

ù semware (books.mac)

*/

/*

[File: Source: ATAGS.DOC]

===

ATAGs v1.09  (AsmTAG and CTAG for TsePRO)
Lechee.Lai
lecheel@yahoo.com

Info ----------------------------------------------------------------------

ATAGs is a powerful facility to search symbol for MASM. which build index
file by phoenix Atags utility, it very siminlar like Exuberant Ctags
which can found http://ctags.sourceforge.net/ so far ATAGs v1.09 can support
those two format for ASM and C Language yap you are correct they use the
same key which depend on file name extension

Load the ATAGS macro, or add it to your AutoLoad list.
<Ctrl F>        to active ATAGs under cursor
<Ctrl B>        bring back for last ATAGs
<CtrlAlt '>     Create Index TAGV3.DAT

Some hilights include:

      Create DOS Console Environment SET TAGFILE=X:\PATH first
       which locate the project in you directory

      lack Atags utility it is because ATAGs is not freeware by the
       way you can use internal Atags Creater by hit "CtrlAlt '"
       which will create TAGV3.DAT in you Project directory of course
       their are many feature need to enhance, I'm glad if someone can
       enhacne this feature.


      Works on TSE 2.8 and TSE 3.0
       2.8 need to change cmpistr() to cmpstr() TsePRO 3.0 change internal
       API not full compatible with 2.8

      if you are using C language only you don't need to
       set TAGFILE=X:\PATH

      default ATAGS.MAC compile with TsePRO 3.0

History -------------------------------------------------------------------

v1.09 Build With CTAGS
      so far ATAGs can work as AsmTAG and Ctags depend on file name extension

v1.08 Backward function and Relayout the KeyAssign

v1.07 BugFix for Label And Enhance Find Token Structure

v1.06 BugFix for Duplicate found

v1.05 Add Phoenix ATags 1.29 Backward Compatible TagV2.DAT
      Auto switch if TagV3.DAT not exist

v1.04 todo Make TagV3.DAT

v1.03 Add Duplicate pattern fill in List for select UiN will auto goto target

v1.02 Add Label Support

v1.01 Add GetEnvStr Set Tagfile=[Drive]:\Path

*/

// v1.01 Add GetEnvStr Set Tagfile=[Drive]:\Path
// v1.02 Add Label Support
// v1.03 Add Duplicate pattern fill in List for select UiN will auto goto target
// v1.04 todo Make TagV3.DAT
// v1.05 Add Phoenix ATags 1.29 Backward Compatible TagV2.DAT // Auto switch if TagV3.DAT not exist
// v1.06 BugFix for Duplicate found
// v1.07 BugFix for Label And Enhance Find Token Structure
// v1.08 Backward function and Relayout the KeyAssign
// v1.09 Build With CTAGS
