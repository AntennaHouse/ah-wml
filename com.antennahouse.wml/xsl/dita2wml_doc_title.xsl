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
     return:	
     note:		Initial implementation.
                toc="no", nested topic are not considered yet.
     -->
    <xsl:template match="*[contains(@class,' topic/topic ')]/*[contains(@class,' topic/title ')]">
        <xsl:param name="prmTopicRef"       tunnel="yes" required="yes" as="element()"/>
        <xsl:param name="prmTopicRefLevel"  tunnel="yes" required="yes" as="xs:integer"/>
        <xsl:param name="prmTopic"          tunnel="yes" required="yes" as="element()"/>
        <xsl:variable name="isInFrontmatterOrBackmatter" as="xs:boolean" select="exists($prmTopicRef/ancestor-or-self::*[ahf:seqContains(@class,(' bookmap/frontmatter',' bookmap/backmatter '))])"/>
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
            <xsl:call-template name="genBookmarkStart">
                <xsl:with-param name="prmElem" select="parent::*"/>
            </xsl:call-template>
            <xsl:apply-templates select="$prmTopic/*[contains(@class,' topic/prolog ')]/*[contains(@class,' topic/metadata ')]/*[contains(@class,' topic/keywords ')]/*[contains(@class,' topic/indexterm ')]"/>
            <xsl:apply-templates/>
            <xsl:call-template name="genBookmarkEnd">
                <xsl:with-param name="prmElem" select="parent::*"/>
            </xsl:call-template>
        </w:p>
    </xsl:template>

    <!-- 
     function:	topichead (including chapter or part) title processing
     param:		prmTopicRef, prmTopicRefLevel
     return:	w:p
     note:		
     -->
    <xsl:template name="genTopicHeadTitle">
        <xsl:param name="prmTopicRef"       required="yes" as="element()"/>

        <xsl:variable name="topicRefLevel" select="ahf:getTopicRefLevel($prmTopicRef)" as="xs:integer"/>
        <xsl:variable name="isInFrontmatterOrBackmatter" as="xs:boolean" select="exists($prmTopicRef/ancestor-or-self::*[ahf:seqContains(@class,(' bookmap/frontmatter',' bookmap/backmatter '))])"/>
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
                <xsl:when test="$prmTopicRef/*[contains(@class,' map/topicmeta ')]/*[contains(@class,' topic/navtitle ')]">
                    <xsl:apply-templates select="$prmTopicRef/*[contains(@class,' map/topicmeta ')]/*[contains(@class,' topic/navtitle ')]/node()">
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
     function:	topiref title for indexlist, etc
     param:		prmTopicRef, prmTopicRefLevel
     return:	w:p
     note:		
     -->
    <xsl:template name="genTopicRefTitle">
        <xsl:param name="prmTopicRef"       as="element()"  required="yes"/>
        <xsl:param name="prmTopicRefLevel"  as="xs:integer" required="yes"/>
        <xsl:param name="prmTitle"          as="xs:string"  required="no" select="''"/>
        
        <xsl:variable name="isInFrontmatterOrBackmatter" as="xs:boolean" select="exists($prmTopicRef/ancestor-or-self::*[ahf:seqContains(@class,(' bookmap/frontmatter',' bookmap/backmatter '))])"/>
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
                <xsl:when test="$prmTopicRef/*[contains(@class,' map/topicmeta ')]/*[contains(@class,' topic/navtitle ')]">
                    <xsl:apply-templates select="$prmTopicRef/*[contains(@class,' map/topicmeta ')]/*[contains(@class,' topic/navtitle ')]/node()">
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
        
        <xsl:variable name="prefixPart" as="xs:string">
            <xsl:choose>
                <xsl:when test="$pAddPartOrChapterToTitle">
                    <xsl:choose>
                        <xsl:when test="$isBookMap">
                            <xsl:choose>
                                <xsl:when test="$prmTopicRef/ancestor::*[contains(@class, ' bookmap/frontmatter ')]">
                                    <xsl:sequence select="''"/>
                                </xsl:when>
                                <xsl:when test="$prmTopicRef/self::*[contains(@class, ' bookmap/part ')]">
                                    <xsl:sequence select="$cPartTitlePrefix"/>
                                </xsl:when>
                                <xsl:when test="$prmTopicRef/self::*[contains(@class, ' bookmap/chapter ')]">
                                    <xsl:sequence select="$cChapterTitlePrefix"/>
                                </xsl:when>
                                <xsl:when test="$prmTopicRef/self::*[contains(@class, ' bookmap/appendix ')]">
                                    <xsl:sequence select="$cAppendixTitle"/>
                                </xsl:when>
                                <xsl:when test="$prmTopicRef/ancestor::*[contains(@class, ' bookmap/backmatter ')]">
                                    <xsl:sequence select="''"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <!-- May be appendice -->
                                    <xsl:sequence select="''"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:otherwise>
                            <!-- map -->
                            <xsl:sequence select="''"/>
                        </xsl:otherwise>
                    </xsl:choose>                    
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="''"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:variable name="suffixPart" as="xs:string">
            <xsl:choose>
                <xsl:when test="$pAddPartOrChapterToTitle">
                    <xsl:choose>
                        <xsl:when test="$isBookMap">
                            <xsl:choose>
                                <xsl:when test="$prmTopicRef/ancestor::*[contains(@class, ' bookmap/frontmatter ')]">
                                    <xsl:sequence select="''"/>
                                </xsl:when>
                                <xsl:when test="$prmTopicRef/self::*[contains(@class, ' bookmap/part ')]">
                                    <xsl:sequence select="$cPartTitleSuffix"/>
                                </xsl:when>
                                <xsl:when test="$prmTopicRef/self::*[contains(@class, ' bookmap/chapter ')]">
                                    <xsl:sequence select="$cChapterTitleSuffix"/>
                                </xsl:when>
                                <xsl:when test="$prmTopicRef/self::*[contains(@class, ' bookmap/appendix ')]">
                                    <xsl:sequence select="''"/>
                                </xsl:when>
                                <xsl:when test="$prmTopicRef/ancestor::*[contains(@class, ' bookmap/backmatter ')]">
                                    <xsl:sequence select="''"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <!-- May be appendice -->
                                    <xsl:sequence select="''"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:otherwise>
                            <!-- map -->
                            <xsl:value-of select="''"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="''"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:variable name="numberPart" as="xs:string">
            <xsl:choose>
                <xsl:when test="$isBookMap">
                    <xsl:choose>
                        <xsl:when test="$prmTopicRef/ancestor::*[contains(@class, ' bookmap/frontmatter ')]">
                            <xsl:sequence select="''"/>
                        </xsl:when>
                        <xsl:when test="$prmTopicRef/ancestor-or-self::*[contains(@class, ' bookmap/part ')]">
                            <xsl:sequence select="ahf:genLevelTitlePrefix($prmTopicRef)"/>
                        </xsl:when>
                        <xsl:when test="$prmTopicRef/ancestor-or-self::*[contains(@class, ' bookmap/chapter ')]">
                            <xsl:sequence select="ahf:genLevelTitlePrefix($prmTopicRef)"/>
                        </xsl:when>
                        <xsl:when test="$prmTopicRef/ancestor-or-self::*[contains(@class, ' bookmap/appendix ')]">
                            <xsl:sequence select="ahf:genLevelTitlePrefix($prmTopicRef)"/>
                        </xsl:when>
                        <xsl:when test="$prmTopicRef/ancestor::*[contains(@class, ' bookmap/backmatter ')]">
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
        
        <xsl:variable name="result" select="concat($prefixPart,$numberPart,$suffixPart)"/>
        <xsl:sequence select="$result"/>
    </xsl:template>

    <!-- 
     function:	Generate top level topicref count
     param:		prmTopicRef
     return:	top level topicref count 
     note:		none
     -->
    <xsl:function name="ahf:hasTopTopicrefNumber" as="xs:boolean">
        <xsl:param name="prmTopicRef" as="element()"/>
        <xsl:variable name="topTopicRef" as="element()" select="$prmTopicRef/ancestor-or-self::*[contains(@class,' map/topicref ')][not(contains(@class,' bookmap/appendices '))][last()]"/>
        <xsl:choose>
            <xsl:when test="$isBookMap">
                <xsl:choose>
                    <xsl:when test="$topTopicRef/self::*[contains(@class, ' bookmap/frontmatter ')]">
                        <xsl:sequence select="false()"/>
                    </xsl:when>
                    <xsl:when test="$topTopicRef/self::*[contains(@class, ' bookmap/part ')]">
                        <xsl:sequence select="true()"/>
                    </xsl:when>
                    <xsl:when test="$topTopicRef/self::*[contains(@class, ' bookmap/chapter ')]">
                        <xsl:sequence select="true()"/>
                    </xsl:when>
                    <xsl:when test="$topTopicRef/self::*[contains(@class, ' bookmap/appendix ')]">
                        <xsl:sequence select="true()"/>
                    </xsl:when>
                    <xsl:when test="$prmTopicRef/ancestor::*[contains(@class, ' bookmap/backmatter ')]">
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
        <xsl:variable name="topTopicRef" as="element()" select="$prmTopicRef/ancestor-or-self::*[contains(@class,' map/topicref ')][not(contains(@class,' bookmap/appendices '))][last()]"/>
        <xsl:choose>
            <xsl:when test="$isBookMap">
                <xsl:choose>
                    <xsl:when test="$topTopicRef/self::*[contains(@class, ' bookmap/frontmatter ')]">
                        <xsl:sequence select="0"/>
                    </xsl:when>
                    <xsl:when test="$topTopicRef/self::*[contains(@class, ' bookmap/part ')]">
                        <xsl:sequence select="count($topTopicRef | $topTopicRef/preceding-sibling::*[contains(@class, ' bookmap/part ')])"/>
                    </xsl:when>
                    <xsl:when test="$topTopicRef/self::*[contains(@class, ' bookmap/chapter ')]">
                        <xsl:sequence select="count($topTopicRef | $topTopicRef/preceding-sibling::*[contains(@class, ' bookmap/chapter ')])"/>
                    </xsl:when>
                    <xsl:when test="$topTopicRef/self::*[contains(@class, ' bookmap/appendix ')]">
                        <xsl:sequence select="count($topTopicRef | $topTopicRef/preceding-sibling::*[contains(@class, ' bookmap/appendix ')])"/>
                    </xsl:when>
                    <xsl:when test="$prmTopicRef/ancestor::*[contains(@class, ' bookmap/backmatter ')]">
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
                <xsl:sequence select="count($topTopicRef | $topTopicRef/preceding-sibling::*[contains(@class, ' map/topicref ')])"/>
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
        <xsl:variable name="ancestorOrSelfTopicRef" as="element()*" select="$prmTopicRef/ancestor-or-self::*[contains(@class,' map/topicref ')][not(contains(@class,' bookmap/appendices '))]"/>
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
        <xsl:variable name="ancestorOrSelfTopicRef" as="element()*" select="($prmTopicRef/ancestor-or-self::*[contains(@class,' map/topicref ')][not(contains(@class,' bookmap/appendices '))])[position() le $prmCutLimit]"/>
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
                        <xsl:when test="$topicRef[contains(@class, ' bookmap/part ')]">
                            <xsl:variable name="partCount" as="xs:integer" select="count($topicRef/preceding-sibling::*[contains(@class, ' map/topicref ')][contains(@class, ' bookmap/part ')][ahf:isToc(.)]|$topicRef)"/>
                            <xsl:variable name="partCountFormat" as="xs:string" select="ahf:getVarValue('Part_Count_Format')"/>
                            <xsl:number format="{$partCountFormat}" value="$partCount"/>
                        </xsl:when>
                        <xsl:when test="$topicRef[contains(@class, ' bookmap/chapter ')][empty(parent::*[contains(@class, ' bookmap/part ')])]">
                            <xsl:variable name="chapterCount" as="xs:integer" select="count($topicRef/preceding-sibling::*[contains(@class, ' map/topicref ')][contains(@class, ' bookmap/chapter ')][ahf:isToc(.)]|$topicRef)"/>
                            <xsl:variable name="chapterCountFormat" as="xs:string" select="ahf:getVarValue('Chapter_Count_Format')"/>
                            <xsl:number format="{$chapterCountFormat}" value="$chapterCount"/>
                        </xsl:when>
                        <xsl:when test="$topicRef[contains(@class, ' bookmap/appendix ')]">
                            <xsl:variable name="appendixCount" select="count($topicRef/preceding-sibling::*[contains(@class, ' map/topicref ')][contains(@class, ' bookmap/appendix ')][ahf:isToc(.)]|$topicRef)"/>
                            <xsl:variable name="appendixCountFormat" as="xs:string" select="ahf:getVarValue('Appendix_Count_Format')"/>
                            <xsl:number format="{$appendixCountFormat}" value="$appendixCount"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:sequence select="string(count($topicRef/preceding-sibling::*[contains(@class, ' map/topicref ')][ahf:isToc(.)]|$topicRef))"/>
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

    <!-- ==== END OF STYLESHEET === -->

</xsl:stylesheet>