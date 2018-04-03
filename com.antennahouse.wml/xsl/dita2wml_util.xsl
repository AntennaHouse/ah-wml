<?xml version="1.0" encoding="UTF-8" ?>
<!--
**************************************************************
Utility Templates
**************************************************************
File Name : dita2wml_util.xsl
**************************************************************
Copyright © 2009 2017 Antenna House, Inc. All rights reserved.
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
    ===============================================
     Utility Templates
    ===============================================
    -->
    <xsl:include href="dita2wml_util_attr.xsl"/>    
    <xsl:include href="dita2wml_util_datetime.xsl"/>
    <xsl:include href="dita2wml_util_node.xsl"/>
    <xsl:include href="dita2wml_util_string.xsl"/>
    <xsl:include href="dita2wml_util_unit.xsl"/>    
    <xsl:include href="dita2wml_util_wml.xsl"/>    
    
    <!-- end of stylesheet -->
</xsl:stylesheet>
