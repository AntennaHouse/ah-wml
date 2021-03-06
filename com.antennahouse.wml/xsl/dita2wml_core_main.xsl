<?xml version="1.0" encoding="UTF-8"?>
<!--
****************************************************************
DITA to WordprocessingML Stylesheet
Module: Making docProps/core.xml main stylesheet.
Copyright © 2009-2017 Antenna House, Inc. All rights reserved.
Antenna House is a trademark of Antenna House, Inc.
URL    : http://www.antennahouse.com/
E-mail : info@antennahouse.com
****************************************************************
-->
<xsl:stylesheet version="3.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:cp="http://schemas.openxmlformats.org/package/2006/metadata/core-properties"
    xmlns:dcterms="http://purl.org/dc/terms/"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
    exclude-result-prefixes="xs ahf">

    <xsl:template match="/">
        <xsl:variable name="topicmeta" select="$map/*[@class => contains-token('map/topicmeta')]" as="element()?"/>
        <cp:coreProperties>
            <dc:title>
                <xsl:choose>
                    <xsl:when test="$isBookMap">
                        <xsl:variable name="title" as="xs:string*">
                            <xsl:apply-templates select="$map/*[@class => contains-token('bookmap/booktitle')]/*[@class => contains-token('bookmap/mainbooktitle')]" mode="MODE_TEXT_ONLY"/>
                        </xsl:variable>
                        <xsl:value-of select="normalize-space(string-join($title,''))"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:variable name="title" as="xs:string*">
                            <xsl:apply-templates select="$map/*[@class => contains-token('map/title')]" mode="MODE_TEXT_ONLY"/>
                        </xsl:variable>
                        <xsl:value-of select="normalize-space(string-join($title,''))"/>
                    </xsl:otherwise>
                </xsl:choose>
            </dc:title>
            <dc:subject/>
            <dc:creator>
                <xsl:choose>
                    <xsl:when test="$topicmeta/*[@class => contains-token('topic/author')]">
                        <xsl:variable name="author" as="xs:string*">
                            <xsl:apply-templates select="$topicmeta/*[@class => contains-token('topic/author')]" mode="MODE_TEXT_ONLY"/>
                        </xsl:variable>
                        <xsl:value-of select="normalize-space(string-join($author,''))"/>
                    </xsl:when>
                    <xsl:when test="$topicmeta/*[@class => contains-token('xnal-d/authorinformation')]/*[@class => contains-token('xnal-d/personinfo')]/*[@class => contains-token('xnal-d/namedetails')]/*[@class => contains-token('xnal-d/personname')]">
                        <xsl:variable name="personName" as="element()" select="$topicmeta/*[@class => contains-token('xnal-d/authorinformation')]/*[@class => contains-token('xnal-d/personinfo')]/*[@class => contains-token('xnal-d/namedetails')]/*[@class => contains-token('xnal-d/personname')]"/>
                        <xsl:variable name="author" as="xs:string*">
                            <xsl:apply-templates select="$personName/*[@class => contains-token('xnal-d/firstname')]" mode="MODE_TEXT_ONLY"/>
                            <xsl:text> </xsl:text>
                            <xsl:apply-templates select="$personName/*[@class => contains-token('xnal-d/xnal-d/middlename')]" mode="MODE_TEXT_ONLY"/>
                            <xsl:text> </xsl:text>
                            <xsl:apply-templates select="$personName/*[@class => contains-token('xnal-d/xnal-d/xnal-d/lastname')]" mode="MODE_TEXT_ONLY"/>
                        </xsl:variable>
                        <xsl:value-of select="normalize-space(string-join($author,''))"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text/>
                    </xsl:otherwise>
                </xsl:choose>
            </dc:creator>
            <cp:keywords>
                <xsl:variable name="keywords" as="xs:string*">
                    <xsl:for-each select="$topicmeta/*[@class => contains-token('topic/metadata')]/*[@class => contains-token('topic/keywords')]/*[@class => contains-token('topic/keyword')]">
                        <xsl:variable name="keyword" as="xs:string*">
                            <xsl:apply-templates select="." mode="MODE_TEXT_ONLY"/>
                        </xsl:variable>
                        <xsl:sequence select="normalize-space(string-join($keyword,''))"/>
                    </xsl:for-each>
                </xsl:variable>
                <xsl:value-of select="string-join($keywords,', ')"/>
            </cp:keywords>
            <dc:description/>
            <cp:lastModifiedBy/>
            <cp:revision>1</cp:revision>
            <xsl:variable name="critdates" as="element()?" select="($topicmeta/*[@class => contains-token('topic/critdates')])[1]"/>
            <xsl:variable name="created" as="attribute()?" select="$critdates/*[@class => contains-token('topic/created')]/@date"/>
            <xsl:variable name="createdDateTime" as="xs:dateTime" select="ahf:toDateTimeWithDefault(string($created),current-dateTime())"/>
            <dcterms:created xsi:type="dcterms:W3CDTF">
                <xsl:value-of select="format-dateTime($createdDateTime, '[Y0001]-[M01]-[D01]T[H01]:[m01]:[s01][Z]')"/>
            </dcterms:created>
            <xsl:variable name="revised" as="attribute()*" select="$critdates/*[@class => contains-token('topic/revised')]/@modified"/>
            <xsl:variable name="revisedDateTime" as="xs:dateTime?" select="ahf:toDateTime(string($revised[1]))"/>
            <xsl:if test="exists($revisedDateTime)">
                <dcterms:modified xsi:type="dcterms:W3CDTF">
                    <xsl:value-of select="format-dateTime($revisedDateTime, '[Y0001]-[M01]-[D01]T[H01]:[m01]:[s01][Z]')"/>
                </dcterms:modified>
            </xsl:if>
        </cp:coreProperties>
    </xsl:template>

</xsl:stylesheet>
