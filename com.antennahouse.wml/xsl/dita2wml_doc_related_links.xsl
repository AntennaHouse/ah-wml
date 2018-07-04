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
    
    <!-- 
     function:	Judge target link
     param:		prmLink
     return:	xs:boolean
     note:		parent, child links are ignored. 
     -->
    <xsl:function name="ahf:isTargetLink" as="xs:boolean">
        <xsl:param name="prmLink" as="element()"/>
        <xsl:sequence select="string($prmLink/@role) = ('friend','other','')"/>
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
        <xsl:call-template name="makeRelatedLinksTitleLine"/>
            
        <!-- process link -->
        <xsl:call-template name="processLink">
            <xsl:with-param name="prmRelatedLinks" select="$prmRelatedLinks"/>
        </xsl:call-template>
        
        <!-- Make related-link end block -->
        <xsl:call-template name="makeRelatedLinksUnderLine"/>
    </xsl:template>

    <!-- 
     function:	Make related-links title line
     param:		none
     return:	w:p
     note:		Current context is related-links
     -->
    <xsl:template name="makeRelatedLinksTitleLine" as="element(w:p)">
        
        <!-- Get underline end position -->
        <xsl:variable name="lineEndPosInTwip" as="xs:integer" select="ahf:getLineEndPosInTwip(.)"/>

        <!-- Relatd-links title -->
        <xsl:variable name="title" as="xs:string">
            <xsl:call-template name="getVarValueWithLang">
                <xsl:with-param name="prmVarName" select="'Relatedlink_Title'"/>
            </xsl:call-template>
        </xsl:variable>

        <xsl:call-template name="getWmlObjectReplacing">
            <xsl:with-param name="prmObjName" select="'wmlRelatedLinksTitle'"/>
            <xsl:with-param name="prmSrc" select="('%title','%end-pos')"/>
            <xsl:with-param name="prmDst" select="($title,string($lineEndPosInTwip))"/>
        </xsl:call-template>
        
    </xsl:template>
    
    <!-- 
     function:	Make related-links under line
     param:		
     return:	w:p
     note:		Current context is related-links
     -->
    <xsl:template name="makeRelatedLinksUnderLine" as="element(w:p)">
        
        <!-- Get underline end position -->
        <xsl:variable name="lineEndPosInTwip" as="xs:integer" select="ahf:getLineEndPosInTwip(.)"/>
        
        <xsl:call-template name="getWmlObjectReplacing">
            <xsl:with-param name="prmObjName" select="'wmlRelatedLinksUnderLine'"/>
            <xsl:with-param name="prmSrc" select="('%end-pos')"/>
            <xsl:with-param name="prmDst" select="(string($lineEndPosInTwip))"/>
        </xsl:call-template>
        
    </xsl:template>

    <!-- 
     function:	Process link
     param:		prmRelatedLinks
     return:	reference line contentes
     note:		none
     -->
    <xsl:template name="processLink">
        <xsl:param name="prmRelatedLinks" required="yes" as="element()"/>
        
        <xsl:variable name="contentIndent" as="xs:string">
            <xsl:call-template name="getVarValue">
                <xsl:with-param name="prmVarName" select="'RelatedLinksContentIndent'"/>
            </xsl:call-template>
        </xsl:variable>
        
        <xsl:for-each select="$prmRelatedLinks/descendant::*[contains(@class,' topic/link ')][ahf:isTargetLink(.)]">
            <xsl:variable name="link" select="." as="element()"/>
            <xsl:variable name="href" select="string($link/@href)" as="xs:string"/>
            <xsl:variable name="ohref" select="string($link/@ohref)" as="xs:string"/>
            <xsl:variable name="xtrf"  select="string($link/@xtrf)" as="xs:string"/>
            <xsl:variable name="linktext" as="node()*">
                <xsl:call-template name="getContentsRestricted">
                    <xsl:with-param name="prmElem" select="$link/linktext"/>
                    <xsl:with-param name="prmRunProps" tunnel="yes" select="()"/>
                </xsl:call-template>
            </xsl:variable>
            <xsl:variable name="isLinkInside" as="xs:boolean" select="starts-with($href,'#')"/>
            <xsl:variable name="topic" as="element()?" select="if ($isLinkInside) then ahf:getTopicFromLink($link) else ()"/>
            <xsl:variable name="topicRef" as="element()?" select="if (exists($topic)) then ahf:getTopicRef($topic) else ()"/>
            <xsl:variable name="topicTitle" as="element()?" select="if (exists($topic)) then $topic/child::*[contains(@class,' topic/title ')][1] else ()"/>

            <xsl:choose>
                <xsl:when test="$isLinkInside">
                    <xsl:choose>
                        <xsl:when test="empty($topic)">
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
                                <xsl:with-param name="prmTopic"        select="$topic"/>
                                <xsl:with-param name="prmRelatedLinks" select="$prmRelatedLinks"/>
                                <xsl:with-param name="prmIndentLevel" tunnel="yes" select="0"/>
                                <xsl:with-param name="prmExtraIndent" tunnel="yes" select="ahf:toTwip($contentIndent)"/>
                            </xsl:call-template>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="editLinkOutside">
                        <xsl:with-param name="prmHref" select="$href"/>
                        <xsl:with-param name="prmLinkText" select="$linktext"/>
                        <xsl:with-param name="prmIndentLevel" tunnel="yes" select="0"/>
                        <xsl:with-param name="prmExtraIndent" tunnel="yes" select="ahf:toTwip($contentIndent)"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>
    
    <!-- 
     function:	Edit reference line for internal link to topic
     param:		prmTopicRef, prmTopicContent
     return:	reference line contentes
     note:		
     -->
    <xsl:template name="editLinkInside">
        <xsl:param name="prmTopicRef"     required="yes" as="element()"/>
        <xsl:param name="prmTopic"        required="yes" as="element()"/>
        <xsl:param name="prmRelatedLinks" required="yes" as="element()"/>
        <xsl:param name="prmIndentLevel" tunnel="yes" required="yes" as="xs:integer"/>
        <xsl:param name="prmExtraIndent" tunnel="yes" required="yes" as="xs:integer"/>
        
        <xsl:variable name="targetElemNumber" as="xs:integer?" select="map:get($targetElemIdAndNumberMap,generate-id($prmTopic))"/>
        <xsl:assert test="exists($targetElemNumber)" select="'[editLinkInside] Target is not defined',ahf:generateId($prmTopic)"/>
        <xsl:variable name="titleResult" as="element(w:r)*">
            <xsl:variable name="titlePrefix" as="xs:string">
                <xsl:call-template name="genTitlePrefix">
                    <xsl:with-param name="prmTopicRef" select="$prmTopicRef"/>
                </xsl:call-template>                                        
            </xsl:variable>
            <xsl:if test="$pAddChapterNumberPrefixToTopicTitle and string($titlePrefix)">
                <w:r>
                    <w:t>
                        <xsl:value-of select="$titlePrefix"/>
                    </w:t>
                </w:r>
            </xsl:if>
            <xsl:call-template name="getContentsRestricted">
                <xsl:with-param name="prmElem" select="$prmTopic/*[contains(@class,' topic/title ')][1]"/> 
                <xsl:with-param name="prmRunProps" tunnel="yes" select="()"/>
            </xsl:call-template>
        </xsl:variable>
        <w:p>
            <w:pPr>
                <w:pStyle w:val="{ahf:getStyleIdFromName('related-links')}"/>
                <xsl:copy-of select="ahf:getIndentAttrElem($prmIndentLevel,$prmExtraIndent)"/>
            </w:pPr>
            <xsl:call-template name="getWmlObjectReplacing">
                <xsl:with-param name="prmObjName" select="'wmlRefField'"/>
                <xsl:with-param name="prmSrc" select="('%ref-id','%field-opt','node:field-result')"/>
                <xsl:with-param name="prmDst" select="(ahf:genBookmarkName($targetElemNumber),'\w',$titleResult)"/>
            </xsl:call-template>
        </w:p>
    </xsl:template>
    
    <!-- 
     function:	Edit link line for outside link
     param:		prmHref, prmLinktext
     return:	reference line contentes
     note:		
     -->
    <xsl:template name="editLinkOutside">
        <xsl:param name="prmHref"     required="yes" as="xs:string"/>
        <xsl:param name="prmLinkText" required="yes" as="node()*"/>
        <xsl:param name="prmIndentLevel" tunnel="yes" required="yes" as="xs:integer"/>
        <xsl:param name="prmExtraIndent" tunnel="yes" required="yes" as="xs:integer"/>
        
        <xsl:variable name="rId" as="xs:string" select="concat('rId',map:get($externalLinkIdMap,$prmHref))"/>
        <w:p>
            <w:pPr>
                <w:pStyle w:val="{ahf:getStyleIdFromName('related-links')}"/>
                <xsl:copy-of select="ahf:getIndentAttrElem($prmIndentLevel,$prmExtraIndent)"/>
            </w:pPr>
            <w:r>
                <w:hyperlink r:id="{$rId}" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">
                    <xsl:copy-of select="$prmLinkText"/>
                </w:hyperlink>
            </w:r>
        </w:p>

    </xsl:template>
    
    <!-- END OF STYLESHEET -->

</xsl:stylesheet>