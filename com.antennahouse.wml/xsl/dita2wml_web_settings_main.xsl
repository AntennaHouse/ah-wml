<?xml version="1.0" encoding="UTF-8"?>
<!--
****************************************************************
DITA to WordprocessingML Stylesheet
Module: Making word/webSettings.xml main stylesheet.
Copyright © 2009-2018 Antenna House, Inc. All rights reserved.
Antenna House is a trademark of Antenna House, Inc.
URL    : http://www.antennahouse.com/
E-mail : info@antennahouse.com
****************************************************************
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" 
    xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
    exclude-result-prefixes="xs ahf"
    version="3.0">
    
    <!-- This template generates word/webSettings.xml from the scratch.
         The input is dummy XML file.
     -->
    
    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>

    <!--
    function:   document-node template
    param:      none
    return:     w:webSettings
    note:       
    -->
    <xsl:template match="/" as="document-node()">
        <xsl:document>
            <xsl:call-template name="genWebSetting"/>
        </xsl:document>
    </xsl:template>

</xsl:stylesheet>
