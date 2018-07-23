<?xml version="1.0" encoding="UTF-8"?>
<!--
**************************************************************
DITA to WordprocessingML Stylesheet
Section control module Templates
**************************************************************
File Name : dita2wml_sect_control_info.xsl
**************************************************************
Copyright © 2009-2018 Antenna House, Inc. All rights reserved.
Antenna House is a trademark of Antenna House, Inc.
URL : http://www.antenna.co.jp/
**************************************************************
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    exclude-result-prefixes="#all"
    version="3.0">

    <!--Debugging switch for section information grouping -->
    <xsl:param name="PRM_DEBUG_SECT" as="xs:string" required="no" select="$cYes"/>
    <xsl:variable name="pDebugSect" as="xs:boolean" select="$PRM_DEBUG_SECT eq $cYes"/>

    <!--
    function:   Construct main content, multi column, break information
    param:      none
    return:     
    note:       Generate main content, column count, break information from topicref, topic, image.
                - Frontmatter is not main content. Others are assumed as main content.
                - Chapter,part,appendix should be 1 column and apply page break.
                  Breaking in top level topicrefs in map is controlled by parameter $PRM_BREAK_IN_TOP_TOPICREF
                - Decide column count for other topicrefs.
                  If topicref has no @href, it is treated as topichead.
    -->
    
    <!-- Breaking constants -->
    <xsl:variable name="cBreakAuto"   as="xs:integer" select="0"/>
    <xsl:variable name="cBreakPage"   as="xs:integer" select="1"/>
    <xsl:variable name="cBreakColumn" as="xs:integer" select="2"/>
    <xsl:variable name="cBreakEven"   as="xs:integer" select="3"/>
    <xsl:variable name="cBreakOdd"    as="xs:integer" select="4"/>
    <xsl:variable name="cBreakInfoSeq" as="xs:integer+" select="($cBreakAuto,$cBreakPage,$cBreakColumn)"/>
    
    <!-- Content Key -->
    <xsl:variable name="cContentFrontmatter" as="xs:integer" select="0"/>
    <xsl:variable name="cContentMain"        as="xs:integer" select="1"/>
    
    <xsl:variable name="columnMapTreeOrg" as="document-node()">
        <xsl:document>
           <xsl:apply-templates select="$map/*[contains(@class,' map/topicref ')]" mode="MODE_MAKE_SECT_INFO"/>
        </xsl:document>
    </xsl:variable>

    <xsl:template match="*[contains(@class,' bookmap/frontmatter ')]" mode="MODE_MAKE_SECT_INFO" priority="5">
        <xsl:apply-templates select="*[contains(@class,' map/topicref ')]" mode="#current">
            <xsl:with-param name="prmIsInFrontMatter" tunnel="yes" select="true()"/>
        </xsl:apply-templates>
    </xsl:template>

    <xsl:template match="*[contains(@class,' bookmap/backmatter ')]" mode="MODE_MAKE_SECT_INFO" priority="5">
        <xsl:apply-templates select="*[contains(@class,' map/topicref ')]" mode="#current"/>
    </xsl:template>

    <xsl:template match="*[contains(@class,' bookmap/booklists ')]" mode="MODE_MAKE_SECT_INFO" priority="5">
        <xsl:apply-templates select="*[contains(@class,' map/topicref ')]" mode="#current"/>
    </xsl:template>
    
    <xsl:template match="*[contains(@class,' map/topicref ')]" mode="MODE_MAKE_SECT_INFO">
        <xsl:param name="prmIsInFrontMatter" tunnel="yes" required="false" select="false()"/>
        <xsl:variable name="columnInfo" as="item()+" select="ahf:getColumnInfo(.)"/>
        <xsl:variable name="breakInfo" as="xs:integer" select="ahf:getBreakInfo(.)"/>
        <xsl:choose>
            <xsl:when test="($columnInfo[1] eq 0)">
                <topichead>
                    <xsl:attribute name="column" select="$columnInfo[1]"/>
                    <xsl:attribute name="id" select="$columnInfo[2]"/>
                    <xsl:attribute name="break" select="$breakInfo"/>
                    <xsl:attribute name="contentkey" select="if ($prmIsInFrontMatter) then '0' else '1'"/>
                    <xsl:attribute name="xpath" select="ahf:getNodeXPathStr(.)"/>
                    <xsl:attribute name="navtitle" select="string(@navtitle)"/>
                    <xsl:attribute name="colsep" select="$columnInfo[4]"/>
                </topichead>
                <xsl:apply-templates select="*[contains(@class,' map/topicref ')]" mode="#current"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="topic" as="element()?" select="$columnInfo[5]"/>
                <topicref>
                    <xsl:attribute name="column" select="$columnInfo[1]"/>
                    <xsl:attribute name="id" select="$columnInfo[2]"/>
                    <xsl:attribute name="oid" select="$columnInfo[3]"/>
                    <xsl:attribute name="xpath" select="ahf:getNodeXPathStr(if (exists($topic)) then $topic else .)"/>
                    <xsl:attribute name="break">
                        <xsl:choose>
                            <xsl:when test="($breakInfo eq $cBreakAuto)">
                                <xsl:value-of select="ahf:getBreakInfo($topic)"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$breakInfo"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                    <xsl:attribute name="contentkey" select="if ($prmIsInFrontMatter) then '0' else '1'"/>
                    <xsl:attribute name="navtitle">
                        <xsl:choose>
                            <xsl:when test="exists(*[contains(@class,' map/topicmeta ')]/*[contains(@class,' topic/navtitle ')])">
                                <xsl:value-of select="string(*[contains(@class,' map/topicmeta ')]/*[contains(@class,' topic/navtitle ')])"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="@navtitle"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                    <xsl:attribute name="colsep" select="$columnInfo[4]"/>
                    <xsl:attribute name="href" select="string(@href)"/>
                </topicref>
                <!-- body & related-links -->
                <xsl:if test="ahf:shouldProcessBodyAndRelatdLinks(.)">
                    <xsl:apply-templates select="$topic/*[contains(@class,' topic/body ')]" mode="#current">
                        <xsl:with-param name="prmTopicRef" select="."/>
                    </xsl:apply-templates>
                    <xsl:apply-templates select="$topic/*[contains(@class,' topic/related-links ')]" mode="#current">
                        <xsl:with-param name="prmTopicRef" select="."/>
                    </xsl:apply-templates>
                </xsl:if>
                <!-- nested topic-->
                <xsl:apply-templates select="$topic/*[contains(@class,' topic/topic ')]" mode="#current">
                    <xsl:with-param name="prmTopicRef" select="."/>
                </xsl:apply-templates>
                <xsl:apply-templates select="*[contains(@class,' map/topicref ')]" mode="#current"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- 
     function:	Check the requirement for process body and related-links
     param:		prmTopicRef
     return:	xs:boolean
     note:		
     -->
    <xsl:function name="ahf:shouldProcessBodyAndRelatdLinks" as="xs:boolean">
        <xsl:param name="prmTopicRef" as="element()"/>
        <xsl:sequence select="true()"/>
    </xsl:function>    
    
    <!-- topic/body -->
    <xsl:template match="*[contains(@class,' topic/body ')]" mode="MODE_MAKE_SECT_INFO">
        <xsl:param name="prmTopicRef" as="element()" required="yes"/>
        <xsl:param name="prmIsInFrontMatter" tunnel="yes" required="false" select="false()"/>
        <xsl:variable name="body" as="element()" select="."/>
        <xsl:variable name="columnInfo3" as="item()+" select="ahf:getColumnInfo3($prmTopicRef,$body)"/>
        <xsl:variable name="spanImage" as="element()*" select="$body/descendant::*[contains(@class,' topic/image ')][string(@placement) eq 'break'][ahf:isSpannedImage(.)]"/>
        <body>
            <xsl:attribute name="column" select="$columnInfo3[1]"/>
            <xsl:attribute name="id" select="$columnInfo3[2]"/>
            <xsl:attribute name="break" select="$cBreakAuto"/>
            <xsl:attribute name="contentkey" select="if ($prmIsInFrontMatter) then '0' else '1'"/>
            <xsl:attribute name="xpath" select="ahf:getNodeXPathStr($body)"/>
            <xsl:attribute name="colsep" select="$columnInfo3[3]"/>
        </body>
        <xsl:apply-templates select="$spanImage" mode="#current">
            <xsl:with-param name="prmTopicRef" select="$prmTopicRef"/>
        </xsl:apply-templates>
    </xsl:template>

    <!-- topic/related-links -->
    <xsl:template match="*[contains(@class,' topic/related-links ')]" mode="MODE_MAKE_SECT_INFO">
        <xsl:param name="prmTopicRef" as="element()" required="yes"/>
        <xsl:param name="prmIsInFrontMatter" tunnel="yes" required="false" select="false()"/>
        <xsl:variable name="relatedLinks" as="element()" select="."/>
        <xsl:variable name="columnInfo4" as="item()+" select="ahf:getColumnInfo4($prmTopicRef,$relatedLinks)"/>
        <related-links>
            <xsl:attribute name="column" select="$columnInfo4[1]"/>
            <xsl:attribute name="id" select="$columnInfo4[2]"/>
            <xsl:attribute name="break" select="$cBreakAuto"/>
            <xsl:attribute name="contentkey" select="if ($prmIsInFrontMatter) then '0' else '1'"/>
            <xsl:attribute name="xpath" select="ahf:getNodeXPathStr($relatedLinks)"/>
            <xsl:attribute name="colsep" select="$columnInfo4[3]"/>
        </related-links>
    </xsl:template>
    
    <!-- Image that span columns -->
    <xsl:template match="*[contains(@class,' topic/image ')][string(@placement) eq 'break'][ahf:isSpannedImage(.)]" mode="MODE_MAKE_SECT_INFO" priority="5">
        <xsl:param name="prmIsInFrontMatter" tunnel="yes" required="false" select="false()"/>
        <xsl:param name="prmTopicRef" as="element()" required="yes"/>
        <image>
            <xsl:attribute name="column" select="'1'"/>
            <xsl:attribute name="id" select="ahf:generateId(.)"/>
            <xsl:attribute name="break" select="$cBreakAuto"/>
            <xsl:attribute name="contentkey" select="if ($prmIsInFrontMatter) then '0' else '1'"/>
            <xsl:attribute name="xpath" select="ahf:getNodeXPathStr(.)"/>
            <xsl:attribute name="colsep" select="ahf:getColSepSpecFromTopicRef($prmTopicRef)"/>
        </image>
    </xsl:template>

    <!-- 
     function:	Check column span image
     param:		prmImage
     return:	xs:boolean
     note:		
     -->
    <xsl:function name="ahf:isSpannedImage" as="xs:boolean">
        <xsl:param name="prmImage" as="element()"/>
        <xsl:sequence select="ahf:hasOutputclassValue($prmImage,'span-all')"/>
    </xsl:function>    

    <!--General image-->
    <xsl:template match="*[contains(@class,' topic/image ')][string(@placement) eq 'break'][empty(ancestor::*[ahf:seqContains(string(@class),(' floatfig-d/floatfig ',' floatfig-d/floatfig-group '))][string(@float) = ('left','right')])]" mode="MODE_MAKE_SECT_INFO">
        <xsl:param name="prmIsInFrontMatter" tunnel="yes" required="false" select="false()"/>
        <xsl:param name="prmTopicRef" as="element()" required="yes"/>
        <image>
            <xsl:attribute name="column" select="'0'"/>
            <xsl:attribute name="id" select="ahf:generateId(.)"/>
            <xsl:attribute name="break" select="$cBreakAuto"/>
            <xsl:attribute name="contentkey" select="if ($prmIsInFrontMatter) then '0' else '1'"/>
            <xsl:attribute name="xpath" select="ahf:getNodeXPathStr(.)"/>
            <xsl:attribute name="colsep" select="ahf:getColSepSpecFromTopicRef($prmTopicRef)"/>
        </image>
    </xsl:template>

    <!-- Nested topic -->
    <xsl:template match="*[contains(@class,' topic/topic ')]" mode="MODE_MAKE_SECT_INFO">
        <xsl:param name="prmIsInFrontMatter" tunnel="yes" required="false" select="false()"/>
        <xsl:param name="prmTopicRef" as="element()" required="yes"/>
        <xsl:variable name="topic" as="element()" select="."/>
        <xsl:variable name="topicRefBreakInfo" as="xs:integer" select="ahf:getBreakInfo($prmTopicRef)"/>
        <xsl:variable name="columnInfo2" as="item()+" select="ahf:getColumnInfo2($prmTopicRef,$topic)"/>
        <topic>
            <xsl:attribute name="column" select="$columnInfo2[1]"/>
            <xsl:attribute name="title" select="string(*[contains(@class,' topic/title ')])"/>
            <xsl:attribute name="id" select="$columnInfo2[2]"/>
            <xsl:attribute name="oid" select="$columnInfo2[3]"/>
            <xsl:attribute name="break">
                <xsl:choose>
                    <xsl:when test="$topic/ancestor::*[contains(@class,' topic/topic ')]">
                        <xsl:value-of select="ahf:getBreakInfo($topic)"/>
                    </xsl:when>
                    <xsl:when test="($topicRefBreakInfo eq $cBreakAuto)">
                        <xsl:value-of select="ahf:getBreakInfo($topic)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$topicRefBreakInfo"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:attribute name="contentkey" select="if ($prmIsInFrontMatter) then '0' else '1'"/>
            <xsl:attribute name="xpath" select="ahf:getNodeXPathStr($topic)"/>
            <xsl:attribute name="colsep" select="$columnInfo2[4]"/>
        </topic>
        <!-- body & related-links -->
        <xsl:if test="ahf:shouldProcessBodyAndRelatdLinks($prmTopicRef)">
            <xsl:apply-templates select="$topic/*[contains(@class,' topic/body ')]" mode="#current">
                <xsl:with-param name="prmTopicRef" select="$prmTopicRef"/>
            </xsl:apply-templates>
            <xsl:apply-templates select="$topic/*[contains(@class,' topic/related-links ')]" mode="#current">
                <xsl:with-param name="prmTopicRef" select="$prmTopicRef"/>
            </xsl:apply-templates>
        </xsl:if>
        <!-- More nested topic -->
        <xsl:apply-templates select="*[contains(@class,' topic/topic ')]" mode="#current">
            <xsl:with-param name="prmTopicRef" select="$prmTopicRef"/>
        </xsl:apply-templates>
    </xsl:template>

    <!-- 
     function:	Get column(1 or 2) and other key information from topicref or referenced topic.
     param:		prmTopicRef
     return:	item()+
                item()[1]: xs:integer 1 is 1 column. 2 is 2 column. 0 is undefined.
                item()[2]: xs:string unique id of topic
                item()[3]: xs:string topic/@oid (for debug)
                itme()[4]: xs:integer column separator 0 or 1
                item()[5]: element() topic
     note:		Column of topichead is assumed as unknown (0).
                Chapter is 1 column without no consideration.
                Glossentry as descendant of booklists/glossarylist is assumed as 2 column unconditionally.
     -->
    <xsl:function name="ahf:getColumnInfo" as="item()+">
        <xsl:param name="prmTopicRef" as="element()"/>
        <xsl:variable name="topicRefColSpec" as="xs:string" select="ahf:getColSpecFromElem($prmTopicRef)"/>
        <xsl:variable name="topicRefColSepSpec" as="xs:integer" select="ahf:getColSepSpecFromTopicRef($prmTopicRef)"/>
        <xsl:variable name="topic" select="ahf:getTopicFromTopicRef($prmTopicRef)" as="element()?"/>
        <xsl:choose>
            <xsl:when test="exists($prmTopicRef/@href) and exists($topic)">
                <xsl:choose>
                    <xsl:when test="$prmTopicRef[contains(@class,' bookmap/chapter ')]">
                        <xsl:sequence select="(1,ahf:generateId($topic),string($topic/@oid),$topicRefColSepSpec,$topic)"/>
                    </xsl:when>
                    <xsl:when test="$prmTopicRef/ancestor::*[contains(@class,' bookmap/glossarylist ')]">
                        <xsl:sequence select="(2,ahf:generateId($topic),string($topic/@oid),$topicRefColSepSpec,$topic)"/>
                    </xsl:when>
                    <xsl:when test="$topicRefColSpec ne ''">
                        <xsl:sequence select="(xs:integer($topicRefColSpec),ahf:generateId($topic),string($topic/@oid),$topicRefColSepSpec,$topic)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:variable name="topicColSpec" as="xs:string" select="ahf:getColSpecFromElem($topic)"/>
                        <xsl:choose>
                            <xsl:when test="$topicColSpec ne ''">
                                <xsl:sequence select="(xs:integer($topicColSpec),ahf:generateId($topic),string($topic/@oid),$topic,$topicRefColSepSpec)"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:sequence select="(1,ahf:generateId($topic),string($topic/@oid),$topicRefColSepSpec,$topic)"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="$prmTopicRef[contains(@class,' bookmap/chapter ')]">
                        <xsl:sequence select="(1,ahf:generateId($prmTopicRef),'',$topicRefColSepSpec,())"/>
                    </xsl:when>
                    <xsl:when test="$prmTopicRef[contains(@class,' bookmap/indexlist ')]">
                        <xsl:sequence select="(1,ahf:generateId($prmTopicRef),'',$topicRefColSepSpec,())"/>
                    </xsl:when>
                    <xsl:when test="$prmTopicRef[contains(@class,' bookmap/toc ')]">
                        <xsl:sequence select="(1,ahf:generateId($prmTopicRef),'',$topicRefColSepSpec,())"/>
                    </xsl:when>
                    <xsl:when test="$prmTopicRef[contains(@class,' bookmap/glossarylist ')]">
                        <xsl:sequence select="(1,ahf:generateId($prmTopicRef),'',$topicRefColSepSpec,())"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:sequence select="(0,ahf:generateId($prmTopicRef),'',$topicRefColSepSpec,())"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>    

    <!-- For nested topic 
         item()[1]: xs:integer column count
         item()[2]: xs:string  id 
         item()[3]: xs:string  oid 
         item()[4]: xs:integer column separator
     -->
    <xsl:function name="ahf:getColumnInfo2" as="item()+">
        <xsl:param name="prmTopicRef" as="element()"/>
        <xsl:param name="prmTopic" as="element()"/>
        <xsl:variable name="topicRefColSpec" as="xs:string" select="ahf:getColSpecFromElem($prmTopicRef)"/>
        <xsl:variable name="topicRefColSepSpec" as="xs:integer" select="ahf:getColSepSpecFromTopicRef($prmTopicRef)"/>
        <xsl:choose>
            <xsl:when test="$topicRefColSpec ne ''">
                <xsl:sequence select="(xs:integer($topicRefColSpec),ahf:generateId($prmTopic),string($prmTopic/@oid),$topicRefColSepSpec)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="topicColSpec" as="xs:string" select="ahf:getColSpecFromElem($prmTopic)"/>
                <xsl:choose>
                    <xsl:when test="$topicColSpec ne ''">
                        <xsl:sequence select="(xs:integer($topicColSpec),ahf:generateId($prmTopic),string($prmTopic/@oid),$topicRefColSepSpec)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:sequence select="(1,ahf:generateId($prmTopic),string($prmTopic/@oid),$topicRefColSepSpec)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>    
    
    <!-- For body
         item()[1]: xs:integer column count
         item()[2]: xs:string  id 
         item()[3]: xs:integer column separator
     -->
    <xsl:function name="ahf:getColumnInfo3" as="item()*">
        <xsl:param name="prmTopicRef" as="element()"/>
        <xsl:param name="prmBody" as="element()"/>
        <xsl:variable name="bodyColSpec" as="xs:string" select="ahf:getColSpecFromElem($prmBody)"/>
        <xsl:variable name="topicRefColSepSpec" as="xs:integer" select="ahf:getColSepSpecFromTopicRef($prmTopicRef)"/>
        <xsl:choose>
            <xsl:when test="$bodyColSpec ne ''">
                <xsl:sequence select="(xs:integer($bodyColSpec),ahf:generateId($prmBody),$topicRefColSepSpec)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="topicRefColSpec" as="xs:string" select="ahf:getColSpecFromElem($prmTopicRef)"/>
                <xsl:choose>
                    <xsl:when test="$topicRefColSpec ne ''">
                        <xsl:sequence select="(xs:integer($topicRefColSpec),ahf:generateId($prmBody),$topicRefColSepSpec)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:sequence select="(1,ahf:generateId($prmBody),$topicRefColSepSpec)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>    
    
    <!-- For related-links
         item()[1]: xs:integer  column count
         item()[2]: xs:string   id
         item()[3]: xs:integer  column separator
         related-links inherits body column
     -->
    <xsl:function name="ahf:getColumnInfo4" as="item()*">
        <xsl:param name="prmTopicRef" as="element()"/>
        <xsl:param name="prmRelatdLinks" as="element()"/>
        <xsl:variable name="body" as="element()?" select="$prmRelatdLinks/preceding-sibling::*[contains(@class,' topic/body ')][1]"/>
        <xsl:variable name="bodyColSpec" as="xs:string" select="if (exists($body)) then ahf:getColSpecFromElem($body) else ''"/>
        <xsl:variable name="topicRefColSepSpec" as="xs:integer" select="ahf:getColSepSpecFromTopicRef($prmTopicRef)"/>
        <xsl:choose>
            <xsl:when test="$bodyColSpec ne ''">
                <xsl:sequence select="(xs:integer($bodyColSpec),ahf:generateId($prmRelatdLinks),$topicRefColSepSpec)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="topicRefColSpec" as="xs:string" select="ahf:getColSpecFromElem($prmTopicRef)"/>
                <xsl:choose>
                    <xsl:when test="$topicRefColSpec ne ''">
                        <xsl:sequence select="(xs:integer($topicRefColSpec),ahf:generateId($prmRelatdLinks),$topicRefColSepSpec)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:sequence select="(1,ahf:generateId($prmRelatdLinks),$topicRefColSepSpec)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <!--
    function:   Get column spec from element (topicref, topic, body)
    param:      prmElem 
    return:     xs:string
    note:       '' means no specification for column
    -->
    <xsl:function name="ahf:getColSpecFromElem" as="xs:string">
        <xsl:param name="prmElem" as="element()"/>
        <xsl:sequence select="ahf:getOutputClassRegx($prmElem,'(\d+)(-col)','$1')"/>
    </xsl:function>
    
    <!--
    function:   Get column separator spec from topicref
    param:      prmTopicRef 
    return:     xs:integer 1 means that have column separator. 0 means that does not have column separator
    note:       Temporary only glossary does not have column separator. Other two column such as task has separator.
    -->
    <xsl:function name="ahf:getColSepSpecFromTopicRef" as="xs:integer">
        <xsl:param name="prmTopicRef" as="element()"/>
        <xsl:sequence select="if ($prmTopicRef/ancestor::*[contains(@class,' bookmap/glossarylist ')]) then 0 else 1"/>
    </xsl:function>
    
    <!--
    function:   Get break information for chapter level element
    param:      prmElem (topic or topicref)
    return:     xs:integer
    note:       
    -->
    <xsl:function name="ahf:getBreakInfo" as="xs:integer">
        <xsl:param name="prmElem" as="element()?"/>
        <xsl:variable name="cBreakSpecSeq" as="xs:string+" select="('auto','page','col')"/>
        <xsl:choose>
            <xsl:when test="exists($prmElem)">
                <xsl:variable name="break" as="xs:string" select="ahf:getOutputClassRegx($prmElem,'(break-)(auto|page|col)','$2')"/>
                <xsl:variable name="breakIndex" as="xs:integer?" select="index-of($cBreakSpecSeq,$break)"/>
                <xsl:choose>
                    <xsl:when test="$prmElem[ahf:seqContains(@class,(' bookmap/part ',' bookmap/chapter ',' bookmap/appendix ',' bookmap/toc ',' bookmap/indexlist',' bookmap/glossarylist '))][empty(parent::*[contains(@class,' bookmap/part ')])]">
                        <xsl:sequence select="ahf:getPageSpecInfo($prmElem)"/>
                    </xsl:when>
                    <xsl:when test="exists($breakIndex)">
                        <xsl:sequence select="$cBreakInfoSeq[$breakIndex]"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:sequence select="$cBreakAuto"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="$cBreakAuto"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <!--
    function:   Get page number information for topic & topicref
    param:      prmElem (topic or topicref)
    return:     xs:integer
    note:       
    -->
    <xsl:function name="ahf:getPageSpecInfo" as="xs:integer">
        <xsl:param name="prmElem" as="element()"/>
        <xsl:variable name="page" as="xs:string" select="ahf:getOutputClassRegx($prmElem,'(page-number-)(auto|even|odd)','$2')"/>
        <xsl:choose>
            <xsl:when test="$page eq 'auto'">
                <xsl:sequence select="$cBreakPage"/>
            </xsl:when>
            <xsl:when test="$page eq 'even'">
                <xsl:sequence select="$cBreakEven"/>
            </xsl:when>
            <xsl:when test="$page eq 'odd'">
                <xsl:sequence select="$cBreakOdd"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="$cBreakPage"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <!--
    function:   Complement topichead column number
    param:      none
    return:     xsl:document
    note:       topichead continues previous column information value.
    -->
    <xsl:variable name="columnMapTreeComplement" as="document-node()">
        <xsl:document>
            <xsl:apply-templates select="$columnMapTreeOrg/*" mode="MODE_COMPLEMENT_SPAN_INFO"/>
        </xsl:document>
    </xsl:variable>
    
    <xsl:template match="*" mode="MODE_COMPLEMENT_SPAN_INFO">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
        </xsl:copy>
        <!--xsl:apply-templates mode="#current"/-->
    </xsl:template>
    
    <!-- complement topichead column information-->
    <xsl:template match="topichead" mode="MODE_COMPLEMENT_SPAN_INFO" priority="5">
        <xsl:variable name="topicHead" as="element()" select="."/>
        <xsl:variable name="nearestNonTopicHead" as="element()?" select="($topicHead/preceding-sibling::*[not(self::image)][string(@column) ne '0'])[last()]"/>
        <xsl:variable name="column" as="xs:string" select="if (exists($nearestNonTopicHead)) then $nearestNonTopicHead/@column/string(.) else '1'"/>
        <xsl:copy>
            <xsl:attribute name="column" select="$column"/>
            <xsl:copy-of select="@* except @column"/>
            <!--xsl:apply-templates mode="#current"/-->
        </xsl:copy>
    </xsl:template>

    <!-- complement image column information -->
    <xsl:template match="image[string(@column) eq '0']" mode="MODE_COMPLEMENT_SPAN_INFO" priority="5">
        <xsl:variable name="image" as="element()" select="."/>
        <xsl:variable name="body" as="element()?" select="$image/parent::body"/>
        <xsl:variable name="column" as="xs:string" select="string($body/@column)"/>
        <xsl:copy>
            <xsl:attribute name="column" select="$column"/>
            <xsl:copy-of select="@* except @column"/>
            <!--xsl:apply-templates mode="#current"/-->
        </xsl:copy>
    </xsl:template>

    <!--
    function:   Column map tree with adjacent information
    param:      none
    return:     document-node
    note:       
    -->
    <xsl:variable name="columnMapTreeWithAdjacentInfo" as="document-node()">
        <xsl:document>
            <xsl:apply-templates select="$columnMapTreeComplement/*" mode="MODE_ADD_ADJACENT_INFO"/>
        </xsl:document>
    </xsl:variable>
    
    <xsl:template match="*" mode="MODE_ADD_ADJACENT_INFO">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="topicref|topichead" mode="MODE_ADD_ADJACENT_INFO">
        <xsl:variable name="elem" as="element()" select="."/>
        <xsl:variable name="prev" as="element()?" select="$elem/preceding-sibling::*[1]"/>
        <xsl:variable name="next" as="element()?" select="$elem/following-sibling::*[1]"/>
        <xsl:variable name="prevColumn" as="xs:integer" select="if (exists($prev)) then $prev/@column/xs:integer(.) else 0"/>
        <xsl:variable name="nextColumn" as="xs:integer" select="if (exists($next)) then $next/@column/xs:integer(.) else 0"/>
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="prev-column" select="string($prevColumn)"/>
            <xsl:attribute name="next-column" select="string($nextColumn)"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="body|topic|related-links" mode="MODE_ADD_ADJACENT_INFO">
        <xsl:variable name="elem" as="element()" select="."/>
        <xsl:variable name="prev" as="element()?" select="$elem/preceding-sibling::*[1]"/>
        <xsl:variable name="next" as="element()?" select="$elem/following-sibling::*[1]"/>
        <xsl:variable name="prevColumn" as="xs:integer" select="if (exists($prev)) then $prev/@column/xs:integer(.) else 0"/>
        <xsl:variable name="nextColumn" as="xs:integer" select="if (exists($next)) then $next/@column/xs:integer(.) else 0"/>
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="prev-column" select="string($prevColumn)"/>
            <xsl:attribute name="next-column" select="string($nextColumn)"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="image" mode="MODE_ADD_ADJACENT_INFO">
        <xsl:variable name="elem" as="element()" select="."/>
        <xsl:variable name="prev" as="element()?" select="$elem/preceding-sibling::*[1]"/>
        <xsl:variable name="next" as="element()?" select="$elem/following-sibling::*[1]"/>
        <xsl:variable name="prevColumn" as="xs:integer" select="if (exists($prev)) then $prev/@column/xs:integer(.) else 0"/>
        <xsl:variable name="nextColumn" as="xs:integer" select="if (exists($next)) then $next/@column/xs:integer(.) else 0"/>
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="prev-column" select="string($prevColumn)"/>
            <xsl:attribute name="next-column" select="string($nextColumn)"/>
        </xsl:copy>
    </xsl:template>
    
    <!--
    function:   Section map
    param:      none
    return:     map(xs:string, xs:integer+)
    note:       Made from $columnMapTree by grouping content/column/break key change
                Column count may be 1 or 2.
                Break keys are column, page. auto. Group it column with follwoing auto or oage with following auto.
                This grouping is needed to construct two column layout in Word.
    -->
    <xsl:variable name="sectMap" as="map(xs:string,xs:integer+)">
        <xsl:variable name="sectMapElems" as="element()+" select="$columnMapTreeWithAdjacentInfo/*"/>
        <xsl:variable name="sectMapElemsTree" as="document-node()">
            <xsl:document>
                <xsl:for-each select="$sectMapElems">
                    <xsl:copy>
                        <xsl:copy-of select="@*"/>
                    </xsl:copy>
                </xsl:for-each>
            </xsl:document>
        </xsl:variable>
        <xsl:map>
            <xsl:for-each-group select="$sectMapElemsTree/*" group-adjacent="ahf:genSectContentKey(.)">
                <xsl:variable name="sectContentGroup" as="element()+" select="current-group()"/>
                <xsl:variable name="sectContentKey" as="xs:string" select="current-grouping-key()"/>
                <xsl:message select="'[sectMap] current-content-grouping-key()=',$sectContentKey"/>
                <xsl:for-each-group select="$sectContentGroup" group-adjacent="ahf:genSectGroupKey(.)">
                    <xsl:variable name="sectGroup" as="element()+" select="current-group()"/>
                    <xsl:variable name="seqInSectGroup" as="xs:integer" select="position()"/>
                    <xsl:variable name="sectGroupStart" as="element()" select="$sectGroup[1]"/>
                    <xsl:variable name="sectGroupEnd" as="element()" select="$sectGroup[last()]"/>
                    <xsl:if test="$pDebugSect">
                        <xsl:message select="'[sectMap] current-grouping-key()=',current-grouping-key()"/>
                        <xsl:message select="'[sectMap] current-group()=',current-group()"/>
                    </xsl:if>
                    <xsl:variable name="id" select="string($sectGroupEnd/@id)"/>
                    <xsl:variable name="currentColumn" as="xs:integer" select="xs:integer($sectGroupEnd/@column)"/>
                    <xsl:variable name="prevColumn" as="xs:integer" select="xs:integer($sectGroupStart/@prev-column)"/>
                    <xsl:variable name="nextColumn" as="xs:integer" select="xs:integer($sectGroupEnd/@next-column)"/>
                    <xsl:variable name="break" as="xs:integer" select="xs:integer($sectGroupStart/@break)"/>
                    <xsl:variable name="content" as="xs:integer" select="xs:integer($sectContentKey)"/>
                    <xsl:variable name="colsep" as="xs:integer" select="xs:integer($sectGroupStart/@colsep)"/>
                    <xsl:variable name="seq" as="xs:integer" select="$seqInSectGroup"/>
                    <xsl:map-entry key="$id" select="($prevColumn,$currentColumn,$nextColumn,$break,$content,$colsep,$seq)"/>
                </xsl:for-each-group>
            </xsl:for-each-group>
        </xsl:map>
    </xsl:variable>

    <!--
    function:   Generate sect content key
    param:      prmElement
    return:     xs:string
    note:       returns content grouping key
                
    -->
    <xsl:function name="ahf:genSectContentKey" as="xs:string">
        <xsl:param name="prmElem" as="element()"/>
        <xsl:variable name="contentKey" as="xs:string" select="$prmElem/@contentkey/string(.)"/>
        <xsl:sequence select="$contentKey"/>
    </xsl:function>
    
    <!--
    function:   Generate sect grouping key
    param:      prmElement
    return:     xs:string
    note:       returns grouping key
    -->
    <xsl:function name="ahf:genSectGroupKey" as="xs:string">
        <xsl:param name="prmElem" as="element()"/>
        <xsl:variable name="columnKey" as="xs:integer" select="ahf:genColumnGroupKey($prmElem)"/>
        <xsl:variable name="columnKeyStr" as="xs:string" select="format-integer($columnKey,'00000')"/>
        <xsl:variable name="colSepKey" as="xs:string" select="string($prmElem/@colsep)"/>
        <xsl:variable name="breakKey" as="xs:integer" select="ahf:genBreakGroupKey($prmElem)"/>
        <xsl:variable name="breakKeyStr" as="xs:string" select="format-integer($breakKey,'00000')"/>
        <xsl:sequence select="concat($columnKeyStr,' ',$colSepKey,' ',$breakKeyStr)"/>
    </xsl:function>
    
    <!--
    function:   Generate column grouping key
    param:      prmElement
    return:     xs:integer
    note:       returns grouping number
                group by column count change
    -->
    <xsl:function name="ahf:genColumnGroupKey" as="xs:integer">
        <xsl:param name="prmElem" as="element()"/>
        <xsl:variable name="columnKey" as="xs:integer" select="count(($prmElem|$prmElem/preceding-sibling::*)[string(@prev-column) ne string(@column)])"/>
        <xsl:sequence select="$columnKey"/>
    </xsl:function>

    <!--
    function:   Generate break grouping key
    param:      prmElement
    return:     xs:integer
    note:       returns grouping number
                group by page break or column break that follows any non-break (auto) key 
    -->
    <xsl:function name="ahf:genBreakGroupKey" as="xs:integer">
        <xsl:param name="prmElem" as="element()"/>
        <xsl:variable name="breakKey" as="xs:integer" select="count(($prmElem|$prmElem/preceding-sibling::*)[xs:integer(string(@break)) = ($cBreakPage,$cBreakColumn,$cBreakEven,$cBreakOdd)])"/>
        <xsl:sequence select="$breakKey"/>
    </xsl:function>

    <!--
    function:   Column map
    param:      none
    return:     map(xs:string, xs:integer+)
    note:       Made from $columnMapTree
                Used to get column information from any element.
    -->
    <xsl:variable name="columnMap" as="map(xs:string,xs:integer+)">
        <xsl:variable name="columnMapElems" as="element()+" select="$columnMapTreeWithAdjacentInfo/*"/>
        <xsl:map>
            <xsl:for-each select="$columnMapElems">
                <xsl:variable name="columnMapElem" as="element()" select="."/>
                <xsl:variable name="id" select="string($columnMapElem/@id)"/>
                <xsl:variable name="currentColumn" as="xs:integer" select="xs:integer($columnMapElem/@column)"/>
                <xsl:variable name="prevColumn" as="xs:integer" select="xs:integer($columnMapElem/@prev-column)"/>
                <xsl:variable name="nextColumn" as="xs:integer" select="xs:integer($columnMapElem/@next-column)"/>
                <xsl:variable name="colsep" as="xs:integer" select="xs:integer($columnMapElem/@colsep)"/>
                <xsl:variable name="break" as="xs:integer" select="xs:integer($columnMapElem/@break)"/>
                <xsl:map-entry key="$id" select="($prevColumn,$currentColumn,$nextColumn,$colsep,$break)"/>
            </xsl:for-each>
        </xsl:map>
    </xsl:variable>

    <!--
    function:   Dump column map tree
    param:      none
    return:     ColumnMapTree.xml
    note:       
    -->
    <xsl:template name="columnMapTreeDump">
        <xsl:result-document href="{concat($pTempDirUrl,'/ColumnMapTree.xml')}" encoding="UTF-8" indent="yes">
            <map>
                <xsl:copy-of select="$columnMapTreeWithAdjacentInfo"/>
            </map>
        </xsl:result-document>
    </xsl:template>

    <!--
    function:   Dump column map in document order
    param:      none
    return:     ColumnMap.xml
    note:       
    -->
    <xsl:template name="sectMapDump">
        <xsl:variable name="sectMapElems" as="element()+" select="$columnMapTreeWithAdjacentInfo/*/descendant::*"/>
        <xsl:variable name="sectMapElemsTree" as="document-node()">
            <xsl:document>
                <xsl:for-each select="$sectMapElems">
                    <xsl:copy>
                        <xsl:copy-of select="@*"/>
                    </xsl:copy>
                </xsl:for-each>
            </xsl:document>
        </xsl:variable>
        <xsl:result-document href="{concat($pTempDirUrl,'/SectMap.xml')}" encoding="UTF-8" indent="yes">
            <xsl:variable name="dumpData" as="element()+">
                <xsl:variable name="mapEntrySeq" as="xs:string+" 
                    select="map:for-each($sectMap,function($k, $v){(string($k),string($v[1]),string($v[2]),string($v[3]),string($v[4]),string($v[5]),string($v[6]),string($v[7]))})"/>
                <xsl:for-each select="1 to (xs:integer(count($mapEntrySeq) div 8))">
                    <xsl:variable name="pos" as="xs:integer" select="(. - 1) * 8 + 1"/>
                    <entry key="{$mapEntrySeq[$pos]}" prev="{$mapEntrySeq[$pos + 1]}" current="{$mapEntrySeq[$pos + 2]}" next="{$mapEntrySeq[$pos + 3]}" 
                           break="{$mapEntrySeq[$pos + 4]}" content="{$mapEntrySeq[$pos + 5]}" colsep="{$mapEntrySeq[$pos + 6]}" seq="{$mapEntrySeq[$pos + 7]}"/>
                </xsl:for-each>
            </xsl:variable>
            <map>
                <xsl:for-each select="$dumpData">
                    <xsl:copy-of select="."/>
                </xsl:for-each>
            </map>
        </xsl:result-document>
    </xsl:template>

    <!-- END OF STYLESHEET -->
</xsl:stylesheet>