<?xml version="1.0" encoding="UTF-8"?>
<!--
****************************************************************
DITA to WordprocessingML Stylesheet
Module: Making word/setting.xml main stylesheet.
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
    
    <!-- This template maintains w:setting/w:evenAndOddHeaders/@w:val attribute based on PRM_OUTPUT_TYPE parameter.
     -->
    
    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>

    <!--
    function:   general template for settings.xml
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
    function:   even and odd headers property
    param:      none
    return:     w:evenAndOddHeaders
    note:       
    -->
    <xsl:template match="/w:settings/w:evenAndOddHeaders" as="element(w:evenAndOddHeaders)">
        <xsl:copy>
            <xsl:apply-templates select="@* except @w:val"/>
            <xsl:attribute name="w:val" select="if ($pIsPrintOutput) then 'true' else 'false'"/>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
