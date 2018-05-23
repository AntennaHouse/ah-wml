<?xml version="1.0" encoding="UTF-8" ?>
<!--
**************************************************************
DITA to WordprocessingML Stylesheet
Utility Templates
**************************************************************
File Name : dita2wml_dita_util.xsl
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
     DITA Utility Templates
    ===============================================
    -->
    
    <!-- 
      ============================================
         toc utility
      ============================================
    -->
    <!--
    function: isToc Utility
    param: prmElement
    note: Return boolena that parameter should add toc or not.
    -->
    <xsl:function name="ahf:isToc" as="xs:boolean">
        <xsl:param name="prmValue" as ="element()"/>
        
        <xsl:sequence select="not(ahf:isTocNo($prmValue))"/>
    </xsl:function>
    
    <!-- 
     function:	Check @toc="no" 
     param:		prmTopicRef
     return:	xs:boolean
     note:		
     -->
    <xsl:function name="ahf:isTocNo" as="xs:boolean">
        <xsl:param name="prmTopicRef" as="element()"/>
        <xsl:choose>
            <xsl:when test="string($prmTopicRef/@toc) eq 'no'">
                <xsl:sequence select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <!-- 
     function:	Get topic from topicref 
     param:		prmTopicRef
     return:	xs:element?
     note:		
     -->
    <xsl:function name="ahf:getTopicFromTopicRef" as="element()?">
        <xsl:param name="prmTopicRef" as="element()"/>
        <xsl:variable name="id" select="substring-after($prmTopicRef/@href, '#')" as="xs:string"/>
        <xsl:variable name="topicContent" select="if (string($id)) then key('topicById', $id, $root)[1] else ()" as="element()?"/>
        <xsl:sequence select="$topicContent"/>
    </xsl:function>
    
    <xsl:function name="ahf:getTopicFromLink" as="element()?">
        <xsl:param name="prmLink" as="element()"/>
        <xsl:sequence select="ahf:getTopicFromTopicRef($prmLink)"/>
    </xsl:function>

    <!-- 
     function:	Get topic from href 
     param:		prmHref
     return:	xs:element?
     note:		
     -->
    <xsl:function name="ahf:getTopicFromHref" as="element()?">
        <xsl:param name="prmHref" as="xs:string"/>
        <xsl:variable name="topicContent" select="if (string($prmHref)) then key('topicById', $prmHref, $root)[1] else ()" as="element()?"/>
        <xsl:sequence select="$topicContent"/>
    </xsl:function>

    <!-- 
     function:	Get topicref from topic
     param:		prmTopicContent
     return:	topicref
     note:		
     -->
    <xsl:function name="ahf:getTopicRef" as="element()?">
        <xsl:param name="prmTopic" as="element()?"/>
        
        <xsl:choose>
            <xsl:when test="empty($prmTopic)">
                <!-- invalid parameter -->
                <xsl:sequence select="()"/>
            </xsl:when>
            <xsl:when test="not(contains($prmTopic/@class, ' topic/topic '))">
                <!-- It is not a topic! -->
                <xsl:sequence select="()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="id" select="$prmTopic/@id" as="xs:string"/>
                <xsl:variable name="topicRef" select="key('topicrefByHref', concat('#',$id), $map)[1]" as="element()?"/>
                <xsl:choose>
                    <xsl:when test="exists($topicRef)">
                        <xsl:sequence select="$topicRef"/>
                    </xsl:when>
                    <xsl:when test="$prmTopic/ancestor::*[contains(@class, ' topic/topic ')]">
                        <!-- search ancestor -->
                        <xsl:sequence select="ahf:getTopicRef($prmTopic/ancestor::*[contains(@class, ' topic/topic ')][position()=last()])"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- not found -->
                        <xsl:sequence select="()"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!-- 
     function:	Generate topic file name as @ahd:topic attribute for debugging
     param:		prmTopic
     return:	attribute()
     note:		
     -->
    <xsl:template name="ahf:getTopicFileNameAsAttr" as="attribute()">
        <xsl:sequence select="ahf:getTopicFileNameAsAttr(.)"/>
    </xsl:template>
    
    <xsl:function name="ahf:getTopicFileNameAsAttr" as="attribute()">
        <xsl:param name="prmTopic" as="element()"/>
        <xsl:variable name="topicFileName" as="xs:string" select="ahf:substringAfterLast(ahf:bsToSlash(string($prmTopic/@xtrf)),'/')"/>
        <xsl:attribute name="ahd:topic-file" select="$topicFileName"/>
    </xsl:function>

    <!-- 
     function:	Return topicref is for cover 
     param:		prmTopicRef
     return:	xs:boolean
     note:		
     -->
    <xsl:function name="ahf:isCoverTopicRef" as="xs:boolean">
        <xsl:param name="prmTopicRef" as="element()?"/>
        <xsl:variable name="outputClass" as="xs:string" select="if (exists($prmTopicRef)) then string($prmTopicRef/@outputclass) else ''"/>
        <xsl:sequence select="matches($outputClass,'cover[1-4]')"/>
    </xsl:function>
    
    <!-- 
     function:	topicref count template
     param:		prmTopicRef
     return:	topicref count that have same @href
     note:		none
    -->
    <xsl:function name="ahf:countTopicRef" as="xs:integer">
        <xsl:param name="prmTopicRef" as="element()"/>
        
        <xsl:variable name="href" select="string($prmTopicRef/@href)" as="xs:string"/>
        <xsl:variable name="topicRefCount" as="xs:integer">
            <xsl:number select="$prmTopicRef"
                level="any"
                count="*[contains(@class,' map/topicref ')][string(@href) eq $href]"
                from="*[contains(@class,' map/map ')]"
                format="1"/>
        </xsl:variable>
        <xsl:sequence select="$topicRefCount"/>
    </xsl:function>

    <!-- 
     function:	get topicref level
     param:		prmTopicRef
     return:	topicref count without frontmatter,backmatter,appendices
     note:		none
    -->
    <xsl:function name="ahf:getTopicRefLevel" as="xs:integer">
        <xsl:param name="prmTopicRef" as="element()"/>
        <xsl:variable name="ancestorTopicRef" as="element()+" select="$prmTopicRef/ancestor-or-self::*[contains(@class,' map/topicref ')][not(ahf:seqContains(string(@class),(' bookmap/frontmatter ',' bookmap/appendices ',' bookmap/backmatter ')))]"/>
        <xsl:sequence select="count($ancestorTopicRef)"/>
    </xsl:function>

    <!-- 
     function:	get list nesting level
     param:		prmElem (ol or ul)
     return:	list nesting count
     note:		Nesting count starts from body or table cell or abstract.
    -->
    <xsl:function name="ahf:getListLevel" as="xs:integer">
        <xsl:param name="prmElem" as="element()"/>
        <xsl:variable name="startElem" as="element()?" select="$prmElem/ancestor-or-self::*[ahf:seqContains(@class,(' topic/table ',' topic/body ',' topic/abstract '))][1]"/>
        <xsl:assert test="exists($startElem)" select="'[getListStartLevel] start element not found $prmElem=',ahf:genHistoryId($prmElem)"/>
        <xsl:variable name="ancestorList" as="element()+" select="$prmElem/ancestor-or-self::*[ahf:seqContains(@class,(' topic/ol ',' topic/ul '))][. &gt;&gt; $startElem]"/>
        <xsl:sequence select="count($ancestorList)"/>
    </xsl:function>

    <!-- 
     function:	Determine xref/@href is external or internal link
     param:		prmHref
     return:	xs:boolean
     note:		
     -->
    <xsl:function name="ahf:isInternalLink" as="xs:boolean">
        <xsl:param name="prmHref" as="xs:string"/>
        <xsl:sequence select="starts-with($prmHref,'#')"/>
    </xsl:function>
    
    <xsl:function name="ahf:isExternalLink" as="xs:boolean">
        <xsl:param name="prmHref" as="xs:string"/>
        <xsl:sequence select="not(ahf:isInternalLink($prmHref))"/>
    </xsl:function>

    <!-- 
     function:	Check topic whether it is pointed from topicref
     param:		prmElem, prmTopicRef
     return:	xs:boolean
     note:		
     -->
    <xsl:function name="ahf:isPointedFromTopicref" as="xs:boolean">
        <xsl:param name="prmElem" as="element()"/>
        <xsl:param name="prmTopicRef" as="element()"/>
        <xsl:variable name="topic" as="element()?" select="ahf:getTopicFromTopicRef($prmTopicRef)"/>
        <xsl:sequence select="if (exists($topic)) then ($topic is $prmElem) else false()"/>
    </xsl:function>

    <!-- 
     function:	Get @output class value as xs:string*
     param:		prmElem
     return:	xs:string*
     note:		
     -->
    <xsl:function name="ahf:getOutputClass" as="xs:string*">
        <xsl:param name="prmElem" as="element()"/>
        <xsl:variable name="outputClass" as="xs:string" select="normalize-space(string($prmElem/@outputclass))"/>
        <xsl:sequence select="tokenize($outputClass,' ')"/>
    </xsl:function>
    
    <!-- 
     function:	Get @output class value with regex
     param:		prmElem, prmRegx, prmReplace
     return:	xs:string
     note:		prmRegEx must have several parts using "(" and ")"
                Ex: outputclass="width60" & prmRegx="(width)(\d+)" & prmReplace="$2"
     -->
    <xsl:function name="ahf:getOutputClassRegx" as="xs:string">
        <xsl:param name="prmElem" as="element()"/>
        <xsl:param name="prmRegx" as="xs:string"/>
        <xsl:param name="prmReplace" as="xs:string"/>
        <xsl:variable name="outputClassValues" as="xs:string*" select="ahf:getOutputClass($prmElem)"/>
        <xsl:variable name="value" as="xs:string?">
            <xsl:for-each select="$outputClassValues[matches(.,$prmRegx)][1]">
                <xsl:sequence select="replace(.,$prmRegx,$prmReplace)"/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:sequence select="if (exists($value)) then $value else ''"/>
    </xsl:function>

    <xsl:function name="ahf:getOutputClassRegxWithDefault" as="xs:string">
        <xsl:param name="prmElem" as="element()"/>
        <xsl:param name="prmRegx" as="xs:string"/>
        <xsl:param name="prmReplace" as="xs:string"/>
        <xsl:param name="prmDefault" as="xs:string"/>
        <xsl:variable name="result" as="xs:string" select="ahf:getOutputClassRegx($prmElem,$prmRegx,$prmReplace)"/>
        <xsl:sequence select="if ($result eq '') then $prmDefault else $result"/>
    </xsl:function>
    
    <!-- end of stylesheet -->
</xsl:stylesheet>
