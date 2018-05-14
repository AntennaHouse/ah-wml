<?xml version="1.0" encoding="UTF-8"?>
<!--
**************************************************************
DITA to WordprocessingML Stylesheet
Document.xml index Templates
**************************************************************
File Name : dita2wml_document_index.xsl
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
     function:	index processing
     param:		none
     return:	INDEX field
     note:      Only generate INDEX field.
                Generating index is own by Word.
     -->
    <xsl:template match="*[contains(@class,' bookmap/indexlist ')]" name="genIndexField" as="element(w:p)+">
        
        <xsl:variable name="option" as="xs:string*">
            <xsl:sequence select="'\c 2'"/>
            <xsl:sequence select="'\e &quot;, &quot;'"/>
            <xsl:sequence select="'\h &quot;—A—&quot;'"/>
            <xsl:call-template name="getVarValue">
                <xsl:with-param name="prmVarName" select="'IndexOptionEtc'"/>
            </xsl:call-template>
        </xsl:variable>
        
        <xsl:call-template name="genTopicRefTitle">
            <xsl:with-param name="prmTopicRef" select="."/>
            <xsl:with-param name="prmTopicRefLevel"  select="1"/>
            <xsl:with-param name="prmTitle">
                <xsl:call-template name="getVarValue">
                    <xsl:with-param name="prmVarName" select="'Index_Title'"/>
                </xsl:call-template>
            </xsl:with-param>
        </xsl:call-template>    
        
        <w:p>
            <xsl:call-template name="getWmlObjectReplacing">
                <xsl:with-param name="prmObjName" select="'wmlIndexField'"/>
                <xsl:with-param name="prmSrc" select="('%field-opt')"/>
                <xsl:with-param name="prmDst" select="(string-join($option,' '))"/>
            </xsl:call-template>
        </w:p>
    </xsl:template>

    <!-- ==== END OF STYLESHEET === -->

</xsl:stylesheet>