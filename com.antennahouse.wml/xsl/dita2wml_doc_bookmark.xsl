<?xml version="1.0" encoding="UTF-8"?>
<!--
**************************************************************
DITA to WordprocessingML Stylesheet
Document.xml Bookmark Templates
**************************************************************
File Name : dita2wml_document_bookmark.xsl
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
     function:	Bookmark processing for title
     param:		none
     return:	
     note:		FIX-ME: Need to generate bookmark for title/descendant[1] and title/descendant[last()] 
     -->
    <!--xsl:template match="*[@class => contains-token('topic/title ')][parent::*[ahf:seqContains(@class,(' topic/fig ',' topic/table ',' topic/section ',' topic/example'))]]" priority="20">
        <xsl:call-template name="genBookmarkStart">
            <xsl:with-param name="prmElem" select="parent::*"/>
        </xsl:call-template>
        <xsl:next-match/>
        <xsl:call-template name="genBookmarkEnd">
            <xsl:with-param name="prmElem" select="parent::*"/>
        </xsl:call-template>
    </xsl:template-->
    
    <!-- ==== END OF STYLESHEET === -->

</xsl:stylesheet>