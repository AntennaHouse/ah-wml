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
>
    <!-- *************************************** 
            Global fn Constants
         ***************************************-->
    
    <!-- image id offset -->
    <xsl:variable name="fnIdOffset" as="xs:integer">
        <xsl:call-template name="getVarValueAsInteger">
            <xsl:with-param name="prmVarName" select="'Default_Fn_Id_Offset'"/>
        </xsl:call-template>
    </xsl:variable>

    <!-- fn id map
         key:   ahf:generateId
         value: occurrence number (used w:footnote/@id & 
     -->
    <xsl:variable name="fnIdMap" as="map(xs:string,xs:integer)">
        <xsl:variable name="fnIds" as="xs:string*" select="/descendant::*[contains(@class, ' topic/fn ')]/ahf:generateId(.)"/>
        <xsl:map>
            <xsl:for-each select="$fnIds">
                <xsl:variable name="key" as="xs:string" select="."/>
                <xsl:variable name="id" as="xs:integer" select="position() + $fnIdOffset"/>
                <xsl:map-entry key="$key" select="$id"/>
            </xsl:for-each>
        </xsl:map>
    </xsl:variable>

</xsl:stylesheet>
