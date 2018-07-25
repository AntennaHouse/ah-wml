<?xml version='1.0' encoding="UTF-8" ?>
<!--
****************************************************************
DITA to WordprocessingML Stylesheet
Module: Merged file conversion templates (1)
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
    <!-- This stylesheet sorts topicrefs located under the booklists/glossarylist if $PRM_SORT_GLOSSARY_LIST is 'yes':
         1. Extract glossentry from glossgroup.
         2. Generate temporary tree for booklists/glossarylist//topicref 
         3. Sort temporary tree by glossterm as key
         4. Restore the sort result
      -->

    <!-- Sorting URI -->
    <xsl:variable name="cGlossEntrySortUri" as="xs:string" select="'http://saxon.sf.net/collation?lang='"/>

    <!-- 
     function:	General template for all element
     param:		none
     return:	copied result
     note:		
     -->
    <xsl:template match="*">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="@*">
        <xsl:copy/>
    </xsl:template>

    <xsl:template match="node()" priority="-10">
        <xsl:copy/>
    </xsl:template>
    
    <!-- 
     function:	glossarylist
     param:		none
     return:	sorted or copied result
     note:		
     -->
    <xsl:template match="*[contains(@class,' bookmap/glossarylist ')]">
        <xsl:choose>
            <xsl:when test="$pSortGlossaryList">
                <xsl:copy>
                    <xsl:apply-templates select="@*"/>
                    <xsl:call-template name="sortGlossryList"/>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- 
     function:	Sort glossarylist//topicref using glossterm as key
     param:		none
     return:	sorted result
     note:		Extract glossentry from glossgroup
     -->
    <xsl:template name="sortGlossryList" as="element()*">
        <xsl:param name="prmGlossaryList" as="element()" select="."/>
        
        <xsl:variable name="glossEntryTopicRefs" as="document-node()">
            <xsl:document>
                <xsl:apply-templates select="$prmGlossaryList/*[contains(@class,' map/topicref ')]" mode="MODE_MAKE_SORT_KEY"/>    
            </xsl:document>
        </xsl:variable>
        
        <xsl:variable name="glossEntrySortedTopicrefs" as="document-node()">
            <xsl:document>
                <xsl:for-each select="$glossEntryTopicRefs/*">
                    <xsl:sort select="@sort-key" lang="{$documentLang}" collation="{concat($cGlossEntrySortUri,$documentLang)}" data-type="text"/>
                    <xsl:element name="{name()}">
                        <xsl:copy-of select="@*"/>
                        <xsl:copy-of select="child::node()"/>
                    </xsl:element>
                </xsl:for-each>
            </xsl:document>
        </xsl:variable>
        
        <xsl:sequence select="$glossEntrySortedTopicrefs/*"/>
        
    </xsl:template>
    
    <!-- 
     function:	topicref template for glossentry
     param:		none
     return:	topicref adding sort-key and auto generated topicref from glossgroup
     note:		
     -->
    <xsl:template match="*[contains(@class,' map/topicref ')][exists(@href)]" mode="MODE_MAKE_SORT_KEY">
        <xsl:variable name="topicRef" as="element()" select="."/>
        <xsl:variable name="topic" as="element()?" select="ahf:getTopicFromTopicRef($topicRef)"/>
        <xsl:choose>
            <xsl:when test="exists($topic)">
                <xsl:choose>
                    <xsl:when test="$topic[contains(@class,' glossenrty/glossentry ')]">
                        <xsl:variable name="sortKey" as="xs:string">
                            <xsl:variable name="sortKeyTexts" as="xs:string*">
                                <xsl:apply-templates select="$topic/*[contains(@class,' glossentry/glossterm ')]" mode="TEXT_ONLY"/>
                            </xsl:variable>
                            <xsl:sequence select="normalize-space(string-join($sortKeyTexts,''))"/>
                        </xsl:variable>
                        <xsl:copy>
                            <xsl:copy-of select="@*"/>
                            <xsl:attribute name="sort-key" select="$sortKey"/>
                            <xsl:copy-of select="* except *[contains(@class,' map/topicref ')]"/>
                        </xsl:copy>
                    </xsl:when>
                    <xsl:when test="$topic[contains(@class,' glossgroup/glossgroup ')]">
                        <xsl:variable name="glossGroup" as="element()" select="$topic"/>
                        <xsl:variable name="glossEntry" as="element()+" select="$glossGroup/descendant::*[contains(@class,' glossentry/glossentry ')]"/>
                        <xsl:for-each select="$glossEntry">
                            <xsl:variable name="glossEntry" as="element()" select="."/>
                            <xsl:variable name="href" as="xs:string" select="concat('#',string($glossEntry/@id))"/>
                            <xsl:variable name="sortKey" as="xs:string">
                                <xsl:variable name="sortKeyTexts" as="xs:string*">
                                    <xsl:apply-templates select="$glossEntry/*[contains(@class,' glossentry/glossterm ')]" mode="TEXT_ONLY"/>
                                </xsl:variable>
                                <xsl:sequence select="normalize-space(string-join($sortKeyTexts,''))"/>
                            </xsl:variable>
                            <xsl:for-each select="$topicRef">
                                <xsl:copy>
                                    <xsl:copy-of select="@*"/>
                                    <xsl:attribute name="href" select="$href"/>
                                    <xsl:attribute name="first_topic_id" select="$href"/>
                                    <xsl:attribute name="type" select="'glossentry'"/>
                                    <xsl:attribute name="sort-key" select="$sortKey"/>
                                    <xsl:copy-of select="*[contains(@class,' map/topicmeta ')]"/>
                                </xsl:copy>
                            </xsl:for-each>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:variable name="sortKey" as="xs:string">
                            <xsl:variable name="sortKeyTexts" as="xs:string*">
                                <xsl:apply-templates select="$topic/*[contains(@class,' topic/title ')]" mode="TEXT_ONLY"/>
                            </xsl:variable>
                            <xsl:sequence select="normalize-space(string-join($sortKeyTexts,''))"/>
                        </xsl:variable>
                        <xsl:copy>
                            <xsl:copy-of select="@*"/>
                            <xsl:attribute name="sort-key" select="$sortKey"/>
                            <xsl:copy-of select="* except *[contains(@class,' map/topicref ')]"/>
                        </xsl:copy>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:apply-templates select="*[contains(@class,' map/topicref ')]" mode="#current"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="warningContinue">
                    <xsl:with-param name="prmMes" select="ahf:replace($stMes1009,('%href','%xtrf'),(string(@href),string(@xtrf)))"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="*[contains(@class,' map/topicref ')][empty(@href)]" mode="MODE_MAKE_SORT_KEY">
        <xsl:apply-templates select="*[contains(@class,' map/topicref ')]" mode="#current"/>
    </xsl:template>

    <!-- 
     function:	glossgroup template
     param:		none
     return:	Extract glossentry as the dependent entry
     note:		
     -->
    <xsl:template match="$topics/descendant-or-self::*[contains(@class,' glossgroup/glossgroup ')]">
        <xsl:variable name="glossGroup" as="element()" select="."/>
        <xsl:variable name="glossEntries" as="element()+" select="$glossGroup/descendant::*[contains(@class,' glossentry/glossentry ')]"/>
        <xsl:for-each select="$glossEntries">
            <xsl:apply-templates select="."/>
        </xsl:for-each>
    </xsl:template>
        

</xsl:stylesheet>
