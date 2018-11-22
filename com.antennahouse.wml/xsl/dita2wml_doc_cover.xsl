<?xml version="1.0" encoding="UTF-8"?>
<!--
**************************************************************
DITA to WordprocessingML Stylesheet
Document.xml Cover Templates
**************************************************************
File Name : dita2wml_document_cover.xsl
**************************************************************
Copyright © 2009-2018 Antenna House, Inc. All rights reserved.
Antenna House is a trademark of Antenna House, Inc.
URL : http://www.antennahouse.com/
**************************************************************
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" 
    xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
    xmlns:array="http://www.w3.org/2005/xpath-functions/array"
    exclude-result-prefixes="xs ahf array"
    version="3.0">

    <!-- Parameter For Debug -->
    <xsl:variable name="PRM_SUPPORT_COVER" as="xs:string" select="$cNo"/>
    <xsl:variable name="pSupportCover" as="xs:boolean" select="$PRM_SUPPORT_COVER eq $cYes"/>
    
    <!-- Cover topicref/@outputclass value -->
    <xsl:variable name="cCover1" as="xs:string" select="'cover1'"/>
    <xsl:variable name="cCover2" as="xs:string" select="'cover2'"/>
    <xsl:variable name="cCover3" as="xs:string" select="'cover3'"/>
    <xsl:variable name="cCover4" as="xs:string" select="'cover4'"/>
    <xsl:variable name="coverOutputClassValue" as="xs:string+" select="($cCover1,$cCover2,$cCover3,$cCover4)"/>

    <!-- Text Box defaults -->
    <xsl:variable name="cTxtBoxDefaultTop"    as="xs:integer" select="0"/>
    <xsl:variable name="cTxtBoxDefaultLeft"   as="xs:integer" select="0"/>
    <xsl:variable name="cTxtBoxDefaultWidth"  as="xs:integer" select="ahf:toEmu('20mm')"/>
    <xsl:variable name="cTxtBoxDefaultHeight" as="xs:integer" select="ahf:toEmu('20mm')"/>

    <!-- 
     function:	Generate cover N
     param:		prmMap, prmCoverN
     return:	See probe
     note:		 
     -->
    <xsl:template name="genCoverN" as="element(w:p)*">
        <xsl:param name="prmMap" as="element()" required="yes"/>
        <xsl:param name="prmCoverN" as="xs:string+" required="yes"/>
        <xsl:choose>
            <xsl:when test="$isBookMap">
                <xsl:for-each select="$prmCoverN">
                    <xsl:variable name="coverN" as="xs:string" select="."/>
                    <xsl:apply-templates select="$map/*[contains(@class, ' bookmap/frontmatter ')]/*[contains(@class,' map/topicref ')][ahf:hasOutputClassValue(.,$coverN)]" mode="MODE_MAKE_COVER"/>
                    <xsl:apply-templates select="$map/*[contains(@class, ' bookmap/backmatter ')]/*[contains(@class,' map/topicref ')][ahf:hasOutputClassValue(.,$coverN)]" mode="MODE_MAKE_COVER"/>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:for-each select="$prmCoverN">
                    <xsl:variable name="coverN" as="xs:string" select="."/>
                    <xsl:apply-templates select="$map/*[contains(@class, ' map/topicref ')][ahf:hasOutputClassValue(.,$coverN)]" mode="MODE_MAKE_COVER"/>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>            
    </xsl:template>

    <!-- 
        function:	Cover topicref template
        param:		none
        return:	    none
        note:		Call cover generation template
    -->
    <xsl:template match="*[contains(@class,' map/topicref ')]" mode="MODE_MAKE_COVER">
        <xsl:variable name="topicRef" select="."/>
        <xsl:variable name="topicContent"  as="element()?" select="ahf:getTopicFromTopicRef($topicRef)"/>
        <xsl:choose>
            <xsl:when test="exists($topicContent)">
                <xsl:apply-templates select="$topicContent/*[contains(@class,' topic/body ')]/*[contains(@class,' topic/bodydiv ')]" mode="MODE_MAKE_COVER">
                    <xsl:with-param name="prmTopicRef" tunnel="yes" select="$topicRef"/>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="warningContinue">
                    <xsl:with-param name="prmMes" 
                        select="ahf:replace($stMes070,('%href','%file'),(string(@href),string(@xtrf)))"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- 
     function:	bodydiv processing
     param:		prmTopicRef
     return:	See probe
     note:		bodydiv is assumed as container that should generate absolute positioning fo:block-container in PDF.
                In .docx processing this template generates absolute positioned text-box. 
     -->
    <xsl:template match="*[contains(@class,' topic/bodydiv ')]" mode="MODE_MAKE_COVER">
        <xsl:param name="prmTopicRef" as="element()" tunnel="yes" required="yes"/>
        <xsl:call-template name="genAbsTextBoxForCover">
            <xsl:with-param name="prmElem" select="."/>
        </xsl:call-template>                
    </xsl:template>
    
    <!-- 
     function:	generate absolute positioned text box
     param:		prmTopicRef
     return:	See probe
     note:		bodydiv is assumed as container that should generate absolute positioning fo:block-container in PDF.
                In .docx processing this template generates absolute positioned text-box. 
     -->
    <xsl:template name="genAbsTextBoxForCover" as="node()*">
        <xsl:param name="prmElem" as="element()" required="yes"/>
        <xsl:variable name="foValue" as="xs:string" select="ahf:getFoProps($prmElem)"/>
        <xsl:variable name="foProp" as="attribute()*" select="ahf:getFoPropertyWithPageVariables($foValue,$prmElem)"/>
        <xsl:variable name="textBoxSpec" as="array(xs:integer)" select="ahf:getTextBoxSpec($foProp)"/>
        <!--Dummy-->
        <xsl:sequence select="()"/>
    </xsl:template>
    
    <!-- 
     function:	Get FO property string
     param:		prmElem
     return:	xs:string
     note:		The FO property name will be different by vocabulary. 
     -->
    <xsl:function name="ahf:getFoProps" as="xs:string">
        <xsl:param name="prmElem" as="element()"/>
        <xsl:sequence select="string($prmElem/@fo)"/>
    </xsl:function>

    <!-- 
     function:	Get text-box property top, left, width, height in EMU unit
     param:		prmFoProp
     return:	attribute()+
     note:		Return appropriate initial value if not specified. 
     -->
    <xsl:function name="ahf:getTextBoxSpec" as="array(xs:integer)">
        <xsl:param name="prmFoProps" as="attribute()+"/>
        <!-- Calculate EMU value from FO property -->
        <xsl:variable name="propTop"     as="xs:integer?" select="ahf:convertFoPropToEmu($prmFoProps[name() eq 'top'][1])"/>
        <xsl:variable name="propBottom"  as="xs:integer?" select="ahf:convertFoPropToEmu($prmFoProps[name() eq 'bottom'][1])"/>
        <xsl:variable name="propLeft"    as="xs:integer?" select="ahf:convertFoPropToEmu($prmFoProps[name() eq 'left'][1])"/>
        <xsl:variable name="propRight"   as="xs:integer?" select="ahf:convertFoPropToEmu($prmFoProps[name() eq 'right'][1])"/>
        <xsl:variable name="propWidth"   as="xs:integer?" select="ahf:convertFoPropToEmu($prmFoProps[name() eq 'width'][1])"/>
        <xsl:variable name="propHeight"  as="xs:integer?" select="ahf:convertFoPropToEmu($prmFoProps[name() eq 'height'][1])"/>
        <!-- Select top, left, width, height -->
        <xsl:variable name="top" as="xs:integer">
            <xsl:choose>
                <xsl:when test="exists($propTop)">
                    <xsl:sequence select="$propTop"/>
                </xsl:when>
                <xsl:when test="exists($propBottom) and exists($propHeight)">
                    <xsl:sequence select="round(ahf:toEmu($pPaperHeight) - $propBottom)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="$cTxtBoxDefaultTop"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="left" as="xs:integer">
            <xsl:choose>
                <xsl:when test="exists($propLeft)">
                    <xsl:sequence select="$propLeft"/>
                </xsl:when>
                <xsl:when test="exists($propRight) and exists($propWidth)">
                    <xsl:sequence select="round(ahf:toEmu($pPaperWidth) - $propRight)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="$cTxtBoxDefaultLeft"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="width" as="xs:integer">
            <xsl:choose>
                <xsl:when test="exists($propWidth)">
                    <xsl:sequence select="$propWidth"/>
                </xsl:when>
                <xsl:when test="empty($propLeft) and exists($propRight)">
                    <xsl:sequence select="round(ahf:toEmu($pPaperWidth) - $propRight)"/>
                </xsl:when>
                <xsl:when test="exists($propLeft) and empty($propRight)">
                    <xsl:sequence select="round(ahf:toEmu($pPaperWidth) - $propLeft)"/>
                </xsl:when>
                <xsl:when test="exists($propLeft) and exists($propRight)">
                    <xsl:sequence select="round(ahf:toEmu($pPaperWidth) - $propLeft - $propRight)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="round(ahf:toEmu($pPaperWidth))"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="height" as="xs:integer">
            <xsl:choose>
                <xsl:when test="exists($propHeight)">
                    <xsl:sequence select="$propHeight"/>
                </xsl:when>
                <xsl:when test="empty($propTop) and exists($propBottom)">
                    <xsl:sequence select="round(ahf:toEmu($pPaperHeight) - $propBottom)"/>
                </xsl:when>
                <xsl:when test="exists($propTop) and empty($propBottom)">
                    <xsl:sequence select="round(ahf:toEmu($pPaperHeight) - $propTop)"/>
                </xsl:when>
                <xsl:when test="exists($propTop) and exists($propBottom)">
                    <xsl:sequence select="round(ahf:toEmu($pPaperHeight) - $propTop - $propBottom)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="round(ahf:toEmu($pPaperHeight))"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:sequence select="[$top,$left,$width,$height]"/>
    </xsl:function>
    
    <!-- 
     function:	Convert expression to EMU value
     param:		prmFoProp
     return:	xs:integer?
     note:		 
     -->
    <xsl:function name="ahf:convertFoPropToEmu" as="xs:integer?">
        <xsl:param name="prmFoProp" as="attribute()?"/>
        <xsl:choose>
            <xsl:when test="exists($prmFoProp)">
                <xsl:variable name="foProp" as="xs:string" select="string($prmFoProp)"/>
                <xsl:variable name="foPropXpath" as="xs:string" select="ahf:convertToEmuXpath($foProp)"/>
                <xsl:try>
                    <xsl:variable name="xpathResult" as="xs:numeric">
                        <xsl:evaluate xpath="$foPropXpath" as="xs:numeric"/>
                    </xsl:variable>
                    <xsl:sequence select="xs:integer(round($xpathResult))"/>
                    <xsl:catch>
                        <xsl:call-template name="warningContinue">
                            <xsl:with-param name="prmMes" select="ahf:replace($stMes2015,('%xpath'),($foPropXpath))"/>
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
     function:	Convert expression to XPath string that returns EMU value
     param:		prmFoPropExp
     return:	xs:string
     note:		 
     -->
    <xsl:function name="ahf:convertToEmuXpath" as="xs:string">
        <xsl:param name="prmFoPropExp" as="xs:string"/>
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
                            <xsl:sequence select="concat('ahf:toEmu(''',.,''')')"/>
                        </xsl:when>
                        <xsl:when test="ahf:isNumericValue(.)">
                            <xsl:sequence select="."/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:sequence select="ahf:convertVariableInFoProp(.)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:non-matching-substring>
            </xsl:analyze-string>
        </xsl:variable>
        <xsl:sequence select="string-join($tempExpandedExp,'')"/>
    </xsl:function>
    
    <!-- 
     function:	Convert variable to value
     param:		prmVariable
     return:	xs:string
     note:		 
     -->
    <xsl:function name="ahf:convertVariableInFoProp" as="xs:string">
        <xsl:param name="prmVariable" as="xs:string"/>
        <xsl:sequence select="'1'"/>
    </xsl:function>

    <!-- ==== END OF STYLESHEET === -->

</xsl:stylesheet>