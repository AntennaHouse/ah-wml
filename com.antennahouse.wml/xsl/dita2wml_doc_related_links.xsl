<?xml version="1.0" encoding="UTF-8"?>
<!--
**************************************************************
DITA to WordprocessingML Stylesheet
Document.xml Related-links element Templates
**************************************************************
File Name : dita2wml_doc_related_links.xsl
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
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    exclude-result-prefixes="xs ahf map"
    version="3.0">

    <!-- 
     function:	related-links processing
     param:		prmTopicRef (tunnel)
     return:	
     note:		
     -->
    <xsl:template match="*[contains(@class,' topic/related-links ')]">
        <xsl:param name="prmTopicRef" tunnel="yes" required="yes" as="element()"/>
        <!-- Generate section property -->
        <xsl:call-template name="getSectionPropertyElemBefore"/>
        
        <xsl:variable name="linkCount" select="count(descendant::*[contains(@class,' topic/link ')][ahf:isTargetLink(.)])" as="xs:integer"/>
        <xsl:if test="$linkCount gt 0">
            <xsl:call-template name="makeRelatedLink">
                <xsl:with-param name="prmRelatedLinks" select="."/>
            </xsl:call-template>
        </xsl:if>
        
        <xsl:call-template name="getSectionPropertyElemAfter"/>
        
    </xsl:template>
    
    <xsl:function name="ahf:isTargetLink" as="xs:boolean">
        <xsl:param name="prmLink" as="element()"/>
        <xsl:sequence select="(string($prmLink/@role) = ('friend','other')) or empty($prmLink/@role)"/>
    </xsl:function>
    
    <!-- 
     function:	Make related-links block
     param:		prmRelatedLinks
     return:	related-links fo objects
     note:		
     -->
    <xsl:template name="makeRelatedLink">
        <xsl:param name="prmRelatedLinks" required="yes" as="element()"/>
        
        <!-- Make related-link title block -->
        
        <!-- process link -->
        <xsl:call-template name="processLink">
            <xsl:with-param name="prmRelatedLinks" select="$prmRelatedLinks"/>
        </xsl:call-template>
        
        <!-- Make related-link end block -->
    </xsl:template>
    
    <!-- 
     function:	Process link
     param:		prmRelatedLinks
     return:	reference line contentes
     note:		none
     -->
    <xsl:template name="processLink">
        <xsl:param name="prmRelatedLinks" required="yes" as="element()"/>
        
        <xsl:for-each select="$prmRelatedLinks/descendant::*[contains(@class,' topic/link ')]
            [ahf:isTargetLink(.)]">
            <xsl:variable name="link" select="." as="element()"/>
            <xsl:variable name="href" select="string($link/@href)" as="xs:string"/>
            <xsl:variable name="ohref" select="string($link/@ohref)" as="xs:string"/>
            <xsl:variable name="xtrf"  select="string($link/@xtrf)" as="xs:string"/>
            <xsl:variable name="linktext" as="node()*">
                <xsl:apply-templates select="$link/linktext" mode="GET_CONTENTS"/>
            </xsl:variable>
            <xsl:variable name="isLinkInside" as="xs:boolean" select="starts-with($href,'#')"/>
            <!--
            <xsl:variable name="topicContent" as="element()?" select="if ($isLinkInside) then ahf:getTopicFromLink($link) else ()"/>
            <xsl:variable name="topicRef" as="element()?" select="if (exists($topicContent)) then ahf:getTopicRef($topicContent) else ()"/>
            <xsl:variable name="topicTitle" as="element()?" select="if (exists($topicContent)) then $topicContent/child::*[contains(@class,' topic/title ')][1] else ()"/>
            -->
            <!--fo:block>
                <xsl:call-template name="getAttributeSetWithLang">
                    <xsl:with-param name="prmAttrSetName" select="'atsRelatedLinkBlock'"/>
                    <xsl:with-param name="prmElem" select="if (exists($topicTitle)) then $topicTitle else $link"/>
                </xsl:call-template>
                <fo:inline>
                    <xsl:choose>
                        <xsl:when test="$isLinkInside">
                            <xsl:choose>
                                <xsl:when test="empty($topicContent)">
                                    <xsl:call-template name="warningContinue">
                                        <xsl:with-param name="prmMes"
                                            select="ahf:replace($stMes062,('%file','%href'),($xtrf,$ohref))"/>
                                    </xsl:call-template>
                                </xsl:when>
                                <xsl:when test="empty($topicRef)">
                                    <xsl:call-template name="warningContinue">
                                        <xsl:with-param name="prmMes"
                                            select="ahf:replace($stMes063,('%file','%href'),($xtrf,$ohref))"/>
                                    </xsl:call-template>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:call-template name="editLinkInside">
                                        <xsl:with-param name="prmTopicRef"     select="$topicRef"/>
                                        <xsl:with-param name="prmTopicContent" select="$topicContent"/>
                                        <xsl:with-param name="prmRelatedLinks" select="$prmRelatedLinks"/>
                                    </xsl:call-template>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="editLinkOutside">
                                <xsl:with-param name="prmHref" select="$href"/>
                                <xsl:with-param name="prmLinktext" select="$linktext"/>
                            </xsl:call-template>
                        </xsl:otherwise>
                    </xsl:choose>
                </fo:inline>
            </fo:block-->
        </xsl:for-each>
    </xsl:template>
    
    <!-- 
     function:	Linktext template
     param:	    
     return:	linktext contents
     note:		This template will be never called!
     -->
    <xsl:template match="*[contains(@class, ' map/linktext ')] | *[contains(@class, ' topic/linktext ')]">
        <!--fo:inline>
            <xsl:call-template name="getAttributeSetWithLang">
                <xsl:with-param name="prmAttrSetName" select="'atsLinkText'"/>
            </xsl:call-template>
            <xsl:call-template name="ahf:getUnivAtts"/>
            <xsl:apply-templates>
            </xsl:apply-templates>
        </fo:inline-->
    </xsl:template>
    
    <!-- 
     function:	Edit reference line for inside link
     param:		prmTopicRef, prmTopicContent
     return:	reference line contentes
     note:		
     -->
    <xsl:template name="editLinkInside">
        <xsl:param name="prmTopicRef" required="yes" as="element()"/>
        <xsl:param name="prmTopicContent" required="yes" as="element()"/>
        <xsl:param name="prmRelatedLinks" required="yes" as="element()"/>
        
        <!--xsl:variable name="topicIdAtr" select="ahf:getIdAtts($prmTopicContent,$prmTopicRef,true())" as="attribute()*"/>
        <xsl:variable name="topicId" select="string($topicIdAtr[1])" as="xs:string"/>
        <xsl:variable name="titleMode" select="ahf:getTitleMode($prmTopicRef,$prmTopicContent)" as="xs:integer"/>
        
        <xsl:variable name="title" as="element()">
            <xsl:sequence select="$prmTopicContent/child::*[contains(@class, ' topic/title ')][1]"/>
        </xsl:variable>
        
        <xsl:variable name="titleContent" as="node()*">
            <xsl:apply-templates select="$title" mode="GET_CONTENTS"/>
        </xsl:variable>
        
        <xsl:variable name="titlePrefix" as="xs:string">
            <xsl:choose>
                <xsl:when test="$titleMode eq $cSquareBulletTitleMode">
                    <xsl:call-template name="getVarValueWithLang">
                        <xsl:with-param name="prmVarName" select="'Level4_Label_Char'"/>
                        <xsl:with-param name="prmElem" select="$title"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:when test="$titleMode eq $cRoundBulletTitleMode">
                    <xsl:call-template name="getVarValueWithLang">
                        <xsl:with-param name="prmVarName" select="'Level5_Label_Char'"/>
                        <xsl:with-param name="prmElem" select="$title"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:when test="$pAddNumberingTitlePrefix">
                    <xsl:call-template name="genTitlePrefix">
                        <xsl:with-param name="prmTopicRef" select="$prmTopicRef"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="''"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <!-\- Generate FO for link line -\->
        <xsl:choose>
            <xsl:when test="($titleMode eq $cSquareBulletTitleMode) or ($titleMode eq $cRoundBulletTitleMode)">
                <!-\- Link line for square/round bullet item -\->
                <fo:basic-link internal-destination="{$topicId}">
                    <fo:inline>
                        <xsl:attribute name="font-family">
                            <xsl:call-template name="getVarValueWithLang">
                                <xsl:with-param name="prmVarName" select="'General_Bullet_Font'"/>
                                <xsl:with-param name="prmElem" select="$title"/>
                            </xsl:call-template>
                        </xsl:attribute>
                        <xsl:value-of select="$titlePrefix"/>
                    </fo:inline>
                    <xsl:text>&#x2002;</xsl:text>
                    <xsl:copy-of select="$titleContent"/>
                    <xsl:call-template name="getVarValueWithLang">
                        <xsl:with-param name="prmVarName" select="'Relatedlink_Prefix'"/>
                        <xsl:with-param name="prmElem" select="$prmRelatedLinks"/>
                    </xsl:call-template>
                    <fo:page-number-citation ref-id="{$topicId}"/>
                    <xsl:call-template name="getVarValueWithLang">
                        <xsl:with-param name="prmVarName" select="'Relatedlink_Suffix'"/>
                        <xsl:with-param name="prmElem" select="$prmRelatedLinks"/>
                    </xsl:call-template>
                </fo:basic-link>
            </xsl:when>
            <xsl:otherwise>
                <!-\- Link line for normal numbered item -\->
                <fo:basic-link internal-destination="{$topicId}">
                    <xsl:value-of select="$titlePrefix"/>
                    <xsl:if test="string($titlePrefix)">
                        <xsl:text>&#x2002;</xsl:text>
                    </xsl:if>
                    <xsl:copy-of select="$titleContent"/>
                    <xsl:call-template name="getVarValueWithLang">
                        <xsl:with-param name="prmVarName" select="'Relatedlink_Prefix'"/>
                        <xsl:with-param name="prmElem" select="$prmRelatedLinks"/>
                    </xsl:call-template>
                    <fo:page-number-citation ref-id="{$topicId}"/>
                    <xsl:call-template name="getVarValueWithLang">
                        <xsl:with-param name="prmVarName" select="'Relatedlink_Suffix'"/>
                        <xsl:with-param name="prmElem" select="$prmRelatedLinks"/>
                    </xsl:call-template>
                </fo:basic-link>
            </xsl:otherwise>
        </xsl:choose-->
    </xsl:template>
    
    
    <!-- 
     function:	Edit link line for outside link
     param:		prmHref, prmLinktext
     return:	reference line contentes
     note:		ADD: Link to PDF named destination
                2010/12/15 t.makita
     -->
    <xsl:template name="editLinkOutside">
        <xsl:param name="prmHref"     required="yes" as="xs:string"/>
        <xsl:param name="prmLinktext" required="yes" as="node()*"/>
        
        <!--xsl:variable name="href" select="lower-case(normalize-space($prmHref))" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="$href=$cDeadLinkPDF">
                <!-\- Evidence of dead link -\->
                <xsl:attribute name="color">
                    <xsl:value-of select="$cDeadLinkColor"/>
                </xsl:attribute>
                <xsl:copy-of select="$prmLinktext"/>
            </xsl:when>
            <xsl:when test="contains(lower-case($href),'.pdf#')">
                <!-\- Link to PDF named destination -\->
                <xsl:variable name="tempHref" as="xs:string" select="replace($prmHref,'#','#nameddest=')"/>
                <fo:basic-link external-destination="{$tempHref}" axf:action-type="gotor">
                    <xsl:value-of select="$prmLinktext"/>
                </fo:basic-link>
            </xsl:when>
            <xsl:otherwise>
                <fo:basic-link external-destination="{$prmHref}">
                    <xsl:copy-of select="$prmLinktext"/>
                </fo:basic-link>
            </xsl:otherwise>
        </xsl:choose-->
    </xsl:template>
    
    <!-- END OF STYLESHEET -->

</xsl:stylesheet>