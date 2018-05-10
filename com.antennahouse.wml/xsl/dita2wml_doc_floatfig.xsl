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
    xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing"
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
     note:      Generate text-box for floatfig.
                The width of the text-box is 50% of the text body or specified via @outputclass="widthNN".
                The height of the text-box is hard to calculate because it's depend on the contents.
                In this template the height is calculated using provisional method counting w:p has fixed height. 
                (based on the assumption that w:p fits the text-box width.)
     -->
    <xsl:template match="*[contains(@class,' floatfig-d/floatfig ')][string(@float) = ('left','right')]" name="processFloatFigInline" as="element(w:r)?" priority="5">
        <xsl:param name="prmFloatFig" as="element()" required="no" select="."/>
        <xsl:param name="prmSpaceBefore" as="xs:string" tunnel="yes" required="no" select="'0pt'"/>
        <xsl:variable name="drawingIdKey" as="xs:string" select="ahf:generateId($prmFloatFig)"/>
        <xsl:variable name="drawingId" as="xs:string" select="xs:string(map:get($drawingIdMap,$drawingIdKey))"/>
        <xsl:variable name="isRight" as="xs:boolean" select="string($prmFloatFig/@float) eq 'right'"/>
        <xsl:variable name="widthPct" as="xs:integer" select="xs:integer(ahf:getOutputClassRegxWithDefault($prmFloatFig,'(width)(\d+)(pct)?','$2','50'))"/>
        <xsl:variable name="distToTextInEmu" as="xs:integer">
            <xsl:variable name="distToText" as="xs:string">
                <xsl:call-template name="getVarValue">
                    <xsl:with-param name="prmVarName" select="'FloatFigDistCommon'"/>
                </xsl:call-template>
            </xsl:variable>
            <xsl:sequence select="ahf:toEmu($distToText)"/>
        </xsl:variable>
        <xsl:variable name="paperBodyWidthInEmu" as="xs:integer" select="ahf:toEmu($pPaperBodyWidth)"/>
        <xsl:variable name="widthInEmu" as="xs:integer" select="xs:integer(round($paperBodyWidthInEmu * $widthPct div 100 - $distToTextInEmu))"/>
        <xsl:variable name="distL" as="xs:integer" select="if ($isRight) then $distToTextInEmu else 0"/>        
        <xsl:variable name="distR" as="xs:integer" select="if (not($isRight)) then $distToTextInEmu else 0"/>
        <xsl:variable name="posX" as="xs:integer" select="if ($isRight) then $paperBodyWidthInEmu - $widthInEmu else 0"/>
        <xsl:variable name="frame" as="element()">
            <xsl:choose>
                <xsl:when test="string($prmFloatFig/@frame) eq 'all'">
                    <xsl:call-template name="getWmlObject">
                        <xsl:with-param name="prmObjName" select="'wmlFloatFigFrame'"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="$cElemNull"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="txbxContent" as="document-node()">
            <xsl:document>
                <xsl:apply-templates>
                    <xsl:with-param name="prmIndentLevel" tunnel="yes" select="0"/>
                    <xsl:with-param name="prmExtraIndent" tunnel="yes" select="0"/>
                    <xsl:with-param name="prmWidthConstraintInEmu" tunnel="yes" as="xs:integer" select="$widthInEmu"/>
                </xsl:apply-templates>
            </xsl:document>
        </xsl:variable>
        <xsl:variable name="heightInEmu" as="xs:integer">
            <xsl:variable name="pHeightInEmu" as="xs:integer">
                <xsl:call-template name="getVarValueAsInteger">
                    <xsl:with-param name="prmVarName" select="'PHeightInEmu'"/>
                </xsl:call-template>
            </xsl:variable>
            <xsl:variable name="contentHeightsInEmu" as="xs:integer+">
                <xsl:apply-templates select="$txbxContent/*" mode="MODE_GET_HEIGHT">
                    <xsl:with-param name="prmPHeightInEmu" tunnel="yes" select="$pHeightInEmu"/>
                </xsl:apply-templates>
            </xsl:variable>
            <xsl:sequence select="sum($contentHeightsInEmu)"/>
        </xsl:variable>
        
        <!-- Generate text-box -->
        <w:r>
            <xsl:call-template name="getWmlObjectReplacing">
                <xsl:with-param name="prmObjName" select="'wmlFloatFig'"/>
                <xsl:with-param name="prmSrc" select="('%dist-l','%dist-r','%pos-x','%pos-y','%width','%height','%id','node:frame','node:txbxContent')"/>
                <xsl:with-param name="prmDst" select="(string($distL),string($distR),string($posX),ahf:toEmuStr($prmSpaceBefore),string($widthInEmu),string($heightInEmu),string($drawingId),$frame,$txbxContent)"/>
            </xsl:call-template>
        </w:r>
    </xsl:template>

    <!-- Normal w:p -->
    <xsl:template match="w:p[empty(w:r[1]/w:drawing/wp:inline/wp:extent/@cy) or exists(w:r[2])]" as="xs:integer" mode="MODE_GET_HEIGHT">
        <xsl:param name="prmPHeightInEmu" as="xs:integer" tunnel="yes" required="yes"/>
        <xsl:sequence select="$prmPHeightInEmu"/>
    </xsl:template>
    
    <!-- w:p with block image -->
    <xsl:template match="w:p[exists(w:r[1]/w:drawing/wp:inline/wp:extent/@cy)][empty(w:r[2])]" as="xs:integer" mode="MODE_GET_HEIGHT">
        <xsl:param name="prmPHeightInEmu" as="xs:integer" tunnel="yes" required="yes"/>
        <xsl:sequence select="xs:integer(w:r/w:drawing/wp:inline/wp:extent/@cy/string())"/>
    </xsl:template>
    
    <!-- w:tbl (!) -->
    <xsl:template match="w:tbl" as="xs:integer" mode="MODE_GET_HEIGHT">
        <xsl:param name="prmPHeightInEmu" as="xs:integer" tunnel="yes" required="yes"/>
        <xsl:sequence select="$prmPHeightInEmu * count(w:tr)"/>
    </xsl:template>
    
    <!-- END OF STYLESHEET -->

</xsl:stylesheet>