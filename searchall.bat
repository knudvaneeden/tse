@REM version 1.0.0.0.32

@REM [kn, ri, we, 10-02-2021 17:11:20]-[kn, ri, th, 11-02-2021 03:19:17]-[kn, ri, th, 11-02-2021 09:46:28]-[kn, ri, th, 11-02-2021 11:05:08]
@REM [kn, ri, th, 11-02-2021 12:33:04]-[kn, ri, th, 11-02-2021 16:26:09]-[kn, ri, fr, 12-02-2021 14:33:49]-[kn, ri, fr, 12-02-2021 14:46:55]
@REM [kn, ri, mo, 15-02-2021 11:47:34]-[kn, ri, mo, 19-07-2021 22:48:27]-[kn, ri, th, 14-10-2021 15:01:26]-[kn, ri, we, 22-12-2021 22:42:00]
@REM [kn, ri, th, 23-12-2021 13:12:29]-[kn, ri, fr, 21-01-2022 18:29:54]-[kn, ri, su, 20-03-2022 19:31:40]-[kn, ri, su, 20-03-2022 19:52:29]
@REM [kn, ri, su, 20-03-2022 19:56:45]-[kn, ri, su, 20-03-2022 20:08:11]-[kn, ri, su, 20-03-2022 20:32:33]-[kn, ri, sa, 04-06-2022 17:45:54]
@REM [kn, ri, th, 04-08-2022 12:33:52]-[kn, ri, th, 04-08-2022 13:08:55]-[kn, ri, th, 04-08-2022 13:34:36]-[kn, ri, th, 04-08-2022 14:10:11]
@REM [kn, ri, th, 04-08-2022 14:51:01]-[kn, ri, th, 04-08-2022 15:13:08]-[kn, ri, sa, 31-12-2022 23:17:36]-[kn, ri, tu, 28-02-2023 22:07:58]
@REM [kn, ri, tu, 14-03-2023 18:41:22]-[kn, ri, mo, 20-03-2023 14:26:41]-[kn, ri, we, 22-03-2023 12:18:47]-[kn, ri, sa, 03-06-2023 01:00:50]

@REM Usage: searchall.bat <your query>
@REM
@REM For example:
@REM
@REM searchall.bat this is a test
@REM
@REM searchall.bat this is another test
@REM
@REM searchall.bat error 123
@REM
@REM Note: Only once you will have to install the Google Chrome app (which can be found in the 'Company Portal' app with officially approved software
@REM
@REM Note: You typically will have to run this searchall.bat 2 times initially, first to login to e.g. Empower, then to run it again without having to log in.
@REM
@REM Note: The search string will also automatically be copied to the Microsoft Windows clipboard, so that you can paste it in the search box in the web pages where applicable
@REM
@REM Note: Do not use double quotes "" around the query. Thus e.g. searchall.bat This is a test is OK, but searchall.bat "This is a test" not.
@REM
@REM Note: If you want to disable a URL, just put 'REM ' or '@REM ' (without single quotes) in front of that line below and save this .bat file
@REM
@REM Note: To quickly close your open tabs in Google Chrome, just go to the leftmost tab, right click and select 'close tabs to the right'.

@REM copy current command line parameters to the Microsoft Windows clipboard
echo %* | clip

start chrome https://daeisearch.eur.ad.sag/web/search/search.html#do=search^&q="%*"
start chrome https://empower.softwareag.com/searchpage.aspx?q="%*"
start chrome https://empower.softwareag.com/KnowledgeCenter/Product_Fixes/FixExplorer/default.aspx

pause

start chrome https://daeisearch.eur.ad.sag/web/search/search.html#do=search^&q="%*"
start chrome https://empower.softwareag.com/searchpage.aspx?q="%*"
start chrome https://empower.softwareag.com/KnowledgeCenter/Product_Fixes/FixExplorer/default.aspx

start chrome https://ifind.eur.ad.sag/source/
start chrome https://github.softwareag.com/search?q=org:AIM+"%*"
start chrome https://github.softwareag.com/AIM/esb/search?q="%*"
start chrome https://github.softwareag.com/AIM/num/search?q="%*"
start chrome https://getsupport.softwareag.com/browse/IC-99191?jql=text~"%*"
start chrome https://itrac.eur.ad.sag/secure/QuickSearch.jspa?searchString="%*"
start chrome https://iwiki.eur.ad.sag/dosearchsite.action?queryString="%*"
start chrome https://tech.forums.softwareag.com/search?q="%*"
start chrome https://learning.softwareag.com/course/search.php?search="%*"

start chrome https://documentation.softwareag.com/
start chrome https://documentation.softwareag.com/onlinehelp/Rohan/num10-5/10-5_UM_webhelp/index.html
start chrome https://empower.softwareag.com/sl24sec/SecuredServices/document/java/Troubleshooting/atg/index.htm
start chrome https://www.atlassian.com/software/jira/guides/expand-jira/jql

start chrome https://chat.openai.com
start chrome https://heypi.com/talk?utm_source=inflection.ai
start msedge https://bing.com

start chrome https://www.google.com/search?q="%*"
start chrome https://books.google.com/books?q="%*"
start chrome https://www.youtube.com/results?search_query="%*"
start chrome https://learning.oreilly.com/search/?query="%*"
start chrome https://www.wolframalpha.com/input/?i="%*"
start chrome https://en.wikipedia.org/wiki/"%*"
start chrome https://www.bing.com/search?q="%*"
start chrome https://search.yahoo.com/bin/query?p="%*"
start chrome https://www.ask.com/web?q="%*"
start chrome https://yandex.com/search/?text="%*"
start chrome https://you.com/search?q="%*"
start chrome https://duckduckgo.com/?q="%*"
start chrome https://yep.com/web?q="%*"
start chrome https://www.mojeek.com/search?q="%*"
start chrome https://www.baidu.com/s?wd="%*"
start chrome https://search.naver.com/search.naver?query="%*"
start chrome https://search.aol.co.uk/aol/search?q="%*"
start chrome https://results.excite.com/serp?q="%*"
start chrome https://search.lycos.com/web/?q="%*"
start chrome https://wordpress.org/openverse/search/?q="%*"
start chrome https://swisscows.com/web?query="%*"
start chrome https://gibiru.com/results.html?q="%*"
start chrome https://boardreader.com/s/"%*".html
start chrome https://web.archive.org/web/20220000000000*/"%*"
start chrome https://ekoru.org/?q="%*"
start chrome https://www.ecosia.org/search?q="%*"
start chrome https://twitter.com/search?q="%*"
start chrome https://neeva.com/search?q="%*"
start chrome https://search.brave.com/search?q="%*"
start chrome https://www.slideshare.net/search/slideshow?q="%*"
start chrome http://www.wiki.com/results1.htm?cx=009420061493499222400%3Ae8sof1xaq-u^&btnG=Wiki+Search^&cof=GIMP%3A009900%3BT%3A000000%3BALC%3AFF9900%3BGFNT%3AB0B0B0%3BLC%3A003F7D%3BBGC%3AFFFFFF%3BVLC%3A666666%3BGALT%3A36A200%3BFORID%3A9%3B^&as_q=on^&q="%*"

start chrome https://www.onesearch.com
start chrome https://www.searchencrypt.com
start chrome https://www.startpage.com
