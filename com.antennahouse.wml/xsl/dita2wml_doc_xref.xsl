<?xml version="1.0" encoding="UTF-8"?>
<!--
**************************************************************
DITA to WordprocessingML Stylesheet
Document.xml Xref element Templates
**************************************************************
File Name : dita2wml_document_xref.xsl
**************************************************************
Copyright © 2009-2017 Antenna House, Inc. All rights reserved.
Antenna House is a trademark of Antenna House, Inc.
URL : http://www.antennahouse.com/
**************************************************************
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" 
    xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    exclude-result-prefixes="xs ahf map"
    version="3.0">

    <!-- 
     function:	Xref processing
     param:		prmRunProps (tunnel)
     return:	w:r with field
     note:		The xref target is already searched in dita2wml_global_bookmark.xsl
     -->
    <xsl:variable name="xrefOptTitleAndPage" as="xs:string">
        <xsl:call-template name="getVarValue">
            <xsl:with-param name="prmVarName" select="'XrefOptTitleAndPage'"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="xrefOptTitleOnly" as="xs:string">
        <xsl:call-template name="getVarValue">
            <xsl:with-param name="prmVarName" select="'XrefOptTitleOnly'"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="xrefOptPageOnly" as="xs:string">
        <xsl:call-template name="getVarValue">
            <xsl:with-param name="prmVarName" select="'XrefOptPageOnly'"/>
        </xsl:call-template>
    </xsl:variable>
    
    <!-- Common xref run prop (Italic) -->
    <xsl:variable name="xrefRunProp" as="element()*">
        <xsl:call-template name="getWmlObject">
            <xsl:with-param name="prmObjName" select="'wmlXrefRunProp'"/>
        </xsl:call-template>
    </xsl:variable>
    
    <xsl:template match="*[contains(@class,' topic/xref ')]">
        <xsl:param name="prmRunProps" tunnel="yes" required="no" as="element()*" select="()"/>
        <xsl:variable name="xref" as="element()" select="."/>
        <xsl:variable name="href" as="xs:string" select="string(@href)"/>
        <xsl:variable name="isInternalLink" as="xs:boolean" select="starts-with($href,'#')"/>
        <xsl:variable name="mergedXrefRunProps" as="element()*" select="ahf:mergeRunProps($prmRunProps,$xrefRunProp)"/>
        <xsl:choose>
            <xsl:when test="$isInternalLink">
                <xsl:call-template name="processInternalXref">
                    <xsl:with-param name="prmXref" select="$xref"/>
                    <xsl:with-param name="prmHref" select="$href"/>
                    <xsl:with-param name="prmRunProps" tunnel="yes" select="$mergedXrefRunProps"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="processExternalXref">
                    <xsl:with-param name="prmXref" select="$xref"/>
                    <xsl:with-param name="prmHref" select="$href"/>
                    <xsl:with-param name="prmRunProps" tunnel="yes" select="$mergedXrefRunProps"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- 
     function:	Internal Xref processing
     param:		prmXref, prmHref, prmRunProps (tunnel)
     return:	w:r with field
     note:		
     -->
    <xsl:template name="processInternalXref" as="element()*">
        <xsl:param name="prmXref" as="element()" required="yes"/>
        <xsl:param name="prmHref" as="xs:string" required="yes"/>
        <xsl:variable name="targetElemInfo" as="item()*" select="map:get($bookmarkTargetMap,$prmHref)"/>
        <xsl:variable name="targetId" as="xs:string?" select="$targetElemInfo[1]"/>
        <xsl:variable name="targetElem" as="element()?" select="$targetElemInfo[2]"/>
        <xsl:variable name="targetTopic" as="element()?" select="$targetElem/ancestor-or-self::*[contains(@class,' topic/topic ')][last()]"/>
        <xsl:variable name="topicRef" as="element()?" select="ahf:getTopicRef($targetTopic)"/>
        <xsl:variable name="targetElemNumber" as="xs:integer?" select="map:get($targetElemIdAndNumberMap,$targetId)"/>
        <xsl:choose>
            <xsl:when test="empty($targetElemInfo) or not(string($targetId))">
                <xsl:call-template name="warningContinue">
                    <xsl:with-param name="prmMes" select="ahf:replace($stMes2032,('%xref','%href'),(ahf:getNodeXPathStr(.),$prmHref))"/>
                </xsl:call-template>
            </xsl:when>
            <!-- Reference to topic -->
            <xsl:when test="$targetElem[contains(@class,' topic/topic ')]">
                <xsl:call-template name="xrefToTopic">
                    <xsl:with-param name="prmXref"     select="$prmXref"/>
                    <xsl:with-param name="prmTopicRef" select="$topicRef"/>
                    <xsl:with-param name="prmTopic"    select="$targetElem"/>
                    <xsl:with-param name="prmTargetElemNumber"    select="$targetElemNumber"/>
                </xsl:call-template>                    
            </xsl:when>
            <!-- Reference to example, section -->
            <xsl:when test="$targetElem[ahf:seqContains(@class,(' topic/section ',' topic/example '))][exists(*[contains(@class,' topic/title ')])]">
                <xsl:call-template name="xrefToSection">
                    <xsl:with-param name="prmXref"     select="$prmXref"/>
                    <xsl:with-param name="prmTopicRef" select="$topicRef"/>
                    <xsl:with-param name="prmTargetElem"  select="$targetElem"/>
                    <xsl:with-param name="prmTargetElemNumber"  select="$targetElemNumber"/>
                </xsl:call-template>                    
            </xsl:when>
            <!-- Reference to table -->
            <xsl:when test="$targetElem[contains(@class,(' topic/table '))][exists(*[contains(@class,' topic/title ')])]">
                <xsl:call-template name="xrefToTable">
                    <xsl:with-param name="prmXref"     select="$prmXref"/>
                    <xsl:with-param name="prmTopicRef" select="$topicRef"/>
                    <xsl:with-param name="prmTargetElem"  select="$targetElem"/>
                    <xsl:with-param name="prmTargetElemNumber"  select="$targetElemNumber"/>
                </xsl:call-template>                    
            </xsl:when>
            <!-- Reference to fig -->
            <xsl:when test="$targetElem[contains(@class,' topic/fig ')][exists(*[contains(@class,' topic/title ')])]">
                <xsl:call-template name="xrefToFig">
                    <xsl:with-param name="prmXref"     select="$prmXref"/>
                    <xsl:with-param name="prmTopicRef" select="$topicRef"/>
                    <xsl:with-param name="prmTargetElem"  select="$targetElem"/>
                    <xsl:with-param name="prmTargetElemNumber"  select="$targetElemNumber"/>
                </xsl:call-template>                    
            </xsl:when>
            <!-- Reference to ol/li -->
            <xsl:when test="$targetElem[contains(@class,' topic/li ')][parent::*[contains(@class,' topic/ol ')]]">
                <xsl:call-template name="xrefToOlLi">
                    <xsl:with-param name="prmTopicRef" select="$topicRef"/>
                    <xsl:with-param name="prmTargetElem"  select="$targetElem"/>
                    <xsl:with-param name="prmTargetElemNumber"  select="$targetElemNumber"/>
                </xsl:call-template>                    
            </xsl:when>
            <!-- Reference to fn -->
            <xsl:when test="$targetElem[contains(@class,' topic/fn ')]">
                <xsl:call-template name="xrefToFn">
                    <xsl:with-param name="prmXref" select="$prmXref"/>
                    <xsl:with-param name="prmTopicRef" select="$topicRef"/>
                    <xsl:with-param name="prmTargetElem"  select="$targetElem"/>
                    <xsl:with-param name="prmTargetElemNumber"  select="$targetElemNumber"/>
                </xsl:call-template>                    
            </xsl:when>
            <xsl:otherwise>
                <!-- Not Yet Implemented -->
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- 
     function:	Judge output title for Xref to topic
     param:		prmXref
     return:	xs:boolean
     note:		
     -->
    <xsl:function name="ahf:outputTopicTitleForXref" as="xs:boolean">
        <xsl:param name="prmXref" as="element()"/>
        <xsl:variable name="outputClass" as="xs:string*" select="ahf:getOutputClass($prmXref)"/>
        <xsl:sequence select="($outputClass = $xrefOptTitleAndPage) or ($outputClass = $xrefOptTitleOnly) or not($outputClass = ($xrefOptTitleAndPage,$xrefOptTitleOnly,$xrefOptPageOnly))"/>
    </xsl:function>
    
    <!-- 
     function:	Judge output page for Xref to topic
     param:		prmXref
     return:	xs:boolean
     note:		
     -->
    <xsl:function name="ahf:outputTopicPageForXref" as="xs:boolean">
        <xsl:param name="prmXref" as="element()"/>
        <xsl:variable name="outputClass" as="xs:string*" select="ahf:getOutputClass($prmXref)"/>
        <xsl:sequence select="($outputClass = $xrefOptTitleAndPage) or ($outputClass = $xrefOptPageOnly) or not($outputClass = ($xrefOptTitleAndPage,$xrefOptTitleOnly,$xrefOptPageOnly))"/>
    </xsl:function>

    <!-- 
     function:	Xref to topic template
     param:		prmXref, prmHref, prmRunProps (tunnel)
     return:	w:r with field
     note:		Set U+00A0 to the PAGEREF field result to retain inherited run property such as <b>.
                U+0020 does not work in this case.
     -->
    <xsl:template name="xrefToTopic" as="element(w:r)+">
        <xsl:param name="prmXref"             as="element()" required="yes"/>
        <xsl:param name="prmTopicRef"         as="element()" required="yes"/>
        <xsl:param name="prmTopic"            as="element()" required="yes"/>
        <xsl:param name="prmTargetElemNumber" as="xs:integer" required="yes"/>
        <xsl:param name="prmRunProps" tunnel="yes" required="no" as="element()*" select="()"/>
        <xsl:variable name="outputTitle" as="xs:boolean" select="ahf:outputTopicTitleForXref($prmXref)"/>
        <xsl:variable name="outputPage"  as="xs:boolean" select="ahf:outputTopicPageForXref($prmXref)"/>
        <xsl:variable name="titlePrefix" as="xs:string">
            <xsl:call-template name="genTitlePrefix">
                <xsl:with-param name="prmTopicRef" select="$prmTopicRef"/>
            </xsl:call-template>                                        
        </xsl:variable>
        <xsl:if test="$pAddChapterNumberPrefixToTopicTitle and string($titlePrefix) and $outputTitle">
            <xsl:variable name="titlePrefixResult" as="element(w:r)">
                <w:r>
                    <xsl:if test="exists($prmRunProps)">
                        <w:rPr>
                            <xsl:copy-of select="$prmRunProps"/>
                        </w:rPr>
                    </xsl:if>
                    <w:t>
                        <xsl:value-of select="$titlePrefix"/>
                    </w:t>
                </w:r>
            </xsl:variable>
            <xsl:call-template name="getWmlObjectReplacing">
                <xsl:with-param name="prmObjName" select="'wmlRefField'"/>
                <xsl:with-param name="prmSrc" select="('%ref-id','%field-opt','node:field-result')"/>
                <xsl:with-param name="prmDst" select="(ahf:genBookmarkName($prmTargetElemNumber),'\w',$titlePrefixResult)"/>
            </xsl:call-template>
            <w:r>
                <w:t xml:space="preserve"> </w:t>
            </w:r>
        </xsl:if>
        <xsl:if test="$outputTitle">
            <xsl:variable name="title" as="node()*">
                <xsl:apply-templates select="$prmTopic/*[contains(@class,' topic/title ')]/node()">
                    <xsl:with-param name="prmSkipBookmark" tunnel="yes" select="true()"/>
                    <xsl:with-param name="prmSkipFn"       tunnel="yes" select="true()"/>
                </xsl:apply-templates>
            </xsl:variable>
            <xsl:call-template name="getWmlObjectReplacing">
                <xsl:with-param name="prmObjName" select="'wmlRefField'"/>
                <xsl:with-param name="prmSrc" select="('%ref-id','%field-opt','node:field-result')"/>
                <xsl:with-param name="prmDst" select="(ahf:genBookmarkName($prmTargetElemNumber),'',$title)"/>
            </xsl:call-template>
        </xsl:if>
        <xsl:call-template name="outputPageRef">
            <xsl:with-param name="prmOutputTitle" select="$outputTitle"/>
            <xsl:with-param name="prmOutputPage" select="$outputPage"/>
            <xsl:with-param name="prmTargetElemNumber" select="$prmTargetElemNumber"/>            
        </xsl:call-template>
    </xsl:template>

    <!-- 
     function:	Output page number template
     param:		prmXref
     return:	w:r*
     note:		
     -->
    <xsl:template name="outputPageRef" as="element(w:r)*">
        <xsl:param name="prmRunProps"    as="element()*" tunnel="yes" required="false" select="()"/>
        <xsl:param name="prmOutputTitle" as="xs:boolean" required="yes"/>
        <xsl:param name="prmOutputPage"  as="xs:boolean" required="yes"/>
        <xsl:param name="prmTargetElemNumber"  as="xs:integer" required="yes"/>
        <xsl:choose>
            <xsl:when test="$prmOutputTitle and $prmOutputPage">
                <xsl:variable name="xrefPagePrefix" as="xs:string">
                    <xsl:call-template name="getVarValue">
                        <xsl:with-param name="prmVarName" select="'XrefPagePrefix'"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:variable name="xrefPageSuffix" as="xs:string">
                    <xsl:call-template name="getVarValue">
                        <xsl:with-param name="prmVarName" select="'XrefPageSuffix'"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:variable name="pageRefResult" as="document-node()">
                    <xsl:document>
                        <w:r>
                            <xsl:if test="exists($prmRunProps)">
                                <w:rPr>
                                    <xsl:copy-of select="$prmRunProps"/>
                                </w:rPr>
                            </xsl:if>
                            <w:t xml:space="preserve">&#xA0;</w:t>
                        </w:r>
                    </xsl:document>
                </xsl:variable>
                <w:r>
                    <xsl:if test="exists($prmRunProps)">
                        <w:rPr>
                            <xsl:copy-of select="$prmRunProps"/>
                        </w:rPr>
                    </xsl:if>
                    <w:t xml:space="preserve"><xsl:value-of select="$xrefPagePrefix"/></w:t>
                </w:r>
                <xsl:call-template name="getWmlObjectReplacing">
                    <xsl:with-param name="prmObjName" select="'wmlPageRefField'"/>
                    <xsl:with-param name="prmSrc" select="('%bookmark','%field-opt','node:field-result')"/>
                    <xsl:with-param name="prmDst" select="(ahf:genBookmarkName($prmTargetElemNumber),'',$pageRefResult)"/>
                </xsl:call-template>
                <w:r>
                    <xsl:if test="exists($prmRunProps)">
                        <w:rPr>
                            <xsl:copy-of select="$prmRunProps"/>
                        </w:rPr>
                    </xsl:if>
                    <w:t xml:space="preserve"><xsl:value-of select="$xrefPageSuffix"/></w:t>
                </w:r>
            </xsl:when>
            <xsl:when test="not($prmOutputTitle) and $prmOutputPage">
                <xsl:variable name="xrefPageOnlyPrefix" as="xs:string">
                    <xsl:call-template name="getVarValue">
                        <xsl:with-param name="prmVarName" select="'XrefPageOnlyPrefix'"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:variable name="xrefPageOnlySuffix" as="xs:string">
                    <xsl:call-template name="getVarValue">
                        <xsl:with-param name="prmVarName" select="'XrefPageOnlySuffix'"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:variable name="pageRefResult" as="document-node()">
                    <xsl:document>
                        <w:r>
                            <xsl:if test="exists($prmRunProps)">
                                <w:rPr>
                                    <xsl:copy-of select="$prmRunProps"/>
                                </w:rPr>
                            </xsl:if>
                            <w:t xml:space="preserve">&#xA0;</w:t>
                        </w:r>
                    </xsl:document>
                </xsl:variable>
                <w:r>
                    <xsl:if test="exists($prmRunProps)">
                        <w:rPr>
                            <xsl:copy-of select="$prmRunProps"/>
                        </w:rPr>
                    </xsl:if>
                    <w:t xml:space="preserve"><xsl:value-of select="$xrefPageOnlyPrefix"/></w:t>
                </w:r>
                <xsl:call-template name="getWmlObjectReplacing">
                    <xsl:with-param name="prmObjName" select="'wmlPageRefField'"/>
                    <xsl:with-param name="prmSrc" select="('%bookmark','%field-opt','node:field-result')"/>
                    <xsl:with-param name="prmDst" select="(ahf:genBookmarkName($prmTargetElemNumber),'',$pageRefResult)"/>
                </xsl:call-template>
                <w:r>
                    <xsl:if test="exists($prmRunProps)">
                        <w:rPr>
                            <xsl:copy-of select="$prmRunProps"/>
                        </w:rPr>
                    </xsl:if>
                    <w:t xml:space="preserve"><xsl:value-of select="$xrefPageOnlySuffix"/></w:t>
                </w:r>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    

    <!-- 
     function:	Judge output title for Xref to section/example
     param:		prmXref
     return:	xs:boolean
     note:		
     -->
    <xsl:function name="ahf:outputSectionTitleForXref" as="xs:boolean">
        <xsl:param name="prmXref" as="element()"/>
        <xsl:variable name="outputClass" as="xs:string*" select="ahf:getOutputClass($prmXref)"/>
        <xsl:sequence select="$outputClass = $xrefOptTitleAndPage or $outputClass = $xrefOptTitleOnly or not($outputClass = ($xrefOptTitleAndPage,$xrefOptTitleOnly,$xrefOptPageOnly))"/>
    </xsl:function>
    
    <!-- 
     function:	Judge output page for Xref to section/example
     param:		prmXref
     return:	xs:boolean
     note:		Default: not output page
     -->
    <xsl:function name="ahf:outputSectionPageForXref" as="xs:boolean">
        <xsl:param name="prmXref" as="element()"/>
        <xsl:variable name="outputClass" as="xs:string*" select="ahf:getOutputClass($prmXref)"/>
        <xsl:sequence select="$outputClass = $xrefOptTitleAndPage or $outputClass = $xrefOptPageOnly"/>
    </xsl:function>

    <!-- 
     function:	Xref to section template
     param:		prmXref, prmHref, prmRunProps (tunnel)
     return:	w:r with field
     note:		
     -->
    <xsl:template name="xrefToSection" as="element(w:r)+">
        <xsl:param name="prmXref"             as="element()" required="yes"/>
        <xsl:param name="prmTopicRef"         as="element()" required="yes"/>
        <xsl:param name="prmTargetElem"       as="element()" required="yes"/>
        <xsl:param name="prmTargetElemNumber" as="xs:integer" required="yes"/>
        <xsl:param name="prmRunProps" tunnel="yes" required="no" as="element()*" select="()"/>
        <xsl:variable name="outputTitle" as="xs:boolean" select="ahf:outputSectionTitleForXref($prmXref)"/>
        <xsl:variable name="outputPage"  as="xs:boolean" select="ahf:outputSectionPageForXref($prmXref)"/>
        <xsl:if test="$outputTitle">
            <xsl:variable name="title" as="node()*">
                <xsl:apply-templates select="$prmTargetElem/*[contains(@class,' topic/title ')]/node()">
                    <xsl:with-param name="prmSkipBookmark" tunnel="yes" select="true()"/>
                    <xsl:with-param name="prmSkipFn"       tunnel="yes" select="true()"/>
                </xsl:apply-templates>
            </xsl:variable>
            <xsl:call-template name="getWmlObjectReplacing">
                <xsl:with-param name="prmObjName" select="'wmlRefField'"/>
                <xsl:with-param name="prmSrc" select="('%ref-id','%field-opt','node:field-result')"/>
                <xsl:with-param name="prmDst" select="(ahf:genBookmarkName($prmTargetElemNumber),'',$title)"/>
            </xsl:call-template>
        </xsl:if>
        <xsl:call-template name="outputPageRef">
            <xsl:with-param name="prmOutputTitle" select="$outputTitle"/>
            <xsl:with-param name="prmOutputPage" select="$outputPage"/>
            <xsl:with-param name="prmTargetElemNumber" select="$prmTargetElemNumber"/>            
        </xsl:call-template>
    </xsl:template>

    <!-- 
     function:	Judge output title for Xref to fig/table
     param:		prmXref
     return:	xs:boolean
     note:		
     -->
    <xsl:function name="ahf:outputFigTblTitleForXref" as="xs:boolean">
        <xsl:param name="prmXref" as="element()"/>
        <xsl:variable name="outputClass" as="xs:string*" select="ahf:getOutputClass($prmXref)"/>
        <xsl:sequence select="$outputClass = $xrefOptTitleAndPage or $outputClass = $xrefOptTitleOnly or not($outputClass = ($xrefOptTitleAndPage,$xrefOptTitleOnly,$xrefOptPageOnly))"/>
    </xsl:function>
    
    <!-- 
     function:	Judge output page for Xref to section/example
     param:		prmXref
     return:	xs:boolean
     note:		Default: not output page
     -->
    <xsl:function name="ahf:outputFigTblPageForXref" as="xs:boolean">
        <xsl:param name="prmXref" as="element()"/>
        <xsl:variable name="outputClass" as="xs:string*" select="ahf:getOutputClass($prmXref)"/>
        <xsl:sequence select="$outputClass = $xrefOptTitleAndPage or $outputClass = $xrefOptPageOnly"/>
    </xsl:function>

    <!-- 
     function:	Xref to table template
     param:		prmXref, prmHref, prmRunProps (tunnel)
     return:	w:r with field
     note:		
     -->
    <xsl:template name="xrefToTable" as="element(w:r)+">
        <xsl:param name="prmXref"             as="element()" required="yes"/>
        <xsl:param name="prmTopicRef"         as="element()" required="yes"/>
        <xsl:param name="prmTargetElem"       as="element()" required="yes"/>
        <xsl:param name="prmTargetElemNumber" as="xs:integer" required="yes"/>
        <xsl:param name="prmRunProps" tunnel="yes" required="no" as="element()*" select="()"/>
        <xsl:variable name="outputTitle" as="xs:boolean" select="ahf:outputFigTblTitleForXref($prmXref)"/>
        <xsl:variable name="outputPage"  as="xs:boolean" select="ahf:outputFigTblPageForXref($prmXref)"/>
        <xsl:if test="$outputTitle">
            <xsl:variable name="targetTableTitleResultWithField" as="document-node()">
                <xsl:document>
                    <xsl:call-template name="ahf:getTableTitlePrefix">
                        <xsl:with-param name="prmTable" select="$prmTargetElem/parent::*"/>
                        <xsl:with-param name="prmTopicRef" tunnel="yes" select="$prmTopicRef"/>
                    </xsl:call-template>
                    <xsl:apply-templates select="$prmTargetElem/*[contains(@class,' topic/title ')]/node()">
                        <xsl:with-param name="prmTopicRef" tunnel="yes" select="$prmTopicRef"/>
                        <xsl:with-param name="prmSkipBookmark" tunnel="yes" select="true()"/>
                        <xsl:with-param name="prmSkipFn"       tunnel="yes" select="true()"/>
                    </xsl:apply-templates>
                </xsl:document>
            </xsl:variable>
            <xsl:variable name="targetTableTitleResult" as="document-node()">
                <xsl:document>
                    <xsl:copy-of select="$targetTableTitleResultWithField/w:r[exists(w:t)]"/>
                </xsl:document>
            </xsl:variable>
            <xsl:call-template name="getWmlObjectReplacing">
                <xsl:with-param name="prmObjName" select="'wmlRefField'"/>
                <xsl:with-param name="prmSrc" select="('%ref-id','%field-opt','node:field-result')"/>
                <xsl:with-param name="prmDst" select="(ahf:genBookmarkName($prmTargetElemNumber),'',$targetTableTitleResult)"/>
            </xsl:call-template>
        </xsl:if>
        <xsl:call-template name="outputPageRef">
            <xsl:with-param name="prmOutputTitle" select="$outputTitle"/>
            <xsl:with-param name="prmOutputPage" select="$outputPage"/>
            <xsl:with-param name="prmTargetElemNumber" select="$prmTargetElemNumber"/>            
        </xsl:call-template>
    </xsl:template>

    <!-- 
     function:	Xref to fig template
     param:		prmXref, prmHref, prmRunProps (tunnel)
     return:	w:r with field
     note:		
     -->
    <xsl:template name="xrefToFig" as="element(w:r)+">
        <xsl:param name="prmXref"             as="element()" required="yes"/>
        <xsl:param name="prmTopicRef"            as="element()" required="yes"/>
        <xsl:param name="prmTargetElem"          as="element()" required="yes"/>
        <xsl:param name="prmTargetElemNumber"    as="xs:integer" required="yes"/>
        <xsl:variable name="outputTitle" as="xs:boolean" select="ahf:outputFigTblTitleForXref($prmXref)"/>
        <xsl:variable name="outputPage"  as="xs:boolean" select="ahf:outputFigTblPageForXref($prmXref)"/>
        <xsl:if test="$outputTitle">
            <xsl:variable name="targetFigTitleResultWithField" as="document-node()">
                <xsl:document>
                    <xsl:call-template name="ahf:getFigTitlePrefix">
                        <xsl:with-param name="prmFig" select="$prmTargetElem/parent::*"/>
                        <xsl:with-param name="prmTopicRef" tunnel="yes" select="$prmTopicRef"/>
                    </xsl:call-template>
                    <xsl:apply-templates select="$prmTargetElem/*[contains(@class,' topic/title ')]/node()">
                        <xsl:with-param name="prmTopicRef" tunnel="yes" select="$prmTopicRef"/>
                        <xsl:with-param name="prmSkipBookmark" tunnel="yes" select="true()"/>
                        <xsl:with-param name="prmSkipFn"       tunnel="yes" select="true()"/>
                    </xsl:apply-templates>
                </xsl:document>
            </xsl:variable>
            <xsl:variable name="targetFigTitleResult" as="document-node()">
                <xsl:document>
                    <xsl:copy-of select="$targetFigTitleResultWithField/w:r[exists(w:t)]"/>
                </xsl:document>
            </xsl:variable>
            <xsl:call-template name="getWmlObjectReplacing">
                <xsl:with-param name="prmObjName" select="'wmlRefField'"/>
                <xsl:with-param name="prmSrc" select="('%ref-id','%field-opt','node:field-result')"/>
                <xsl:with-param name="prmDst" select="(ahf:genBookmarkName($prmTargetElemNumber),'',$targetFigTitleResult)"/>
            </xsl:call-template>
        </xsl:if>
        <xsl:call-template name="outputPageRef">
            <xsl:with-param name="prmOutputTitle" select="$outputTitle"/>
            <xsl:with-param name="prmOutputPage" select="$outputPage"/>
            <xsl:with-param name="prmTargetElemNumber" select="$prmTargetElemNumber"/>            
        </xsl:call-template>
    </xsl:template>

    <!-- 
     function:	Xref to ol/li template
     param:		prmXref, prmHref, prmRunProps (tunnel)
     return:	w:r with field
     note:		You can change field result such as multi-level format "1.-a" by setting %field-opt as '\w \d -' instead of "\r'.
                Also the actual filed reslult should be changed to generate "1.-a".
                Varibale 'Ol_Number_Formats' must be changed according to the ol/li style.
                Xref to ol/li has no @outputclass rendering option.
     -->
    <xsl:template name="xrefToOlLi" as="element(w:r)+">
        <xsl:param name="prmTopicRef"            as="element()" required="yes"/>
        <xsl:param name="prmTargetElem"          as="element()" required="yes"/>
        <xsl:param name="prmTargetElemNumber"    as="xs:integer" required="yes"/>
        <xsl:param name="prmRunProps" tunnel="yes" required="no" as="element()*" select="()"/>
        <xsl:variable name="olNumberFormat" as="xs:string*">
            <xsl:variable name="olNumberFormats" as="xs:string">
                <xsl:call-template name="getVarValueWithLang">
                    <xsl:with-param name="prmVarName" select="'Ol_Number_Formats'"/>
                    <xsl:with-param name="prmElem" select="$prmTargetElem"/>
                </xsl:call-template>
            </xsl:variable>
            <xsl:for-each select="tokenize($olNumberFormats, '[\s]+')">
                <xsl:sequence select="."/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="olFormat" as="xs:string" select="ahf:getOlNumberFormat($prmTargetElem/parent::*,$olNumberFormat)"/>
        <xsl:variable name="liNumber" as="xs:integer" select="count($prmTargetElem|$prmTargetElem/preceding-sibling::*[not(contains(@class,' task/stepsection '))])"/>
        <xsl:variable name="targetLi" as="element(w:r)">
            <w:r>
                <xsl:if test="exists($prmRunProps)">
                    <w:rPr>
                        <xsl:copy-of select="$prmRunProps"/>
                    </w:rPr>
                </xsl:if>
                <w:t>
                    <xsl:number format="{$olFormat}" value="$liNumber"/>
                </w:t>
            </w:r>
        </xsl:variable>
        <xsl:call-template name="getWmlObjectReplacing">
            <xsl:with-param name="prmObjName" select="'wmlRefField'"/>
            <xsl:with-param name="prmSrc" select="('%ref-id','%field-opt','node:field-result')"/>
            <xsl:with-param name="prmDst" select="(ahf:genBookmarkName($prmTargetElemNumber),'\r',$targetLi)"/>
        </xsl:call-template>
    </xsl:template>

    <!-- 
     function:	Xref to fn template
     param:		prmXref, prmHref, prmRunProps (tunnel)
     return:	w:r with field
     note:		Xref to fn has no rendering @outputclass option
     -->
    <xsl:template name="xrefToFn" as="element()+">
        <xsl:param name="prmXref"                as="element()" required="yes"/>
        <xsl:param name="prmTopicRef"            as="element()" required="yes"/>
        <xsl:param name="prmTargetElem"          as="element()" required="yes"/>
        <xsl:param name="prmTargetElemNumber"    as="xs:integer" required="yes"/>
        <xsl:variable name="topic" as="element()" select="$prmXref/ancestor-or-self::*[contains(@class,' topic/topic ')][last()]"/>
        <xsl:variable name="key" as="xs:string" select="ahf:generateId($prmTargetElem)"/>
        <xsl:variable name="fnId" as="xs:integer?" select="map:get($fnIdMap,$key)[1]"/>
        <xsl:assert test="exists($fnId)" select="'[fn] key=',$key,' does not exists is $fnIdMap key=',ahf:mapKeyDump($fnIdMap)"/>
        <xsl:variable name="isFirstXrefToFn" as="xs:boolean">
            <xsl:variable name="sameXrefs" as="element()+" select="$topic/descendant::*[contains(@class,' topic/xref ')][string(@href) eq string($prmXref/@href)]"/>
            <xsl:sequence select="$sameXrefs[1] is $prmXref"/> 
        </xsl:variable>
        <xsl:choose>
            <!-- Generate w:footnoteReference from first xref to fn -->
            <xsl:when test="$isFirstXrefToFn">
                <xsl:copy-of select="ahf:genBookmarkStart($prmTargetElem)"/>
                <w:r>
                    <w:rPr>
                        <w:rStyle w:val="{ahf:getStyleIdFromName('footnote reference')}"/>
                    </w:rPr>
                    <xsl:choose>
                        <xsl:when test="$prmTargetElem/@callout">
                            <w:footnoteReference w:customMarkFollows="1" w:id="{string($fnId)}"/>
                            <w:t xml:space="preserve"><xsl:value-of select="$prmTargetElem/@callout"/></w:t>
                        </xsl:when>
                        <xsl:otherwise>
                            <w:footnoteReference w:id="{string($fnId)}"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </w:r>
                <xsl:copy-of select="ahf:genBookmarkEnd($prmTargetElem)"/>
            </xsl:when>
            <!-- Generate NOTEREF field from remaining xref to fn
                 The field result is determined by Word using Ctrl + A & F9
              -->
            <xsl:otherwise>
                <xsl:call-template name="getWmlObjectReplacing">
                    <xsl:with-param name="prmObjName" select="'wmlNoteRefField'"/>
                    <xsl:with-param name="prmSrc" select="('%bookmark','%field-opt')"/>
                    <xsl:with-param name="prmDst" select="(ahf:genBookmarkName($prmTargetElemNumber),'\f')"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- 
     function:	External Xref processing
     param:		prmXref, prmHref, prmRunProps (tunnel)
     return:	w:r with field
     note:		
     -->
    <xsl:template name="processExternalXref" as="element(w:hyperlink)">
        <xsl:param name="prmXref" as="element()" required="yes"/>
        <xsl:param name="prmHref" as="xs:string" required="yes"/>
        <xsl:param name="prmRunProps" tunnel="yes" required="no" as="element()*" select="()"/>
        <xsl:variable name="rId" as="xs:string" select="concat('rId',map:get(if ($prmXref/ancestor::*[contains(@class,' topic/fn ')]) then $externalFootnotesLinkIdMap else $externalDocumentLinkIdMap,$prmHref))"/>
        <w:hyperlink r:id="{$rId}" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">
            <xsl:apply-templates>
                <xsl:with-param name="prmRunProps" tunnel="yes" as="element()*">
                    <w:rStyle w:val="{ahf:getStyleIdFromName('Hyperlink')}"/>
                </xsl:with-param>
            </xsl:apply-templates>
        </w:hyperlink>
    </xsl:template>
    
    <!-- 
     function:	Get ol number format
     param:		prmOl, prmOlNumberFormat
     return:	Number format string
     note:		Count ol in entry/note independently.
                2015-06-03 t.makita
     -->
    <xsl:function name="ahf:getOlNumberFormat" as="xs:string">
        <xsl:param name="prmOl" as="element()"/>
        <xsl:param name="prmOlNumberFormat" as="xs:string+"/>
        
        <xsl:variable name="olNumberFormatCount" as="xs:integer" select="count($prmOlNumberFormat)"/>
        <xsl:variable name="olNestLevel" as="xs:integer" select="ahf:getListLevel($prmOl)"/>
        <xsl:variable name="formatOrder" as="xs:integer" select="$olNestLevel mod $olNumberFormatCount"/>
        <xsl:sequence select="$prmOlNumberFormat[if ($formatOrder eq 0) then $olNumberFormatCount else $formatOrder]"/>
    </xsl:function>
    
    <!-- 
     function:	Generate bookmark name 
     param:		prmSeq
     return:	xs:string
     note:		
     -->
    <xsl:param name="prmBooknamePrefix" as="xs:string" select="'Ref_'"/>
    
    <xsl:function name="ahf:genBookmarkName" as="xs:string">
        <xsl:param name="prmSeq" as="xs:integer"/>
        <xsl:sequence select="concat($prmBooknamePrefix,format-number($prmSeq,'00000'))"/>
    </xsl:function>
    
    <!-- 
     function:	Generate bookmark start
     param:		prmElem
     return:	element()?
     note:		
     -->
    <xsl:function name="ahf:genBookmarkStart" as="element()?">
        <xsl:param name="prmElem" as="element()"/>
        <xsl:variable name="id" as="xs:string" select="ahf:generateId($prmElem)"/>
        <xsl:variable name="seq" as="xs:integer?" select="map:get($targetElemIdAndNumberMap,$id)"/>
        <xsl:choose>
            <xsl:when test="exists($seq)">
                <w:bookmarkStart w:id="{$seq}" w:name="{ahf:genBookmarkName($seq)}"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:template name="genBookmarkStart" as="element()?">
        <xsl:param name="prmElem" as="element()" required="no" select="."/>
        <xsl:param name="prmSkipBookmark" as="xs:boolean" tunnel="yes" required="no" select="false()"/>
        <xsl:choose>
            <xsl:when test="$prmSkipBookmark">
                <xsl:sequence select="()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="ahf:genBookmarkStart($prmElem)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="genBookmarkStartWithNull" as="element()">
        <xsl:param name="prmElem" as="element()" required="no" select="."/>
        <xsl:param name="prmSkipBookmark" as="xs:boolean" tunnel="yes" required="no" select="false()"/>
        <xsl:choose>
            <xsl:when test="$prmSkipBookmark">
                <xsl:sequence select="$cElemNull"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="bmStart" as="element()?" select="ahf:genBookmarkStart($prmElem)"/>
                <xsl:sequence select="if (exists($bmStart)) then $bmStart else $cElemNull"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- 
     function:	Generate bookmark end
     param:		prmElem
     return:	element()?
     note:		
     -->
    <xsl:function name="ahf:genBookmarkEnd" as="element()?">
        <xsl:param name="prmElem" as="element()"/>
        <xsl:variable name="id" as="xs:string" select="ahf:generateId($prmElem)"/>
        <xsl:variable name="seq" as="xs:integer?" select="map:get($targetElemIdAndNumberMap,$id)"/>
        <xsl:choose>
            <xsl:when test="exists($seq)">
                <w:bookmarkEnd w:id="{$seq}"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:template name="genBookmarkEnd" as="element()?">
        <xsl:param name="prmElem" as="element()" required="no" select="."/>
        <xsl:param name="prmSkipBookmark" as="xs:boolean" tunnel="yes" required="no" select="false()"/>
        <xsl:choose>
            <xsl:when test="$prmSkipBookmark">
                <xsl:sequence select="()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="ahf:genBookmarkEnd($prmElem)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="genBookmarkEndWithNull" as="element()">
        <xsl:param name="prmElem" as="element()" required="no" select="."/>
        <xsl:param name="prmSkipBookmark" as="xs:boolean" tunnel="yes" required="no" select="false()"/>
        <xsl:choose>
            <xsl:when test="$prmSkipBookmark">
                <xsl:sequence select="$cElemNull"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="bmEnd" as="element()?" select="ahf:genBookmarkEnd($prmElem)"/>
                <xsl:sequence select="if (exists($bmEnd)) then $bmEnd else $cElemNull"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- 
     function:	Get bookmark name
     param:		prmElem
     return:	xs:string
     note:		
     -->
    <xsl:function name="ahf:getBookmarkName" as="xs:string?">
        <xsl:param name="prmElem" as="element()"/>
        <xsl:variable name="id" as="xs:string" select="ahf:generateId($prmElem)"/>
        <xsl:variable name="seq" as="xs:integer?" select="map:get($targetElemIdAndNumberMap,$id)"/>
        <xsl:choose>
            <xsl:when test="exists($seq)">
                <xsl:sequence select="ahf:genBookmarkName($seq)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:template name="getBookmarkName" as="xs:string">
        <xsl:param name="prmElem" as="element()" required="no" select="."/>
        <xsl:copy-of select="ahf:getBookmarkName($prmElem)"/>
    </xsl:template>

    <!-- 
     function:	xref/desc template
     param:		
     return:	
     note:		Don't generate <p>. This is inline element.
     -->
    <xsl:template match="*[contains(@class,' topic/xref ')]/*[contains(@class,' topic/desc ')]">
        <xsl:apply-templates/>
    </xsl:template>
    
    <!-- END OF STYLESHEET -->

</xsl:stylesheet>