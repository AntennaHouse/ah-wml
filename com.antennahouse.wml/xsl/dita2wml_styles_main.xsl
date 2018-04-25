<?xml version="1.0" encoding="UTF-8"?>
<!--
****************************************************************
DITA to WordprocessingML Stylesheet
Module: Making word/styles.xml main stylesheet.
Copyright © 2009-2017 Antenna House, Inc. All rights reserved.
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
    
    <!-- This template adds styles used for note before/after line that have horizontal rule made by <strike/> element.
     -->
    
    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>

    <!--
    param:      none
    return:     self and descendant node
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
    function:   default run property
    param:      none
    return:     w:rPrDefault
    note:       
    -->
    <xsl:template match="/w:styles/w:docDefaults/w:rPrDefault">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:call-template name="getWmlObject">
                <xsl:with-param name="prmObjName" select="'wmlInlineDefault'"/>
            </xsl:call-template>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
