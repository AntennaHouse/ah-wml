<?xml version="1.0" encoding="UTF-8"?>
<!--
**************************************************************
DITA to WordprocessingML Stylesheet
Document.xml Software Domain Templates
**************************************************************
File Name : dita2wml_doc_software_domain.xsl
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
    
    <!-- msgblock is implemented by pre element.
     -->
    
    <!-- 
     function:	msgph element processing
     param:		prmRunProps
     return:	w:r
     note:      Apply mono-space font.
     -->
    <xsl:template match="*[contains(@class,' sw-d/msgph ')]" priority="5">
        <xsl:param name="prmRunProps" tunnel="yes" required="no" as="element()*" select="()"/>
        <xsl:variable name="msgPhRunProp" as="element()*">
            <xsl:call-template name="getWmlObject">
                <xsl:with-param name="prmObjName" select="'wmlMsgPh'"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="runProps" select="ahf:mergeRunProps($prmRunProps,$msgPhRunProp)"/>
        <xsl:apply-templates>
            <xsl:with-param name="prmRunProps" tunnel="yes" select="$runProps"/>
        </xsl:apply-templates>
    </xsl:template>
    
    <!-- 
     function:	msgnum element processing
     param:		prmRunProps
     return:	w:r
     note:      Apply mono-space font.
     -->
    <xsl:template match="*[contains(@class,' sw-d/msgnum ')]" priority="5">
        <xsl:param name="prmRunProps" tunnel="yes" required="no" as="element()*" select="()"/>
        <xsl:variable name="msgNumRunProp" as="element()*">
            <xsl:call-template name="getWmlObject">
                <xsl:with-param name="prmObjName" select="'wmlMsgNum'"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="runProps" select="ahf:mergeRunProps($prmRunProps,$msgNumRunProp)"/>
        <xsl:apply-templates>
            <xsl:with-param name="prmRunProps" tunnel="yes" select="$runProps"/>
        </xsl:apply-templates>
    </xsl:template>

    <!-- 
     function:	cmdname element processing
     param:		prmRunProps
     return:	w:r
     note:      Apply mono-space font.
     -->
    <xsl:template match="*[contains(@class,' sw-d/cmdname ')]" priority="5">
        <xsl:param name="prmRunProps" tunnel="yes" required="no" as="element()*" select="()"/>
        <xsl:variable name="cmdNameRunProp" as="element()*">
            <xsl:call-template name="getWmlObject">
                <xsl:with-param name="prmObjName" select="'wmlCmdName'"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="runProps" select="ahf:mergeRunProps($prmRunProps,$cmdNameRunProp)"/>
        <xsl:apply-templates>
            <xsl:with-param name="prmRunProps" tunnel="yes" select="$runProps"/>
        </xsl:apply-templates>
    </xsl:template>
    
    <!-- 
     function:	varname element processing
     param:		prmRunProps
     return:	w:r
     note:      Apply italic style.
     -->
    <xsl:template match="*[contains(@class,' sw-d/varname ')]" priority="5">
        <xsl:param name="prmRunProps" tunnel="yes" required="no" as="element()*" select="()"/>
        <xsl:variable name="varNameRunProp" as="element()*">
            <xsl:call-template name="getWmlObject">
                <xsl:with-param name="prmObjName" select="'wmlVarName'"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="runProps" select="ahf:mergeRunProps($prmRunProps,$varNameRunProp)"/>
        <xsl:apply-templates>
            <xsl:with-param name="prmRunProps" tunnel="yes" select="$runProps"/>
        </xsl:apply-templates>
    </xsl:template>

    <!-- 
     function:	filepath element processing
     param:		prmRunProps
     return:	w:r
     note:      Apply italic style.
     -->
    <xsl:template match="*[contains(@class,' sw-d/filepath ')]" priority="5">
        <xsl:param name="prmRunProps" tunnel="yes" required="no" as="element()*" select="()"/>
        <xsl:variable name="filePathRunProp" as="element()*">
            <xsl:call-template name="getWmlObject">
                <xsl:with-param name="prmObjName" select="'wmlFilePath'"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="runProps" select="ahf:mergeRunProps($prmRunProps,$filePathRunProp)"/>
        <xsl:apply-templates>
            <xsl:with-param name="prmRunProps" tunnel="yes" select="$runProps"/>
        </xsl:apply-templates>
    </xsl:template>
    
    <!-- 
     function:	userinput element processing
     param:		prmRunProps
     return:	w:r
     note:      Apply italic style.
     -->
    <xsl:template match="*[contains(@class,' sw-d/userinput ')]" priority="5">
        <xsl:param name="prmRunProps" tunnel="yes" required="no" as="element()*" select="()"/>
        <xsl:variable name="userInputRunProp" as="element()*">
            <xsl:call-template name="getWmlObject">
                <xsl:with-param name="prmObjName" select="'wmlUserInput'"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="runProps" select="ahf:mergeRunProps($prmRunProps,$userInputRunProp)"/>
        <xsl:apply-templates>
            <xsl:with-param name="prmRunProps" tunnel="yes" select="$runProps"/>
        </xsl:apply-templates>
    </xsl:template>

    <!-- 
     function:	systemputput element processing
     param:		prmRunProps
     return:	w:r
     note:      Apply italic style.
     -->
    <xsl:template match="*[contains(@class,' sw-d/systemoutput ')]" priority="5">
        <xsl:param name="prmRunProps" tunnel="yes" required="no" as="element()*" select="()"/>
        <xsl:variable name="systemOutputRunProp" as="element()*">
            <xsl:call-template name="getWmlObject">
                <xsl:with-param name="prmObjName" select="'wmlSystemOutput'"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="runProps" select="ahf:mergeRunProps($prmRunProps,$systemOutputRunProp)"/>
        <xsl:apply-templates>
            <xsl:with-param name="prmRunProps" tunnel="yes" select="$runProps"/>
        </xsl:apply-templates>
    </xsl:template>

    <!-- ==== END OF STYLESHEET === -->

</xsl:stylesheet>