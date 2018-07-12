<?xml version="1.0" encoding="UTF-8"?>
<!--
****************************************************************
DITA to WordprocessingML Stylesheet
Module: Making [Content_Types].xml main stylesheet.
Copyright © 2009-2018 Antenna House, Inc. All rights reserved.
Antenna House is a trademark of Antenna House, Inc.
URL    : http://www.antennahouse.com/
E-mail : info@antennahouse.com
****************************************************************
-->
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns="http://schemas.openxmlformats.org/package/2006/content-types"
    xmlns:ctype="http://schemas.openxmlformats.org/package/2006/content-types"
    xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
    exclude-result-prefixes="xs ctype ahf"
    version="3.0">
    
    <!-- This template complements the content of [Content_Types].xml.
     -->
    
    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>

    <xsl:variable name="cTypesDefault" as="element()*">
        <xsl:call-template name="getWmlObject">
            <xsl:with-param name="prmObjName" select="'wmlContentTypeOverride'"/>
        </xsl:call-template>
    </xsl:variable>

    <!--
    function:   Types template
    param:      none
    return:     Types
    note:       Complement the <Default> element
    -->
    <xsl:template match="ctype:Types">
        <xsl:variable name="types" as="element()" select="."/>
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates select="ctype:Default"/>
            <xsl:for-each select="$cTypesDefault">
                <xsl:variable name="defaultElem" as="element()" select="."/>
                <xsl:if test="empty($types/ctype:Default/@Extension[string(.) eq current()/@Extension/string(.)])">
                    <xsl:copy-of select="$defaultElem"/>
                </xsl:if>
            </xsl:for-each>
            <xsl:apply-templates select="* except ctype:Default"/>
            <!-- Generate Header/Footer Content Overrides -->
            <xsl:call-template name="genHeaderFooterContentTypeOverride"/>
            <!-- Generate webSettings Content Overrides -->
            <!--xsl:call-template name="genWebSettingsXmlContentTypeOverride"/-->
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="*">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
