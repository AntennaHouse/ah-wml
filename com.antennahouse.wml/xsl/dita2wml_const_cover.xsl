<?xml version="1.0" encoding="UTF-8" ?>
<!--
****************************************************************
DITA to WordprocessingML Stylesheet
Module: Cover constants.
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
 exclude-result-prefixes="#all">
   <!-- 
      *************************************** 
         Cover Constants
      ***************************************-->

   <!-- Cover topicref/@outputclass value -->
   <xsl:variable name="cCover1" as="xs:string" select="'cover1'"/>
   <xsl:variable name="cCover2" as="xs:string" select="'cover2'"/>
   <xsl:variable name="cCover3" as="xs:string" select="'cover3'"/>
   <xsl:variable name="cCover4" as="xs:string" select="'cover4'"/>
   <xsl:variable name="coverOutputClassValue" as="xs:string+" select="($cCover1,$cCover2,$cCover3,$cCover4)"/>
   
    
</xsl:stylesheet>
