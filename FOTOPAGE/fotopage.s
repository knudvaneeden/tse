
/*************************************************************************
  FOTOPAGE    Generates a single page album HTML file from a directory
              of images

  Author:     Mike Chambers (Contributing User)

  Date:       Dec 4, 2000  (Original: Mike Chambers)

  Version:    1.00

  Overview:   This macro automates the generation of a hyperlinked
              summary page for a set of digital photos in a subdirectory.

              To use this macro:
              1. Create a directory of images.
              2. Create a subdirectory of thumbnails with the same name as each image
              3. Execute FOTOPAGE
              4. Provide Name of the Image directory
              5. Provide Name of the Thumbnail directory
              6. Provide a Title for the Page
              7. Provide a URL Link and Description for the bottom of the page
              8. Specify number of images per row.

              The file will be saved at index.html in the path with the images.

              FOTOPAGE requires a directory structure as follows

              \XZY
                   \Thumbnails             //Thumnail dir can be named anything
                        file1.jpg          //Thumbnail files must be same name as images they represent
                        file2.jpg
                        file3.jpg
              file1.jpg
              file2.jpg
              file3.jpg

              (Note IrfanView/32 "batch conversion" can be used to generate thumbnails of anysize.
              I suggest 240x180 since this allows 3 images across on a 800x600 screen.
              JPEG  compression level 85 will generate a nice quality & small size.
              Batch conversion is preferable to IrfanViews thumbnail generator because
              irfanview adds frames that clutter the screen.
              IrfanView is freeware and can be downloaded from http://www.irfanview.com.
              Any thumbnail generator can be used with this macro, provided that it can
              generator thumbnails in a subdir named the same as the original image.)


  Keys:       (none)

  Usage notes:

              You may have to do some manual clean-up because of case sensitivity of the
              web server you upload to.

              You can see an exaple of the results of this macro (and some very
              nice photos in a photo contest) at:

              http://www.egroups.com/files/coolpix990/Featured+Photo+Submissions/Thumbnails.html
*************************************************************************/


proc main()
            integer handle
            integer htmbuffid
            string dirpath[50]="*.jpg"
            string wintitle[50] = "Featured Photos"
            string AddlURL[80]="http://www.egroups.com/surveys/coolpix990?id=377040"
            string AddlURLDesc[80]="Cast your Vote"
            // thumbnails need to be in a separate directory identically named to full size image
            string ThumbnailDir[80]="Thumbnails/"
            integer NumColumns = 3
            integer photonum = 0
            string reply[2]="3"
            string savename[80] =""

            htmbuffid = newfile()
            ask('Enter directory path to build for',dirpath)  //location of full size images
            ask('Name of thumbnail directory',ThumbnailDir)   //location of thumbnails
            ask('Enter Window/Bookmark Title',wintitle)       //Window Title and Page heading
            ask('Additional URL',AddlURL)                     //link at bottom of page
            ask('Additional URL Description',AddlURLDesc)     //description for link at bottom of page
            asknumeric('Number of Columns for page',reply)    //number of photos in a row (3 is best)
            NumColumns = val(reply)

addline('<html>')
addline('<head>')
addline('')
addline('<meta http-equiv="Content-Type"content="text/html; charset=iso-8859-1">')
addline('<<meta name="generator" content="TSEPro/32 FOTOPAGE macro">')
addline('')
addline(format('<title>',wintitle,'</title>'))
addline('<style>')
addline('body {font-family:Verdana;}')
addline('</style>')
addline('</head>')
addline('<body bgcolor="#000000">')
addline('<center>')
addline(format('<font color="ffffcf"><h1>',wintitle,'</h1></font>'))
addline('<hr>')
addline('')
addline('<TABLE>')
addline('')
addline('')
addline('<TR>')


            handle = FindFirstFile(dirpath, -1)
            if handle <> -1
                repeat
                    photonum = photonum + 1
                    addline('')
                    addline('<TD ALIGN=CENTER VALIGN=BOTTOM><FONT face="Verdana, Arial, Helvetica, Sans-Serif" size="-2">')
                    addline(format('<A HREF="',FFName(),'" target="ImageWindow">'))
                    addline(format('<IMG SRC="',thumbnaildir,ffname(),'"   BORDER="0" '))
                    addline(format('ALT="',ffname(),'"><BR>',ffname(),'<BR>',ffsize()/1024,'KB</A></FONT></TD>'))

                    if (photonum mod NumColumns) == 0
                        addline('</TR><TR>')
                    endif
                until not FindNextFile(handle, -1)  //get next file
                FindFileClose(handle)          //release search handle
            endif


addline('</TR>')
addline('')
addline('')
addline('</TABLE>')
addline('')
addline('<hr>')
addline(format('<b><A HREF="',AddlURL,'">',AddlURLDesc,'</A></b>'))
addline(format('<br><br><FONT color="ffffcf" face="Verdana, Arial, Helvetica, Sans-Serif" size="-4">This page courtesy of TSEPro32: FOTOPAGE'))
addline('</center>')
addline('</body>')
addline('</html>')
savename=(format(SplitPath(ExpandPath(dirpath), _DRIVE_ | _PATH_)))
saveas(format(savename,'index.html'))
abandonfile(htmbuffid)
end
