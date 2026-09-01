    Set oIE = CreateObject("InternetExplorer.Application")

    If IsObject(oIE) Then
        'Internet Explorer was successfully loaded - now display the document
        oIE.Visible = True
        oIE.FullScreen = False
        oIE.navigate "about:blank"
        'oIE.navigate "file://C:/a.htm"

        oIE.Document.open()
        oIE.Document.write("<h1>hello</h1><br><h2><center>world</center></h2>")
        oIE.Document.close()

        msgbox "Click to continue..."

        oIE.Document.open()
        oIE.Document.write("<h1>fini</h1>")
        oIE.Document.close()

        msgbox "Click to continue..."

        oIE.Quit
    End If
