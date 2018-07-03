<?xml version="1.0" encoding="UTF-8"?>
<!--
**************************************************************
DITA to WordprocessingML Stylesheet
numbering.xml Shell Templates
**************************************************************
File Name : dita2wml_numbering_shell.xsl
**************************************************************
Copyright © 2009 2017 Antenna House, Inc. All rights reserved.
Antenna House is a trademark of Antenna House, Inc.
URL : http://www.antennahouse.com/
**************************************************************
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="3.0">
    
    <xsl:include href="dita2wml_constants.xsl"/>
    <xsl:include href="dita2wml_util.xsl"/>
    <xsl:include href="dita2wml_util_dita.xsl"/>
    <xsl:include href="dita2wml_util_error.xsl"/>
    <xsl:include href="dita2wml_message.xsl"/>

    <xsl:include href="dita2wml_global_wml.xsl"/>
    <xsl:include href="dita2wml_global_merged.xsl"/>
    <xsl:include href="dita2wml_global_list.xsl"/>
    <xsl:include href="dita2wml_param.xsl"/>
    <xsl:include href="dita2wml_param_papersize.xsl"/>
    <xsl:include href="dita2wml_style_get.xsl"/>
    <xsl:include href="dita2wml_style_set.xsl"/>
    <xsl:include href="dita2wml_doc_sect_control_info.xsl"/>
    <xsl:include href="dita2wml_history_id.xsl"/>
    <xsl:include href="dita2wml_doc_id.xsl"/>
    
    <xsl:include href="dita2wml_numbering_main.xsl"/>
    
</xsl:stylesheet>