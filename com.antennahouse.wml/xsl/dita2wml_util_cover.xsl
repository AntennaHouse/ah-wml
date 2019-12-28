<?xml version="1.0" encoding="UTF-8" ?>
<!--
**************************************************************
DITA to WordprocessingML Stylesheet
Utility Templates
**************************************************************
File Name : dita2wml_util_cover.xsl
**************************************************************
Copyright © 2009-2018 Antenna House, Inc. All rights reserved.
Antenna House is a trademark of Antenna House, Inc.
URL : http://www.antennahouse.com/
**************************************************************
-->

<xsl:stylesheet version="3.0" 
	xmlns:fo="http://www.w3.org/1999/XSL/Format" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
 	xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
 	xmlns:ahd="http://www.antennahouse.com/names/XSLT/Debugging"
 	exclude-result-prefixes="xs ahf" >

    <!--
    ===============================================
     DITA Cover Utility Templates
    ===============================================
    -->

    <!-- 
     function:	Return topicref is for cover 
     param:		prmTopicRef
     return:	xs:boolean
     note:		
     -->
    <xsl:function name="ahf:isCoverTopicRef" as="xs:boolean">
        <xsl:param name="prmTopicRef" as="element()"/>
        <xsl:sequence select="ahf:hasOneOfOutputClassValue($prmTopicRef,$coverOutputClassValue)"/>
    </xsl:function>

    <xsl:function name="ahf:isNotCoverTopicRef" as="xs:boolean">
        <xsl:param name="prmTopicRef" as="element()?"/>
        <xsl:sequence select="not(ahf:isCoverTopicRef($prmTopicRef))"/>
    </xsl:function>

    <!-- 
     function:	Return map has the topicref is for cover 
     param:		prmMap
     return:	xs:boolean
     note:		
     -->
    <xsl:function name="ahf:hasCoverN" as="xs:boolean">
        <xsl:param name="prmMap" as="element()"/>
        <xsl:param name="prmCoverN" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="$isBookMap">
                <xsl:sequence select="exists($map/*[contains(@class, ' bookmap/frontmatter ')]/*[@class => contains-token('map/topicref')][ahf:isCoverN(.,$prmCoverN)]) or 
                    exists($map/*[contains(@class, ' bookmap/backmatter ')]/*[@class => contains-token('map/topicref')][ahf:isCoverN(.,$prmCoverN)])"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="exists($map/*[contains(@class, ' map/topicref ')][ahf:isCoverN(.,$prmCoverN)])"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="ahf:hasCover12" as="xs:boolean">
        <xsl:param name="prmMap" as="element()"/>
        <xsl:choose>
            <xsl:when test="$isBookMap">
                <xsl:sequence select="exists($map/*[contains(@class, ' bookmap/frontmatter ')]/*[@class => contains-token('map/topicref')][ahf:isCoverN(.,$cCover1) or ahf:isCoverN(.,$cCover2)]) or 
                    exists($map/*[contains(@class, ' bookmap/backmatter ')]/*[@class => contains-token('map/topicref')][ahf:isCoverN(.,$cCover1) or ahf:isCoverN(.,$cCover2)])"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="exists($map/*[contains(@class, ' map/topicref ')][ahf:isCoverN(.,$cCover1) or ahf:isCoverN(.,$cCover2)])"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:function name="ahf:hasCover34" as="xs:boolean">
        <xsl:param name="prmMap" as="element()"/>
        <xsl:choose>
            <xsl:when test="$isBookMap">
                <xsl:sequence select="exists($map/*[contains(@class, ' bookmap/frontmatter ')]/*[@class => contains-token('map/topicref')][ahf:isCoverN(.,$cCover3) or ahf:isCoverN(.,$cCover4)]) or 
                    exists($map/*[contains(@class, ' bookmap/backmatter ')]/*[@class => contains-token('map/topicref')][ahf:isCoverN(.,$cCover3) or ahf:isCoverN(.,$cCover4)])"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="exists($map/*[contains(@class, ' map/topicref ')][ahf:isCoverN(.,$cCover3) or ahf:isCoverN(.,$cCover4)])"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="ahf:isCoverN" as="xs:boolean">
        <xsl:param name="prmTopicRef" as="element()"/>
        <xsl:param name="prmCoverN" as="xs:string"/>
        <xsl:sequence
            select="exists($prmTopicRef[ahf:hasOutputClassValue(., $prmCoverN)])"/>
    </xsl:function>
    
    <!-- end of stylesheet -->
</xsl:stylesheet>
