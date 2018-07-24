<?xml version='1.0' encoding="UTF-8" ?>
<!--
****************************************************************
DITA to WordprocessingML Stylesheet 
Module: Import layer shell stylesheet for preprocessing
Copyright © 2009-2014 Antenna House, Inc. All rights reserved.
Antenna House is a trademark of Antenna House, Inc.
URL    : http://www.antennahouse.com/
E-mail : info@antennahouse.com
****************************************************************
-->
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:include href="dita2wml_constants.xsl"/>
  <xsl:include href="dita2wml_history_id.xsl"/>

  <xsl:include href="dita2wml_convmerged4.xsl"/>
  <xsl:include href="dita2wml_convmerged_table_expand.xsl"/>
  <xsl:include href="dita2wml_convmerged_build_colspec.xsl"/>
</xsl:stylesheet>
