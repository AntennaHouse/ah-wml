<?xml version="1.0" encoding="UTF-8" ?>
<!--
****************************************************************
DITA to WordprocessingML Stylesheet
Module: Stylesheet constants.
Copyright © 2009-2017 Antenna House, Inc. All rights reserved.
Antenna House is a trademark of Antenna House, Inc.
URL    : http://www.antennahouse.com/
E-mail : info@antennahouse.com
****************************************************************
-->
<xsl:stylesheet version="3.0" 
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:xs="http://www.w3.org/2001/XMLSchema"
 xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
 exclude-result-prefixes="#all">
    <!-- *************************************** 
            Constants
         ***************************************-->
    
    <!-- External Parameter yes/no value -->
    <xsl:variable name="cYes" select="'yes'" as="xs:string" static="yes"/>
    <xsl:variable name="cNo" select="'no'" as="xs:string" static="yes"/>
    
    <!-- Inner flag/attribute value: true/false -->
    <xsl:variable name="true" select="'true'" as="xs:string"/>
    <xsl:variable name="false" select="'false'" as="xs:string"/>
    
    <xsl:variable name="NaN" select="'NaN'" as="xs:string"/>
    <xsl:variable name="lf" select="'&#x0A;'" as="xs:string"/>
    <xsl:variable name="doubleApos" as="xs:string" select="''''''"/>
    
    <!-- Width type -->
    <xsl:variable name="cTwip" as="xs:string" select="'dxa'"/>
    <xsl:variable name="cPercent" as="xs:string" select="'pct'"/>
    <xsl:variable name="cAuto" as="xs:string" select="'auto'"/>
    
    <!-- Code -->
    <xsl:variable name="cNbSp" as="xs:string" select="'&#xA0;'"/>
   
   <!-- null element -->
   <xsl:variable name="cElemNull" as="element()">
      <_null/>
   </xsl:variable>
    
</xsl:stylesheet>
