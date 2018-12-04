<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" 
    xmlns:fo="http://www.w3.org/1999/XSL/Format" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" 
    xmlns:axf="http://www.antennahouse.com/names/XSL/Extensions"
    xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
    xmlns:ahs="http://www.antennahouse.com/names/XSLT/Document/Layout"
    exclude-result-prefixes="xs ahf fo axf ahs">
    
    <!-- 
         function:	Convert FO property into w:pPr child level elements
         param:     prmFoProp
         return:	element()*
         note:		XSL-FO properties are expanded in $prmFoProp. 
                    This function convert them into the elements that constructs w:pPr children.
    -->
    <xsl:function name="ahf:foPropToPprChild" as="element()*">
        <xsl:param name="prmFoProp" as="attribute()*"/>
    </xsl:function>
    
</xsl:stylesheet>