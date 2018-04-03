<?xml version="1.0" encoding="UTF-8" ?>
<!--
****************************************************************
DITA to WordprocessingML Stylesheet
Module: WordprocessingML global constants.
Copyright © 2009-2018 Antenna House, Inc. All rights reserved.
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
>
    <!-- *************************************** 
            Global External Link Constants
         ***************************************-->
    
    <!-- external link id offset -->
    <xsl:variable name="externalLinkIdOffset" as="xs:integer">
        <xsl:call-template name="getVarValueAsInteger">
            <xsl:with-param name="prmVarName" select="'Default_External_Link_Id_Offset'"/>
        </xsl:call-template>
    </xsl:variable>

    <!-- external link id map for document contained xref/link
         key:   @href
         value: occurrence number
     -->
    <xsl:variable name="externalLinkIdMap" as="map(xs:string,xs:integer)">
        <xsl:variable name="externalLinkHrefs" as="xs:string*" select="/descendant::*[ahf:seqContains(@class, (' topic/xref ',' topic/link '))]/@href[ahf:isExternalLink(string(.))]/string(.)"/>
        <xsl:variable name="uniqueExternalHrefs" as="xs:string*" select="distinct-values($externalLinkHrefs)"/>
        <xsl:map>
            <xsl:for-each select="$uniqueExternalHrefs">
                <xsl:variable name="key" as="xs:string" select="."/>
                <xsl:variable name="id" as="xs:integer" select="position() + $externalLinkIdOffset"/>
                <xsl:map-entry key="$key" select="$id"/>
            </xsl:for-each>
        </xsl:map>
    </xsl:variable>
    
</xsl:stylesheet>
