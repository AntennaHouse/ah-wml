<?xml version="1.0" encoding="UTF-8"?>
<!--
**************************************************************
DITA to WordprocessingML Stylesheet
Document.xml floatfig element Templates
**************************************************************
File Name : dita2wml_document_floatfig.xsl
**************************************************************
Copyright © 2009-2018 Antenna House, Inc. All rights reserved.
Antenna House is a trademark of Antenna House, Inc.
URL : http://www.antennahouse.co.jp/
**************************************************************
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" 
    xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
    xmlns:dita-ot="http://dita-ot.sourceforge.net/ns/201007/dita-ot"
    xmlns:graphicUtil="java:com.antennahouse.xsltutil.GraphicUtil"
    extension-element-prefixes="graphicUtil"
    exclude-result-prefixes="xs ahf dita-ot map graphicUtil"
    version="3.0">

    <!-- 
     function:	floatfig element processing
     param:		none
     return:	w:r
     note:      This template also called form block image processing.
                If it is block level image, adjust the image size to fit the body domain.
     -->
    <xsl:template match="*[contains(@class,' floatfig-d/floatfig ')][string(@float) = ('left','right')]" name="processFloatFigInline" as="element(w:r)?" priority="5">
        <xsl:param name="prmFloatFig" as="element()" required="no" select="."/>
        <xsl:variable name="isRight" as="xs:boolean" select="string($prmFloatFig/@float) eq 'right'"/>
        <xsl:variable name="widthPct" as="xs:integer" select="xs:integer(ahf:getOutputClassRegxWithDefault($prmFloatFig,'(width)(\d.)','50'))"/>
        <xsl:variable name="distToTextInEmu" as="xs:integer">
            <xsl:variable name="distToText" as="xs:string">
                <xsl:call-template name="getVarValue">
                    <xsl:with-param name="prmVarName" select="'FloatFigDistCommon'"/>
                </xsl:call-template>
            </xsl:variable>
            <xsl:sequence select="ahf:toEmu($distToText)"/>
        </xsl:variable>
        <xsl:variable name="widthInEmu" as="xs:integer" select="xs:integer(round(ahf:toEmu($pPaperBodyWidthInMm) * $widthPct div 100 - $distToTextInEmu))"/>
        <xsl:variable name="distL" as="xs:integer" select="if ($isRight) then $distToTextInEmu else 0"/>        
        <xsl:variable name="distR" as="xs:integer" select="if (not($isRight)) then $distToTextInEmu else 0"/>        
    </xsl:template>

    <!-- END OF STYLESHEET -->

</xsl:stylesheet>