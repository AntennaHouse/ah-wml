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

    <!-- Include frontmatter to toc
      -->
    <xsl:param name="PRM_INCLUDE_FRONTMATTER_TO_TOC" required="no" as="xs:string" select="$cNo"/>
    <xsl:variable name="pIncludeFrontmatterToToc"
        select="boolean($PRM_INCLUDE_FRONTMATTER_TO_TOC eq $cYes)" as="xs:boolean"/>

    <!-- Add numbering prefix to part/chapter title
      -->
    <xsl:param name="PRM_ADD_CHAPTER_NUMBER_PREFIX_TO_TOPIC_TITLE" required="no" as="xs:string" select="$cYes"/>
    <xsl:variable name="pAddChapterNumberPrefixToTopicTitle"
        select="boolean($PRM_ADD_CHAPTER_NUMBER_PREFIX_TO_TOPIC_TITLE eq $cYes)" as="xs:boolean"/>

    <!-- Add part/chapter to title
     -->
    <xsl:param name="PRM_ADD_PART_OR_CHAPTER_TO_TITLE" required="no" as="xs:string" select="$cNo"/>
    <xsl:variable name="pAddPartOrChapterToTitle"
        select="boolean($PRM_ADD_PART_OR_CHAPTER_TO_TITLE eq $cYes) and $pAddChapterNumberPrefixToTopicTitle" as="xs:boolean"/>

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
    <xsl:param name="PRM_LANG" select="$doubleApos"/>

    <!-- Output draft-comment -->
    <xsl:param name="PRM_OUTPUT_DRAFT_COMMENT" required="no" as="xs:string" select="$cNo"/>
    <xsl:variable name="pOutputDraftComment" select="boolean($PRM_OUTPUT_DRAFT_COMMENT eq $cYes)"
        as="xs:boolean"/>

    <!-- Output required-cleanup -->
    <xsl:param name="PRM_OUTPUT_REQUIRED_CLEANUP" required="no" as="xs:string" select="$cNo"/>
    <xsl:variable name="pOutputRequiredCleanup" select="boolean($PRM_OUTPUT_REQUIRED_CLEANUP eq $cYes)"
        as="xs:boolean"/>

    <!-- Generate unique id in XSL-FO: Deprecated. -->
    <!--xsl:param name="PRM_GEN_UNIQUE_ID" select="$cYes"/>
    <xsl:variable name="pGenUniqueId" select="boolean($PRM_GEN_UNIQUE_ID eq $cYes)" as="xs:boolean"/-->

    <!-- Use @oid in XSL-FO 
         ADDED: 2010/12/16 t.makita
    -->
    <xsl:param name="PRM_USE_OID" required="no" as="xs:string" select="$cNo"/>
    <xsl:variable name="pUseOid" select="boolean($PRM_USE_OID eq $cYes)" as="xs:boolean"/>


    <!-- Format dl as block -->
    <xsl:param name="PRM_FORMAT_DL_AS_BLOCK" required="no" as="xs:string" select="$cYes"/>
    <xsl:variable name="pFormatDlAsBlock" select="boolean($PRM_FORMAT_DL_AS_BLOCK eq $cYes)"
        as="xs:boolean"/>

    <!-- Honor toc="no" or not -->
    <!-- Deprecated. @toc must be honored in DITA 1.2
         2-15-08-06 t.makita
     -->
    <!--xsl:param name="PRM_APPLY_TOC_ATTR" required="no" as="xs:string" select="$cYes"/>
    <xsl:variable name="pApplyTocAttr" select="boolean($PRM_APPLY_TOC_ATTR eq $cYes)" as="xs:boolean"/-->

    <!-- Online or pre-press PDF
         Deprecated. Use $PRM_OUTPUT_TYPE!
      -->
    <!--xsl:param name="PRM_ONLINE_PDF" required="no" as="xs:string" select="$cYes"/>
    <xsl:variable name="pOnlinePdf" select="boolean($PRM_ONLINE_PDF eq $cYes)" as="xs:boolean"/-->

    <!-- Adopt topicref/@navtitle for topicref/[not(@href)] 
         Not released in build.xml.
         2011-07-26 t.makita
         Deprecated.
         2015-08-08 t.makita
     -->
    <!--xsl:param name="PRM_ADOPT_NAVTITLE" required="no" as="xs:string" select="$cYes"/>
    <xsl:variable name="pAdoptNavtitle" select="boolean($PRM_ADOPT_NAVTITLE eq $cYes)" as="xs:boolean"/-->

    <!-- Use outputclass="deprecated" 
         2011-09-05 t.makita
         Deprecated! Use fo:prop instead.
         2015-05-07 t.makita
     -->
    <!--xsl:param name="PRM_USE_OUTPUT_CLASS_DEPRECATED" required="no" as="xs:string" select="$cNo"/>
    <xsl:variable name="pUseOutputClassDeprecated"
        select="boolean($PRM_USE_OUTPUT_CLASS_DEPRECATED eq $cYes)" as="xs:boolean"/-->

    <!-- Use outputclass="nohyphenation" 
         2011-09-05 t.makita
         Deprecated! Use fo:prop instead.
         2015-05-07 t.makita
     -->
    <!--xsl:param name="PRM_USE_OUTPUT_CLASS_NOHYPHENATE" required="no" as="xs:string" select="$cNo"/>
    <xsl:variable name="pUseOutputClassNoHyphenate"
        select="boolean($PRM_USE_OUTPUT_CLASS_NOHYPHENATE eq $cYes)" as="xs:boolean"/-->

    <!-- Sort glossentry according to the xml:lang of map
         Not released in build.xml.
         2011-10-11 t.makita
     -->
    <xsl:param name="PRM_SORT_GLOSSENTRY" required="no" as="xs:string" select="$cYes"/>
    <xsl:variable name="pSortGlossEntry" select="boolean($PRM_SORT_GLOSSENTRY eq $cYes)"
        as="xs:boolean"/>

    <!-- Supress first page-break for first child of part,chapter,appendix in bookmap
         Not released in build.xml.
         2012-04-02 t.makita
         Deprecated. This parameter is not used in anywhere.
         2015-08-10 t.makita
    -->
    <!--xsl:param name="PRM_SUPRESS_FIRST_CHILD_PAGE_BREAK" required="no" as="xs:string" select="$cYes"/>
    <xsl:variable name="pSupressFirstChildPageBreak"
        select="boolean($PRM_SUPRESS_FIRST_CHILD_PAGE_BREAK eq $cYes)" as="xs:boolean"/-->

    <!-- Compatibility parameter.
         Display footnote at the end of topic.
         If this parameter is "no" then <fn> must exists as the descendant of table, simpletable, ul, ol, glossdef and
         the <fn> elements are displayed at the end of these elements.
         Not released in build.xml.
         2012-04-04 t.makita
    -->
    <xsl:param name="PRM_DISPLAY_FN_AT_END_OF_TOPIC" required="no" as="xs:string" select="$cNo"/>
    <xsl:variable name="pDisplayFnAtEndOfTopic"
        select="boolean($PRM_DISPLAY_FN_AT_END_OF_TOPIC eq $cYes)" as="xs:boolean"/>

    <!-- Compatibility parameter.
         Display table/title at the end of the table.
         The new implemenatation outputs table/title before its body.
         Not released in build.xml.
         2012-04-04 t.makita
    -->
    <xsl:param name="PRM_OUTPUT_TABLE_TITLE_AFTER" required="no" as="xs:string" select="$cNo"/>
    <xsl:variable name="pOutputTableTitleAfter"
        select="boolean($PRM_OUTPUT_TABLE_TITLE_AFTER eq $cYes)" as="xs:boolean"/>

    <!-- Output plug-in start message.
         2013-09-30 t.makita
      -->
    <xsl:param name="PRM_OUTPUT_START_MESSAGE" required="no" as="xs:string" select="$cYes"/>
    <xsl:variable name="pOutputStartMessage" select="boolean($PRM_OUTPUT_START_MESSAGE eq $cYes)"
        as="xs:boolean"/>


    <!-- Map directory
         2012-11-11 t.makita
     -->
    <!--xsl:param name="PRM_MAP_DIR_URL" required="yes" as="xs:string"/>
    <xsl:variable name="pMapDirUrl" as="xs:string" select="$PRM_MAP_DIR_URL"/-->

    <!-- DITA-OT version
         2014-11-02 t.makita
     -->
    <!--xsl:param name="PRM_OT_VERSION" required="yes" as="xs:string"/>
    <xsl:variable name="pOtVersion" as="xs:string" select="$PRM_OT_VERSION"/-->

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

    <!-- Auto scall down to fit for block level image
         2015-03-08 t.makita
     -->
    <xsl:param name="PRM_AUTO_SCALE_DOWN_TO_FIT" required="no" as="xs:string" select="$cYes"/>
    <xsl:variable name="pAutoScaleDownToFit" select="boolean($PRM_AUTO_SCALE_DOWN_TO_FIT eq $cYes)"
        as="xs:boolean"/>

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
    <xsl:variable name="pListIndentSize" as="xs:string">
        <xsl:choose>
            <xsl:when test="not(string($PRM_LIST_INDENT_SIZE)) or ($PRM_LIST_INDENT_SIZE = ('''''','&quot;&quot;'))">
                <xsl:sequence select="ahf:getVarValue('List_Indent_Size')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="$PRM_LIST_INDENT_SIZE"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="pListIndentSizeInTwip" as="xs:integer" select="ahf:toTwip($pListIndentSize)"/>
    <xsl:variable name="pListIndentSizeInEmu" as="xs:integer" select="ahf:toEmu($pListIndentSize)"/>
    
    <!-- List base indent size -->
    <xsl:param name="PRM_LIST_BASE_INDENT_SIZE" required="no" as="xs:string" select="''"/>
    <xsl:variable name="pListBaseIndentSize" as="xs:string">
        <xsl:choose>
            <xsl:when test="not(string($PRM_LIST_BASE_INDENT_SIZE)) or ($PRM_LIST_BASE_INDENT_SIZE = ('''''','&quot;&quot;'))">
                <xsl:sequence select="ahf:getVarValue('List_Base_Indent_Size')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="$PRM_LIST_BASE_INDENT_SIZE"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="pListBaseIndentSizeInTwip" as="xs:integer" select="ahf:toTwip($pListBaseIndentSize)"/>
    <xsl:variable name="pListBaseIndentSizeInEmu" as="xs:integer" select="ahf:toEmu($pListBaseIndentSize)"/>
    
    <!-- Merged final middle file URL -->
    <xsl:param name="PRM_MERGED_FINAL_OUTPUT_URL" required="yes" as="xs:anyURI"/>
    <xsl:variable name="pMergedFinalOutputUrl" as="xs:string" select="xs:string($PRM_MERGED_FINAL_OUTPUT_URL)"/>

    <!-- plug-in directory URL -->
    <xsl:param name="PRM_PLUGIN_DIR_URL" required="yes" as="xs:anyURI"/>
    <xsl:variable name="pPluginDirUrl" as="xs:anyURI" select="$PRM_PLUGIN_DIR_URL"/>
    
    <!-- temp directory URL -->
    <xsl:param name="PRM_TEMP_DIR_URL" required="yes" as="xs:anyURI"/>
    <xsl:variable name="pTempDirUrl" as="xs:anyURI" select="$PRM_TEMP_DIR_URL"/>
    
</xsl:stylesheet>