
Welcome to the wonderful world of Ringlets!

This is a big and powerful package, with many files and much
documentation.

The main documentation is in the file Ringlets.txt. To install the
package, follow the instructions in the INSTALLATION section of that
file.  A lot of features should start working immediately after you
compile and run the macros.  So you can play around with the system
a bit, before you dive into the CONFIGURATION section of the manual.

Here's a brief overview of all the files in this package:

    Documentation
    -------------
    Ringlets.txt - Main documentation for the Ringlets system
    LoadProj.txt - Documentation for the LoadProj.s macro
    FILE_ID.DIZ  - brief description of the Ringlets package
    Readme.txt   - this overview


    Macros (these need to be compiled by you)
    ------
    Ringlets.s   - Main Ringlets macro source file
    LoadProj.s   - Simple Project loader for the Ringlets system
    regex.s      - Regular expression library for macros


    Plugin Macros (these also need to be compiled by you)
    -------------
    r_pm.s       - display Perl modules by their module name (e.g.
                   File::Find instead of File/Find.pm)

    r_html.s     - display HTML documents by the contents of their
                   <title></title> tags.

    Configuration
    -------------
    Ringkeys.si  - Ringlets keyboard definitions


    Library Files
    -------------
    regex.si     - Regular expression include file for macros
    setcache.si  - Library for determining if settings need to be reloaded
    FindProf.si  - Library for finding TSE.INI
    buffutil.si  - Library for manipulating text in ther buffers


    Support Files
    -------------
    LoadProj.reg - Windows Registry script to allow you to double click
                   on your project files (.proj) in Windows Explorer
                   and have them automatically load in TSE


Known issues in this release
----------------------------
This is a beta release, and there are some rough edges.

Here is a list of issues I plan to address in the near future:

 * Auto Ring tracking (new feature):
   - Each file tracks its "Current Ring".
   - You can have two files from two rings on screen at the same time
     (different windows)
   - Switching between windows when the files are in different rings
     also switches the ring

 * Ring Persistence Bugs: the rings don't always store their settings
   properly.

 * TSE.INI variable overlap: there are some overlaps between the
   functions of some variables, for instance "default_ring_properties"
   and the other "default_*" values.

 * Scrolling issues:  I don't like the way that rings containing
   many files are currently handled: the cursor always seems to be at
   the last item on the screen.  I haven't decided how to address this.

 * Convenience feature allow user to open a file from within the buffer
   list.

 * When you exit a file and it is the only file in a ring, the
   'all' ring is made current.

