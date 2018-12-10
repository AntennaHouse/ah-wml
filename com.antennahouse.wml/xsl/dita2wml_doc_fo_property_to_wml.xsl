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
         function:	Convert FO property into w:pPr child level elements
         param:     prmFoProp
         return:	element()*
         note:		XSL-FO properties are expanded in $prmFoProp. 
                    This function convert them into the elements that constructs w:pPr children.
    -->
    <xsl:function name="ahf:foPropToPprChild" as="element()*">
        <xsl:param name="prmFoProp" as="attribute()*"/>
        <!-- keep-next.within-page/column -->
        <xsl:if test="$prmFoProp[name() = ('keep-next.within-page','keep-next.within-column')][last()][string(.) eq 'always']">
            <w:keepNext w:val="true"/>
        </xsl:if>
        
        <!-- keep-together.within-page/column -->
        <xsl:if test="$prmFoProp[name() eq 'keep-together.within-page'][last()][string(.) eq 'always']">
            <w:keepLines w:val="true"/>
        </xsl:if>
        
        <!-- break-before="page" -->
        <xsl:if test="$prmFoProp[name() eq 'break-before'][last()][string(.) eq 'page']">
            <w:pageBreakBefore w:val="true"/>
        </xsl:if>
        
        <!-- hyphenate="true/false" -->
        <xsl:if test="$prmFoProp[name() eq 'hyphenate'][last()][string(.) = ('true','false')]">
            <xsl:variable name="hyphenatePropVal" as="xs:string" select="string($prmFoProp[name() eq 'hyphenate'][last()][string(.) = ('true','false')])"/>
            <xsl:variable name="noHyphenateVal" as="xs:boolean" select="$hyphenatePropVal eq 'false'"/>
            <w:suppressAutoHyphens>
                <xsl:attribute name="w:val" select="string($noHyphenateVal)"/>
            </w:suppressAutoHyphens>
        </xsl:if>

        <!-- axf:word-break="break-all" -->
        <xsl:if test="$prmFoProp[name() eq 'axf:word-break'][last()][string(.) eq 'break-all']">
            <w:wordWrap w:val="false"/>
        </xsl:if>

        <!-- space-before, space-after, line-height
             XSL-FO line-height notation is too difficult to convert into Word's w:line and w:lineRule
         -->
        <xsl:if test="$prmFoProp[name() = ('space-before', 'space-after')]">
            <w:spacing>
                <xsl:if test="$prmFoProp[name() eq 'space-before']">
                    <xsl:variable name="spaceBeforeProp" as="xs:string" select="string($prmFoProp[name() eq 'space-before'][last()])"/>
                    <xsl:variable name="spaceBeforeTwipVal" as="xs:integer?" select="ahf:convertFoExpToUnitValue($spaceBeforeProp,$cUnitTwip)"/>
                    <xsl:attribute name="w:before" select="if (exists($spaceBeforeTwipVal)) then string($spaceBeforeTwipVal) else '0'"/>
                </xsl:if>
                <xsl:if test="$prmFoProp[name() eq 'space-after']">
                    <xsl:variable name="spaceAfterProp" as="xs:string" select="string($prmFoProp[name() eq 'space-after'][last()])"/>
                    <xsl:variable name="spaceAfterTwipVal" as="xs:integer?" select="ahf:convertFoExpToUnitValue($spaceAfterProp,$cUnitTwip)"/>
                    <xsl:attribute name="w:after" select="if (exists($spaceAfterTwipVal)) then string($spaceAfterTwipVal) else '0'"/>
                </xsl:if>
            </w:spacing>
        </xsl:if>
        
        <!-- start-indent, end-indent, text-indent -->
        <xsl:if test="$prmFoProp[name() = ('start-indent', 'end-indent', 'text-indent')]">
            <w:ind>
                <xsl:if test="$prmFoProp[name() eq 'start-indent']">
                    <xsl:variable name="startIndentProp" as="xs:string" select="string($prmFoProp[name() eq 'start-indent'][last()])"/>
                    <xsl:variable name="startIndentTwipVal" as="xs:integer?" select="ahf:convertFoExpToUnitValue($startIndentProp,$cUnitTwip)"/>
                    <xsl:attribute name="w:start" select="if (exists($startIndentTwipVal)) then string($startIndentTwipVal) else '0'"/>
                </xsl:if>
                <xsl:if test="$prmFoProp[name() eq 'end-indent']">
                    <xsl:variable name="endIndentProp" as="xs:string" select="string($prmFoProp[name() eq 'end-indent'][last()])"/>
                    <xsl:variable name="endIndentTwipVal" as="xs:integer?" select="ahf:convertFoExpToUnitValue($endIndentProp,$cUnitTwip)"/>
                    <xsl:attribute name="w:end" select="if (exists($endIndentTwipVal)) then string($endIndentTwipVal) else '0'"/>
                </xsl:if>
                <xsl:if test="$prmFoProp[name() eq 'text-indent']">
                    <xsl:variable name="textIndentProp" as="xs:string" select="string($prmFoProp[name() eq 'text-indent'][last()])"/>
                    <xsl:variable name="textIndentTwipVal" as="xs:integer?" select="ahf:convertFoExpToUnitValue($textIndentProp,$cUnitTwip)"/>
                    <xsl:choose>
                        <xsl:when test="empty($textIndentTwipVal)"/>
                        <xsl:when test="$textIndentTwipVal gt 0">
                            <xsl:attribute name="w:firstLine" select="string($textIndentTwipVal)"/>
                        </xsl:when>
                        <xsl:when test="$textIndentTwipVal lt 0">
                            <xsl:attribute name="w:hanging" select="string(-1 * $textIndentTwipVal)"/>
                        </xsl:when>
                        <xsl:otherwise/>
                    </xsl:choose>
                </xsl:if>
            </w:ind>
        </xsl:if>

        <!-- text-align="start | center | end | justify | inside | outside | left | right" -->
        <xsl:if test="$prmFoProp[name() eq 'text-align'][last()][string(.) = ('start','center','end','justify','left','right')]">
            <xsl:variable name="textAlignPropVal" as="xs:string" select="string($prmFoProp[name() eq 'text-align'][last()][string(.) = ('start','center','end','justify','left','right')])"/>
            <xsl:variable name="textAlignVal" as="xs:string">
                <xsl:choose>
                    <xsl:when test="$textAlignPropVal = ('start','left')">
                        <xsl:sequence select="'start'"/>
                    </xsl:when>
                    <xsl:when test="$textAlignPropVal = ('end','right')">
                        <xsl:sequence select="'end'"/>
                    </xsl:when>
                    <xsl:when test="$textAlignPropVal eq 'center'">
                        <xsl:sequence select="'center'"/>
                    </xsl:when>
                    <xsl:when test="$textAlignPropVal eq 'justify'">
                        <xsl:sequence select="'both'"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:variable>
            <w:jc w:val="{$textAlignVal}"/>
        </xsl:if>
        
    </xsl:function>
    
</xsl:stylesheet>