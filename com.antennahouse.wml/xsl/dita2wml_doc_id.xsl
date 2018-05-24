<?xml version="1.0" encoding="UTF-8"?>
<!--
**************************************************************
DITA to WordprocessingML Stylesheet
Id attribute related function
**************************************************************
File Name : dita2wml_doc_id.xsl
**************************************************************
Copyright © 2009 2017 Antenna House, Inc. All rights reserved.
Antenna House is a trademark of Antenna House, Inc.
URL : http://www.antennahouse.com/
**************************************************************
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:w="http://purl.oclc.org/ooxml/wordprocessingml/main"
    xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
    exclude-result-prefixes="xs ahf"
    version="3.0">
    
    <!-- 
     function:	Get ID attribute of given element
     param:		prmElement
     return:	attribute node
     note:		Use template version for normal context such as topic/body/p.
                In most cases we can omit paramters.
                <xsl:call-template name="ahf:getIdAtts"/>
                Use function version for the special context such as generateing id for title.
                We can explicitly specify parameters for this case.
     -->
    <xsl:function name="ahf:getIdAtt" as="attribute()">
        <xsl:param name="prmElement"  as="element()"/>
        
        <xsl:call-template name="ahf:getIdAtt">
            <xsl:with-param name="prmElement" select="$prmElement"/>
        </xsl:call-template>
        
    </xsl:function>
    
    <xsl:template name="ahf:getIdAtt" as="attribute()*">
        <xsl:param name="prmElement"  as="element()" required="no" select="."/>
        
        <xsl:choose>
            <!-- topicref -->
            <xsl:when test="contains($prmElement/@class, ' map/topicref ')">
                <xsl:choose>
                    <xsl:when test="$prmElement/@id">
                        <xsl:attribute name="id">
                            <xsl:value-of select="$prmElement/@id"/>
                        </xsl:attribute>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="id">
                            <xsl:value-of select="ahf:generateId($prmElement)"/>
                        </xsl:attribute>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <!-- id-atts: id -->
            <xsl:when test="($prmElement/@id)">
                <xsl:variable name="id" select="$prmElement/@id" as="attribute()"/>
                <xsl:variable name="oid" select="$prmElement/@oid" as="attribute()"/>
                <xsl:choose>
                    <xsl:when test="contains($prmElement/@class, ' topic/topic ')">
                        <!-- Topic 
                         -->
                        <xsl:choose>
                            <xsl:when test="$pUseOid">
                                <!-- Adopt "oid". -->
                                <xsl:attribute name="id">
                                    <xsl:value-of select="string($oid)"/>
                                </xsl:attribute>
                            </xsl:when>
                            <xsl:otherwise>
                                <!-- Adopt DITA-OT's id:"uniqueN" -->
                                <xsl:sequence select="$id"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- Other local elements 
                             The id attribute must be unique only within the topic.
                             This stylesheet make them unique in whole document.
                             
                             "Note: Thus, within a single XML document containing multiple peer or nested topics, the
                              IDs of the non-topic elements only need to be unique within each topic without regard 
                              to the IDs of elements within any ancestor or descendant topics."
                              http://docs.oasis-open.org/dita/v1.2/cs01/spec/archSpec/id.html
                              
                              * However the parser does not report error when duplicate id exist in one topic.
                             
                        -->
                        <xsl:variable name="parentTopic" select="$prmElement/ancestor::*[contains(@class, ' topic/topic ')][1]" as="element()?"/>
                        <xsl:choose>
                            <xsl:when test="$pUseOid">
                                <!-- add topic/oid to every id as prefix to make it unique -->
                                <xsl:variable name="topicOid" 
                                    select="string($prmElement/ancestor::*[contains(@class, ' topic/topic ')][1]/@oid)" as="xs:string"/>
                                <!-- normal pattern -->
                                <xsl:attribute name="id">
                                    <xsl:value-of select="$topicOid"/>
                                    <xsl:value-of select="$idSeparator"/>
                                    <xsl:value-of select="$id"/>
                                </xsl:attribute>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:variable name="topicId" 
                                    select="string($prmElement/ancestor::*[contains(@class, ' topic/topic ')][1]/@id)" as="xs:string"/>
                                <xsl:attribute name="id">
                                    <xsl:value-of select="$topicId"/>
                                    <xsl:value-of select="$idSeparator"/>
                                    <xsl:value-of select="$id"/>
                                </xsl:attribute>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <!-- 
     function:	Generate unique id cosidering multiple topic reference
     param:		prmElement,prmTopicRef
     return:	id string
     note:		About the indexterm in topicref/topicmeta, the parameter 
                $prmTopicRef is empty.
     -->
    <xsl:function name="ahf:generateId" as="xs:string">
        <xsl:param name="prmElement" as="element()"/>
        <xsl:call-template name="ahf:generateId">
            <xsl:with-param name="prmElement" select="$prmElement"/>
        </xsl:call-template>
    </xsl:function>
    
    <xsl:template name="ahf:generateId" as="xs:string">
        <xsl:param name="prmElement" required="no" as="element()" select="."/>
        <xsl:sequence select="ahf:genHistoryId($prmElement)"/>
    </xsl:template>
    
</xsl:stylesheet>