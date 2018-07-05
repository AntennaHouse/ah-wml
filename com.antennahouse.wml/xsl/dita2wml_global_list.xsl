<?xml version="1.0" encoding="UTF-8" ?>
<!--
****************************************************************
DITA to WordprocessingML Stylesheet
Module: WordprocessingML global map for list.
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
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    exclude-result-prefixes="xs ahf map"
>
    <!-- List occurence number map for whole document.
     -->
    <!-- List instances: All ol,ul,related-links -->
    <xsl:variable name="listInstances" as="element()*">
        <xsl:sequence select="doc($pMergedFinalOutputUrl)/*/*[contains(@class,' topic/topic ')]/descendant::*[contains(@class, ' topic/ol ') or contains(@class, ' topic/ul ')]"/>
        <xsl:sequence select="doc($pMergedFinalOutputUrl)/*/*[contains(@class,' topic/topic ')]/descendant::*[contains(@class, ' topic/related-links ')][ahf:isEffectiveRelatedLinks(.)]"/>
    </xsl:variable>
    
    <!-- Unique list instances
         Used for generate w:num/w:numId in numbering.xml
      -->
    <xsl:variable name="uniqueListInstances" as="element()*" select="$listInstances|()"/>

    <!-- map: key=ahf:generateId(.) value=list sequence number
         Used to generate w:p/w:pPr/w:numPr/w:numId/@w:val in document.xml
      -->
    <xsl:variable name="listNumberMap" as="map(xs:string,xs:integer)">
        <xsl:map>
            <xsl:for-each select="$uniqueListInstances">
                <xsl:variable name="position" as="xs:integer" select="position()"/>
                <xsl:variable name="key" as="xs:string" select="ahf:generateId(.)"/>
                <xsl:variable name="value" as="xs:integer" select="$position"/>
                <xsl:map-entry key="$key" select="$value"/>
            </xsl:for-each>
        </xsl:map>
    </xsl:variable>

    <!-- END OF STYLESHEET -->

</xsl:stylesheet>
