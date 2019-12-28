<?xml version="1.0" encoding="UTF-8" ?>
<!--
****************************************************************
DITA to WordprocessingML Stylesheet
Module: WordprocessingML global constants.
Copyright © 2009-2017 Antenna House, Inc. All rights reserved.
Antenna House is a trademark of Antenna House, Inc.
URL    : http://www.antennahouse.com/
E-mail : info@antennahouse.com
****************************************************************
-->
<xsl:stylesheet version="3.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
    exclude-result-prefixes="#all"
>
    <!-- ****************************************************** 
           Global Constants that depend on merged middle file
         ****************************************************** -->
    
    <!-- Merged middle file document -->
    <xsl:variable name="docMergedMiddleFile" as="document-node()?" select="doc($pMergedFinalOutputUrl)"/>
    
    <!-- Temporary define map and documentLang for dita2wml_style_get.xsl -->
    <!-- Top level element -->
    <xsl:variable name="root" select="$docMergedMiddleFile/*[1]" as="element()"/>
    <xsl:variable name="map" select="$root/*[@class => contains-token('map/map')][1]" as="element()"/>
    <xsl:variable name="topic" select="$root/*[@class => contains-token('topic/topic')]" as="element()*"/>
    
    <!-- Document language -->
    <xsl:variable name="documentLang" as="xs:string">
        <xsl:variable name="defaultLang" as="xs:string" select="'en-US'"/>
        <xsl:choose>
            <xsl:when test="string($PRM_LANG) and ($PRM_LANG != $doubleApos)">
                <xsl:sequence select="$PRM_LANG"/>
            </xsl:when>
            <xsl:when test="$root/*[1]/@xml:lang">
                <xsl:sequence select="string($root/*[1]/@xml:lang)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="warningContinue">
                    <xsl:with-param name="prmMes">
                        <xsl:value-of select="ahf:replace($stMes101,('%lang'),($defaultLang))"/>
                    </xsl:with-param>
                </xsl:call-template>
                <xsl:sequence select="$defaultLang"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    
</xsl:stylesheet>
