<?xml version="1.0" encoding="UTF-8"?>
<!--
**************************************************************
DITA to WordprocessingML Stylesheet
Document.xml hi-light domain text Templates
**************************************************************
File Name : dita2wml_document_highlight_domain.xsl
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
    version="2.0">

    <!-- 
     function:	hi-lighting domain processing
     param:		none
     return:	
     note:      Add new inline style into $prmRunProps and apply templates.
                Microsoft Word does not allow same w:rPr child elements.
                Thus x = y<sup>2<sup>3</sup></sup> will be correctly formatted in XSL-FO but Word cannot do it.
     -->
    <xsl:template match="*[contains(@class, ' hi-d/u ')]" priority="5">
        <xsl:param name="prmRunProps" tunnel="yes" required="no" as="element()*" select="()"/>
        <xsl:variable name="uProp" as="element()">
           <w:u w:val="single"/>
        </xsl:variable>
        <xsl:apply-templates>
            <xsl:with-param name="prmRunProps" tunnel="yes" select="($prmRunProps[not(self::w:u)],$uProp)"/>
        </xsl:apply-templates>
    </xsl:template>
    
    <xsl:template match="*[contains(@class, ' hi-d/b ')]" priority="5">
        <xsl:param name="prmRunProps" tunnel="yes" required="no" as="element()*" select="()"/>
        <xsl:variable name="bProp" as="element()">
            <w:b w:val="true"/>
        </xsl:variable>
        <xsl:apply-templates>
            <xsl:with-param name="prmRunProps" tunnel="yes" select="($prmRunProps[not(self::w:b)],$bProp)"/>
        </xsl:apply-templates>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' hi-d/i ')]" priority="5">
        <xsl:param name="prmRunProps" tunnel="yes" required="no" as="element()*" select="()"/>
        <xsl:variable name="iProp" as="element()">
            <w:i w:val="true"/>
        </xsl:variable>
        <xsl:apply-templates>
            <xsl:with-param name="prmRunProps" tunnel="yes" select="($prmRunProps[not(self::w:i)],$iProp)"/>
        </xsl:apply-templates>
    </xsl:template>
    
    <xsl:template match="*[contains(@class, ' hi-d/sup ')]" priority="5">
        <xsl:param name="prmRunProps" tunnel="yes" required="no" as="element()*" select="()"/>
        <xsl:variable name="supProp" as="element()">
            <w:vertAlign w:val="superscript"/>
        </xsl:variable>
        <xsl:apply-templates>
            <xsl:with-param name="prmRunProps" tunnel="yes" select="($prmRunProps[not(self::w:vertAlign)],$supProp)"/>
        </xsl:apply-templates>
    </xsl:template>
    
    <xsl:template match="*[contains(@class, ' hi-d/sub ')]" priority="5">
        <xsl:param name="prmRunProps" tunnel="yes" required="no" as="element()*" select="()"/>
        <xsl:variable name="subProp" as="element()">
            <w:vertAlign w:val="subscript"/>
        </xsl:variable>
        <xsl:apply-templates>
            <xsl:with-param name="prmRunProps" tunnel="yes" select="($prmRunProps[not(self::w:vertAlign)],$subProp)"/>
        </xsl:apply-templates>
    </xsl:template>
    
    <xsl:template match="*[contains(@class, ' hi-d/line-through ')]" priority="5">
        <xsl:param name="prmRunProps" tunnel="yes" required="no" as="element()*" select="()"/>
        <xsl:variable name="subProp" as="element()">
            <w:strike w:val="true"/>
        </xsl:variable>
        <xsl:apply-templates>
            <xsl:with-param name="prmRunProps" tunnel="yes" select="($prmRunProps[not(self::w:strike)],$subProp)"/>
        </xsl:apply-templates>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' hi-d/overline ')]" priority="5">
        <xsl:call-template name="warningContinue">
            <xsl:with-param name="prmMes" select="ahf:replace($stMes2022,('%pos'),(ahf:genHistoryId(.)))"/>
        </xsl:call-template>
        <xsl:apply-templates/>
    </xsl:template>
    
    <!-- ==== END OF STYLESHEET === -->

</xsl:stylesheet>