<?xml version="1.0" encoding="UTF-8"?>
<!--
**************************************************************
DITA to WordprocessingML Stylesheet
Document.xml User Interface Domain Templates
**************************************************************
File Name : dita2wml_doc_userinterface_domain.xsl
**************************************************************
Copyright © 2009-2018 Antenna House, Inc. All rights reserved.
Antenna House is a trademark of Antenna House, Inc.
URL : http://www.antennahouse.com/
**************************************************************
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" 
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
    exclude-result-prefixes="xs ahf map"
    version="3.0">
    
    <xsl:variable name="cMenuCascadeSymbol"  select="ahf:getVarValue('MenuCascadeSymbol')" as="xs:string"/>
    <xsl:variable name="cUiControlPrefix"    select="ahf:getVarValue('UiControlPrefix')" as="xs:string"/>
    <xsl:variable name="cUiControlSuffix"    select="ahf:getVarValue('UiControlSuffix')" as="xs:string"/>
    
    <!-- 
     function:	uicontrol element processing
     param:		prmRunProps
     return:	w:r*
     note:      If uicontrol is child of menucascade, insert ">" between as needed.
     -->
    <xsl:template match="*[contains(@class,' ui-d/uicontrol ')]" priority="5">
        <xsl:param name="prmRunProps" tunnel="yes" required="no" as="element()*" select="()"/>
        <xsl:variable name="uiControlRunProp" as="element()*">
            <xsl:call-template name="getWmlObject">
                <xsl:with-param name="prmObjName" select="'wmlUiControl'"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="runProps" select="ahf:mergeRunProps($prmRunProps,$uiControlRunProp)"/>
        <xsl:if test="parent::*[contains(@class, ' ui-d/menucascade ')]">
            <!-- Child of menucascade -->
            <xsl:if test="preceding-sibling::*[contains(@class, ' ui-d/uicontrol ')]">
                <!-- preceding uicontrol -->
                <w:r>
                    <xsl:if test="exists($prmRunProps)">
                        <w:rPr>
                            <xsl:copy-of select="$prmRunProps"/>
                        </w:rPr>
                    </xsl:if>
                    <!-- append '&gt;' -->
                    <w:t xml:space="preserve"><xsl:value-of select="$cMenuCascadeSymbol"/></w:t>
                </w:r>
            </xsl:if>
        </xsl:if>
        <!-- Insert prefix-->
        <xsl:if test="string($cUiControlPrefix)">
            <w:r>
                <xsl:if test="exists($runProps)">
                    <w:rPr>
                        <xsl:copy-of select="$runProps"/>
                    </w:rPr>
                </xsl:if>
                <!-- insert prefix -->
                <w:t><xsl:value-of select="$cUiControlPrefix"/></w:t>
            </w:r>
        </xsl:if>
        <xsl:apply-templates>
            <xsl:with-param name="prmRunProps" tunnel="yes" select="$runProps"/>
        </xsl:apply-templates>
        <xsl:if test="string($cUiControlSuffix)">
            <w:r>
                <xsl:if test="exists($runProps)">
                    <w:rPr>
                        <xsl:copy-of select="$runProps"/>
                    </w:rPr>
                </xsl:if>
                <!-- insert suffix -->
                <w:t><xsl:value-of select="$cUiControlSuffix"/></w:t>
            </w:r>
        </xsl:if>
    </xsl:template>
    
    <!-- ==== END OF STYLESHEET === -->

</xsl:stylesheet>