<?xml version='1.0' encoding="UTF-8" ?>
<!--
****************************************************************
DITA to WordprocessingML Stylesheet
Module: Text mode templates
Copyright © 2009-2017 Antenna House, Inc. All rights reserved.
Antenna House is a trademark of Antenna House, Inc.
URL    : http://www.antennahouse.com/
E-mail : info@antennahouse.com
****************************************************************
-->
<xsl:stylesheet version="3.0" 
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:xs="http://www.w3.org/2001/XMLSchema"
 xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
 exclude-result-prefixes="#all" 
>
    
    <!-- ======================================================================
          Text-only templates
         ======================================================================
     -->
    
    <!-- * -->
    <xsl:template match="*" mode="MODE_TEXT_ONLY">
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    
    <!-- text -->
    <xsl:template match="text()" mode="MODE_TEXT_ONLY">
        <xsl:value-of select="."/>
    </xsl:template>
    
    <!-- fn -->
    <xsl:template match="*[contains(@class,' topic/fn ')]" mode="MODE_TEXT_ONLY">
    </xsl:template>
    
    <!-- tm -->
    <xsl:template match="*[contains(@class,' topic/tm ')]" mode="MODE_TEXT_ONLY">
        <xsl:apply-templates mode="#current"/>
        <xsl:variable name="tmType" as="xs:string" select="string(@tmtype)"/>
        <xsl:choose>
            <xsl:when test="$tmType eq 'tm'">
                <xsl:variable name="tmSymbolTmText" as="xs:string">
                    <xsl:call-template name="getVarValueWithLang">
                        <xsl:with-param name="prmVarName" select="'Tm_Symbol_Tm_Text'"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:value-of select="$tmSymbolTmText"/>
            </xsl:when>
            <xsl:when test="$tmType eq 'reg'">
                <xsl:variable name="tmSymbolRegText" as="xs:string">
                    <xsl:call-template name="getVarValueWithLang">
                        <xsl:with-param name="prmVarName" select="'Tm_Symbol_Reg_Text'"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:value-of select="$tmSymbolRegText"/>
            </xsl:when>
            <xsl:when test="$tmType eq 'service'">
                <xsl:variable name="tmSymbolServiceText" as="xs:string">
                    <xsl:call-template name="getVarValueWithLang">
                        <xsl:with-param name="prmVarName" select="'Tm_Symbol_Service_Text'"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:value-of select="$tmSymbolServiceText"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <!-- data-about -->
    <xsl:template match="*[contains(@class,' topic/data-about ')]" mode="MODE_TEXT_ONLY">
    </xsl:template>
    
    <!-- data -->
    <xsl:template match="*[contains(@class,' topic/data ')]" mode="MODE_TEXT_ONLY">
    </xsl:template>
    
    <!-- foreign -->
    <xsl:template match="*[contains(@class,' topic/foreign ')]" mode="MODE_TEXT_ONLY">
    </xsl:template>
    
    <!-- unknown -->
    <xsl:template match="*[contains(@class,' topic/unknown ')]" mode="MODE_TEXT_ONLY">
    </xsl:template>
    
    <!-- no-topic-nesting -->
    <xsl:template match="*[contains(@class,' topic/no-topic-nesting ')]" mode="MODE_TEXT_ONLY">
    </xsl:template>
    
    <!-- indexterm is coded in dita2fo_indexcommon.xsl -->
    
    <!-- required-cleanup -->
    <xsl:template match="*[contains(@class,' topic/required-cleanup ')]" mode="MODE_TEXT_ONLY"/>
    
    <!-- state -->
    <xsl:template match="*[contains(@class,' topic/state ')]" mode="MODE_TEXT_ONLY">
        <xsl:value-of select="@name"/>
        <xsl:text>=</xsl:text>
        <xsl:value-of select="@value"/>
    </xsl:template>
    
    <!-- boolean -->
    <xsl:template match="*[contains(@class,' topic/boolean ')]" mode="MODE_TEXT_ONLY">
        <xsl:value-of select="@state"/>
    </xsl:template>
    
</xsl:stylesheet>
