<?xml version="1.0" encoding="UTF-8" ?>
<!--
****************************************************************
DITA to WordprocessingML Stylesheet
Module: WordprocessingML global constants for xref or link.
Copyright © 2009-2017 Antenna House, Inc. All rights reserved.
Antenna House is a trademark of Antenna House, Inc.
URL    : http://www.antennahouse.com/
E-mail : info@antennahouse.com
****************************************************************
-->
<xsl:stylesheet version="3.0" 
    xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    exclude-result-prefixes="map"
>
    <!-- Bookmark id map for whole document.
     -->
    <!-- Bookmark targets: All xref, link and topicref element that reference internal target -->
    <xsl:variable name="bookmarkTargets" as="xs:string*">
        <xsl:sequence select="$map//*[contains(@class,' map/topicref ')][starts-with(@href,'#')]/string(@href)"/>
        <xsl:sequence select="//*[contains(@class,' topic/xref ')][starts-with(@href,'#')]/string(@href)"/>
        <xsl:sequence select="//*[contains(@class,' topic/link ')][starts-with(@href,'#')]/string(@href)"/>
    </xsl:variable>

    <xsl:variable name="uniqueBookmarkTargets" as="xs:string*" select="distinct-values($bookmarkTargets)"/>

    <!-- Target elements -->
    <xsl:variable name="targetElems" as="node()*">
        <xsl:for-each select="$uniqueBookmarkTargets">
            <xsl:variable name="href" as="xs:string" select="."/>
            <xsl:variable name="topicId" as="xs:string" select="if (contains($href,'/')) then substring-before(substring($href,2),'/') else substring($href,2)"/>
            <xsl:variable name="elemId" as="xs:string" select="if (contains($href,'/')) then substring-after($href,'/') else ''"/>
            <xsl:variable name="topicElem" as="element()?" select="key('topicById', $topicId, $root)[1]"/>
            <xsl:variable name="targetElem" as="element()?" select="if (not(string($elemId))) then $topicElem else $topicElem//*[string(@id) eq $elemId][1]"/>
            <xsl:choose>
                <xsl:when test="empty($targetElem)">
                    <xsl:comment>Not Found: <xsl:value-of select="$href"/></xsl:comment>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="$targetElem"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:variable>
    
    <xsl:variable name="targetIds" as="xs:string*" select="for $elem in $targetElems return if ($elem[self::element()]) then generate-id($elem) else '' "/>

    <!-- map: key=@href value=generate-id(), target node()
         Used for xref & link to generate "REF" field
      -->
    <xsl:variable name="bookmarkTargetMap" as="map(xs:string,item()*)">
        <xsl:map>
            <xsl:for-each select="$uniqueBookmarkTargets">
                <xsl:variable name="position" as="xs:integer" select="position()"/>
                <xsl:variable name="key" as="xs:string" select="."/>
                <xsl:variable name="value" as="item()*" select="($targetIds[$position],$targetElems[$position])"/>
                <xsl:map-entry key="$key" select="$value"/>
            </xsl:for-each>
        </xsl:map>
    </xsl:variable>
    
    <xsl:variable name="targetElemsDocSeq" as="element()*" select="//*[generate-id() = $targetIds]"/>
    
    <!-- map: key=generate-id() value=position()
         Used for target elements to generate w:bookMark
      -->
    <xsl:variable name="targetElemIdAndNumberMap" as="map(xs:string,xs:integer)">
        <xsl:map>
            <xsl:for-each select="$targetElemsDocSeq">
                <xsl:map-entry key="generate-id(.)" select="position()"/>
            </xsl:for-each>
        </xsl:map>
    </xsl:variable>

</xsl:stylesheet>