<?xml version="1.0" encoding="UTF-8"?>
<!--
**************************************************************
DITA to WordprocessingML Stylesheet
w:sectPr Templates
**************************************************************
File Name : dita2wml_document_sectpr.xsl
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
    exclude-result-prefixes="xs map ahf" 
    version="3.0">
    
    <!-- 
     function:	Generate section properties from column & break information
     param:		  prmElem
     return:	  w:p? or w:sectPr? with debug comment()
     note:		  section varies by the following elements:
                topic, body, image (block level)
                getSectionPropertyElemBefore and getSectionPropertyElemAfter
                should be called before and after the element processing
    -->
    <!-- getSectionPropertyElemBefore only handles column spanned image
     -->
    <xsl:template name="getSectionPropertyElemBefore" as="node()*">
        <xsl:param name="prmElem" as="element()" required="no" select="."/>
        <xsl:comment select="'[getSectionPropertyElemBefore] prmElem=',ahf:generateId($prmElem)"/>
        <xsl:variable name="sectInfo" as="xs:integer*" select="map:get($sectMap, ahf:generateId($prmElem))"/>
        <xsl:variable name="prevCol" as="xs:integer?" select="$sectInfo[1]"/>
        <xsl:variable name="currentCol" as="xs:integer?" select="$sectInfo[2]"/>
        <xsl:variable name="nextCol" as="xs:integer?" select="$sectInfo[3]"/>
        <xsl:variable name="break" as="xs:integer?" select="$sectInfo[4]"/>
        <xsl:variable name="content" as="xs:integer?" select="$sectInfo[5]"/>
        <xsl:variable name="colsep" as="xs:integer?" select="$sectInfo[6]"/>
        <xsl:variable name="seq" as="xs:integer?" select="$sectInfo[7]"/>
        <xsl:choose>
            <xsl:when test="exists($sectInfo)">
                <xsl:choose>
                    <xsl:when test="$prmElem/self::*[contains(@class, ' topic/image ')][string(@placement) eq 'break'][ahf:isSpannedImage(.)]">
                        <!-- generate N column section property-->
                        <xsl:variable name="colInfo" as="xs:integer*" select="map:get($columnMap,ahf:generateId($prmElem/ancestor::*[contains(@class,' topic/body ')]))"/>
                        <xsl:variable name="currentCol" as="xs:integer" select="$colInfo[2]"/>
                        <w:p>
                            <w:pPr>
                                <xsl:call-template name="getWmlObjectReplacing">
                                    <xsl:with-param name="prmObjName" select="'wmlSectPr'"/>
                                    <xsl:with-param name="prmSrc" select="('node:hdrFtrReference','%type','node:pgNumType','%col','%sep')"/>
                                    <xsl:with-param name="prmDst" select="($cElemNull,$sectTypeContinuous,$cElemNull,string($currentCol),string($colsep))"/>
                                </xsl:call-template>
                            </w:pPr>
                        </w:p>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:sequence select="()"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <!-- getSectionPropertyElemAfter handles column spanned spanned image and common sect generation opportunity.
         If called at the document end, w:pPr should be directly generated. Otherwise it should wrapped by w:p/w:pPr.
         If it is called at the start of the content, w:hdrreference, w:ftrReference, w:pgNumType should be also generated.
         If it is called from end of the N-column body that have spanned image and has following-sibling related-links, omit w:sectPr generation to remove redundant section break.
     -->
    <xsl:template name="getSectionPropertyElemAfter" as="node()*">
        <xsl:param name="prmElem" as="element()" required="no" select="."/>
        <xsl:param name="prmId" as="xs:string?" required="no" select="()"/>
        <xsl:comment select="'[getSectionPropertyElemAfter] prmElem=',ahf:generateId($prmElem)"/>
        <xsl:variable name="sectInfo" as="xs:integer*" select="map:get($sectMap, if (empty($prmId)) then ahf:generateId($prmElem) else $prmId)"/>
        <xsl:choose>
            <xsl:when test="empty($sectInfo)">
                <xsl:sequence select="()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="prevCol" as="xs:integer" select="$sectInfo[1]"/>
                <xsl:variable name="currentCol" as="xs:integer" select="$sectInfo[2]"/>
                <xsl:variable name="nextCol" as="xs:integer" select="$sectInfo[3]"/>
                <xsl:variable name="break" as="xs:integer" select="$sectInfo[4]"/>
                <xsl:variable name="content" as="xs:integer" select="$sectInfo[5]"/>
                <xsl:variable name="colsep" as="xs:integer?" select="$sectInfo[6]"/>
                <xsl:variable name="seq" as="xs:integer" select="$sectInfo[7]"/>
                <xsl:variable name="isFirst" as="xs:boolean" select="$seq eq 1"/>
                <xsl:variable name="isLast" as="xs:boolean" select="$nextCol eq 0"/>
                <xsl:variable name="sectType" as="xs:string" select="ahf:getSectTypeFromBreakAndPosition($break,$isFirst)"/>
                <xsl:choose>
                    <xsl:when test="$prmElem/self::*[contains(@class, ' topic/image ')][string(@placement) eq 'break'][ahf:isSpannedImage(.)]">
                        <!-- Restore sect info -->
                        <w:p>
                            <w:pPr>
                                <xsl:call-template name="getWmlObjectReplacing">
                                    <xsl:with-param name="prmObjName" select="'wmlSectPr'"/>
                                    <xsl:with-param name="prmSrc" select="('node:hdrFtrReference','%type','node:pgNumType','%col','%sep')"/>
                                    <xsl:with-param name="prmDst" select="($cElemNull,$sectTypeContinuous,$cElemNull,string($currentCol),string($colsep))"/>
                                </xsl:call-template>
                            </w:pPr>
                        </w:p>
                    </xsl:when>
                    <xsl:when test="$prmElem/self::*[contains(@class, ' topic/body ')][$currentCol gt 1][exists(descendant::*[contains(@class, ' topic/image ')][string(@placement) eq 'break'][ahf:isSpannedImage(.)])][exists(following-sibling::*[contains(@class, ' topic/related-links ')][ahf:isEffectiveRelatedLinks(.)])]"/>
                    <xsl:otherwise>
                        <xsl:variable name="hdrFtrReference" as="node()" select="ahf:genHdrFtrReference($isFirst,$content)"/>
                        <xsl:variable name="pgNumType" as="node()" select="ahf:genPgNumType($isFirst,$content)"/>
                        <xsl:choose>
                            <xsl:when test="$isLast">
                                <xsl:call-template name="getWmlObjectReplacing">
                                    <xsl:with-param name="prmObjName" select="'wmlSectPr'"/>
                                    <xsl:with-param name="prmSrc" select="('node:hdrFtrReference','%type','node:pgNumType','%col','%sep')"/>
                                    <xsl:with-param name="prmDst" select="($hdrFtrReference,$sectType,$pgNumType,string($currentCol),string($colsep))"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:otherwise>
                                <w:p>
                                    <w:pPr>
                                        <xsl:call-template name="getWmlObjectReplacing">
                                            <xsl:with-param name="prmObjName" select="'wmlSectPr'"/>
                                            <xsl:with-param name="prmSrc" select="('node:hdrFtrReference','%type','node:pgNumType','%col','%sep')"/>
                                            <xsl:with-param name="prmDst" select="($hdrFtrReference,$sectType,$pgNumType,string($currentCol),string($colsep))"/>
                                        </xsl:call-template>
                                    </w:pPr>
                                </w:p>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- 
     function:	Generate @type attribute of w:sectPr/w:type from break & position information
     param:		  prmBreakInfo, prmIsFirst
     return:	  xs:string
     note:		  0 (auto)   ⇒ continuous
                1 (page)   ⇒ nextPage
                2 (column) ⇒ nextColumn
                If document has cover 1 or 2, the first section must begin with $sectTypeNextPage.
    -->
    <xsl:variable name="sectTypeContinuous" as="xs:string" select="'continuous'"/>
    <xsl:variable name="sectTypeNextPage" as="xs:string" select="'nextPage'"/>
    <xsl:variable name="sectTypeNextColumn" as="xs:string" select="'nextColumn'"/>
    <xsl:variable name="sectTypeEvenPage" as="xs:string" select="'evenPage'"/>
    <xsl:variable name="sectTypeOddPage" as="xs:string" select="'oddPage'"/>
    
    <xsl:function name="ahf:getSectTypeFromBreakAndPosition" as="xs:string">
        <xsl:param name="prmBreakInfo" as="xs:integer"/>
        <xsl:param name="prmIsFirst" as="xs:boolean"/>
        <xsl:choose>
            <xsl:when test="$prmIsFirst and ahf:hasCover12($map)">
                <xsl:sequence select="$sectTypeNextPage"/>
            </xsl:when>
            <xsl:when test="$prmBreakInfo eq $cBreakAuto">
                <xsl:sequence select="$sectTypeContinuous"/>
            </xsl:when>
            <xsl:when test="$prmBreakInfo eq $cBreakPage">
                <xsl:sequence select="$sectTypeNextPage"/>
            </xsl:when>
            <xsl:when test="$prmBreakInfo eq $cBreakColumn">
                <xsl:sequence select="$sectTypeNextColumn"/>
            </xsl:when>
            <xsl:when test="$prmBreakInfo eq $cBreakEven">
                <xsl:sequence select="$sectTypeEvenPage"/>
            </xsl:when>
            <xsl:when test="$prmBreakInfo eq $cBreakOdd">
                <xsl:sequence select="$sectTypeOddPage"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:assert test="false()" select="'[ahf:getSectTypeFromBreak] Invalid break type=',$prmBreakInfo"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <!-- 
     function:	Generate heder/footer reference
     param:		prmIsFirst, prmContent
     return:	document-node or <_null/>
     note:		If first section in the content, it is needed to generate w:headerReference, w:footerReference
    -->
    <xsl:function name="ahf:genHdrFtrReference" as="node()">
        <xsl:param name="prmIsFirst" as="xs:boolean"/>
        <xsl:param name="prmContent" as="xs:integer"/>
        <xsl:choose>
            <xsl:when test="$prmIsFirst">
                <xsl:document>
                    <xsl:call-template name="genHeaderFooterReferenceInSectPr">
                        <xsl:with-param name="prmUsage">
                            <xsl:choose>
                                <xsl:when test="$prmContent eq $cContentFrontmatter">
                                    <xsl:sequence select="$cHeaderFooterUsageFrontmatter"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:sequence select="$cHeaderFooterUsageMain"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:with-param>
                    </xsl:call-template>
                </xsl:document>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="$cElemNull"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!-- 
     function:	Generate w:pgNumType of w:sectPr
     param:		prmIsFirst, prmContent
     return:	document-node() or <_null/>
     note:		If first section in the content, it is needed to set w:pgNumType/@fmt,@start
    -->
    <xsl:function name="ahf:genPgNumType" as="node()">
        <xsl:param name="prmIsFirst" as="xs:boolean"/>
        <xsl:param name="prmContent" as="xs:integer"/>
        <xsl:choose>
            <xsl:when test="$prmIsFirst">
                <xsl:document>
                    <xsl:call-template name="getWmlObject">
                        <xsl:with-param name="prmObjName">
                            <xsl:choose>
                                <xsl:when test="$prmContent eq $cContentFrontmatter">
                                    <xsl:sequence select="'wmlPgNumTypeFrontMatter'"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:sequence select="'wmlPgNumTypeMain'"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:with-param>
                    </xsl:call-template>
                </xsl:document>
            </xsl:when>
            <xsl:otherwise>
                <xsl:document>
                    <xsl:call-template name="getWmlObject">
                        <xsl:with-param name="prmObjName">
                            <xsl:choose>
                                <xsl:when test="$prmContent eq $cContentFrontmatter">
                                    <xsl:sequence select="'wmlPgNumTypeFrontMatterContinue'"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:sequence select="'wmlPgNumTypeMainContinue'"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:with-param>
                    </xsl:call-template>
                </xsl:document>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <!-- 
     function:	Generate column break
     param:		prmTopicRef, prmTopic
     return:	w:p
     note:		Column break is not expressed by section property. But defined here for compatibility.
    -->
    <xsl:template name="getColumnBreak" as="element(w:p)?">
        <xsl:param name="prmTopicRef" as="element()?" required="yes"/>
        <xsl:param name="prmTopic"    as="element()?" required="yes"/>
        <xsl:variable name="isColumnBreak" as="xs:boolean">
            <xsl:choose>
                <xsl:when test="exists($prmTopic)">
                    <xsl:variable name="isNestedTopic" as="xs:boolean" select="exists($prmTopic/ancestor::*[contains(@class,' topic/topic ')])"/>
                    <xsl:choose>
                        <xsl:when test="$isNestedTopic">
                            <xsl:sequence select="ahf:isColumnBreak($prmTopic)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:sequence select="ahf:isColumnBreak($prmTopicRef) or ahf:isColumnBreak($prmTopic)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="ahf:isColumnBreak($prmTopicRef)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:if test="$isColumnBreak">
            <xsl:call-template name="getWmlObject">
                <xsl:with-param name="prmObjName" select="'wmlColumnBreak'"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>

    <!-- end of stylesheet -->
</xsl:stylesheet>