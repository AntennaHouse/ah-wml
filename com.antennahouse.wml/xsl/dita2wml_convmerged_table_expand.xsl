<?xml version="1.0" encoding="UTF-8"?>
<!--
**************************************************************
DITA to WordprocessingML Stylesheet
Document.xml Table element Templates
**************************************************************
File Name : dita2wml_convmerged_table_expand.xsl
**************************************************************
Copyright © 2009-2017 Antenna House, Inc. All rights reserved.
Antenna House is a trademark of Antenna House, Inc.
URL : http://www.antennahouse.com/
**************************************************************
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
    xmlns:dita-ot="http://dita-ot.sourceforge.net/ns/201007/dita-ot"
    exclude-result-prefixes="xs ahf"
    version="3.0">

    <!-- 
     function:	Genarate updated thead or tbody adding column/row span information
     param:		prmColumnNumber, prmColSpaec, prmTableHeadOrBodyPart 
     return:	thead or tbody with span information
     note:		Newly added attributes for entry:
                @ahf:colnum : column number
                @ahf:col-span-count : column span count (exists only column span first entry)
                @ahf:row-span-count : row span count (exists only row span first entry)
                @ahf:col-spanned : 'yes' indicates column spanned entry
                @ahf:row-spanned : 'yes' indicates row spanned entry 
                @ahf:is-last-col : 'yes' indicates this cell is last in column
                @ahf:is-last-row : 'yes' indicates this cell is in last row (considering row span)
     -->
    <xsl:template name="expandTheadOrTbodyWithSpanInfo" as="element()">
        <xsl:param name="prmColNumber" as="xs:integer" required="yes"/>
        <xsl:param name="prmColSpec" as="document-node()" required="yes"/>
        <xsl:param name="prmTableHeadOrBodyPart" as="element()" required="yes"/>
        
        <!-- Add column spanning information --> 
        <xsl:variable name="colExpandedTableHeadOrBodyPart" as="element()">
            <xsl:for-each select="$prmTableHeadOrBodyPart">
                <xsl:copy>
                    <xsl:copy-of select="@*"/>
                    <xsl:for-each select="*[@class => contains-token('topic/row')]">
                        <xsl:variable name="isLastRow" as="xs:boolean" select="position() eq last()"/>
                        <xsl:copy>
                            <xsl:copy-of select="@*"/>
                            <xsl:apply-templates select="*[@class => contains-token('topic/entry')][1]" mode="MODE_EXPAND_COLUMN_SPAN">
                                <xsl:with-param name="prmColSpec" tunnel="yes" select="$prmColSpec"/>
                                <xsl:with-param name="prmIsLastRow" tunnel="yes" select="$isLastRow"/>
                                <xsl:with-param name="prmColNumber" tunnel="yes" select="$prmColNumber"/>
                                <xsl:with-param name="prmTableHeadOrBodyPart" tunnel="yes" select="$prmTableHeadOrBodyPart"/>
                            </xsl:apply-templates>
                        </xsl:copy>
                    </xsl:for-each>
                </xsl:copy>
            </xsl:for-each>
        </xsl:variable>
        
        <!-- Add row spanning information -->
        <xsl:variable name="rowExpandedTableHeadOrBodyPart" as="element()">
            <xsl:for-each select="$colExpandedTableHeadOrBodyPart">
                <xsl:copy>
                    <xsl:copy-of select="@*"/>
                    <xsl:apply-templates select="*[@class => contains-token('topic/row')][1]" mode="MODE_EXPAND_ROW_SPAN">
                        <xsl:with-param name="prmRowSpanInfo" as="xs:integer+">
                            <xsl:call-template name="genInitialRowSpanInf">
                                <xsl:with-param name="prmColNumber" select="$prmColNumber"/>
                            </xsl:call-template>
                        </xsl:with-param>
                    </xsl:apply-templates>
                </xsl:copy>
            </xsl:for-each>
        </xsl:variable>
        
        <!-- Complement col spanning information to row spanned entry -->
        <xsl:variable name="colSpanComplementedTableHeaderOrBodyPart" as="element()">
            <xsl:for-each select="$rowExpandedTableHeadOrBodyPart">
                <xsl:copy>
                    <xsl:copy-of select="@*"/>
                    <xsl:apply-templates select="*[@class => contains-token('topic/row')]" mode="MODE_COMPLEMENT_COL_SPAN"/>
                </xsl:copy>
            </xsl:for-each>
        </xsl:variable>
        
        <!-- Return thead or tbody -->
        <xsl:sequence select="$colSpanComplementedTableHeaderOrBodyPart"/>

    </xsl:template>

    <!-- 
     function:	Add column spanning information to entry
     param:		prmColumnNumber
     return:	entry
     note:		set own namespace attribute 
     -->
    <xsl:template match="*[@class => contains-token('topic/entry')]" mode="MODE_EXPAND_COLUMN_SPAN">
        <xsl:param name="prmColSpec" tunnel="yes" required="yes" as="document-node()"/>
        <xsl:param name="prmIsLastRow" tunnel="yes" required="yes" as="xs:boolean"/>
        <xsl:param name="prmColNumber" tunnel="yes" required="yes" as="xs:integer"/>
        <xsl:param name="prmTableHeadOrBodyPart" tunnel="yes" required="yes" as="element()"/>
        <xsl:variable name="colnum" as="xs:integer" select="ahf:getColNumFromColName(if (exists(@namest)) then @namest else @colname ,$prmColSpec,$prmTableHeadOrBodyPart)"/>
        <xsl:variable name="colSpanCount" as="xs:integer" select="if (exists(@namest) and exists(@nameend)) then ahf:getColumSpanCount(@namest,@nameend,$prmColSpec,$prmTableHeadOrBodyPart) else 0"/>
        <xsl:variable name="rowSpanCount" as="xs:integer" select="if (exists(@morerows)) then xs:integer(@morerows) else 0"/>
        <xsl:copy>
            <xsl:copy-of select="@* except @dita-ot:*"/>
            <xsl:if test="$prmIsLastRow">
                <xsl:attribute name="ahf:is-last-row" select="$cYes"/>
            </xsl:if>
            <xsl:if test="($colnum + $colSpanCount) eq $prmColNumber">
                <xsl:attribute name="ahf:is-last-col" select="$cYes"/>
            </xsl:if>
            <xsl:attribute name="ahf:colnum" select="string($colnum)"/>
            <xsl:if test="$colSpanCount gt 0">
                <xsl:attribute name="ahf:col-span-count" select="string($colSpanCount)"/>
            </xsl:if>
            <xsl:if test="$rowSpanCount gt 0">
                <xsl:attribute name="ahf:row-span-count" select="string($rowSpanCount)"/>
            </xsl:if>
            <xsl:copy-of select="node()"/>
        </xsl:copy>
        <xsl:if test="$colSpanCount gt 0">
            <xsl:for-each select="1 to $colSpanCount">
                <entry class=" topic/entry " ahf:colnum="{string($colnum + position())}" ahf:col-spanned="yes">
                    <xsl:if test="$rowSpanCount gt 0">
                        <xsl:attribute name="ahf:row-span-count" select="string($rowSpanCount)"/>
                    </xsl:if>
                </entry>
            </xsl:for-each>
        </xsl:if>
        <xsl:apply-templates select="following-sibling::*[1]" mode="MODE_EXPAND_COLUMN_SPAN"/>
    </xsl:template>

    <!-- 
     function:	Generate initial row spanning information
     param:		prmColumnNumber
     return:	row spanning information
     note:		set row span count to all 0
     -->
    <xsl:template name="genInitialRowSpanInf" as="xs:integer+">
        <xsl:param name="prmColNumber" as="xs:integer" required="yes"/>
        <xsl:sequence select="for $i in 1 to $prmColNumber return 0"/>
    </xsl:template>

    <!-- 
     function:	Set row span information to row/entry
     param:		prmRowSpanInfo
     return:	row 
     note:		$prmRowSpanInfo manages the row span count for each table entry.
                If the value is greater than 0, the relevant entry does not exists.
                In this case this template generates dummy entry element.
     -->
    <xsl:template match="*[@class => contains-token('topic/row')]" mode="MODE_EXPAND_ROW_SPAN">
        <xsl:param name="prmRowSpanInfo" required="yes" as="xs:integer+"/>
        <xsl:variable name="row" as="element()" select="."/>
        <xsl:variable name="isLastRow" as="xs:boolean" select="empty($row/following-sibling::*[@class => contains-token('topic/row')])"/>
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:for-each select="$prmRowSpanInfo">
                <xsl:variable name="rowSpanInfo" as="xs:integer" select="."/>
                <xsl:variable name="colnum" as="xs:integer" select="position()"/>
                <xsl:variable name="isLastColumn" as="xs:boolean" select="position() eq last()"/>
                <xsl:variable name="emptyColnum" as="xs:integer" select="count($prmRowSpanInfo[position() lt $colnum][. gt 0])"/>
                <xsl:choose>
                    <xsl:when test="$rowSpanInfo gt 0">
                        <entry class=" topic/entry " ahf:colnum="{string($colnum)}" ahf:row-spanned="yes">
                            <xsl:if test="$isLastRow">
                                <xsl:attribute name="ahf:is-last-row" select="$cYes"/>
                            </xsl:if>
                            <xsl:if test="$isLastColumn">
                                <xsl:attribute name="ahf:is-last-col" select="$cYes"/>
                            </xsl:if>
                        </entry>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="$row/*[@class => contains-token('topic/entry')][position() eq ($colnum - $emptyColnum)]" mode="MODE_COPY_ENTRY"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:copy>
        <xsl:variable name="updatedRowSpanInfo" as="xs:integer+">
            <xsl:for-each select="$prmRowSpanInfo">
                <xsl:variable name="rowSpanInfo" as="xs:integer" select="."/>
                <xsl:variable name="colnum" as="xs:integer" select="position()"/>
                <xsl:variable name="emptyColnum" as="xs:integer" select="count($prmRowSpanInfo[position() lt $colnum][. gt 0])"/>
                <xsl:choose>
                    <xsl:when test="$rowSpanInfo gt 0">
                        <xsl:sequence select="$rowSpanInfo - 1"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="$row/*[@class => contains-token('topic/entry')][position() eq ($colnum - $emptyColnum)]" mode="MODE_UPDATE_ROW_SPAN_INFO"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:variable>
        <xsl:apply-templates select="following-sibling::*[@class => contains-token('topic/row')][1]" mode="MODE_EXPAND_ROW_SPAN">
            <xsl:with-param name="prmRowSpanInfo" select="$updatedRowSpanInfo"/>
        </xsl:apply-templates>
    </xsl:template>

    <!-- 
     function:	Copy entry information
     param:		prmRowSpanInfo
     return:	row 
     note:		
     -->
    <xsl:template match="*[@class => contains-token('topic/entry')]" mode="MODE_COPY_ENTRY">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:copy-of select="node()"/>
        </xsl:copy>
    </xsl:template>

    <!-- 
     function:	Update row span information using entry information
     param:		
     return:	xs:integer
     note:		
     -->
    <xsl:template match="*[@class => contains-token('topic/entry')]" mode="MODE_UPDATE_ROW_SPAN_INFO" as="xs:integer">
        <xsl:choose>
            <xsl:when test="exists(@ahf:row-span-count)">
                <xsl:sequence select="xs:integer(@ahf:row-span-count)"/>
            </xsl:when>
            <xsl:when test="exists(@ahf:col-spanned) and (string(@ahf:col-spanned) eq 'yes')">
                <xsl:choose>
                    <xsl:when test="preceding-sibling::*[exists(@ahf:col-span-count) and xs:integer(@ahf:col-span-count) gt 0][1][exists(@ahf:row-span-count)]">
                        <xsl:sequence select="xs:integer(preceding-sibling::*[exists(@ahf:col-span-count) and xs:integer(@ahf:col-span-count) gt 0][1]/@ahf:row-span-count)"></xsl:sequence>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:sequence select="0"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="0"/>
            </xsl:otherwise>
        </xsl:choose>            
    </xsl:template>

    <!-- 
     function:	Get colnum from colname
     param:		colname
     return:	column number
     note:		Use colspec temporary tree
                DEBUG: Report message when tgroup/@cols is not match the actual table column count.
                       2019-01-08 t.makita
     -->
    <xsl:function name="ahf:getColNumFromColName" as="xs:integer">
        <xsl:param name="prmColName" as="xs:string"/>
        <xsl:param name="prmColSpec" as="document-node()"/>
        <xsl:param name="prmTableHeadOrBodyPart" as="element()"/>
        <!-- DEBUG -->
        <xsl:variable name="colnum" as="xs:integer?" select="xs:integer($prmColSpec/colspec[string(@colname) eq $prmColName]/@colnum)"/>
        <xsl:if test="empty($colnum)">
            <xsl:call-template name="errorExit">
                <xsl:with-param name="prmMes" select="ahf:replace($stMes1022,('%colname','%cols','%file'),($prmColName,string($prmTableHeadOrBodyPart/parent::*[1]/@cols),string($prmTableHeadOrBodyPart/parent::*[1]/@xtrf)))"/>
            </xsl:call-template>
        </xsl:if>
        <xsl:sequence select="xs:integer($prmColSpec/colspec[string(@colname) eq $prmColName]/@colnum)"/>
    </xsl:function>

    <!-- 
     function:	Get column span count from @namest and @nameed
     param:		prmNnameSt, prmNameEnd
     return:	spanned column number
     note:		Use colspec temporary tree
     -->
    <xsl:function name="ahf:getColumSpanCount" as="xs:integer">
        <xsl:param name="prmNameSt" as="xs:string"/>
        <xsl:param name="prmNameEnd" as="xs:string"/>
        <xsl:param name="prmColSpec" as="document-node()"/>
        <xsl:param name="prmTableHeadOrBodyPart" as="element()"/>
        <xsl:sequence select="ahf:getColNumFromColName($prmNameEnd,$prmColSpec,$prmTableHeadOrBodyPart) - ahf:getColNumFromColName($prmNameSt,$prmColSpec,$prmTableHeadOrBodyPart)"/>
    </xsl:function>

    <!-- 
     function:	Row template for complementing colum span
     param:		
     return:	row
     note:		
     -->
    <xsl:template match="*[@class => contains-token('topic/row')]" as="element()" mode="MODE_COMPLEMENT_COL_SPAN">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates select="*[@class => contains-token('topic/entry')]" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- 
     function:	Entry template for complementing colum span
     param:		
     return:	entry
     note:		Complement the column-span information.
     -->
    <xsl:template match="*[@class => contains-token('topic/entry')][string(@ahf:row-spanned) ne $cYes]" as="element()" mode="MODE_COMPLEMENT_COL_SPAN">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:copy-of select="node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="*[@class => contains-token('topic/entry')][string(@ahf:row-spanned) eq $cYes]" as="element()" mode="MODE_COMPLEMENT_COL_SPAN">
        <xsl:variable name="colnum" as="xs:integer" select="xs:integer(@ahf:colnum)"/>
        <xsl:variable name="theadOrTbody" as="element()" select="parent::*/parent::*"/>
        <xsl:variable name="prevRowSpanStartEntry" as="element()?" select="($theadOrTbody/*[@class => contains-token('topic/row')][. &lt;&lt; current()/parent::*]/*[@class => contains-token('topic/entry')][xs:integer(@ahf:colnum) eq $colnum][string(@ahf:row-span-count)])[last()]"/>
        <!--xsl:message select="'$prevRowSpanStartEntry=',if (exists($prevRowSpanStartEntry)) then ahf:genHistoryId($prevRowSpanStartEntry) else ''"/>
        <xsl:message select="'$prevRowSpanStartEntry/@ahf:col-span-count=',string($prevRowSpanStartEntry/@ahf:col-span-count)"/>
        <xsl:message select="'$prevRowSpanStartEntry/@ahf:col-spanned=',string($prevRowSpanStartEntry/@ahf:col-spanned)"/-->
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:copy-of select="$prevRowSpanStartEntry/@ahf:col-span-count"/>
            <xsl:copy-of select="$prevRowSpanStartEntry/@ahf:col-spanned"/>
            <xsl:copy-of select="node()"/>
        </xsl:copy>
    </xsl:template>

    <!-- 
     function:	Genarate updated simpletable adding column/row span information
     param:		prmSimpleTable 
     return:	simpletable with span information
     note:		This template exists only for compatibility with table processing.
                Newly added attributes for entry:
                @ahf:colnum : column number
                @ahf:col-span-count : Not applicable for simpletable
                @ahf:row-span-count : Not applicable for simpletable
                @ahf:col-spanned : Not applicable for simpletable
                @ahf:row-spanned : Not applicable for simpletable 
                @ahf:is-last-col : 'yes' indicates this cell is last in column
                @ahf:is-last-row : 'yes' indicates this cell is in last row
     -->
    <xsl:template name="expandSimpleTableWithSpanInfo" as="element()">
        <xsl:param name="prmSimpleTable" as="element()" required="yes"/>
        <!-- Maintain stentry/@colnum -->
        <xsl:for-each select="$prmSimpleTable">
            <xsl:copy>
                <xsl:copy-of select="@*"/>
                <xsl:for-each select="*[@class => ahf:seqContainsToken(('topic/sthead','topic/strow'))]">
                    <xsl:variable name="isLastRow" as="xs:boolean" select="position() eq last()"/>
                    <xsl:copy>
                        <xsl:copy-of select="@*"/>
                        <xsl:apply-templates select="*[@class => contains-token('topic/stentry')]" mode="MODE_ADD_COLNUM">
                            <xsl:with-param name="prmIsLastRow" tunnel="yes" select="$isLastRow"/>
                        </xsl:apply-templates>
                    </xsl:copy>
                </xsl:for-each>
            </xsl:copy>
        </xsl:for-each>
    </xsl:template>

    <!-- 
     function:	Add column number information to stentry
     param:		prmIsLastRow
     return:	stentry
     note:		set own namespace attribute 
     -->
    <xsl:template match="*[@class => contains-token('topic/stentry')]" mode="MODE_ADD_COLNUM">
        <xsl:param name="prmIsLastRow" tunnel="yes" required="yes" as="xs:boolean"/>
        <xsl:copy>
            <xsl:copy-of select="@* except @dita-ot:*"/>
            <xsl:if test="empty(following-sibling::*)">
                <xsl:attribute name="ahf:is-last-col" select="$cYes"/>
            </xsl:if>
            <xsl:if test="$prmIsLastRow">
                <xsl:attribute name="ahf:is-last-row" select="$cYes"/>
            </xsl:if>
            <xsl:attribute name="ahf:colnum" select="count(.|preceding-sibling::*)"/>
            <xsl:copy-of select="node()"/>
        </xsl:copy>
    </xsl:template>

    <!-- END OF STYLESHEET -->

</xsl:stylesheet>