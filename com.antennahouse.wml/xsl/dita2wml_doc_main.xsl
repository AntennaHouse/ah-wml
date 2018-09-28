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
        <xsl:if test="$pDebugStyle">
            <xsl:call-template name="styleDump"/>
        </xsl:if>
        <xsl:if test="$pDebugSect">
            <xsl:call-template name="columnMapTreeDump"/>
            <xsl:call-template name="sectMapDump"/>
        </xsl:if>
        <xsl:if test="$pDebugClearElemMap">
            <xsl:call-template name="clearElemMapDump"/>
        </xsl:if>
        <w:document>
            <w:body>
                <!-- Make cover -->
                <!--xsl:call-template name="genCover"/-->
                
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
                        <xsl:apply-templates select="$map/*[contains(@class, ' map/topicref ')]"/>
                    </xsl:otherwise>
                </xsl:choose>
            </w:body>
        </w:document>        
    </xsl:template>
    
</xsl:stylesheet>