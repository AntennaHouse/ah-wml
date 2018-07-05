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
        
        <xsl:if test="ahf:isEffectiveRelatedLinks(.)">
            <xsl:variable name="id" as="xs:string" select="ahf:generateId(.)"/>
            <xsl:variable name="listOccurenceNumber" as="xs:integer?" select="map:get($listNumberMap,$id)"/>
            <xsl:assert test="exists($listOccurenceNumber)" select="'[related-links] id=',$id,' does not exits in $listNumberMap'"/>
            
            <xsl:call-template name="makeRelatedLink">
                <xsl:with-param name="prmRelatedLinks" select="."/>
                <xsl:with-param name="prmListOccurenceNumber" tunnel="yes" select="$listOccurenceNumber"/>
                <xsl:with-param name="prmListLevel" tunnel="yes" select="1"/>
            </xsl:call-template>
        </xsl:if>
        
        <xsl:call-template name="getSectionPropertyElemAfter"/>
        
    </xsl:template>
    
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
                        <xsl:with-param name="prmLink" select="$link"/>
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
        <xsl:param name="prmListOccurenceNumber" tunnel="yes" required="yes" as="xs:integer"/>
        <xsl:param name="prmListLevel" tunnel="yes" required="yes" as="xs:integer"/>
        
        <xsl:variable name="numPr" as="element(w:numPr)">
            <w:numPr>
                <w:ilvl w:val="{string(ahf:getIlvlFromListLevel($prmListLevel))}"/>
                <w:numId w:val="{ahf:getNumIdFromListOccurenceNumber($prmListOccurenceNumber)}"/>
            </w:numPr>
        </xsl:variable>
        <xsl:variable name="titlePrefix" as="xs:string">
            <xsl:call-template name="genTitlePrefix">
                <xsl:with-param name="prmTopicRef" select="$prmTopicRef"/>
            </xsl:call-template>                                        
        </xsl:variable>
        <xsl:variable name="titleResult" as="document-node()">
            <xsl:document>
                <xsl:call-template name="getContentsRestricted">
                    <xsl:with-param name="prmElem" select="$prmTopic/*[contains(@class,' topic/title ')][1]"/> 
                    <xsl:with-param name="prmRunProps" tunnel="yes" select="()"/>
                </xsl:call-template>
            </xsl:document>
        </xsl:variable>
        <xsl:variable name="pagePrefix" as="xs:string">
            <xsl:call-template name="getVarValueWithLang">
                <xsl:with-param name="prmVarName" select="'Xref_Page_Prefix'"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="pageSuffix" as="xs:string">
            <xsl:call-template name="getVarValueWithLang">
                <xsl:with-param name="prmVarName" select="'Xref_Page_Suffix'"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="bookmarkName" as="xs:string?" select="ahf:getBookmarkName($prmTopic)"/>
        
        <w:p>
            <w:pPr>
                <w:pStyle w:val="{ahf:getStyleIdFromName('related-links')}"/>
                <xsl:copy-of select="$numPr"/>
            </w:pPr>
            <xsl:if test="$pAddChapterNumberPrefixToTopicTitle and string($titlePrefix)">
                <xsl:variable name="titlePrefixResult" as="element(w:r)">
                    <w:r>
                        <w:t>
                            <xsl:value-of select="$titlePrefix"/>
                        </w:t>
                    </w:r>
                </xsl:variable>
                <xsl:call-template name="getWmlObjectReplacing">
                    <xsl:with-param name="prmObjName" select="'wmlRefField'"/>
                    <xsl:with-param name="prmSrc" select="('%ref-id','%field-opt','node:field-result')"/>
                    <xsl:with-param name="prmDst" select="($bookmarkName,'\w',$titlePrefixResult)"/>
                </xsl:call-template>
                <w:r>
                    <w:t xml:space="preserve"> </w:t>
                </w:r>
            </xsl:if>
            <xsl:call-template name="getWmlObjectReplacing">
                <xsl:with-param name="prmObjName" select="'wmlRefField'"/>
                <xsl:with-param name="prmSrc" select="('%ref-id','%field-opt','node:field-result')"/>
                <xsl:with-param name="prmDst" select="($bookmarkName,'',$titleResult)"/>
            </xsl:call-template>
            <w:r>
                <w:t xml:space="preserve"><xsl:value-of select="$pagePrefix"/></w:t>
            </w:r>
            <xsl:call-template name="getWmlObjectReplacing">
                <xsl:with-param name="prmObjName" select="'wmlPageRefField'"/>
                <xsl:with-param name="prmSrc" select="('%bookmark','%field-opt')"/>
                <xsl:with-param name="prmDst" select="($bookmarkName,'')"/>
            </xsl:call-template>
            <w:r>
                <w:t xml:space="preserve"><xsl:value-of select="$pageSuffix"/></w:t>
            </w:r>
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
        <xsl:param name="prmLink"     required="yes" as="element()"/>
        <xsl:param name="prmIndentLevel" tunnel="yes" required="yes" as="xs:integer"/>
        <xsl:param name="prmExtraIndent" tunnel="yes" required="yes" as="xs:integer"/>
        <xsl:param name="prmListOccurenceNumber" tunnel="yes" required="yes" as="xs:integer"/>
        <xsl:param name="prmListLevel" tunnel="yes" required="yes" as="xs:integer"/>
        
        <xsl:variable name="linkText" as="node()*">
            <xsl:call-template name="getContentsRestricted">
                <xsl:with-param name="prmElem" select="$prmLink/linktext"/>
                <xsl:with-param name="prmRunProps" tunnel="yes" select="()"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="rId" as="xs:string" select="concat('rId',map:get($externalLinkIdMap,$prmHref))"/>
        <xsl:variable name="numPr" as="element(w:numPr)">
            <w:numPr>
                <w:ilvl w:val="{string(ahf:getIlvlFromListLevel($prmListLevel))}"/>
                <w:numId w:val="{ahf:getNumIdFromListOccurenceNumber($prmListOccurenceNumber)}"/>
            </w:numPr>
        </xsl:variable>
        <w:p>
            <w:pPr>
                <w:pStyle w:val="{ahf:getStyleIdFromName('related-links')}"/>
                <xsl:copy-of select="$numPr"/>
            </w:pPr>
            <w:r>
                <w:hyperlink r:id="{$rId}" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">
                    <xsl:copy-of select="$linkText"/>
                </w:hyperlink>
            </w:r>
        </w:p>
    </xsl:template>
    
    <!-- END OF STYLESHEET -->

</xsl:stylesheet>