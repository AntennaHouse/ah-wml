<?xml version="1.0" encoding="UTF-8"?>
<!--
**************************************************************
DITA to WordprocessingML Stylesheet
disp-atts related function
**************************************************************
File Name : dita2wml_doc_disp_atts.xsl
**************************************************************
Copyright © 2009-2018 Antenna House, Inc. All rights reserved.
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
     function:	Check display-atts existence 
     param:		prmElem
     return:	xs:boolean
     note:		
     -->
    <xsl:function name="ahf:hasDispAttr" as="xs:boolean">
        <xsl:param name="prmElem" as="element()"/>
        <xsl:variable name="hasFrameAttr" as="xs:boolean" select="string($prmElem/@frame) = ('top','bottom','topbot','sides','all')"/>
        <xsl:variable name="hasScaleAttrAttr" as="xs:boolean" select="string($prmElem/@scale) and (string($prmElem/@scale) ne '100')"/>
        <xsl:sequence select="$hasFrameAttr or $hasScaleAttrAttr"/>
    </xsl:function>
    
    <!-- end of stylesheet -->
</xsl:stylesheet>