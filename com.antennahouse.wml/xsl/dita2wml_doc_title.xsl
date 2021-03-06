<?xml version="1.0" encoding="UTF-8"?>
<!--
**************************************************************
DITA to WordprocessingML Stylesheet
Document.xml Title Templates
**************************************************************
File Name : dita2wml_document_title.xsl
**************************************************************
Copyright © 2009-2017 Antenna House, Inc. All rights reserved.
Antenna House is a trademark of Antenna House, Inc.
URL : http://www.antennahouse.com/
**************************************************************
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" 
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
    exclude-result-prefixes="xs ahf map"
    version="3.0">

    <!-- 
     function:	Topic/title processing
     param:		none
     return:	w:p
     note:		Initial implementation.
                - toc="no" and nested topic are not considered.
                - XE field from indexterm should be generated outside the bookmark
                  because bookmark is referenced from toc, related-links/link and xref.
     -->
    <xsl:template match="*[@class => contains-token('topic/topic')]/*[@class => contains-token('topic/title')]" as="element(w:p)">
        <xsl:param name="prmTopicRef"       tunnel="yes" required="yes" as="element()"/>
        <xsl:param name="prmTopicRefLevel"  tunnel="yes" required="yes" as="xs:integer"/>
        <xsl:param name="prmTopic"          tunnel="yes" required="yes" as="element()"/>
        <xsl:variable name="title" as="element()" select="."/>
        <xsl:variable name="topicLevel" as="xs:integer" select="$title/parent::*/ancestor::*[@class => contains-token('topic/topic')] => count()"/>
        <xsl:variable name="isInFrontmatterOrBackmatter" as="xs:boolean" select="$prmTopicRef/ancestor-or-self::*[@class => ahf:seqContainsToken(('bookmap/frontmatter','bookmap/backmatter'))] => exists()"/>
        <w:p>
            <w:pPr>
                <w:pStyle>
                    <xsl:attribute name="w:val" select="ahf:getStyleIdFromName(concat('heading ',string($prmTopicRefLevel + $topicLevel)))"/>
                </w:pStyle>
                <xsl:if test="$pAddChapterNumberPrefixToTopicTitle and not($isInFrontmatterOrBackmatter)">
                    <w:numPr>
                        <w:ilvl w:val="{ahf:getIlvlFromTopicLevel($prmTopicRefLevel)}"/>
                        <w:numId w:val="{$numIdForTopicTitle}"/>
                    </w:numPr>
                </xsl:if>
            </w:pPr>
            <xsl:apply-templates select="$prmTopic/*[@class => contains-token('topic/prolog')]/*[@class => contains-token('topic/metadata')]/*[@class => contains-token('topic/keywords')]/*[@class => contains-token('topic/indexterm')]"/>
            <xsl:call-template name="genBookmarkStart">
                <xsl:with-param name="prmElem" select="parent::*"/>
            </xsl:call-template>
            <xsl:apply-templates/>
            <xsl:call-template name="genBookmarkEnd">
                <xsl:with-param name="prmElem" select="parent::*"/>
            </xsl:call-template>
        </w:p>
    </xsl:template>
    
    <!-- 
     function:	topichead (including chapter or part) title processing
     param:		prmTopicRef, prmDefaultTitle
     return:	w:p
     note:		
     -->
    <xsl:template name="genTopicHeadTitle">
        <xsl:param name="prmTopicRef"       required="yes" as="element()"/>
        <xsl:param name="prmDefaultTitle"   required="yes" as="xs:string"/>

        <xsl:variable name="topicRefLevel" select="ahf:getTopicRefLevel($prmTopicRef)" as="xs:integer"/>
        <xsl:variable name="isInFrontmatterOrBackmatter" as="xs:boolean" select="exists($prmTopicRef/ancestor-or-self::*[@class => ahf:seqContainsToken(('bookmap/frontmatter','bookmap/backmatter'))])"/>
        <w:p>
            <w:pPr>
                <w:pStyle>
                    <xsl:attribute name="w:val" select="ahf:getStyleIdFromName(concat('heading ',string($topicRefLevel)))"/>
                </w:pStyle>
                <xsl:if test="$pAddChapterNumberPrefixToTopicTitle and not($isInFrontmatterOrBackmatter)">
                    <w:numPr>
                        <w:ilvl w:val="{ahf:getIlvlFromTopicLevel($topicRefLevel)}"/>
                        <w:numId w:val="{$numIdForTopicTitle}"/>
                    </w:numPr>
                </xsl:if>
            </w:pPr>
            <xsl:choose>
                <xsl:when test="$prmDefaultTitle ne ''">
                    <w:r>
                        <w:t xml:space="preserve"><xsl:value-of select="$prmDefaultTitle"/></w:t>
                    </w:r>
                </xsl:when>
                <xsl:when test="$prmTopicRef/*[@class => contains-token('map/topicmeta')]/*[@class => contains-token('topic/navtitle')]">
                    <xsl:apply-templates select="$prmTopicRef/*[@class => contains-token('map/topicmeta')]/*[@class => contains-token('topic/navtitle')]/node()">
                        <xsl:with-param name="prmTopicRef" tunnel="yes" select="$prmTopicRef"/>
                    </xsl:apply-templates>
                </xsl:when>
                <xsl:when test="$prmTopicRef/@navtitle">
                    <w:r>
                        <w:t xml:space="preserve"><xsl:value-of select="$prmTopicRef/@navtitle"/></w:t>
                    </w:r>
                </xsl:when>
            </xsl:choose>
        </w:p>
    </xsl:template>
    
    <!-- 
     function:	topicref title for indexlist, etc
     param:		prmTopicRef, prmTopicRefLevel
     return:	w:p
     note:		
     -->
    <xsl:template name="genTopicRefTitle">
        <xsl:param name="prmTopicRef"       as="element()"  required="yes"/>
        <xsl:param name="prmTopicRefLevel"  as="xs:integer" required="yes"/>
        <xsl:param name="prmTitle"          as="xs:string"  required="no" select="''"/>
        
        <xsl:variable name="isInFrontmatterOrBackmatter" as="xs:boolean" select="exists($prmTopicRef/ancestor-or-self::*[@class => ahf:seqContainsToken(('bookmap/frontmatter','bookmap/backmatter'))])"/>
        <w:p>
            <w:pPr>
                <w:pStyle>
                    <xsl:attribute name="w:val" select="ahf:getStyleIdFromName(concat('heading ',string($prmTopicRefLevel)))"/>
                </w:pStyle>
                <xsl:if test="$pAddChapterNumberPrefixToTopicTitle and not($isInFrontmatterOrBackmatter)">
                    <w:numPr>
                        <w:ilvl w:val="{ahf:getIlvlFromTopicLevel($prmTopicRefLevel)}"/>
                        <w:numId w:val="{$numIdForTopicTitle}"/>
                    </w:numPr>
                </xsl:if>
            </w:pPr>
            <xsl:choose>
                <xsl:when test="string($prmTitle)">
                    <w:r>
                        <w:t xml:space="preserve"><xsl:value-of select="$prmTitle"/></w:t>
                    </w:r>
                </xsl:when>
                <xsl:when test="$prmTopicRef/*[@class => contains-token('map/topicmeta')]/*[@class => contains-token('topic/navtitle')]">
                    <xsl:apply-templates select="$prmTopicRef/*[@class => contains-token('map/topicmeta')]/*[@class => contains-token('topic/navtitle')]/node()">
                        <xsl:with-param name="prmTopicRef" tunnel="yes" select="$prmTopicRef"/>
                    </xsl:apply-templates>
                </xsl:when>
                <xsl:when test="$prmTopicRef/@navtitle">
                    <w:r>
                        <w:t xml:space="preserve"><xsl:value-of select="$prmTopicRef/@navtitle"/></w:t>
                    </w:r>
                </xsl:when>
            </xsl:choose>
        </w:p>
    </xsl:template>
    

    <!-- 
     function:	Generate prefix of title
     param:		prmTopicRef
     return:	prefix of title 
     note:		none
     -->
    <xsl:template name="genTitlePrefix" as="xs:string">
        <xsl:param name="prmTopicRef" required="yes" as="element()"/>
        <xsl:variable name="numberPart" as="xs:string">
            <xsl:choose>
                <xsl:when test="$isBookMap">
                    <xsl:choose>
                        <xsl:when test="$prmTopicRef/ancestor::*[@class => contains-token('bookmap/frontmatter')]">
                            <xsl:sequence select="''"/>
                        </xsl:when>
                        <xsl:when test="$prmTopicRef/ancestor-or-self::*[@class => contains-token('bookmap/part')]">
                            <xsl:sequence select="ahf:genLevelTitlePrefix($prmTopicRef)"/>
                        </xsl:when>
                        <xsl:when test="$prmTopicRef/ancestor-or-self::*[@class => contains-token('bookmap/chapter')]">
                            <xsl:sequence select="ahf:genLevelTitlePrefix($prmTopicRef)"/>
                        </xsl:when>
                        <xsl:when test="$prmTopicRef/ancestor-or-self::*[@class => contains-token('bookmap/appendix')]">
                            <xsl:sequence select="ahf:genLevelTitlePrefix($prmTopicRef)"/>
                        </xsl:when>
                        <xsl:when test="$prmTopicRef/ancestor::*[@class => contains-token('bookmap/backmatter')]">
                            <xsl:value-of select="''"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <!-- May be appendice -->
                            <xsl:value-of select="''"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <!-- map -->
                    <xsl:sequence select="ahf:genLevelTitlePrefix($prmTopicRef)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:sequence select="$numberPart"/>
    </xsl:template>

    <!-- 
     function:	Generate top level topicref count
     param:		prmTopicRef
     return:	top level topicref count 
     note:		none
     -->
    <xsl:function name="ahf:hasTopTopicrefNumber" as="xs:boolean">
        <xsl:param name="prmTopicRef" as="element()"/>
        <xsl:variable name="topTopicRef" as="element()" select="$prmTopicRef/ancestor-or-self::*[@class => contains-token('map/topicref')][@class => contains-token('bookmap/appendices') => not()][last()]"/>
        <xsl:choose>
            <xsl:when test="$isBookMap">
                <xsl:choose>
                    <xsl:when test="$topTopicRef/self::*[@class => contains-token('bookmap/frontmatter')]">
                        <xsl:sequence select="false()"/>
                    </xsl:when>
                    <xsl:when test="$topTopicRef/self::*[@class => contains-token('bookmap/part')]">
                        <xsl:sequence select="true()"/>
                    </xsl:when>
                    <xsl:when test="$topTopicRef/self::*[@class => contains-token('bookmap/chapter')]">
                        <xsl:sequence select="true()"/>
                    </xsl:when>
                    <xsl:when test="$topTopicRef/self::*[@class => contains-token('bookmap/appendix')]">
                        <xsl:sequence select="true()"/>
                    </xsl:when>
                    <xsl:when test="$prmTopicRef/ancestor::*[@class => contains-token('bookmap/backmatter')]">
                        <xsl:sequence select="false()"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- Should not happen -->
                        <xsl:sequence select="false()"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <!-- map -->
                <xsl:sequence select="true()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <!-- 
     function:	Generate top level topicref count
     param:		prmTopicRef
     return:	top level topicref count 
     note:		none
     -->
    <xsl:template name="getTopTopicrefNumber" as="xs:integer">
        <xsl:param name="prmTopicRef" required="yes" as="element()"/>
        <xsl:variable name="topTopicRef" as="element()" select="$prmTopicRef/ancestor-or-self::*[@class => contains-token('map/topicref')][@class => contains-token('bookmap/appendices') => not()][last()]"/>
        <xsl:choose>
            <xsl:when test="$isBookMap">
                <xsl:choose>
                    <xsl:when test="$topTopicRef/self::*[@class => contains-token('bookmap/frontmatter')]">
                        <xsl:sequence select="0"/>
                    </xsl:when>
                    <xsl:when test="$topTopicRef/self::*[@class => contains-token('bookmap/part')]">
                        <xsl:sequence select="count($topTopicRef | $topTopicRef/preceding-sibling::*[@class => contains-token('bookmap/part')])"/>
                    </xsl:when>
                    <xsl:when test="$topTopicRef/self::*[@class => contains-token('bookmap/chapter')]">
                        <xsl:sequence select="count($topTopicRef | $topTopicRef/preceding-sibling::*[@class => contains-token('bookmap/chapter')])"/>
                    </xsl:when>
                    <xsl:when test="$topTopicRef/self::*[@class => contains-token('bookmap/appendix')]">
                        <xsl:sequence select="count($topTopicRef | $topTopicRef/preceding-sibling::*[@class => contains-token('bookmap/appendix')])"/>
                    </xsl:when>
                    <xsl:when test="$prmTopicRef/ancestor::*[@class => contains-token('bookmap/backmatter')]">
                        <xsl:sequence select="0"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- Should not happen -->
                        <xsl:sequence select="0"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <!-- map -->
                <xsl:sequence select="count($topTopicRef | $topTopicRef/preceding-sibling::*[@class => contains-token('map/topicref')])"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- 
     function:	Generate level of topicref
     param:		prmTopicRef
     return:	xs:string 
     note:		none
     -->
    <xsl:function name="ahf:genLevelTitlePrefix" as="xs:string">
        <xsl:param name="prmTopicRef" as="element()"/>
        <xsl:variable name="ancestorOrSelfTopicRef" as="element()*" select="$prmTopicRef/ancestor-or-self::*[@class => contains-token('map/topicref')][@class => contains-token('bookmap/appendices') => not()]"/>
        <xsl:variable name="levelString" as="xs:string*" select="ahf:getSibilingTopicrefCount($ancestorOrSelfTopicRef)"/>
        <xsl:sequence select="string-join($levelString,'')"/>
    </xsl:function>
    
    <!-- 
     function:	Generate level of topicref
     param:		prmTopicRef,prmCutLimit
     return:	xs:string 
     note:		Ancestor or self of $prmTopicref will be cut by $prmCutLevel level.
                This function is used for table & fig numbering title prefix.
                2014-09-16 t.makita
     -->
    <xsl:function name="ahf:genLevelTitlePrefixByCount" as="xs:string">
        <xsl:param name="prmTopicRef" as="element()"/>
        <xsl:param name="prmCutLimit" as="xs:integer"/>
        <xsl:variable name="ancestorOrSelfTopicRef" as="element()*" select="($prmTopicRef/ancestor-or-self::*[@class => contains-token('map/topicref')][@class => contains-token('bookmap/appendices') => not()])[position() le $prmCutLimit]"/>
        <xsl:variable name="levelString" as="xs:string*" select="ahf:getSibilingTopicrefCount($ancestorOrSelfTopicRef)"/>
        <xsl:sequence select="string-join($levelString,'')"/>
    </xsl:function>
    
    <!-- 
     function:	Get preceding-sibling topicref count
     param:		prmTopicRef
     return:	xs:string* 
     note:		topicref/@toc="no" is not counted.
                Fix topicref counting bug.
                2015-08-07 t.makita
     -->
    <xsl:function name="ahf:getSibilingTopicrefCount" as="xs:string*">
        <xsl:param name="prmTopicRefs" as="element()*"/>
        <xsl:choose>
            <xsl:when test="exists($prmTopicRefs[1])">
                <xsl:variable name="topicRef" as="element()" select="$prmTopicRefs[1]"/>
                <xsl:variable name="precedingCountStr" as="xs:string">
                    <xsl:choose>
                        <xsl:when test="$topicRef[@class => contains-token('bookmap/part')]">
                            <xsl:variable name="partCount" as="xs:integer" select="count($topicRef/preceding-sibling::*[@class => contains-token('map/topicref')][@class => contains-token('bookmap/part')][. => ahf:isToc()]|$topicRef)"/>
                            <xsl:variable name="partCountFormat" as="xs:string" select="ahf:getVarValue('Part_Count_Format')"/>
                            <xsl:number format="{$partCountFormat}" value="$partCount"/>
                        </xsl:when>
                        <xsl:when test="$topicRef[@class => contains-token('bookmap/chapter')][parent::*[@class => contains-token('bookmap/part')] => empty()]">
                            <xsl:variable name="chapterCount" as="xs:integer" select="count($topicRef/preceding-sibling::*[@class => contains-token('map/topicref')][@class => contains-token('bookmap/chapter')][. => ahf:isToc()]|$topicRef)"/>
                            <xsl:variable name="chapterCountFormat" as="xs:string" select="ahf:getVarValue('Chapter_Count_Format')"/>
                            <xsl:number format="{$chapterCountFormat}" value="$chapterCount"/>
                        </xsl:when>
                        <xsl:when test="$topicRef[@class => contains-token('bookmap/appendix')]">
                            <xsl:variable name="appendixCount" select="count($topicRef/preceding-sibling::*[@class => contains-token('map/topicref')][@class => ahf:seqContainsToken(('bookmap/appendix','bookmap/chapter','bookmap/part'))][. => ahf:isToc()]|$topicRef)"/>
                            <xsl:variable name="appendixCountFormat" as="xs:string" select="ahf:getVarValue('Chapter_Count_Format')"/>
                            <xsl:number format="{$appendixCountFormat}" value="$appendixCount"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:sequence select="string(count($topicRef/preceding-sibling::*[@class => contains-token('map/topicref')][. => ahf:isToc()]|$topicRef))"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:sequence select="$precedingCountStr"/>
                <xsl:if test="exists($prmTopicRefs[2][ahf:isToc(.)])">
                    <xsl:sequence select="$cTitlePrefixSeparator"/>
                    <xsl:sequence select="ahf:getSibilingTopicrefCount($prmTopicRefs[position() gt 1])"/>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="''"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!-- 
     function:	Generate topic title without footnotes, bookmark
     param:		prmTopicRef, prmTopic, prmRunProps
     return:	w:r
     note:		Used for field result processing.
     -->
    <xsl:template name="genTitleWmlRestricted" as="element(w:r)*">
        <xsl:param name="prmTopicRef" as="element()" required="yes"/>
        <xsl:param name="prmTopic" as="element()?" required="yes"/>
        <xsl:param name="prmRunProps" as="element()*" required="yes"/>
        <xsl:apply-templates select="$prmTopic/*[@class => contains-token('topic/title')]/node()">
            <xsl:with-param name="prmRunProps"       tunnel="yes" select="$prmRunProps"/>
            <xsl:with-param name="prmSkipBookmark"   tunnel="yes" select="true()"/>
            <xsl:with-param name="prmSkipFn"         tunnel="yes" select="true()"/>
            <xsl:with-param name="prmSkipIndexTerm"  tunnel="yes" select="true()"/>
        </xsl:apply-templates>
    </xsl:template>

    <!-- ==== END OF STYLESHEET === -->

</xsl:stylesheet>