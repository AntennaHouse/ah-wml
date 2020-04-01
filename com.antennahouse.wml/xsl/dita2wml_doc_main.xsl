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
                <xsl:choose>
                    <xsl:when test="ahf:hasCover12($map) and $pSupportCover">
                        <xsl:call-template name="genCoverN">
                            <xsl:with-param name="prmMap" select="$map"/>
                            <xsl:with-param name="prmCoverN" select="($cCover1,$cCover2)"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <!--xsl:call-template name="genNormalCover"/-->
                    </xsl:otherwise>
                </xsl:choose>
                
                <!-- Process main contents -->
                <xsl:choose>
                    <xsl:when test="$isBookMap">
                        <xsl:apply-templates select="$map/*[@class => contains-token('bookmap/frontmatter')]/*[@class => contains-token('map/topicref')][. => ahf:isNotCoverTopicRef()]"/>
                        <xsl:apply-templates select="$map/*[@class => contains-token('bookmap/part') or @class => contains-token('bookmap/chapter')]"/>
                        <xsl:apply-templates select="$map/*[@class => contains-token('bookmap/appendices')]/*[@class => contains-token('bookmap/appendix')]"/>
                        <xsl:apply-templates select="$map/*[@class => contains-token('bookmap/appendix')]"/>
                        <xsl:apply-templates select="$map/*[@class => contains-token('bookmap/backmatter')]/*[@class => contains-token('map/topicref')][. => ahf:isNotCoverTopicRef()]"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="$map/*[@class => contains-token('map/topicref ')][ahf:isNotCoverTopicRef(.)]"/>
                    </xsl:otherwise>
                </xsl:choose>

                <!-- Make cover -->
                <xsl:if test="ahf:hasCover34($map) and $pSupportCover">
                    <xsl:call-template name="genCoverN">
                        <xsl:with-param name="prmMap" select="$map"/>
                        <xsl:with-param name="prmCoverN" select="($cCover3,$cCover4)"/>
                    </xsl:call-template>
                </xsl:if>
            </w:body>
        </w:document>        
    </xsl:template>
    
</xsl:stylesheet>