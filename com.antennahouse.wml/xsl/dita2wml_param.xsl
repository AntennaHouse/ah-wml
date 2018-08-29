<?xml version='1.0' encoding="UTF-8" ?>
<!--
****************************************************************
DITA to WordprocessingML Stylesheet
Module: Stylesheet parameter and global variables.
Copyright © 2009-2017 Antenna House, Inc. All rights reserved.
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

    <!-- Add part/chapter to title
         Deprecated: not supported in Word conversion
     -->
    <!--xsl:param name="PRM_ADD_PART_OR_CHAPTER_TO_TITLE" required="no" as="xs:string" select="$cYes"/>
    <xsl:variable name="pAddPartOrChapterToTitle"
        select="boolean($PRM_ADD_PART_OR_CHAPTER_TO_TITLE eq $cYes) and $pAddChapterNumberPrefixToTopicTitle" as="xs:boolean"/-->

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

    <!-- Add chapter number prefix to equation number
      -->
    <xsl:param name="PRM_ADD_CHAPTER_NUMBER_PREFIX_TO_EQUATION_NUMBER" required="no" as="xs:string" select="$cYes"/>
    <xsl:variable name="pAddChapterNumberPrefixToEquationNumber"
        select="boolean($PRM_ADD_CHAPTER_NUMBER_PREFIX_TO_EQUATION_NUMBER eq $cYes) and $pAddChapterNumberPrefixToTopicTitle" as="xs:boolean"/>

    <!-- Document language -->
    <xsl:param name="PRM_LANG" as="xs:string" required="no" select="$doubleApos"/>

    <!-- Map directory URL
         2012-11-11 t.makita
     -->
    <xsl:param name="PRM_MAP_DIR_URL" required="yes" as="xs:string"/>
    <xsl:variable name="pMapDirUrl" as="xs:string" select="$PRM_MAP_DIR_URL"/>

    <!-- Debug parameter
         2014-11-02 t.makita
     -->
    <xsl:param name="PRM_DEBUG" required="no" as="xs:string" select="$cNo"/>
    <xsl:variable name="pDebug" as="xs:boolean" select="$PRM_DEBUG eq $cYes"/>

    <!-- Debug style parameter
         2014-11-02 t.makita
     -->
    <xsl:param name="PRM_DEBUG_STYLE" required="no" as="xs:string" select="$cNo"/>
    <xsl:variable name="pDebugStyle" as="xs:boolean" select="$PRM_DEBUG_STYLE eq $cYes"/>

    <!-- Make toc for simple map (not for bookmap)
         2015-03-11 t.makita
     -->
    <xsl:param name="PRM_MAKE_TOC_FOR_MAP" required="no" as="xs:string" select="$cYes"/>
    <xsl:variable name="pMakeTocForMap" select="boolean($PRM_MAKE_TOC_FOR_MAP eq $cYes)"
        as="xs:boolean"/>

    <!-- Make index for simple map (not for bookmap)
           2015-03-11 t.makita
       -->
    <xsl:param name="PRM_MAKE_INDEX_FOR_MAP" required="no" as="xs:string" select="$cYes"/>
    <xsl:variable name="pMakeIndexForMap" select="boolean($PRM_MAKE_INDEX_FOR_MAP eq $cYes)"
        as="xs:boolean"/>

    <!-- Generate axf:alt-text for fo:external-graphic
         2015-03-11 t.makita
     -->
    <xsl:param name="PRM_MAKE_ALT_TEXT" required="no" as="xs:string" select="$cNo"/>
    <xsl:variable name="pMakeAltText" select="boolean($PRM_MAKE_ALT_TEXT eq $cYes)"
        as="xs:boolean"/>
    
    <!-- Copy image to output folder
         2015-05-05 t.makita
     -->
    <xsl:param name="PRM_IMAGE_IN_OUTPUT_FOLDER" required="no" as="xs:string" select="$cNo"/>
    <xsl:variable name="pImageInOutputFolder" select="boolean($PRM_IMAGE_IN_OUTPUT_FOLDER eq $cYes)" as="xs:boolean"/>
    
    <!-- Output crop region
         2015-05-06 t.makita
     -->
    <xsl:param name="PRM_OUTPUT_CROP_REGION" required="no" as="xs:string" select="$cNo"/>
    <xsl:variable name="pOutputCropRegion" select="boolean($PRM_OUTPUT_CROP_REGION eq $cYes)" as="xs:boolean"/>

    <!-- Output type
         Possible value: "web","print-color","print-monochrome"
     -->
    <xsl:param name="PRM_OUTPUT_TYPE" as="xs:string" required="no" select="'web'"/>
    <xsl:variable name="pOutputType" as="xs:string" select="$PRM_OUTPUT_TYPE"/>
    <xsl:variable name="pIsWebOutput" as="xs:boolean" select="$pOutputType eq 'web'"/>
    <xsl:variable name="pIsPrintOutput" as="xs:boolean" select="not($pIsWebOutput)"/>
    
    <!-- Support floating fig
         This function is experimental
     -->
    <xsl:param name="PRM_SUPPORT_FLOAT_FIG" as="xs:string" required="no" select="$cNo"/>
    <xsl:variable name="pSupportFloatFig" as="xs:boolean" select="$PRM_SUPPORT_FLOAT_FIG eq $cYes"/>

    <!-- Exclude cover pages from counting page
     -->
    <xsl:param name="PRM_EXCLUDE_COVER_FROM_COUNTING_PAGE" as="xs:string" required="no" select="$cYes"/>
    <xsl:variable name="pExcludeCoverFromCountingPage" as="xs:boolean" select="$PRM_EXCLUDE_COVER_FROM_COUNTING_PAGE eq $cYes"/>
    <xsl:variable name="pIncludeCoverIntoPageCounting" as="xs:boolean" select="not($pExcludeCoverFromCountingPage)"/>
    
    <!-- Number <equation-block> unconditionally
         <equation-number> with effective number will be honored
     -->
    <xsl:param name="PRM_NUMBER_EQUATION_BLOCK_UNCONDITIONALLY" as="xs:string" required="no" select="$cNo"/>
    <xsl:variable name="pNumberEquationBlockUnconditionally" as="xs:boolean" select="$PRM_NUMBER_EQUATION_BLOCK_UNCONDITIONALLY eq $cYes"/>
    
    <!-- Exclude <equation-block> in <equation-figure> in unconditionally numbering mode
     -->
    <xsl:param name="PRM_EXCLUDE_AUTO_NUMBERING_FROM_EQUATION_FIGURE" as="xs:string" required="no" select="$cYes"/>
    <xsl:variable name="pExcludeAutoNumberingFromEquationFigure" as="xs:boolean" select="$PRM_EXCLUDE_AUTO_NUMBERING_FROM_EQUATION_FIGURE eq $cYes"/>

    <!-- Assume all <equation-number> as auto
         This parameter ignores manual numbering of <equation-number>
         This function is not in OASIS standard. But useful for making books. 
     -->
    <xsl:param name="PRM_ASSUME_EQUATION_NUMBER_AS_AUTO" as="xs:string" required="no" select="$cNo"/>
    <xsl:variable name="pAssumeEquationNumberAsAuto" as="xs:boolean" select="$PRM_ASSUME_EQUATION_NUMBER_AS_AUTO eq $cYes"/>
    
    <!-- Output directory URL
         2016-01-11 t.makita
     -->
    <!--xsl:param name="PRM_OUTPUT_DIR_URL" required="yes" as="xs:string"/>
    <xsl:variable name="pOutputDirUrl" as="xs:string" select="$PRM_OUTPUT_DIR_URL"/-->

    <!-- DITA input file name (wo directory & extension)
         2016-01-11 t.makita
     -->
    <!--xsl:param name="PRM_INPUT_MAP_NAME" required="yes" as="xs:string"/>
    <xsl:variable name="pInputMapName" as="xs:string" select="$PRM_INPUT_MAP_NAME"/-->
    
    <!-- Output index
         2016-03-26 t.makita
     -->
    <xsl:param name="PRM_OUTPUT_INDEX" required="no" as="xs:string" select="$cYes"/>
    <xsl:variable name="pOutputIndex" as="xs:boolean" select="$PRM_OUTPUT_INDEX eq $cYes"/>
    
    <!-- .docx template directory URL -->
    <xsl:param name="PRM_TEMPLATE_DIR_URL" required="yes" as="xs:anyURI"/>
    <xsl:variable name="pTemplateDirUrl" as="xs:anyURI" select="$PRM_TEMPLATE_DIR_URL"/>
    <xsl:variable name="pTemplateDocument" as="xs:anyURI" select="xs:anyURI(concat(xs:string($pTemplateDirUrl),'/word/document.xml'))"/>
    <xsl:variable name="pTemplateStyle" as="xs:anyURI" select="xs:anyURI(concat(xs:string($pTemplateDirUrl),'/word/styles.xml'))"/>
    <xsl:variable name="pTemplateNumbering" as="xs:anyURI" select="xs:anyURI(concat(xs:string($pTemplateDirUrl),'/word/numbering.xml'))"/>
    
    <!-- Debug merged middle file processing -->
    <xsl:param name="PRM_DEBUG_MERGED" required="no" as="xs:string"/>
    <xsl:variable name="pDebugMerged" as="xs:boolean" select="$PRM_DEBUG_MERGED eq $cYes"/>
    
    <!-- Debug table expansition -->
    <xsl:param name="PRM_DEBUG_TABLE" required="no" as="xs:string"/>
    <xsl:variable name="pDebugTable" as="xs:boolean" select="$PRM_DEBUG_TABLE eq $cYes"/>
    
    <!-- List indent size -->
    <xsl:param name="PRM_LIST_INDENT_SIZE" required="no" as="xs:string" select="''"/>
    
    <!-- List base indent size -->
    <xsl:param name="PRM_LIST_BASE_INDENT_SIZE" required="no" as="xs:string" select="''"/>
    
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
