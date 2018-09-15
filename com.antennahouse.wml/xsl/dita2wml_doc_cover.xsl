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
    xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
    exclude-result-prefixes="xs ahf"
    version="3.0">

    <xsl:variable name="coverOutputClassValue" as="xs:string+" select="('cover1','cover2','cover3','cover4')"/>

    <!-- 
     function:	bodydiv processing
     param:		prmTopicRef
     return:	See probe
     note:		bodydiv is assumed as container that should generate absolute positioning fo:block-container in PDF.
                In .docx processing this template generates absolute positioned text-box. 
     -->
    <xsl:template match="*[contains(@class,' topic/bodydiv ')]" priority="20">
        <xsl:param name="prmTopicRef" as="element()" tunnel="yes" required="yes"/>
        <xsl:choose>
            <xsl:when test="ahf:hasOneOfOutputclassValue($prmTopicRef,$coverOutputClassValue)">
                <xsl:call-template name="genAbsTextBoxForCover">
                    <xsl:with-param name="prmElem" select="."/>
                </xsl:call-template>                
            </xsl:when>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- 
     function:	generate absolute positioned text box
     param:		prmTopicRef
     return:	See probe
     note:		bodydiv is assumed as container that should generate absolute postioning fo:block-container in PDF.
                In .docx processing this template generates absolute positioned text-box. 
     -->
    <xsl:template name="genAbsTextBoxForCover" as="node()*">
        <xsl:param name="prmElem" as="element()" required="yes"/>
        <xsl:variable name="foValue" as="xs:string" select="ahf:getFoProps($prmElem)"/>
        <xsl:variable name="foProp" as="attribute()*" select="ahf:getFoPropertyWithPageVariables($foValue,$prmElem)"/>
        
    </xsl:template>
    
    <!-- 
     function:	get FO property string
     param:		prmElem
     return:	xs:string
     note:		The FO property name will be different by vocabulary. 
     -->
    <xsl:function name="ahf:getFoProps" as="xs:string">
        <xsl:param name="prmElem" as="element()"/>
        <xsl:sequence select="string($prmElem/@fo)"/>
    </xsl:function>

    <!-- 
     function:	get text-box property top, left, width, height in EMU unit
     param:		prmFoProp
     return:	attribute()+
     note:		Return appropriate initial value if not specified. 
     -->
    <xsl:function name="ahf:getTextBoxSpec" as="attribute()+">
        <xsl:param name="prmFoProp" as="attribute()+"/>
        
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
            <xsl:analyze-string select="$prmFoPropExp" regex="{$expandExpRegX}">
                <!-- White-space, operation symbol or parentheses-->
                <xsl:matching-substring>
                    <xsl:sequence select="."/>
                </xsl:matching-substring>
                <!-- Token that is delimited by white-space or symbol-->
                <xsl:non-matching-substring>
                    <xsl:variable name="token" as="xs:string" select="."/>
                    <xsl:choose>
                        <xsl:when test="ahf:isUnitValue(.)">
                            <xsl:sequence select="concat('ahf:toEmu(',.,')')"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:sequence select="'1'"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:non-matching-substring>
            </xsl:analyze-string>
        </xsl:variable>
        <xsl:sequence select="string-join($tempExpandedExp,'')"/>
    </xsl:function>
    















    <!-- 
     function:	Genral topicref processing
     param:		none
     return:	
     note:		If topicref/@href points to topic, an section break should be detected at topic level.
                Otherwise it should be detected at topicref level.
     -->
    <!--
    <xsl:template match="*[contains(@class,' map/topicref ')][exists(@href)]">
        <xsl:variable name="topicRef" select="."/>
        
        <!-\- get topic from @href -\->
        <xsl:variable name="topic" select="ahf:getTopicFromTopicRef($topicRef)" as="element()?"/>
        <xsl:variable name="topicRefLevel" select="ahf:getTopicRefLevel($topicRef)" as="xs:integer"/>
        
        <xsl:choose>
            <xsl:when test="exists($topic)">
                <!-\- Process contents -\->
                <xsl:apply-templates select="$topic">
                    <xsl:with-param name="prmTopicRef"       tunnel="yes" select="$topicRef"/>
                    <xsl:with-param name="prmTopicRefLevel"  tunnel="yes" select="$topicRefLevel"/>
                    <xsl:with-param name="prmTopic"          tunnel="yes" select="$topic"/>
                    <xsl:with-param name="prmIndentLevel"    tunnel="yes" select="0"/>
                    <xsl:with-param name="prmExtraIndent"    tunnel="yes" select="0"/>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="warningContinue">
                    <xsl:with-param name="prmMes" 
                        select="ahf:replace($stMes070,('%href','%file'),(string(@href),string(@xtrf)))"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
        
        <!-\- Nested topicref processing -\->
        <xsl:apply-templates select="child::*[contains(@class,' map/topicref ')]"/>
        
    </xsl:template>

    <xsl:template match="*[contains(@class,' map/topicref ')][empty(@href)]">
        <xsl:variable name="topicRef" select="."/>
        
        <!-\- Generate section property -\->
        <xsl:call-template name="getSectionPropertyElemBefore"/>

        <!-\- Generate column break -\->
        <xsl:call-template name="getColumnBreak">
            <xsl:with-param name="prmTopicRef" select="$topicRef"/>
            <xsl:with-param name="prmTopic" select="()"/>
        </xsl:call-template>

        <xsl:choose>
            <xsl:when test="$topicRef/*[contains(@class,' map/topicmeta ')]/*[contains(@class,' topic/navtitle ')] or exists(@navtitle) or $topicRef[contains(@class,' bookmap/glossarylist ')]">
                <!-\- Process title -\->
                <xsl:call-template name="genTopicHeadTitle">
                    <xsl:with-param name="prmTopicRef"       select="$topicRef"/>
                    <xsl:with-param name="prmIndentLevel"    tunnel="yes" select="0"/>
                    <xsl:with-param name="prmExtraIndent"    tunnel="yes" select="0"/>
                    <xsl:with-param name="prmDefaultTitle">
                        <xsl:choose>
                            <xsl:when test="$topicRef[contains(@class,' bookmap/glossarylist ')]">
                                <xsl:call-template name="getVarValue">
                                    <xsl:with-param name="prmVarName" select="'Glossary_List_Title'"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:sequence select="''"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise/>
        </xsl:choose>

        <xsl:call-template name="getSectionPropertyElemAfter"/>
        
        <!-\- Nested topicref processing -\->
        <xsl:apply-templates select="child::*[contains(@class,' map/topicref ')]"/>
        
    </xsl:template-->
    

    <!-- 
     function:	General topic processing
     param:		prmTopicRef
     return:	
     note:		related-links is not implemented yet!
                Section break must be detected after shortdesc/abstract processing.
                An boy may have another section property.
     -->
    <!--xsl:template match="*[contains(@class, ' topic/topic ')]">
        <xsl:param name="prmTopicRef" as="element()" tunnel="yes" required="yes"/>
        <xsl:comment> topic @id="<xsl:value-of select="ahf:generateId(.)"/>"</xsl:comment>
        
        <!-\- Generate section property -\->
        <xsl:call-template name="getSectionPropertyElemBefore"/>

        <!-\- Generate column break -\->
        <xsl:call-template name="getColumnBreak">
            <xsl:with-param name="prmTopicRef" select="$prmTopicRef"/>
            <xsl:with-param name="prmTopic" select="."/>
        </xsl:call-template>
        
        <xsl:apply-templates select="*[contains(@class, ' topic/title ')]"/>    
        <xsl:apply-templates select="*[contains(@class, ' topic/shortdesc ')] | *[contains(@class, ' topic/abstract ')]"/>

        <!-\- Generate section property -\->
        <xsl:call-template name="getSectionPropertyElemAfter"/>

        <xsl:apply-templates select="*[contains(@class, ' topic/body ')]"/>
        <xsl:apply-templates select="*[contains(@class, ' topic/related-links ')]"/>

        <!-\- Nested topic processing -\->
        <xsl:apply-templates select="*[contains(@class, ' topic/topic ')]"/>
    </xsl:template-->

    <!-- ==== END OF STYLESHEET === -->

</xsl:stylesheet>