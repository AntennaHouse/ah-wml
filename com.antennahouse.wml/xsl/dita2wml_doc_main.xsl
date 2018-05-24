<?xml version="1.0" encoding="UTF-8"?>
<!--
**************************************************************
DITA to WordprocessingML Stylesheet
Document.xml Shell Templates
**************************************************************
File Name : dita2wml_document_main.xsl
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
    function:   Document node template
    param:      none
    return:     w:document
    note:       
    -->
    <xsl:template match="/">
        <!--xsl:call-template name="styleDump"/-->
        <!--xsl:message select="concat('$cTopicTitleStyleName=','''',$cTopicTitleStyleName,'''')"/-->
        <w:document>
            <w:body>
                <!-- Make cover -->
                <!--xsl:call-template name="genCover"/-->
                
                <!-- Make toc for map -->
                <xsl:if test="$isMap and $pMakeTocForMap">
                    <!--xsl:call-template name="genMapToc"/-->
                </xsl:if>
                
                <!-- Process main contents -->
                <xsl:choose>
                    <xsl:when test="$isBookMap">
                        <xsl:apply-templates select="$map/*[contains(@class, ' bookmap/frontmatter ')]/*[contains(@class,' map/topicref ')]"/>
                        <xsl:apply-templates select="$map/*[contains(@class, ' bookmap/part ') or contains(@class, ' bookmap/chapter ')]"/>
                        <xsl:apply-templates select="$map/*[contains(@class, ' bookmap/appendices ')]/*[contains(@class, ' bookmap/appendix ')]"/>
                        <xsl:apply-templates select="$map/*[contains(@class, ' bookmap/appendix ')]"/>
                        <xsl:apply-templates select="$map/*[contains(@class, ' bookmap/backmatter ')]/*[contains(@class,' map/topicref ')]"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="$map/*[contains(@class, ' map/topicref ')]">
                            <xsl:with-param name="prmTopElement" tunnel="yes" select="'map'"/>
                        </xsl:apply-templates>
                    </xsl:otherwise>
                </xsl:choose>
                
                <!-- Make index for map -->
                <xsl:if test="$isMap and $pMakeIndexForMap and $pOutputIndex">
                    <!--xsl:call-template name="genMapIndex"/-->
                </xsl:if>
                
                <xsl:call-template name="genSingleSideSectPr"/>
            </w:body>
        </w:document>        
    </xsl:template>
    
</xsl:stylesheet>