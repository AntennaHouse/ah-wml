<?xml version="1.0" encoding="UTF-8"?>
<!--
**************************************************************
DITA to WordprocessingML Stylesheet
Document.xml floatfig element Templates
**************************************************************
File Name : dita2wml_document_floatfig.xsl
**************************************************************
Copyright © 2009-2018 Antenna House, Inc. All rights reserved.
Antenna House is a trademark of Antenna House, Inc.
URL : http://www.antennahouse.co.jp/
**************************************************************
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" 
    xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
    xmlns:dita-ot="http://dita-ot.sourceforge.net/ns/201007/dita-ot"
    xmlns:graphicUtil="java:com.antennahouse.xsltutil.GraphicUtil"
    extension-element-prefixes="graphicUtil"
    exclude-result-prefixes="xs ahf dita-ot map graphicUtil"
    version="3.0">

    <!-- 
     function:	floatfig element processing
     param:		none
     return:	w:r
     note:      This template also called form block image processing.
                If it is block level image, adjust the image size to fit the body domain.
     -->
    <xsl:template match="*[contains(@class,' topic/floatfig ')]" name="processFloatFigInline" as="element(w:r)?">
    </xsl:template>

    <!-- END OF STYLESHEET -->

</xsl:stylesheet>