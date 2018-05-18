<?xml version="1.0" encoding="UTF-8"?>
<!--
**************************************************************
DITA to WordprocessingML Stylesheet
Comment.xml Templates
**************************************************************
File Name : dita2wml_comment.xsl
**************************************************************
Copyright © 2009 2017 Antenna House, Inc. All rights reserved.
Antenna House is a trademark of Antenna House, Inc.
URL : http://www.antennahouse.com/
**************************************************************
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:w="http://purl.oclc.org/ooxml/wordprocessingml/main"
    exclude-result-prefixes="xs"
    version="3.0">
    
    <!--
    function:   Document node template
    param:      none
    return:     w:comment
    note:       Not implemented yet!
    -->
    <xsl:template match="/">
        <w:comment/>
    </xsl:template>
    
</xsl:stylesheet>