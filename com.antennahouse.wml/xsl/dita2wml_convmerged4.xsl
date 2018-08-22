<?xml version='1.0' encoding="UTF-8" ?>
<!--
****************************************************************
DITA to WordprocessingML Stylesheet
Module: Merged file conversion templates (4)
Copyright © 2009-2018 Antenna House, Inc. All rights reserved.
Antenna House is a trademark of Antenna House, Inc.
URL    : http://www.antennahouse.com/
E-mail : info@antennahouse.com
****************************************************************
-->
<xsl:stylesheet version="3.0" 
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:xs="http://www.w3.org/2001/XMLSchema"
 xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
 exclude-result-prefixes="xs ahf"
>
    <!-- This stylesheet has following functions:
         1. Maintain table/tgroup/thead, tbody adding column/row span information.
     -->

    <!-- 
     function:	General template
     param:		none
     return:	self and under-laying node
     note:		
     -->
    <xsl:template match="*">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="@*">
        <xsl:copy/>
    </xsl:template>

    <!-- Copy processing-instruction or comment or text in other pattern -->
    <xsl:template match="node()" priority="-10">
        <xsl:copy/>
    </xsl:template>

    <!-- 
     function:	Maintain table
     param:		none
     return:	<thead> or <tbody>
     note:		
     -->
    <xsl:template match="*[contains(@class, ' topic/tgroup ')]">
        <xsl:variable name="tGroup" as="element()" select="."/>
        <xsl:variable name="cols" as="xs:integer" select="xs:integer($tGroup/@cols)"/>

        <!-- Complement the @colwidth and calculate the column width ratio -->
        <xsl:variable name="colspecNormalized" as="document-node()?">
            <xsl:call-template name="buildColSpecTree">
                <xsl:with-param name="prmTgroup" select="$tGroup"/>
            </xsl:call-template>
        </xsl:variable>

        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:copy-of select="$colspecNormalized/*"/>
            
            <xsl:if test="$tGroup/*[contains(@class, ' topic/thead ')]">
                <xsl:call-template name="expandTheadOrTbodyWithSpanInfo">
                    <xsl:with-param name="prmColNumber" select="$cols"/>
                    <xsl:with-param name="prmColSpec" select="$colspecNormalized"/>
                    <xsl:with-param name="prmTableHeadOrBodyPart" select="$tGroup/*[contains(@class, ' topic/thead ')]"/>
                </xsl:call-template>
            </xsl:if>

            <xsl:call-template name="expandTheadOrTbodyWithSpanInfo">
                <xsl:with-param name="prmColNumber" select="$cols"/>
                <xsl:with-param name="prmColSpec" select="$colspecNormalized"/>
                <xsl:with-param name="prmTableHeadOrBodyPart" select="$tGroup/*[contains(@class, ' topic/tbody ')]"/>
            </xsl:call-template>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
