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
URL : http://www.antennahouse.com/
**************************************************************
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" 
    xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
    xmlns:dita-ot="http://dita-ot.sourceforge.net/ns/201007/dita-ot"
    xmlns:graphicUtil="java:com.antennahouse.wml.xsltutil.GraphicUtil"
    extension-element-prefixes="graphicUtil"
    exclude-result-prefixes="xs ahf dita-ot map graphicUtil"
    version="3.0">

    <!-- 
     function:	Block image element processing
     param:		none
     return:	
     note:      handle column break
     -->
    <xsl:template match="*[@class => contains-token('topic/image')][string(@placement) eq 'break'][ancestor::*[@class => ahf:seqContainsToken(('floatfig-d/floatfig','floatfig-d/floatfig-group'))][string(@float) = ('left','right')] => empty()]" priority="20">
        <xsl:call-template name="getSectionPropertyElemBefore"/>
        <xsl:next-match/>
        <xsl:call-template name="getSectionPropertyElemAfter"/>
    </xsl:template>
    
    <!-- 
     function:	Block image element processing
     param:		none
     return:	w:p
     note:      
     -->
    <xsl:template match="*[@class => contains-token('topic/image')][string(@placement) eq 'break']" name="processBlockImage" as="element(w:p)+" priority="5">
        <xsl:param name="prmIndentLevel" tunnel="yes" required="yes" as="xs:integer"/>
        <xsl:param name="prmExtraIndent" tunnel="yes" required="yes" as="xs:integer"/>
        <xsl:param name="prmEndIndent" tunnel="yes" required="no" as="xs:integer" select="0"/>
        <xsl:param name="prmTcAttr" tunnel="yes" as="element()?" select="()"/>
        
        <w:p>
            <w:pPr>
                <xsl:call-template name="getWmlObject">
                    <xsl:with-param name="prmObjName" select="'wmlSingleLineHeight'"/>
                </xsl:call-template>
                <xsl:copy-of select="ahf:getIndentAttrElem(ahf:getIndentFromIndentLevel($prmIndentLevel, $prmExtraIndent),$prmEndIndent,0,0)"/>
                <xsl:copy-of select="ahf:getAlignAttrElem(if (exists(@align)) then @align else $prmTcAttr/@align)"/>
            </w:pPr>
            <xsl:next-match/>
        </w:p>
        <xsl:copy-of select="ahf:genSpaceAfterOnlyP('SpaceAfterForImage')"/>
    </xsl:template>

    <!-- 
     function:	General block image element processing
     param:		none
     return:	w:r
     note:      This template also called form block image processing.
                Adjust the image size to fit the body domain.
     -->
    <xsl:template match="*[@class => contains-token('topic/image')][string(@placement) eq 'break']" name="processBlockImageGenaral" as="element(w:r)?">
        <xsl:variable name="imageSize" as="xs:integer+">
            <xsl:call-template name="ahf:getImageSizeInEmu">
                <xsl:with-param name="prmImage" select="."/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="imageFileName" as="xs:string" select="ahf:substringAfterLast(ahf:bsToSlash(@href),'/')"/>
        <xsl:variable name="isSvg" as="xs:boolean" select="ends-with(lower-case($imageFileName),'.svg')"/>
        <xsl:variable name="imageIdKey" as="xs:string" select="string(@href)"/>
        <xsl:variable name="imageId" as="xs:string" select="xs:string(map:get($imageIdMap,$imageIdKey))"/>
        <xsl:variable name="drawingIdKey" as="xs:string" select="ahf:generateId(.)"/>
        <xsl:variable name="drawingId" as="xs:string" select="xs:string(map:get($drawingIdMap,$drawingIdKey))"/>
        <xsl:variable name="isFloatFigImage" as="xs:boolean" select="exists(self::*[ancestor::*[@class => contains-token('floatfig-d/floatfig')]][following-sibling::*[1][@class => contains-token('topic/image')][string(@placement) eq 'break']])"/>
        <xsl:variable name="vMargin" as="xs:integer">
            <xsl:choose>
                <xsl:when test="$isFloatFigImage">
                    <xsl:variable name="vMarginVal" as="xs:integer">
                        <xsl:call-template name="getVarValueAsInteger">
                            <xsl:with-param name="prmVarName" select="'MultiFloatFigImageVMargin'"/>
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:sequence select="$vMarginVal"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="0"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="($imageSize[1] gt 0) and ($imageSize[2] gt 0)">
                <xsl:variable name="adjustImageSize" as="xs:integer+">
                    <xsl:call-template name="ahf:adjustBlockImageSize">
                        <xsl:with-param name="prmImage" select="."/>
                        <xsl:with-param name="prmImageSize" select="$imageSize"/>
                    </xsl:call-template>
                </xsl:variable>
                <w:r>
                    <xsl:call-template name="getWmlObjectReplacing">
                        <xsl:with-param name="prmObjName" select="if ($isSvg) then 'wmlImageWithHMarginSvg' else 'wmlImageWithHMargin'"/>
                        <xsl:with-param name="prmSrc" select="('%width','%height','%id','%name','%desc','%rid','%v-margin')"/>
                        <xsl:with-param name="prmDst" select="(string($adjustImageSize[1]),string($adjustImageSize[2]),$drawingId,$imageFileName,$imageFileName,concat($rIdPrefix,$imageId),string($vMargin))"/>
                    </xsl:call-template>
                </w:r>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="warningContinue">
                    <xsl:with-param name="prmMes" select="ahf:replace($stMes2020,('%href'),(string(@href)))"/>                    
                </xsl:call-template>
                <xsl:message select="'image-size=',$imageSize"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- 
     function:	Inline image element processing
     param:		none
     return:	w:r
     note:      Call general templates by passing implicit inline image size constraint by EMU size.   
     -->
    <xsl:template match="*[@class => contains-token('topic/image')][string(@placement) eq 'inline']" as="element(w:r)?" priority="5">
        <xsl:next-match>
            <xsl:with-param name="prmInlineImageWidthConstraint" as="xs:integer?">
                <xsl:variable name="inlineImageWidthConstraint" as="xs:integer">
                    <xsl:call-template name="getVarValueAsInteger">
                        <xsl:with-param name="prmVarName" select="'InlineImageWidthConstraint'"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:sequence select="if ($inlineImageWidthConstraint eq 0) then () else $inlineImageWidthConstraint"/>
            </xsl:with-param>
            <xsl:with-param name="prmInlineImageHeightConstraint" as="xs:integer?">
                <xsl:variable name="inlineImageHeightConstraint" as="xs:integer">
                    <xsl:call-template name="getVarValueAsInteger">
                        <xsl:with-param name="prmVarName" select="'InlineImageHeightConstraint'"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:sequence select="if ($inlineImageHeightConstraint eq 0) then () else $inlineImageHeightConstraint"/>
            </xsl:with-param>
        </xsl:next-match>
    </xsl:template>
    
    <!-- 
     function:	Inline image element processing
     param:		$prmInlineImageWidthConstraint, $prmInlineImageHeightConstraint and $prmRunProps 
     return:	w:r
     note:      This template is for inline image only.
     -->
    <xsl:template match="*[@class => contains-token('topic/image')][string(@placement) eq 'inline']"  as="element(w:r)?">
        <xsl:param name="prmInlineImageWidthConstraint" as="xs:integer?" required="yes"/>
        <xsl:param name="prmInlineImageHeightConstraint" as="xs:integer?" required="yes"/>
        <xsl:param name="prmRunProps" tunnel="yes" required="no" as="element()*" select="()"/>
        <xsl:variable name="imageSize" as="xs:integer+">
            <xsl:call-template name="ahf:getImageSizeInEmu">
                <xsl:with-param name="prmImage" select="."/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="imageFileName" as="xs:string" select="ahf:substringAfterLast(ahf:bsToSlash(@href),'/')"/>
        <xsl:variable name="isSvg" as="xs:boolean" select="ends-with(lower-case($imageFileName),'.svg')"/>
        <xsl:variable name="imageIdKey" as="xs:string" select="string(@href)"/>
        <xsl:variable name="imageId" as="xs:string" select="xs:string(map:get($imageIdMap,$imageIdKey))"/>
        <xsl:variable name="drawingIdKey" as="xs:string" select="ahf:generateId(.)"/>
        <xsl:variable name="drawingId" as="xs:string" select="xs:string(map:get($drawingIdMap,$drawingIdKey))"/>
        <xsl:choose>
            <xsl:when test="($imageSize[1] gt 0) and ($imageSize[2] gt 0)">
                <xsl:variable name="adjustImageSize" as="xs:integer+">
                    <xsl:call-template name="ahf:adjustInlineImageSize">
                        <xsl:with-param name="prmImage" select="."/>
                        <xsl:with-param name="prmImageSize" select="$imageSize"/>
                        <xsl:with-param name="prmInlineImageWidthConstraint" select="$prmInlineImageWidthConstraint"/>
                        <xsl:with-param name="prmInlineImageHeightConstraint" select="$prmInlineImageHeightConstraint"/>
                    </xsl:call-template>
                </xsl:variable>
                <w:r>
                    <xsl:variable name="mergedRunProps" as="element()*">
                        <xsl:choose>
                            <xsl:when test="string(@placement) eq 'inline'">
                                <xsl:variable name="inlineImageBaselineShift" as="element()">
                                    <xsl:call-template name="getWmlObject">
                                        <xsl:with-param name="prmObjName" select="'wmlInlineImageBaselineShift'"/>
                                    </xsl:call-template>
                                </xsl:variable>
                                <xsl:copy-of select="ahf:mergeRunProps($prmRunProps,$inlineImageBaselineShift)"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:copy-of select="$prmRunProps"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:if test="exists($mergedRunProps)">
                        <w:rPr>
                            <xsl:copy-of select="$mergedRunProps"/>
                        </w:rPr>
                    </xsl:if>
                    <xsl:call-template name="getWmlObjectReplacing">
                        <xsl:with-param name="prmObjName" select="if ($isSvg) then 'wmlImageSvg' else 'wmlImage'"/>
                        <xsl:with-param name="prmSrc" select="('%width','%height','%id','%name','%desc','%rid')"/>
                        <xsl:with-param name="prmDst" select="(string($adjustImageSize[1]),string($adjustImageSize[2]),$drawingId,$imageFileName,$imageFileName,concat($rIdPrefix,$imageId))"/>
                    </xsl:call-template>
                </w:r>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="warningContinue">
                    <xsl:with-param name="prmMes" select="ahf:replace($stMes2020,('%href'),(string(@href)))"/>                    
                </xsl:call-template>
                <xsl:message select="'image-size=',$imageSize"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- 
     function:	return image size in EMU using DITA-OT generated image size
     param:		prmImage
     return:	image size (width, height) in EMU
     note:		Current DITA-OT only returns PNG image resolution.
                https://github.com/dita-ot/dita-ot/issues/2778
                The return value (0,0) means unsupported image format.
     -->
    <xsl:template name="ahf:getImageSizeInEmu" as="xs:integer+">
        <xsl:param name="prmImage" as="element()" required="yes"/>
        <xsl:variable name="imageInfo" as="item()+">
            <xsl:call-template name="ahf:getImageSizeInfo">
                <xsl:with-param name="prmImage" select="$prmImage"/>
                <xsl:with-param name="prmMapDirUrl" select="xs:anyURI($pMapDirUrl)"/>
            </xsl:call-template>
        </xsl:variable>

        <xsl:variable name="orgImageWidth" as="xs:integer" select="xs:integer($imageInfo[1])"/>
        <xsl:variable name="orgImageHeight" as="xs:integer" select="xs:integer($imageInfo[2])"/>
        <xsl:variable name="horizontalDpi" as="xs:integer" select="xs:integer($imageInfo[3])"/>
        <xsl:variable name="verticalDpi" as="xs:integer" select="xs:integer($imageInfo[4])"/>
        <xsl:variable name="scale" as="xs:double" select="xs:double($imageInfo[5])"/>
        
        <xsl:choose>
            <xsl:when test="($orgImageWidth eq 0) or ($orgImageHeight eq 0)">
                <xsl:sequence select="(0, 0)"/>
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
     function:	return image size information:
                Width and height in pixel, both dimension resolution, scale
     param:		prmImage image element
                prmMapDirUrl base map directory
     return:	image size information (width, height in pixel, resolution of both axes, scale)
     note:		Call lib/xstutil.jar for getting EMF information because it is not supported in Java.
     -->
    <xsl:template name="ahf:getImageSizeInfo" as="item()+">
        <xsl:param name="prmImage" as="element()" required="yes"/>
        <xsl:param name="prmMapDirUrl" as="xs:anyURI" required="yes"/>
        <xsl:variable name="href" as="xs:string" select="string($prmImage/@href)"/>
        <xsl:variable name="defaultDpi" as="xs:integer">
            <xsl:call-template name="getVarValueAsInteger">
                <xsl:with-param name="prmVarName" select="'Default_Image_Dpi'"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="horizontalDpi" as="xs:integer" select="if (string($prmImage/@dita-ot:horizontal-dpi) castable as xs:integer) then xs:integer($prmImage/@dita-ot:horizontal-dpi) else $defaultDpi"/>
        <xsl:variable name="verticalDpi" as="xs:integer" select="if (string($prmImage/@dita-ot:vertical-dpi) castable as xs:integer) then xs:integer($prmImage/@dita-ot:vertical-dpi) else $defaultDpi"/>
        <xsl:variable name="orgImageWidth" as="xs:integer">
            <xsl:variable name="imageWidth" as="xs:string" select="string($prmImage/@dita-ot:image-width)"/>
            <xsl:choose>
                <xsl:when test="$imageWidth castable as xs:integer">
                    <xsl:sequence select="xs:integer($imageWidth)"/>
                </xsl:when>
                <xsl:when test="$imageWidth castable as xs:double">
                    <xsl:sequence select="xs:integer(round(xs:double($imageWidth)))"/>
                </xsl:when>
                <xsl:when test="ahf:isUnitValue($imageWidth)">
                    <xsl:sequence select="xs:integer(round(xs:double(ahf:toIn($imageWidth) * $horizontalDpi)))"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="0"/>
                </xsl:otherwise>
            </xsl:choose>            
        </xsl:variable>
        <xsl:variable name="orgImageHeight" as="xs:integer">
            <xsl:variable name="imageHeight" as="xs:string" select="string($prmImage/@dita-ot:image-height)"/>
            <xsl:choose>
                <xsl:when test="$imageHeight castable as xs:integer">
                    <xsl:sequence select="xs:integer($imageHeight)"/>
                </xsl:when>
                <xsl:when test="$imageHeight castable as xs:double">
                    <xsl:sequence select="xs:integer(round(xs:double($imageHeight)))"/>
                </xsl:when>
                <xsl:when test="ahf:isUnitValue($imageHeight)">
                    <xsl:sequence select="xs:integer(round(xs:double(ahf:toIn($imageHeight) * $verticalDpi)))"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="0"/>
                </xsl:otherwise>
            </xsl:choose>            
        </xsl:variable>
        <xsl:variable name="scale" as="xs:double" select="if (string($prmImage/@scale)) then (xs:integer($prmImage/@scale) div 100) else 1"/>
        
        <xsl:choose>
            <xsl:when test="($orgImageWidth gt 0) and ($orgImageHeight gt 0)">
                <xsl:sequence select="($orgImageWidth,$orgImageHeight,$horizontalDpi,$verticalDpi,$scale)"/>
            </xsl:when>
            <xsl:when test="ends-with(lower-case($href),'.emf')">
                <xsl:variable name="url" as="xs:anyURI" select="ahf:getUriFromHref($href,xs:anyURI($pMapDirUrl))"/>
                <!--xsl:message select="'$href=',$href,'$pMapDirUrl=',$pMapDirUrl,'$url=',$url"></xsl:message-->
                <xsl:variable name="emfInfo" as="xs:string" select="graphicUtil:getImageSizeByUri($url)"/>
                <xsl:variable name="emfInfoSeq" as="item()+" select="tokenize($emfInfo)"/>
                <xsl:sequence select="($emfInfoSeq[1],$emfInfoSeq[2],$emfInfoSeq[3],$emfInfoSeq[4],$scale)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="(0,0,$horizontalDpi,$verticalDpi,$scale)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- 
     function:	Make URL from href
     param:		prmHref : @href value
                prmBase : Base URL
     return:	xs:string
     note:		
     -->
    <xsl:function name="ahf:getUriFromHref" as="xs:anyURI">
        <xsl:param name="prmHref" as="xs:string"/>
        <xsl:param name="prmBaseUrl" as="xs:anyURI"/>
        <xsl:variable name="hrefRevised" as="xs:string" select="translate($prmHref,'\','/')"/>
        <xsl:choose>
            <xsl:when test="starts-with($prmHref,'/')">
                <xsl:sequence select="xs:anyURI(concat('file:/',$hrefRevised))"/>
            </xsl:when>
            <xsl:when test="matches($hrefRevised,'^[a-zA-Z]{1}:/')">
                <xsl:sequence select="xs:anyURI(concat('file:/',$hrefRevised))"/>
            </xsl:when>
            <xsl:when test="matches($hrefRevised,'^(\S+)://([^:/]+)(:(\d+))?(/[^#\s]*)(#(\S+))?')">
                <xsl:sequence select="xs:anyURI($hrefRevised)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="xs:anyURI(concat($prmBaseUrl,$hrefRevised))"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <!-- 
     function:	adjust block image size considering the body text domain width
     param:		prmImage,prmImageSize,prmIndentLevel,prmExtraIndent,prmWidthConstraintInEmu 
     return:	image size (width, height) in EMU
     note:		references tunnel parameter $prmIndentLevel, $prmExtraIndent
                If the image is in a table cell, we cannot do anything because column width is hard to know.
                If the image is in floatfig $prmWidthConstraintInEmu is passed not to over the text box size.
                The body width is calculated via bodyWidth/column - gap * (column - 1)/column
     -->
    <xsl:template name="ahf:adjustBlockImageSize" as="xs:integer+">
        <xsl:param name="prmImage" required="yes" as="element()"/>
        <xsl:param name="prmImageSize" required="yes" as="xs:integer+" />
        <xsl:param name="prmIndentLevel" tunnel="yes" required="yes" as="xs:integer"/>
        <xsl:param name="prmExtraIndent" tunnel="yes" required="yes" as="xs:integer"/>
        <xsl:param name="prmWidthConstraintInEmu" tunnel="yes" required="no" as="xs:integer?" select="()"/>
        <xsl:variable name="bodyWidth" as="xs:integer">
            <xsl:choose>
                <xsl:when test="exists($prmWidthConstraintInEmu)">
                    <xsl:sequence select="$prmWidthConstraintInEmu"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:variable name="columnCount" as="xs:integer">
                        <xsl:variable name="bodyOrTopic" as="element()" select="if (exists($prmImage/ancestor::*[@class => contains-token('topic/body')])) then $prmImage/ancestor::*[@class => contains-token('topic/body')] else $prmImage/ancestor::*[@class => contains-token('topic/topic')][1]"/>
                        <xsl:choose>
                            <xsl:when test="ahf:isSpannedImage($prmImage)">
                                <xsl:sequence select="1"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:variable name="columnInfo" as="item()*" select="map:get($columnMap,ahf:generateId($bodyOrTopic))"/>
                                <xsl:choose>
                                    <xsl:when test="exists($columnInfo)">
                                        <xsl:sequence select="xs:integer($columnInfo[2])"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:sequence select="1"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <!--xsl:message select="'$columnCount=',$columnCount,'$pPaperColumnGap=',$pPaperColumnGap"/-->
                    <xsl:choose>
                        <xsl:when test="$columnCount eq 1">
                            <xsl:sequence select="ahf:toEmu($pPaperBodyWidth)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:sequence select="ahf:toEmu($pPaperBodyWidth) div $columnCount - ahf:toEmu($pPaperColumnGap) * ($columnCount - 1) div $columnCount"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="inheritedIndentSize" as="xs:integer" select="ahf:getIndentFromIndentLevelInEmu($prmIndentLevel,$prmExtraIndent)"/>
        <xsl:variable name="remainBodyWidth" as="xs:integer" select="$bodyWidth - $inheritedIndentSize"/>
        <!--xsl:message select="'$pPaperBodyWidth=',$pPaperBodyWidth,' $inheritedIndentSize=',$inheritedIndentSize,' $remainBodySize=',$remainBodyWidth"/-->
        <xsl:choose>
            <xsl:when test="$prmImageSize[1] gt $remainBodyWidth">
                <!--xsl:message select="'result=',($remainBodyWidth, xs:integer($prmImageSize[2] * $remainBodyWidth div $prmImageSize[1]))"/-->
                <xsl:sequence select="($remainBodyWidth, xs:integer($prmImageSize[2] * $remainBodyWidth div $prmImageSize[1]))"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="$prmImageSize"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- 
     function:	adjust inline image size considering the constraint width & height
     param:		$prmImage, $prmImageSize, prmInlineImageWidthConstraint and $prmInlineImageHeightConstraint (one of two is empty)
                All of the image size is EMU unit
     return:	image size (width, height) in EMU
     note:		
     -->
    <xsl:template name="ahf:adjustInlineImageSize" as="xs:integer+">
        <xsl:param name="prmImage" required="yes" as="element()"/>
        <xsl:param name="prmImageSize" required="yes" as="xs:integer+" />
        <xsl:param name="prmInlineImageWidthConstraint" as="xs:integer?" required="yes"/>
        <xsl:param name="prmInlineImageHeightConstraint" as="xs:integer?" required="yes"/>
        <xsl:variable name="imageWidth" as="xs:integer" select="$prmImageSize[1]"/>
        <xsl:variable name="imageHeight" as="xs:integer" select="$prmImageSize[2]"/>
        <xsl:variable name="resultImageSize" as="xs:integer+">
            <xsl:choose>
                <xsl:when test="exists($prmInlineImageHeightConstraint)">
                    <xsl:choose>
                        <xsl:when test="$imageHeight gt $prmInlineImageHeightConstraint">
                            <xsl:sequence select="(xs:integer(round($imageWidth * $prmInlineImageHeightConstraint div $imageHeight)),$prmInlineImageHeightConstraint)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:sequence select="($imageWidth,$imageHeight)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:choose>
                        <xsl:when test="$imageWidth gt $prmInlineImageWidthConstraint">
                            <xsl:sequence select="($prmInlineImageWidthConstraint,xs:integer(round($imageHeight * $prmInlineImageWidthConstraint div $imageWidth)))"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:sequence select="($imageWidth,$imageHeight)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:sequence select="$resultImageSize"/>
    </xsl:template>

    <!-- END OF STYLESHEET -->

</xsl:stylesheet>