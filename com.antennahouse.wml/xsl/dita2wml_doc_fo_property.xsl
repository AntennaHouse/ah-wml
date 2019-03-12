<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" 
    xmlns:fo="http://www.w3.org/1999/XSL/Format" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" 
    xmlns:axf="http://www.antennahouse.com/names/XSL/Extensions"
    xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
    xmlns:ahs="http://www.antennahouse.com/names/XSLT/Document/Layout"
    exclude-result-prefixes="xs ahf fo axf ahs">

    <!--
         function:	Get FO property name
         note:	    The FO property name will be different by specialization.
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
         param:	    prmElem
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
         function:	Get FO property value
         param:	    prmElem, prmName
         return:	xs:string
         note:		Get FO property value by specified $prmName
    -->
    <xsl:function name="ahf:getFoPropertyValue" as="xs:string?">
        <xsl:param name="prmElem" as="element()"/>
        <xsl:param name="prmName" as="xs:string"/>
        <xsl:variable name="foProp" as="attribute()*" select="ahf:getFoProperty($prmElem)"/>
        <xsl:variable name="targetFoProp" as="attribute()?" select="$foProp[name() eq $prmName]"/>
        <xsl:sequence select="if (exists($targetFoProp)) then string($targetFoProp) else ()"/>
    </xsl:function>
    
    <!-- 
         function:	Expand FO property into attribute()*
         param:     prmElem
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
     param:	    prmElem
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
                            <xsl:attribute name="{xs:Name($propName)}" select="$propValue"/>
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
     function:	Convert start-indent to WML
     param:	    prmStartIndent
     return:	xs:string
     note:		prmStartIndent must be written as length notation 
     -->
    <xsl:function name="ahf:convertStartIndentToWml" as="element()?">
        <xsl:param name="prmStartIndent" as="xs:string"/>
        <xsl:variable name="startIndentTwipVal" as="xs:string" select="string(ahf:convertFoExpToUnitValue($prmStartIndent,'twip'))"/>
        <w:ind w:start="{$startIndentTwipVal}"/>
    </xsl:function>
    
    <!-- 
     function:	Convert expression in variable to specified unit value
     param:	    prmFoPropExp (XSL-FO property expression), prmUnit
     return:	xs:integer?
     note:		 
     -->
    <xsl:function name="ahf:convertFoExpToUnitValue" as="xs:integer?">
        <xsl:param name="prmFoPropExp" as="xs:string?"/>
        <xsl:param name="prmUnit" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="exists($prmFoPropExp)">
                <xsl:variable name="foPropExpXpath" as="xs:string" select="ahf:convertFoPropExpToXpath($prmFoPropExp,$prmUnit)"/>
                <xsl:try>
                    <xsl:variable name="xpathResult" as="xs:numeric">
                        <xsl:evaluate xpath="$foPropExpXpath" as="xs:numeric"/>
                    </xsl:variable>
                    <xsl:sequence select="xs:integer(round($xpathResult))"/>
                    <xsl:catch>
                        <xsl:call-template name="warningContinue">
                            <xsl:with-param name="prmMes" select="ahf:replace($stMes2015,('%xpath'),($foPropExpXpath))"/>
                        </xsl:call-template>
                        <xsl:sequence select="()"/>
                    </xsl:catch>
                </xsl:try>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!-- 
     function:	Convert XSL-FO property value expression to XPath string that returns specified unit value
     param:	    prmFoPropExp, prmUnit
     return:	xs:string
     note:		Conversion function is supposed to be "ahf:to[Uppercase of first unit string][lowercase of remain unit string]"
                They are implemented in dita2wml_util_unit.xsl
     -->
    <xsl:function name="ahf:convertFoPropExpToXpath" as="xs:string">
        <xsl:param name="prmFoPropExp" as="xs:string"/>
        <xsl:param name="prmUnit" as="xs:string"/>
        <xsl:variable name="unitFunc" as="xs:string" select="concat('ahf:to',upper-case(substring($prmUnit,1,1)),substring($prmUnit,2))"/>
        <xsl:variable name="expandExpRegX" as="xs:string" select="'[\s\(\),\*\+'']+?'"/>
        <xsl:variable name="tempExpandedExp" as="xs:string*">
            <!-- Analyze string using regular expression -->
            <xsl:analyze-string select="normalize-space($prmFoPropExp)" regex="{$expandExpRegX}">
                <!-- White-space, operation symbol or parentheses-->
                <xsl:matching-substring>
                    <xsl:sequence select="."/>
                </xsl:matching-substring>
                <!-- Token that is delimited by white-space or symbol-->
                <xsl:non-matching-substring>
                    <xsl:variable name="token" as="xs:string" select="."/>
                    <xsl:choose>
                        <xsl:when test="ahf:isUnitValue(.)">
                            <xsl:sequence select="concat($unitFunc,'(''',.,''')')"/>
                        </xsl:when>
                        <xsl:when test="ahf:isNumericValue(.)">
                            <xsl:sequence select="."/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:variable name="convertedToken" select="ahf:convertPageVariablesInFoProp(.)"/>
                            <xsl:choose>
                                <xsl:when test="ahf:isUnitValue($convertedToken)">
                                    <xsl:sequence select="concat($unitFunc,'(''',$convertedToken,''')')"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:sequence select="$convertedToken"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:non-matching-substring>
            </xsl:analyze-string>
        </xsl:variable>
        <xsl:sequence select="string-join($tempExpandedExp,'')"/>
    </xsl:function>
    
</xsl:stylesheet>