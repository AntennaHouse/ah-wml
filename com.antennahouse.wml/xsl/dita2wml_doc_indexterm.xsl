<?xml version="1.0" encoding="UTF-8"?>
<!--
**************************************************************
DITA to WordprocessingML Stylesheet
Document.xml indexterm Templates
**************************************************************
File Name : dita2wml_document_text.xsl
**************************************************************
Copyright © 2009-2018 Antenna House, Inc. All rights reserved.
Antenna House is a trademark of Antenna House, Inc.
URL : http://www.antennahouse.co.jp/
**************************************************************
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" 
    xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
    exclude-result-prefixes="xs ahf"
    version="3.0">

    <!-- 
     function:	indexterm processing
     param:		none
     return:	XE field
     note:      still temporary. @start/@end is not implemented.
     -->
    <xsl:template match="*[contains(@class,' topic/indexterm ')]" as="element(w:r)+">
        <xsl:variable name="text" as="xs:string" select="string(.)"/>
        <xsl:variable name="see" as="xs:string" select="string(*[contains(@class,' indexing-d/index-see ')])"/>
        <xsl:variable name="seeAlso" as="xs:string" select="string(*[contains(@class,' indexing-d/index-see-also ')])"/>
        <xsl:variable name="indexSortAs" as="xs:string" select="string(*[contains(@class,' indexing-d/index-sort-as ')])"/>
        
        <xsl:variable name="option" as="xs:string*">
            <xsl:choose>
                <xsl:when test="string($see)">
                    <xsl:variable name="seePrefix" as="xs:string">
                        <xsl:call-template name="getVarValueWithLang">
                            <xsl:with-param name="prmVarName" select="'See_Prefix'"/>
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:variable name="seeSuffix" as="xs:string">
                        <xsl:call-template name="getVarValueWithLang">
                            <xsl:with-param name="prmVarName" select="'See_Suffix'"/>
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:sequence select="concat('\t &quot;',$seePrefix,$see,$seeSuffix,'&quot;')"/>
                </xsl:when>
                <xsl:when test="string($seeAlso)">
                    <xsl:variable name="seeAlsoPrefix" as="xs:string">
                        <xsl:call-template name="getVarValueWithLang">
                            <xsl:with-param name="prmVarName" select="'See_Also_Prefix'"/>
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:variable name="seeAlsoSuffix" as="xs:string">
                        <xsl:call-template name="getVarValueWithLang">
                            <xsl:with-param name="prmVarName" select="'See_Also_Suffix'"/>
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:sequence select="concat('\t &quot;',$seeAlsoPrefix,$seeAlso,$seeAlsoSuffix,'&quot;')"/>
                </xsl:when>
            </xsl:choose>
            <xsl:if test="string($indexSortAs)">
                <xsl:sequence select="concat('\y ',$indexSortAs)"/>
            </xsl:if>
        </xsl:variable>
        
        <xsl:call-template name="getWmlObjectReplacing">
            <xsl:with-param name="prmObjName" select="'wmlXeField'"/>
            <xsl:with-param name="prmSrc" select="('%text','%field-opt')"/>
            <xsl:with-param name="prmDst" select="($text,string-join($option,' '))"/>
        </xsl:call-template>
    </xsl:template>

    <!-- ==== END OF STYLESHEET === -->

</xsl:stylesheet>