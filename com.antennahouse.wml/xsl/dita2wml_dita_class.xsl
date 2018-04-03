<?xml version='1.0' encoding="UTF-8" ?>
<!--
****************************************************************
DITA to WordprocessingML Stylesheet
Module: Define DITA class related function
Copyright © 2009-2017 Antenna House, Inc. All rights reserved.
Antenna House is a trademark of Antenna House, Inc.
URL    : http://www.antennahouse.com/
E-mail : info@antennahouse.com
****************************************************************
-->
<xsl:stylesheet version="2.0" 
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:xs="http://www.w3.org/2001/XMLSchema"
 xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
 exclude-result-prefixes="xs ahf"
>
    
    <!-- Block elements or wrapper elements
     -->
    <xsl:variable name="blockElementClasses" as="xs:string+" select="
        (
        ' topic/abstract ',
        ' topic/body ',
        ' topic/bodydiv ',
        ' topic/div ',
        ' topic/dl ',
        ' topic/draft-comment ',
        ' topic/fig ',
        (:' topic/fn ',:)
        ' topic/itemgroup ',
        ' topic/lines ',
        ' topic/note ',
        ' topic/object ',
        ' topic/ol ',
        ' topic/ul ',
        ' topic/p ',
        ' topic/pre ',
        ' topic/required-cleanup ',
        ' topic/sectiondiv ',
        ' topic/simpletable ',
        ' topic/sl ',
        ' topic/table ',
        ' topic/title '
        )"/>

    <!-- 
     function:	Return $prmElem/@class has value in $textToParaElementClasses
     param:		$prmElem
     return:	xs:boolean
     note:		abstract/shortdesc is assumed inline level.
                topic/shortdesc is assumed as block level.
     -->
    <xsl:function name="ahf:isBlockElement" as="xs:boolean">
        <xsl:param name="prmNode" as="node()"/>
        <xsl:choose>
            <xsl:when test="$prmNode instance of element()">
                <xsl:variable name="class" as="xs:string" select="string($prmNode/@class)"/>
                <xsl:variable name="isOneOfBlockElement" as="xs:boolean" select="some $c in $blockElementClasses satisfies contains($class,$c)"/>
                <xsl:variable name="isBlockImage" as="xs:boolean" select="contains($class,' topic/image ') and (string($prmNode/@placement) eq 'break')"/>
                <xsl:variable name="isBlockLevelShortdesc" as="xs:boolean" select="exists($prmNode/self::*[contains(@class,' topic/shortdesc ')][parent::*[contains(@class,' topic/abstract ')]])"/>
                <xsl:variable name="isPContentDesc" as="xs:boolean" select="$prmNode[contains(@class,' topic/desc ')] and $prmNode/ancestor::*/@class[ahf:seqContains(string(.),(' topic/fig ',' topic/table ',' topic/object '))]"/>
                <xsl:sequence select="$isOneOfBlockElement or $isBlockImage or $isBlockLevelShortdesc or $isPContentDesc"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <!-- Block elements or wrapper elements where text child node and block elements are allowed.
         Stylesheet must generate <p> from child text node and inline elements sequence.
     -->
    <xsl:variable name="mixedContentElementClasses" as="xs:string+" select="
        (
        ' topic/abstract ',
        ' topic/bodydiv ',
        ' topic/dd ',
        ' topic/ddhd ',
        ' topic/dthd ',
        ' topic/div ',
        ' topic/draft-comment ',
        ' topic/example ',
        ' topic/fn ',
        ' topic/fig ',
        ' topic/itemgroup ',
        ' topic/li ',
        ' topic/lq ',
        ' topic/note ',
        ' topic/p ',
        ' topic/section ',
        ' topic/sectiondiv ',
        ' topic/entry ',
        ' topic/stentry ',
        ' topic/required-cleanup '
        )"/>
    
    <!-- 
     function:	Return $prmElem/@class has value in $mixedContentElementClasses
     param:		$prmElem
     return:	xs:boolean
     note:		
     -->
    <xsl:function name="ahf:isMixedContentElement" as="xs:boolean">
        <xsl:param name="prmElem" as="element()"/>
        <xsl:variable name="class" as="xs:string" select="string($prmElem/@class)"/>
        <xsl:variable name="isOneOfMixedContentElement" as="xs:boolean" select="some $c in $mixedContentElementClasses satisfies contains($class,$c)"/>
        <xsl:sequence select="$isOneOfMixedContentElement"/>
    </xsl:function>

    <!-- Inline container elements where text child node and inline elements are allowed.
         Stylesheet must generate <p> from these elements.
     -->
    <xsl:variable name="pElementClasses" as="xs:string+" select="
        (
        ' topic/title ',
        (:' topic/desc ',:)
        (:' topic/dd ',:)
        ' topic/sli '
        )"/>
    
    <!-- 
     function:	Return $prmElem/@class has value in $inlineContentElementClasses
     param:		$prmElem
     return:	xs:boolean
     note:		stylesheet shoould generate <p> if the return value is true()
     -->
    <xsl:function name="ahf:isPContentElement" as="xs:boolean">
        <xsl:param name="prmElem" as="element()"/>
        <xsl:variable name="class" as="xs:string" select="string($prmElem/@class)"/>
        <xsl:variable name="isOneOfPElement" as="xs:boolean" select="some $c in $pElementClasses satisfies contains($class,$c)"/>
        <xsl:variable name="isPContentDesc" as="xs:boolean" select="$prmElem[contains(@class,' topic/desc ')] and ahf:seqContains($prmElem/parent::*/@class/string(.),(' topic/fig ',' topic/table ',' topic/object '))"/>
        <xsl:sequence select="$isOneOfPElement or $isPContentDesc"/>
    </xsl:function>

</xsl:stylesheet>
