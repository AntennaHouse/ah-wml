<?xml version="1.0" encoding="UTF-8"?>
<!--
**************************************************************
DITA to WordprocessingML Stylesheet
Document.xml Task element Templates
**************************************************************
File Name : dita2wml_doc_task.xsl
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
    exclude-result-prefixes="xs ahf"
    version="3.0">

    <!-- 
     function:	Task/stepsection processing
     param:		not used
     return:	none
     note:		Only apply templates to child elements.
                Set high priority than li element template.
     -->
    <xsl:template match="*[@class => contains-token('task/stepsection')]" priority="5">
        <xsl:apply-templates/>
    </xsl:template>

    <!-- END OF STYLESHEET -->

</xsl:stylesheet>