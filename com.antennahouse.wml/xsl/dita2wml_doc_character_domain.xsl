<?xml version="1.0" encoding="UTF-8"?>
<!--
**************************************************************
DITA to WordprocessingML Stylesheet
Document.xml character domain text Templates
**************************************************************
File Name : dita2wml_document_character_domain.xsl
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
     function:	br element processing
     param:		none
     return:	w:r
     note:      <br/> is introduced in ah-dita specialization:
                https://github.com/AntennaHouse/ah-dita
     -->
    <xsl:template match="*[contains(@class, ' ch-d/br ')]" priority="5" as="element(w:r)">
        <w:r>
            <w:br/>
        </w:r>
    </xsl:template>
    
    <!-- ==== END OF STYLESHEET === -->

</xsl:stylesheet>