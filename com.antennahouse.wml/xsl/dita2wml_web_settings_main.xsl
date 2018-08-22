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
    
    <!-- This template generates word/webSettings.xml from template adding w:divs element.
     -->
    
    <xsl:output method="xml" encoding="UTF-8"/>

    <!--
    function:   General template
    param:      none
    return:     itself and attribute & descendant node
    note:       
    -->
    <xsl:template match="node()">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="@*">
        <xsl:copy/>
    </xsl:template>

    <!--
    function:   document-node template
    param:      none
    return:     w:webSettings
    note:       
    -->
    <xsl:template match="w:webSettings">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:call-template name="genWebSettingDivs"/>
            <xsl:apply-templates select="* except w:div"/>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
