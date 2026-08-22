===

1. -To install

     1. -Take the file svn_knud.zip

     2. -And unzip it in any arbitrary directory

     3. -Then run the file zipinstallsvn.bat

     4. -That will create a new file svn_knud.zip
         in that directory

     5. -Unzip that latest file in a new arbitrary directory

     6. -Then run the file

          svn.mac

2. -The .ini file is the local file 'svn.ini'
    (thus not using tse.ini)

===

// Revision: 14970
//
// ===
//
// Macro     Svn.s
// Author    Carlo.Hogeveen@xs4all.nl
// Date      25 May 2012
// Version   See the history and the help_text.
//
// ===
//
// Purpose:
//   The fastest possible Subversion browser.
//
// Why:
//   Tortoisesvn is beyond too slow for directories with many files.
//
// Trade-off:
//   A selected file's Subversion-properties are initially not shown.
//
// Installation:
//   The "svn" macro is "just" a shell around the "svn" commandline tool,
//   which is [a part of] the actual Subversion tool.
//   Therefore the commandline-tool "svn" must be installed and in the PATH
//   environment variable, either in general or from where TSE is started.
//
//   Either download the latest version of TortoiseSVN (1.7.7 as I write,
//   which also includes and installs "SVN") from
//   http://tortoisesvn.net/downloads.html ,
//
//   or download one of the binary packages for "svn" for Windows at the
//   bottom of the page of
//   http://subversion.apache.org/packages.html .
//
//   As for the macro, just put it in TSE's "mac" directory,
//   and compile and execute it.
//
// Features:
//   Browsing the HEAD of a Subversion repository's directories and files,
//   view their info, properties, and history, and read or edit [the historic
//   version of] a file (without saving to the repository).
//
// NOT a feature (yet):
//   Subversion security: the repository must either be publicly accessible,
//   or the username and password must already be locally stored
//   by (Tortoise)SVN itself.
//
// Wishlist:
// MUST
// - Being asked for a username and password when required by the repository.
// SHOULD
// - Closing a selected historic object should return to the history-list.
// - Being able to browse historic repository directories.
// - In the history-list you should not be able to select the separation lines.
// - Putting the @<revision> before the file-extension to enable
//   syntax-hiliting.
// COULD
// - Being able to compare two versions.
// WOULD
// - Make the macro also compileable to a .exe.
//
// History:
// 0.9   25 May 2012
//   - Initial version.
// 0.9.1  3 Jun 2012
//   - If started from the command-line with "-eSvn" and no file was opened
//     for editing, then TSE is closed with the macro.
// 0.9.2  25 Feb 2013
//     - Changed the helptext and a warning to English.
//
