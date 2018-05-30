<?xml version="1.0" encoding="UTF-8"?>
<!--
**************************************************************
Utility Templates
**************************************************************
File Name : dita2wml_util_string.xsl
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
         String utility
      ============================================
    -->
    <!--
    function: String Utility
    param: see below
    note: return the sub-string before or after of the LAST delimiter
    -->
    <xsl:function name="ahf:substringBeforeLast" as="xs:string">
        <xsl:param name="prmSrcString" as="xs:string"/>
        <xsl:param name="prmDlmString" as="xs:string"/>
        <xsl:call-template name="substringBeforeLast">
            <xsl:with-param name="prmSrcString" select="$prmSrcString"/>
            <xsl:with-param name="prmDlmString" select="$prmDlmString"/>
        </xsl:call-template>
    </xsl:function>

    <xsl:template name="substringBeforeLast">
    	<xsl:param name="prmSrcString" required="yes" as="xs:string"/>
    	<xsl:param name="prmDlmString" required="yes" as="xs:string"/>
    	
    	<xsl:variable name="substringBefore" select="substring-before($prmSrcString, $prmDlmString)"/>
    	<xsl:variable name="substringAfter" select="substring-after($prmSrcString, $prmDlmString)"/>
    	<xsl:choose>
    		<xsl:when test="contains($substringAfter, $prmDlmString)">
    			<xsl:variable name="restResult">
    				<xsl:call-template name="substringBeforeLast">
    					<xsl:with-param name="prmSrcString" select="$substringAfter"/>
    					<xsl:with-param name="prmDlmString" select="$prmDlmString"/>
    				</xsl:call-template>
    			</xsl:variable>
    			<xsl:value-of select="concat($substringBefore, $prmDlmString, $restResult)"/>
    		</xsl:when>
    		<xsl:otherwise>
    			<xsl:value-of select="$substringBefore"/>
    		</xsl:otherwise>
    	</xsl:choose>
    </xsl:template>
    
    <xsl:function name="ahf:substringAfterLast" as="xs:string">
    	<xsl:param name="prmSrcString" as="xs:string"/>
    	<xsl:param name="prmDlmString" as="xs:string"/>
    	
    	<xsl:variable name="substringBefore" select="substring-before($prmSrcString, $prmDlmString)"/>
    	<xsl:variable name="substringAfter" select="substring-after($prmSrcString, $prmDlmString)"/>
    	<xsl:choose>
    		<xsl:when test="not(contains($prmSrcString, $prmDlmString))">
    			<xsl:sequence select="$prmSrcString"/>
    		</xsl:when>
    		<xsl:when test="contains($substringAfter, $prmDlmString)">
    			<xsl:sequence select="ahf:substringAfterLast($substringAfter, $prmDlmString)"/>
    		</xsl:when>
    		<xsl:otherwise>
    			<xsl:sequence select="$substringAfter"/>
    		</xsl:otherwise>
    	</xsl:choose>
    </xsl:function>
    
    <!--
        function: Convert back-slash to slash
        param: prmString
        note: Result string
    -->
    <xsl:function name="ahf:bsToSlash" as="xs:string">
        <xsl:param name="prmStr" as="xs:string"/>
        <xsl:sequence select="translate($prmStr,'&#x005C;','/')"/>
    </xsl:function>

    <!--
     function: escapeForRegx
     param:    prmSrcString
     return:   Escaped xs:string
     note:     Original code by Priscilla Walmsley.
               http://www.xsltfunctions.com/xsl/functx_escape-for-regex.html
    -->
    <xsl:function name="ahf:escapeForRegxDst" as="xs:string">
        <xsl:param name="prmSrcString" as="xs:string"/>
        <xsl:sequence select="replace($prmSrcString,'(\\|\$)','\\$1')"/>
    </xsl:function>
    
    <xsl:function name="ahf:escapeForRegxSrc" as="xs:string">
        <xsl:param name="prmSrcString" as="xs:string"/>
        <xsl:sequence select="replace($prmSrcString,'(\.|\[|\]|\\|\||\-|\^|\$|\?|\*|\+|\{|\}|\(|\))','\\$1')"/>
    </xsl:function>

    <!--
        function: Safe replace function
        param: prmStr,prmSrc,prmDst
        note: Result string
    -->
    <xsl:function name="ahf:safeReplace" as="xs:string">
        <xsl:param name="prmStr" as="xs:string"/>
        <xsl:param name="prmSrc" as="xs:string"/>
        <xsl:param name="prmDst" as="xs:string"/>
        <xsl:sequence select="replace($prmStr,ahf:escapeForRegxSrc($prmSrc),ahf:escapeForRegxDst($prmDst))"/>
    </xsl:function>
    
    <!--
        function: Multiple replace function
        param: prmStr,prmSrc,prmDst
        note: Result string
    -->
    <xsl:function name="ahf:replace" as="xs:string">
        <xsl:param name="prmStr" as="xs:string"/>
        <xsl:param name="prmSrc" as="xs:string+"/>
        <xsl:param name="prmDst" as="xs:string+"/>
    
        <xsl:variable name="firstResult" select="ahf:safeReplace($prmStr,$prmSrc[1],$prmDst[1])" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="exists($prmSrc[2]) and exists($prmDst[2])">
                <xsl:sequence select="ahf:replace($firstResult,subsequence($prmSrc,2),subsequence($prmDst,2))"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="$firstResult"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <!--
        function: Multiple replace function
        param: prmStr,prmSrc,prmDst
        return: Result string
        note: This function accespts $prmDst as item()+.
              If $prmDst is not instance of xs:string, the processing is skipped.
    -->
    <xsl:function name="ahf:extReplace" as="item()">
        <xsl:param name="prmStr" as="xs:string"/>
        <xsl:param name="prmSrc" as="xs:string+"/>
        <xsl:param name="prmDst" as="item()+"/>
        
        <xsl:variable name="firstResult" select="if ($prmDst[1] instance of xs:string) then ahf:safeReplace($prmStr,$prmSrc[1],$prmDst[1]) else $prmStr" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="exists($prmSrc[2]) and exists($prmDst[2])">
                <xsl:sequence select="ahf:extReplace($firstResult,subsequence($prmSrc,2),subsequence($prmDst,2))"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="$firstResult"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <!--
        function: Node replace function
        param: prmStr,prmSrc,prmDst,prmTarget
        return: Result node
        note: This function accespts $prmDst as item()+.
              If $prmDst is not instance of node(), the processing is skipped.
    -->
    <xsl:function name="ahf:extNodeReplace" as="node()*">
        <xsl:param name="prmStr" as="xs:string"/>
        <xsl:param name="prmSrc" as="xs:string+"/>
        <xsl:param name="prmDst" as="item()+"/>
        <xsl:param name="prmTarget" as="xs:string"/>
        
        <xsl:variable name="firstResult" as="node()*">
            <xsl:choose>
                <xsl:when test="($prmStr eq $prmSrc[1]) and ($prmDst[1] instance of node())">
                    <xsl:choose>
                        <xsl:when test="$prmDst[1] instance of document-node()">
                            <xsl:copy-of select="$prmDst[1]/node()"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:copy-of select="$prmDst[1]"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="exists($firstResult)">
                <xsl:sequence select="if ($firstResult instance of element(_null)) then () else $firstResult "/>
            </xsl:when>
            <xsl:when test="exists($prmSrc[2]) and exists($prmDst[2])">
                <xsl:sequence select="ahf:extNodeReplace($prmStr,subsequence($prmSrc,2),subsequence($prmDst,2),$prmTarget)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="errorExit">
                    <xsl:with-param name="prmMes" select="ahf:replace($stMes2030,('%param','%target'),($prmStr,$prmTarget))"/>
                </xsl:call-template>
                <xsl:sequence select="()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    


    <!-- 
     function:	Make hexadecimal string from positive integer
     param:		prmNumber
     return:	Hexadecimal string
     note:		
     -->
    <xsl:function name="ahf:intToHexString" as="xs:string">
        <xsl:param name="prmValue" as="xs:integer"/>
    
        <xsl:variable name="quotient"  select="$prmValue idiv 16" as="xs:integer"/>
        <xsl:variable name="remainder" select="$prmValue mod 16"  as="xs:integer"/>
        
        <xsl:variable name="quotientString" select="if ($quotient &gt; 0) then (ahf:intToHexString($quotient)) else ''" as="xs:string"/>
        <xsl:variable name="remainderString" as="xs:string">
            <xsl:choose>
                <xsl:when test="($remainder &gt;= 0) and ($remainder &lt;= 9)">
                    <xsl:value-of select="format-number($remainder, '0')"/>
                </xsl:when>
                <xsl:when test="$remainder = 10">
                    <xsl:value-of select="'A'"/>
                </xsl:when>
                <xsl:when test="$remainder = 11">
                    <xsl:value-of select="'B'"/>
                </xsl:when>
                <xsl:when test="$remainder = 12">
                    <xsl:value-of select="'C'"/>
                </xsl:when>
                <xsl:when test="$remainder = 13">
                    <xsl:value-of select="'D'"/>
                </xsl:when>
                <xsl:when test="$remainder = 14">
                    <xsl:value-of select="'E'"/>
                </xsl:when>
                <xsl:when test="$remainder = 15">
                    <xsl:value-of select="'F'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="''"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:sequence select="concat($quotientString, $remainderString)"/>
    </xsl:function>
    
    <!-- 
     function:	Make hexadecimal string from codepoint sequence
     param:		prmCodePoint
     return:	Hexadecimal string
     note:		
     -->
    <xsl:function name="ahf:codepointToHexString" as="xs:string">
        <xsl:param name="prmCodePoint" as="xs:integer*"/>
    
        <xsl:choose>
            <xsl:when test="empty($prmCodePoint)">
                <xsl:sequence select="''"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="first" select="ahf:intToHexString($prmCodePoint[1])" as="xs:string"/>
                <xsl:variable name="paddingCount" select="string-length($first) mod 4"/>
                <xsl:variable name="paddingZero" select="if ($paddingCount gt 0) then string-join(for $i in 1 to $paddingCount return '0','') else ''"/>
                <xsl:variable name="rest"  select="ahf:codepointToHexString(subsequence($prmCodePoint,2))" as="xs:string"/>
                <xsl:sequence select="concat($paddingZero, $first, $rest)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!-- 
     function:	Make hexadecimal string from string
     param:		prmString
     return:	Hexadecimal string
     note:		
     -->
    <xsl:function name="ahf:stringToHexString" as="xs:string">
        <xsl:param name="prmString" as="xs:string"/>
    
        <xsl:variable name="codePoints" select="string-to-codepoints($prmString)" as="xs:integer*"/>
        <xsl:sequence select="ahf:codepointToHexString($codePoints)"/>
    </xsl:function>
    
    <!-- 
        function:	Return true() if $prmStr contains one of the given $prmDstStrSeq[N].
        param:	    prmStr, prmDstStrSeq
        return:	    xs:boolean
        note:		
    -->
    <xsl:function name="ahf:seqContains" as="xs:boolean">
        <xsl:param name="prmStr" as="xs:string?"/>
        <xsl:param name="prmDstStrSeq" as="xs:string*"/>
        <xsl:choose>
            <xsl:when test="empty($prmStr)">
                <xsl:sequence select="false()"/>
            </xsl:when>
            <xsl:when test="count($prmDstStrSeq) ge 1">
                <xsl:variable name="dstStr" as="xs:string" select="$prmDstStrSeq[1]"/>
                <xsl:choose>
                    <xsl:when test="contains($prmStr,$dstStr)">
                        <xsl:sequence select="true()"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:sequence select="ahf:seqContains($prmStr,$prmDstStrSeq[position() gt 1])"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!--
     function: containsAnyOf
     param:    prmSrcString,prmSearchString
     return:   Return true() if $prmSrcString contains any of $prmSrcString
     note:     Original code by Priscilla Walmsley.
               http://www.xsltfunctions.com/xsl/functx_contains-any-of.html
    -->
    <xsl:function name="ahf:containsAnyOf">
        <xsl:param name="prmSrcString" as="xs:string?"/>
        <xsl:param name="prmSearchStrings" as="xs:string*"/>
        <xsl:sequence select="some $searchString in $prmSearchStrings satisfies contains($prmSrcString,$searchString)"/>
    </xsl:function>

    <!-- end of stylesheet -->
</xsl:stylesheet>
