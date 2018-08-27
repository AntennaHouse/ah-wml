<?xml version="1.0" encoding="UTF-8" ?>
<!--
**************************************************************
Utility Templates For WordprocessingML
**************************************************************
File Name : dita2wml_unit_doc.xsl
**************************************************************
Copyright © 2009-2018 Antenna House, Inc. All rights reserved.
Antenna House is a trademark of Antenna House, Inc.
URL : http://www.antennahouse.com/
**************************************************************
-->
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
  xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
  xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  exclude-result-prefixes="xs ahf map">

  <!-- 
     function:	Calculate line end position in twip
     param:		prmElem
     return:	xs:integer
     note:		
   -->
  <xsl:function name="ahf:getLineEndPosInTwip" as="xs:integer" visibility="public">
    <xsl:param name="prmElem" as="element()"/>
    <xsl:variable name="isInTwoColumn" as="xs:boolean">
      <xsl:variable name="col" as="xs:integer">
        <xsl:variable name="colInfo" as="xs:integer*" select="map:get($columnMap, ahf:generateId($prmElem))"/>
        <xsl:assert test="exists($colInfo)" select="'[ahf:getLineEndPosInTwip] Empty column info elem=',ahf:getNodeXPathStr($prmElem)"/>
        <xsl:variable name="currentCol" as="xs:integer" select="$colInfo[2]"/>
        <xsl:sequence select="$currentCol"/>                        
      </xsl:variable>
      <xsl:sequence select="$col eq 2"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$isInTwoColumn">
        <xsl:sequence select="(ahf:toTwip($pPaperBodyWidth) - ahf:toTwip($pPaperColumnGap) ) div 2"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="ahf:toTwip($pPaperBodyWidth)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!-- end of stylesheet -->
</xsl:stylesheet>
