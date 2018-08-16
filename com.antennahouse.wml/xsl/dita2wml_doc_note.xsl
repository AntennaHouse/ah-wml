<?xml version="1.0" encoding="UTF-8"?>
<!--
**************************************************************
DITA to WordprocessingML Stylesheet
Document.xml note element Templates
**************************************************************
File Name : dita2wml_document_note.xsl
**************************************************************
Copyright © 2009-2017 Antenna House, Inc. All rights reserved.
Antenna House is a trademark of Antenna House, Inc.
URL : http://www.antennahouse.com/
**************************************************************
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" 
    xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
    exclude-result-prefixes="xs map ahf"
    version="3.0">

    <!-- 
     function:	note processing
     param:		prmIndentLevel, prmExtraIndent
     return:	mainly w:p+
     note:      
     -->
    <xsl:template match="*[contains(@class,' topic/note ')]" as="node()*">
        <xsl:param name="prmIndentLevel" tunnel="yes" required="yes" as="xs:integer"/>
        <xsl:param name="prmExtraIndent" tunnel="yes" required="yes" as="xs:integer"/>
        
        <xsl:variable name="iconFileName" as="xs:string">
            <xsl:call-template name="getNoteIconFileName">
                <xsl:with-param name="prmNote" select="."/>
            </xsl:call-template>
        </xsl:variable>
        
        <xsl:variable name="noteTitle" as="xs:string">
            <xsl:call-template name="getNoteTitle">
                <xsl:with-param name="prmNote" select="."/>
            </xsl:call-template>
        </xsl:variable>
        
        <xsl:variable name="iconFileId" as="xs:string" select="string(map:get($commonImageIdMap,$iconFileName))"/>
        
        <xsl:variable name="drawingIdKey" as="xs:string" select="ahf:generateId(.)"/>
        <xsl:variable name="drawingId" as="xs:string" select="xs:string(map:get($drawingIdMap,$drawingIdKey))"/>
        
        <xsl:variable name="iconWidthInEmu" as="xs:string">
            <xsl:variable name="iconWidth" as="xs:string">
                <xsl:call-template name="getVarValueWithLang">
                    <xsl:with-param name="prmVarName" select="'Note_Icon_Width'"/>
                </xsl:call-template>
            </xsl:variable>
            <xsl:sequence select="string(ahf:toEmu($iconWidth))"/>
        </xsl:variable>
        
        <xsl:variable name="iconHeightInEmu" as="xs:string">
            <xsl:variable name="iconHeight" as="xs:string">
                <xsl:call-template name="getVarValueWithLang">
                    <xsl:with-param name="prmVarName" select="'Note_Icon_Height'"/>
                </xsl:call-template>
            </xsl:variable>
            <xsl:sequence select="string(ahf:toEmu($iconHeight))"/>
        </xsl:variable>
        
        <xsl:variable name="iconImage" as="node()">
            <xsl:call-template name="getWmlObjectReplacing">
                <xsl:with-param name="prmObjName" select="'wmlNoteImage'"/>
                <xsl:with-param name="prmSrc" select="('%width','%height','%id','%name','%desc','%rid')"/>
                <xsl:with-param name="prmDst" select="($iconWidthInEmu,$iconHeightInEmu,$drawingId,string(@type),string(@type),concat($rIdPrefix,$iconFileId))"/>
            </xsl:call-template>
        </xsl:variable>

        <xsl:variable name="noteTitleFontSizeInHalfPoint" as="xs:double">
            <xsl:variable name="noteTitleFontSize" as="xs:string">
                <xsl:call-template name="getVarValueWithLang">
                    <xsl:with-param name="prmVarName" select="'Note_Title_Font_Size'"/>
                </xsl:call-template>
            </xsl:variable>
            <xsl:sequence select="ahf:toHalfPoint($noteTitleFontSize)"/>
        </xsl:variable>

        <xsl:variable name="noteTitleFontSize" as="xs:string" select="xs:string(xs:integer(round($noteTitleFontSizeInHalfPoint)))"/>

        <xsl:variable name="csFontSizeRatio" as="xs:double">
            <xsl:call-template name="getVarValueAsDouble">
                <xsl:with-param name="prmVarName" select="'Complex_Script_Font_Ratio'"/>
            </xsl:call-template>
        </xsl:variable>

        <xsl:variable name="noteTitleCsFontSize" as="xs:string">
            <xsl:sequence select="xs:string(xs:integer(round($noteTitleFontSizeInHalfPoint * $csFontSizeRatio)))"/>
        </xsl:variable>
        
        <!-- Is in table -->
        <xsl:variable name="isNotInTable" as="xs:boolean" select="empty(ancestor::*[ahf:seqContains(@class,(' topic/entry',' topic/stentry '))])"/>
        
        <!-- w:tabs for note rule -->
        <xsl:variable name="bodyRightEdgeInTwip" as="xs:integer" select="ahf:toTwip($pPaperWidth) - ahf:toTwip($pPaperMarginLeft) - ahf:toTwip($pPaperMarginRight)"/>
        <xsl:variable name="pPrTabs" as="node()">
            <xsl:choose>
                <xsl:when test="$isNotInTable">
                    <w:tabs>
                        <w:tab w:val="right" w:pos="{$bodyRightEdgeInTwip}"/>
                    </w:tabs>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:comment/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <!-- Tab itself
             Tab is not inserted if note exists in table because the right edge calculation is difficult.
          -->
        <xsl:variable name="tab" as="node()">
            <xsl:choose>
                <xsl:when test="$isNotInTable">
                    <w:r>
                        <w:tab/>
                    </w:r>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:comment/>                    
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <!-- Make upper line -->
        <xsl:call-template name="getWmlObjectReplacing">
            <xsl:with-param name="prmObjName" select="'wmlNoteUpperLine'"/>
            <xsl:with-param name="prmSrc" select="('node:tabs','%start-ind','node:icon-image','%szcs','%sz','%title','node:tab')"/>
            <xsl:with-param name="prmDst" select="($pPrTabs,string(ahf:getIndentFromIndentLevel($prmIndentLevel, $prmExtraIndent)),$iconImage,$noteTitleCsFontSize,$noteTitleFontSize,$noteTitle,$tab)"/>
        </xsl:call-template>
        
        <!-- Note contents -->
        <xsl:apply-templates/>

        <!-- Make under line -->
        <xsl:if test="$isNotInTable">
            <xsl:call-template name="getWmlObjectReplacing">
                <xsl:with-param name="prmObjName" select="'wmlNoteUnderLine'"/>
                <xsl:with-param name="prmSrc" select="('node:tabs','%start-ind')"/>
                <xsl:with-param name="prmDst" select="($pPrTabs,string(ahf:getIndentFromIndentLevel($prmIndentLevel,$prmExtraIndent)))"/>
            </xsl:call-template>
        </xsl:if>

    </xsl:template>
    
    <!-- 
     function:	get note icon image file name by @type value
     param:		prmNote
     return:	xs:string
     note:      
     -->
    <xsl:template name="getNoteIconFileName" as="xs:string">
        <xsl:param name="prmNote" as="element()" required="yes"/>
        <xsl:variable name="type" as="xs:string" select="string($prmNote/@type)"/>
        
        <xsl:variable name="iconVarName" as="xs:string">
            <xsl:choose>
                <xsl:when test="$type = ('note','')">
                    <xsl:sequence select="'Note_Icon_Note'"/>
                </xsl:when>
                <xsl:when test="$type = ('caution','attention','warning','notice','danger')">
                    <xsl:sequence select="'Note_Icon_Caution'"/>
                </xsl:when>
                <xsl:when test="$type eq 'fastpath'">
                    <xsl:sequence select="'Note_Icon_FastPath'"/>
                </xsl:when>
                <xsl:when test="$type = ('important','restriction','remember','trouble')">
                    <xsl:sequence select="'Note_Icon_Important'"/>
                </xsl:when>
                <xsl:when test="$type eq 'tip'">
                    <xsl:sequence select="'Note_Icon_Tip'"/>
                </xsl:when>
                <xsl:when test="$type eq 'other'">
                    <xsl:sequence select="'Note_Icon_Other'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="'Note_Icon_Other'"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:call-template name="getVarValue">
            <xsl:with-param name="prmVarName" select="$iconVarName"/>
        </xsl:call-template>
    </xsl:template>
    
    <!-- 
     function:	get note title
     param:		prmNote
     return:	xs:string
     note:      
     -->
    <xsl:template name="getNoteTitle" as="xs:string">
        <xsl:param name="prmNote" as="element()" required="yes"/>
        <xsl:variable name="type" as="xs:string" select="string($prmNote/@type)"/>
        
        <xsl:variable name="titleVarName" as="xs:string">
            <xsl:choose>
                <xsl:when test="$type = ('note','')">
                    <xsl:sequence select="'Note_Note'"/>
                </xsl:when>
                <xsl:when test="$type eq 'attention'">
                    <xsl:sequence select="'Note_Attention'"/>
                </xsl:when>
                <xsl:when test="$type eq 'caution'">
                    <xsl:sequence select="'Note_Caution'"/>
                </xsl:when>
                <xsl:when test="$type eq 'danger'">
                    <xsl:sequence select="'Note_Danger'"/>
                </xsl:when>
                <xsl:when test="$type eq 'fastpath'">
                    <xsl:sequence select="'Note_FastPath'"/>
                </xsl:when>
                <xsl:when test="$type eq 'important'">
                    <xsl:sequence select="'Note_Important'"/>
                </xsl:when>
                <xsl:when test="$type eq 'notice'">
                    <xsl:sequence select="'Note_Notice'"/>
                </xsl:when>
                <xsl:when test="$type eq 'remember'">
                    <xsl:sequence select="'Note_Remember'"/>
                </xsl:when>
                <xsl:when test="$type eq 'restriction'">
                    <xsl:sequence select="'Note_Restriction'"/>
                </xsl:when>
                <xsl:when test="$type eq 'tip'">
                    <xsl:sequence select="'Note_Tip'"/>
                </xsl:when>
                <xsl:when test="$type eq 'warning'">
                    <xsl:sequence select="'Note_Warning'"/>
                </xsl:when>
                <xsl:when test="$type eq 'trouble'">
                    <xsl:sequence select="'Note_Trouble'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="''"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="string($titleVarName)">
                <xsl:call-template name="getVarValueWithLang">
                    <xsl:with-param name="prmVarName" select="$titleVarName"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$type eq 'other'">
                <xsl:sequence select="string($prmNote/@othertype)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="''"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- ==== END OF STYLESHEET === -->

</xsl:stylesheet>