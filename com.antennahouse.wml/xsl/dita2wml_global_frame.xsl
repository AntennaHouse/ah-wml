<?xml version="1.0" encoding="UTF-8" ?>
<!--
****************************************************************
DITA to WordprocessingML Stylesheet
Module: WordprocessingML global constants for frame setting.
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
    exclude-result-prefixes="xs ahf map"
>
    <!-- This module defines maps for implementing DITA @frame attribute
     -->
    
    
    <!-- Frame attribute value -->
    <xsl:variable name="frameVal" as="xs:string+" select="('top','bottom','topbot','all','sides')"/>
    
    <!-- Frame targets: All fig (except floatfig) lines, pre. (table and simpletable are implemented in another way) -->
    <xsl:variable name="frameTargets" as="element()*">
        <xsl:sequence select="$root/*[contains(@class,' topic/topic ')]/descendant::*[not(contains(@class,' topic/fig '))][not(contains(@class,' floatfig-d/floatfig '))][string(@frame) = $frameVal]"/>
        <xsl:sequence select="$root/*[contains(@class,' topic/topic ')]/descendant::*[not(contains(@class,' topic/lines '))][string(@frame) = $frameVal]"/>
        <xsl:sequence select="$root/*[contains(@class,' topic/topic ')]/descendant::*[not(contains(@class,' topic/pre '))][string(@frame) = $frameVal]"/>
    </xsl:variable>

    <xsl:variable name="uniqueFrameTargets" as="element()" select="$frameTargets|()"/>

    <!-- WebSetting.xml w:div/@w:val base -->
    <xsl:variable name="divIdBase" as="xs:integer">
        <xsl:call-template name="getVarValueAsInteger">
            <xsl:with-param name="prmVarName" select="'DivldIdBase'"/>
        </xsl:call-template>
    </xsl:variable>

    <!-- map: key=ahf:generateId() 
              value=w:div/@w:id, 0 or 1 (has ancestor fig/@frame?)
         Used to generate w:divId/@w:val for w:pPr or w:trPr in main document generation.
     -->
    <xsl:variable name="frameTargetIdAndNumberMap" as="map(xs:string,xs:integer+)">
        <xsl:map>
            <xsl:for-each select="$uniqueFrameTargets">
                <xsl:variable name="hasAncestorFigWithFrame" as="xs:boolean">
                    <xsl:choose>
                        <xsl:when test="ancestor::*[contains(@class,' topic/fig ')][[string(@frame) = $frameVal]]">
                            <xsl:sequence select="true()"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:sequence select="false()"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:map-entry key="ahf:generateId(.)" select="(position() + $divIdBase,xs:integer($hasAncestorFigWithFrame))"/>
            </xsl:for-each>
        </xsl:map>
    </xsl:variable>
    
    <!-- map: key=w:div/@w:id
              value=@frame value (top, bottom, topbot,all, sides
         Used to generate WebSetting.xml w:divs/w:div entry
         An div border is supposed only one level. Nested @frame such as fig/codeblock with @frame attribute for every element is not supported.
     -->
    <xsl:variable name="frameTargetIdAndFrameClassMap" as="map(xs:decimal, xs:string)">
        <xsl:map>
            <xsl:for-each select="$uniqueFrameTargets">
                <xsl:map-entry key="position() + $divIdBase" select="string(./@frame)"/>
            </xsl:for-each>
        </xsl:map>
    </xsl:variable>

</xsl:stylesheet>
