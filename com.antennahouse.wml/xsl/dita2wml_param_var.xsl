<?xml version='1.0' encoding="UTF-8" ?>
<!--
****************************************************************
DITA to WordprocessingML Stylesheet
Module: Variable definition from parameter that needs function call
Copyright © 2009-2018 Antenna House, Inc. All rights reserved.
Antenna House is a trademark of Antenna House, Inc.
URL    : http://www.antennahouse.com/
E-mail : info@antennahouse.com
****************************************************************
-->
<xsl:stylesheet version="3.0" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
    exclude-result-prefixes="#all">

    <!-- List indent size -->
    <xsl:variable name="pListIndentSize" as="xs:string">
        <xsl:choose>
            <xsl:when test="not(string($PRM_LIST_INDENT_SIZE)) or ($PRM_LIST_INDENT_SIZE = ('''''','&quot;&quot;'))">
                <xsl:sequence select="ahf:getVarValue('ListIndentSize')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="$PRM_LIST_INDENT_SIZE"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="pListIndentSizeInTwip" as="xs:integer" select="ahf:toTwip($pListIndentSize)"/>
    <xsl:variable name="pListIndentSizeInEmu" as="xs:integer" select="ahf:toEmu($pListIndentSize)"/>

    <!-- ol base indent size: applicable for first level ol -->
    <xsl:variable name="pOlBaseIndentSize" as="xs:string">
        <xsl:choose>
            <xsl:when test="not(string($PRM_OL_BASE_INDENT_SIZE)) or ($PRM_OL_BASE_INDENT_SIZE = ('''''','&quot;&quot;'))">
                <xsl:sequence select="ahf:getVarValue('OlBaseIndentSize')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="$PRM_OL_BASE_INDENT_SIZE"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="pOlBaseIndentSizeInTwip" as="xs:integer" select="ahf:toTwip($pOlBaseIndentSize)"/>
    <xsl:variable name="pOlBaseIndentSizeInEmu" as="xs:integer" select="ahf:toEmu($pOlBaseIndentSize)"/>
    
    <!-- ul base indent size: applicable for first level ol -->
    <xsl:variable name="pUlBaseIndentSize" as="xs:string">
        <xsl:choose>
            <xsl:when test="not(string($PRM_UL_BASE_INDENT_SIZE)) or ($PRM_UL_BASE_INDENT_SIZE = ('''''','&quot;&quot;'))">
                <xsl:sequence select="ahf:getVarValue('UlBaseIndentSize')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="$PRM_UL_BASE_INDENT_SIZE"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="pUlBaseIndentSizeInTwip" as="xs:integer" select="ahf:toTwip($pUlBaseIndentSize)"/>
    <xsl:variable name="pUlBaseIndentSizeInEmu" as="xs:integer" select="ahf:toEmu($pUlBaseIndentSize)"/>
    
</xsl:stylesheet>
