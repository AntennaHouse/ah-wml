<?xml version='1.0' encoding="UTF-8" ?>
<!--
****************************************************************
DITA to WordprocessingML Stylesheet
Module: text() maintain utility
Copyright © 2009-2017 Antenna House, Inc. All rights reserved.
Antenna House is a trademark of Antenna House, Inc.
URL    : http://www.antennahouse.com/
E-mail : info@antennahouse.com
****************************************************************
-->
<xsl:stylesheet version="2.0" 
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:xs="http://www.w3.org/2001/XMLSchema"
 xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
 exclude-result-prefixes="xs ahf"
>
    <!-- This stylesheet has following functions:
         1. Make text() map from inline elements with editing information.
         2. Determine ignorable leading space & trailing space.
         3. Return the revised text() map based above analysis.
      -->
    
    <xsl:variable name="cWhiteSpace" as="xs:string+" select="('&#x20;','&#x0A;','&#x09;')"/>
    <xsl:variable name="cOneSpace" as="xs:string" select="'&#x20;'"/>
    
    <!-- 
     function:	Return revised text() map from input inline elements.
     param:		$prmInilines
     return:	document-node()
     note:		Not all text nodes become the processing target.
                For instance text nodes in data, data-about, unknown, xref, image, foreign should be omitted from the target.
                Also some elements such as image, xref, foreign are treated as special inline object.
     -->
    <xsl:template name="ahf:getRevisedTextMap" as="document-node()">
        <xsl:param name="prmNode" as="node()*"/>
        <xsl:param name="prmInFn" as="xs:boolean" tunnel="yes" required="no" select="false()"/>
        <xsl:param name="prmInFloatFig" as="xs:boolean" tunnel="yes" required="no" select="false()"/>
        <xsl:variable name="notInFn" as="xs:boolean" select="not($prmInFn)"/>
        <xsl:variable name="notInFloatFig" as="xs:boolean" select="not($prmInFloatFig)"/>
        <!-- Original text map -->
        <xsl:variable name="textMapOriginal" as="document-node()">
            <xsl:document>
                <xsl:for-each select="$prmNode">
                    <xsl:variable name="node" as="node()" select="."/>
                    <xsl:for-each select="$node/descendant-or-self::text()
                        [(empty(ancestor::*[contains(@class,' topic/fn ')]) and $notInFn) or $prmInFn]
                        [(empty(ancestor::*[contains(@class,' floatfig-d/floatfig ')]) and $notInFloatFig) or $prmInFloatFig]
                        [empty(ancestor::*[ahf:seqContains(string(@class),(' topic/data ',' topic/data-about ',' topic/unknown '))])]
                        [empty(ancestor::*[ahf:seqContains(string(@class),(' topic/indexterm ',' indexing-d/index-see ',' indexing-d/index-see-also '))])]
                        [empty(ancestor::*[ahf:seqContains(string(@class),(' topic/image ', ' topic/foreign '))])]
                        [empty(ancestor::*[contains(string(@class),' topic/xref ')][ahf:isInternalLink(string(@href))])]
                        | $node/descendant-or-self::*[ahf:seqContains(string(@class),(' topic/image ',' topic/foreign '))]
                        | $node/descendant-or-self::*[contains(string(@class),' topic/xref ')][ahf:isInternalLink(string(@href))]">
                        <xsl:choose>
                            <xsl:when test="self::text()">
                                <xsl:variable name="text" as="xs:string" select="string(.)"/>
                                <text>
                                    <xsl:attribute name="id" select="ahf:genHistoryId(.)"/>
                                    <xsl:attribute name="val" select="string(.)"/>
                                    <xsl:attribute name="parent" select="name(parent::*)"/>
                                </text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:element name="{name()}">
                                    <xsl:attribute name="id" select="ahf:genHistoryId(.)"/>
                                    <xsl:attribute name="val" select="'xxxx'"/>
                                    <xsl:attribute name="parent" select="name(parent::*)"/>
                                </xsl:element>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:for-each>
                </xsl:for-each>
            </xsl:document>
        </xsl:variable>
        <!-- White-space combined text map -->
        <xsl:variable name="textMapWsCombined" as="document-node()">
            <xsl:document>
                <xsl:for-each-group select="$textMapOriginal/*" group-adjacent="normalize-space(@val) eq ''">
                    <xsl:choose>
                        <xsl:when test="current-grouping-key() eq true()">
                            <text>
                                <xsl:attribute name="id" select="string-join(for $text in current-group() return string($text/@id), ' ')"/>
                                <xsl:attribute name="val" select="string-join(for $text in current-group() return string($text/@val), '')"/>
                                <xsl:copy-of select="current-group()[1]/@parent"/>
                            </text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:copy-of select="current-group()"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each-group>
            </xsl:document>
        </xsl:variable>
        <!-- text map with attribute -->
        <xsl:variable name="textMapWithAttr" as="document-node()">
            <xsl:document>
                <xsl:for-each select="$textMapWsCombined/*">
                    <xsl:variable name="val" as="xs:string" select="string(@val)"/>
                    <xsl:copy>
                        <xsl:copy-of select="@*"/>
                        <xsl:attribute name="isAllWhiteSpace" select="ahf:isAllWhiteSpace($val)"/>
                        <xsl:attribute name="hasContent" select="not(ahf:isAllWhiteSpace($val))"/>
                        <xsl:attribute name="hasLeadingWhiteSpace" select="ahf:hasLeadingWhiteSpace($val)"/>
                        <xsl:attribute name="hasTrailingWhiteSpace" select="ahf:hasTrailingWhiteSpace($val)"/>
                        <xsl:attribute name="isOneWhiteSpace" select="ahf:isOneWhiteSpace($val)"/>
                    </xsl:copy>
                </xsl:for-each>
            </xsl:document>
        </xsl:variable>
        <!-- Add leading & trailing text information-->
        <xsl:variable name="textMapWithLeadingAndTrailingWhitesSaceInfo">
            <xsl:document>
                <xsl:for-each select="$textMapWithAttr/*">
                    <xsl:copy>
                        <xsl:copy-of select="@*"/>
                        <xsl:attribute name="isLeadingWhiteSpaceText" select="every $text in .|preceding-sibling::* satisfies string($text/@isAllWhiteSpace) eq 'true'"/>
                        <xsl:attribute name="isTrailingWhiteSpaceText" select="every $text in .|following-sibling::* satisfies string($text/@isAllWhiteSpace) eq 'true'"/>
                    </xsl:copy>
                </xsl:for-each>
            </xsl:document>
        </xsl:variable>
        <!-- Genrate revised text -->
        <xsl:variable name="textMapRevised">
            <xsl:document>
                <xsl:for-each select="$textMapWithLeadingAndTrailingWhitesSaceInfo/*">
                    <xsl:variable name="text" as="element()" select="."/>
                    <xsl:variable name="addLeadingSpace" as="xs:boolean" select="ahf:leadingSpace($text)"/>
                    <xsl:variable name="addTrailingSpace" as="xs:boolean" select="ahf:addTrailingSpace($text,$addLeadingSpace)"/>
                    <xsl:copy>
                        <xsl:copy-of select="@*"/>
                        <xsl:attribute name="addLeadingSpace" select="string($addLeadingSpace)"/>
                        <xsl:attribute name="addTrailingSpace" select="string($addTrailingSpace)"/>
                        <xsl:choose>
                            <xsl:when test="(string(@isLeadingWhiteSpaceText) eq 'true') or (string(@isTrailingWhiteSpaceText) eq 'true')">
                                <xsl:attribute name="val" select="''"/>
                            </xsl:when>
                            <xsl:when test="$addLeadingSpace and $addTrailingSpace and (string(@isAllWhiteSpace) eq 'true')">
                                <xsl:attribute name="addTrailingSpace" select="'false'"/>
                                <xsl:attribute name="val" select="'&#x20;'"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:variable name="textValOrg" as="xs:string" select="string(@val)"/>
                                <xsl:variable name="textValRevisedSeq" as="xs:string*">
                                    <xsl:if test="$addLeadingSpace">
                                        <xsl:sequence select="'&#x20;'"/>
                                    </xsl:if>
                                    <xsl:sequence select="normalize-space($textValOrg)"/>
                                    <xsl:if test="$addTrailingSpace">
                                        <xsl:sequence select="'&#x20;'"/>
                                    </xsl:if>
                                </xsl:variable>
                                <xsl:variable name="textValRevised" as="xs:string" select="string-join($textValRevisedSeq,'')"/>
                                <xsl:attribute name="val" select="$textValRevised"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:copy>
                </xsl:for-each>
            </xsl:document>
        </xsl:variable>
        <xsl:sequence select="$textMapRevised"/>        
    </xsl:template>

    <!-- 
     function:	Determine add leading space
     param:		$prmText
     return:	xs:boolean
     note:		
     -->
    <xsl:function name="ahf:leadingSpace" as="xs:boolean">
        <xsl:param name="prmText" as="element()"/>
        <xsl:choose>
            <xsl:when test="string($prmText/@hasLeadingWhiteSpace) eq 'true'">
                <xsl:choose>
                    <xsl:when test="empty($prmText/preceding-sibling::*)">
                        <xsl:sequence select="false()"/>
                    </xsl:when>
                    <xsl:when test="string($prmText/preceding-sibling::*[1]/@isLeadingWhiteSpaceText) eq 'true'">
                        <xsl:sequence select="false()"/>
                    </xsl:when>
                    <xsl:when test="string($prmText/preceding-sibling::*[1]/@hasTrailingWhiteSpace) eq 'true'">
                        <xsl:sequence select="false()"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:sequence select="true()"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!-- 
     function:	Determine add trailing space
     param:		$prmText
     return:	xs:boolean
     note:		
     -->
    <xsl:function name="ahf:addTrailingSpace" as="xs:boolean">
        <xsl:param name="prmText" as="element()"/>
        <xsl:param name="prmAddLeadingSpace" as="xs:boolean?"/>
        <xsl:choose>
            <xsl:when test="string($prmText/@hasTrailingWhiteSpace) eq 'true'">
                <xsl:variable name="precedingSiblingWithTrailingSpace" as="node()?" select="$prmText/preceding-sibling::*[string(@hasContent) eq 'true'][string(@hasTrailingWhiteSpace) eq 'true'][1]"/>
                <xsl:variable name="precedingSiblingWhiteSpaceNode" as="node()*" select="$prmText/preceding-sibling::*[. >> $precedingSiblingWithTrailingSpace]"/>
                <xsl:variable name="isAllWhiteSpace" as="xs:boolean" select="string($prmText/@isAllWhiteSpace) eq 'true'"/>
                <xsl:choose>
                    <xsl:when test="empty($prmText/following-sibling::*)">
                        <xsl:sequence select="false()"/>
                    </xsl:when>
                    <xsl:when test="string($prmText/following-sibling::*[1]/@isTrailingWhiteSpaceText) eq 'true'">
                        <xsl:sequence select="false()"/>
                    </xsl:when>
                    <xsl:when test="exists($prmAddLeadingSpace) and string($prmText/@isOneWhiteSpace) eq 'true'">
                        <xsl:sequence select="false()"/>
                    </xsl:when>
                    <xsl:when test="$isAllWhiteSpace and exists($precedingSiblingWithTrailingSpace) and (exists($precedingSiblingWhiteSpaceNode)) and (every $text in $precedingSiblingWhiteSpaceNode satisfies string($text/@isAllWhiteSpace) eq 'true')">
                        <xsl:sequence select="false()"/>
                    </xsl:when>
                    <xsl:when test="$isAllWhiteSpace and exists($precedingSiblingWithTrailingSpace) and empty($precedingSiblingWhiteSpaceNode)">
                        <xsl:sequence select="false()"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:sequence select="true()"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <!-- 
     function:	Return that $prmText is composed of all white-space
     param:		$prmText
     return:	xs:boolean
     note:		
     -->
    <xsl:function name="ahf:isAllWhiteSpace" as="xs:boolean">
        <xsl:param name="prmText" as="xs:string"/>
        <xsl:sequence select="normalize-space($prmText) eq ''"/>
    </xsl:function>
    
    <!-- 
     function:	Return that $prmText has leading white-space
     param:		$prmText
     return:	xs:boolean
     note:		
     -->
    <xsl:function name="ahf:hasLeadingWhiteSpace" as="xs:boolean">
        <xsl:param name="prmText" as="xs:string"/>
        <xsl:sequence select="substring($prmText,1,1) = $cWhiteSpace"/>
    </xsl:function>
    
    <!-- 
     function:	Return that $prmText has trailing white-space
     param:		$prmText
     return:	xs:boolean
     note:		
     -->
    <xsl:function name="ahf:hasTrailingWhiteSpace" as="xs:boolean">
        <xsl:param name="prmText" as="xs:string"/>
        <xsl:sequence select="substring($prmText,string-length($prmText),1) = $cWhiteSpace"/>
    </xsl:function>
    
    <!-- 
     function:	Return that $prmText is one white-space character
     param:		$prmText
     return:	xs:boolean
     note:		
     -->
    <xsl:function name="ahf:isOneWhiteSpace" as="xs:boolean">
        <xsl:param name="prmText" as="xs:string"/>
        <xsl:sequence select="string-length($prmText) eq 1 and ahf:isAllWhiteSpace($prmText)"/>
    </xsl:function>
    
</xsl:stylesheet>
