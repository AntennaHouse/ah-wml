<?xml version="1.0" encoding="UTF-8"?>
<!--
**************************************************************
DITA to WordprocessingML Stylesheet
Document.xml Topic element Templates
**************************************************************
File Name : dita2wml_document_topic.xsl
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
    version="2.0">

    <!-- 
     function:	Topic/shortdesc processing
     param:		prmIndentLevel
     return:	
     note:		Shortdesc is composed of inlne elements.
     -->
    <xsl:template match="*[contains(@class,' topic/topic ')]/*[contains(@class,' topic/shortdesc ')][empty(child::node())]" priority="5"/>
    <xsl:template match="*[contains(@class,' topic/abstract ')]/*[contains(@class,' topic/shortdesc ')][empty(child::node())]" priority="5"/>
    
    <xsl:template match="*[contains(@class,' topic/topic ')]/*[contains(@class,' topic/shortdesc ')]|*[contains(@class,' topic/abstract ')]/*[contains(@class,' topic/shortdesc ')]">
        <xsl:param name="prmIndentLevel" tunnel="yes" required="yes" as="xs:integer"/>
        <xsl:param name="prmExtraIndent" tunnel="yes" required="yes" as="xs:integer"/>
        <w:p>
            <xsl:variable name="shortDescStyle" as="xs:string">
                <xsl:call-template name="getVarValue">
                    <xsl:with-param name="prmVarName" select="'Shortdesc_Style_Name'"/>
                </xsl:call-template>
            </xsl:variable>
            <w:pPr>
                <xsl:if test="string($shortDescStyle)">
                    <w:pStyle w:val="{ahf:getStyleIdFromName($shortDescStyle)}"/>
                </xsl:if>
                <xsl:copy-of select="ahf:getIndentAttrElem($prmIndentLevel, $prmExtraIndent)"/>                
            </w:pPr>
            <xsl:apply-templates/>
        </w:p>
    </xsl:template>

    <!-- 
     function:	Topic/abstract processing
     param:		none
     return:	
     note:		Abstract contains both text or inline elements and block elements.
                The merged file preprocessing converts text or inline elements into <p> element.
                So only <xsl:apply-templates> is needed to process contents.
     -->
    <xsl:template match="*[contains(@class,' topic/abstract ')][empty(child::node())]" priority="5"/>
    
    <xsl:template match="*[contains(@class,' topic/abstract ')]">
        <xsl:apply-templates>
            <xsl:with-param name="prmListOccurenceNumber" tunnel="yes" select="0"/>
            <xsl:with-param name="prmListLevel" tunnel="yes" select="0"/>
            <xsl:with-param name="prmIndentLevel" tunnel="yes" select="0"/>
        </xsl:apply-templates>
    </xsl:template>

    <!-- 
     function:	Topic/body processing
     param:		none
     return:	
     note:		Body contains block elements.
                So only <xsl:apply-templates> selecting element is needed to process contents.
     -->
    <xsl:template match="*[contains(@class,' topic/body ')]">
        <xsl:apply-templates select="*">
            <xsl:with-param name="prmListOccurenceNumber" tunnel="yes" select="0"/>
            <xsl:with-param name="prmListLevel" tunnel="yes" select="0"/>
            <xsl:with-param name="prmIndentLevel" tunnel="yes" select="0"/>
        </xsl:apply-templates>
    </xsl:template>

    <!-- 
     function:	Topic/bodydiv processing
     param:		none
     return:	
     note:		Bodydiv contains both text or inline elements and block elements.
                The merged file preprocessing converts text or inline elements into <p> element.
                So only <xsl:apply-templates> is needed to process contents.
     -->
    <xsl:template match="*[contains(@class,' topic/bodydiv ')]">
        <xsl:apply-templates/>
    </xsl:template>

    <!-- END OF STYLESHEET -->

</xsl:stylesheet>