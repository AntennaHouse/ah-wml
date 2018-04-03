<?xml version="1.0" encoding="UTF-8"?>
<!--
**************************************************************
DITA to WordprocessingML Stylesheet
word/_rels/document.xml.rels Templates
**************************************************************
File Name : dita2wml_document_topic.xsl
**************************************************************
Copyright © 2009-2017 Antenna House, Inc. All rights reserved.
Antenna House is a trademark of Antenna House, Inc.
URL : http://www.antennahouse.co.jp/
**************************************************************
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    xmlns:r="http://schemas.openxmlformats.org/package/2006/relationships"
    xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
    exclude-result-prefixes="xs ahf map"
    version="3.0">

    <!-- Template _rels file -->   
    <xsl:variable name="relsDoc" as="document-node()" select="doc(concat($PRM_TEMPLATE_DIR_URL,'word/_rels/document.xml.rels'))"/>

    <!-- Relationship namespace -->
    <xsl:variable name="rsNs" as="xs:string">
        <xsl:call-template name="getVarValue">
            <xsl:with-param name="prmVarName" select="'Relationship_Table_Namespace'"/>
        </xsl:call-template>
    </xsl:variable>

    <!-- 
     function:	Generate relationships both from template "_rels" file and DITA merged middle file
     param:		
     return:	Relationships
     note:		Relationship ID is obtained from $imageIdMap, $commonImageIdMap.
     -->
    <xsl:template match="/">
        <xsl:element name="Relationships" namespace="{$rsNs}">
            <xsl:variable name="originalRels" select="$relsDoc/r:Relationships/r:Relationship" as="element()*"/>
            <xsl:copy-of select="$originalRels"/>

            <!-- Generate common image relationships -->
            <xsl:for-each select="map:keys($commonImageIdMap)">
                <xsl:variable name="file" as="xs:string" select="."/>
                <xsl:variable name="rId" as="xs:string" select="concat('rId',map:get($commonImageIdMap,$file))"/>
                <xsl:call-template name="getWmlObjectReplacing">
                    <xsl:with-param name="prmObjName" select="'wmlImageRelationship'"/>
                    <xsl:with-param name="prmSrc" select="('%id','%target')"/>
                    <xsl:with-param name="prmDst" select="($rId,concat('media/',$file))"/>
                </xsl:call-template> 
            </xsl:for-each>
            
            <!-- Generate image relationships contained in DITA document -->
            <xsl:for-each select="map:keys($imageIdMap)">
                <xsl:variable name="href" as="xs:string" select="."/>
                <xsl:variable name="rId" as="xs:string" select="concat('rId',map:get($imageIdMap,$href))"/>
                <xsl:call-template name="getWmlObjectReplacing">
                    <xsl:with-param name="prmObjName" select="'wmlImageRelationship'"/>
                    <xsl:with-param name="prmSrc" select="('%id','%target')"/>
                    <xsl:with-param name="prmDst" select="($rId,concat('media/',$href))"/>
                </xsl:call-template> 
            </xsl:for-each>

            <!-- Generate external link relationships contained in DITA document -->
            <xsl:for-each select="map:keys($externalLinkIdMap)">
                <xsl:variable name="href" as="xs:string" select="."/>
                <xsl:variable name="rId" as="xs:string" select="concat('rId',map:get($externalLinkIdMap,$href))"/>
                <xsl:call-template name="getWmlObjectReplacing">
                    <xsl:with-param name="prmObjName" select="'wmlExternalLinkRelationship'"/>
                    <xsl:with-param name="prmSrc" select="('%id','%target')"/>
                    <xsl:with-param name="prmDst" select="($rId,$href)"/>
                </xsl:call-template> 
            </xsl:for-each>
        </xsl:element>
    </xsl:template>

    <!-- END OF STYLESHEET -->

</xsl:stylesheet>