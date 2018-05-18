<?xml version="1.0" encoding="UTF-8" ?>
<!--
**************************************************************
Utility Templates
**************************************************************
File Name : dita2wml_unit_datetime.xsl
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
         Date & Time conversion utility
      ============================================
    -->
    <!--
    function:   Convert string to xs:dateTime
    param:      prmDateTime Date & Time string
                prmDefault Default xs:dateTime
    return:     The converted value
    note:       If $prmDateTime cannot convert to xs:dateTime, $prmDefault will be used.
    -->
    <xsl:function name="ahf:toDateTimeWithDefault" as="xs:dateTime">
        <xsl:param name="prmDateTime" as="xs:string"/>
        <xsl:param name="prmDefault" as="xs:dateTime"/>
        <xsl:try>
            <xsl:choose>
                <xsl:when test="contains($prmDateTime, 'T')">
                    <xsl:sequence select="xs:dateTime($prmDateTime)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="dateTime(xs:date($prmDateTime), xs:time('00:00:00'))"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:catch errors="*">
                <xsl:sequence select="$prmDefault"/>
            </xsl:catch>
        </xsl:try>
    </xsl:function>
    
    <!--
    function:   Convert string to xs:dateTime
    param:      prmDateTime Date & Time string
    return:     The converted value
    note:       If $prmDateTime cannot convert to xs:dateTime, empty sequence is returned,
    -->
    <xsl:function name="ahf:toDateTime" as="xs:dateTime?">
        <xsl:param name="prmDateTime" as="xs:string"/>
        <xsl:try>
            <xsl:choose>
                <xsl:when test="contains($prmDateTime, 'T')">
                    <xsl:sequence select="xs:dateTime($prmDateTime)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="dateTime(xs:date($prmDateTime), xs:time('00:00:00'))"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:catch errors="*">
                <xsl:sequence select="()"/>
            </xsl:catch>
        </xsl:try>
    </xsl:function>
    
    <!-- end of stylesheet -->
</xsl:stylesheet>
