<?xml version='1.0' encoding="UTF-8" ?>
<!--
****************************************************************
DITA to WordprocessingML Stylesheet
Module: Stylesheet parameter and global variables.
Copyright © 2009-2018 Antenna House, Inc. All rights reserved.
Antenna House is a trademark of Antenna House, Inc.
URL    : http://www.antennahouse.com/
E-mail : info@antennahouse.com
****************************************************************
-->
<xsl:stylesheet version="3.0" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
    exclude-result-prefixes="#all">

    <!-- Default style definition file: Plug-in relative path -->
    <xsl:param name="PRM_STYLE_DEF_FILE" required="no" as="xs:string" select="'config/default_style.xml'"/>

    <!-- Add numbering prefix to part/chapter title
      -->
    <xsl:param name="PRM_ADD_CHAPTER_NUMBER_PREFIX_TO_TOPIC_TITLE" required="no" as="xs:string" select="$cYes"/>
    <xsl:variable name="pAddChapterNumberPrefixToTopicTitle"
        select="boolean($PRM_ADD_CHAPTER_NUMBER_PREFIX_TO_TOPIC_TITLE eq $cYes)" as="xs:boolean"/>

    <!-- Add chapter number prefix to table title
      -->
    <xsl:param name="PRM_ADD_CHAPTER_NUMBER_PREFIX_TO_TABLE_TITLE" required="no" as="xs:string" select="$cYes"/>
    <xsl:variable name="pAddChapterNumberPrefixToTableTitle"
        select="boolean($PRM_ADD_CHAPTER_NUMBER_PREFIX_TO_TABLE_TITLE eq $cYes) and $pAddChapterNumberPrefixToTopicTitle" as="xs:boolean"/>

    <!-- Add chapter number prefix to fig title
      -->
    <xsl:param name="PRM_ADD_CHAPTER_NUMBER_PREFIX_TO_FIG_TITLE" required="no" as="xs:string" select="$cYes"/>
    <xsl:variable name="pAddChapterNumberPrefixToFigTitle"
        select="boolean($PRM_ADD_CHAPTER_NUMBER_PREFIX_TO_FIG_TITLE eq $cYes) and $pAddChapterNumberPrefixToTopicTitle" as="xs:boolean"/>

    <!-- Document language -->
    <xsl:param name="PRM_LANG" as="xs:string" required="no" select="$doubleApos"/>

    <!-- Map directory URL
     -->
    <xsl:param name="PRM_MAP_DIR_URL" required="yes" as="xs:string"/>
    <xsl:variable name="pMapDirUrl" as="xs:string" select="$PRM_MAP_DIR_URL"/>

    <!-- Debug style parameter
         2014-11-02 t.makita
     -->
    <xsl:param name="PRM_DEBUG_STYLE" required="no" as="xs:string" select="$cNo"/>
    <xsl:variable name="pDebugStyle" as="xs:boolean" select="$PRM_DEBUG_STYLE eq $cYes"/>

    <!-- Output type
         Possible value: "web","print-color","print-monochrome"
     -->
    <xsl:param name="PRM_OUTPUT_TYPE" as="xs:string" required="no" select="'web'"/>
    <xsl:variable name="pOutputType" as="xs:string" select="$PRM_OUTPUT_TYPE"/>
    <xsl:variable name="pIsWebOutput" as="xs:boolean" select="$pOutputType eq 'web'"/>
    <xsl:variable name="pIsPrintOutput" as="xs:boolean" select="not($pIsWebOutput)"/>
    
    <!-- .docx template directory URL -->
    <xsl:param name="PRM_TEMPLATE_DIR_URL" required="yes" as="xs:anyURI"/>
    <xsl:variable name="pTemplateDirUrl" as="xs:anyURI" select="$PRM_TEMPLATE_DIR_URL"/>
    <xsl:variable name="pTemplateDocument" as="xs:anyURI" select="xs:anyURI(concat(xs:string($pTemplateDirUrl),'/word/document.xml'))"/>
    <xsl:variable name="pTemplateStyle" as="xs:anyURI" select="xs:anyURI(concat(xs:string($pTemplateDirUrl),'/word/styles.xml'))"/>
    <xsl:variable name="pTemplateNumbering" as="xs:anyURI" select="xs:anyURI(concat(xs:string($pTemplateDirUrl),'/word/numbering.xml'))"/>
    
    <!-- Debug merged middle file processing -->
    <xsl:param name="PRM_DEBUG_MERGED" required="no" as="xs:string"/>
    <xsl:variable name="pDebugMerged" as="xs:boolean" select="$PRM_DEBUG_MERGED eq $cYes"/>
    
    <!-- List indent size
         Used in dita2wml_param_var.xsl
     -->
    <xsl:param name="PRM_LIST_INDENT_SIZE" required="no" as="xs:string" select="''"/>
    
    <!-- List base indent size
         Used in dita2wml_param_var.xsl
     -->
    <xsl:param name="PRM_OL_BASE_INDENT_SIZE" required="no" as="xs:string" select="''"/>
    <xsl:param name="PRM_UL_BASE_INDENT_SIZE" required="no" as="xs:string" select="''"/>
    
    <!-- Adopt fixed list indent -->
    <xsl:param name="PRM_ADOPT_FIXED_LIST_INDENT" required="no" as="xs:string" select="$cNo"/>
    <xsl:variable name="pAdoptFixedListIndent" as="xs:boolean" select="$PRM_ADOPT_FIXED_LIST_INDENT eq $cYes"/>
    
    <!-- Merged final middle file URL -->
    <xsl:param name="PRM_MERGED_FINAL_OUTPUT_URL" required="yes" as="xs:anyURI"/>
    <xsl:variable name="pMergedFinalOutputUrl" as="xs:string" select="xs:string($PRM_MERGED_FINAL_OUTPUT_URL)"/>

    <!-- plug-in directory URL -->
    <xsl:param name="PRM_PLUGIN_DIR_URL" required="yes" as="xs:anyURI"/>
    <xsl:variable name="pPluginDirUrl" as="xs:anyURI" select="$PRM_PLUGIN_DIR_URL"/>
    
    <!-- temp directory URL -->
    <xsl:param name="PRM_TEMP_DIR_URL" required="yes" as="xs:anyURI"/>
    <xsl:variable name="pTempDirUrl" as="xs:anyURI" select="$PRM_TEMP_DIR_URL"/>

    <!-- folio prefix
         If the value is "A", the page number will be appeared as "A-nnn".
     -->
    <xsl:param name="PRM_OUTPUT_FOLIO_PREFIX" as="xs:string" select="''"/>
    <xsl:variable name="pOutputFolioPrefix" select="$PRM_OUTPUT_FOLIO_PREFIX" as="xs:string"/>
    <xsl:variable name="pHasOutputFolioPrefix" select="$pOutputFolioPrefix ne ''" as="xs:boolean"/>
    
</xsl:stylesheet>
