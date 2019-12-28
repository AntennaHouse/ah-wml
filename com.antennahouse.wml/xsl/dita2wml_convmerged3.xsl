<?xml version='1.0' encoding="UTF-8" ?>
<!--
****************************************************************
DITA to WordprocessingML Stylesheet
Module: Merged file conversion templates (3)
Copyright © 2009-2017 Antenna House, Inc. All rights reserved.
Antenna House is a trademark of Antenna House, Inc.
URL    : http://www.antennahouse.com/
E-mail : info@antennahouse.com
****************************************************************
-->
<xsl:stylesheet version="3.0" 
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:xs="http://www.w3.org/2001/XMLSchema"
 xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
 exclude-result-prefixes="xs ahf"
>
    <!-- This stylesheet has following functions:
         1. Remove redundant white space text nodes.
         2. Generate <p> from sequence of raw text and inline elements located in block level element.
         3. Format <indextrm> to generate XE field easily in the following step.
     -->
    
    <!-- generate <p> element -->
    <xsl:variable name="pAttr" as="attribute()">
        <xsl:attribute name="class" select="'- topic/p '"/>
    </xsl:variable>

    <!-- 
     function:	General template
     param:		none
     return:	self and under-laying node
     note:		
     -->
    <xsl:template match="*" name="generalElementProcessing">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="@*">
        <xsl:choose>
            <xsl:when test="$pDebugMerged">
                <xsl:if test="not(name() = ('xtrc','xtrf','domains'))">
                    <xsl:copy/>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Copy processing-instruction or comment or text in other pattern -->
    <xsl:template match="node()" priority="-10">
        <!--xsl:message select="'Unmatched node=','''',.,''''"/-->
        <xsl:copy/>
    </xsl:template>

    <!-- 
     function:	Elements that should generate <p> from child text
                and process block level elements.
     param:		none
     return:	<p> or block element
     note:		Group node() whether it is block or not.
                1. Generate <p>...</p> from the chunk of inline elements and text supressing leading, trailing white spaces.
                2. If there is child block element, apply underlaying templates for them.
                3. If matched element is <p>, it is removed from output and genrate elements applying above rule.
     -->
    <xsl:template match="*[ahf:isMixedContentElement(.)]" name="processBlocAndInlineContentElements" priority="5">
        <xsl:variable name="elem" as="element()" select="."/>
        <xsl:variable name="isP" as="xs:boolean" select="@class => contains-token('topic/p')"/>
        <xsl:choose>
            <xsl:when test="$isP">
                <!-- Matched <p> element. The <p> itself is removed from output.-->
                <xsl:for-each-group select="child::node()" group-adjacent="ahf:isBlockElement(.)">
                    <xsl:choose>
                        <xsl:when test="current-grouping-key()">
                            <!-- block elements -->
                            <xsl:apply-templates select="current-group()"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <!-- inline elements -->
                            <xsl:choose>
                                <xsl:when test="(count(current-group()) eq 1) and not(current-group()/self::*) and (not(string(normalize-space(current-group()[1])))) and empty(current-group()[1]/self::element())">
                                    <!-- ignore redundant text node! -->
                                </xsl:when>
                                <xsl:otherwise>
                                    <!-- Generate paragraph from inline -->
                                    <p>
                                        <xsl:copy-of select="$pAttr"/>
                                        <xsl:if test="position() eq 1">
                                            <xsl:copy-of select="parent::*/@*"/>
                                        </xsl:if>
                                        <xsl:call-template name="ahf:processInline">
                                            <xsl:with-param name="prmInline" select="current-group()"/>
                                        </xsl:call-template>
                                    </p>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each-group>
            </xsl:when>
            <xsl:otherwise>
                <!-- Other block or wrapper elements -->
                <xsl:copy>
                    <xsl:apply-templates select="@*"/>
                    <xsl:for-each-group select="child::node()" group-adjacent="ahf:isBlockElement(.)">
                        <xsl:choose>
                            <xsl:when test="current-grouping-key()">
                                <!-- block elements -->
                                <xsl:apply-templates select="current-group()"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <!-- inline elements -->
                                <xsl:choose>
                                    <xsl:when test="(count(current-group()) eq 1) and (not(string(normalize-space(current-group()[1]))))">
                                        <!-- ignore! -->
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <!-- Parent is non-paragraph block elements -->
                                        <p>
                                            <xsl:copy-of select="$pAttr"/>
                                            <xsl:if test="position() eq 1">
                                                <!--copy @outputclass to handle breaking --> 
                                                <xsl:copy-of select="./parent::*/@outputclass"/>
                                            </xsl:if>
                                            <xsl:call-template name="ahf:processInline">
                                                <xsl:with-param name="prmInline" select="current-group()"/>
                                            </xsl:call-template>
                                        </p>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:for-each-group>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- 
     function:	Process inline element
     param:		none
     return:	inline nodes
     note:		
     -->
    <xsl:template match="*[ahf:isPContentElement(.)]" name="processInlineContentElement" priority="5">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:if test="exists(node())">
                <xsl:call-template name="ahf:processInline">
                    <xsl:with-param name="prmInline" select="node()"/>
                </xsl:call-template>
            </xsl:if>
        </xsl:copy>
    </xsl:template>
    
    <!-- 
     function:	Process shortdesc
     param:		none
     return:	and inline nodes
     note:		
     -->
    <xsl:template match="*[@class => contains-token('topic/shortdesc ')][parent::*[contains(@class,' topic/topic')]][exists(child::node())]" priority="5">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:call-template name="ahf:processInline">
                <xsl:with-param name="prmInline" select="node()"/>
            </xsl:call-template>
        </xsl:copy>
    </xsl:template>

    <!-- 
     function:	Process fn
     param:		none
     return:	inline & block nodes
     note:		
     -->
    <xsl:template match="*[@class => contains-token('topic/fn')]" priority="10">
        <xsl:call-template name="processBlocAndInlineContentElements">
            <xsl:with-param name="prmTextMap" tunnel="yes" select="()"/>
        </xsl:call-template>
    </xsl:template>
    
    <!-- 
     function:	Process indexterm
     param:		none
     return:	Edited indexterm
     note:		This template will be called in prolog processing
     -->
    <xsl:template match="*[@class => contains-token('topic/indexterm')]" priority="5">
        <xsl:call-template name="ahf:processIndexterm"/>
    </xsl:template>
    
    <!-- 
     function:	Process inline nodes
     param:		$prmInline
     return:	inline nodes
     note:		
     -->
    <xsl:template name="ahf:processInline" as="node()*">
        <xsl:param name="prmInline" as="node()+" required="yes"/>
        <xsl:param name="prmTextMap" as="document-node()?" tunnel="yes" required="no" select="()"/>
        <xsl:variable name="textMap" as="document-node()?">
            <xsl:choose>
                <xsl:when test="empty($prmTextMap) and $pDebugGenTextmap">
                    <xsl:call-template name="ahf:getRevisedTextMap">
                        <xsl:with-param name="prmNode" select="$prmInline"/>
                        <xsl:with-param name="prmBase" select="$prmInline[1]/parent::*"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="$prmTextMap"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:if test="empty($prmTextMap) and $pDebugMerged and exists($prmInline)">
            <xsl:result-document href="{concat(ahf:getHistoryStr($prmInline[1]),'-text-map.xml')}" method="xml" indent="yes">
                <texts>
                    <xsl:copy-of select="$textMap/*"/>
                </texts>
            </xsl:result-document>
        </xsl:if>
        <xsl:for-each select="$prmInline">
            <xsl:variable name="inlineNode" as="node()" select="."/>
            <xsl:choose>
                <xsl:when test="$inlineNode/self::text()">
                    <!-- text node -->
                    <xsl:call-template name="ahf:processText">
                        <xsl:with-param name="prmText" select="$inlineNode"/>
                        <xsl:with-param name="prmTextMap" tunnel="yes" select="$textMap"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <!-- inline element or other -->
                    <xsl:choose>
                        <xsl:when test="$inlineNode/self::*[@class => contains-token('topic/fn')]">
                            <xsl:call-template name="processBlocAndInlineContentElements">
                                <xsl:with-param name="prmTextMap" tunnel="yes" select="()"/>
                                <xsl:with-param name="prmInFn" tunnel="yes" select="true()"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:when test="$inlineNode/self::*[@class => contains-token('floatfig-d/floatfig')]">
                            <xsl:call-template name="processBlocAndInlineContentElements">
                                <xsl:with-param name="prmTextMap" tunnel="yes" select="()"/>
                                <xsl:with-param name="prmInFloatFig" tunnel="yes" select="true()"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:when test="$inlineNode/self::*[contains(string(@class),' topic/image ')]">
                            <xsl:call-template name="generalElementProcessing"/>
                        </xsl:when>
                        <xsl:when test="$inlineNode/self::*[ahf:seqContains(string(@class),(' topic/data ',' topic/data-about ',' topic/unknown ',' topic/foreign '))]">
                            <xsl:call-template name="generalElementProcessing"/>
                        </xsl:when>
                        <xsl:when test="$inlineNode/self::*[@class => contains-token('topic/indexterm')]">
                            <xsl:call-template name="ahf:processIndexterm"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:copy>
                                <xsl:apply-templates select="@*"/>
                                <xsl:if test="$inlineNode/node()">
                                    <xsl:call-template name="ahf:processInline">
                                        <xsl:with-param name="prmInline" select="$inlineNode/node()"/>
                                        <xsl:with-param name="prmTextMap" tunnel="yes" select="$textMap"/>
                                    </xsl:call-template>
                                </xsl:if>
                            </xsl:copy>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <!-- 
     function:	Process text node
     param:		$prmText
     return:	text node
     note:		Remove white space by following rule:
                1. If there is following inline element, preserve trailing white-space as one space.
                2. If there is preceding inline element, preserve leading white-space as one space.
                Sometimes text() nodes with all white spaces are combined into one entry. In such a case 
                $prmTextMap/*/@id is composed from plural ids of text(). This template adopt only the first 
                text() occurrence to avoid generating unnecessary spaces.  
     -->
    <xsl:template name="ahf:processText" as="text()">
        <xsl:param name="prmText" as="text()" required="yes"/>
        <xsl:param name="prmTextMap" as="document-node()?" tunnel="yes" required="no" select="()"/>
        <xsl:variable name="textId" as="xs:string" select="ahf:genHistoryId($prmText)"/>
        <xsl:choose>
            <xsl:when test="empty($prmTextMap)">
                <xsl:call-template name="warningContinue">
                    <xsl:with-param name="prmMes" select="ahf:replace($stMes1020,('%text','%id'),(string($prmText),$textId))"/>
                </xsl:call-template>
                <xsl:sequence select="$prmText"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="string($prmTextMap/*[tokenize(string(@id),'&#x20;')[1] eq $textId]/@val)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- 
     function:	Process indexterm
     param:		Current context is indexterm
     return:	indexterm
     note:		Remove white-space & construct indexterm that can be easily converted into XE field.
                1. Nested indexterm element will be combined using ":" as separartor.
                2. Also index-sort-as element will be combined using ":" as separator and set into child <index-sort-as> element
                   only when one of index-sort-as element has effective text.
                2. Generated indexterm may have <index-see>, <index-see-also> element as a child.
     -->
    <xsl:variable name="indextermClass" as="xs:string" select="' topic/indexterm '"/>
    <xsl:variable name="indextermClassGroup" as="xs:string+" select="(' topic/indexterm ',' indexing-d/index-see ',' indexing-d/index-see-also ')"/>
    <xsl:variable name="indextermClassSortAs" as="xs:string+" select="(' indexing-d/index-sort-as ')"/>
    <xsl:variable name="indextermClassGroupWithSortAs" as="xs:string+" select="($indextermClassGroup,$indextermClassSortAs)"/>
    <xsl:variable name="indextermSeeSeeAlsoClassGroup" as="xs:string+" select="(' indexing-d/index-see ',' indexing-d/index-see-also ')"/>

    <xsl:template name="ahf:processIndexterm" as="element()*">
        <xsl:variable name="indexterm" as="element()" select="."/>
        <xsl:variable name="nestedLastIndextermSeq" as="element()*" 
            select="$indexterm/descendant-or-self::*[self::*[contains(@class,$indextermClass)] and empty(*[ahf:seqContains(@class,$indextermClassGroup)]) and empty(ancestor::*[ahf:seqContains(@class,$indextermSeeSeeAlsoClassGroup)])]
                  | $indexterm/descendant::*[self::*[ahf:seqContains(@class,$indextermSeeSeeAlsoClassGroup)]]"/>
        <xsl:for-each select="$nestedLastIndextermSeq">
            <xsl:variable name="last" as="element()" select="."/>
            <xsl:variable name="indextermSeq" as="element()+" select="$last/ancestor-or-self::*[ahf:seqContains(string(@class),$indextermClassGroup)]"/>
            <xsl:for-each select="$indextermSeq[1]">
                <xsl:copy>
                    <xsl:copy-of select="@*"/>
                    <xsl:text>"</xsl:text>
                    <xsl:for-each select="$indextermSeq[contains(@class,$indextermClass)]">
                        <xsl:apply-templates select="." mode="MODE_BUILD_INDEXTERM_TEXT"/>
                    </xsl:for-each>
                    <xsl:text>"</xsl:text>
                    <xsl:for-each select="$indextermSeq[ahf:seqContains(@class,$indextermSeeSeeAlsoClassGroup)]">
                        <xsl:apply-templates select="." mode="MODE_BUILD_INDEXTERM_TEXT"/>
                    </xsl:for-each>
                    <xsl:if test="$indextermSeq[exists(*[contains(@class,$indextermClassSortAs)])]">
                        <xsl:variable name="sortAsSeq" as="xs:string*">
                            <xsl:for-each select="$indextermSeq[contains(@class,$indextermClass)]">
                                <xsl:apply-templates select="." mode="MODE_BUILD_SORT_AS"/>
                            </xsl:for-each>
                        </xsl:variable>
                        <xsl:if test="some $sortAs in $sortAsSeq satisfies string($sortAs)">
                            <xsl:for-each select="($indextermSeq/*[contains(@class,$indextermClassSortAs)])[1]">
                                <xsl:copy>
                                    <xsl:copy-of select="@*"/>
                                    <xsl:text>"</xsl:text>
                                    <xsl:value-of select="string-join($sortAsSeq,':')"/>
                                    <xsl:text>"</xsl:text>
                                </xsl:copy>
                            </xsl:for-each>
                        </xsl:if>
                    </xsl:if>
                </xsl:copy>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:template>

    <!-- generate text() from indexterm -->
    <xsl:template match="*[contains(@class,$indextermClass)]" mode="MODE_BUILD_INDEXTERM_TEXT">
        <xsl:variable name="indextermTextVal" as="xs:string*">
            <xsl:apply-templates select="node() except *[ahf:seqContains(@class,$indextermClassGroupWithSortAs)]" mode="MODE_TEXT_ONLY"/>
        </xsl:variable>
        <xsl:variable name="indextermStringVal" as="xs:string" select="normalize-space(string-join($indextermTextVal,''))"/>
        <xsl:if test="parent::*[@class => contains-token('topic/indexterm')] and string($indextermStringVal)">
            <xsl:value-of select="':'"/>
        </xsl:if>
        <xsl:value-of select="$indextermStringVal"/>
    </xsl:template>

    <!-- index-see, index-see-also element -->
    <xsl:template match="*[ahf:seqContains(@class,$indextermSeeSeeAlsoClassGroup)]" mode="MODE_BUILD_INDEXTERM_TEXT">
        <xsl:variable name="indextermSeeOrSeeAlsoTextVal" as="xs:string*">
            <xsl:apply-templates select="node()" mode="MODE_TEXT_ONLY"/>
        </xsl:variable>
        <xsl:variable name="indextermSeeOrSeeAlsoStringVal" as="xs:string" select="normalize-space(string-join($indextermSeeOrSeeAlsoTextVal,''))"/>
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:value-of select="$indextermSeeOrSeeAlsoStringVal"/>
        </xsl:copy>
    </xsl:template>

    <!-- index-sort-as element -->
    <xsl:template match="*[contains(@class,$indextermClass)]" mode="MODE_BUILD_SORT_AS" as="xs:string">
        <xsl:variable name="sortAsTextVal" as="xs:string*">
            <xsl:apply-templates select="child::*[contains(@class,$indextermClassSortAs)]/node()" mode="MODE_TEXT_ONLY"/>
        </xsl:variable>
        <xsl:variable name="indextermStringVal" as="xs:string" select="string(normalize-space(string-join($sortAsTextVal,'')))"/>
        <xsl:sequence select="$indextermStringVal"/>
    </xsl:template>

</xsl:stylesheet>
