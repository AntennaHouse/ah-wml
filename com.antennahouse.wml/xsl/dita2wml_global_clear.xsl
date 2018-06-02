<?xml version="1.0" encoding="UTF-8" ?>
<!--
****************************************************************
DITA to WordprocessingML Stylesheet
Module: WordprocessingML global constants.
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
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
    exclude-result-prefixes="xs map ahf"
>
    <!-- ****************************************************************************** 
           Global Text Wrapping Clear Map
           @clear is the attribute defined in ah-dita specialization to support floatfig.
           https://github.com/AntennaHouse/ah-dita
           
           1. XSL-FO defines @clear attribute for clearing text wrapping.
           2. WordProcessingML defines <w:br w:type="textWrapping" w:clear="all"/>
              for almost the same purpose.
           3. The diffrence is that:
             - In XSL-FO @clear is specified the FO that should be clear text wrapping.
             - In WordprocessingML it should be located at the last run before @clear
               is specified.
           This module defines map that specified which element should generate
           <w:br w:type="textWrapping" w:clear="XXX"/>
         ******************************************************************************-->

    <!-- Elemets that has @clear or defulted.
     -->
    <xsl:variable name="elementsThatHasClear" as="element()*">
        <xsl:sequence select="$root/descendant::*[string(@clear) = ('both','right','left')]"/>
    </xsl:variable>
    <xsl:variable name="stepsThatHaveFloatFig" as="element()*">
        <xsl:sequence select="$root/descendant::*[contains(@class,' task/step ')][*[contains(@class,'task/info ')][1]/descendant::*[contains(@class,' floatfig-d/floatfig ')][string(@float) = ('left','right')]]"/>
    </xsl:variable>
    <xsl:variable name="distinctElementsThatHasClear" as="element()*" select="$elementsThatHasClear|$stepsThatHaveFloatFig"/>    
    
    <!-- element id map that should generate <w:br w:type="textWrapping" w:clear="XXX"/>
         key:   ahf:generate-id()
         value: @float value
     -->
    <xsl:variable name="clearElemMap" as="map(xs:string,xs:string)?">
        <xsl:variable name="targetElemId" as="xs:string*">
            <xsl:for-each select="$distinctElementsThatHasClear">
                <xsl:variable name="elem" as="element()" select="."/>
                <xsl:variable name="targetCandidate" as="element()?">
                    <xsl:variable name="precedingElem" as="element()?" select="$elem/preceding-sibling::*[1]"/>
                    <xsl:sequence select="$precedingElem"/>
                </xsl:variable>
                <!--xsl:message select="'$targetCandidate=',$targetCandidate"/-->
                <xsl:choose>
                    <xsl:when test="empty($targetCandidate)">
                        <xsl:sequence select="concat('#',string(position()))"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:sequence select="ahf:generateId($targetCandidate)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:variable>
        
        <xsl:map>
            <xsl:for-each select="$targetElemId">
                <xsl:variable name="key" as="xs:string" select="."/>
                <xsl:variable name="pos" as="xs:integer" select="position()"/>
                <xsl:map-entry key="$key" select="$distinctElementsThatHasClear[$pos]/string(@clear)"/>
            </xsl:for-each>
        </xsl:map>
    </xsl:variable>

    <!-- 
     function:	judge that element is composed of floatfig only
     param:		prmElem
     return:	xs:boolean
     note:      floatfig is treated as inline and there exists such pattern as info/p/floatfig
                floatfig only element (mainly <p>) should be rejected to generate clear text wrapping WordprocessingML.
     -->
    <xsl:function name="ahf:isFloatFigOnlyElem" as="xs:boolean">
        <xsl:param name="prmElem" as="element()"/>
        <xsl:variable name="floatfig" as="element()*" select="$prmElem/descendant::*[contains(@class,' floatfig-d/floatfig ')]"/>
        <xsl:variable name="descendant" as="node()*" select="$prmElem/descendant::node()[not(ancestor-or-self::*[contains(@class,' floatfig-d/floatfig ')])]"/>
        <xsl:sequence select="empty($descendant/self::text())"/>
    </xsl:function>

    <xsl:function name="ahf:isNotFloatFigOnlyElem" as="xs:boolean">
        <xsl:param name="prmElem" as="element()"/>
        <xsl:sequence select="not(ahf:isFloatFigOnlyElem($prmElem))"/>
    </xsl:function>

    <!-- 
     function:	generate <w:br w:type="textWrapping" w:clear="XXX"/>
                if target is in $clearElemMap 
     param:		prmElem
     return:	element(w:r)*
     note:		
     -->
    <xsl:template name="ahf:genClearTextWrap" as="element(w:r)?">
        <xsl:param name="prmElem" as="element()" required="no" select="."/>
        <xsl:message select="'[ahf:genClearTextWrap] id=',ahf:generateId($prmElem)"/>
        <xsl:variable name="clearVal" as="xs:string?" select="map:get($clearElemMap,ahf:generateId($prmElem))"/>
        <xsl:if test="exists($clearVal)">
            <xsl:call-template name="getWmlObjectReplacing">
                <xsl:with-param name="prmObjName" select="'wmlClearTextWrapping'"/>
                <xsl:with-param name="prmSrc" select="('%clear-val')"/>
                <xsl:with-param name="prmDst" select="if ($clearVal = ('both','')) then 'all' else $clearVal"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>

    <xsl:template name="ahf:genClearTextWrapP" as="element(w:p)?">
        <xsl:param name="prmElem" as="element()" required="no" select="."/>
        <xsl:message select="'[ahf:genClearTextWrapP] id=',ahf:generateId($prmElem)"/>
        <xsl:variable name="clearVal" as="xs:string?" select="map:get($clearElemMap,ahf:generateId($prmElem))"/>
        <xsl:message select="if (exists($clearVal)) then 'Matched!' else 'Unmatched!'"/>
        <xsl:if test="exists($clearVal)">
            <xsl:call-template name="getWmlObjectReplacing">
                <xsl:with-param name="prmObjName" select="'wmlClearTextWrappingP'"/>
                <xsl:with-param name="prmSrc" select="('%clear-val')"/>
                <xsl:with-param name="prmDst" select="if ($clearVal = ('both','')) then 'all' else $clearVal"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    
    <!-- 
     function:	return that $prmElem is target for generate clear text wrapping: <w:br w:type="textWrapping" w:clear="XXX"/>
     param:		prmElem
     return:	xs:boolean
     note:		
     -->
    <xsl:function name="ahf:isClearTextTarget" as="xs:boolean">
        <xsl:param name="prmElem" as="element()"/>
        <xsl:sequence select="exists(map:get($clearElemMap,ahf:generateId($prmElem)))"/>
    </xsl:function>

    <!-- 
     function:	generate clear text wrapping
     param:		prmElem
     return:	w:p
     note:		Very important because this template precedes all of other templates.
     -->
    <xsl:template match="*[ahf:isClearTextTarget(.)]" priority="50">
        <xsl:next-match/>
        <xsl:call-template name="ahf:genClearTextWrapP"/>
    </xsl:template>

    <!-- 
     function:	Dump $clearElemMap
     param:		none
     return:	
     note:		
     -->
    <xsl:template name="ahf:dumpClearElemMap">
        <xsl:variable name="mapEntrySeq" as="xs:string*" select="map:for-each($clearElemMap,function($k, $v){string($k),string($v)})"/>
        <xsl:result-document href="{concat($pTempDirUrl,'ClearElemMap.xml')}" method="xml" indent="yes">
            <map>
                <xsl:for-each select="1 to count($mapEntrySeq) div 2">
                    <xsl:variable name="pos" as="xs:integer" select="position()"/>
                    <entry>
                        <xsl:attribute name="key" select="$mapEntrySeq[$pos * 2 -1]"/>
                        <xsl:attribute name="val" select="$mapEntrySeq[$pos * 2]"/>
                    </entry>
                </xsl:for-each>
            </map>
        </xsl:result-document>
    </xsl:template>
    
</xsl:stylesheet>