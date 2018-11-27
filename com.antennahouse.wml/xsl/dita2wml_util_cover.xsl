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
    
    <xsl:function name="ahf:hasCover" as="xs:boolean">
        <xsl:param name="prmMap" as="element()"/>
        <xsl:choose>
            <xsl:when test="$isBookMap">
                <xsl:sequence select="exists($map/*[contains(@class, ' bookmap/frontmatter ')]/*[contains(@class,' map/topicref ')][ahf:isCoverTopicRef(.)]) or 
                                      exists($map/*[contains(@class, ' bookmap/backmatter ')]/*[contains(@class,' map/topicref ')][ahf:isCoverTopicRef(.)])"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="exists($map/*[contains(@class, ' map/topicref ')][ahf:isCoverTopicRef(.)])"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:function name="ahf:isCoverN" as="xs:boolean">
        <xsl:param name="prmTopicRef" as="element()"/>
        <xsl:param name="prmCoverN" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="$isBookMap">
                <xsl:sequence select="exists($map/*[contains(@class, ' bookmap/frontmatter ')]/*[contains(@class,' map/topicref ')][ahf:hasOutputClassValue(.,concat('cover',$prmCoverN))])"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="exists($map/*[contains(@class, ' map/topicref ')][ahf:hasOutputClassValue(.,concat('cover',$prmCoverN))])"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!-- end of stylesheet -->
</xsl:stylesheet>
