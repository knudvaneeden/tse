    Set oIE = CreateObject("InternetExplorer.Application")

    If IsObject(oIE) Then
        'Internet Explorer was successfully loaded - now display the document
        oIE.Visible = True
        oIE.FullScreen = False
        oIE.navigate "about:blank"

        Set xmldoc = CreateObject("MSXML.DOMDocument")
        Set xsldoc = CreateObject("MSXML.DOMDocument")

        xmldoc.loadXML("<?xml version='1.0'?><data><row col='Chinese'/><row col='Dutch'/><row col='English'/><row col='French'/><row col='German'/><row col='Korean'/></data>")
        xsldoc.loadXML("<?xml version='1.0'?><xsl:stylesheet xmlns:xsl='http://www.w3.org/TR/WD-xsl'><xsl:template match='/'><SELECT size='5'><xsl:for-each select='data/row'><xsl:element name='OPTION'><xsl:value-of select='@col' /></xsl:element></xsl:for-each></SELECT></xsl:template></xsl:stylesheet>")

        htmldoc = xmldoc.transformNode(xsldoc.documentElement)

        oIE.Document.open()
        oIE.Document.write(htmldoc)
        oIE.Document.close()

        msgbox "Click to quit..."

        oIE.Quit
    End If
