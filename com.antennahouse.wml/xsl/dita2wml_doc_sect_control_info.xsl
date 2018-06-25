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
    <xsl:variable name="cBreakInfoSeq" as="xs:integer+" select="($cBreakAuto,$cBreakPage,$cBreakColumn)"/>
    
    <!--xsl:variable name="cBreakInfoSeqInAuthoring" as="xs:string+" select="('auto','page','column')"/-->
    
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
                    <xsl:attribute name="maincontent" select="if ($prmIsInFrontMatter) then '0' else '1'"/>
                    <xsl:attribute name="xpath" select="ahf:getNodeXPathStr(.)"/>
                    <xsl:attribute name="navtitle" select="string(@navtitle)"/>
                </topichead>
                <xsl:apply-templates select="*[contains(@class,' map/topicref ')]" mode="#current"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="topic" as="element()?" select="$columnInfo[4]"/>
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
                    <xsl:attribute name="maincontent" select="if ($prmIsInFrontMatter) then '0' else '1'"/>
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
                    <xsl:attribute name="href" select="string(@href)"/>
                </topicref>
                <!-- body -->
                <xsl:apply-templates select="$topic/*[contains(@class,' topic/body ')]" mode="#current">
                    <xsl:with-param name="prmTopicRef" select="."/>
                </xsl:apply-templates>
                <!-- nested topic-->
                <xsl:apply-templates select="$topic/*[contains(@class,' topic/topic ')]" mode="#current">
                    <xsl:with-param name="prmTopicRef" select="."/>
                </xsl:apply-templates>
                <xsl:apply-templates select="*[contains(@class,' map/topicref ')]" mode="#current"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- topic/body -->
    <xsl:template match="*[contains(@class,' topic/body ')]" mode="MODE_MAKE_SECT_INFO">
        <xsl:param name="prmTopicRef" as="element()" required="yes"/>
        <xsl:param name="prmIsInFrontMatter" tunnel="yes" required="false" select="false()"/>
        <xsl:variable name="body" as="element()" select="."/>
        <xsl:variable name="columnInfo3" as="item()*" select="ahf:getColumnInfo3($prmTopicRef,$body)"/>
        <xsl:variable name="spanImage" as="element()*" select="$body/descendant::*[contains(@class,' topic/image ')][string(@placement) eq 'break'][string(@span) eq 'all']"/>
        <body>
            <xsl:attribute name="column" select="$columnInfo3[1]"/>
            <xsl:attribute name="id" select="$columnInfo3[2]"/>
            <xsl:attribute name="break" select="$cBreakAuto"/>
            <xsl:attribute name="maincontent" select="if ($prmIsInFrontMatter) then '0' else '1'"/>
            <xsl:attribute name="xpath" select="ahf:getNodeXPathStr($body)"/>
        </body>
        <xsl:apply-templates select="$spanImage" mode="#current">
            <xsl:with-param name="prmTopicRef" select="$prmTopicRef"/>
        </xsl:apply-templates>
        <xsl:if test="exists($spanImage)">
            <body>
                <xsl:attribute name="column" select="$columnInfo3[1]"/>
                <xsl:attribute name="id" select="concat(string($columnInfo3[2]),'.end')"/>
                <xsl:attribute name="break" select="$cBreakAuto"/>
                <xsl:attribute name="maincontent" select="if ($prmIsInFrontMatter) then '0' else '1'"/>
                <xsl:attribute name="xpath" select="ahf:getNodeXPathStr($body)"/>
            </body>
        </xsl:if>
    </xsl:template>
    
    <!-- Image that span columns -->
    <xsl:template match="*[contains(@class,' topic/image ')][string(@placement) eq 'break'][ahf:isSpannedImage(.)]" mode="MODE_MAKE_SECT_INFO" priority="5">
        <xsl:param name="prmIsInFrontMatter" tunnel="yes" required="false" select="false()"/>
        <image>
            <xsl:attribute name="column" select="'1'"/>
            <xsl:attribute name="id" select="ahf:generateId(.)"/>
            <xsl:attribute name="break" select="$cBreakAuto"/>
            <xsl:attribute name="maincontent" select="if ($prmIsInFrontMatter) then '0' else '1'"/>
            <xsl:attribute name="xpath" select="ahf:getNodeXPathStr(.)"/>
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
        <image>
            <xsl:attribute name="column" select="'0'"/>
            <xsl:attribute name="id" select="ahf:generateId(.)"/>
            <xsl:attribute name="break" select="$cBreakAuto"/>
            <xsl:attribute name="maincontent" select="if ($prmIsInFrontMatter) then '0' else '1'"/>
            <xsl:attribute name="xpath" select="ahf:getNodeXPathStr(.)"/>
        </image>
    </xsl:template>

    <!-- Nested topic -->
    <xsl:template match="*[contains(@class,' topic/topic ')]" mode="MODE_MAKE_SECT_INFO">
        <xsl:param name="prmIsInFrontMatter" tunnel="yes" required="false" select="false()"/>
        <xsl:param name="prmTopicRef" as="element()" required="yes"/>
        <xsl:variable name="topic" as="element()" select="."/>
        <xsl:variable name="topicRefBreakInfo" as="xs:integer" select="ahf:getBreakInfo($prmTopicRef)"/>
        <xsl:variable name="columnInfo2" as="item()*" select="ahf:getColumnInfo2($prmTopicRef,$topic)"/>
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
            <xsl:attribute name="maincontent" select="if ($prmIsInFrontMatter) then '0' else '1'"/>
            <xsl:attribute name="xpath" select="ahf:getNodeXPathStr($topic)"/>
        </topic>
        <!-- body -->
        <xsl:apply-templates select="*[contains(@class,' topic/body ')]" mode="#current">
            <xsl:with-param name="prmTopicRef" select="$prmTopicRef"/>
        </xsl:apply-templates>
        <!-- More nested topic -->
        <xsl:apply-templates select="*[contains(@class,' topic/topic ')]" mode="#current">
            <xsl:with-param name="prmTopicRef" select="$prmTopicRef"/>
        </xsl:apply-templates>
    </xsl:template>

    <!-- 
     function:	Get column(1 or 2) and other key information from topicref or referenced topic.
     param:		prmTopicRef
     return:	item()+
                item()[1]: 1 is 1 column. 2 is 2 column
                item()[2]: unique id of topic
                item()[3]: topic/@oid (for debug)
                item()[4]: topic
     note:		Column of topichead is assumed as unknown (0).
                Chapter is 1 column without no consideration.
     -->
    <xsl:variable name="cTwoColumn" as="xs:string" select="'2-col'"/>
    <xsl:variable name="cOneColumn" as="xs:string" select="'1-col'"/>
    <xsl:variable name="cAutoColumn" as="xs:string" select="'auto'"/>
    
    <xsl:function name="ahf:getColumnInfo" as="item()+">
        <xsl:param name="prmTopicRef" as="element()"/>
        <xsl:variable name="topicRefColSpec" as="xs:string" select="ahf:getOutputClassRegx($prmTopicRef,'(\d+)(-col)','$1')"/>
        <xsl:variable name="topic" select="ahf:getTopicFromTopicRef($prmTopicRef)" as="element()?"/>
        <xsl:choose>
            <xsl:when test="exists($prmTopicRef/@href) and exists($topic)">
                <xsl:choose>
                    <xsl:when test="$prmTopicRef[contains(@class,' bookmap/chapter ')]">
                        <xsl:sequence select="(1,ahf:generateId($topic),string($topic/@oid),$topic)"/>
                    </xsl:when>
                    <xsl:when test="$topicRefColSpec ne ''">
                        <xsl:sequence select="(xs:integer($topicRefColSpec),ahf:generateId($topic),string($topic/@oid)),$topic"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:variable name="topicColSpec" as="xs:string" select="ahf:getOutputClassRegx($topic,'(\d+)(-col)','$1')"/>
                        <xsl:choose>
                            <xsl:when test="$topicColSpec ne ''">
                                <xsl:sequence select="(xs:integer($topicColSpec),ahf:generateId($topic),string($topic/@oid),$topic)"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:sequence select="(1,ahf:generateId($topic),string($topic/@oid),$topic)"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="$prmTopicRef[contains(@class,' bookmap/chapter ')]">
                        <xsl:sequence select="(1,ahf:generateId($prmTopicRef),'',())"/>
                    </xsl:when>
                    <xsl:when test="$prmTopicRef[contains(@class,' bookmap/indexlist ')]">
                        <xsl:sequence select="(1,ahf:generateId($prmTopicRef),'',())"/>
                    </xsl:when>
                    <xsl:when test="$prmTopicRef[contains(@class,' bookmap/toc ')]">
                        <xsl:sequence select="(1,ahf:generateId($prmTopicRef),'',())"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:sequence select="(0,ahf:generateId($prmTopicRef),'',())"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>    

    <!-- For nested topic 
         item()[1]: xs:integer column count
         item()[2]: xs:string  id 
         item()[3]: xs:string  oid 
     -->
    <xsl:function name="ahf:getColumnInfo2" as="item()+">
        <xsl:param name="prmTopicRef" as="element()"/>
        <xsl:param name="prmTopic" as="element()"/>
        <xsl:variable name="topicRefColSpec" as="xs:string" select="ahf:getOutputClassRegx($prmTopicRef,'(\d+)(-col)','$1')"/>
        <xsl:choose>
            <xsl:when test="$topicRefColSpec ne ''">
                <xsl:sequence select="(xs:integer($topicRefColSpec),ahf:generateId($prmTopic),string($prmTopic/@oid))"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="topicColSpec" as="xs:string" select="ahf:getOutputClassRegx($prmTopic,'(\d+)(-col)','$1')"/>
                <xsl:choose>
                    <xsl:when test="$topicColSpec ne ''">
                        <xsl:sequence select="(xs:integer($topicColSpec),ahf:generateId($prmTopic),string($prmTopic/@oid))"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:sequence select="(1,ahf:generateId($prmTopic),string($prmTopic/@oid))"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>    
    
    <!-- body用
         item()[1]: xs:integer カラム数
         item()[2]: xs:string  id 
     -->
    <xsl:function name="ahf:getColumnInfo3" as="item()*">
        <xsl:param name="prmTopicRef" as="element()"/>
        <xsl:param name="prmBody" as="element()"/>
        <xsl:variable name="bodyColSpec" as="xs:string" select="ahf:getOutputClassRegx($prmBody,'(\d+)(-col)','$1')"/>
        <xsl:choose>
            <xsl:when test="$bodyColSpec ne ''">
                <xsl:sequence select="(xs:integer($bodyColSpec),ahf:generateId($prmBody))"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="topicRefColSpec" as="xs:string" select="ahf:getOutputClassRegx($prmTopicRef,'(\d+)(-col)','$1')"/>
                <xsl:choose>
                    <xsl:when test="$topicRefColSpec ne ''">
                        <xsl:sequence select="(xs:integer($topicRefColSpec),ahf:generateId($prmBody))"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:sequence select="(1,ahf:generateId($prmBody))"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>    

    <!--
    function:   Get break information for topic & topicref
    param:      prmElem (topic or topicref)
    return:     xs:integer
    note:       
    -->
    <xsl:function name="ahf:getBreakInfo" as="xs:integer">
        <xsl:param name="prmElem" as="element()?"/>
        <xsl:choose>
            <xsl:when test="exists($prmElem)">
                <xsl:variable name="break" as="xs:string" select="string($prmElem/@break)"/>
                <xsl:variable name="breakIndex" as="xs:integer?" select="index-of($cBreakInfoSeqInAuthoring,$break)"/>
                <xsl:choose>
                    <xsl:when test="$prmElem[ahf:seqContains(@class,(' bookmap/chapter ',' bookmap/toc ',' bookmap/indexlist'))]">
                        <xsl:sequence select="$cBreakPage"/>
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
    function:   Complement topichead column number
    param:      none
    return:     xsl:document
    note:       topicheadは直前の段組みの値を引き継ぎます．
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
    
    <!-- topicheadのカラムを補完-->
    <xsl:template match="topichead" mode="MODE_COMPLEMENT_SPAN_INFO" priority="5">
        <xsl:variable name="topicHead" as="element()" select="."/>
        <!--xsl:variable name="nearestNonTopicHead" as="element()?" select="root($topicHead)/*/descendant::*[. &lt;&lt; $topicHead][not(image)][string(@column) ne '0'][last()]"/-->
        <xsl:variable name="nearestNonTopicHead" as="element()?" select="($topicHead/preceding-sibling::*[not(self::image)][string(@column) ne '0'])[last()]"/>
        <xsl:variable name="column" as="xs:string" select="if (exists($nearestNonTopicHead)) then $nearestNonTopicHead/@column/string(.) else '1'"/>
        <xsl:copy>
            <xsl:attribute name="column" select="$column"/>
            <xsl:copy-of select="@* except @column"/>
            <!--xsl:apply-templates mode="#current"/-->
        </xsl:copy>
    </xsl:template>

    <!-- imageのカラムを補完-->
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
    
    <xsl:template match="body|topic" mode="MODE_ADD_ADJACENT_INFO">
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
    note:       Made from $columnMapTree by grouping column/break change
                カラム数は1か2のいずれか．これにbreakの情報を追加してキーを作る．
                breakはcolumnとpageとautoがあるが、columnとそれに続くauto、pageとそれに続くautoというようにグルーピングする．
                こうしないと余計なセクション属性が挿入されてしまい、カラムブレークの場合は段組みの真ん中の線がカラムブレークした次の先頭段落に引かれなくなってしまう．
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
            <xsl:for-each-group select="$sectMapElemsTree/*" group-adjacent="ahf:genSectGroupKey(.)">
                <xsl:variable name="sectGroup" as="element()+" select="current-group()"/>
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
                <xsl:map-entry key="$id" select="($prevColumn,$currentColumn,$nextColumn,$break)"/>
            </xsl:for-each-group>
        </xsl:map>
    </xsl:variable>

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
        <xsl:variable name="breakKey" as="xs:integer" select="ahf:genBreakGroupKey($prmElem)"/>
        <xsl:variable name="breakKeyStr" as="xs:string" select="format-integer($breakKey,'00000')"/>
        <xsl:sequence select="concat($columnKeyStr,' ',$breakKeyStr)"/>
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
        <xsl:variable name="breakKey" as="xs:integer" select="count(($prmElem|$prmElem/preceding-sibling::*)[xs:integer(string(@break)) = ($cBreakPage,$cBreakColumn)])"/>
        <xsl:sequence select="$breakKey"/>
    </xsl:function>

    <!--
    function:   Column map
    param:      none
    return:     map(xs:string, xs:integer+)
    note:       Made from $columnMapTree 
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
                <xsl:variable name="break" as="xs:integer" select="xs:integer($columnMapElem/@break)"/>
                <xsl:map-entry key="$id" select="($prevColumn,$currentColumn,$nextColumn,$break)"/>
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
                <xsl:variable name="mapEntrySeq" as="xs:string+" select="map:for-each($sectMap,function($k, $v){(string($k),string($v[1]),string($v[2]),string($v[3]),string($v[4]))})"/>
                <xsl:for-each select="1 to (xs:integer(count($mapEntrySeq) div 5))">
                    <xsl:variable name="pos" as="xs:integer" select="(. - 1) * 5 + 1"/>
                    <entry key="{$mapEntrySeq[$pos]}" prev="{$mapEntrySeq[$pos + 1]}" current="{$mapEntrySeq[$pos + 2]}" next="{$mapEntrySeq[$pos + 3]}" break="{$mapEntrySeq[$pos + 4]}"/>
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