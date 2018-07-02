<?xml version="1.0" encoding="UTF-8"?>
<!--
**************************************************************
DITA to WordprocessingML Stylesheet
Document.xml Related-links element Templates
**************************************************************
File Name : dita2wml_doc_related_links.xsl
**************************************************************
Copyright © 2009-2018 Antenna House, Inc. All rights reserved.
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
     function:	related-links processing
     param:		prmTopicRef (tunnel)
     return:	
     note:		
     -->
    <xsl:template match="*[contains(@class,' topic/related-links ')]">
        <xsl:param name="prmTopicRef" tunnel="yes" required="yes" as="element()"/>
        <!-- Generate section property -->
        <xsl:call-template name="getSectionPropertyElemBefore"/>
        
        <xsl:call-template name="getSectionPropertyElemAfter"/>
        
    </xsl:template>

    <!-- END OF STYLESHEET -->

</xsl:stylesheet>