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
    <!-- getSectionPropertyElemBefore only handles column spanned spanned image
     -->
    <xsl:template name="getSectionPropertyElemBefore" as="node()*">
        <xsl:param name="prmElem" as="element()" required="no" select="."/>
        <xsl:param name="prmTopicRef" as="element()" tunnel="yes" required="yes"/>
        <xsl:comment select="'[getSectionPropertyElemBefore] prmElem=',ahf:generateId($prmElem)"/>
        <xsl:variable name="isPointedFromTopicRef" as="xs:boolean" select="ahf:isPointedFromTopicref($prmElem,$prmTopicRef)"/>
        <xsl:variable name="isSameTopicRef" as="xs:boolean" select="$prmTopicRef is $prmElem"/>
        <xsl:variable name="sectInfo" as="xs:integer*" select="map:get($sectMap, ahf:generateId($prmElem))"/>
        <xsl:variable name="prevCol" as="xs:integer?" select="$sectInfo[1]"/>
        <xsl:variable name="currentCol" as="xs:integer?" select="$sectInfo[2]"/>
        <xsl:variable name="nextCol" as="xs:integer?" select="$sectInfo[3]"/>
        <xsl:variable name="break" as="xs:integer?" select="$sectInfo[4]"/>
        <xsl:variable name="content" as="xs:integer?" select="$sectInfo[5]"/>
        <xsl:variable name="seq" as="xs:integer?" select="$sectInfo[6]"/>
        <xsl:choose>
            <xsl:when test="exists($sectInfo)">
                <xsl:choose>
                    <xsl:when test="$prmElem/self::*[contains(@class, ' topic/image ')][string(@placement) eq 'break'][ahf:isSpannedImage(.)]">
                        <!-- generate 1 column section property-->
                        <w:p>
                            <w:pPr>
                                <xsl:call-template name="getWmlObjectReplacing">
                                    <xsl:with-param name="prmObjName" select="'wmlSectPr'"/>
                                    <xsl:with-param name="prmSrc" select="('node:hdrFtrReference','%type','node:pgNumType','%col')"/>
                                    <xsl:with-param name="prmDst" select="($cElemNull,$sectTypeContinuous,$cElemNull,'1')"/>
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
                <xsl:variable name="seq" as="xs:integer" select="$sectInfo[6]"/>
                <xsl:variable name="sectType" as="xs:string" select="ahf:getSectTypeFromBreak($break)"/>
                <xsl:choose>
                    <xsl:when test="$prmElem/self::*[contains(@class, ' topic/image ')][string(@placement) eq 'break'][ahf:isSpannedImage(.)]">
                        <!-- Restore sect info -->
                        <w:p>
                            <w:pPr>
                                <xsl:call-template name="getWmlObjectReplacing">
                                    <xsl:with-param name="prmObjName" select="'wmlSectPr'"/>
                                    <xsl:with-param name="prmSrc" select="('node:hdrFtrReference','%type','node:pgNumType','%col')"/>
                                    <xsl:with-param name="prmDst" select="($cElemNull,$sectTypeContinuous,$cElemNull,string($currentCol))"/>
                                </xsl:call-template>
                            </w:pPr>
                        </w:p>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:variable name="isFirst" as="xs:boolean" select="$seq eq 1"/>
                        <xsl:variable name="isLast" as="xs:boolean" select="$nextCol eq 0"/>
                        <xsl:variable name="hdrFtrReference" as="element()+" select="ahf:genHdrFtrReference($isFirst,$content)"/>
                        <xsl:variable name="pgNumType" as="element()" select="ahf:genPgNumType($isFirst,$content)"/>
                        <xsl:choose>
                            <xsl:when test="$isLast">
                                <xsl:call-template name="getWmlObjectReplacing">
                                    <xsl:with-param name="prmObjName" select="'wmlSectPr'"/>
                                    <xsl:with-param name="prmSrc" select="('node:hdrFtrReference','%type','node:pgNumType','%col')"/>
                                    <xsl:with-param name="prmDst" select="($hdrFtrReference,$sectTypeContinuous,$pgNumType,string($currentCol))"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:otherwise>
                                <w:p>
                                    <w:pPr>
                                        <xsl:call-template name="getWmlObjectReplacing">
                                            <xsl:with-param name="prmObjName" select="'wmlSectPr'"/>
                                            <xsl:with-param name="prmSrc" select="('node:hdrFtrReference','%type','node:pgNumType','%col')"/>
                                            <xsl:with-param name="prmDst" select="($hdrFtrReference,$sectTypeContinuous,$pgNumType,string($currentCol))"/>
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
     function:	Generate @type attribute of w:sectPr/w:type from break information
     param:		  prmBreakInfo
     return:	  xs:string
     note:		  0 (auto)   ⇒ continuous
                1 (page)   ⇒ nextPage
                2 (column) ⇒ nextColumn
    -->
    <xsl:variable name="sectTypeContinuous" as="xs:string" select="'continuous'"/>
    <xsl:variable name="sectTypeNextPageBreak" as="xs:string" select="'nextPage'"/>
    <xsl:variable name="sectTypeNextColumnBreak" as="xs:string" select="'nextColumn'"/>
    
    <xsl:function name="ahf:getSectTypeFromBreak" as="xs:string">
        <xsl:param name="prmBreakInfo" as="xs:integer"/>
        <xsl:choose>
            <xsl:when test="$prmBreakInfo eq $cBreakAuto">
                <xsl:sequence select="$sectTypeContinuous"/>
            </xsl:when>
            <xsl:when test="$prmBreakInfo eq $cBreakPage">
                <xsl:sequence select="$sectTypeNextPageBreak"/>
            </xsl:when>
            <xsl:when test="$prmBreakInfo eq $cBreakColumn">
                <xsl:sequence select="$sectTypeNextColumnBreak"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:assert test="false()" select="'[ahf:getSectTypeFromBreak] Invalid break type=',$prmBreakInfo"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <!-- 
     function:	Generate heder/footer reference
     param:		prmIsFirst, prmContent
     return:	element()+
     note:		If first section in the content, it is needed to generate w:headerReference, w:footerReference
    -->
    <xsl:function name="ahf:genHdrFtrReference" as="element()+">
        <xsl:param name="prmIsFirst" as="xs:boolean"/>
        <xsl:param name="prmContent" as="xs:integer"/>
        <xsl:choose>
            <xsl:when test="$prmIsFirst">
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
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="$cElemNull"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!-- 
     function:	Generate w:pgNumType of w:sectPr
     param:		prmIsFirst, prmContent
     return:	element()
     note:		If first section in the content, it is needed to set w:pgNumType/@fmt,@start
    -->
    <xsl:function name="ahf:genPgNumType" as="element()">
        <xsl:param name="prmIsFirst" as="xs:boolean"/>
        <xsl:param name="prmContent" as="xs:integer"/>
        <xsl:choose>
            <xsl:when test="$prmIsFirst">
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
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="$cElemNull"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <!-- end of stylesheet -->
</xsl:stylesheet>