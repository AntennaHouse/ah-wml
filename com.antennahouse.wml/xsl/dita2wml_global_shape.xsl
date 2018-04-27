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
            Global Shape Map
         ***************************************-->
    
    <!-- w:drawing//wp:docPr/@id must have unique id value in a document.
         from Ecma Office Open XML Part 1 - Fundamentals And Markup Language Reference page 3110
         "Specifies a unique identifier for the current DrawingML object within the current
          document. This ID can be used to assist in uniquely identifying this object so that it can
          be referred to by other parts of the document.
          If multiple objects within the same document share the same id attribute value, then the
          document shall be considered non-conformant."
     -->
    <!-- shape id offset -->
    <xsl:variable name="shapeIdOffset" as="xs:integer">
        <xsl:call-template name="getVarValueAsInteger">
            <xsl:with-param name="prmVarName" select="'Default_Shape_Id_Offset'"/>
        </xsl:call-template>
    </xsl:variable>

    <!-- shape id map for document contained objects that generates shape
         key:   id (ahf:generateId)
         value: occurrence number
         notes: current target elements are image, note and floatfig
     -->
    <xsl:variable name="shapeIdMap" as="map(xs:string,xs:integer)">
        <xsl:variable name="shapeIds" as="xs:string*">
            <!-- image & note -->
            <xsl:sequence select="/descendant::*[ahf:seqContains(@class, (' topic/image ',' topic/note '))]/ahf:generateId(.)"/>
            <!-- floatfig -->
            <xsl:sequence select="/descendant::*[contains(@class, ' topic/floatfig ')]/ahf:generateId(.)"/>
        </xsl:variable>
        <xsl:map>
            <xsl:for-each select="$shapeIds">
                <xsl:variable name="key" as="xs:string" select="."/>
                <xsl:variable name="id" as="xs:integer" select="position() + $shapeIdOffset"/>
                <xsl:map-entry key="$key" select="$id"/>
            </xsl:for-each>
        </xsl:map>
    </xsl:variable>
    
</xsl:stylesheet>
