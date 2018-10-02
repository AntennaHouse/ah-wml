<?xml version='1.0' encoding="UTF-8" ?>
<!--
****************************************************************
DITA to WordprocessingML Stylesheet
Module: Stylesheet parameter and global variables (2).
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

    <!-- Paper size
         2015-04-23 t.makita
     -->
    <xsl:param name="PRM_PAPER_SIZE" required="no" as="xs:string" select="'Letter'"/>
    <xsl:variable name="pPaperSize" as="xs:string" select="$PRM_PAPER_SIZE"/>
    
    <xsl:param name="cPaperInfo" as="xs:string+">
        <xsl:call-template name="getVarValueAsStringSequence">
            <xsl:with-param name="prmVarName" select="'Paper_Info'"/>
            <xsl:with-param name="prmPaperSize" select="()"/>
        </xsl:call-template>
    </xsl:param>
    
    <xsl:variable name="paperIndex" as="xs:integer" >
        <xsl:variable name="tempPaperIndex" as="xs:integer?" select="index-of($cPaperInfo,$pPaperSize)[1]"/>
        <xsl:choose>
            <xsl:when test="empty($tempPaperIndex)">
                <xsl:call-template name="errorExit">
                    <xsl:with-param name="prmMes" select="ahf:replace($stMes1500,('%param','%sptval'),($pPaperSize,string-join($cPaperInfo[(position() mod 5) eq 1],',')))"/>
                </xsl:call-template>
                <xsl:sequence select="1"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="$tempPaperIndex"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <!-- Margin
         Defined as variable because it is used for XPath evaluation in style definition file.
     -->
    <xsl:variable name="cPaperMarginTopDefault"    as="xs:string" select="'25mm'"/>
    <xsl:variable name="cPaperMarginBottomDefault" as="xs:string" select="'25mm'"/>
    <xsl:variable name="cPaperMarginInnerDefault"   as="xs:string" select="'25mm'"/>
    <xsl:variable name="cPaperMarginOuterDefault"  as="xs:string" select="'25mm'"/>
    <xsl:variable name="cPaperHeaderHeightDefault" as="xs:string" select="'20mm'"/>
    <xsl:variable name="cPaperFooterHeightDefault" as="xs:string" select="'20mm'"/>
    <xsl:variable name="cPaperColumnGapDefault"    as="xs:string" select="'10mm'"/>
    
    <xsl:param name="PRM_PAPER_MARGIN_TOP"    required="no" as="xs:string" select="$cPaperMarginTopDefault"/>
    <xsl:param name="PRM_PAPER_MARGIN_OUTER"  required="no" as="xs:string" select="$cPaperMarginOuterDefault"/>
    <xsl:param name="PRM_PAPER_MARGIN_BOTTOM" required="no" as="xs:string" select="$cPaperMarginBottomDefault"/>
    <xsl:param name="PRM_PAPER_MARGIN_INNER"  required="no" as="xs:string" select="$cPaperMarginInnerDefault"/>
    <xsl:param name="PRM_PAPER_HEADER_HEIGHT" required="no" as="xs:string" select="$cPaperHeaderHeightDefault"/>
    <xsl:param name="PRM_PAPER_FOOTER_HEIGHT" required="no" as="xs:string" select="$cPaperFooterHeightDefault"/>
    <xsl:param name="PRM_PAPER_COLUMN_GAP"    required="no" as="xs:string" select="$cPaperColumnGapDefault"/>
    
    <xsl:variable name="pPaperMarginTop" as="xs:string">
        <xsl:choose>
            <xsl:when test="ahf:isUnitValue($PRM_PAPER_MARGIN_TOP)">
                <xsl:sequence select="$PRM_PAPER_MARGIN_TOP"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message select="'[dita2wml_param_papersize] Invalid unit value $PRM_PAPER_MARGIN_TOP=',$PRM_PAPER_MARGIN_TOP"/>
                <xsl:sequence select="$cPaperMarginTopDefault"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    
    <xsl:variable name="pPaperMarginBottom" as="xs:string">
        <xsl:choose>
            <xsl:when test="ahf:isUnitValue($PRM_PAPER_MARGIN_BOTTOM)">
                <xsl:sequence select="$PRM_PAPER_MARGIN_BOTTOM"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message select="'[dita2wml_param_papersize] Invalid unit value $PRM_PAPER_MARGIN_BOTTOM=',$PRM_PAPER_MARGIN_BOTTOM"/>
                <xsl:sequence select="$cPaperMarginBottomDefault"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    
    <xsl:variable name="pPaperMarginOuter" as="xs:string">
        <xsl:choose>
            <xsl:when test="ahf:isUnitValue($PRM_PAPER_MARGIN_OUTER)">
                <xsl:sequence select="$PRM_PAPER_MARGIN_OUTER"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message select="'[dita2wml_param_papersize] Invalid unit value $PRM_PAPER_MARGIN_OUTER=',$PRM_PAPER_MARGIN_OUTER"/>
                <xsl:sequence select="$cPaperMarginOuterDefault"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <xsl:variable name="pPaperMarginInner" as="xs:string">
        <xsl:choose>
            <xsl:when test="ahf:isUnitValue($PRM_PAPER_MARGIN_INNER)">
                <xsl:sequence select="$PRM_PAPER_MARGIN_INNER"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message select="'[dita2wml_param_papersize] Invalid unit value $PRM_PAPER_MARGIN_INNER=',$PRM_PAPER_MARGIN_INNER"/>
                <xsl:sequence select="$cPaperMarginInnerDefault"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <xsl:variable name="pPaperHeaderHeight" as="xs:string">
        <xsl:choose>
            <xsl:when test="ahf:isUnitValue($PRM_PAPER_HEADER_HEIGHT)">
                <xsl:sequence select="$PRM_PAPER_HEADER_HEIGHT"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message select="'[dita2wml_param_papersize] Invalid unit value $PRM_PAPER_HEADER_HEIGHT=',$PRM_PAPER_HEADER_HEIGHT"/>
                <xsl:sequence select="$cPaperHeaderHeightDefault"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    
    <xsl:variable name="pPaperFooterHeight" as="xs:string">
        <xsl:choose>
            <xsl:when test="ahf:isUnitValue($PRM_PAPER_FOOTER_HEIGHT)">
                <xsl:sequence select="$PRM_PAPER_FOOTER_HEIGHT"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message select="'[dita2wml_param_papersize] Invalid unit value $PRM_PAPER_FOOTER_HEIGHT=',$PRM_PAPER_FOOTER_HEIGHT"/>
                <xsl:sequence select="$cPaperFooterHeightDefault"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <xsl:variable name="pPaperColumnGap" as="xs:string">
        <xsl:choose>
            <xsl:when test="ahf:isUnitValue($PRM_PAPER_COLUMN_GAP)">
                <xsl:sequence select="$PRM_PAPER_COLUMN_GAP"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message select="'[dita2wml_param_papersize] Invalid unit value $PRM_PAPER_COLUMN_GAP=',$PRM_PAPER_COLUMN_GAP"/>
                <xsl:sequence select="$cPaperColumnGapDefault"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    
    <!-- paper related variables used here -->
    <xsl:variable name="pPaperWidth" as="xs:string" select="$cPaperInfo[$paperIndex + 1]"/>
    <xsl:variable name="pPaperHeight" as="xs:string" select="$cPaperInfo[$paperIndex + 2]"/>
    <xsl:variable name="pPaperBodyWidth" as="xs:string" select="concat(string(ahf:toMm($pPaperWidth) - ahf:toMm($pPaperMarginInner) - ahf:toMm($pPaperMarginOuter)),'mm')"/>
    
</xsl:stylesheet>
