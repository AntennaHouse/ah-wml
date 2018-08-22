<?xml version="1.0" encoding="UTF-8"?>
<!--
**************************************************************
DITA to WordprocessingML Stylesheet
Document.xml Common Templates
**************************************************************
File Name : dita2wml_doc_common.xsl
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

    <!-- 
     function:	General template for unsupported element
     param:		
     return:	empty-sequence
     note:		This template aims to detect unsupported elements.
     -->
    <xsl:template match="*" priority="-5">
        <xsl:call-template name="warningContinue">
            <xsl:with-param name="prmMes" select="ahf:replace($stMes001,('%elem','%file'),(name(.),string(@xtrf)))"/>
        </xsl:call-template>
    </xsl:template>

    <!-- 
     function:	General template for getting contents
     param:		none
     return:	
     note:		This template ignores indexterm, bookmark generation, footnotes.
                Used for generating field results.
     -->
    <xsl:template name="getContentsRestricted" as="element(w:r)*">
        <xsl:param name="prmElem" as="node()*" required="yes"/>
        <xsl:param name="prmRunProps" tunnel="yes" required="yes"/>
        
        <xsl:choose>
            <xsl:when test="$prmElem instance of element()">
                <xsl:apply-templates select="$prmElem/node()">
                    <xsl:with-param name="prmRunProps"       tunnel="yes" select="$prmRunProps"/>
                    <xsl:with-param name="prmSkipBookmark"   tunnel="yes" select="true()"/>
                    <xsl:with-param name="prmSkipFn"         tunnel="yes" select="true()"/>
                    <xsl:with-param name="prmSkipIndexTerm"  tunnel="yes" select="true()"/>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="$prmElem">
                    <xsl:with-param name="prmRunProps"       tunnel="yes" select="$prmRunProps"/>
                    <xsl:with-param name="prmSkipBookmark"   tunnel="yes" select="true()"/>
                    <xsl:with-param name="prmSkipFn"         tunnel="yes" select="true()"/>
                    <xsl:with-param name="prmSkipIndexTerm"  tunnel="yes" select="true()"/>
                </xsl:apply-templates>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>
    

    <!-- ==== END OF STYLESHEET === -->

</xsl:stylesheet>