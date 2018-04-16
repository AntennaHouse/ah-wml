<?xml version="1.0" encoding="UTF-8" ?>
<!--
**************************************************************
Utility Templates For Unit
**************************************************************
File Name : dita2wml_unit_util.xsl
**************************************************************
Copyright © 2009-2017 Antenna House, Inc. All rights reserved.
Antenna House is a trademark of Antenna House, Inc.
URL : http://www.antennahouse.co.jp/
**************************************************************
-->
<xsl:stylesheet version="3.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
    exclude-result-prefixes="#all" >
    <!-- 
      ============================================
         Unit conversion utility
      ============================================
    -->
    <!-- units -->
    <xsl:variable name="cUnitPc"   select="'pc'" as="xs:string"/>
    <xsl:variable name="cUnitPt"   select="'pt'" as="xs:string"/>
    <xsl:variable name="cUnitPx"   select="'px'" as="xs:string"/>
    <xsl:variable name="cUnitIn"   select="'in'" as="xs:string"/>
    <xsl:variable name="cUnitCm"   select="'cm'" as="xs:string"/>
    <xsl:variable name="cUnitMm"   select="'mm'" as="xs:string"/>
    <xsl:variable name="cUnitEm"   select="'em'" as="xs:string"/>
    <xsl:variable name="cUnitTwip" select="'twip'" as="xs:string"/>
    
    <!-- Ratios -->
    <xsl:variable name="cPtPerPc" as="xs:integer" select="12"/>
    <xsl:variable name="cPxDpi"   as="xs:integer" select="96"/>
    <xsl:variable name="cPtPerIn" as="xs:integer" select="72"/>
    <xsl:variable name="cCmPerIn" as="xs:double"  select="2.54"/>
    <xsl:variable name="cMmPerIn" as="xs:double"  select="25.4"/>
    <xsl:variable name="cMmPerCm" as="xs:integer" select="10"/>
    <xsl:variable name="cTwipPerPt" as="xs:integer" select="20"/>
    <xsl:variable name="cEmuPerPt" as="xs:integer" select="12700"/>
    <xsl:variable name="cEmuPerIn" as="xs:integer" select="914400"/>
    <xsl:variable name="cEmuPerTwip" as="xs:integer" select="635"/>
    
    <!--
    function:   Check length pattern
    param:      prmUnitVal any numeric value with length unit
    return:     xs:boolean
    note:       If $prmUnitVal is valid value returns true().
    -->
    <xsl:function name="ahf:isUnitValue" as="xs:boolean">
        <xsl:param name="prmUnitVal" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="matches($prmUnitVal,'^([+-]?[1-9][\d]*|0)(\.\d+)?(pc|pt|px|in|cm|mm)$')">
                <xsl:sequence select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <!--
    function:   Convert to mm
    param:      prmUnitVal any numeric value with length unit
    return:     the computed mm value
    note:       
    -->
    <xsl:function name="ahf:toMm" as="xs:double">
        <xsl:param name="prmUnitValue" as="xs:string"/>
        <xsl:try>
            <xsl:choose>
                <xsl:when test="ends-with($prmUnitValue,$cUnitPc)">
                    <xsl:sequence select="xs:double(xs:double(substring($prmUnitValue, 1, string-length($prmUnitValue) - string-length($cUnitPc))) * $cPtPerPc div $cPtPerIn * $cMmPerIn  )"/>
                </xsl:when>
                <xsl:when test="ends-with($prmUnitValue,$cUnitPt)">
                    <xsl:sequence select="xs:double(xs:double(substring($prmUnitValue, 1, string-length($prmUnitValue) - string-length($cUnitPt))) div $cPtPerIn * $cMmPerIn)"/>
                </xsl:when>
                <xsl:when test="ends-with($prmUnitValue,$cUnitPx)">
                    <xsl:sequence select="xs:double(xs:double(substring($prmUnitValue, 1, string-length($prmUnitValue) - string-length($cUnitPx))) div $cPxDpi * $cMmPerIn)"/>
                </xsl:when>
                <xsl:when test="ends-with($prmUnitValue,$cUnitIn)">
                    <xsl:sequence select="xs:double(xs:double(substring($prmUnitValue, 1, string-length($prmUnitValue) - string-length($cUnitIn))) * $cMmPerIn)"/>
                </xsl:when>
                <xsl:when test="ends-with($prmUnitValue,$cUnitCm)">
                    <xsl:sequence select="xs:double(xs:double(substring($prmUnitValue, 1, string-length($prmUnitValue) - string-length($cUnitCm))) * $cMmPerCm)"/>
                </xsl:when>
                <xsl:when test="ends-with($prmUnitValue,$cUnitMm)">
                    <xsl:sequence select="xs:double(substring($prmUnitValue, 1, string-length($prmUnitValue) - string-length($cUnitMm)))"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="warningContinue">
                        <xsl:with-param name="prmMes" select="ahf:replace($stMes2004,('%value'),($prmUnitValue))"/>
                    </xsl:call-template>
                    <xsl:sequence select="0.0"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:catch errors="*">
                <xsl:call-template name="warningContinue">
                    <xsl:with-param name="prmMes" select="ahf:replace($stMes2005,('%value'),($prmUnitValue))"/>
                </xsl:call-template>
                <xsl:sequence select="0.0"/>
            </xsl:catch>
        </xsl:try>
    </xsl:function>
    
    <!--
    function:   Convert to point
    param:      prmUnitVal any numeric value with length unit
    return:     the computed point value
    note:       1pc = 12pt
                1px is calculated using 96dpi
                1in = 72pt
                1cm = 2.54in
    -->
    <xsl:function name="ahf:toPt" as="xs:double" visibility="public">
        <xsl:param name="prmUnitValue" as="xs:string"/>
        <xsl:try>
            <xsl:choose>
                <xsl:when test="ends-with($prmUnitValue,$cUnitPc)">
                    <xsl:sequence select="xs:double(xs:double(substring($prmUnitValue, 1, string-length($prmUnitValue) - string-length($cUnitPc))) * $cPtPerPc)"/>
                </xsl:when>
                <xsl:when test="ends-with($prmUnitValue,$cUnitPt)">
                    <xsl:sequence select="xs:double(substring($prmUnitValue, 1, string-length($prmUnitValue) - string-length($cUnitPt)))"/>
                </xsl:when>
                <xsl:when test="ends-with($prmUnitValue,$cUnitPx)">
                    <xsl:sequence select="xs:double(xs:double(substring($prmUnitValue, 1, string-length($prmUnitValue) - string-length($cUnitPx))) div $cPxDpi * $cPtPerIn)"/>
                </xsl:when>
                <xsl:when test="ends-with($prmUnitValue,$cUnitIn)">
                    <xsl:sequence select="xs:double(xs:double(substring($prmUnitValue, 1, string-length($prmUnitValue) - string-length($cUnitIn))) * $cPtPerIn)"/>
                </xsl:when>
                <xsl:when test="ends-with($prmUnitValue,$cUnitCm)">
                    <xsl:sequence select="xs:double(xs:double(substring($prmUnitValue, 1, string-length($prmUnitValue) - string-length($cUnitCm))) div $cCmPerIn * $cPtPerIn)"/>
                </xsl:when>
                <xsl:when test="ends-with($prmUnitValue,$cUnitMm)">
                    <xsl:sequence select="xs:double(xs:double(substring($prmUnitValue, 1, string-length($prmUnitValue) - string-length($cUnitMm))) div $cMmPerCm div $cCmPerIn * $cPtPerIn)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="warningContinue">
                        <xsl:with-param name="prmMes" select="ahf:replace($stMes2000,('%value'),($prmUnitValue))"/>
                    </xsl:call-template>
                    <xsl:sequence select="0.0"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:catch errors="*">
                <xsl:call-template name="warningContinue">
                    <xsl:with-param name="prmMes" select="ahf:replace($stMes2001,('%value'),($prmUnitValue))"/>
                </xsl:call-template>
                <xsl:sequence select="0.0"/>
            </xsl:catch>
        </xsl:try>
    </xsl:function>

    <!--
    function:   Convert to half point
    param:      prmUnitVal any numeric value with length unit
    return:     the computed half point value
    note:       Used to express font size
    -->
    <xsl:function name="ahf:toHalfPoint" as="xs:double" visibility="public">
        <xsl:param name="prmUnitValue" as="xs:string"/>
        <xsl:sequence select="ahf:toPt($prmUnitValue) * 2"/>
    </xsl:function>

    <!-- string version -->
    <xsl:function name="ahf:toHalfPointStr" as="xs:string" visibility="public">
        <xsl:param name="prmUnitValue" as="xs:string"/>
        <xsl:sequence select="string(xs:integer(ahf:toHalfPoint($prmUnitValue)))"/>
    </xsl:function>

    <!--
    function:   Convert to twip
    param:      prmUnitVal any numeric value with length unit
    return:     the computed twip value
    note:       A twip is defined as 20pt.
                1pc = 12pt
                1px is calculated using 96dpi
                1in = 72pt
                1cm = 2.54in
    -->
    <xsl:function name="ahf:toTwip" as="xs:integer" visibility="public">
        <xsl:param name="prmUnitValue" as="xs:string"/>
        <xsl:sequence select="xs:integer(ahf:toPt($prmUnitValue) * $cTwipPerPt)"/>
    </xsl:function>
    
    <xsl:function name="ahf:toTwipStr" as="xs:string" visibility="public">
        <xsl:param name="prmUnitValue" as="xs:string"/>
        <xsl:sequence select="string(ahf:toTwip($prmUnitValue))"/>
    </xsl:function>
    
    <!--
    function:   Convert to EMU
    param:      prmUnitVal any numeric value with length unit
    return:     the computed EMU value
    note:       A EMU is defined as 1/12700pt. (1/914400in or 1/360000cm)
                1pc = 12pt
                1px is calculated using 96dpi
                1in = 72pt
                1cm = 2.54in
                1twip = 20pt
    -->
    <xsl:function name="ahf:toEmu" as="xs:integer" visibility="public">
        <xsl:param name="prmUnitValue" as="xs:string"/>
        <xsl:try>
            <xsl:choose>
                <xsl:when test="ends-with($prmUnitValue,$cUnitPc)">
                    <xsl:sequence select="xs:integer(xs:double(substring($prmUnitValue, 1, string-length($prmUnitValue) - string-length($cUnitPc))) * $cPtPerPc * $cEmuPerPt)"/>
                </xsl:when>
                <xsl:when test="ends-with($prmUnitValue,$cUnitPt)">
                    <xsl:sequence select="xs:integer(xs:double(substring($prmUnitValue, 1, string-length($prmUnitValue) - string-length($cUnitPt))) * $cEmuPerPt)"/>
                </xsl:when>
                <xsl:when test="ends-with($prmUnitValue,$cUnitPx)">
                    <xsl:sequence select="xs:integer(xs:double(substring($prmUnitValue, 1, string-length($prmUnitValue) - string-length($cUnitPx))) div $cPxDpi * $cPtPerIn * $cEmuPerPt)"/>
                </xsl:when>
                <xsl:when test="ends-with($prmUnitValue,$cUnitIn)">
                    <xsl:sequence select="xs:integer(xs:double(substring($prmUnitValue, 1, string-length($prmUnitValue) - string-length($cUnitIn))) * $cEmuPerIn)"/>
                </xsl:when>
                <xsl:when test="ends-with($prmUnitValue,$cUnitCm)">
                    <xsl:sequence select="xs:integer(xs:double(substring($prmUnitValue, 1, string-length($prmUnitValue) - string-length($cUnitCm))) div $cCmPerIn * $cPtPerIn * $cEmuPerPt)"/>
                </xsl:when>
                <xsl:when test="ends-with($prmUnitValue,$cUnitMm)">
                    <xsl:sequence select="xs:integer(xs:double(substring($prmUnitValue, 1, string-length($prmUnitValue) - string-length($cUnitMm))) div $cMmPerCm div $cCmPerIn * $cPtPerIn * $cEmuPerPt)"/>
                </xsl:when>
                <xsl:when test="ends-with($prmUnitValue,$cUnitTwip)">
                    <xsl:sequence select="xs:integer(xs:double(substring($prmUnitValue, 1, string-length($prmUnitValue) - string-length($cUnitTwip)))  * $cEmuPerTwip)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="warningContinue">
                        <xsl:with-param name="prmMes" select="ahf:replace($stMes2002,('%value'),($prmUnitValue))"/>
                    </xsl:call-template>
                    <xsl:sequence select="0"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:catch errors="*">
                <xsl:call-template name="warningContinue">
                    <xsl:with-param name="prmMes" select="ahf:replace($stMes2003,('%value'),($prmUnitValue))"/>
                </xsl:call-template>
                <xsl:sequence select="0"/>
            </xsl:catch>
        </xsl:try>
    </xsl:function>
    
    <!-- string version -->
    <xsl:function name="ahf:toEmuStr" as="xs:string" visibility="public">
        <xsl:param name="prmUnitValue" as="xs:string"/>
        <xsl:sequence select="string(ahf:toEmu($prmUnitValue))"/>        
    </xsl:function>

    <!-- 
     function:	Get line height ratio based 1 line as 240
     param:		prmRatio
     return:	xs:string
     note:		
     -->
    <xsl:function name="ahf:toLineHeightStr" as="xs:string" visibility="public">
        <xsl:param name="prmRatio" as="xs:string"/>
        <xsl:sequence select="string(xs:integer((240 * xs:double($prmRatio))))"/>        
    </xsl:function>

    <!-- 
     function:	Get numeric part of numeric property
     param:		prmProperty
     return:	number
     note:		
     -->
    <xsl:function name="ahf:getPropertyNu" as="xs:double">
        <xsl:param name="prmProperty" as="xs:string"/>
        
        <xsl:variable name="propertyNu" select="replace($prmProperty,'[\p{L}]','')"/>
        <xsl:choose>
            <xsl:when test="string(number($propertyNu))=$NaN">
                <xsl:call-template name="warningContinue">
                    <xsl:with-param name="prmMes" 
                        select="ahf:replace('[getPropertyNu 400W] Invalid non-numeric property value=''%val''. Treated as 1.0.',('%val'),($prmProperty))"/>
                </xsl:call-template>
                <xsl:sequence select="number(1.0)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="number($propertyNu)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!-- 
     function:	Get unit part of numeric property
     param:		prmProperty
     return:	unit string
     note:		
     -->
    <xsl:function name="ahf:getPropertyUnit" as="xs:string">
        <xsl:param name="prmProperty" as="xs:string"/>
        <xsl:sequence select="replace($prmProperty,'[\.\p{Nd}]','')"/>
    </xsl:function>
    
    <!--
     function:	Get calculated the property value with specified ratio
     param:		prmProperty, prmRatio
     return:	calculated property string
     note:		
     -->
    <xsl:function name="ahf:getPropertyRatio" as="xs:string">
        <xsl:param name="prmProperty" as="xs:string"/>
        <xsl:param name="prmRatio"    as="xs:double"/>
        
        <!--xsl:variable name="propertyValue" select="ahf:getPropertyNu($prmProperty)" as="xs:double"/>
        <xsl:variable name="propertyUnit"  select="ahf:getPropertyUnit($prmProperty)" as="xs:string"/>
        <xsl:variable name="calculatedValue" select="$propertyValue * $prmRatio" as="xs:double"/>
        <xsl:sequence select="concat(string($calculatedValue), $propertyUnit)"/-->
        
        <xsl:sequence select="concat('(',$prmProperty, ') * ',string($prmRatio))"/>
        
    </xsl:function>
    
    <!-- end of stylesheet -->
</xsl:stylesheet>
