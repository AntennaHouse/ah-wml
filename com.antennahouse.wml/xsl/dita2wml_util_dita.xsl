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
     function:	Check nested topic 
     param:		prmTopic
     return:	xs:boolean
     note:		
     -->
    <xsl:function name="ahf:isNestedTopic" as="xs:boolean">
        <xsl:param name="prmTopic" as="element()"/>
        <xsl:choose>
            <xsl:when test="exists($prmTopic/ancestor::*[@class => contains-token('topic/topic')])">
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
            <xsl:when test="$prmTopic/@class => contains-token('topic/topic') => not()">
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
                    <xsl:when test="$prmTopic/ancestor::*[@class => contains-token('topic/topic')]">
                        <!-- search ancestor -->
                        <xsl:sequence select="ahf:getTopicRef($prmTopic/ancestor::*[@class => contains-token('topic/topic')][position()=last()])"/>
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
                count="*[@class => contains-token('map/topicref')][string(@href) eq $href]"
                from="*[@class => contains-token('map/map')]"
                format="1"/>
        </xsl:variable>
        <xsl:sequence select="$topicRefCount"/>
    </xsl:function>
    
    <!-- 
     function:	topicref content check function
     param:		prmTopicRef
     return:	xs:boolean
     note:		If topicref has @href for internal topic or topicref has @navtitle or topicmeta/navtitle
    -->
    <xsl:function name="ahf:hasTopicRefContent" as="xs:boolean">
        <xsl:param name="prmTopicRef" as="element()"/>
        
        <xsl:variable name="href" select="string($prmTopicRef/@href)" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="ahf:isInternalLink($href)">
                <xsl:sequence select="true()"/>
            </xsl:when>
            <xsl:when test="$prmTopicRef/@navtitle or $prmTopicRef/*[@class => contains-token('map/topicmeta')]/*[@class => contains-token('topic/navtitle')]">
                <xsl:sequence select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!-- 
     function:	get topicref level
     param:		prmTopicRef
     return:	topicref count without frontmatter,backmatter,appendices
     note:		none
    -->
    <xsl:function name="ahf:getTopicRefLevel" as="xs:integer">
        <xsl:param name="prmTopicRef" as="element()"/>
        <xsl:variable name="ancestorTopicRef" as="element()+" select="$prmTopicRef/ancestor-or-self::*[@class => contains-token('map/topicref')][@class => ahf:seqContainsToken(('bookmap/frontmatter','bookmap/appendices','bookmap/backmatter')) => not()]"/>
        <xsl:sequence select="count($ancestorTopicRef)"/>
    </xsl:function>

    <!-- 
     function:	get list nesting level
     param:		prmElem (ol or ul)
     return:	list nesting count
     note:		Nesting count starts from body or table cell or abstract.
                Count only same kind of list (ol or ul)
    -->
    <xsl:function name="ahf:getListLevel" as="xs:integer">
        <xsl:param name="prmElem" as="element()"/>
        <xsl:variable name="isOl" as="xs:boolean" select="exists($prmElem[@class => contains-token('topic/ol')])"/>
        <xsl:variable name="startElem" as="element()?" select="$prmElem/ancestor-or-self::*[@class => ahf:seqContainsToken(('topic/entry','topic/stentry','topic/body','topic/abstract', 'topic/note'))][1]"/>
        <xsl:assert test="exists($startElem)" select="'[getListStartLevel] start element not found $prmElem=',ahf:genHistoryId($prmElem)"/>
        <xsl:variable name="ancestorList" as="element()+" select="$prmElem/ancestor-or-self::*[@class => contains-token(if ($isOl) then 'topic/ol' else 'topic/ul')][. &gt;&gt; $startElem]"/>
        <xsl:sequence select="count($ancestorList)"/>
    </xsl:function>

    <!-- 
     function:	get absolute list nesting level
     param:		prmElem (ol or ul)
     return:	list nesting count
     note:		Nesting count starts from body or table cell or abstract.
                Count all kind of list (ol or ul)
    -->
    <xsl:function name="ahf:getAbsListLevel" as="xs:integer">
        <xsl:param name="prmElem" as="element()"/>
        <xsl:variable name="startElem" as="element()?" select="$prmElem/ancestor-or-self::*[@class => ahf:seqContainsToken(('topic/entry','topic/stentry','topic/body','topic/abstract', 'topic/note'))][1]"/>
        <xsl:assert test="exists($startElem)" select="'[getAbsListStartLevel] start element not found $prmElem=',ahf:genHistoryId($prmElem)"/>
        <xsl:variable name="ancestorList" as="element()+" select="$prmElem/ancestor-or-self::*[@class => ahf:seqContainsToken(('topic/ol','topic/ul'))][. &gt;&gt; $startElem]"/>
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
        <xsl:sequence select="tokenize($outputClass,'[\s]+')"/>
    </xsl:function>
    
    <!-- 
     function:	Get @outputclass value with regex
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

    <!-- 
     function:	Checkt @outputclass value has specified value
     param:		prmElem, prmValue
     return:	xs:boolean
     note:		
     -->
    <xsl:function name="ahf:hasOutputClassValue" as="xs:boolean">
        <xsl:param name="prmElem" as="element()"/>
        <xsl:param name="prmValue" as="xs:string"/>
        <xsl:sequence select="$prmValue = ahf:getOutputClass($prmElem)"/>
    </xsl:function>
    
    <!-- 
     function:	Checkt @outputclass value has one of specified value
     param:		prmElem, prmValueSeq
     return:	xs:boolean
     note:		
     -->
    <xsl:function name="ahf:hasOneOfOutputClassValue" as="xs:boolean">
        <xsl:param name="prmElem" as="element()"/>
        <xsl:param name="prmValueSeq" as="xs:string+"/>
        <xsl:sequence select="$prmValueSeq = ahf:getOutputClass($prmElem)"/>
    </xsl:function>
    
    <!-- end of stylesheet -->
</xsl:stylesheet>
