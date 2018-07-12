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
    xmlns:ct="http://schemas.openxmlformats.org/package/2006/content-types"
    xmlns:r="http://schemas.openxmlformats.org/package/2006/relationships"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    exclude-result-prefixes="xs ahf map"
>
    <!-- This module defines maps, templates for implementing DITA @frame attribute.
         @frame attribute is used in fig, lines, pre (and its specialization elements).
         Table and simple table also has @frame sttributes but they are implemented in table building.
         NOTE:
         - DITA 1.3 specification allows nested fig element authoring. An fig can contain simpletable. An stentry can contain fig.
         - Elements that has @frame attribute can be nested. fig/@frame contains lines/@frame or pre/@frame.
         - These nesting is expressed using w:divsChild element.
     -->

    <!-- Frame attribute value -->
    <xsl:variable name="frameVal" as="xs:string+" select="('top','bottom','topbot','all','sides')"/>

    <!-- 
     function:	Judge elements that have effective @frame value
     param:		prmElem
     return:	xs:boolean
     note:		Return that element has effective @feame attribute
     -->
    <xsl:function name="ahf:isFrameAttrElem" as="xs:boolean">
        <xsl:param name="prmElem" as="element()"/>
        <!--xsl:sequence select="exists($prmElem/self::*[ahf:seqContains(@class,(' topic/fig ',' topic/lines ',' topic/pre '))][not(contains(@class,' floatfig-d/floatfig '))][[string(@frame) = $frameVal]])"/-->
        <xsl:variable name="classAttr" as="xs:string" select="string($prmElem/@class)"/>   
        <xsl:variable name="frameAttr" as="xs:string" select="string($prmElem/@frame)"/>
        <xsl:sequence select="ahf:seqContains($classAttr,(' topic/fig ',' topic/lines ',' topic/pre ')) and not(contains($classAttr,' floatfig-d/floatfig ')) and ($frameAttr = $frameVal)"/>
    </xsl:function>

    <!-- Frame targets: All fig (except floatfig) lines, pre. (table and simpletable are implemented in another way) -->
    <xsl:variable name="frameTargets" as="element()*">
        <xsl:sequence select="$root/*[contains(@class,' topic/topic ')]/descendant::*[ahf:isFrameAttrElem(.)]"/>
    </xsl:variable>

    <xsl:variable name="uniqueFrameTargets" as="element()*" select="$frameTargets|()"/>

    <!-- WebSetting.xml w:div/@w:val base -->
    <xsl:variable name="divIdBase" as="xs:integer">
        <xsl:call-template name="getVarValueAsInteger">
            <xsl:with-param name="prmVarName" select="'DivldIdBase'"/>
        </xsl:call-template>
    </xsl:variable>

    <!-- map: key=ahf:generateId() 
              value=w:div/@w:id, 0 or 1 (has ancestor element/@frame?), 0 or 1 (has descendant element/@frame)
         Used to generate w:divId/@w:val for w:pPr or w:trPr in main document generation.
     -->
    <xsl:variable name="frameInfoMap" as="map(xs:string,xs:integer+)">
        <xsl:map>
            <xsl:for-each select="$uniqueFrameTargets">
                <xsl:variable name="hasAncestorFigWithFrame" as="xs:boolean">
                    <xsl:choose>
                        <xsl:when test="ancestor::*[ahf:isFrameAttrElem(.)]">
                            <xsl:sequence select="true()"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:sequence select="false()"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="hasDescendantFigWithFrame" as="xs:boolean">
                    <xsl:choose>
                        <xsl:when test="descendant::*[ahf:isFrameAttrElem(.)]">
                            <xsl:sequence select="true()"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:sequence select="false()"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:map-entry key="ahf:generateId(.)" select="(xs:integer(position() + $divIdBase),xs:integer($hasAncestorFigWithFrame),xs:integer($hasDescendantFigWithFrame))"/>
            </xsl:for-each>
        </xsl:map>
    </xsl:variable>
    
    <!-- map: key=w:div/@w:id
              value=@frame value (top, bottom, topbot,all, sides
         Used to generate WebSetting.xml w:divs/w:div entry
         An div border is supposed only one level. Nested @frame such as fig/codeblock with @frame attribute for every element is not supported.
     -->
    <xsl:variable name="frameClassInfoMap" as="map(xs:integer, xs:string)">
        <xsl:map>
            <xsl:for-each select="$uniqueFrameTargets">
                <xsl:map-entry key="position() + $divIdBase" select="if (exists(@frame)) then string(./@frame) else 'all'"/>
            </xsl:for-each>
        </xsl:map>
    </xsl:variable>
    
    <!-- 
     function:	Generate webSettting.xml's w:div
     param:		prmElem DITA element that has effective @frame attribute
                prmIsTop switch to indicate top level elements processing
     return:	element(w:div)*
     note:		Recursively call itself to generate nested w:divsChild/w:w:div 
     -->
    <xsl:template name="genWebSettingDiv" as="element(w:div)*">
        <xsl:param name="prmElem" as="element()" required="yes"/>
        <xsl:param name="prmIsTop" as="xs:boolean" required="yes"/>
        
        <xsl:variable name="elemId" as="xs:string" select="ahf:generateId($prmElem)"/>
        <xsl:variable name="frameInfo" as="item()*" select="map:get($frameInfoMap,$elemId)"/>
        <xsl:assert test="exists($frameInfo)" select="'[genWebSettingDiv] Cannot get frameInfo from map id=',$elemId"/>
        <xsl:variable name="id" as="xs:integer" select="$frameInfo[1]"/>
        <xsl:variable name="hasAncestor" as="xs:boolean" select="xs:integer($frameInfo[2]) eq 1"/>        
        <xsl:variable name="hasDescendant" as="xs:boolean" select="xs:integer($frameInfo[3]) eq 1"/>
        <xsl:choose>
            <xsl:when test="(not($hasAncestor) and $prmIsTop) or not($prmIsTop)">
                <xsl:variable name="frameClassInfo" as="item()*" select="map:get($frameClassInfoMap,$id)"/>
                <xsl:assert test="exists($frameClassInfo)" select="'[genWebSettingDiv] Cannot get frameClassInfo from map id=',$elemId"/>
                <xsl:variable name="frameClass" as="xs:string"  select="xs:string($frameClassInfo[1])"/>
                <xsl:variable name="leftStyle"  as="xs:string"   select="if ($frameClass = ('sides','all')) then 'solid' else 'none'"/>
                <xsl:variable name="rightStyle" as="xs:string"   select="if ($frameClass = ('sides','all')) then 'solid' else 'none'"/>
                <xsl:variable name="topStyle"  as="xs:string"   select="if ($frameClass = ('top','topbot','all')) then 'solid' else 'none'"/>
                <xsl:variable name="bottomStyle" as="xs:string"  select="if ($frameClass = ('bottom','topbot','all')) then 'solid' else 'none'"/>
                <xsl:variable name="divsChild" as="element()">
                    <xsl:choose>
                        <xsl:when test="$hasDescendant">
                            <xsl:variable name="divs" as="document-node()">
                                <xsl:document>
                                    <xsl:for-each select="$prmElem/*[ahf:isFrameAttrElem(.)]">
                                        <xsl:call-template name="genWebSettingDiv">
                                            <xsl:with-param name="prmElem" select="."/>
                                            <xsl:with-param name="prmIsTop" select="false()"/>
                                        </xsl:call-template>                                        
                                    </xsl:for-each>
                                </xsl:document>
                            </xsl:variable>
                            <xsl:call-template name="getWmlObjectReplacing">
                                <xsl:with-param name="prmObjName" select="'wmlDivsChild'"/>
                                <xsl:with-param name="prmSrc" select="('node:div')"/>
                                <xsl:with-param name="prmDst" select="($divs)"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:sequence select="$cElemNull"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:call-template name="getWmlObjectReplacing">
                    <xsl:with-param name="prmObjName" select="'wmlDiv'"/>
                    <xsl:with-param name="prmSrc" select="('%id','%border-top-style', '%border-bottom-style', '%border-left-style', '%border-right-style','node:divsChild')"/>
                    <xsl:with-param name="prmDst" select="(string($id),$topStyle,$bottomStyle,$leftStyle,$rightStyle,$divsChild)"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise/>
        </xsl:choose>
    </xsl:template>

    <!-- 
     function:	Generate webSettting.xml/w:divs
     param:		none
     return:	element(w:divs)
     note:		Used to generate word/webSetting.xml that defines HTML equivalent border/padding/margin
     -->
    <xsl:template name="genWebSettingDivs" as="element(w:divs)">
        <xsl:variable name="div" as="node()">
            <xsl:variable name="divsFromFrameTargets" as="element(w:div)*">
                <xsl:for-each select="$uniqueFrameTargets">
                    <xsl:call-template name="genWebSettingDiv">
                        <xsl:with-param name="prmElem" select="."/>
                        <xsl:with-param name="prmIsTop" select="true()"/>
                    </xsl:call-template>
                </xsl:for-each>
            </xsl:variable>
            <xsl:choose>
                <xsl:when test="exists($divsFromFrameTargets)">
                    <xsl:document>
                        <xsl:copy-of select="$divsFromFrameTargets"/>
                    </xsl:document>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="$cElemNull"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:call-template name="getWmlObjectReplacing">
            <xsl:with-param name="prmObjName" select="'wmlDivs'"/>
            <xsl:with-param name="prmSrc" select="('node:div')"/>
            <xsl:with-param name="prmDst" select="($div)"/>
        </xsl:call-template>
    </xsl:template>

</xsl:stylesheet>
