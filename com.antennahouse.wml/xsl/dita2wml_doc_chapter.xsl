<?xml version="1.0" encoding="UTF-8"?>
<!--
**************************************************************
DITA to WordprocessingML Stylesheet
Document.xml Chapter Templates
**************************************************************
File Name : dita2wml_document_chapter.xsl
**************************************************************
Copyright © 2009-2017 Antenna House, Inc. All rights reserved.
Antenna House is a trademark of Antenna House, Inc.
URL : http://www.antennahouse.com/
**************************************************************
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
    exclude-result-prefixes="xs ahf"
    version="3.0">

    <!-- 
     function:	Chapter/part topicref processing
     param:		none
     return:	
     note:		none
     -->
    <xsl:template match="*[contains(@class,' bookmap/chapter ')]" priority="5">
        <xsl:next-match>
            <xsl:with-param name="prmTopElement" tunnel="yes" select="'chapter'"/>
        </xsl:next-match>
    </xsl:template>
    
    <xsl:template match="*[contains(@class,' bookmap/part ')]" priority="5">
        <xsl:next-match>
            <xsl:with-param name="prmTopElement" tunnel="yes" select="'part'"/>
        </xsl:next-match>
    </xsl:template>

    <!-- 
     function:	Genral topicref processing
     param:		none
     return:	
     note:		none
     -->
    <xsl:template match="*[contains(@class,' map/topicref ')][exists(@href)]">
        <xsl:variable name="topicRef" select="."/>
        <!-- get topic from @href -->
        <xsl:variable name="topic" select="ahf:getTopicFromTopicRef($topicRef)" as="element()?"/>
        <xsl:variable name="topicRefLevel" select="ahf:getTopicRefLevel($topicRef)" as="xs:integer"/>
        
        <xsl:choose>
            <xsl:when test="exists($topic)">
                <!-- Process contents -->
                <xsl:apply-templates select="$topic">
                    <xsl:with-param name="prmTopicRef"       tunnel="yes" select="$topicRef"/>
                    <xsl:with-param name="prmTopicRefLevel"  tunnel="yes" select="$topicRefLevel"/>
                    <xsl:with-param name="prmTopic"          tunnel="yes" select="$topic"/>
                    <xsl:with-param name="prmIndentLevel"    tunnel="yes" select="0"/>
                    <xsl:with-param name="prmExtraIndent"    tunnel="yes" select="0"/>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="warningContinue">
                    <xsl:with-param name="prmMes" 
                        select="ahf:replace($stMes070,('%href','%file'),(string(@href),string(@xtrf)))"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
        
        <!-- Nested topicref processing -->
        <xsl:apply-templates select="child::*[contains(@class,' map/topicref ')]"/>
        
    </xsl:template>

    <xsl:template match="*[contains(@class,' map/topicref ')][empty(@href)]">
        <xsl:variable name="topicRef" select="."/>
        
        <xsl:choose>
            <xsl:when test="exists($topicRef/*[contains(@class,' map/topicmeta ')]/*[contains(@class,' topic/navtitle ')]) or exists(@navtitle)">
                <!-- Process title -->
                <xsl:call-template name="genTopicHeadTitle">
                    <xsl:with-param name="prmTopicRef"       select="$topicRef"/>
                    <xsl:with-param name="prmIndentLevel"    tunnel="yes" select="0"/>
                    <xsl:with-param name="prmExtraIndent"    tunnel="yes" select="0"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <!--xsl:call-template name="warningContinue">
                    <xsl:with-param name="prmMes" 
                        select="ahf:replace($stMes070,('%href','%file'),(string(@href),string(@xtrf)))"/>
                </xsl:call-template-->
            </xsl:otherwise>
        </xsl:choose>
        
        <!-- Nested topicref processing -->
        <xsl:apply-templates select="child::*[contains(@class,' map/topicref ')]"/>
        
    </xsl:template>
    

    <!-- 
     function:	Genral topic processing
     param:		none
     return:	
     note:		related-links is not implemented yet!
     -->
    <xsl:template match="*[contains(@class, ' topic/topic ')]">
        <xsl:comment> topic @id="<xsl:value-of select="@id"/>"</xsl:comment>
        <xsl:apply-templates select="*[contains(@class, ' topic/title ')]"/>    
        <xsl:apply-templates select="*[contains(@class, ' topic/shortdesc ')] | *[contains(@class, ' topic/abstract ')]"/>
        <xsl:apply-templates select="*[contains(@class, ' topic/body ')]"/>
        <!--xsl:apply-templates select="*[contains(@class, ' topic/related-links ')]"/-->
        <!-- Nesteed topic processing -->
        <xsl:apply-templates select="*[contains(@class, ' topic/topic ')]"/>
        <!--xsl:if test="empty(parent::*[contains(@class, ' topic/topic ')])">
            <xsl:copy-of select="$body-section"/>
        </xsl:if-->
    </xsl:template>

    <!-- ==== END OF STYLESHEET === -->

</xsl:stylesheet>