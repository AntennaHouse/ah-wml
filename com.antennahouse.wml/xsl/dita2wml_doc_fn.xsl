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
     function:	fn processing
     param:		prmRunProps (tunnel)
     return:	w:r with w:footnotereference
     note:		The fn content exists in word/footnote.xml
                - fn is ignored in generating TOC entry title or xref target title 
     -->
    <xsl:template match="*[contains(@class,' topic/fn ')]">
        <xsl:param name="prmRunProps" tunnel="yes" required="no" as="element()*" select="()"/>
        <xsl:param name="prmSkipFn"   tunnel="yes" required="no" as="xs:boolean" select="false()"/>
        <xsl:if test="not($prmSkipFn)">
            <xsl:variable name="key" as="xs:string" select="ahf:generateId(.)"/>
            <xsl:variable name="fnId" as="xs:integer?" select="map:get($fnIdMap,$key)[1]"/>
            <xsl:assert test="exists($fnId)" select="'[fn] key=',$key,' does not exists is $fnIdMap key=',ahf:mapKeyDump($fnIdMap)"/>
            <w:r>
                <w:rPr>
                    <w:rStyle w:val="{ahf:getStyleIdFromName('footnote reference')}"/>
                    <xsl:copy-of select="$prmRunProps"/>
                </w:rPr>
                <xsl:choose>
                    <xsl:when test="@callout">
                        <w:footnoteReference w:customMarkFollows="1" w:id="{string($fnId)}"/>
                        <w:t xml:space="preserve"><xsl:value-of select="@callout"/></w:t>
                    </xsl:when>
                    <xsl:otherwise>
                        <w:footnoteReference w:id="{string($fnId)}"/>
                    </xsl:otherwise>
                </xsl:choose>
            </w:r>
        </xsl:if>
    </xsl:template>
    
    <!-- END OF STYLESHEET -->

</xsl:stylesheet>