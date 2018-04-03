<?xml version="1.0" encoding="UTF-8"?>
<!--
**************************************************************
DITA to WordprocessingML Stylesheet
Making Numbring Tree Templates
**************************************************************
File Name : dita2wml_doc_numbering_map.xsl
**************************************************************
Copyright © 2009-2017 Antenna House, Inc. All rights reserved.
Antenna House is a trademark of Antenna House, Inc.
URL : http://www.antennahouse.co.jp/
**************************************************************
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:w="http://purl.oclc.org/ooxml/wordprocessingml/main"
    xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
    exclude-result-prefixes="xs ahf"
    version="3.0">
    
    <!-- External Dependencies
         dita2wml_global.xsl
      -->
    
    <!-- fig, table, footnote grouping max level
      -->
    <xsl:variable name="cTableGroupingLevelMax" as="xs:integer">
        <xsl:choose>
            <xsl:when test="$pAddChapterNumberPrefixToTableTitle">
                <xsl:sequence select="1"/>
            </xsl:when>
            <xsl:otherwise>
                <!-- if user selects not to add title prefix, the table number will not be grouped. -->
                <xsl:sequence select="0"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    
    <xsl:variable name="cFigGroupingLevelMax" as="xs:integer">
        <xsl:choose>
            <xsl:when test="$pAddChapterNumberPrefixToFigTitle">
                <xsl:sequence select="1"/>
            </xsl:when>
            <xsl:otherwise>
                <!-- if user selects not to add title prefix, the figure number will not be grouped. -->
                <xsl:sequence select="0"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    
    <xsl:variable name="cFnGroupingLevelMax" as="xs:integer">
        <xsl:sequence select="xs:integer(ahf:getVarValue('Footnote_Grouping_Level_Max'))"/>
    </xsl:variable>
    
    <!-- Table Numbering Map -->
    <xsl:variable name="tableCountMap" as="document-node()">
        <xsl:document>
            <xsl:call-template name="makeTableCount"/>
        </xsl:document>
    </xsl:variable>
    
    <xsl:variable name="tableNumberingMap" as="document-node()">
        <xsl:document>
            <xsl:call-template name="makeTableStartCount"/>
        </xsl:document>
    </xsl:variable>
    
    <xsl:variable name="tableExists" as="xs:boolean" select="exists($tableCountMap/table-count[xs:integer(@count) gt 0])"/>
    
    <!-- Figure Numbering Map -->
    <xsl:variable name="figCountMap" as="document-node()">
        <xsl:document>
            <xsl:call-template name="makeFigCount"/>
        </xsl:document>
    </xsl:variable>
    
    <xsl:variable name="figNumberingMap" as="document-node()">
        <xsl:document>
            <xsl:call-template name="makeFigStartCount"/>
        </xsl:document>
    </xsl:variable>
    
    <xsl:variable name="figureExists" as="xs:boolean" select="exists($figCountMap/fig-count[xs:integer(@count) gt 0])"/>
    
    <!-- Footnote Numbering Map -->
    <xsl:variable name="fnCountMap" as="document-node()">
        <xsl:document>
            <xsl:call-template name="makeFnCount"/>
        </xsl:document>
    </xsl:variable>

    <xsl:variable name="fnNumberingMap" as="document-node()">
        <xsl:document>
            <xsl:call-template name="makeFnStartCount"/>
        </xsl:document>
    </xsl:variable>

    <!-- 
     function:	make table, fig, footnote count map template
     param:		none
     return:	node that has count information
     note:		
     -->
    <xsl:template name="makeTableCount" as="element()*">
        <xsl:apply-templates select="$map/*[contains(@class, ' map/topicref ')]" mode="MODE_TABLE_COUNT"/>
    </xsl:template>
    
    <xsl:template match="*[contains(@class, ' map/topicref ')]" mode="MODE_TABLE_COUNT" as="element()">
        <xsl:variable name="topicRef" as="element()" select="."/>
        <xsl:variable name="targetTopic" as="element()?" select="ahf:getTopicFromTopicRef($topicRef)"/>
        <xsl:variable name="tableCount" as="xs:integer">
            <xsl:choose>
                <xsl:when test="exists($targetTopic)">
                    <xsl:variable name="tables" as="element()*">
                        <xsl:call-template name="getTopicTable">
                            <xsl:with-param name="prmTopic" select="$targetTopic"/>
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:sequence select="count($tables)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="0"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="topicId" as="xs:string">
            <xsl:choose>
                <xsl:when test="exists($targetTopic)">
                    <xsl:call-template name="ahf:generateId">
                        <xsl:with-param name="prmElement" select="$targetTopic"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="ahf:generateId">
                        <xsl:with-param name="prmElement" select="$topicRef"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:element name="table-count">
            <xsl:attribute name="id" select="$topicId"/>
            <xsl:attribute name="count" select="$tableCount"/>
            <xsl:apply-templates select="*[contains(@class, ' map/topicref ')]" mode="#current"/>
        </xsl:element>
    </xsl:template>

    <xsl:template name="makeFigCount" as="element()*">
        <xsl:apply-templates select="$map/*[contains(@class, ' map/topicref ')]" mode="MODE_FIG_COUNT"/>
    </xsl:template>
    
    <xsl:template match="*[contains(@class, ' map/topicref ')]" mode="MODE_FIG_COUNT" as="element()">
        <xsl:variable name="topicRef" as="element()" select="."/>
        <xsl:variable name="targetTopic" as="element()?" select="ahf:getTopicFromTopicRef($topicRef)"/>
        <xsl:variable name="figCount" as="xs:integer">
            <xsl:choose>
                <xsl:when test="exists($targetTopic)">
                    <xsl:variable name="figs" as="element()*">
                        <xsl:call-template name="getTopicFig">
                            <xsl:with-param name="prmTopic" select="$targetTopic"/>
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:sequence select="count($figs)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="0"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="topicId" as="xs:string">
            <xsl:choose>
                <xsl:when test="exists($targetTopic)">
                    <xsl:variable name="idAttr" as="attribute()">
                        <xsl:call-template name="ahf:getIdAtt">
                            <xsl:with-param name="prmElement" select="$targetTopic"/>
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:sequence select="string($idAttr)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="ahf:generateId">
                        <xsl:with-param name="prmElement" select="$topicRef"/>
                        <xsl:with-param name="prmTopicRef" tunnel="yes" select="$topicRef"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:element name="fig-count">
            <xsl:attribute name="id" select="$topicId"/>
            <xsl:attribute name="count" select="$figCount"/>
            <xsl:apply-templates select="*[contains(@class, ' map/topicref ')]" mode="#current"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template name="makeFnCount" as="element()*">
        <xsl:apply-templates select="$map/*[contains(@class, ' map/topicref ')]" mode="MODE_FN_COUNT"/>
    </xsl:template>
    
    <xsl:template match="*[contains(@class, ' map/topicref ')]" mode="MODE_FN_COUNT" as="element()">
        <xsl:variable name="topicRef" as="element()" select="."/>
        <xsl:variable name="targetTopic" as="element()?" select="ahf:getTopicFromTopicRef($topicRef)"/>
        <xsl:variable name="fnCount" as="xs:integer">
            <xsl:choose>
                <xsl:when test="exists($targetTopic)">
                    <xsl:variable name="fns" as="element()*">
                        <xsl:call-template name="getTopicFn">
                            <xsl:with-param name="prmTopic" select="$targetTopic"/>
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:sequence select="count($fns)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="0"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="topicId" as="xs:string">
            <xsl:choose>
                <xsl:when test="exists($targetTopic)">
                    <xsl:variable name="idAttr" as="attribute()">
                        <xsl:call-template name="ahf:getIdAtt">
                            <xsl:with-param name="prmElement" select="$targetTopic"/>
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:sequence select="string($idAttr)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="ahf:generateId">
                        <xsl:with-param name="prmElement" select="$topicRef"/>
                        <xsl:with-param name="prmTopicRef" tunnel="yes" select="$topicRef"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:element name="fn-count">
            <xsl:attribute name="id" select="$topicId"/>
            <xsl:attribute name="count" select="$fnCount"/>
            <xsl:apply-templates select="*[contains(@class, ' map/topicref ')]" mode="#current"/>
        </xsl:element>
    </xsl:template>

    <!-- 
     function:	Return table, fig, footnote that is descendant of given topic.
     param:		prmTopic
     return:	each elements
     note:		Count only tables that have title element.
     -->
    <xsl:template name="getTopicTable" as="element()*">
        <xsl:param name="prmTopic" as="element()" required="yes"/>
        <xsl:variable name="tableElem" as="element()*">
            <xsl:sequence select="$prmTopic//*[contains(@class,' topic/table ')]
                                               [not(ancestor::*[contains(@class,' topic/table ')])]
                                               [exists(*[contains(@class,' topic/title ')])]"/>
        </xsl:variable> 
        <xsl:sequence select="$tableElem"/>
    </xsl:template>

    <xsl:template name="getTopicFig" as="element()*">
        <xsl:param name="prmTopic" as="element()" required="yes"/>
        <xsl:variable name="figElem" as="element()*">
            <xsl:sequence select="$prmTopic//*[contains(@class,' topic/fig ')]
                                               [exists(*[contains(@class,' topic/title ')])]"/>
        </xsl:variable> 
        <xsl:sequence select="$figElem"/>
    </xsl:template>

    <xsl:template name="getTopicFn" as="element()*">
        <xsl:param name="prmTopic" as="element()" required="yes"/>
        <xsl:variable name="fnElem" as="element()*">
            <xsl:sequence select="$prmTopic//*[contains(@class,' topic/fn ')]
                                               [exists(*[contains(@class,' topic/title ')])]
                                               [not(contains(@class,' pr-d/synnote '))]
                                               [empty(@callout)]"/>
        </xsl:variable> 
        <xsl:sequence select="$fnElem"/>
    </xsl:template>

    <!-- 
     function:	make table, fig, footnote numbering map template
     param:		none
     return:	each element start count node
     note:		
     -->
    <xsl:template name="makeTableStartCount" as="element()*">
        <xsl:apply-templates select="$tableCountMap/*" mode="MODE_TABLE_START_COUNT"/>
    </xsl:template>
    
    <xsl:template match="table-count" mode="MODE_TABLE_START_COUNT" as="element()">
        <xsl:variable name="level" as="xs:integer" select="count(ancestor-or-self::*)"/>
        <xsl:variable name="countTopElem" as="element()?" select="(ancestor-or-self::*)[position() eq $cTableGroupingLevelMax]"/>
        <xsl:variable name="prevCount" as="xs:integer">
            <xsl:choose>
                <xsl:when test="$cTableGroupingLevelMax eq 0">
                    <!-- Table number is not grouped. -->
                    <xsl:sequence select="xs:integer(sum(root(current())//*[. &lt;&lt; current()]/@count))"/>
                </xsl:when>
                <xsl:when test="$level le $cTableGroupingLevelMax">
                    <!-- Table number always starts from 1. -->
                    <xsl:sequence select="0"/>
                </xsl:when>
                <xsl:otherwise>
                    <!-- Count table count with grouping topicref considering $cTableGroupingLevelMax -->
                    <xsl:variable name="countTragetElem" as="element()*" select="root(current())//*[. &lt;&lt; current()] except root(current())//*[. &lt;&lt; $countTopElem]"/>
                    <xsl:sequence select="xs:integer(sum($countTragetElem/@count))"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="prev-count" select="string($prevCount)"/>
            <xsl:apply-templates select="*" mode="#current"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template name="makeFigStartCount" as="element()*">
        <xsl:apply-templates select="$figCountMap/*" mode="MODE_FIG_START_COUNT"/>
    </xsl:template>
    
    <xsl:template match="fig-count" mode="MODE_FIG_START_COUNT" as="element()">
        <xsl:variable name="level" as="xs:integer" select="count(ancestor-or-self::*)"/>
        <xsl:variable name="countTopElem" as="element()?" select="(ancestor-or-self::*)[position() eq $cFigGroupingLevelMax]"/>
        <xsl:variable name="prevCount" as="xs:integer">
            <xsl:choose>
                <xsl:when test="$cFigGroupingLevelMax eq 0">
                    <!-- Table number is not grouped. -->
                    <xsl:sequence select="xs:integer(sum(root(current())//*[. &lt;&lt; current()]/@count))"/>
                </xsl:when>
                <xsl:when test="$level le $cFigGroupingLevelMax">
                    <!-- Table number always starts from 1. -->
                    <xsl:sequence select="0"/>
                </xsl:when>
                <xsl:otherwise>
                    <!-- Count fig number with grouping topicref considering $cFigGroupingLevelMax -->
                    <xsl:variable name="countTragetElem" as="element()*" select="root(current())//*[. &lt;&lt; current()] except root(current())//*[. &lt;&lt; $countTopElem]"/>
                    <xsl:sequence select="xs:integer(sum($countTragetElem/@count))"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="prev-count" select="string($prevCount)"/>
            <xsl:apply-templates select="*" mode="#current"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template name="makeFnStartCount" as="element()*">
        <xsl:apply-templates select="$fnCountMap/*" mode="MODE_FN_START_COUNT"/>
    </xsl:template>
    
    <xsl:template match="fn-count" mode="MODE_FN_START_COUNT" as="element()">
        <xsl:variable name="level" as="xs:integer" select="count(ancestor-or-self::*)"/>
        <xsl:variable name="countTopElem" as="element()?" select="(ancestor-or-self::*)[position() eq $cFnGroupingLevelMax]"/>
        <xsl:variable name="prevCount" as="xs:integer">
            <xsl:choose>
                <xsl:when test="$cFnGroupingLevelMax eq 0">
                    <!-- Table number is not grouped. -->
                    <xsl:sequence select="xs:integer(sum(root(current())//*[. &lt;&lt; current()]/@count))"/>
                </xsl:when>
                <xsl:when test="$level le $cFnGroupingLevelMax">
                    <!-- Table number always starts from 1. -->
                    <xsl:sequence select="0"/>
                </xsl:when>
                <xsl:otherwise>
                    <!-- Count fig number with grouping topicref considering $cFnGroupingLevelMax -->
                    <xsl:variable name="countTragetElem" as="element()*" select="root(current())//*[. &lt;&lt; current()] except root(current())//*[. &lt;&lt; $countTopElem]"/>
                    <xsl:sequence select="xs:integer(sum($countTragetElem/@count))"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="prev-count" select="string($prevCount)"/>
            <xsl:apply-templates select="*" mode="#current"/>
        </xsl:copy>
    </xsl:template>

    <!-- 
     function:	dump table, fig, footnote numbering map template
     param:		none
     return:	result-document
     note:		
     -->
    <xsl:template name="outputTableCountMap">
        <xsl:variable name="fileName1" select="'tableCountMap.xml'"/>
        <xsl:result-document href="{$fileName1}" encoding="UTF-8" indent="yes">
            <xsl:copy-of select="$tableCountMap"/>
        </xsl:result-document>
        <xsl:variable name="fileName2" select="'tableNumberingMap.xml'"/>
        <xsl:result-document href="{$fileName2}" encoding="UTF-8" indent="yes">
            <xsl:copy-of select="$tableNumberingMap"/>
        </xsl:result-document>
    </xsl:template>

    <xsl:template name="outputFigCountMap">
        <xsl:variable name="fileName1" select="'figCountMap.xml'"/>
        <xsl:result-document href="{$fileName1}" encoding="UTF-8" indent="yes">
            <xsl:copy-of select="$figCountMap"/>
        </xsl:result-document>
        <xsl:variable name="fileName2" select="'figNumberingMap.xml'"/>
        <xsl:result-document href="{$fileName2}" encoding="UTF-8" indent="yes">
            <xsl:copy-of select="$figNumberingMap"/>
        </xsl:result-document>
    </xsl:template>

    <xsl:template name="outputFnCountMap">
        <xsl:variable name="fileName1" select="'fnCountMap.xml'"/>
        <xsl:result-document href="{$fileName1}" encoding="UTF-8" indent="yes">
            <xsl:copy-of select="$fnCountMap"/>
        </xsl:result-document>
        <xsl:variable name="fileName2" select="'fnNumberingMap.xml'"/>
        <xsl:result-document href="{$fileName2}" encoding="UTF-8" indent="yes">
            <xsl:copy-of select="$fnNumberingMap"/>
        </xsl:result-document>
    </xsl:template>

    <!-- 
     function:	get table, fig, footnote number amount
     param:		prmTopic
     return:	xs:integer
     note:		
     -->
    <xsl:template name="ahf:getTablePrevAmount" as="xs:integer">
        <xsl:param name="prmTopic" as="element()" required="yes"/>
        
        <xsl:variable name="idAttr" as="attribute()">
            <xsl:call-template name="ahf:getIdAtt">
                <xsl:with-param name="prmElement" select="$prmTopic"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="id" as="xs:string" select="string($idAttr)"/>
        <!-- ** DEBUG **
        <xsl:message select="'$tableCountMap=',$tableCountMap"/>
        <xsl:message select="'$tableingMap=',$tableingMap"/>
        <xsl:message select="'[ahf:gettablePrevAmount] $prmTopic @id=',string($prmTopic/@id),' @oid=',string($prmTopic/@oid)"/>
        <xsl:message select="'[ahf:gettablePrevAmount] $id=',$id"/>
        <xsl:message select="'[ahf:gettablePrevAmountt] $idAttr=',$idAttr"/>
        * -->
        <xsl:variable name="tableInf" as="element()?" select="($tableNumberingMap//*[string(@id) eq $id])[1]"/>
        <xsl:assert test="empty($tableInf)" select="'[ahf:getTablePrevAmount] @id notfound:',$id"/>
        <xsl:sequence select="if (exists($tableInf)) then xs:integer(string($tableInf/@prev-count)) else 0"/>
    </xsl:template>
    
    <xsl:template name="ahf:getFigPrevAmount" as="xs:integer">
        <xsl:param name="prmTopic" as="element()" required="yes"/>
        
        <xsl:variable name="idAttr" as="attribute()">
            <xsl:call-template name="ahf:getIdAtt">
                <xsl:with-param name="prmElement" select="$prmTopic"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="id" as="xs:string" select="string($idAttr)"/>
        <!-- ** DEBUG **
        <xsl:message select="'$figCountMap=',$figCountMap"/>
        <xsl:message select="'$figingMap=',$figingMap"/>
        <xsl:message select="'[ahf:getfigPrevAmount] $prmTopic @id=',string($prmTopic/@id),' @oid=',string($prmTopic/@oid)"/>
        <xsl:message select="'[ahf:getfigPrevAmount] $id=',$id"/>
        <xsl:message select="'[ahf:getfigPrevAmountt] $idAttr=',$idAttr"/>
        * -->
        <xsl:variable name="figInf" as="element()?" select="($figNumberingMap//*[string(@id) eq $id])[1]"/>
        <xsl:assert test="empty($figInf)" select="'[ahf:getFigPrevAmount] @id notfound:',$id"/>
        <xsl:sequence select="if (exists($figInf)) then xs:integer(string($figInf/@prev-count)) else 0"/>
    </xsl:template>

    <xsl:template name="ahf:getFnPrevAmount" as="xs:integer">
        <xsl:param name="prmTopic" as="element()" required="yes"/>
        
        <xsl:variable name="idAttr" as="attribute()">
            <xsl:call-template name="ahf:getIdAtt">
                <xsl:with-param name="prmElement" select="$prmTopic"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="id" as="xs:string" select="string($idAttr)"/>
        <!-- ** DEBUG **
        <xsl:message select="'$fnCountMap=',$fnCountMap"/>
        <xsl:message select="'$fningMap=',$fningMap"/>
        <xsl:message select="'[ahf:getfnPrevAmount] $prmTopic @id=',string($prmTopic/@id),' @oid=',string($prmTopic/@oid)"/>
        <xsl:message select="'[ahf:getfnPrevAmount] $id=',$id"/>
        <xsl:message select="'[ahf:getfnPrevAmountt] $idAttr=',$idAttr"/>
        * -->
        <xsl:variable name="fnInf" as="element()?" select="($fnNumberingMap//*[string(@id) eq $id])[1]"/>
        <xsl:assert test="empty($fnInf)" select="'[ahf:getfnPrevAmount] @id notfound:',$id"/>
        <xsl:sequence select="if (exists($fnInf)) then xs:integer(string($fnInf/@prev-count)) else 0"/>
    </xsl:template>

</xsl:stylesheet>