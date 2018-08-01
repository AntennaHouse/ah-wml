<?xml version="1.0" encoding="UTF-8" ?>
<!--
**************************************************************
Utility Templates
**************************************************************
File Name : dita2wml_util_node.xsl
**************************************************************
Copyright © 2009-2017 Antenna House, Inc. All rights reserved.
Antenna House is a trademark of Antenna House, Inc.
URL : http://www.antennahouse.com/
**************************************************************
-->
<xsl:stylesheet version="3.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
    exclude-result-prefixes="#all" >
    
    <!-- 
      ============================================
         Node Utility
      ============================================
    -->
    <!-- 
     function:	Get leading white-space only text node of the given node()*
     param:		prmNode
     return:	leading white-space nodes
     note:		
     -->
    <xsl:function name="ahf:getLeadingUnusedNodes" as="node()*">
        <xsl:param name="prmNode" as="node()*"/>
        
        <xsl:variable name="firstNode" as="node()?" select="$prmNode[1]"/>
        <xsl:variable name="isLeadingUnusedNode" as="xs:boolean" select="exists($firstNode[self::text()][not(string(normalize-space(string(.))))]) or 
                                                                         exists($firstNode[self::processing-instruction()]) or
                                                                         exists($firstNode[self::comment()])"/>
        <xsl:choose>
            <xsl:when test="$isLeadingUnusedNode">
                <xsl:sequence select="$prmNode[1] | ahf:getLeadingUnusedNodes($prmNode[position() gt 1])"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <!-- 
     function:	Get trailing white-space only text node or processing instruction or comment of the given node()*
     param:		prmNode
     return:	trailing white-space nodes
     note:		
     -->
    <xsl:function name="ahf:getTrailingUnusedNodes" as="node()*">
        <xsl:param name="prmNode" as="node()*"/>
        
        <xsl:variable name="lastNode" as="node()?" select="$prmNode[position() eq last()]"/>
        <xsl:variable name="isTrailingUnusedNode" as="xs:boolean" select="exists($lastNode[self::text()][not(string(normalize-space(string(.))))]) or 
                                                                          exists($lastNode[self::processing-instruction()]) or
                                                                          exists($lastNode[self::comment()])"/>
        <xsl:choose>
            <xsl:when test="$isTrailingUnusedNode">
                <xsl:sequence select="$prmNode[position() eq last()] | ahf:getTrailingUnusedNodes($prmNode[position() lt last()])"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <!-- 
     function:	Remove leading white-space only text node or processing-instruction or comment of the given node()*
     param:		prmNode
     return:	result nodes
     note:		
     -->
    <xsl:function name="ahf:removeLeadingUnusedNodes" as="node()*">
        <xsl:param name="prmNode" as="node()*"/>
        
        <xsl:variable name="leadingUnusedNodes" as="node()*" select="ahf:getLeadingUnusedNodes($prmNode)"/>
        <xsl:sequence select="$prmNode except $leadingUnusedNodes"/>
    </xsl:function>

    <!-- 
     function:	Remove trailing white-space only text node or processing-instruction or comment of the given node()*
     param:		prmNode
     return:	result nodes
     note:		
     -->
    <xsl:function name="ahf:removeTrailingUnusedNodes" as="node()*">
        <xsl:param name="prmNode" as="node()*"/>
        
        <xsl:variable name="trailingUnusedNodes" as="node()*" select="ahf:getTrailingUnusedNodes($prmNode)"/>
        <xsl:sequence select="$prmNode except $trailingUnusedNodes"/>
    </xsl:function>
    
    <!-- 
     function:	Remove leading & trailing white-space only text node or processing-instruction or comment of the given node()*
     param:		prmNode
     return:	result nodes
     note:		
     -->
    <xsl:function name="ahf:removeLtUnusedNodes" as="node()*">
        <xsl:param name="prmNode" as="node()*"/>
        
        <xsl:variable name="unusedNodes" as="node()*" select="ahf:getLeadingUnusedNodes($prmNode) | ahf:getTrailingUnusedNodes($prmNode)"/>
        <xsl:sequence select="$prmNode except $unusedNodes"/>
    </xsl:function>
    
    <!-- 
     function:	Judge empty element
     param:		prmElem
     return:	xs:boolean
     note:		
     -->
    <xsl:function name="ahf:isNotEmptyElement" as="xs:boolean">
        <xsl:param name="prmElem" as="element()"/>
        <xsl:sequence select="not(ahf:isEmptyElement($prmElem))"/>
    </xsl:function>        
    
    <xsl:function name="ahf:isEmptyElement" as="xs:boolean">
        <xsl:param name="prmElem" as="element()"/>
        <xsl:choose>
            <xsl:when test="empty($prmElem/node())">
                <xsl:sequence select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="every $node in $prmElem/node() satisfies ahf:isRedundantNode($node)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="ahf:isRedundantNode" as="xs:boolean">
        <xsl:param name="prmNode" as="node()"/>
        <xsl:choose>
            <xsl:when test="$prmNode/self::comment()">
                <xsl:sequence select="true()"/>
            </xsl:when>
            <xsl:when test="$prmNode/self::processing-instruction()">
                <xsl:sequence select="true()"/>
            </xsl:when>
            <xsl:when test="$prmNode/self::text()">
                <xsl:choose>
                    <xsl:when test="not(string(normalize-space($prmNode)))">
                        <xsl:sequence select="true()"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:sequence select="false()"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$prmNode/self::element()">
                <xsl:sequence select="false()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="true()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <!-- 
     function:	Get first preceding elememnt
     param:		prmElem
     return:	element()?
     note:		
     -->
    <xsl:function name="ahf:getFirstPrecedingElemWoWh" as="element()?">
        <xsl:param name="prmElem" as="element()?"/>
        <xsl:variable name="precedingFirstElem" as="element()?" select="$prmElem/preceding-sibling::*[1]"/>
        <xsl:choose>
            <xsl:when test="empty($precedingFirstElem)">
                <xsl:sequence select="()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="nodesBetween" as="node()*" select="$prmElem/preceding-sibling::node()[. &gt;&gt; $precedingFirstElem]"/>
                <xsl:choose>
                    <xsl:when test="empty($nodesBetween)">
                        <xsl:sequence select="$precedingFirstElem"/>
                    </xsl:when>
                    <xsl:when test="every $node in $nodesBetween satisfies ahf:isRedundantNode($node)">
                        <xsl:sequence select="$precedingFirstElem"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:sequence select="()"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <!-- end of stylesheet -->
</xsl:stylesheet>
