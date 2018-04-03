<?xml version="1.0" encoding="UTF-8"?>
<!--
****************************************************************
DITA to WordprocessingML Stylesheet
Module: Making word/theme/theme1.xml main stylesheet.
Copyright © 2009-2018 Antenna House, Inc. All rights reserved.
Antenna House is a trademark of Antenna House, Inc.
URL    : http://www.antennahouse.com/
E-mail : info@antennahouse.com
****************************************************************
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main"
    xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
    exclude-result-prefixes="xs ahf"
    version="3.0">
    
    <!-- This template replaces a:majorFont & a:minorFont contents by style definition.
     -->
    
    <xsl:param name="PRM_FILE_NAME" required="yes" as="xs:string"/>
    <xsl:param name="PRM_FILE_DIR" required="yes" as="xs:string"/>
    
    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
       
    <!--
    function:   document-node template
    param:      none
    return:     display processsing file
    note:       
    -->
    <xsl:template match="/">
        <xsl:message select="concat('[dita2wml_theme_main] Processing=',$PRM_FILE_DIR,'/',$PRM_FILE_NAME)"/>
        <xsl:apply-templates/>
    </xsl:template>

    <!--
    function:   a:theme genral template
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
    function:   a:fontScheme template
    param:      none
    return:     a:fontSchem
    note:       replace a:majorFont & a:minorFont
    -->
    <xsl:template match="a:fontScheme">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <a:majorFont>
                <xsl:call-template name="getWmlObject">
                    <xsl:with-param name="prmObjName" select="'wmlThemeMajorFont'"/>
                </xsl:call-template>
            </a:majorFont>
            <a:minorFont>
                <xsl:call-template name="getWmlObject">
                    <xsl:with-param name="prmObjName" select="'wmlThemeMinorFont'"/>
                </xsl:call-template>
            </a:minorFont>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
