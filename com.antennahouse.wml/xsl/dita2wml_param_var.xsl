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
                <xsl:sequence select="ahf:getVarValue('List_Indent_Size')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="$PRM_LIST_INDENT_SIZE"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="pListIndentSizeInTwip" as="xs:integer" select="ahf:toTwip($pListIndentSize)"/>
    <xsl:variable name="pListIndentSizeInEmu" as="xs:integer" select="ahf:toEmu($pListIndentSize)"/>

    <xsl:variable name="pListBaseIndentSize" as="xs:string">
        <xsl:choose>
            <xsl:when test="not(string($PRM_LIST_BASE_INDENT_SIZE)) or ($PRM_LIST_BASE_INDENT_SIZE = ('''''','&quot;&quot;'))">
                <xsl:sequence select="ahf:getVarValue('List_Base_Indent_Size')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="$PRM_LIST_BASE_INDENT_SIZE"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="pListBaseIndentSizeInTwip" as="xs:integer" select="ahf:toTwip($pListBaseIndentSize)"/>
    <xsl:variable name="pListBaseIndentSizeInEmu" as="xs:integer" select="ahf:toEmu($pListBaseIndentSize)"/>

</xsl:stylesheet>
