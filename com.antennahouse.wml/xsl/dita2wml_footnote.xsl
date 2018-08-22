<?xml version="1.0" encoding="UTF-8"?>
<!--
**************************************************************
DITA to WordprocessingML Stylesheet
word/footnote.xml Templates
**************************************************************
File Name : dita2wml_footnote.xsl
**************************************************************
Copyright © 2009-2018 Antenna House, Inc. All rights reserved.
Antenna House is a trademark of Antenna House, Inc.
URL : http://www.antennahouse.com/
**************************************************************
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
    xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
    exclude-result-prefixes="xs ahf map"
    version="3.0">

    <!-- 
     function:	Generate footnote.xml
     param:		
     return:	w:footnotes
     note:		w:footnote/@id is obtained from $fnIdMap.
     -->
    <xsl:template match="/">
        <w:footnotes>
            <xsl:call-template name="getWmlObject">
                <xsl:with-param name="prmObjName" select="'wmlFootnoteSeparator'"/>
            </xsl:call-template>
            <xsl:call-template name="getWmlObject">
                <xsl:with-param name="prmObjName" select="'wmlFootnoteContinuationSeparator'"/>
            </xsl:call-template>
            
            <xsl:variable name="fns" select="/descendant::*[contains(@class,' topic/fn ')]" as="element()*"/>

            <!-- Generate w:footnote entry -->
            <xsl:for-each select="$fns">
                <xsl:variable name="fn" as="element()" select="."/>
                <xsl:variable name="child" as="element()*" select="$fn/*"/>
                <xsl:variable name="topic" as="element()" select="$fn/ancestor::*[contains(@class,' topic/topic ')][last()]"/>
                <xsl:variable name="topicRef" as="element()?" select="ahf:getTopicRef($topic)"/>
                <xsl:assert test="exists($topicRef)" select="'[footnote] Failed to get topicref from topic. topic=',string($topic/@id),' title=',string($topic/*[contains(@class,' topic/title ')])"/>
                <xsl:variable name="fnId" as="xs:integer" select="map:get($fnIdMap,ahf:generateId($fn))"/>
                <w:footnote w:id="{string($fnId)}">
                    <!-- First element must be p -->
                    <w:p>
                        <w:pPr>
                            <w:pStyle w:val="{ahf:getStyleIdFromName('footnote text')}"/>
                        </w:pPr>
                        <w:r>
                            <xsl:choose>
                                <xsl:when test="$fn/@callout">
                                    <w:t><xsl:value-of select="$fn/@callout"/></w:t>
                                </xsl:when>
                                <xsl:otherwise>
                                    <w:footnoteRef/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </w:r>
                        <w:r>
                            <w:t xml:space="preserve">&#xA0;</w:t>
                        </w:r>
                        <xsl:apply-templates select="$child[1]/node()">
                            <xsl:with-param name="prmTopicRef" tunnel="yes" select="$topicRef"/>
                            <xsl:with-param name="prmIndentLevel" tunnel="yes" select="0"/>
                            <xsl:with-param name="prmExtraIndent" tunnel="yes" select="0"/>
                        </xsl:apply-templates>
                    </w:p>
                    <xsl:apply-templates select="$child[position() gt 1]">
                        <xsl:with-param name="prmTopicRef" tunnel="yes" select="$topicRef"/>
                        <xsl:with-param name="prmIndentLevel" tunnel="yes" select="0"/>
                        <xsl:with-param name="prmExtraIndent" tunnel="yes" select="0"/>
                    </xsl:apply-templates>
                </w:footnote>
            </xsl:for-each>
        </w:footnotes>
    </xsl:template>

    <!-- END OF STYLESHEET -->

</xsl:stylesheet>