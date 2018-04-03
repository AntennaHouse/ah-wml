<?xml version='1.0' encoding="UTF-8" ?>
<!--
****************************************************************
DITA to WordprocessingML Stylesheet
Module: History id generation template
Copyright © 2017 Antenna House, Inc. All rights reserved.
Antenna House is a trademark of Antenna House, Inc.
URL    : http://www.antennahouse.com/
E-mail : info@antennahouse.com
****************************************************************
-->
<xsl:stylesheet version="3.0" xmlns:fo="http://www.w3.org/1999/XSL/Format"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
    exclude-result-prefixes="xs ahf">
    
    <!-- 
     function:	Generate id using element history (hierarchy)
     param:	    prmNode
     return:	id string
     note:		Newly coded to avoid using generate-id() function.
                2014-09-13 t.makita
                Extend to support all nodes.
                2017-05-26 t.makita
     -->
    <xsl:function name="ahf:genHistoryId" as="xs:string">
        <xsl:param name="prmNode" as="node()"/>
        <xsl:sequence select="ahf:getHistoryStr($prmNode)"/>
    </xsl:function>
    
    <!-- 
     function:    Generate node history (hierarchy) string
     param:       prmNode
     return:      xs:string
     note:        Fixed bug for non well-formed (well-balanced) tree.
                  2014-08-29 t.makita
     -->
    <xsl:function name="ahf:getHistoryStr" as="xs:string">
        <xsl:param name="prmNode" as="node()"/>
        <xsl:variable name="ancestorNode" as="node()+" select="$prmNode/ancestor-or-self::node()[not(self::document-node())]"/>
        <xsl:variable name="historyStr" as="xs:string*">
            <xsl:for-each select="$ancestorNode">
                <xsl:variable name="node" select="."/>
                <xsl:variable name="name" as="xs:string" select="ahf:getNodeName($node)"/>
                <xsl:sequence select="if (position() gt 1) then '.' else ''"/>
                <xsl:sequence select="$name"/>
                <xsl:sequence select="if (exists($node/parent::node()) or exists($node/preceding-sibling::node()|$node/following-sibling::node())) then string(count($node|$node/preceding-sibling::node()[ahf:getNodeName(.) eq $name])) else ''"/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:sequence select="string-join($historyStr,'')"/>
    </xsl:function>

    <xsl:function name="ahf:getNodeName" as="xs:string">
        <xsl:param name="prmNode" as="node()"/>
        <xsl:choose>
            <xsl:when test="$prmNode/self::text()">
                <xsl:sequence select="'text'"/>
            </xsl:when>
            <xsl:when test="$prmNode/self::processing-instruction()">
                <xsl:sequence select="concat('pi-',name($prmNode))"/>
            </xsl:when>
            <xsl:when test="$prmNode/self::comment()">
                <xsl:sequence select="'comment'"/>
            </xsl:when>
            <xsl:when test="$prmNode/self::element()">
                <xsl:sequence select="name($prmNode)"/>
            </xsl:when>
            <xsl:when test="$prmNode/self::attribute()">
                <xsl:sequence select="name($prmNode)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="'unknown'"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <!-- 
     function:    Generate node hierarchy XPath string
     param:       prmNode
     return:      xs:string
     note:        
     -->
    <xsl:function name="ahf:getNodeXPathStr" as="xs:string">
        <xsl:param name="prmNode" as="node()"/>
        <xsl:variable name="ancestorNode" as="node()+" select="$prmNode/ancestor-or-self::node()[not(self::document-node())]"/>
        <xsl:variable name="historyStr" as="xs:string*">
            <xsl:for-each select="$ancestorNode">
                <xsl:variable name="node" select="."/>
                <xsl:variable name="name" as="xs:string" select="ahf:getNodeNameXPath($node)"/>
                <xsl:sequence select="if (position() gt 1) then '/' else ''"/>
                <xsl:sequence select="$name"/>
                <xsl:sequence select="'['"/>
                <xsl:sequence select="if (exists($node/parent::node()) or exists($node/preceding-sibling::node()|$node/following-sibling::node())) then string(count($node|$node/preceding-sibling::node()[ahf:getNodeName(.) eq $name])) else ''"/>
                <xsl:sequence select="']'"/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:sequence select="string-join($historyStr,'')"/>
    </xsl:function>
    
    <xsl:function name="ahf:getNodeNameXPath" as="xs:string">
        <xsl:param name="prmNode" as="node()"/>
        <xsl:choose>
            <xsl:when test="$prmNode/self::text()">
                <xsl:sequence select="'text()'"/>
            </xsl:when>
            <xsl:when test="$prmNode/self::processing-instruction()">
                <xsl:sequence select="concat('processing-instruction(',name($prmNode),')')"/>
            </xsl:when>
            <xsl:when test="$prmNode/self::comment()">
                <xsl:sequence select="'comment()'"/>
            </xsl:when>
            <xsl:when test="$prmNode/self::element()">
                <xsl:sequence select="name($prmNode)"/>
            </xsl:when>
            <xsl:when test="$prmNode/self::attribute()">
                <xsl:sequence select="concat('@',name($prmNode))"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="'unknown??'"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    

</xsl:stylesheet>