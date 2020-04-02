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
           3. The diffrences are:
             - In XSL-FO @clear is specified the FO that should be clear text wrapping.
             - In WordprocessingML it should be located at the next of last paragraph before 
               @clear is specified.
           This module defines map that specified which element should generate
           <w:br w:type="textWrapping" w:clear="XXX"/>
         ******************************************************************************-->

    <!-- Debug parameter -->
    <xsl:param name="PRM_DEBUG_CLEAR_ELEM_MAP" as="xs:string" select="$cYes"/>
    <xsl:variable name="pDebugClearElemMap" as="xs:boolean" select="$PRM_DEBUG_CLEAR_ELEM_MAP eq $cYes"/>

    <!-- Elements that has @clear or clear text wrapping is default.
         1. Elements that has @clear attribute.
         2. task/step that has info[1]/floatfig.
         3. li that has floatfig
         4. section, example, topic (unconditionally) 
     -->
    <xsl:variable name="cmClearCandidateElements" as="element()*">
        <xsl:sequence select="$root/descendant::*[string(@clear) = ('both','right','left')][ahf:isBlockElement(.)]/preceding-sibling::*[1]"/>
        <xsl:for-each select="$root/descendant::*[@class => contains-token('task/step')][*[@class => contains-token('task/info')][1]/descendant::*[@class => contains-token('floatfig-d/floatfig')][string(@float) = ('left','right')]]">
            <xsl:variable name="step" as="element()" select="."/>
            <xsl:choose>
                <!-- preceding-sibling::*[1] is step -->
                <xsl:when test="$step/preceding-sibling::*[1][not(@class => contains-token('task/stepsection'))]">
                    <xsl:sequence select="$step/preceding-sibling::*[1]"/>
                </xsl:when>
                <!-- preceding-sibling::*[1] is stepsection that have floatfig -->
                <xsl:when test="$step/preceding-sibling::*[1][@class => contains-token('task/stepsection')][descendant::*[@class => contains-token('floatfig-d/floatfig')][string(@float) = ('left','right')]]">
                    <xsl:sequence select="$step/preceding-sibling::*[1]"/>
                </xsl:when>
                <!-- preceding-sibling::*[1] is stepsection that does not have floatfig and preceding-sibling::*[2] is step -->
                <xsl:when test="$step[preceding-sibling::*[1][@class => contains-token('task/stepsection')][descendant::*[@class => contains-token('floatfig-d/floatfig')] => empty()]][preceding-sibling::*[2]]">
                    <xsl:sequence select="$step/preceding-sibling::*[2]"/>
                </xsl:when>
                <xsl:otherwise>
                    <!-- first step -->
                    <xsl:sequence select="$step/parent::*[1]/preceding-sibling::*[1]"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
        <xsl:sequence select="$root/descendant::*[@class => contains-token('topic/li')][@class => contains-token('task/step') => not()][descendant::*[@class => contains-token('floatfig-d/floatfig')][string(@float) = ('left','right')]]/preceding-sibling::*[1]"/>
        <xsl:for-each select="$root/descendant::*[@class => contains-token('topic/dd')][descendant::*[@class => contains-token('floatfig-d/floatfig')][string(@float) = ('left','right')]]">
            <xsl:variable name="dd" select="."/>
            <xsl:if test="$dd/preceding-sibling::*[1][@class => contains-token('topic/dt')]">
                <!-- select dlentry -->
                <xsl:sequence select="$dd/parent::*/preceding-sibling::*[1]"/>
            </xsl:if>
        </xsl:for-each>
        <xsl:variable name="targetClass" as="xs:string*" select="('topic/topic','topic/section','topic/example','task/stepsection', 'topic/related-links')"/>
        <xsl:variable name="targetElements" as="element()*">
            <xsl:variable name="clearCandidates" as="element()*" select="$root/descendant::*[@class => ahf:seqContainsToken($targetClass)]"/>
            <xsl:for-each select="$clearCandidates">
                <xsl:variable name="clearCandidate" as="element()" select="."/>
                <xsl:variable name="targetElem" select="if ($clearCandidate[@class => contains-token('topic/topic')]) then $clearCandidate else $clearCandidate/preceding-sibling::*[1]"/>
                <xsl:sequence select="$targetElem"/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:sequence select="$targetElements"/>
    </xsl:variable>

    <xsl:variable name="cmDistinctClearCandidateElements" as="element()*" select="$cmClearCandidateElements|()"/>    
    
    <!-- element id map that should generate <w:br w:type="textWrapping" w:clear="XXX"/>
         key:   ahf:generate-id()
         value: @float value
     -->
    <xsl:variable name="clearElemMap" as="map(xs:string,xs:string)">
        <xsl:map>
            <xsl:for-each select="$cmDistinctClearCandidateElements">
                <xsl:variable name="key" as="xs:string" select="ahf:generateId(.)"/>
                <xsl:variable name="pos" as="xs:integer" select="position()"/>
                <xsl:map-entry key="$key" select="$cmDistinctClearCandidateElements[$pos]/string(@clear)"/>
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
        <xsl:variable name="floatfig" as="element()*" select="$prmElem/descendant::*[@class => contains-token('floatfig-d/floatfig')]"/>
        <xsl:variable name="descendant" as="node()*" select="$prmElem/descendant::node()[not(ancestor-or-self::*[@class => contains-token('floatfig-d/floatfig')])]"/>
        <xsl:sequence select="empty($descendant/self::text())"/>
    </xsl:function>

    <xsl:function name="ahf:isNotFloatFigOnlyElem" as="xs:boolean">
        <xsl:param name="prmElem" as="element()"/>
        <xsl:sequence select="not(ahf:isFloatFigOnlyElem($prmElem))"/>
    </xsl:function>

    <!-- 
     function:	generate <w:br w:type="textWrapping" w:clear="XXX"/>
                if target is in $clearElemMap 
     param:		prmClearElem(tunnel)
     return:	element(w:r)*
     note:		Used only for <p>
     -->
    <xsl:template name="ahf:genClearTextWrapR" as="element(w:r)?">
        <xsl:param name="prmP" as="element()" required="no" select="."/>
        <xsl:param name="prmClearElem" as="element()?" tunnel="yes" required="no"  select="()"/>
        <xsl:param name="prmClearVal" as="xs:string" tunnel="yes" required="no" select="''"/>
        <xsl:choose>
            <xsl:when test="$prmClearElem is $prmP">
                <xsl:call-template name="getWmlObjectReplacing">
                    <xsl:with-param name="prmObjName" select="'wmlClearTextWrappingR'"/>
                    <xsl:with-param name="prmSrc" select="('%clear-val')"/>
                    <xsl:with-param name="prmDst" select="if ($prmClearVal = ('both','')) then 'all' else $prmClearVal"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- 
     function:	generate <w:br w:type="textWrapping" w:clear="XXX"/> with w:p
                if target is in $clearElemMap 
     param:		prmClearElem(tunnel)
     return:	element(w:r)*
     note:		Used for element except for <p>
     -->
    <xsl:template name="ahf:genClearTextWrapP" as="element(w:p)?">
        <xsl:param name="prmClearElem" as="element()" required="no" select="."/>
        <xsl:variable name="clearVal" as="xs:string" select="string(map:get($clearElemMap,ahf:generateId($prmClearElem)))"/>
        <xsl:call-template name="getWmlObjectReplacing">
            <xsl:with-param name="prmObjName" select="'wmlClearTextWrappingP'"/>
            <xsl:with-param name="prmSrc" select="('%clear-val')"/>
            <xsl:with-param name="prmDst" select="if ($clearVal = ('both','')) then 'all' else $clearVal"/>
        </xsl:call-template>
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
                If this template is overridden from other plug-in, the template should use $xsl:apply-imports
                to prevent multiple clear text wrapping generation.
     -->
    <xsl:template match="*[ahf:isClearTextTarget(.)]" priority="50">
        <xsl:param name="prmProcessClearTextMap" as="xs:boolean" tunnel="yes" required="no" select="true()"/>
        <xsl:next-match/>
        <xsl:if test="$prmProcessClearTextMap">
            <xsl:call-template name="ahf:genClearTextWrapP"/>
        </xsl:if>
    </xsl:template>

    <!-- 
     function:	dump clearElemMap by sequence
     param:		none
     return:	debugClear.xml
     note:      
     -->
    <xsl:template name="clearElemMapDump">
        <xsl:variable name="clearElemSeq" as="element()*">
            <xsl:for-each select="$cmDistinctClearCandidateElements">
                <xsl:variable name="xpath" as="xs:string" select="ahf:getNodeXPathStr(.)"/>
                <xsl:variable name="pos" as="xs:integer" select="position()"/>
                <xsl:variable name="clear" as="xs:string" select="$cmDistinctClearCandidateElements[$pos]/string(@clear)"/>
                <entry seq="{$pos}" xpath="{$xpath}" clear="{$clear}"/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:result-document href="{concat($pTempDirUrl,'/DebugClearElemMap.xml')}" encoding="UTF-8" indent="yes">
            <map>
                <xsl:for-each select="$clearElemSeq">
                    <xsl:sort select="@seq" data-type="number"/>
                    <xsl:copy-of select="."/>
                </xsl:for-each>
            </map>
        </xsl:result-document>
    </xsl:template>

</xsl:stylesheet>
