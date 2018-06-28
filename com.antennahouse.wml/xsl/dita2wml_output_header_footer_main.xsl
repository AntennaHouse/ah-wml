<?xml version="1.0" encoding="UTF-8"?>
<!--
**************************************************************
DITA to WordprocessingML Stylesheet
Output Header/Footer Main Templates
**************************************************************
File Name : dita2wml_output_header_footer_main.xsl
**************************************************************
Copyright © 2009-2018 Antenna House, Inc. All rights reserved.
Antenna House is a trademark of Antenna House, Inc.
URL : http://www.antennahouse.com/
**************************************************************
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="3.0">
    
    <!-- 
     function:	Initial template 
     param:		None
     return:	None
     note:		Generate Header/Footer File To [temp dir]/docx/word Folder
                Ant XSLT task always needs input file even if <xsl:template name="xsl:initial-template"> is defined.
     -->
    <!--xsl:template name="xsl:initial-template"/-->
    <xsl:template match="/">
        <xsl:call-template name="genHeaderFooterFiles"/>
    </xsl:template>    
    
</xsl:stylesheet>