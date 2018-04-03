<?xml version="1.0" encoding="UTF-8"?>
<!--
**************************************************************
DITA to WordprocessingML Stylesheet
numbering.xml Main Templates
**************************************************************
File Name : dita2wml_numbering_main.xsl
**************************************************************
Copyright © 2009-2017 Antenna House, Inc. All rights reserved.
Antenna House is a trademark of Antenna House, Inc.
URL : http://www.antennahouse.co.jp/
**************************************************************
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:wpc="http://schemas.microsoft.com/office/word/2010/wordprocessingCanvas" 
    xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006" 
    xmlns:o="urn:schemas-microsoft-com:office:office" 
    xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" 
    xmlns:m="http://schemas.openxmlformats.org/officeDocument/2006/math" 
    xmlns:v="urn:schemas-microsoft-com:vml" 
    xmlns:wp14="http://schemas.microsoft.com/office/word/2010/wordprocessingDrawing" 
    xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing" 
    xmlns:w10="urn:schemas-microsoft-com:office:word" 
    xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" 
    xmlns:w14="http://schemas.microsoft.com/office/word/2010/wordml" 
    xmlns:w15="http://schemas.microsoft.com/office/word/2012/wordml" 
    xmlns:wpg="http://schemas.microsoft.com/office/word/2010/wordprocessingGroup" 
    xmlns:wpi="http://schemas.microsoft.com/office/word/2010/wordprocessingInk" 
    xmlns:wne="http://schemas.microsoft.com/office/word/2006/wordml" 
    xmlns:wps="http://schemas.microsoft.com/office/word/2010/wordprocessingShape" 
    xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
    exclude-result-prefixes="xs ahf"
    version="2.0">
    
    <!--
    function:   General template for numbering.xml
    param:      none
    return:     
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
    function:   Root element w:numbering 
    param:      none
    return:     
    note:       
    -->
    <xsl:template match="w:numbering">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="w:abstractNum"/>
            <!-- Generate w:abtsractNum for topic/title numbering -->
            <xsl:if test="$pAddChapterNumberPrefixToTopicTitle">
                <xsl:call-template name="genTopicTitleAbstarctWnumInstance"/>
            </xsl:if>
            <xsl:apply-templates select="w:num"/>
            <!-- Generate w:num per input document list instances -->
            <xsl:call-template name="genDocWnumInstance"/>
            <xsl:if test="$pAddChapterNumberPrefixToTopicTitle">
                <xsl:call-template name="genTopicTitleWnumInstance"/>
            </xsl:if>
        </xsl:copy>
    </xsl:template>

    <!--
    function:   Ordered list or unordered list
    param:      none
    return:     
    note:       
    -->
    <xsl:template match="w:abstractNum[string(@w:abstractNumId) = ($olAbstractNumId,$ulAbstractNumId)]">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates>
                <xsl:with-param name="prmIsList" tunnel="yes" select="true()"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>
    
    <!--
    function:   Adjust the list indent size 
    param:      prmIsList
    return:     
    note:       
    -->
    <xsl:template match="w:abstractNum/w:lvl/w:pPr/w:ind">
        <xsl:param name="prmIsList" tunnel="yes" required="no" as="xs:boolean" select="false()"/>
        <xsl:choose>
            <xsl:when test="$prmIsList">
                <xsl:variable name="level" as="xs:integer" select="xs:integer(parent::*/parent::*/@w:ilvl)"/>
                <xsl:copy>
                    <!--xsl:attribute name="w:left" select="string(ahf:getIndentFromIndentLevel($level,0) + xs:integer(@w:hanging))"/-->
                    <xsl:attribute name="w:left" select="string(ahf:getIndentFromIndentLevel($level,0) + $pListIndentSizeInTwip)"/>
                    <xsl:attribute name="w:hanging" select="$pListIndentSizeInTwip"/>
                    <xsl:apply-templates select="@* except (@w:left | @w:hanging)"/>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates select="@*"/>
                    <xsl:apply-templates/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!--
    function:   w:num in the template document 
    param:      
    return:     
    note:       Retain all w:num instances in template document for safety.
    -->
    <xsl:template match="w:num">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>

    <!--
    function:   generate w:num for the input document 
    param:      
    return:     
    note:       w:num is categorized into two patterns (ol or ul)
                Every w:num instances identifies individual list.
                So w:lvlOverride is needed to restart the new ol number.
    -->
    
    <xsl:template name="genDocWnumInstance">
        <xsl:for-each select="doc($pMergedFinalOutputUrl)//*[contains(@class, ' topic/ol ') or contains(@class, ' topic/ul ')]">
            <w:num>
                <xsl:attribute name="w:numId" select="ahf:getNumIdFromListOccurenceNumber(position())"/>
                <w:abstractNumId>
                    <xsl:attribute name="w:val">
                        <xsl:choose>
                            <xsl:when test="contains(@class,' topic/ol ')">
                                <xsl:value-of select="$olAbstractNumId"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$ulAbstractNumId"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                </w:abstractNumId>
                <xsl:if test="contains(@class,' topic/ol ')">
                    <w:lvlOverride w:ilvl="0">
                        <w:startOverride w:val = "1"/>
                    </w:lvlOverride>
                    <w:lvlOverride w:ilvl="1">
                        <w:startOverride w:val = "1"/>
                    </w:lvlOverride>
                    <w:lvlOverride w:ilvl="2">
                        <w:startOverride w:val = "1"/>
                    </w:lvlOverride>
                    <w:lvlOverride w:ilvl="3">
                        <w:startOverride w:val = "1"/>
                    </w:lvlOverride>
                    <w:lvlOverride w:ilvl="4">
                        <w:startOverride w:val = "1"/>
                    </w:lvlOverride>
                    <w:lvlOverride w:ilvl="5">
                        <w:startOverride w:val = "1"/>
                    </w:lvlOverride>
                    <w:lvlOverride w:ilvl="6">
                        <w:startOverride w:val = "1"/>
                    </w:lvlOverride>
                    <w:lvlOverride w:ilvl="7">
                        <w:startOverride w:val = "1"/>
                    </w:lvlOverride>
                    <w:lvlOverride w:ilvl="8">
                        <w:startOverride w:val = "1"/>
                    </w:lvlOverride>
                </xsl:if>
            </w:num>
        </xsl:for-each>
    </xsl:template>

    <!--
    function:   generate w:num for the topic/title numbering 
    param:      none
    return:     w:num
    note:       
    -->
    <xsl:template name="genTopicTitleAbstarctWnumInstance">
        <xsl:call-template name="getWmlObject">
            <xsl:with-param name="prmObjName" select="'wmlTopicTitleAbstractNum'"/>
        </xsl:call-template>
    </xsl:template>
    
    <!--
    function:   generate w:num for the topic/title numbering 
    param:      none
    return:     w:num
    note:       
    -->
    <xsl:template name="genTopicTitleWnumInstance">
        <xsl:call-template name="getWmlObject">
            <xsl:with-param name="prmObjName" select="'wmlTopicTitleNum'"/>
        </xsl:call-template>
    </xsl:template>
    
    <!-- END OF STYLESHEET -->
</xsl:stylesheet>