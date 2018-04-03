<?xml version="1.0" encoding="UTF-8"?>
<!--
****************************************************************
DITA to WordprocessingML Stylesheet
Module: Making word/styles.xml main stylesheet.
Copyright © 2009-2017 Antenna House, Inc. All rights reserved.
Antenna House is a trademark of Antenna House, Inc.
URL    : http://www.antennahouse.com/
E-mail : info@antennahouse.com
****************************************************************
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:wpc="http://schemas.microsoft.com/office/word/2010/wordprocessingCanvas" 
    xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006" 
    xmlns:o="urn:schemas-microsoft-com:office:office" 
    xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" 
    xmlns:m="http://schemas.openxmlformats.org/officeDocument/2006/math" 
    xmlns:v="urn:schemas-microsoft-com:vml" 
    xmlns:wp14="http://schemas.microsoft.com/office/word/2010/wordprocessingDrawing" 
    xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing" 
    xmlns:w10="urn:schemas-microsoft-com:office:word" 
    xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" 
    xmlns:w14="http://schemas.microsoft.com/office/word/2010/wordml" 
    xmlns:w15="http://schemas.microsoft.com/office/word/2012/wordml" 
    xmlns:wpg="http://schemas.microsoft.com/office/word/2010/wordprocessingGroup" 
    xmlns:wpi="http://schemas.microsoft.com/office/word/2010/wordprocessingInk" 
    xmlns:wne="http://schemas.microsoft.com/office/word/2006/wordml" 
    xmlns:wps="http://schemas.microsoft.com/office/word/2010/wordprocessingShape" 
    xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
    exclude-result-prefixes="xs ahf"
    version="3.0">
    
    <!-- This template adds styles used for note before/after line that have horizontal rule made by <strike/> element.
     -->
    
    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>

    <!--
    function:   w:styles genral template
    param:      none
    return:     self and descendant node
    note:       
    -->
    <xsl:template match="*">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <!--
    function:   w:styles template
    param:      none
    return:     w:styles
    note:       Add one style
    -->
    <xsl:template match="w:styles">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
            <!-- Make note rule line style -->
            <xsl:variable name="bodyRightEdgeTwip" as="xs:integer" select="ahf:toTwip($pPaperWidth) - ahf:toTwip($pPaperMarginLeft) - ahf:toTwip($pPaperMarginRight)"/>
            <xsl:variable name="normalStyleId" as="xs:string" select="ahf:getStyleIdFromName('Normal')"/>
            <!--xsl:call-template name="getWmlObjectReplacing">
                <xsl:with-param name="prmObjName" select="'wmlNoteLineStyle'"/>
                <xsl:with-param name="prmSrc" select="('%based-on','%next-style')"/>
                <xsl:with-param name="prmDst" select="($normalStyleId,$normalStyleId)"/>
            </xsl:call-template-->
        </xsl:copy>
    </xsl:template>
    

</xsl:stylesheet>
