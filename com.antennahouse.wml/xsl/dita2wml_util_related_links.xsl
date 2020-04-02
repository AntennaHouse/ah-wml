<?xml version="1.0" encoding="UTF-8"?>
<!--
**************************************************************
DITA to WordprocessingML Stylesheet
Document.xml Related-links utility Templates
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
     function:	Judge target link
     param:		prmLink
     return:	xs:boolean
     note:		parent, child links are ignored. 
     -->
    <xsl:function name="ahf:isTargetLink" as="xs:boolean">
        <xsl:param name="prmLink" as="element()"/>
        <xsl:sequence select="string($prmLink/@role) = ('friend','other','')"/>
    </xsl:function>

    <!-- 
     function:	Judge effective related-links
     param:		prmRelatedLink
     return:	xs:boolean
     note:		 
     -->
    <xsl:function name="ahf:isEffectiveRelatedLinks" as="xs:boolean">
        <xsl:param name="prmRelatedLinks" as="element()"/>
        <xsl:variable name="linkCount" select="count($prmRelatedLinks/descendant::*[@class => contains-token('topic/link')][ahf:isTargetLink(.)])" as="xs:integer"/>
        <xsl:sequence select="$linkCount gt 0"/>
    </xsl:function>
    
    <!-- END OF STYLESHEET -->

</xsl:stylesheet>