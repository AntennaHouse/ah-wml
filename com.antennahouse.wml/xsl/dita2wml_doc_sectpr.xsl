<?xml version="1.0" encoding="UTF-8"?>
<!--
**************************************************************
DITA to WordprocessingML Stylesheet
w:sectPr Templates
**************************************************************
File Name : dita2wml_document_sectpr.xsl
**************************************************************
Copyright © 2009-2017 Antenna House, Inc. All rights reserved.
Antenna House is a trademark of Antenna House, Inc.
URL : http://www.antennahouse.com/
**************************************************************
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
    xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
    exclude-result-prefixes="xs ahf" 
    version="3.0">
    
    
    <xsl:variable name="lastTemplateSectPr" as="element(w:sectPr)" select="doc($pTemplateDocument)/w:document/w:body/w:sectPr[last()]"/>
    
    <!--
    function:   Section property template
    param:      none
    return:     w:sectPr
    note:       
    -->
    <xsl:template name="genSingleSideSectPr">
        <xsl:variable name="pgWidth" as="xs:integer" select="0"/>
        <xsl:apply-templates select="$lastTemplateSectPr">
            <xsl:with-param name="prmSectType" tunnel="yes" select="'single-side'"/>
        </xsl:apply-templates>
    </xsl:template>


    <!-- w:sectPr templates -->
    <xsl:template match="w:sectPr">
        <xsl:copy>
            <xsl:apply-templates select="* except w:titlePg"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- header templates for w:headerReference -->
    <xsl:template match="w:headerReference[string(@w:type) eq 'even']">
        <xsl:param name="prmSectType" as="xs:string" tunnel="yes" required="yes"/>
        <xsl:if test="$prmSectType eq 'left-right'">
            <xsl:copy>
                <xsl:copy-of select="@*"/>
            </xsl:copy>
        </xsl:if>
    </xsl:template>

    <xsl:template match="w:headerReference[string(@w:type) eq 'default']">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="w:headerReference[string(@w:type) eq 'first']">
    </xsl:template>

    <!-- footer templates for w:footerReference -->
    <xsl:template match="w:footerReference[string(@w:type) eq 'even']">
        <xsl:param name="prmSectType" as="xs:string" tunnel="yes" required="yes"/>
        <xsl:if test="$prmSectType eq 'left-right'">
            <xsl:copy>
                <xsl:copy-of select="@*"/>
            </xsl:copy>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="w:footerReference[string(@w:type) eq 'default']">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="w:footerReference[string(@w:type) eq 'first']">
    </xsl:template>
    
    <!-- Page size templates -->
    <xsl:template match="w:pgSz">
        <xsl:copy>
            <xsl:attribute name="w:w" select="ahf:toTwip($pPaperWidth)"/>
            <xsl:attribute name="w:h" select="ahf:toTwip($pPaperHeight)"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- Margin size templates -->
    <xsl:template match="w:pgMar">
        <xsl:copy>
            <xsl:attribute name="w:top" select="ahf:toTwip($pPaperMarginTop)"/>
            <xsl:attribute name="w:right" select="ahf:toTwip($pPaperMarginRight)"/>
            <xsl:attribute name="w:left" select="ahf:toTwip($pPaperMarginLeft)"/>
            <xsl:attribute name="w:bottom" select="ahf:toTwip($pPaperMarginBottom)"/>
            <xsl:attribute name="w:header" select="string(ahf:toTwip($pPaperMarginTop) idiv 2)"/>
            <xsl:attribute name="w:footer" select="string(ahf:toTwip($pPaperMarginBottom) idiv 2)"/>
            <xsl:attribute name="w:gutter" select="'0'"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- Other section elements -->
    <xsl:template match="w:cols">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="w:docGrid">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>