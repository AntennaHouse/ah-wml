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
         2. Maintain simpletable/sthead,strow/stentry column number information for make compatibility with table.
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
     note:      DEBUG: There is tgroup/@cols that is not match the actual column count.
                       2019-01-08 t.makita
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
        
        <!-- debug -->
        <!--
        <xsl:for-each select="$tGroup/descendant::*[@class => contains-token('topic/entry')]">
            <xsl:variable name="entry" as="element()" select="."/>
            <xsl:variable name="colname" as="xs:string" select="string($entry/@colname)"/>
            <xsl:if test="string($colname)">
                <xsl:variable name="result" as="xs:boolean" select="some $colspec in $colspecNormalized/* satisfies string($colspec/@colname) eq $colname"/>
                <xsl:if test="not($result)">
                    <xsl:message select="'Invalid colname=',$colname, 'tgroup=', $tGroup"></xsl:message>
                </xsl:if>
            </xsl:if>
            <xsl:variable name="namest" as="xs:string" select="string($entry/@namest)"/>
            <xsl:if test="string($namest)">
                <xsl:variable name="result" as="xs:boolean" select="some $colspec in $colspecNormalized/* satisfies string($colspec/@colname) eq $namest"/>
                <xsl:if test="not($result)">
                    <xsl:message select="'Invalid namest=',$namest, 'tgroup=', $tGroup"></xsl:message>
                </xsl:if>
            </xsl:if>
            <xsl:variable name="nameend" as="xs:string" select="string($entry/@nameend)"/>
            <xsl:if test="string($nameend)">
                <xsl:variable name="result" as="xs:boolean" select="some $colspec in $colspecNormalized/* satisfies string($colspec/@colname) eq $nameend"/>
                <xsl:if test="not($result)">
                    <xsl:message select="'Invalid nameend=',$nameend, 'tgroup=', $tGroup"></xsl:message>
                </xsl:if>
            </xsl:if>
        </xsl:for-each>
        -->

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

    <!-- 
     function:	Maintain simpletable
     param:		none
     return:	<simpletable>
     note:		
     -->
    <xsl:template match="*[contains(@class, ' topic/simpletable ')]" as="element()">
        <xsl:call-template name="expandSimpleTableWithSpanInfo">
            <xsl:with-param name="prmSimpleTable" select="."/>
        </xsl:call-template>
    </xsl:template>

</xsl:stylesheet>
