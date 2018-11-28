<?xml version="1.0" encoding="UTF-8" ?>
<!--
**************************************************************
DITA to WordprocessingML Stylesheet
Utility Templates
**************************************************************
File Name : dita2wml_util_fo.xsl
**************************************************************
Copyright © 2009-2018 Antenna House, Inc. All rights reserved.
Antenna House is a trademark of Antenna House, Inc.
URL : http://www.antennahouse.com/
**************************************************************
-->

<xsl:stylesheet version="3.0" 
	xmlns:fo="http://www.w3.org/1999/XSL/Format" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
 	xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
 	xmlns:ahd="http://www.antennahouse.com/names/XSLT/Debugging"
 	exclude-result-prefixes="xs ahf" >

    <!--
    ===============================================
     DITA XSL-FO Propert Utility Templates
    ===============================================
    -->
    
    <!-- 
         function:	Expand FO property into attribute()*
         param:		prmFoProp, prmElem
         return:	Attribute node
         note:		XSL-FO attribute is authored in $prmFoProp in CSS notation.
    -->
    <xsl:function name="ahf:getFoProperty" as="attribute()*">
        <xsl:param name="prmFoProp" as="xs:string"/>
        <xsl:param name="prmElem" as="element()"/>
        <xsl:variable name="foAttr" as="xs:string" select="normalize-space(string($prmFoProp))"/>
        <xsl:for-each select="tokenize($foAttr, ';')">
            <xsl:variable name="propDesc" select="normalize-space(string(.))"/>
            <xsl:choose>
                <xsl:when test="not(string($propDesc))"/>
                <xsl:when test="contains($propDesc,':')">
                    <xsl:variable name="propName" as="xs:string">
                        <xsl:variable name="tempPropName" as="xs:string" select="normalize-space(substring-before($propDesc,':'))"/>
                        <xsl:variable name="axfExt" as="xs:string" select="'axf-'"/>
                        <xsl:variable name="ahsExt" as="xs:string" select="'ahs-'"/>
                        <xsl:choose>
                            <xsl:when test="starts-with($tempPropName,$axfExt)">
                                <xsl:sequence select="concat('axf:',substring-after($tempPropName,$axfExt))"/>
                            </xsl:when>
                            <xsl:when test="starts-with($tempPropName,$ahsExt)">
                                <xsl:sequence select="''"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:sequence select="$tempPropName"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>                            
                    <xsl:variable name="propValue" as="xs:string" select="normalize-space(substring-after($propDesc,':'))"/>
                    <xsl:choose>
                        <xsl:when test="not(string($propName))"/>
                        <!--"castable as xs:NAME" can be used only in Saxon PE or EE.
                            If $propName does not satisfy above, xsl:attribute instruction will be faild!
                            2014-04-22 t.makita
                            This restriction has removed because this stylesheet is compiled with Saxon PE/EE.
                            2018-11-28 t.makita
                         -->
                        <xsl:when test="$propName castable as xs:Name">
                            <xsl:attribute name="{$propName}" select="$propValue"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="warningContinue">
                                <xsl:with-param name="prmMes" select="ahf:replace($stMes802,('%propName','%xtrc','%xtrf'),($propName,string($prmElem/@xtrc),string($prmElem/@xtrf)))"/>
                            </xsl:call-template>
                        </xsl:otherwise>
                    </xsl:choose>                            
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="warningContinue">
                        <xsl:with-param name="prmMes" select="ahf:replace($stMes800,('%foAttr','%xtrc','%xtrf'),($foAttr,string($prmElem/@xtrc),string($prmElem/@xtrf)))"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:function>
    
    <!-- 
         function:	Expand FO property into attribute()*
                    Replacing text() with given parameters ($prmSrc, $prmDst).
         param:		prmFoProp,$prmSrc,$prmDst
         return:	Attribute node
         note:		XSL-FO attribute is authored in $prmElem/@fo:prop in CSS notation.
                    2014-04-22 t.makita
    -->
    <xsl:function name="ahf:getFoPropertyReplacing" as="attribute()*">
        <xsl:param name="prmFoProp" as="xs:string"/>
        <xsl:param name="prmElem" as="element()"/>
        <xsl:param name="prmSrc" as="xs:string+"/>
        <xsl:param name="prmDst" as="xs:string+"/>
        
        <xsl:variable name="foAttr" as="xs:string" select="normalize-space(string($prmFoProp))"/>
        <xsl:for-each select="tokenize($foAttr, ';')">
            <xsl:variable name="propDesc" select="normalize-space(string(.))"/>
            <xsl:choose>
                <xsl:when test="not(string($propDesc))"/>
                <xsl:when test="contains($propDesc,':')">
                    <xsl:variable name="propName" as="xs:string">
                        <xsl:variable name="tempPropName" as="xs:string" select="normalize-space(substring-before($propDesc,':'))"/>
                        <xsl:variable name="axfExt" as="xs:string" select="'axf-'"/>
                        <xsl:choose>
                            <xsl:when test="starts-with($tempPropName,$axfExt)">
                                <xsl:sequence select="concat('axf:',substring-after($tempPropName,$axfExt))"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:sequence select="$tempPropName"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>                            
                    <xsl:variable name="propValue" as="xs:string" select="normalize-space(substring-after($propDesc,':'))"/>
                    <xsl:choose>
                        <!--"castable as xs:NAME" can be used only in Saxon PE or EE.
                            If $propName does not satisfy above, xsl:attribute instruction will be faild!
                            2014-04-22 t.makita
                         -->
                        <!--xsl:when test="$propName castable as xs:NAME"-->
                        <xsl:when test="true()">
                            <xsl:variable name="propReplaceResult" as="xs:string" select="ahf:replace($propValue,$prmSrc,$prmDst)"/>
                            <xsl:attribute name="{$propName}" select="$propReplaceResult"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="warningContinue">
                                <xsl:with-param name="prmMes" select="ahf:replace($stMes806,('%propName','%xtrc','%xtrf'),($propName,string($prmElem/@xtrc),string($prmElem/@xtrf)))"/>
                            </xsl:call-template>
                        </xsl:otherwise>
                    </xsl:choose>                            
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="warningContinue">
                        <xsl:with-param name="prmMes" select="ahf:replace($stMes804,('%foAttr','%xtrc','%xtrf'),($foAttr,string($prmElem/@xtrc),string($prmElem/@xtrf)))"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:function>
    
    <!-- 
         function:	Expand FO property into attribute()*
                    Replacing text() with given page related parameters.
                    %paper-width is replaced with $pPaperWidth
                    %paper-height is replaced with $pPaperHeight
         param:		prmElem
         return:	Attribute node
         note:		Used for making cover page：page size (width,height), cop size (horizontal,vertical), bleed size are replaced by actual value and returned as attribute()*.
                    This function refers global variable $pPaperWidth,$pPaperHeight.（dita2fo_param_papersize.xsl)
                    Authoring "0.5 * %paper-width" will get half width of page size.
    -->
    <xsl:function name="ahf:getFoPropertyWithPageVariables" as="attribute()*">
        <xsl:param name="prmFoProp" as="xs:string"/>
        <xsl:param name="prmElem" as="element()"/>
        <xsl:sequence select="ahf:getFoPropertyReplacing(
            $prmFoProp,
            $prmElem,
            ('%paper-width','%paper-height'),
            ($pPaperWidth,$pPaperHeight))"/>
    </xsl:function>
    
    <!-- end of stylesheet -->
</xsl:stylesheet>
