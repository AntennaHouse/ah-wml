<?xml version="1.0" encoding="UTF-8"?>
<!--
**************************************************************
DITA to WordprocessingML Stylesheet
Document.xml Table element Templates
**************************************************************
File Name : dita2wml_document_table.xsl
**************************************************************
Copyright © 2009-2017 Antenna House, Inc. All rights reserved.
Antenna House is a trademark of Antenna House, Inc.
URL : http://www.antennahouse.com/
**************************************************************
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" 
    xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
    xmlns:style="http://www.antennahouse.com/names/XSLT/Document/Layout"
    exclude-result-prefixes="xs ahf style map"
    version="3.0">

    <!-- 
     function:	Table processing
     param:		none
     return:	
     note:		Only pass the specified table attribute to tgroup template. 
     -->
    <xsl:template match="*[contains(@class, ' topic/table ')]">
        <xsl:apply-templates select="*[contains(@class, ' topic/title ')]"/>
        <xsl:variable name="tableAttr" select="ahf:getTableAttr(.)" as="element()"/>
        <xsl:apply-templates select="*[contains(@class, ' topic/tgroup ')]">
            <xsl:with-param name="prmTableAttr" select="$tableAttr"/>
        </xsl:apply-templates>
    </xsl:template>

    <!-- 
     function:	Table title processing
     param:		none
     return:	w:p
     note:		 
     -->
    <xsl:template match="*[contains(@class, ' topic/table ')]/*[contains(@class,' topic/title ')]">
        <xsl:param name="prmIndentLevel" tunnel="yes" required="yes" as="xs:integer"/>
        <xsl:param name="prmExtraIndent" tunnel="yes" required="yes" as="xs:integer"/>
        <xsl:param name="prmEndIndent" tunnel="yes" required="no" as="xs:integer" select="0"/>
        <w:p>
            <w:pPr>
                <w:pStyle w:val="{ahf:getStyleIdFromName('caption')}"/>
                <xsl:copy-of select="ahf:getIndentAttrElem(ahf:getIndentFromIndentLevel($prmIndentLevel, $prmExtraIndent),$prmEndIndent,0,0)"/>
            </w:pPr>
            <xsl:call-template name="genBookmarkStart">
                <xsl:with-param name="prmElem" select="parent::*"/>
            </xsl:call-template>
            <xsl:call-template name="ahf:getTableTitlePrefix">
                <xsl:with-param name="prmTable" select="parent::*"/>
            </xsl:call-template>
            <xsl:apply-templates/>
            <xsl:call-template name="genBookmarkEnd">
                <xsl:with-param name="prmElem" select="parent::*"/>
            </xsl:call-template>
        </w:p>        
    </xsl:template>

    <!-- 
     function:	build table attributes
     param:		prmTable
     return:	element()
     note:		Set default table attribute value if not specified. 
     -->
    <xsl:function name="ahf:getTableAttr" as="element()">
        <xsl:param name="prmTable" as="element()"/>
        <dummy>
            <xsl:attribute name="frame"  select="if (exists($prmTable/@frame))  then string($prmTable/@frame) else 'all'"/>
            <xsl:attribute name="colsep" select="if (exists($prmTable/@colsep)) then string($prmTable/@colsep) else '1'"/>
            <xsl:attribute name="rowsep" select="if (exists($prmTable/@rowsep)) then string($prmTable/@rowsep) else '1'"/>
            <xsl:attribute name="pgwide" select="if (exists($prmTable/@pgwide)) then string($prmTable/@pgwide) else '0'"/>
            <xsl:attribute name="rowheader" select="if (exists($prmTable/@rowheader)) then string($prmTable/@rowheader) else 'norowheader'"/>
            <xsl:attribute name="scale"  select="if (exists($prmTable/@scale))  then string($prmTable/@scale) else '100'"/>
            <xsl:copy-of select="$prmTable/@class"/>
        </dummy>
    </xsl:function>

    <!-- 
     function:	Tgroup processing
     param:		none
     return:	w:tbl
     note:		Generate space-after only w:p after w:tbl
     -->
    <xsl:template match="*[contains(@class, ' topic/tgroup ')]">
        <xsl:param name="prmTableAttr" required="yes" as="element()"/>
        <xsl:param name="prmIndentLevel" tunnel="yes" required="yes" as="xs:integer"/>
        <xsl:param name="prmExtraIndent" tunnel="yes" required="yes" as="xs:integer"/>
        
        <xsl:variable name="tgroupAttr"  as="element()" select="ahf:getTgroupAttr(.,$prmTableAttr)"/>
        <xsl:variable name="colspec" as="element()+" select="*[contains(@class,' topic/colspec ')]"/>
        <w:tbl>
            <w:tblPr>
                <xsl:call-template name="genTblPr">
                    <xsl:with-param name="prmTgroupAttr" select="$tgroupAttr"/>
                </xsl:call-template>
            </w:tblPr>    
            <w:tblGrid>
                <xsl:call-template name="genGridCol">
                    <xsl:with-param name="prmColSpec" select="*[contains(@class,' topic/colspec ')]"/>
                </xsl:call-template>
            </w:tblGrid>
            
            <xsl:if test="*[contains(@class, ' topic/thead ')]">
                <xsl:variable name="theadAttr" as="element()" select="ahf:getTheadAttr(*[contains(@class, ' topic/thead ')],$tgroupAttr)"/>
                <xsl:call-template name="genRowForHeadOrBody">
                    <xsl:with-param name="prmTheadOrTbodyAttr" select="$theadAttr"/>
                    <xsl:with-param name="prmColSpec" select="$colspec"/>
                    <xsl:with-param name="prmTableHeadOrBodyPart" select="*[contains(@class, ' topic/thead ')]"/>
                    <xsl:with-param name="prmIndentLevel" tunnel="yes" select="0"/>
                    <xsl:with-param name="prmExtraIndent" tunnel="yes" select="0"/>
                </xsl:call-template>
            </xsl:if>

            <xsl:if test="*[contains(@class, ' topic/tbody ')]">
                <xsl:variable name="tbodyAttr" as="element()" select="ahf:getTbodyAttr(*[contains(@class, ' topic/tbody ')],$tgroupAttr)"/>
                <xsl:call-template name="genRowForHeadOrBody">
                    <xsl:with-param name="prmTheadOrTbodyAttr" select="$tbodyAttr"/>
                    <xsl:with-param name="prmColSpec" select="$colspec"/>
                    <xsl:with-param name="prmTableHeadOrBodyPart" select="*[contains(@class, ' topic/tbody ')]"/>
                    <xsl:with-param name="prmIndentLevel" tunnel="yes" select="0"/>
                    <xsl:with-param name="prmExtraIndent" tunnel="yes" select="0"/>
                </xsl:call-template>
            </xsl:if>
        </w:tbl>
        <xsl:copy-of select="ahf:genSpaceAfterOnlyP('SpaceAfterForTable')"/>
    </xsl:template>
    
    <!-- 
     function:	build tgroup attributes
     param:		prmTgroup, prmTableAttr
     return:	element()
     note:		Add tgroup attribute to table attribute
     -->
    <xsl:function name="ahf:getTgroupAttr" as="element()">
        <xsl:param name="prmTgroup"    as="element()"/>
        <xsl:param name="prmTableAttr" as="element()"/>
        <dummy>
            <xsl:copy-of select="$prmTableAttr/@*"/>
            <xsl:attribute name="cols" select="string($prmTgroup/@cols)"/>
            <xsl:copy-of select="$prmTgroup/@colsep"/>
            <xsl:copy-of select="$prmTgroup/@rowsep"/>
            <xsl:copy-of select="$prmTgroup/@align"/>
        </dummy>
    </xsl:function>
    
    <!-- 
     function:	generate w:tblPr
     param:		prmTgroupAttr, prmIndentLevel,prmExtraIndent
     return:	element()*
     note:		Children of w:tblPr must be ordered as the follwoing sequence.
                w:tblStyle, w:tblpPr,w:tblOverlap,w:bidiVisual,w:tblStyleRowBandSize
                w:tblStyleColBandSize,w:tblW,w:jc,w:tblCellSpacing,w:tblInd,w:tblBorders
                w:shd,w:tblLayout,w:tblCellMar,w:tblLook,w:tblCaption,w:tblDescription
                
                tgroup/@align is for the alignment of text in a table column.
                It is not applicable for w:tbl.
     -->
    <xsl:template name="genTblPr" as="element()*">
        <xsl:param name="prmTgroupAttr"    as="element()"/>
        <xsl:param name="prmIndentLevel" tunnel="yes" required="yes" as="xs:integer"/>
        <xsl:param name="prmExtraIndent" tunnel="yes" required="yes" as="xs:integer"/>
        
        <!-- w:tblStyle -->
        <xsl:variable name="tableStyle" as="xs:string">
            <xsl:call-template name="getVarValue">
                <xsl:with-param name="prmVarName" select="'TableStyleName'"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:if test="string($tableStyle)">
            <w:tblStyle>
                <xsl:attribute name="w:val" select="$tableStyle"/>
            </w:tblStyle>
        </xsl:if>
        
        <!-- w:tblW -->
        <w:tblW>
            <xsl:call-template name="getAttributeSet">
                <xsl:with-param name="prmAttrSetName" as="xs:string">
                    <xsl:sequence select="if (ahf:isTablePgwide($prmTgroupAttr)) then 'atsPgWidthTblW' else 'atsAutoTblW'"/>
                </xsl:with-param>
            </xsl:call-template>
        </w:tblW>

        <!-- w:tblInd -->
        <xsl:if test="not(ahf:isTablePgwide($prmTgroupAttr))">
            <w:tblInd w:w="{ahf:getIndentFromIndentLevel($prmIndentLevel,$prmExtraIndent)}" w:type="{$cTwip}"/>
        </xsl:if>
        
        <!-- w:tblBorders -->
        <xsl:variable name="tableBorderPrElem" as="element()*">
            <xsl:call-template name="getTableBorderPrElem">
                <xsl:with-param name="prmTgroupAttr" select="$prmTgroupAttr"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:if test="exists($tableBorderPrElem)">
            <w:tblBorders>
                <xsl:copy-of select="$tableBorderPrElem"/>
            </w:tblBorders>
        </xsl:if>
        
        <!-- w:tblLayout -->
        <w:tblLayout>
            <xsl:call-template name="getAttributeSet">
                <xsl:with-param name="prmAttrSetName" as="xs:string">
                    <xsl:sequence select="'atsTableLayout'"/>
                </xsl:with-param>
            </xsl:call-template>
        </w:tblLayout>
    </xsl:template>

    <!-- 
     function:	Get pgwide attributes
     param:		prmTgroupAttr
     return:	attribute()
     note:		
     -->
    <xsl:function name="ahf:isTablePgwide" as="xs:boolean">
        <xsl:param name="prmTgroupAttr"    as="element()"/>
        <xsl:sequence select="(string($prmTgroupAttr/@pgwide) eq '1') or (string($prmTgroupAttr/@expanse) = ('page','column','spread'))"/>
    </xsl:function>
    
    <!-- 
     function:	Process table/@frame attribute and generate tableBorder child elements
     param:		prmTgroupAttr
     return:	attribute()
     note:		
     -->
    <xsl:template name="getTableBorderPrElem" as="element()*">
        <xsl:param name="prmTgroupAttr" as="element()" required="yes"/>
        <xsl:variable name="frameAtt" as="xs:string" select="string($prmTgroupAttr/@frame)"/>
        <xsl:if test="$frameAtt = ('all','topbot','top')">
            <w:top>
                <xsl:call-template name="getAttributeSet">
                    <xsl:with-param name="prmAttrSetName" select="'atsTableBorderTop'"/>
                </xsl:call-template>
            </w:top>
        </xsl:if>
        <xsl:if test="$frameAtt = ('all','sides')">
            <w:start>
                <xsl:call-template name="getAttributeSet">
                    <xsl:with-param name="prmAttrSetName" select="'atsTableBorderStart'"/>
                </xsl:call-template>
            </w:start>
        </xsl:if>
        <xsl:if test="$frameAtt = ('all','topbot','bottom')">
            <w:bottom>
                <xsl:call-template name="getAttributeSet">
                    <xsl:with-param name="prmAttrSetName" select="'atsTableBorderBottom'"/>
                </xsl:call-template>
            </w:bottom>
        </xsl:if>
        <xsl:if test="$frameAtt = ('all','sides')">
            <w:end>
                <xsl:call-template name="getAttributeSet">
                    <xsl:with-param name="prmAttrSetName" select="'atsTableBorderEnd'"/>
                </xsl:call-template>
            </w:end>
        </xsl:if>
    </xsl:template>

    <!-- 
     function:	Genrate w:gridCol from colspec 
     param:		none
     return:	w:gridCol
     note:		w:gridCol/@w:w only expresses temporary column width. 
                It si not a actual width. See ECMA Spc p.1496 "17.18.87  ST_TblLayoutType (Table Layout Type)" 
     -->
    <xsl:template name="genGridCol" as="element()+">
        <xsl:param name="prmColSpec" as="element()+" required="yes"/>
        <xsl:param name="ancestorColElem" as="element()" select="if (exists($prmColSpec[1]/ancestor::*[contains(@class,' topic/body ')])) then $prmColSpec[1]/ancestor::*[contains(@class,' topic/body ')] else $prmColSpec[1]/ancestor::*[contains(@class,' topic/topic ')][last()]"/>
        <xsl:variable name="colInfo" as="item()+" select="map:get($columnMap,ahf:generateId($ancestorColElem))"/>
        <xsl:variable name="columnCount" as="xs:integer" select="xs:integer($colInfo[2])"/>
        <xsl:variable name="bodyWidth" as="xs:double">
            <xsl:choose>
                <xsl:when test="$columnCount eq 1">
                    <xsl:sequence select="ahf:toTwip($pPaperBodyWidth)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="ahf:toTwip($pPaperBodyWidth) div $columnCount - ahf:toTwip($pPaperColumnGap) * ($columnCount - 1) div $columnCount"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:for-each select="$prmColSpec">
            <w:gridCol>
                <xsl:attribute name="w:w" select="xs:integer(round($bodyWidth * xs:double(string(@ahf:colwidth-ratio)) div 100))"/>
            </w:gridCol>
        </xsl:for-each>
    </xsl:template>
    
    <!-- 
     function:	build thead attributes
     param:		prmThead, prmTgroupAttr
     return:	element()
     note:		
     -->
    <xsl:function name="ahf:getTheadAttr" as="element()">
        <xsl:param name="prmThead"    as="element()"/>
        <xsl:param name="prmTgroupAttr" as="element()"/>
        <dummy>
            <xsl:copy-of select="$prmTgroupAttr/@*"/>
            <xsl:copy-of select="$prmThead/@valign"/>
        </dummy>
    </xsl:function>
    
    <!-- 
     function:	build tgroup attributes
     param:		prmTbody, prmTgroupAttr
     return:	element()
     note:		
     -->
    <xsl:function name="ahf:getTbodyAttr" as="element()">
        <xsl:param name="prmTbody"    as="element()"/>
        <xsl:param name="prmTgroupAttr" as="element()"/>
        <dummy>
            <xsl:copy-of select="$prmTgroupAttr/@*"/>
            <xsl:copy-of select="$prmTbody/@valign"/>
        </dummy>
    </xsl:function>

    <!-- 
     function:	Generate w:tr from thead or tbody
     param:		prmTgroupAttr, prmColSpec, prmTableHeadOrBodyPart (thead or tbody)
     return:	w:tr
     note:		
     -->
    <xsl:template name="genRowForHeadOrBody">
        <xsl:param name="prmTheadOrTbodyAttr" as="element()" required="yes"/>
        <xsl:param name="prmColSpec" as="element()+" required="yes"/>
        <xsl:param name="prmTableHeadOrBodyPart" as="element()" required="yes"/>
        <xsl:variable name="cols" as="xs:integer" select="xs:integer($prmTheadOrTbodyAttr/@cols)"/>
        <xsl:variable name="isThead" as="xs:boolean" select="exists($prmTableHeadOrBodyPart[contains(@class,' topic/thead ')])"/>

        <xsl:for-each select="$prmTableHeadOrBodyPart/*[contains(@class,' topic/row ')]">
            <xsl:variable name="row" as="element()" select="."/>
            <xsl:variable name="rowAttr" as="element()" select="ahf:getRowAttr($row,$prmTheadOrTbodyAttr)"/>
            <w:tr>
                <w:trPr>
                    <xsl:copy-of select="ahf:getWmlObject(if ($isThead) then 'wmlTrPrHead' else 'wmlTrPrBody')"/>
                </w:trPr>
                <xsl:apply-templates select="*[contains(@class,' topic/entry ')]">
                    <xsl:with-param name="prmRowAttr" select="$rowAttr"/>
                    <xsl:with-param name="prmColSpec" select="$prmColSpec"/>
                </xsl:apply-templates>
            </w:tr>
        </xsl:for-each>
    </xsl:template>

    <!-- 
     function:	build row attributes
     param:		prmRow, prmRowUpperAttr
     return:	element()
     note:		
     -->
    <xsl:function name="ahf:getRowAttr" as="element()">
        <xsl:param name="prmRow"    as="element()"/>
        <xsl:param name="prmRowUpperAttr" as="element()"/>
        <dummy>
            <xsl:copy-of select="$prmRowUpperAttr/@*"/>
            <xsl:copy-of select="$prmRow/@rowsep"/>
            <xsl:copy-of select="$prmRow/@valign"/>
        </dummy>
    </xsl:function>

    <!-- 
     function:	Generate w:tc from entry
     param:		prmRowAttr
     return:	w:tr
     note:		Passing $prmTcAttr aims to implement @align in paragraph level.
     -->
    <!-- Ignore column spanned entry -->
    <xsl:template match="*[contains(@class,' topic/entry ')][string(@ahf:col-spanned) eq $cYes]" priority="5"/>
    
    <xsl:template match="*[contains(@class,' topic/entry ')]">
        <xsl:param name="prmRowAttr" as="element()" required="yes"/>
        <xsl:param name="prmColSpec" as="element()+" required="yes"/>
        <xsl:variable name="entry" as="element()" select="."/>
        <xsl:variable name="entryAttr" as="element()" select="ahf:getEntryAttr($entry,$prmRowAttr,$prmColSpec)"/>
        <w:tc>
            <w:tcPr>
                <xsl:call-template name="genTcPr">
                    <xsl:with-param name="prmEntry" select="$entry"/>
                    <xsl:with-param name="prmEntryAttr" select="$entryAttr"/>
                </xsl:call-template>
            </w:tcPr>
            <xsl:choose>
                <xsl:when test="empty(*)">
                    <w:p/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates>
                        <xsl:with-param name="prmTcAttr" tunnel="yes" select="$entryAttr"/>
                    </xsl:apply-templates>
                </xsl:otherwise>
            </xsl:choose>
        </w:tc>
        
    </xsl:template>
    
    <!-- 
     function:	build entry attributes
     param:		prmEntry, prmRowAttr, prmColSpec
     return:	element()
     note:		Final entry attribute = row attribute + colspec attribute + entry attribute
     -->
    <xsl:function name="ahf:getEntryAttr" as="element()">
        <xsl:param name="prmEntry"    as="element()"/>
        <xsl:param name="prmRowAttr"  as="element()"/>
        <xsl:param name="prmColSpec"  as="element()+"/>
        <xsl:variable name="colSpec" as="element()" select="$prmColSpec[xs:integer(@colnum) eq xs:integer($prmEntry/@ahf:colnum)]"/>
        <dummy>
            <xsl:copy-of select="$prmRowAttr/@*"/>
            <xsl:copy-of select="$colSpec/@align"/>
            <xsl:copy-of select="$colSpec/@colsep"/>
            <xsl:copy-of select="$colSpec/@rowsep"/>
            <xsl:copy-of select="$colSpec/@rowheader"/>
            <xsl:copy-of select="$colSpec/@char"/>
            <xsl:copy-of select="$colSpec/@charoff"/>
            <xsl:copy-of select="$prmEntry/@colname"/>
            <xsl:copy-of select="$prmEntry/@namest"/>
            <xsl:copy-of select="$prmEntry/@nameend"/>
            <xsl:copy-of select="$prmEntry/@morerows"/>
            <xsl:copy-of select="$prmEntry/@colsep"/>
            <xsl:copy-of select="$prmEntry/@rowsep"/>
            <xsl:copy-of select="$prmEntry/@align"/>
            <xsl:copy-of select="$prmEntry/@char"/>
            <xsl:copy-of select="$prmEntry/@valign"/>
            <xsl:copy-of select="$prmEntry/@ahf:colnum"/>
            <xsl:copy-of select="$prmEntry/@ahf:col-span-count"/>
            <xsl:copy-of select="$prmEntry/@ahf:row-span-count"/>
            <xsl:copy-of select="$prmEntry/@ahf:col-spanned"/>
            <xsl:copy-of select="$prmEntry/@ahf:row-spanned"/>
            <xsl:copy-of select="$prmEntry/@ahf:is-last-col"/>
            <xsl:copy-of select="$prmEntry/@ahf:is-last-row"/>
        </dummy>
    </xsl:function>
    
    <!-- 
     function:	Generate w:tcPr from entry
     param:		prmEntry, prmEntryAttr
     return:	child of w:tcPr
     note:		Child of w:tcPr must satisfy following sequence:
                cnfStyle,tcW,gridSpan,vMerge,tcBorders,shd,noWrap,tcMar
                textDirection,tcFitText,vAlign,hideMark,headers
     -->
    <xsl:template name="genTcPr">
        <xsl:param name="prmEntry" as="element()" required="yes"/>
        <xsl:param name="prmEntryAttr" as="element()" required="yes"/>
        <xsl:variable name="isThead" as="xs:boolean" select="exists($prmEntry/ancestor::*/ancestor::*[contains(@class,' topic/thead ')])"/>
        
        <!-- w:tcW -->
        <w:tcW>
            <xsl:call-template name="getAttributeSet">
                <xsl:with-param name="prmAttrSetName" as="xs:string">
                    <xsl:sequence select="'atsTcW'"/>
                </xsl:with-param>
            </xsl:call-template>
        </w:tcW>
        
        <!-- w:gridSpan -->
        <xsl:variable name="gridSpan" as="xs:string" select="string($prmEntryAttr/@ahf:col-span-count)"/>
        <xsl:if test="string($gridSpan)">
            <w:gridSpan w:val="{xs:integer($gridSpan) + 1}"/>
        </xsl:if>
        
        <!-- w:vMerge -->
        <xsl:variable name="rowSpanCount" as="xs:string" select="string($prmEntryAttr/@ahf:row-span-count)"/>
        <xsl:variable name="rowSpanned" as="xs:string" select="string($prmEntryAttr/@ahf:row-spanned)"/>
        <xsl:choose>
            <xsl:when test="string($rowSpanCount)">
                <w:vMerge w:val="restart"/>
            </xsl:when>
            <xsl:when test="string($rowSpanned)">
                <w:vMerge/>
            </xsl:when>
        </xsl:choose>
        
        <!-- w:tcBorders -->
        <xsl:variable name="hasColSep" as="xs:boolean" select="string($prmEntryAttr/@colsep) eq '1'"/>
        <xsl:variable name="hasRowSep" as="xs:boolean" select="string($prmEntryAttr/@rowsep) eq '1'"/>
        <xsl:variable name="isLastCol" as="xs:boolean" select="string($prmEntryAttr/@ahf:is-last-col) eq $cYes"/>
        <xsl:variable name="isLastRow" as="xs:boolean" select="string($prmEntryAttr/@ahf:is-last-row) eq $cYes"/>
        <xsl:variable name="isNotLastRow" as="xs:boolean" select="not($isLastRow)"/>
        <xsl:variable name="drawBottomBorder" as="xs:boolean" select="$hasRowSep and ($isNotLastRow or $isThead)"/>
        <xsl:variable name="drawEndBorder" as="xs:boolean" select="$hasColSep and not($isLastCol)"/>
        <xsl:if test="$drawBottomBorder or $drawEndBorder">
            <w:tcBorders>
                <xsl:if test="$drawBottomBorder">
                    <w:bottom>
                        <xsl:call-template name="getAttributeSet">
                            <xsl:with-param name="prmAttrSetName" select="'atsTableCellBorderBottom'"/>
                        </xsl:call-template>
                    </w:bottom>
                </xsl:if>
                <xsl:if test="$drawEndBorder">
                    <w:end>
                        <xsl:call-template name="getAttributeSet">
                            <xsl:with-param name="prmAttrSetName" select="'atsTableCellBorderEnd'"/>
                        </xsl:call-template>
                    </w:end>
                </xsl:if>
            </w:tcBorders>
        </xsl:if>
        
        <!-- w:shd -->
        <xsl:if test="$isThead">
            <w:shd>
                <xsl:call-template name="getAttributeSet">
                    <xsl:with-param name="prmAttrSetName" select="'atsTableCellShading'"/>
                </xsl:call-template>
            </w:shd>
        </xsl:if>

        <!-- w:vAlign -->
        <xsl:variable name="vAlign" as="xs:string" select="string($prmEntryAttr/@valign)"/>
        <xsl:if test="string($vAlign)">
            <w:vAlign>
                <xsl:choose>
                    <xsl:when test="$vAlign = ('top','bottom')">
                        <xsl:attribute name="w:val" select="$vAlign"/>
                    </xsl:when>
                    <xsl:when test="$vAlign eq 'middle'">
                        <xsl:attribute name="w:val" select="'center'"/>
                    </xsl:when>
                </xsl:choose>
            </w:vAlign>
        </xsl:if>
    </xsl:template>
        
    <!-- 
     function:	Generate table title prefix
     param:		prmTopicRef, prmTable
     return:	Table title prefix
     note:		
     -->
    <xsl:template name="ahf:getTableTitlePrefix" as="element(w:r)*">
        <xsl:param name="prmTopicRef" tunnel="yes" required="yes" as="element()"/>
        <xsl:param name="prmTable" required="no" as="element()" select="."/>
        
        <xsl:variable name="topicNode" select="$prmTable/ancestor::*[contains(@class, ' topic/topic ')][position()=last()]"/>
        
        <xsl:variable name="tablePreviousAmount" as="xs:integer">
            <xsl:variable name="topicNodeId" select="ahf:generateId($topicNode)"/>
            <xsl:sequence select="$tableNumberingMap/*[string(@id) eq $topicNodeId]/@prev-count"/>
        </xsl:variable>
        
        <xsl:variable name="tableCurrentAmount"  as="xs:integer">
            <xsl:variable name="topic" as="element()" select="$prmTable/ancestor::*[contains(@class,' topic/topic ')][last()]"/>
            <xsl:sequence select="count($topic//*[contains(@class,' topic/table ')][child::*[contains(@class, ' topic/title ')]][. &lt;&lt; $prmTable]|$prmTable)"/>
        </xsl:variable>
        
        <xsl:variable name="tableNumber" select="$tablePreviousAmount + $tableCurrentAmount" as="xs:integer"/>
        
        <xsl:variable name="topTopicrefNumber" as="xs:integer">
            <xsl:call-template name="getTopTopicrefNumber">
                <xsl:with-param name="prmTopicRef" select="$prmTopicRef"/>
            </xsl:call-template>
        </xsl:variable>
        
        <w:r>
            <w:t xml:space="preserve"><xsl:value-of select="$cTableTitle"/></w:t>
        </w:r>
        <xsl:if test="$pAddChapterNumberPrefixToTableTitle and ahf:hasTopTopicrefNumber($prmTopicRef)">
            <xsl:call-template name="getWmlObjectReplacing">
                <xsl:with-param name="prmObjName" select="'wmlStyleRefField'"/>
                <xsl:with-param name="prmSrc" select="('%style-name','%field-opt','%style-ref-result')"/>
                <xsl:with-param name="prmDst" select="($cTopicTitleStyleName1st,'\s',string($topTopicrefNumber))"/>
            </xsl:call-template>            
            <w:r>
                <w:t>
                    <xsl:value-of select="$cTitleSeparator"/>
                </w:t>
            </w:r>
        </xsl:if>
        <xsl:call-template name="getWmlObjectReplacing">
            <xsl:with-param name="prmObjName" select="'wmlSeqField'"/>
            <xsl:with-param name="prmSrc" select="('%tag','%field-opt','%seq-result')"/>
            <xsl:with-param name="prmDst" select="('Table',concat('\* ARABIC \s ',ahf:getStyleIdFromName($cTopicTitleStyleName1st)),string($tableCurrentAmount))"/>
        </xsl:call-template>            
    </xsl:template>
    
    <xsl:function name="ahf:getTableTitlePrefix" as="element(w:r)*">
        <xsl:param name="prmTopicRef" as="element()"/>
        <xsl:param name="prmTable" as="element()"/>
        
        <xsl:call-template name="ahf:getTableTitlePrefix">
            <xsl:with-param name="prmTopicRef" tunnel="yes" select="$prmTopicRef"/>
            <xsl:with-param name="prmTable" select="$prmTable"/>
        </xsl:call-template>
    </xsl:function>
    
    <!-- 
     function:	simpletable processing
     param:		none
     return:	w:tbl
     note:		
     -->
    <xsl:template match="*[contains(@class, ' topic/simpletable ')]">
        <xsl:variable name="simpleTableAttr" select="ahf:getSimpleTableAttr(.)" as="element()"/>
        <!-- Complement the @relcolwidth and calculate the column width ratio -->
        <xsl:variable name="colWidthSeq" as="xs:double+">
            <xsl:call-template name="buildStColWidthSeq">
                <xsl:with-param name="prmSimpleTable" select="."/>
            </xsl:call-template>
        </xsl:variable>
        
        <w:tbl>
            <w:tblPr>
                <xsl:call-template name="genTblPr">
                    <xsl:with-param name="prmTgroupAttr" select="$simpleTableAttr"/>
                </xsl:call-template>
            </w:tblPr>    
            <w:tblGrid>
                <xsl:call-template name="genStGridCol">
                    <xsl:with-param name="prmSimpleTable" select="."/>
                    <xsl:with-param name="prmColWidthSeq" select="$colWidthSeq"/>
                </xsl:call-template>
            </w:tblGrid>
            
            <xsl:apply-templates select="*[contains(@class, ' topic/sthead ')]">
                <xsl:with-param name="prmSimpleTableAttr" tunnel="yes" select="$simpleTableAttr"/>
                <xsl:with-param name="prmIndentLevel"    tunnel="yes" select="0"/>
                <xsl:with-param name="prmExtraIndent"    tunnel="yes" select="0"/>
            </xsl:apply-templates>

            <xsl:apply-templates select="*[contains(@class, ' topic/strow ')]">
                <xsl:with-param name="prmSimpleTableAttr" tunnel="yes" select="$simpleTableAttr"/>
                <xsl:with-param name="prmIndentLevel"    tunnel="yes" select="0"/>
                <xsl:with-param name="prmExtraIndent"    tunnel="yes" select="0"/>
            </xsl:apply-templates>
        </w:tbl>
        <xsl:copy-of select="ahf:genSpaceAfterOnlyP('SpaceAfterForTable')"/>
    </xsl:template>
    
    <!-- 
     function:	build simpletable attributes
     param:		prmSimpleTable
     return:	element()
     note:		Set default table attribute value if not specified. 
                "scale" and "expance" are not supported in WML output.
                In default the @rowsep and @colsep are treated as "1".
     -->
    <xsl:function name="ahf:getSimpleTableAttr" as="element()">
        <xsl:param name="prmSimpleTable" as="element()"/>
        <dummy>
            <xsl:attribute name="relcolwidth" select="if (exists($prmSimpleTable/@relcolwidth))  then string($prmSimpleTable/@relcolwidth) else ''"/>
            <xsl:attribute name="keycol" select="if (exists($prmSimpleTable/@keycol))  then string($prmSimpleTable/@keycol) else ''"/>
            <xsl:attribute name="scale" select="if (exists($prmSimpleTable/@scale)) then string($prmSimpleTable/@scale) else '100'"/>
            <xsl:attribute name="frame"  select="if (exists($prmSimpleTable/@frame))  then string($prmSimpleTable/@frame) else 'all'"/>
            <xsl:attribute name="expance" select="if (exists($prmSimpleTable/@expanse)) then string($prmSimpleTable/@expanse) else 'textline '"/>
            <xsl:attribute name="rowsep" select="'1'"/>
            <xsl:attribute name="colsep" select="'1'"/>
            <xsl:copy-of select="$prmSimpleTable/@class"/>
        </dummy>
    </xsl:function>
    
    <!-- 
     function:	Generate nomalized colum width sequence for simpletable
     param:		prmSimpleTable
     return:    xs:double+
     note:      simpletable uses @relcolwidth to express column width.
                @relcolwidth will not work currently because simpletable is outputted as <w:tblLayout w:type="autofit"/>.
     -->
    <xsl:template name="buildStColWidthSeq" as="xs:double+">
        <xsl:param name="prmSimpleTable" as="element()" required="yes"/>
        <xsl:variable name="colCount" as="xs:integer" select="count($prmSimpleTable/*[contains(@class,' topic/strow ')][1]/*[contains(@class,' topic/stentry ')])"/>
        <xsl:variable name="relColWidth" as="xs:double+">
            <xsl:choose>
                <xsl:when test="string($prmSimpleTable/@relcolwidth)">
                    <xsl:variable name="relColWidthAttVal" as="xs:string" select="string($prmSimpleTable/@relcolwidth)"/>
                    <xsl:for-each select="tokenize($relColWidthAttVal,'[\s]+')">
                        <xsl:variable name="colWidth" as="xs:string" select="substring-before(.,'*')"/>
                        <xsl:choose>
                            <xsl:when test="$colWidth castable as xs:double">
                                <xsl:sequence select="xs:double($colWidth)"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:call-template name="warningContinue">
                                    <xsl:with-param name="prmMes" select="ahf:replace($stMes2500,('%relcolwidth'),($relColWidthAttVal))"/>
                                </xsl:call-template>
                                <xsl:sequence select="1.0"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="for $n in (1 to $colCount) return 1.0"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <!-- Complement colwidth -->
        <xsl:variable name="colspecComplemented" as="xs:double+">
            <xsl:for-each select="1 to $colCount">
                <xsl:variable name="colPos" as="xs:integer" select="."/>
                <xsl:choose>
                    <xsl:when test="exists($relColWidth[$colPos])">
                        <xsl:sequence select="$relColWidth[$colPos]"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:sequence select="1.0"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:variable>

        <!-- Calculate column width sum -->
        <xsl:variable name="colWidthSum" as="xs:double" select="sum($colspecComplemented)"/>
        
        <!-- Calculate column width ratio --> 
        <xsl:variable name="colspecCalculated" as="xs:double+">
            <xsl:for-each select="$colspecComplemented">
                <xsl:sequence select="xs:double(. div $colWidthSum * 100)"/>
            </xsl:for-each>
        </xsl:variable>
        
        <xsl:sequence select="$colspecCalculated"/>
    </xsl:template>

    <!-- 
     function:	Genrate w:gridCol from colspec 
     param:		none
     return:	w:gridCol
     note:		w:gridCol/@w:w only expresses column width ratio here. 
                Not actual width.
     -->
    <xsl:template name="genStGridCol" as="element()+">
        <xsl:param name="prmSimpleTable" as="element()" required="yes"/>
        <xsl:param name="prmColWidthSeq" as="xs:double+" required="yes"/>
        <xsl:variable name="colInfo" as="item()+" select="map:get($columnMap,ahf:generateId($prmSimpleTable/ancestor::*[contains(@class,' topic/body ')]))"/>
        <xsl:variable name="columnCount" as="xs:integer" select="xs:integer($colInfo[2])"/>
        <xsl:variable name="bodyWidth" as="xs:integer">
            <xsl:choose>
                <xsl:when test="$columnCount eq 1">
                    <xsl:sequence select="ahf:toTwip($pPaperBodyWidth)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="ahf:toTwip($pPaperBodyWidth) div $columnCount - ahf:toTwip($pPaperColumnGap) * ($columnCount - 1) div $columnCount"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:for-each select="$prmColWidthSeq">
            <w:gridCol>
                <xsl:variable name="colWidthRatio" as="xs:double" select="."/>
                <xsl:attribute name="w:w" select="xs:integer(round($bodyWidth * $colWidthRatio div 100))"/>
            </w:gridCol>
        </xsl:for-each>
    </xsl:template>

    <!-- 
     function:	sthead template 
     param:		see simpletable template
     return:	none
     note:		
     -->
    <xsl:template match="*[contains(@class,' topic/sthead ')]">
        <w:tr>
            <w:trPr>
                <xsl:copy-of select="ahf:getWmlObject('wmlTrPrHead')"/>
            </w:trPr>
            <xsl:apply-templates select="*[contains(@class,' topic/stentry ')]"/>
        </w:tr>
    </xsl:template>

    <!-- 
     function:	strow template 
     param:		see simpletable template
     return:	none
     note:		
     -->
    <xsl:template match="*[contains(@class,' topic/strow ')]">
        <w:tr>
            <w:trPr>
                <xsl:copy-of select="ahf:getWmlObject('wmlTrPrBody')"/>
            </w:trPr>
            <xsl:apply-templates select="*[contains(@class,' topic/stentry ')]"/>
        </w:tr>
    </xsl:template>
    
    <!-- 
     function:	Generate w:tc from stentry
     param:		see simplateable template
     return:	w:tc
     note:		
     -->
    <xsl:template match="*[contains(@class,' topic/stentry ')]">
        <xsl:param name="prmSimpleTableAttr" tunnel="yes" as="element()" required="yes"/>
        <xsl:variable name="stentry" as="element()" select="."/>
        <w:tc>
            <w:tcPr>
                <xsl:call-template name="genStTcPr">
                    <xsl:with-param name="prmStEntry" select="$stentry"/>
                    <xsl:with-param name="prmStEntryAttr" select="$prmSimpleTableAttr"/>
                </xsl:call-template>
            </w:tcPr>
            <xsl:choose>
                <xsl:when test="empty(*)">
                    <w:p/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates/>
                </xsl:otherwise>
            </xsl:choose>
        </w:tc>
        
    </xsl:template>
    
    <!-- 
     function:	Generate w:tcPr from stentry
     param:		prmEntry, prmEntryAttr
     return:	child of w:tcPr
     note:		Child of w:tcPr must satisfy following sequence:
                cnfStyle,tcW,gridSpan,vMerge,tcBorders,shd,noWrap,tcMar
                textDirection,tcFitText,vAlign,hideMark,headers
     -->
    <xsl:template name="genStTcPr">
        <xsl:param name="prmStEntry" as="element()" required="yes"/>
        <xsl:param name="prmStEntryAttr" as="element()" required="yes"/>
        <xsl:variable name="colNum" as="xs:integer" select="count($prmStEntry | $prmStEntry/preceding-sibling::*)"/>
        <xsl:variable name="keyColNum" as="xs:integer">
            <xsl:variable name="keycol" as="xs:string" select="string($prmStEntryAttr/@keycol)"/>
            <xsl:choose>
                <xsl:when test="$keycol castable as xs:integer">
                    <xsl:sequence select="xs:integer($keycol)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="0"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="isThead" as="xs:boolean" select="exists($prmStEntry/ancestor::*[contains(@class,' topic/sthead ')]) or ($colNum eq $keyColNum)"/>
        
        <!-- w:tcW -->
        <w:tcW>
            <xsl:call-template name="getAttributeSet">
                <xsl:with-param name="prmAttrSetName" as="xs:string">
                    <xsl:sequence select="'atsTcW'"/>
                </xsl:with-param>
            </xsl:call-template>
        </w:tcW>
        
        <!-- w:tcBorders -->
        <xsl:variable name="hasColSep" as="xs:boolean" select="string($prmStEntryAttr/@colsep) eq '1'"/>
        <xsl:variable name="hasRowSep" as="xs:boolean" select="string($prmStEntryAttr/@rowsep) eq '1'"/>
        <xsl:variable name="isLastCol" as="xs:boolean" select="empty($prmStEntry/following-sibling::*)"/>
        <xsl:variable name="isLastRow" as="xs:boolean" select="empty($prmStEntry/parent::*/following-sibling::*)"/>
        <xsl:variable name="isNotLastRow" as="xs:boolean" select="not($isLastRow)"/>
        <xsl:variable name="drawBottomBorder" as="xs:boolean" select="$hasRowSep and $isNotLastRow"/>
        <xsl:variable name="drawEndBorder" as="xs:boolean" select="$hasColSep and not($isLastCol)"/>
        <xsl:if test="$drawBottomBorder or $drawEndBorder">
            <w:tcBorders>
                <xsl:if test="$drawBottomBorder">
                    <w:bottom>
                        <xsl:call-template name="getAttributeSet">
                            <xsl:with-param name="prmAttrSetName" select="'atsTableCellBorderBottom'"/>
                        </xsl:call-template>
                    </w:bottom>
                </xsl:if>
                <xsl:if test="$drawEndBorder">
                    <w:end>
                        <xsl:call-template name="getAttributeSet">
                            <xsl:with-param name="prmAttrSetName" select="'atsTableCellBorderEnd'"/>
                        </xsl:call-template>
                    </w:end>
                </xsl:if>
            </w:tcBorders>
        </xsl:if>
        
        <!-- w:shd -->
        <xsl:if test="$isThead">
            <w:shd>
                <xsl:call-template name="getAttributeSet">
                    <xsl:with-param name="prmAttrSetName" select="'atsTableCellShading'"/>
                </xsl:call-template>
            </w:shd>
        </xsl:if>
        
    </xsl:template>
    
    <!-- END OF STYLESHEET -->

</xsl:stylesheet>