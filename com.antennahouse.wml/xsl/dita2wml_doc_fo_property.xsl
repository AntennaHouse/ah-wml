<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" 
    xmlns:fo="http://www.w3.org/1999/XSL/Format" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:axf="http://www.antennahouse.com/names/XSL/Extensions"
    xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
    xmlns:ahs="http://www.antennahouse.com/names/XSLT/Document/Layout"
    exclude-result-prefixes="xs ahf fo axf">

    <!--
         function:	Get FO property name
         note:		The FO property name will be different by specialization.
                    If ah-dita specialization is used, the name is 'fo:prop'.
                    Another user uses no namespace attribute 'fo'.
    -->
    <xsl:variable name="foPropName" as="xs:string">
        <xsl:call-template name="getVarValue">
            <xsl:with-param name="prmVarName" select="'foPropName'"/>
        </xsl:call-template>
    </xsl:variable>
    
    <!-- 
         function:	Judge that specified element's FO property has specified value
         param:		prmElem
         return:	xs:boolean
         note:		
    -->
    <xsl:function name="ahf:hasFoProperty" as="xs:boolean">
        <xsl:param name="prmElem" as="element()"/>
        <xsl:param name="prmName" as="xs:string"/>
        <xsl:param name="prmValue" as="xs:string"/>
        <xsl:variable name="foProp" as="attribute()*" select="ahf:getFoProperty($prmElem)"/>
        <xsl:variable name="targetFoProp" as="attribute()?" select="$foProp[name() eq $prmName]"/>
        <xsl:sequence select="string($targetFoProp) eq $prmValue"/>
    </xsl:function>
    
    <!-- 
         function:	Expand FO property into attribute()*
         param:		prmElem
         return:	Attribute node
         note:		XSL-FO attribute is authored in $prmElem/@fo:prop in CSS notation if document type is specialized by ah-dita.
                    Remove stylesheet specific style (starts with "ahs-").
    -->
    <xsl:function name="ahf:getFoProperty" as="attribute()*">
        <xsl:param name="prmElem" as="element()"/>
        <xsl:sequence select="ahf:getFoPropertyInner($prmElem,ahf:getFoAtt($prmElem))"/>
    </xsl:function>

    <!-- 
     function:	Get FO property string
     param:		prmElem
     return:	xs:string
     note:		The FO property name will be different by specialization. 
     -->
    <xsl:function name="ahf:getFoAtt" as="attribute()?">
        <xsl:param name="prmElem" as="element()"/>
        <xsl:sequence select="$prmElem/@*[name(.) eq $foPropName]"/>
    </xsl:function>

    <xsl:function name="ahf:getFoPropertyInner" as="attribute()*">
        <xsl:param name="prmElem" as="element()"/>
        <xsl:param name="prmProp" as="attribute()?"/>
        <xsl:variable name="foAttr" as="xs:string" select="normalize-space(string($prmProp))"/>
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
                                <xsl:sequence select="concat('ahs:',substring-after($tempPropName,$ahsExt))"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:sequence select="$tempPropName"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>                            
                    <xsl:variable name="propValue" as="xs:string" select="normalize-space(substring-after($propDesc,':'))"/>
                    <xsl:choose>
                        <!--"castable as xs:Name" can be used only in Saxon PE or EE.
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
         param:		prmElem,$prmSrc,$prmDst
         return:	Attribute node
         note:		
    -->
    <xsl:function name="ahf:getFoPropertyReplacing" as="attribute()*">
        <xsl:param name="prmElem" as="element()"/>
        <xsl:param name="prmSrc" as="xs:string+"/>
        <xsl:param name="prmDst" as="xs:string+"/>
        <xsl:variable name="foProps" as="attribute()*" select="ahf:getFoProperty($prmElem)"/>
        <xsl:for-each select="$foProps">
            <xsl:variable name="foProp" as="attribute()" select="."/>
            <xsl:variable name="propName" as="xs:Name" select="name($foProp)"/>
            <xsl:variable name="propValue" as="xs:string" select="string($foProp)"/>
            <xsl:variable name="replacedPropValue" as="xs:string" select="ahf:replace($propValue,$prmSrc,$prmDst)"/>
            <xsl:attribute name="{$propName}" select="$replacedPropValue"/>
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
                    This function refers global variable $pPaperWidth,$pPaperHeight,$pCropSizeH,$pCropSizeV,$pBleedSize.（dita2fo_param.xsl)
                    Authoring "0.5 * %paper-width" will get half width of page size.
    -->
    <xsl:function name="ahf:getFoPropertyWithPageVariables" as="attribute()*">
        <xsl:param name="prmElem" as="element()"/>
        <xsl:sequence select="ahf:getFoPropertyReplacing($prmElem,
            ('%paper-width','%paper-height'),
            ($pPaperWidth,$pPaperHeight))"/>
    </xsl:function>

</xsl:stylesheet>