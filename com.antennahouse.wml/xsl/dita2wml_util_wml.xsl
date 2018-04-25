<?xml version="1.0" encoding="UTF-8" ?>
<!--
**************************************************************
Utility Templates For WordprocessingML
**************************************************************
File Name : dita2wml_unit_wml.xsl
**************************************************************
Copyright © 2009-2017 Antenna House, Inc. All rights reserved.
Antenna House is a trademark of Antenna House, Inc.
URL : http://www.antennahouse.co.jp/
**************************************************************
-->
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
  xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
  exclude-result-prefixes="xs ahf">
  <!-- 
      ============================================
         WordprocessingML utility
      ============================================
    -->
  <!-- styles.xml document -->
  <xsl:variable name="templateStyleDoc" as="document-node()?" select="doc(string($pTemplateStyle))"/>

  <!-- numbering.xml document -->
  <xsl:variable name="templateNumberingDoc" as="document-node()?" select="doc(string($pTemplateNumbering))"/>
  
  <!-- base style font size (in half point) -->
  <xsl:variable name="baseStyleFontSize" as="xs:integer">
    <xsl:variable name="baseStyleElem" as="element()" select="$templateStyleDoc/w:style[string(@w:type) eq 'paragraph'][string(@w:default) eq '1']"/>
    <xsl:choose>
      <xsl:when test="$baseStyleElem/w:rPr/w:sz/@w:val">
        <xsl:sequence select="xs:integer($baseStyleElem/w:rPr/w:sz/@w:val)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="21"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  
  <!-- document.xml document -->
  <xsl:variable name="templateDocumentDoc" as="document-node()?"
    select="doc(string($pTemplateDocument))"/>

  <!-- 
     function:	Get style id from style name
     param:		prmStyleName
     return:	style id string
     note:		w:aliases/@w:val can contain multiple aliases style names by delimiting with ",".
     -->
  <xsl:function name="ahf:getStyleIdFromName" as="xs:string" visibility="public">
    <xsl:param name="prmStyleName" as="xs:string"/>
    <xsl:choose>
      <xsl:when
        test="$templateStyleDoc/w:styles/w:style[string(w:name/@w:val) eq $prmStyleName]/@w:styleId">
        <xsl:sequence
          select="string($templateStyleDoc/w:styles/w:style[string(w:name/@w:val) eq $prmStyleName]/@w:styleId)"
        />
      </xsl:when>
      <xsl:when
        test="$templateStyleDoc/w:styles/w:style[$prmStyleName = tokenize(string(w:aliases/@w:val), ',')]/@w:styleId">
        <xsl:sequence
          select="string($templateStyleDoc/w:styles/w:style[$prmStyleName = tokenize(string(w:aliases/@w:val), ',')]/@w:styleId)"
        />
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="warningContinue">
          <xsl:with-param name="prmMes" select="ahf:replace($stMes2010, ('%name'), ($prmStyleName))"
          />
        </xsl:call-template>
        <xsl:sequence select="''"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!-- 
     function:	Get abstractNumId from paragraph style names
     param:		prmStyleName
     return:	abstractNumId
     note:		
     -->
  <xsl:function name="ahf:getAbstractNumIdFromStyleName" as="xs:string">
    <xsl:param name="prmStyleName" as="xs:string"/>
    <xsl:variable name="paraStyleId" as="xs:string" select="ahf:getStyleIdFromName($prmStyleName)"/>
    <xsl:variable name="abstractNumId" as="xs:string">
      <xsl:variable name="abstractNumIdFromInstance" as="xs:string">
        <xsl:variable name="numId" as="xs:string" select="string(($templateDocumentDoc/w:document/w:body/w:p[string(w:pPr/w:pStyle/@w:val) eq $paraStyleId]/w:pPr/w:numPr/w:numId/@w:val)[1])"/>
        <xsl:sequence select="string($templateNumberingDoc/w:numbering/w:num[string(@w:numId) eq $numId]/w:abstractNumId/@w:val)"/>
      </xsl:variable>
      <xsl:variable name="abstractNumIdFromStyle" as="xs:string">
        <xsl:variable name="numId" as="xs:string" select="string($templateStyleDoc/w:styles/w:style[string(@w:styleId) eq $paraStyleId]/w:pPr/w:numPr/w:numId/@w:val)"/>
        <xsl:sequence select="string($templateNumberingDoc/w:numbering/w:num[string(@w:numId) eq $numId]/w:abstractNumId/@w:val)"/>
      </xsl:variable>
      <xsl:choose>
        <xsl:when test="string($abstractNumIdFromInstance)">
          <xsl:sequence select="$abstractNumIdFromInstance"/>
        </xsl:when>
        <xsl:when test="string($abstractNumIdFromStyle)">
          <xsl:sequence select="$abstractNumIdFromStyle"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="''"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="string($abstractNumId)">
        <xsl:sequence select="$abstractNumId"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="warningContinue">
          <xsl:with-param name="prmMes" select="ahf:replace($stMes2012, ('%name'), ($prmStyleName))"/>
        </xsl:call-template>
        <xsl:sequence select="''"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!-- 
     function:	Get left-indent from list level
     param:		prmIndentLevel, prmExtraIndent
     return:	indent value in twip
     note:		
     -->
  <xsl:function name="ahf:getIndentFromIndentLevel" as="xs:integer">
    <xsl:param name="prmIndentLevel" as="xs:integer"/>
    <xsl:param name="prmExtraIndent" as="xs:integer"/>
    <xsl:sequence select="$pListBaseIndentSizeInTwip + $prmIndentLevel * $pListIndentSizeInTwip + $prmExtraIndent"/>
  </xsl:function>

  <xsl:function name="ahf:getIndentFromIndentLevelInEmu" as="xs:integer">
    <xsl:param name="prmIndentLevel" as="xs:integer"/>
    <xsl:param name="prmExtraIndent" as="xs:integer"/>
    <xsl:sequence select="$pListBaseIndentSizeInEmu + $prmIndentLevel * $pListIndentSizeInEmu + ahf:toEmu(concat(string($prmExtraIndent),'twip'))"/>
  </xsl:function>

  <!-- 
     function:	Get w:numId from li
     param:		prmLi
     return:	w:numId of given list
     note:		
     -->
  <xsl:function name="ahf:getNumIdFromLi" as="xs:string">
    <xsl:param name="prmLi" as="element()"/>
    <xsl:choose>
      <xsl:when test="$prmLi/parent::*[contains(@class,' topic/ol ')]">
        <xsl:sequence select="$olAbstractNumId"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$ulAbstractNumId"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!-- 
     function:	Get list style name from li
     param:		prmLi
     return:	style name
     note:		
     -->
  <xsl:function name="ahf:getStyleNameFromLi" as="xs:string">
    <xsl:param name="prmLi" as="element()"/>
    <xsl:choose>
      <xsl:when test="$prmLi/parent::*[contains(@class,' topic/ol ')]">
        <xsl:sequence select="$cOlStyleName"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$cUlStyleName"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <!-- 
     function:	Get w:numId from list occurence number
     param:		prmListOccurenceNumber
     return:	w:numId value
     note:		
     -->
  <xsl:function name="ahf:getNumIdFromListOccurenceNumber" as="xs:string">
    <xsl:param name="prmListNumber" as="xs:integer"/>
    <xsl:sequence select="string($numIdBaseForList + $prmListNumber)"/>
  </xsl:function>

  <!-- 
     function:	Get w:ilvl from list level
     param:		prmListLevel
     return:	w:ilvl value
     note:		
     -->
  <xsl:function name="ahf:getIlvlFromListLevel" as="xs:integer">
    <xsl:param name="prmListLevel" as="xs:integer"/>
    <xsl:sequence select="$prmListLevel - 1"/>
  </xsl:function>

  <!-- 
     function:	Get w:ilvl from topic level
     param:		prmTopicLevel
     return:	w:ilvl value
     note:		
     -->
  <xsl:function name="ahf:getIlvlFromTopicLevel" as="xs:integer">
    <xsl:param name="prmTopicLevel" as="xs:integer"/>
    <xsl:sequence select="$prmTopicLevel - 1"/>
  </xsl:function>

  <!-- 
     function:	Get hanging-indent from style name and list level
     param:		prmStyleName, prmListLevel
     return:	w:hanging value in twip
     note:		
     -->
  <xsl:function name="ahf:getHangingFromStyleNameAndLevel" as="xs:integer">
    <xsl:param name="prmStyleName" as="xs:string"/>
    <xsl:param name="prmListLevel" as="xs:integer"/>
    <xsl:variable name="absNumId" as="xs:string" select="ahf:getAbstractNumIdFromStyleName($prmStyleName)"/>
    <xsl:variable name="w:abstractNum" as="element()" select="$templateNumberingDoc/w:numbering/w:abstractNum[string(@w:abstractNumId) eq $absNumId]"/>
    <xsl:variable name="w:lvl" as="element()?">
      <xsl:choose>
        <xsl:when test="$w:abstractNum/w:multiLevelType/@w:val/string(.) eq 'singleLevel'">
          <xsl:sequence select="$w:abstractNum/w:lvl[string(@w:ilvl) eq '0']"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="$w:abstractNum/w:lvl[string(@w:ilvl) eq string(($prmListLevel - 1))]"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="hanging" as="xs:string?" select="$w:lvl/w:pPr/w:ind/@w:hanging/string(.)"/>
    <xsl:variable name="hangingChars" as="xs:string?" select="$w:lvl/w:pPr/w:ind/@w:hangingChars/string(.)"/>
    <xsl:choose>
      <xsl:when test="string($hangingChars)">
        <xsl:variable name="hangingInPt" select="concat(string((xs:integer($hangingChars) div 100) * ($baseStyleFontSize div 2)),'pt')"/>
        <xsl:sequence select="ahf:toTwip($hangingInPt)"/>
      </xsl:when>
      <xsl:when test="string($hanging)">
        <xsl:sequence select="xs:integer($hanging)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="0"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!-- 
     function:	Get border with from any unit of value
     param:		prmUnitValue
     return:	The size in eighths of a point
     note:		This function is WordprocessingML specific
     -->
  <xsl:function name="ahf:toBorderWidth" as="xs:string" visibility="public">
    <xsl:param name="prmUnitValue" as="xs:string"/>
    <xsl:variable name="ptValue" as="xs:double" select="ahf:toPt($prmUnitValue)"/>
    <xsl:sequence select="string($ptValue * 8)"/>
  </xsl:function>

  <!-- 
     function:	Get paragraph alignment element
     param:		prmAlign
     return:	w:jc
     note:		
     -->
  <xsl:function name="ahf:getAlignAttrElem" as="element(w:jc)?" visibility="public">
    <xsl:param name="prmAlign" as="xs:string?"/>
    <xsl:variable name="alignSpecSeq" as="xs:string+" select="('left','right','center')"/>
    <xsl:variable name="wmlAlignSpecSeq" as="xs:string+" select="('start','end','center')"/>
    <xsl:choose>
      <xsl:when test="$prmAlign = $alignSpecSeq">
        <xsl:variable name="index" as="xs:integer" select="index-of($alignSpecSeq,$prmAlign)"/>
        <w:jc>
          <xsl:attribute name="w:val" select="$wmlAlignSpecSeq[$index]"/>
        </w:jc>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="()"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!-- 
     function:	Get paragraph indent element
     param:		prmIndentLevel, prmExtraIndent
     return:	w:ind
     note:		
   -->
  <xsl:function name="ahf:getIndentAttrElem" as="element(w:ind)?" visibility="public">
    <xsl:param name="prmIndentLevel" as="xs:integer"/>
    <xsl:param name="prmExtraIndent" as="xs:integer"/>
    <xsl:choose>
      <xsl:when test="($prmIndentLevel gt 0) or ($prmExtraIndent gt 0)">
        <xsl:variable name="startIndent" as="xs:integer" select="ahf:getIndentFromIndentLevel($prmIndentLevel, $prmExtraIndent)"/>
        <w:ind>
          <xsl:attribute name="w:left" select="$startIndent"/>
        </w:ind>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="()"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <!-- 
     function:	Get RGB hexiadecimal value from RGB integers
     param:		prmR, prmG, prmB
     return:	xs:string
     note:		all of the parameter must be 0 <= prm <= 255
   -->
  <xsl:function name="ahf:toRgbHexWS" as="xs:string" visibility="public">
    <xsl:param name="prmR" as="xs:integer"/>
    <xsl:param name="prmG" as="xs:integer"/>
    <xsl:param name="prmB" as="xs:integer"/>
    <xsl:sequence select="concat('#',ahf:toRgbHexWoS($prmR,$prmG,$prmB))"/>
  </xsl:function>

  <xsl:function name="ahf:toRgbHexWoS" as="xs:string" visibility="public">
    <xsl:param name="prmR" as="xs:integer"/>
    <xsl:param name="prmG" as="xs:integer"/>
    <xsl:param name="prmB" as="xs:integer"/>
    <xsl:variable name="r" as="xs:string" select="concat('00',ahf:intToHexString($prmR))"/>
    <xsl:variable name="g" as="xs:string" select="concat('00',ahf:intToHexString($prmG))"/>
    <xsl:variable name="b" as="xs:string" select="concat('00',ahf:intToHexString($prmB))"/>
    <xsl:sequence select="concat(substring($r,string-length($r) - 1),substring($g,string-length($g) - 1),substring($b,string-length($b) - 1))"/>
  </xsl:function>
  
  <!-- end of stylesheet -->
</xsl:stylesheet>
