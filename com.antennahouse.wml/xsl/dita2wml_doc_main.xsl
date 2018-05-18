<?xml version="1.0" encoding="UTF-8"?>
<!--
**************************************************************
DITA to WordprocessingML Stylesheet
Document.xml Shell Templates
**************************************************************
File Name : dita2wml_document_main.xsl
**************************************************************
Copyright © 2009-2017 Antenna House, Inc. All rights reserved.
Antenna House is a trademark of Antenna House, Inc.
URL : http://www.antennahouse.com/
**************************************************************
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
    
    <!--
    function:   Document node template
    param:      none
    return:     w:document
    note:       
    -->
    <xsl:template match="/">
        <!--xsl:call-template name="styleDump"/-->
        <!--xsl:message select="concat('$cTopicTitleStyleName=','''',$cTopicTitleStyleName,'''')"/-->
        <w:document>
            <w:body>
                <!-- Make cover -->
                <!--xsl:call-template name="genCover"/-->
                
                <!-- Make toc for map -->
                <xsl:if test="$isMap and $pMakeTocForMap">
                    <!--xsl:call-template name="genMapToc"/-->
                </xsl:if>
                
                <!-- Process main contents -->
                <xsl:choose>
                    <xsl:when test="$isBookMap">
                        <xsl:apply-templates select="$map/*[contains(@class, ' bookmap/frontmatter ')]/*[contains(@class,' map/topicref ')]"/>
                        <xsl:apply-templates select="$map/*[contains(@class, ' bookmap/part ') or contains(@class, ' bookmap/chapter ')]"/>
                        <xsl:apply-templates select="$map/*[contains(@class, ' bookmap/appendices ')]/*[contains(@class, ' bookmap/appendix ')]"/>
                        <xsl:apply-templates select="$map/*[contains(@class, ' bookmap/appendix ')]"/>
                        <xsl:apply-templates select="$map/*[contains(@class, ' bookmap/backmatter ')]/*[contains(@class,' map/topicref ')]"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="$map/*[contains(@class, ' map/topicref ')]">
                            <xsl:with-param name="prmTopElement" tunnel="yes" select="'map'"/>
                        </xsl:apply-templates>
                    </xsl:otherwise>
                </xsl:choose>
                
                <!-- Make index for map -->
                <xsl:if test="$isMap and $pMakeIndexForMap and $pOutputIndex">
                    <!--xsl:call-template name="genMapIndex"/-->
                </xsl:if>
                
                <xsl:call-template name="genSingleSideSectPr"/>
            </w:body>
        </w:document>        
    </xsl:template>
    
</xsl:stylesheet>