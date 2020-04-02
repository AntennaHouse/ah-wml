<?xml version="1.0" encoding="UTF-8" ?>
<!--
****************************************************************
DITA to WordprocessingML Stylesheet
Module: WordprocessingML global constants.
Copyright © 2009-2017 Antenna House, Inc. All rights reserved.
Antenna House is a trademark of Antenna House, Inc.
URL    : http://www.antennahouse.com/
E-mail : info@antennahouse.com
****************************************************************
-->
<xsl:stylesheet version="3.0" 
    xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
    exclude-result-prefixes="xs ahf"
>
    <!-- *************************************** 
            Global Image Constants
         ***************************************-->
    
    <!-- image id offset -->
    <xsl:variable name="imageIdOffset" as="xs:integer">
        <xsl:call-template name="getVarValueAsInteger">
            <xsl:with-param name="prmVarName" select="'Default_Image_Id_Offset'"/>
        </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="commonImageIdOffset" as="xs:integer">
        <xsl:call-template name="getVarValueAsInteger">
            <xsl:with-param name="prmVarName" select="'Default_Common_Image_Id_Offset'"/>
        </xsl:call-template>
    </xsl:variable>

    <!-- image id map for document contained image
         key:   @href
         value: occurrence number
     -->
    <xsl:variable name="imageIdMap" as="map(xs:string,xs:integer)">
        <xsl:variable name="imageHrefs" as="xs:string*" select="//*[@class => contains-token('topic/image')]/@href/string(.)"/>
        <xsl:variable name="uniqueImageHrefs" as="xs:string*" select="distinct-values($imageHrefs)"/>
        <xsl:map>
            <xsl:for-each select="$uniqueImageHrefs">
                <xsl:variable name="key" as="xs:string" select="."/>
                <xsl:variable name="id" as="xs:integer" select="position() + $imageIdOffset"/>
                <xsl:map-entry key="$key" select="$id"/>
            </xsl:for-each>
        </xsl:map>
    </xsl:variable>
    
    <!-- image id map for plug-in common-image folder
         key:   file name
         value: occurrence number
     -->
    <xsl:variable name="commonImageIdMap" as="map(xs:string,xs:integer)">
        <xsl:variable name="imageUriCollection" as="xs:anyURI+" select="uri-collection(concat(xs:string($pPluginDirUrl),'/common-graphic'))"/>
        <xsl:variable name="imageFileNames" as="xs:string+">
            <xsl:for-each select="$imageUriCollection">
                <xsl:variable name="imageUri" as="xs:string" select="xs:string(.)"/>
                <xsl:sequence select="ahf:substringAfterLast($imageUri,'/')"/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:map>
            <xsl:for-each select="$imageFileNames">
                <xsl:variable name="key" as="xs:string" select="."/>
                <xsl:variable name="id" as="xs:integer" select="position() + $commonImageIdOffset"/>
                <xsl:map-entry key="$key" select="$id"/>
            </xsl:for-each>
        </xsl:map>
    </xsl:variable>

</xsl:stylesheet>
