<?xml version="1.0" encoding="UTF-8"?>
<!--
**************************************************************
DITA to WordprocessingML Stylesheet
Document.xml Shell Templates
**************************************************************
File Name : dita2wml_document_shell.xsl
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
    <xsl:include href="dita2wml_const_cover.xsl"/>
    <xsl:include href="dita2wml_util_error.xsl"/>
    <xsl:include href="dita2wml_util.xsl"/>
    <xsl:include href="dita2wml_util_dita.xsl"/>
    <xsl:include href="dita2wml_util_doc.xsl"/>
    <xsl:include href="dita2wml_util_related_links.xsl"/>
    <xsl:include href="dita2wml_util_fo.xsl"/>
    <xsl:include href="dita2wml_message.xsl"/>
    <xsl:include href="dita2wml_history_id.xsl"/>
    
    <xsl:include href="dita2wml_global.xsl"/>
    <xsl:include href="dita2wml_global_wml.xsl"/>
    <xsl:include href="dita2wml_global_image.xsl"/>
    <xsl:include href="dita2wml_global_link.xsl"/>
    <xsl:include href="dita2wml_global_bookmark.xsl"/>
    <xsl:include href="dita2wml_global_fn.xsl"/>
    <xsl:include href="dita2wml_global_drawing.xsl"/>
    <xsl:include href="dita2wml_global_clear.xsl"/>
    <xsl:include href="dita2wml_global_list.xsl"/>
    <xsl:include href="dita2wml_global_header_footer.xsl"/>
    <xsl:include href="dita2wml_global_frame.xsl"/>
    <xsl:include href="dita2wml_param.xsl"/>
    <xsl:include href="dita2wml_param_var.xsl"/>
    <xsl:include href="dita2wml_param_papersize.xsl"/>
    <xsl:include href="dita2wml_style_get.xsl"/>
    <xsl:include href="dita2wml_style_set.xsl"/>
    
    <xsl:include href="dita2wml_doc_main.xsl"/>
    <xsl:include href="dita2wml_doc_common.xsl"/>
    <xsl:include href="dita2wml_doc_sectpr.xsl"/>
    <xsl:include href="dita2wml_doc_cover.xsl"/>
    <xsl:include href="dita2wml_doc_chapter.xsl"/>
    <xsl:include href="dita2wml_doc_topic.xsl"/>
    <xsl:include href="dita2wml_doc_title.xsl"/>
    <xsl:include href="dita2wml_doc_body.xsl"/>
    <xsl:include href="dita2wml_doc_list.xsl"/>
    <xsl:include href="dita2wml_doc_table.xsl"/>
    <xsl:include href="dita2wml_doc_note.xsl"/>
    <xsl:include href="dita2wml_doc_image.xsl"/>
    <xsl:include href="dita2wml_doc_text.xsl"/>
    <xsl:include href="dita2wml_doc_hilighting_domain.xsl"/>
    <xsl:include href="dita2wml_doc_xref.xsl"/>
    <xsl:include href="dita2wml_doc_fn.xsl"/>
    <xsl:include href="dita2wml_doc_indexterm.xsl"/>
    <xsl:include href="dita2wml_doc_bookmark.xsl"/>
    <xsl:include href="dita2wml_doc_numbering_map.xsl"/>
    <xsl:include href="dita2wml_doc_disp_atts.xsl"/>
    <xsl:include href="dita2wml_doc_id.xsl"/>
    <xsl:include href="dita2wml_doc_sect_control_info.xsl"/>
    <xsl:include href="dita2wml_doc_specialization_elements.xsl"/>
    <xsl:include href="dita2wml_doc_hazardstatement.xsl"/>
    <xsl:include href="dita2wml_doc_floatfig.xsl"/>
    <xsl:include href="dita2wml_doc_index.xsl"/>
    <xsl:include href="dita2wml_doc_toc.xsl"/>
    <xsl:include href="dita2wml_doc_related_links.xsl"/>
    <xsl:include href="dita2wml_doc_character_domain.xsl"/>
    <xsl:include href="dita2wml_doc_userinterface_domain.xsl"/>
    <xsl:include href="dita2wml_doc_software_domain.xsl"/>
    <xsl:include href="dita2wml_doc_task.xsl"/>
    
    <xsl:include href="dita2wml_doc_fo_property.xsl"/>
    <xsl:include href="dita2wml_dita_class.xsl"/>

</xsl:stylesheet>