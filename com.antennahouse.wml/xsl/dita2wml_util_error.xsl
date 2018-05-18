<?xml version="1.0" encoding="UTF-8" ?>
<!--
**************************************************************
DITA to WordprocessingML Stylesheet
Error processing Templates
**************************************************************
File Name : dita2fo_error_util.xsl
**************************************************************
Copyright © 2009 2009 Antenna House, Inc. All rights reserved.
Antenna House is a trademark of Antenna House, Inc.
URL : http://www.antennahouse.com/
**************************************************************
-->

<xsl:stylesheet version="3.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:map="http://www.w3.org/2005/xpath-functions/map"
	xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
    exclude-result-prefixes="#all" >
    
    <!--
    ===============================================
     Error processing
    ===============================================
    -->
    <!-- 
     function:	Error Exit routine
     param:		prmMes: message body
     return:	none
     note:		none
    -->
    <xsl:template name="errorExit">
    	<xsl:param name="prmMes" required="yes" as="xs:string"/>
    	<xsl:message terminate="yes"><xsl:value-of select="$prmMes"/></xsl:message>
    </xsl:template>
    
    <!-- 
     function:	Warning display routine
     param:		prmMes: message body
     return:	none
     note:		none
    -->
    <xsl:template name="warningContinue">
        <xsl:param name="prmMes" required="yes" as="xs:string"/>
        <xsl:message terminate="no"><xsl:value-of select="$prmMes"/></xsl:message>
    </xsl:template>

    <!-- 
     function:	Map dump function
     param:		prmMap: target map
     return:	none
     note:		none
    -->
    <xsl:function name="ahf:mapKeyDump" as="xs:string*">
        <xsl:param name="prmMap" as="map(*)"/>
        <xsl:sequence select="map:for-each($prmMap,function($k, $v){concat('''',string($k),'''')})"/>
    </xsl:function>
    
    <!-- end of stylesheet -->
</xsl:stylesheet>
