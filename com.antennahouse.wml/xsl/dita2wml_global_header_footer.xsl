<?xml version="1.0" encoding="UTF-8" ?>
<!--
****************************************************************
DITA to WordprocessingML Stylesheet
Module: WordprocessingML global constants.
Copyright © 2009-2017 Antenna House, Inc. All rights reserved.
Antenna House is a trademark of Antenna House, Inc.
URL    : http://www.antennahouse.com/
E-mail : info@antennahouse.com
****************************************************************
-->
<xsl:stylesheet version="3.0" 
    xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
    xmlns:r="http://schemas.openxmlformats.org/package/2006/relationships"
    xmlns:ct="http://schemas.openxmlformats.org/package/2006/content-types"
    exclude-result-prefixes="xs map ahf"
>
    <!-- ****************************************************************************** 
           Global Header/Footer Definition
         ******************************************************************************-->
    <!-- Relatioship Type -->
    <xsl:variable name="relationshipTypeHeader" as="xs:string">
        <xsl:call-template name="getVarValue">
            <xsl:with-param name="prmVarName" select="'RelationshipTypeHeader'"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="relationshipTypeFooter" as="xs:string">
        <xsl:call-template name="getVarValue">
            <xsl:with-param name="prmVarName" select="'RelationshipTypeFooter'"/>
        </xsl:call-template>
    </xsl:variable>
    
    <!-- Content Type -->
    <xsl:variable name="contentTypeHeader" as="xs:string">
        <xsl:call-template name="getVarValue">
            <xsl:with-param name="prmVarName" select="'ContentTypeHeader'"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="contentTypeFooter" as="xs:string">
        <xsl:call-template name="getVarValue">
            <xsl:with-param name="prmVarName" select="'ContentTypeFooter'"/>
        </xsl:call-template>
    </xsl:variable>
    
    <!-- Constants for $headerFooterDefinitionSeq -->
    <xsl:variable name="headerFooterDefinitionItemCount" as="xs:integer" select="5"/>
    <xsl:variable name="cOffsetHeaderFooterFileName" as="xs:integer" select="1"/>
    <xsl:variable name="cOffsetHeaderFooterWmlObjectName" as="xs:integer" select="2"/>
    <xsl:variable name="cOffsetHeaderFooterRefType" as="xs:integer" select="3"/>
    <xsl:variable name="cOffsetHeaderFooterUsage" as="xs:integer" select="4"/>
    <xsl:variable name="cOffsetHeaderFooterType" as="xs:integer" select="5"/>
    
    <xsl:variable name="cTypeHeader" as="xs:string" select="'header'"/>
    <xsl:variable name="cTypeFooter" as="xs:string" select="'footer'"/>
    
    <xsl:variable name="cHeaderFooterUsageMain" as="xs:string" select="'main'"/>
    <xsl:variable name="cHeaderFooterUsageFrontmatter" as="xs:string" select="'frontmatter'"/>
    <xsl:variable name="cHeaderFooterUsageAny" as="xs:string" select="'any'"/>
    
    <!-- Header/Footer Definition Sequence -->
    <xsl:variable name="headerFooterDefinitionSeq" as="xs:string+">
        <xsl:call-template name="getVarValueAsStringSequence">
            <xsl:with-param name="prmVarName" select="'HeaderFooterDefinitionSeq'"/>
        </xsl:call-template>
    </xsl:variable>
    
    <!-- Relationship definition base value for header/footer file -->
    <xsl:variable name="headerFooterRidBase" as="xs:integer">
        <xsl:call-template name="getVarValueAsInteger">
            <xsl:with-param name="prmVarName" select="'Default_Header_Footer_Id_Offset'"/>
        </xsl:call-template>
    </xsl:variable>
    
    <!-- Header/Footer Relationship ID Map
         Key: file name
         Value: rId
         ⇒Map is not used because $headerFooterDefinitionSeq is sufficient for any purpose.
     -->
    <!--xsl:variable name="headerFooterRelationshipIdMap" as="map(xs:string,xs:integer)">
        <xsl:map>
            <xsl:for-each select="1 to count($headerFooterDefinitionSeq) div $headerFooterDefinitionItemCount">
                <xsl:variable name="index" as="xs:integer" select="."/>
                <xsl:variable name="key" as="xs:string" select="$headerFooterDefinitionSeq[($index - 1) * $headerFooterDefinitionItemCount + $cOffsetHeaderFooterFileName]"/>
                <xsl:variable name="id" as="xs:integer" select="position() + $headerFooterRidBase"/>
                <xsl:map-entry key="$key" select="$id"/>
            </xsl:for-each>
        </xsl:map>
    </xsl:variable-->

    <!-- 
     function:	Generate Content Type Override entry for Header/Footer
     param:		None
     return:	ct:Override elements
     note:		Used to generate word/[Content_Types].xml
     -->
    <xsl:template name="genContentTypeOverride" as="element(ct:Override)+">
        <xsl:for-each select="1 to count($cmDistinctClearCandidateElements) div $headerFooterDefinitionItemCount">
            <xsl:variable name="index" as="xs:integer" select="."/>
            <xsl:variable name="file" as="xs:string" select="$headerFooterDefinitionSeq[($index - 1) * $headerFooterDefinitionItemCount + $cOffsetHeaderFooterFileName]"/>
            <xsl:variable name="type" as="xs:string" select="$headerFooterDefinitionSeq[($index - 1) * $headerFooterDefinitionItemCount + $cOffsetHeaderFooterType]"/>
            <xsl:variable name="typeAttr" as="xs:string" select="if ($type eq $cTypeHeader) then $contentTypeHeader else $contentTypeFooter"/>
            <xsl:element name="Override" namespace="http://schemas.openxmlformats.org/package/2006/content-types">
                <xsl:attribute name="PartName" select="concat('/word/',$file)"/>
                <xsl:attribute name="ContentType" select="$typeAttr"/>
            </xsl:element>
        </xsl:for-each>
    </xsl:template>

    <!-- 
     function:	Generate Relationship entry for Header/Footer
     param:		None
     return:	rs:Relationship elements
     note:		Used to generate word/_rels/document.xml.rels
     -->
    <xsl:template name="genHeaderFooterRelationship" as="element(r:Relationship)+">
        <xsl:for-each select="1 to count($cmDistinctClearCandidateElements) div $headerFooterDefinitionItemCount">
            <xsl:variable name="index" as="xs:integer" select="."/>
            <xsl:variable name="file" as="xs:string" select="$headerFooterDefinitionSeq[($index - 1) * $headerFooterDefinitionItemCount + $cOffsetHeaderFooterFileName]"/>
            <xsl:variable name="type" as="xs:string" select="$headerFooterDefinitionSeq[($index - 1) * $headerFooterDefinitionItemCount + $cOffsetHeaderFooterType]"/>
            <xsl:variable name="id" as="xs:integer" select="position() + $headerFooterRidBase"/>
            <xsl:variable name="rid" as="xs:string" select="concat($rIdPrefix,string($id))"/>
            <xsl:variable name="typeAttr" as="xs:string" select="if ($type eq $cTypeHeader) then $relationshipTypeHeader else $relationshipTypeFooter"/>            
            <xsl:element name="Relationship" namespace="http://schemas.openxmlformats.org/package/2006/relationships">
                <xsl:attribute name="Id" select="$rid"/>
                <xsl:attribute name="Type" select="$typeAttr"/>
                <xsl:attribute name="Target" select="$file"/>
            </xsl:element>
        </xsl:for-each>
    </xsl:template>

    <!-- 
     function:	Generate Header/Footer Reference entry for w:sectPr 
     param:		prmUsage
     return:	w:headerReference,w:footerReference elements
     note:		Used to generate header/footer reference in w:sectPr
     -->
    <xsl:template name="genHeaderFooterReferenceInSectPr" as="element()+">
        <xsl:param name="prmUsage" as="xs:string" required="no" select="$cHeaderFooterUsageMain"/>
        <xsl:for-each select="1 to count($cmDistinctClearCandidateElements) div $headerFooterDefinitionItemCount">
            <xsl:variable name="index" as="xs:integer" select="."/>
            <xsl:variable name="refType" as="xs:string" select="$headerFooterDefinitionSeq[($index - 1) * $headerFooterDefinitionItemCount + $cOffsetHeaderFooterRefType]"/>
            <xsl:variable name="type" as="xs:string" select="$headerFooterDefinitionSeq[($index - 1) * $headerFooterDefinitionItemCount + $cOffsetHeaderFooterType]"/>
            <xsl:variable name="usage" as="xs:string" select="$headerFooterDefinitionSeq[($index - 1) * $headerFooterDefinitionItemCount + $cOffsetHeaderFooterUsage]"/>
            <xsl:variable name="id" as="xs:integer" select="position() + $headerFooterRidBase"/>
            <xsl:variable name="rid" as="xs:string" select="concat($rIdPrefix,string($id))"/>
            <xsl:if test="($usage eq $cHeaderFooterUsageAny) or ($usage eq $prmUsage)">
                <xsl:element name="{if ($type eq $cTypeHeader) then 'w:headerReference' else 'w:footerReference'}">
                    <xsl:attribute name="w:type" select="$refType"/>
                    <xsl:attribute name="r:id" select="$rid"/>
                </xsl:element>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

</xsl:stylesheet>
