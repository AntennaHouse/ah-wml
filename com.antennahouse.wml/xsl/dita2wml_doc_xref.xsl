<?xml version="1.0" encoding="UTF-8"?>
<!--
**************************************************************
DITA to WordprocessingML Stylesheet
Document.xml Xref element Templates
**************************************************************
File Name : dita2wml_document_xref.xsl
**************************************************************
Copyright © 2009-2017 Antenna House, Inc. All rights reserved.
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
     function:	Xref processing
     param:		prmRunProps (tunnel)
     return:	w:r with field
     note:		The xref target is already searched in dita2wml_global_bookmark.xsl
     -->
    <xsl:template match="*[contains(@class,' topic/xref ')]">
        <xsl:param name="prmRunProps" tunnel="yes" required="no" as="element()*" select="()"/>
        <xsl:variable name="xref" as="element()" select="."/>
        <xsl:variable name="href" as="xs:string" select="string(@href)"/>
        <xsl:variable name="isInternalLink" as="xs:boolean" select="starts-with($href,'#')"/>
        <xsl:choose>
            <!-- Internal link -->
            <xsl:when test="$isInternalLink">
                <xsl:variable name="targetElemInfo" as="item()*" select="map:get($bookmarkTargetMap,$href)"/>
                <xsl:variable name="targetId" as="xs:string?" select="$targetElemInfo[1]"/>
                <xsl:variable name="targetElem" as="element()?" select="$targetElemInfo[2]"/>
                <xsl:variable name="targetTopic" as="element()?" select="$targetElem/ancestor-or-self::*[contains(@class,' topic/topic ')][last()]"/>
                <xsl:variable name="topicRef" as="element()?" select="ahf:getTopicRef($targetTopic)"/>
                <xsl:variable name="targetElemNumber" as="xs:integer?" select="map:get($targetElemIdAndNumberMap,$targetId)"/>
                <xsl:choose>
                    <xsl:when test="empty($targetElemInfo) or not(string($targetId))">
                        <xsl:call-template name="warningContinue">
                            <xsl:with-param name="prmMes" select="ahf:replace($stMes2032,('%xref','%href'),(ahf:getNodeXPathStr(.),$href))"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:choose>
                            <!-- Reference to topic -->
                            <xsl:when test="$targetElem[contains(@class,' topic/topic ')]">
                                <xsl:variable name="titlePrefix" as="xs:string">
                                    <xsl:call-template name="genTitlePrefix">
                                        <xsl:with-param name="prmTopicRef" select="$topicRef"/>
                                    </xsl:call-template>                                        
                                </xsl:variable>
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
                                        <xsl:with-param name="prmDst" select="(ahf:genBookmarkName($targetElemNumber),'\w',$titlePrefixResult)"/>
                                    </xsl:call-template>
                                    <w:r>
                                        <w:t xml:space="preserve"> </w:t>
                                    </w:r>
                                </xsl:if>
                                <xsl:variable name="title" as="node()*">
                                    <xsl:apply-templates select="$targetElem/*[contains(@class,' topic/title ')]/node()">
                                        <xsl:with-param name="prmSkipBookmark" tunnel="yes" select="true()"/>
                                        <xsl:with-param name="prmSkipFn"       tunnel="yes" select="true()"/>
                                    </xsl:apply-templates>
                                </xsl:variable>
                                <xsl:call-template name="getWmlObjectReplacing">
                                    <xsl:with-param name="prmObjName" select="'wmlRefField'"/>
                                    <xsl:with-param name="prmSrc" select="('%ref-id','%field-opt','node:field-result')"/>
                                    <xsl:with-param name="prmDst" select="(ahf:genBookmarkName($targetElemNumber),'',$title)"/>
                                </xsl:call-template>
                            </xsl:when>

                            <!-- Reference to example, section -->
                            <xsl:when test="$targetElem[ahf:seqContains(@class,(' topic/section ',' topic/example '))][exists(*[contains(@class,' topic/title ')])]">
                                <xsl:variable name="title" as="node()*">
                                    <xsl:apply-templates select="$targetElem/*[contains(@class,' topic/title ')]/node()">
                                        <xsl:with-param name="prmSkipBookmark" tunnel="yes" select="true()"/>
                                        <xsl:with-param name="prmSkipFn"       tunnel="yes" select="true()"/>
                                    </xsl:apply-templates>
                                </xsl:variable>
                                <xsl:call-template name="getWmlObjectReplacing">
                                    <xsl:with-param name="prmObjName" select="'wmlRefField'"/>
                                    <xsl:with-param name="prmSrc" select="('%ref-id','%field-opt','node:field-result')"/>
                                    <xsl:with-param name="prmDst" select="(ahf:genBookmarkName($targetElemNumber),'',$title)"/>
                                </xsl:call-template>
                            </xsl:when>

                            <!-- Reference to table -->
                            <xsl:when test="$targetElem[contains(@class,(' topic/table '))][exists(*[contains(@class,' topic/title ')])]">
                                <xsl:variable name="targetTableTitleResultWithField" as="document-node()">
                                    <xsl:document>
                                        <xsl:call-template name="ahf:getTableTitlePrefix">
                                            <xsl:with-param name="prmTable" select="$targetElem/parent::*"/>
                                            <xsl:with-param name="prmTopicRef" tunnel="yes" select="$topicRef"/>
                                        </xsl:call-template>
                                        <xsl:apply-templates select="$targetElem/*[contains(@class,' topic/title ')]/node()">
                                            <xsl:with-param name="prmTopicRef" tunnel="yes" select="$topicRef"/>
                                            <xsl:with-param name="prmSkipBookmark" tunnel="yes" select="true()"/>
                                            <xsl:with-param name="prmSkipFn"       tunnel="yes" select="true()"/>
                                        </xsl:apply-templates>
                                    </xsl:document>
                                </xsl:variable>
                                <xsl:variable name="targetTableTitleResult" as="document-node()">
                                    <xsl:document>
                                        <xsl:copy-of select="$targetTableTitleResultWithField/w:r[exists(w:t)]"/>
                                    </xsl:document>
                                </xsl:variable>
                                <xsl:call-template name="getWmlObjectReplacing">
                                    <xsl:with-param name="prmObjName" select="'wmlRefField'"/>
                                    <xsl:with-param name="prmSrc" select="('%ref-id','%field-opt','node:field-result')"/>
                                    <xsl:with-param name="prmDst" select="(ahf:genBookmarkName($targetElemNumber),'',$targetTableTitleResult)"/>
                                </xsl:call-template>
                            </xsl:when>
                            
                            <!-- Reference to fig -->
                            <xsl:when test="$targetElem[contains(@class,' topic/fig ')][exists(*[contains(@class,' topic/title ')])]">
                                <xsl:variable name="targetFigTitleResultWithField" as="document-node()">
                                    <xsl:document>
                                        <xsl:call-template name="ahf:getFigTitlePrefix">
                                            <xsl:with-param name="prmFig" select="$targetElem/parent::*"/>
                                            <xsl:with-param name="prmTopicRef" tunnel="yes" select="$topicRef"/>
                                        </xsl:call-template>
                                        <xsl:apply-templates select="$targetElem/*[contains(@class,' topic/title ')]/node()">
                                            <xsl:with-param name="prmTopicRef" tunnel="yes" select="$topicRef"/>
                                            <xsl:with-param name="prmSkipBookmark" tunnel="yes" select="true()"/>
                                            <xsl:with-param name="prmSkipFn"       tunnel="yes" select="true()"/>
                                        </xsl:apply-templates>
                                    </xsl:document>
                                </xsl:variable>
                                <xsl:variable name="targetFigTitleResult" as="document-node()">
                                    <xsl:document>
                                        <xsl:copy-of select="$targetFigTitleResultWithField/w:r[exists(w:t)]"/>
                                    </xsl:document>
                                </xsl:variable>
                                <xsl:call-template name="getWmlObjectReplacing">
                                    <xsl:with-param name="prmObjName" select="'wmlRefField'"/>
                                    <xsl:with-param name="prmSrc" select="('%ref-id','%field-opt','node:field-result')"/>
                                    <xsl:with-param name="prmDst" select="(ahf:genBookmarkName($targetElemNumber),'',$targetFigTitleResult)"/>
                                </xsl:call-template>
                            </xsl:when>
                            
                            <!-- Reference to ol/li
                                 You can change field result such as multi-level format "1.-a" by setting %field-opt as '\w \d -' instead of "\r'.
                                 Also the actual filed reslult should be changed to generate "1.-a".
                                 Varibale 'Ol_Number_Formats' must be changed according to the ol/li style.
                             -->
                            <xsl:when test="$targetElem[contains(@class,' topic/li ')][ancestor::*[contains(@class,' topic/ol ')]]">
                                <xsl:variable name="olNumberFormat" as="xs:string*">
                                    <xsl:variable name="olNumberFormats" as="xs:string">
                                        <xsl:call-template name="getVarValueWithLang">
                                            <xsl:with-param name="prmVarName" select="'Ol_Number_Formats'"/>
                                            <xsl:with-param name="prmElem" select="$targetElem"/>
                                        </xsl:call-template>
                                    </xsl:variable>
                                    <xsl:for-each select="tokenize($olNumberFormats, '[\s]+')">
                                        <xsl:sequence select="."/>
                                    </xsl:for-each>
                                </xsl:variable>
                                <xsl:variable name="olFormat" as="xs:string" select="ahf:getOlNumberFormat($targetElem,$olNumberFormat)"/>
                                <xsl:variable name="liNumber" as="xs:integer" select="count($targetElem|$targetElem/preceding-sibling::*[not(contains(@class,' task/stepsection '))])"/>
                                <xsl:variable name="targetLi" as="element(w:r)">
                                    <w:r>
                                        <w:t>
                                            <xsl:number format="{$olFormat}" value="$liNumber"/>
                                        </w:t>
                                    </w:r>
                                </xsl:variable>
                                <xsl:call-template name="getWmlObjectReplacing">
                                    <xsl:with-param name="prmObjName" select="'wmlRefField'"/>
                                    <xsl:with-param name="prmSrc" select="('%ref-id','%field-opt','node:field-result')"/>
                                    <xsl:with-param name="prmDst" select="(ahf:genBookmarkName($targetElemNumber),'\r',$targetLi)"/>
                                </xsl:call-template>
                            </xsl:when>
                            
                            <!-- Reference to fn -->
                            <xsl:when test="$targetElem[contains(@class,' topic/fn ')]">
                                <xsl:variable name="key" as="xs:string" select="ahf:generateId($targetElem)"/>
                                <xsl:variable name="fnId" as="xs:integer?" select="map:get($fnIdMap,$key)[1]"/>
                                <xsl:assert test="exists($fnId)" select="'[fn] key=',$key,' does not exists is $fnIdMap key=',ahf:mapKeyDump($fnIdMap)"/>
                                <xsl:variable name="isFirstXrefToFn" as="xs:boolean">
                                    <xsl:variable name="sameXrefs" as="element()+" select="$topic/descendant::*[contains(@class,' topic/xref ')][string(@href) eq $href]"/>
                                    <xsl:sequence select="$sameXrefs[1] is $xref"/> 
                                </xsl:variable>
                                <xsl:choose>
                                    <!-- Generate w:footnoteReference from first xref to fn -->
                                    <xsl:when test="$isFirstXrefToFn">
                                        <xsl:copy-of select="ahf:genBookmarkStart($targetElem)"/>
                                        <w:r>
                                            <w:rPr>
                                                <w:rStyle w:val="{ahf:getStyleIdFromName('footnote reference')}"/>
                                                <xsl:copy-of select="$prmRunProps"/>
                                            </w:rPr>
                                            <xsl:choose>
                                                <xsl:when test="$targetElem/@callout">
                                                    <w:footnoteReference w:customMarkFollows="1" w:id="{string($fnId)}"/>
                                                    <w:t xml:space="preserve"><xsl:value-of select="$targetElem/@callout"/></w:t>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <w:footnoteReference w:id="{string($fnId)}"/>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </w:r>
                                        <xsl:copy-of select="ahf:genBookmarkEnd($targetElem)"/>
                                    </xsl:when>
                                    <!-- Generate NOTEREF field from remaining xref to fn
                                         The field result is determined by Word using Ctrl + A & F9
                                      -->
                                    <xsl:otherwise>
                                        <xsl:call-template name="getWmlObjectReplacing">
                                            <xsl:with-param name="prmObjName" select="'wmlNoteRefField'"/>
                                            <xsl:with-param name="prmSrc" select="('%bookmark','%field-opt')"/>
                                            <xsl:with-param name="prmDst" select="(ahf:genBookmarkName($targetElemNumber),'\f')"/>
                                        </xsl:call-template>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:otherwise>
                                <!-- Not Yet Implemented -->
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <!-- External link -->
                <xsl:variable name="rId" as="xs:string" select="concat('rId',map:get($externalLinkIdMap,$href))"/>
                <w:hyperlink r:id="{$rId}" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">
                    <xsl:apply-templates>
                        <xsl:with-param name="prmRunProps" tunnel="yes" as="element()*">
                            <w:rStyle w:val="{ahf:getStyleIdFromName('Hyperlink')}"/>
                        </xsl:with-param>
                    </xsl:apply-templates>
                </w:hyperlink>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- 
     function:	Get ol number format
     param:		prmOl, prmOlNumberFormat
     return:	Number format string
     note:		Count ol in entry/note independently.
                2015-06-03 t.makita
     -->
    <xsl:function name="ahf:getOlNumberFormat" as="xs:string">
        <xsl:param name="prmOl" as="element()"/>
        <xsl:param name="prmOlNumberFormat" as="xs:string+"/>
        
        <xsl:variable name="olNumberFormatCount" as="xs:integer" select="count($prmOlNumberFormat)"/>
        <xsl:variable name="olNestLevel" select="ahf:countOl($prmOl,0)" as="xs:integer"/>
        <xsl:variable name="formatOrder" as="xs:integer">
            <xsl:variable name="tempFormatOrder" as="xs:integer" select="$olNestLevel mod $olNumberFormatCount"/>
            <xsl:sequence select="if ($tempFormatOrder eq 0) then $olNumberFormatCount else $tempFormatOrder"/>
        </xsl:variable>
        <xsl:sequence select="$prmOlNumberFormat[$formatOrder]"/>
    </xsl:function>
    
    <xsl:function name="ahf:countOl" as="xs:integer">
        <xsl:param name="prmElement" as="element()"/>
        <xsl:param name="prmCount" as="xs:integer"/>
        
        <xsl:variable name="count" select="if ($prmElement[contains(@class, ' topic/ol ')]) then ($prmCount+1) else $prmCount"/>
        <xsl:choose>
            <xsl:when test="$prmElement[contains(@class, ' topic/entry ')]">
                <xsl:sequence select="$count"/>
            </xsl:when>
            <xsl:when test="$prmElement[contains(@class, ' topic/note ')]">
                <xsl:sequence select="$count"/>
            </xsl:when>
            <xsl:when test="$prmElement/parent::*">
                <xsl:sequence select="ahf:countOl($prmElement/parent::*, $count)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="$count"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!-- 
     function:	Generate bookmark name 
     param:		prmSeq
     return:	xs:string
     note:		
     -->
    <xsl:param name="prmBooknamePrefix" as="xs:string" select="'Ref_'"/>
    
    <xsl:function name="ahf:genBookmarkName" as="xs:string">
        <xsl:param name="prmSeq" as="xs:integer"/>
        <xsl:sequence select="concat($prmBooknamePrefix,format-number($prmSeq,'00000'))"/>
    </xsl:function>
    
    <!-- 
     function:	Generate bookmark start
     param:		prmElem
     return:	element()?
     note:		
     -->
    <xsl:function name="ahf:genBookmarkStart" as="element()?">
        <xsl:param name="prmElem" as="element()"/>
        <xsl:variable name="id" as="xs:string" select="ahf:generateId($prmElem)"/>
        <xsl:variable name="seq" as="xs:integer?" select="map:get($targetElemIdAndNumberMap,$id)"/>
        <xsl:choose>
            <xsl:when test="exists($seq)">
                <w:bookmarkStart w:id="{$seq}" w:name="{ahf:genBookmarkName($seq)}"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:template name="genBookmarkStart" as="element()?">
        <xsl:param name="prmElem" as="element()" required="no" select="."/>
        <xsl:param name="prmSkipBookmark" as="xs:boolean" tunnel="yes" required="no" select="false()"/>
        <xsl:choose>
            <xsl:when test="$prmSkipBookmark">
                <xsl:sequence select="()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="ahf:genBookmarkStart($prmElem)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="genBookmarkStartWithNull" as="element()">
        <xsl:param name="prmElem" as="element()" required="no" select="."/>
        <xsl:param name="prmSkipBookmark" as="xs:boolean" tunnel="yes" required="no" select="false()"/>
        <xsl:choose>
            <xsl:when test="$prmSkipBookmark">
                <xsl:sequence select="$cElemNull"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="bmStart" as="element()?" select="ahf:genBookmarkStart($prmElem)"/>
                <xsl:sequence select="if (exists($bmStart)) then $bmStart else $cElemNull"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- 
     function:	Generate bookmark end
     param:		prmElem
     return:	element()?
     note:		
     -->
    <xsl:function name="ahf:genBookmarkEnd" as="element()?">
        <xsl:param name="prmElem" as="element()"/>
        <xsl:variable name="id" as="xs:string" select="ahf:generateId($prmElem)"/>
        <xsl:variable name="seq" as="xs:integer?" select="map:get($targetElemIdAndNumberMap,$id)"/>
        <xsl:choose>
            <xsl:when test="exists($seq)">
                <w:bookmarkEnd w:id="{$seq}"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:template name="genBookmarkEnd" as="element()?">
        <xsl:param name="prmElem" as="element()" required="no" select="."/>
        <xsl:param name="prmSkipBookmark" as="xs:boolean" tunnel="yes" required="no" select="false()"/>
        <xsl:choose>
            <xsl:when test="$prmSkipBookmark">
                <xsl:sequence select="()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="ahf:genBookmarkEnd($prmElem)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="genBookmarkEndWithNull" as="element()">
        <xsl:param name="prmElem" as="element()" required="no" select="."/>
        <xsl:param name="prmSkipBookmark" as="xs:boolean" tunnel="yes" required="no" select="false()"/>
        <xsl:choose>
            <xsl:when test="$prmSkipBookmark">
                <xsl:sequence select="$cElemNull"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="bmEnd" as="element()?" select="ahf:genBookmarkEnd($prmElem)"/>
                <xsl:sequence select="if (exists($bmEnd)) then $bmEnd else $cElemNull"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- 
     function:	Get bookmark name
     param:		prmElem
     return:	xs:string
     note:		
     -->
    <xsl:function name="ahf:getBookmarkName" as="xs:string?">
        <xsl:param name="prmElem" as="element()"/>
        <xsl:variable name="id" as="xs:string" select="ahf:generateId($prmElem)"/>
        <xsl:variable name="seq" as="xs:integer?" select="map:get($targetElemIdAndNumberMap,$id)"/>
        <xsl:choose>
            <xsl:when test="exists($seq)">
                <xsl:sequence select="ahf:genBookmarkName($seq)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:template name="getBookmarkName" as="xs:string">
        <xsl:param name="prmElem" as="element()" required="no" select="."/>
        <xsl:copy-of select="ahf:getBookmarkName($prmElem)"/>
    </xsl:template>

    <!-- 
     function:	xref/desc template
     param:		
     return:	
     note:		Don't generate <p>. This is inline element.
     -->
    <xsl:template match="*[contains(@class,' topic/xref ')]/*[contains(@class,' topic/desc ')]">
        <xsl:apply-templates/>
    </xsl:template>
    
    <!-- END OF STYLESHEET -->

</xsl:stylesheet>