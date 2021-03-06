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
    exclude-result-prefixes="xs ahf"
>
    <!-- *************************************** 
            Global Drawing Map
         ***************************************-->
    
    <!-- w:drawing//wp:docPr/@id must have unique id value in a document.
         from Ecma Office Open XML Part 1 - Fundamentals And Markup Language Reference page 3110
         "Specifies a unique identifier for the current DrawingML object within the current
          document. This ID can be used to assist in uniquely identifying this object so that it can
          be referred to by other parts of the document.
          If multiple objects within the same document share the same id attribute value, then the
          document shall be considered non-conformant."
     -->
    <!-- drawing id offset -->
    <xsl:variable name="drawingIdOffset" as="xs:integer">
        <xsl:call-template name="getVarValueAsInteger">
            <xsl:with-param name="prmVarName" select="'Default_Drawing_Id_Offset'"/>
        </xsl:call-template>
    </xsl:variable>

    <!-- shape id map for document contained objects that generates shape
         key:   id (ahf:generateId)
         value: occurrence number
         notes: current target elements are image, note and floatfig
     -->
    <xsl:variable name="drawingIdMap" as="map(xs:string,xs:integer)">
        <xsl:variable name="drawingIds" as="xs:string*">
            <!-- image & note -->
            <xsl:sequence select="/descendant::*[@class => ahf:seqContainsToken(('topic/image','topic/note'))]/ahf:generateId(.)"/>
            <!-- floatfig -->
            <xsl:sequence select="/descendant::*[@class => contains-token('floatfig-d/floatfig')][string(@float) = ('left','right')]/ahf:generateId(.)"/>
            <xsl:sequence select="/descendant::*[@class => contains-token('floatfig-d/floatfig-group')][string(@float) = ('left','right')]/ahf:generateId(.)"/>
            <!-- cover bodydiv -->
            <xsl:choose>
                <xsl:when test="$isBookMap">
                    <xsl:for-each select="$map/*[@class => ahf:seqContainsToken(('bookmap/frontmatter','bookmap/backmatter'))]/*[@class => contains-token('map/topicref')][. => ahf:isCoverTopicRef()]">
                        <xsl:variable name="topicRef" as="element()" select="."/>
                        <xsl:variable name="topicContent"  as="element()?" select="ahf:getTopicFromTopicRef($topicRef)"/>
                        <xsl:if test="exists($topicContent)">
                            <xsl:sequence select="$topicContent/*[@class => contains-token('topic/body')]/*[@class => contains-token('topic/bodydiv')]/ahf:generateId(.)"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:for-each select="$map/*[@class => contains-token('map/topicref')][ahf:isCoverTopicRef(.)]">
                        <xsl:variable name="topicRef" as="element()" select="."/>                        
                        <xsl:variable name="topicContent"  as="element()?" select="ahf:getTopicFromTopicRef($topicRef)"/>
                        <xsl:if test="exists($topicContent)">
                            <xsl:sequence select="$topicContent/*[@class => contains-token('topic/body')]/*[@class => contains-token('topic/bodydiv')]/ahf:generateId(.)"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:map>
            <xsl:for-each select="$drawingIds">
                <xsl:variable name="key" as="xs:string" select="."/>
                <xsl:variable name="id" as="xs:integer" select="position() + $drawingIdOffset"/>
                <xsl:map-entry key="$key" select="$id"/>
            </xsl:for-each>
        </xsl:map>
    </xsl:variable>
    
</xsl:stylesheet>
