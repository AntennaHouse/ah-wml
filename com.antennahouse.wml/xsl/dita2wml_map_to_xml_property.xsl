<?xml version="1.0" encoding="UTF-8"?>
<!--
****************************************************************
DITA to WordprocessingML Stylesheet
Module: Map to XML property file templates
Copyright © 2013-2018 Antenna House, Inc. All rights reserved.
Antenna House is a trademark of Antenna House, Inc.
URL    : http://www.antennahouse.com/
****************************************************************
-->
<xsl:stylesheet version="3.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
    exclude-result-prefixes="xs ahf" 
    >
    <!-- This stylesheet constructs XML file that has following element:
         map/xml.lang: 
         - The map/@xml:lang value.
         - If PRM_XML_LANG is specified, it is honored than map/@xml:lang.
         This XML file can be referenced from ant xmlproperty task.
            <xmlproperty file="[This output file]"/>
         To get the xml:lang use ${map.xml.lang} in ant script.
         This property will be used for selecting .docx template file.
      -->
    
    <!-- DITA-OT map directory -->
    <xsl:param name="PRM_MAP_DIR" as="xs:string" required="yes"/>
    <!-- DITA-OT temporary directory -->
    <xsl:param name="PRM_TEMP_DIR" as="xs:string" required="yes"/>
    <!-- xm.lang property passed to ant -->
    <xsl:param name="PRM_XML_LANG" as="xs:string" required="no" select="''"/>
    
    <!-- 
     function:	map matching template
     param:		none
     return:	<map> element.
     note:		
     -->
    <xsl:template match="*[@class => contains-token('map/map')]">
        <xsl:message select="'$PRM_MAP_DIR=',$PRM_MAP_DIR"/>
        <xsl:message select="'$PRM_TEMP_DIR=',$PRM_TEMP_DIR"/>
        <xsl:element name="map">
            <xsl:choose>
                <xsl:when test="string($PRM_XML_LANG)">
                    <xsl:element name="xml.lang">
                        <xsl:value-of select="$PRM_XML_LANG"/>
                    </xsl:element>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:element name="xml.lang">
                        <xsl:value-of select="string(@xml:lang)"/>
                    </xsl:element>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:element>
    </xsl:template>
    
</xsl:stylesheet>