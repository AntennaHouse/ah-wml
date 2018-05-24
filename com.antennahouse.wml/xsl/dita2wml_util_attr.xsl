<?xml version="1.0" encoding="UTF-8" ?>
<!--
**************************************************************
Utility Templates
**************************************************************
File Name : dita2wml_util_attr.xsl
**************************************************************
Copyright © 2009 2017 Antenna House, Inc. All rights reserved.
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
         Attribute Utility
      ============================================
    -->

    <!-- 
     function:	Check $prmAttr has $prmValue
     param:		prmAttr, prmValue
     return:	xs:boolean 
     note:		Return true() if $prmAttr attribute has $prmValue
     -->
    <xsl:function name="ahf:hasAttr" as="xs:boolean">
        <xsl:param name="prmAttr" as="attribute()?"/>
        <xsl:param name="prmValue" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="empty($prmAttr)">
                <xsl:sequence select="false()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="attr" as="xs:string" select="string($prmAttr)"/>
                <xsl:variable name="attVals" as="xs:string*" select="tokenize($attr,'[\s]+')"/>
                <xsl:sequence select="$prmValue = $attVals"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <!-- 
     function:	Check $prmAttr has $prmValue at first position
     param:		prmAttr, prmValue
     return:	xs:boolean 
     note:		Return true() if $prmAttr attribute has $prmValue at first position
     -->
    <xsl:function name="ahf:hasAttrAtFirst" as="xs:boolean">
        <xsl:param name="prmAttr" as="attribute()?"/>
        <xsl:param name="prmValue" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="empty($prmAttr)">
                <xsl:sequence select="false()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="attr" as="xs:string" select="string($prmAttr)"/>
                <xsl:variable name="attVals" as="xs:string*" select="tokenize($attr,'[\s]+')"/>
                <xsl:sequence select="$prmValue = $attVals[1]"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <!-- end of stylesheet -->
</xsl:stylesheet>
