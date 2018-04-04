<?xml version="1.0" encoding="UTF-8"?>
<!--
**************************************************************
DITA to WordprocessingML Stylesheet
Document.xml image element Templates
**************************************************************
File Name : dita2wml_document_image.xsl
**************************************************************
Copyright © 2009-2017 Antenna House, Inc. All rights reserved.
Antenna House is a trademark of Antenna House, Inc.
URL : http://www.antennahouse.co.jp/
**************************************************************
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" 
    xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
    xmlns:dita-ot="http://dita-ot.sourceforge.net/ns/201007/dita-ot"
    exclude-result-prefixes="xs ahf dita-ot map"
    version="3.0">

    <!-- 
     function:	Inline image element processing
     param:		none
     return:	w:r
     note:      This template also called form block image processing.
                If it is block level image, adjust the image size to fit the body domain.
     -->
    <xsl:template match="*[contains(@class,' topic/image ')]" name="processImageInline" as="element(w:r)?">
        <xsl:param name="prmRunProps" tunnel="yes" required="no" as="element()*" select="()"/>
        <xsl:variable name="imageSize" as="xs:integer+">
            <xsl:call-template name="ahf:getImageSizeInEmu">
                <xsl:with-param name="prmImage" select="."/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="imageFileName" as="xs:string" select="ahf:substringAfterLast(ahf:bsToSlash(@href),'/')"/>
        <xsl:variable name="imageIdKey" as="xs:string" select="string(@href)"/>
        <xsl:variable name="imageId" as="xs:string" select="xs:string(map:get($imageIdMap,$imageIdKey))"/>
        <xsl:variable name="shapeIdKey" as="xs:string" select="ahf:generateId(.)"/>
        <xsl:variable name="shapeId" as="xs:string" select="xs:string(map:get($shapeIdMap,$shapeIdKey))"/>
        <xsl:choose>
            <xsl:when test="($imageSize[1] gt 0) and ($imageSize[2] gt 0)">
                <xsl:variable name="adjustedImageSize" as="xs:integer+">
                    <xsl:choose>
                        <xsl:when test="string(@placement) eq 'break'">
                            <xsl:call-template name="ahf:adjustImageSize">
                                <xsl:with-param name="prmImage" select="."/>
                                <xsl:with-param name="prmImageSize" select="$imageSize"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:sequence select="$imageSize"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <w:r>
                    <xsl:if test="exists($prmRunProps)">
                        <w:rPr>
                            <xsl:copy-of select="$prmRunProps"/>
                        </w:rPr>
                    </xsl:if>
                    <xsl:call-template name="getWmlObjectReplacing">
                        <xsl:with-param name="prmObjName" select="'wmlImage'"/>
                        <xsl:with-param name="prmSrc" select="('%width','%height','%id','%name','%desc','%rid')"/>
                        <xsl:with-param name="prmDst" select="(string($imageSize[1]),string($imageSize[2]),$shapeId,$imageFileName,$imageFileName,concat($rIdPrefix,$imageId))"/>
                    </xsl:call-template>
                </w:r>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="warningContinue">
                    <xsl:with-param name="prmMes" select="ahf:replace($stMes2020,('%href'),(string(@href)))"/>                    
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- 
     function:	retrun image size in EMU using DITA-OT generated image size
     param:		prmImage
     return:	image size (width, height) in EMU
     note:		Current DITA-OT only returns PNG image resolution.
                https://github.com/dita-ot/dita-ot/issues/2778
                The return value (0,0) means unsupported image format.
     -->
    <xsl:template name="ahf:getImageSizeInEmu" as="xs:integer+">
        <xsl:param name="prmImage" as="element()" required="yes"/>
        <xsl:variable name="defaultDpi" as="xs:integer">
            <xsl:call-template name="getVarValueAsInteger">
                <xsl:with-param name="prmVarName" select="'Default_Image_Dpi'"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="orgImageWidth" as="xs:integer" select="if (string($prmImage/@dita-ot:image-width) castable as xs:integer) then xs:integer($prmImage/@dita-ot:image-width) else 0"/>
        <xsl:variable name="orgImageHeight" as="xs:integer" select="if (string($prmImage/@dita-ot:image-height) castable as xs:integer) then xs:integer($prmImage/@dita-ot:image-height) else 0"/>
        <xsl:variable name="horizontalDpi" as="xs:integer" select="if (string($prmImage/@dita-ot:horizontal-dpi) castable as xs:integer) then xs:integer($prmImage/@dita-ot:horizontal-dpi) else $defaultDpi"/>
        <xsl:variable name="verticalDpi" as="xs:integer" select="if (string($prmImage/@dita-ot:vertical-dpi) castable as xs:integer) then xs:integer($prmImage/@dita-ot:vertical-dpi) else $defaultDpi"/>
        <xsl:variable name="scale" as="xs:double" select="if (string($prmImage/@scale)) then (xs:integer($prmImage/@scale) div 100) else 1"/>
        
        <xsl:choose>
            <xsl:when test="($orgImageWidth eq 0) or ($orgImageHeight eq 0)">
                <xsl:sequence select="(0,0)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="fpRegExp" as="xs:string" select="'^([\d]+?\.{1}?[\d]+?|[\d]+?)$'"/>
                <xsl:variable name="attImageWidthEmu" as="xs:integer?">
                    <xsl:variable name="attWidth" as="xs:string?" select="$prmImage/@width"/>
                    <xsl:choose>
                        <xsl:when test="exists($attWidth)">
                            <xsl:variable name="unit" select="if (matches($attWidth,$fpRegExp)) then 'px' else ''"/>
                            <xsl:sequence select="ahf:toEmu(concat($attWidth,$unit))"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:sequence select="()"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="attImageHeightEmu" as="xs:integer?">
                    <xsl:variable name="attHeight" as="xs:string?" select="$prmImage/@height"/>
                    <xsl:choose>
                        <xsl:when test="exists($attHeight)">
                            <xsl:variable name="unit" select="if (matches($attHeight,$fpRegExp)) then 'px' else ''"/>
                            <xsl:sequence select="ahf:toEmu(concat($attHeight,$unit))"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:sequence select="()"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:choose>
                    <xsl:when test="empty(($attImageWidthEmu,$attImageHeightEmu))">
                        <!-- @width, @height are not specified -->
                        <xsl:variable name="imageWidthEmu" as="xs:integer" select="xs:integer($orgImageWidth div $horizontalDpi * $cEmuPerIn * $scale)"/>
                        <xsl:variable name="imageHeightEmu" as="xs:integer" select="xs:integer($orgImageHeight div $verticalDpi * $cEmuPerIn * $scale)"/>
                        <xsl:sequence select="($imageWidthEmu,$imageHeightEmu)"/>
                    </xsl:when>
                    <xsl:when test="count(($attImageWidthEmu,$attImageHeightEmu)) eq 2">
                        <!-- Both @width, @height are specified -->
                        <xsl:sequence select="($attImageWidthEmu,$attImageHeightEmu)"/>
                    </xsl:when>
                    <xsl:when test="empty($attImageWidthEmu) and exists($attImageHeightEmu)">
                        <xsl:variable name="orgImageWidthEmu" as="xs:integer" select="xs:integer($orgImageWidth div $horizontalDpi * $cEmuPerIn)"/>
                        <xsl:variable name="orgImageHeightEmu" as="xs:integer" select="xs:integer($orgImageHeight div $verticalDpi * $cEmuPerIn)"/>
                        <xsl:variable name="ratio" as="xs:double" select="$attImageHeightEmu div $orgImageHeightEmu"/>
                        <xsl:variable name="imageWidthEmu" as="xs:integer" select="xs:integer($orgImageWidthEmu * $ratio)"/>
                        <xsl:sequence select="($imageWidthEmu,$attImageHeightEmu)"/>
                    </xsl:when>
                    <xsl:when test="exists($attImageWidthEmu) and empty($attImageHeightEmu)">
                        <xsl:variable name="orgImageWidthEmu" as="xs:integer" select="xs:integer($orgImageWidth div $horizontalDpi * $cEmuPerIn)"/>
                        <xsl:variable name="orgImageHeightEmu" as="xs:integer" select="xs:integer($orgImageHeight div $verticalDpi * $cEmuPerIn)"/>
                        <xsl:variable name="ratio" as="xs:double" select="$attImageWidthEmu div $orgImageWidthEmu"/>
                        <xsl:variable name="imageHeightEmu" as="xs:integer" select="xs:integer($orgImageHeightEmu * $ratio)"/>
                        <xsl:sequence select="($attImageWidthEmu,$imageHeightEmu)"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- 
     function:	adjust a image size considering the body text domain width
     param:		prmImageSize, 
     return:	image size (width, height) in EMU
     note:		references tunnel parameter $prmIndentLevel, $prmExtraIndent
     -->
    <xsl:template name="ahf:adjustImageSize" as="xs:integer+">
        <xsl:param name="prmImage" required="yes" as="element()"/>
        <xsl:param name="prmImageSize" required="yes" as="xs:integer+" />
        <xsl:param name="prmIndentLevel" tunnel="yes" required="yes" as="xs:integer"/>
        <xsl:param name="prmExtraIndent" tunnel="yes" required="yes" as="xs:integer"/>
        <xsl:variable name="isInTableCell" as="xs:boolean" select="exists($prmImage/ancestor::*[ahf:seqContains(@class,(' topic/entry ',' topic/stentry '))])"/>
    </xsl:template>



    <!-- 
     function:	Block image element processing
     param:		none
     return:	w:p
     note:      
     -->
    <xsl:template match="*[contains(@class,' topic/image ')][string(@placement) eq 'break']" name="processBlockImage" as="element(w:p)" priority="5">
        <xsl:param name="prmIndentLevel" tunnel="yes" required="yes" as="xs:integer"/>
        <xsl:param name="prmExtraIndent" tunnel="yes" required="yes" as="xs:integer"/>
        <xsl:param name="prmTcAttr" tunnel="yes" as="element()?" select="()"/>
        
        <w:p>
            <xsl:variable name="pPr" as="element()*">
                <xsl:sequence select="ahf:getIndentAttrElem($prmIndentLevel,$prmExtraIndent)"/>
                <xsl:sequence select="ahf:getAlignAttrElem(if (exists(@align)) then @align else $prmTcAttr/@align)"/>
            </xsl:variable>
            <xsl:if test="exists($pPr)">
                <w:pPr>
                    <xsl:copy-of select="$pPr"/>
                </w:pPr>
            </xsl:if>
            <xsl:next-match/>
        </w:p>
    </xsl:template>

    <!-- END OF STYLESHEET -->

</xsl:stylesheet>