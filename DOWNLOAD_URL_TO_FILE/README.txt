===

1. -To install

     1. -Take the file download_url_to_file_knud.zip

     2. -And unzip it in any arbitrary directory

     3. -Then run the file zipinstalldownload_url_to_file.bat

     4. -That will create a new file download_url_to_file_knud.zip
         in that directory

     5. -Unzip that latest file in a new arbitrary directory

     6. -Then run the file

          test_download_url_to_file.mac

2. -The .ini file is the local file 'download_url_to_file.ini'
    (thus not using tse.ini)

===

/*
  Macro           Test_download_url_to_file
  Author          Carlo Hogeveen
  Website         eCarlo.nl/tse
  Compatibility   Windows TSE v4 upwards
  Version         1.0

  This tool dd 14 September 2022 implements downloading all 112 files from
    https://semware.com/tse-macros/
  and all 378 files from
    https://www.semware.com/html/tseprofilesd.php

  It does this dynamically, first downloading each web page, and then all
  downloadable files found on the web page.

  Note that this relies on these two web pages' current format,
  and might not work in the future.

  This tool creates a directory "TSE" + this macro's name in your Windows
  temporary directory as found in the TMP environment variable,
  and it creates 2 subdirectories there, one for each web page.

*/
