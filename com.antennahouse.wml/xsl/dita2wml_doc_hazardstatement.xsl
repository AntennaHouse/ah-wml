<?xml version="1.0" encoding="UTF-8"?>
<!--
**************************************************************
DITA to WordprocessingML Stylesheet
Document.xml hazardstatement element Templates
**************************************************************
File Name : dita2wml_document_hazardstatement.xsl
**************************************************************
Copyright © 2009-2018 Antenna House, Inc. All rights reserved.
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
     function:	hazardstatement processing
     param:		prmIndentLevel, prmExtraIndent
     return:	w:tbl
     note:      Output hazardstatement using w:tbl
                - Header row contains icon & signal word.
                - Each body row contains hazardsymbol[N] and messagepanel[N].
                - Support hazrdstatement/hazardsymbol is empty.
     -->
    <xsl:variable name="noteTypeMap" as="map(xs:string,xs:string)">
        <xsl:map>
            <xsl:map-entry key="'caution'" select="'Note_Caution'"/>
            <xsl:map-entry key="'danger'" select="'Note_Danger'"/>
            <xsl:map-entry key="'warning'" select="'Note_Warning'"/>
            <xsl:map-entry key="'note'" select="'Note_Note'"/>
            <xsl:map-entry key="'tip'" select="'Note_Tip'"/>
            <xsl:map-entry key="'fastpath'" select="'Note_FastPath'"/>
            <xsl:map-entry key="'restriction'" select="'Note_Restriction'"/>
            <xsl:map-entry key="'important'" select="'Note_Important'"/>
            <xsl:map-entry key="'remember'" select="'Note_Remember'"/>
            <xsl:map-entry key="'attention'" select="'Note_Attention'"/>
            <xsl:map-entry key="'notice'" select="'Note_Notice'"/>
            <xsl:map-entry key="'other'" select="'Note_Attention'"/>
        </xsl:map>
    </xsl:variable>
    
    <xsl:template match="*[@class => contains-token('hazard-d/hazardstatement')]" as="element()+" priority="5">
        <xsl:param name="prmIndentLevel" tunnel="yes" required="yes" as="xs:integer"/>
        <xsl:param name="prmExtraIndent" tunnel="yes" required="yes" as="xs:integer"/>

        <!-- Title: Signal Word -->
        <xsl:variable name="hsSignalWord" as="xs:string">
            <xsl:variable name="signalWord" as="xs:string">
                <xsl:call-template name="getVarValueWithLang">
                    <xsl:with-param name="prmVarName">
                        <xsl:variable name="varName" as="xs:string?" select="map:get($noteTypeMap,string(@type))"/>
                        <xsl:choose>
                            <xsl:when test="exists($varName)">
                                <xsl:sequence select="$varName"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:sequence select="'Note_Note'"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:variable>
            <xsl:sequence select="upper-case($signalWord)"/>
        </xsl:variable>
        
        <!-- Hazard symbol cell width -->
        <xsl:variable name="hazardSymbolCellWidthInTwip" as="xs:integer">
            <xsl:variable name="hazardSymbolCellWidth" as="xs:string">
                <xsl:call-template name="getVarValue">
                    <xsl:with-param name="prmVarName" select="'HazardSymbolCellWidth'"/>
                </xsl:call-template>
            </xsl:variable>
            <xsl:sequence select="ahf:toTwip($hazardSymbolCellWidth)"/>
        </xsl:variable>
        
        <!-- Get table width -->
        <xsl:variable name="tableWidthInTwip" as="xs:integer" select="ahf:toTwip($pPaperBodyWidth)"/>
        
        <!-- Message panel cell width -->
        <xsl:variable name="messagePanelCellWidthInTwip" as="xs:integer" select="$tableWidthInTwip - $hazardSymbolCellWidthInTwip"/>
        
        <!-- Hazard statement signal word icon -->
        <xsl:variable name="iconFileName" as="xs:string">
            <xsl:call-template name="getVarValue">
                <xsl:with-param name="prmVarName" select="'HazardStatementIcon'"/>
            </xsl:call-template>
        </xsl:variable>
        
        <xsl:variable name="iconFileId" as="xs:string" select="string(map:get($commonImageIdMap,$iconFileName))"/>
        
        <xsl:variable name="drawingIdKey" as="xs:string" select="ahf:generateId(.)"/>
        <xsl:variable name="drawingId" as="xs:string" select="xs:string(map:get($drawingIdMap,$drawingIdKey))"/>
        
        <xsl:variable name="iconImageWidthInEmu" as="xs:integer">
            <xsl:variable name="iconImageWidth" as="xs:string">
                <xsl:call-template name="getVarValueWithLang">
                    <xsl:with-param name="prmVarName" select="'HazardStatementIconWidth'"/>
                </xsl:call-template>
            </xsl:variable>
            <xsl:sequence select="ahf:toEmu($iconImageWidth)"/>
        </xsl:variable>
        
        <xsl:variable name="iconImageHeightInEmu" as="xs:integer">
            <xsl:variable name="iconImageHeight" as="xs:string">
                <xsl:call-template name="getVarValueWithLang">
                    <xsl:with-param name="prmVarName" select="'HazardStatementIconHeight'"/>
                </xsl:call-template>
            </xsl:variable>
            <xsl:sequence select="ahf:toEmu($iconImageHeight)"/>
        </xsl:variable>
        
        <xsl:variable name="iconImageWidthToHeightRatio" as="xs:double" select="$iconImageHeightInEmu div $iconImageWidthInEmu"/>
        
        <xsl:variable name="hazardStatementSignalWordFontSizeInEmu" as="xs:integer">
            <xsl:variable name="hazrdStatementSignalWordFontSize">
                <xsl:call-template name="getVarValue">
                    <xsl:with-param name="prmVarName" select="'HazardStatementSignalWordFontSize'"/>
                </xsl:call-template>
            </xsl:variable>
            <xsl:sequence select="ahf:toEmu($hazrdStatementSignalWordFontSize)"/>
        </xsl:variable>
        
        <xsl:variable name="hazardStatementIconRelativeRatio" as="xs:double">
            <xsl:call-template name="getVarValueAsDouble">
                <xsl:with-param name="prmVarName" select="'HazardStatementIconRelativeRatio'"/>
            </xsl:call-template>
        </xsl:variable>
        
        <xsl:variable name="hazardStatementIconActualWidthInEmu" as="xs:integer" select="xs:integer(round($hazardStatementSignalWordFontSizeInEmu * $hazardStatementIconRelativeRatio))"/>
        <xsl:variable name="hazardStatementIconActualHeightInEmu" as="xs:integer" select="xs:integer(round($hazardStatementSignalWordFontSizeInEmu * $hazardStatementIconRelativeRatio * $iconImageWidthToHeightRatio))"/>
        
        <xsl:variable name="iconImage" as="element(w:drawing)">
            <xsl:call-template name="getWmlObjectReplacing">
                <xsl:with-param name="prmObjName" select="'wmlNoteImage'"/>
                <xsl:with-param name="prmSrc" select="('%width','%height','%id','%name','%desc','%rid')"/>
                <xsl:with-param name="prmDst" select="(string($hazardStatementIconActualWidthInEmu), string($hazardStatementIconActualHeightInEmu),$drawingId,string(@type),string(@type),concat($rIdPrefix,$iconFileId))"/>
            </xsl:call-template>
        </xsl:variable>
        
        <!-- message panel -->
        <xsl:variable name="panelContents" as="document-node()">
            <xsl:document>
                <xsl:call-template name="genHsRows">
                    <xsl:with-param name="prmHsElem" select="."/>
                </xsl:call-template>
            </xsl:document>
        </xsl:variable>

        <!-- Hazard statement table -->
        <xsl:call-template name="getWmlObjectReplacing">
            <xsl:with-param name="prmObjName" select="'wmlHazardStatementTable'"/>
            <xsl:with-param name="prmSrc" select="('%pic-cell-width','%message-panel-cell-width','node:icon-image','%signal-word','node:rows')"/>
            <xsl:with-param name="prmDst" select="(string($hazardSymbolCellWidthInTwip),string($messagePanelCellWidthInTwip),$iconImage,$hsSignalWord,$panelContents)"/>
        </xsl:call-template>
        
    </xsl:template>

    <!-- 
     function:	Generate sequence of w:row of hazardstatement table
     param:		prmHsElem (hazardstatement element)
     return:	w:tr+
     note:      
     -->
    <xsl:template name="genHsRows" as="element(w:tr)+">
        <xsl:param name="prmHsElem" as="element()" required="yes"/>
        <xsl:for-each select="$prmHsElem/*[@class => contains-token('hazard-d/messagepanel')]">
            <xsl:variable name="hsRowContent" as="element(w:tr)">
                <xsl:call-template name="genHsRow">
                    <xsl:with-param name="prmMessagePanel" select="."/>
                    <xsl:with-param name="prmHsElem" select="$prmHsElem"/>
                    <xsl:with-param name="prmPosition" select="position()"/>
                </xsl:call-template>
            </xsl:variable>
            <xsl:sequence select="$hsRowContent"/>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="genHsRow" as="element(w:tr)">
        <xsl:param name="prmMessagePanel" as="element()" required="yes"/>
        <xsl:param name="prmHsElem" as="element()" required="yes"/>
        <xsl:param name="prmPosition" as="xs:integer" required="yes"/>
        
        <xsl:variable name="hazardSymbol" as="element(w:r)?">
            <xsl:variable name="hazardSymbolWml" as="element(w:drawing)?">
                <xsl:call-template name="genHazardSymbol">
                    <xsl:with-param name="prmHazardSymbol" select="$prmHsElem/*[@class => contains-token('hazard-d/hazardsymbol')][$prmPosition]"/>
                </xsl:call-template>            
            </xsl:variable>
            <xsl:choose>
                <xsl:when test="exists($hazardSymbolWml)">
                    <w:r>
                        <w:rPr>
                            <w:noProof/>
                        </w:rPr>
                        <xsl:copy-of select="$hazardSymbolWml"/>
                    </w:r>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:variable name="panelChildPs" as="document-node()">
            <xsl:variable name="numId" as="xs:string">
                <xsl:variable name="listOuucrrenceNumber" as="xs:integer" select="map:get($listNumberMap,ahf:generateId($prmMessagePanel))"/>
                <xsl:sequence select="ahf:getNumIdFromListOccurenceNumber($listOuucrrenceNumber)"/>
            </xsl:variable>
            <xsl:document>
                <xsl:for-each select="$prmMessagePanel/*">
                    <!-- ((typeofhazard) then (consequence) (any number) then (howtoavoid) (one or more) ) --> 
                    <xsl:variable name="panelChild" as="element()" select="."/>
                    <xsl:choose>
                        <xsl:when test="ahf:isEmptyElement($panelChild)">
                            <xsl:sequence select="()"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:variable name="childInlines" as="document-node()">
                                <xsl:document>
                                    <xsl:apply-templates select="$panelChild/node()">
                                        <xsl:with-param name="prmRunProps" tunnel="yes" select="()"/>
                                    </xsl:apply-templates>
                                </xsl:document>
                            </xsl:variable>
                            <xsl:variable name="lineHeight" as="xs:string">
                                <xsl:call-template name="getVarValueWithLang">
                                    <xsl:with-param name="prmVarName" select="'MessagePanelElementsLineHeightRatio'"/>
                                </xsl:call-template>
                            </xsl:variable>
                            <!-- Generate w:p -->
                            <xsl:call-template name="getWmlObjectReplacing">
                                <xsl:with-param name="prmObjName" select="'wmlMessgaPanelChildElement'"/>
                                <xsl:with-param name="prmSrc" select="('%num-id','node:panelChild')"/>
                                <xsl:with-param name="prmDst" select="($numId,if (empty($childInlines/*)) then $cElemNull else $childInlines)"/>
                            </xsl:call-template>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </xsl:document>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="exists($prmHsElem/*[@class => contains-token('hazard-d/hazardsymbol')])">
                <xsl:call-template name="getWmlObjectReplacing">
                    <xsl:with-param name="prmObjName" select="'wmlHazardStatementRow'"/>
                    <xsl:with-param name="prmSrc" select="('node:icon-image','node:messagepanel')"/>
                    <xsl:with-param name="prmDst" select="(if (empty($hazardSymbol)) then $cElemNull else $hazardSymbol,$panelChildPs)"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="getWmlObjectReplacing">
                    <xsl:with-param name="prmObjName" select="'wmlHazardStatementRowWoHs'"/>
                    <xsl:with-param name="prmSrc" select="('node:messagepanel')"/>
                    <xsl:with-param name="prmDst" select="($panelChildPs)"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>

    <!-- 
     function:	Generate w:r that contains hazardsymbol
     param:		prmHazardSymbol (hazardsymbol element)
     return:	w:r?
     note:      
     -->
    <xsl:template name="genHazardSymbol" as="element(w:drawing)?">
        <xsl:param name="prmHazardSymbol" as="element()?" required="yes"/>
        <xsl:choose>
            <xsl:when test="exists($prmHazardSymbol)">
                <xsl:variable name="imageSize" as="xs:integer+">
                    <xsl:call-template name="ahf:getImageSizeInEmu">
                        <xsl:with-param name="prmImage" select="$prmHazardSymbol"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:variable name="imageFileName" as="xs:string" select="ahf:substringAfterLast(ahf:bsToSlash($prmHazardSymbol/@href),'/')"/>
                <xsl:variable name="isSvg" as="xs:boolean" select="ends-with(lower-case($imageFileName),'.svg')"/>
                <xsl:variable name="imageIdKey" as="xs:string" select="string($prmHazardSymbol/@href)"/>
                <xsl:variable name="imageId" as="xs:string" select="xs:string(map:get($imageIdMap,$imageIdKey))"/>
                <xsl:variable name="drawingIdKey" as="xs:string" select="ahf:generateId($prmHazardSymbol)"/>
                <xsl:variable name="drawingId" as="xs:string" select="xs:string(map:get($drawingIdMap,$drawingIdKey))"/>
                <xsl:variable name="proposedHazardSymbolWidthInEmu" as="xs:integer">
                    <xsl:variable name="proposedHazardSymbolWidth" as="xs:string">
                        <xsl:call-template name="getVarValue">
                            <xsl:with-param name="prmVarName" select="'HazardSymbolWidth'"/>
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:sequence select="ahf:toEmu($proposedHazardSymbolWidth)"/>
                </xsl:variable>
                <xsl:choose>
                    <xsl:when test="($imageSize[1] gt 0) and ($imageSize[2] gt 0)">
                        <xsl:variable name="widthToHeightRatio" as="xs:double" select="$imageSize[2] div $imageSize[1]"/>
                        <xsl:variable name="hazardSymbolHeightInEmu" as="xs:integer" select="xs:integer(round($proposedHazardSymbolWidthInEmu * $widthToHeightRatio))"/>
                        <xsl:call-template name="getWmlObjectReplacing">
                            <xsl:with-param name="prmObjName" select="if ($isSvg) then 'wmlImageSvg' else 'wmlImage'"/>
                            <xsl:with-param name="prmSrc" select="('%width','%height','%id','%name','%desc','%rid')"/>
                            <xsl:with-param name="prmDst" select="(string($proposedHazardSymbolWidthInEmu),string($hazardSymbolHeightInEmu),$drawingId,$imageFileName,$imageFileName,concat($rIdPrefix,$imageId))"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="warningContinue">
                            <xsl:with-param name="prmMes" select="ahf:replace($stMes2020,('%href'),(string($prmHazardSymbol/@href)))"/>                    
                        </xsl:call-template>
                        <xsl:sequence select="()"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- ==== END OF STYLESHEET === -->

</xsl:stylesheet>