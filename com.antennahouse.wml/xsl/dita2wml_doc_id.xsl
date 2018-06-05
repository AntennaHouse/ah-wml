<?xml version="1.0" encoding="UTF-8"?>
<!--
**************************************************************
DITA to WordprocessingML Stylesheet
Id attribute related function
**************************************************************
File Name : dita2wml_doc_id.xsl
**************************************************************
Copyright © 2009 2017 Antenna House, Inc. All rights reserved.
Antenna House is a trademark of Antenna House, Inc.
URL : http://www.antennahouse.com/
**************************************************************
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:w="http://purl.oclc.org/ooxml/wordprocessingml/main"
    xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
    exclude-result-prefixes="xs ahf"
    version="3.0">
    
    <!-- 
     function:	Generate unique id cosidering multiple topic reference
     param:		prmElement,prmTopicRef
     return:	id string
     note:		About the indexterm in topicref/topicmeta, the parameter 
                $prmTopicRef is empty.
     -->
    <xsl:function name="ahf:generateId" as="xs:string">
        <xsl:param name="prmElement" as="element()"/>
        <xsl:call-template name="ahf:generateId">
            <xsl:with-param name="prmElement" select="$prmElement"/>
        </xsl:call-template>
    </xsl:function>
    
    <xsl:template name="ahf:generateId" as="xs:string">
        <xsl:param name="prmElement" required="no" as="element()" select="."/>
        <xsl:sequence select="ahf:genHistoryId($prmElement)"/>
    </xsl:template>
    
</xsl:stylesheet>