<?xml version='1.0' encoding="UTF-8" ?>
<!--
****************************************************************
DITA to WordprocessingML Stylesheet
Module: Build colspec tree for meged middle file processing
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
         1. Maintain table/colspec information and add @ahf:colwidth-ratio for each colspec.
     -->

    <!-- 
     function:	Generate nomalized colspec tree
     param:		prmTgroup
     return:	document-node()
     note:      DITA-OT guarantees colspec/@colnum,@colname after parsing		
     -->
    <xsl:template name="buildColSpecTree" as="document-node()">
        <xsl:param name="prmTgroup" select="."/>
        
        <!-- Complement colwidth -->
        <xsl:variable name="colspecComplemented" as="document-node()">
            <xsl:document>
                <xsl:for-each select="$prmTgroup/*[@class => contains-token('topic/colspec')]">
                    <xsl:copy>
                        <xsl:copy-of select="@*"/>
                        <xsl:choose>
                            <xsl:when test="@colwidth">
                                <xsl:variable name="colWidth" as="xs:string" select="string(@colwidth)"/>
                                <xsl:choose>
                                    <xsl:when test="contains($colWidth,'*')">
                                        <xsl:attribute name="ahf:colwidth-normalized" select="substring-before($colWidth,'*')"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:attribute name="colwidth" select="'1*'"/>
                                        <xsl:attribute name="ahf:colwidth-normalized" select="'1'"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:attribute name="colwidth" select="'1*'"/>
                                <xsl:attribute name="ahf:colwidth-normalized" select="'1'"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:copy>
                </xsl:for-each>
            </xsl:document>
        </xsl:variable>
        
        <!-- Calculate column width sum -->
        <xsl:variable name="colWidthSum" as="xs:double" select="sum($colspecComplemented/*[@class => contains-token('topic/colspec')]/@ahf:colwidth-normalized/xs:double(string(.)))"/>
        <xsl:assert test="$colWidthSum gt 0" select="'[buildColSpecTree] Invalid colwidth table=', ahf:getHistoryStr($prmTgroup/parent::*),' $colspecComplemented=',$colspecComplemented"/>

        <!-- Calculate column width ratio --> 
        <xsl:variable name="colspecCalculated" as="document-node()">
            <xsl:document>
                <xsl:for-each select="$colspecComplemented/*[@class => contains-token('topic/colspec')]">
                    <xsl:copy>
                        <xsl:copy-of select="@*"/>
                        <xsl:attribute name="ahf:colwidth-ratio" select="string(xs:double(xs:double(@ahf:colwidth-normalized) div $colWidthSum * 100))"/>
                    </xsl:copy>
                </xsl:for-each>
            </xsl:document>
        </xsl:variable>
        
        <xsl:sequence select="$colspecCalculated"/>
    </xsl:template>

</xsl:stylesheet>
