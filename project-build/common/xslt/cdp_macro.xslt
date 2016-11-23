<?xml version="1.0" standalone="yes"?> 
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xslt="http://xml.apache.org/xslt">
	
	<xsl:import href="macro_include.xslt"/>
	
	<xsl:output omit-xml-declaration="yes" method="xml" encoding="UTF-8" indent="yes" xslt:indent-amount="4"/>
	
	<!-- Find matching nested <bundle><cdp> tags -->
	<xsl:template match="bundle">
		<xsl:call-template name="header"/>
		<xsl:apply-templates select="cdp"/>
	</xsl:template>

	<!-- The template to use for 'cdp' -->
	<xsl:template match="cdp">
		<xsl:variable name="macro" select="@macro"/>
		
		<xsl:element name="target">
			<xsl:attribute name="name"><xsl:value-of select="@macro"/></xsl:attribute>
			<xsl:apply-templates select="../macros">
				<xsl:with-param name="macro_name" select="@macro"/>
			</xsl:apply-templates>
			
			<!-- Only output if we have a 'fileset' tag -->
			<xsl:if test="fileset">

				<xsl:element name="set-correlator-host-and-port">
					<xsl:attribute name="port">${port}</xsl:attribute>
					<xsl:attribute name="host">${host}</xsl:attribute>
				</xsl:element>

				<xsl:element name="engine-inject">
					<xsl:attribute name="cdp">true</xsl:attribute>
					<xsl:attribute name="port">${port}</xsl:attribute>
					<xsl:attribute name="host">${host}</xsl:attribute>
				
					<xsl:element name="filelist">
						<!-- Loop through each 'fileset' tag -->
						<xsl:for-each select="fileset">
							<xsl:attribute name="dir"><xsl:value-of select="../../@macro_dir"/></xsl:attribute>
							<!-- Loop through each 'include' tag -->
							<xsl:for-each select="include">
								<xsl:element name="file">
									<xsl:attribute name="name"><xsl:value-of select="@name"/></xsl:attribute>
								</xsl:element>
							</xsl:for-each>
						</xsl:for-each>
					</xsl:element>
				</xsl:element>
			</xsl:if>
		</xsl:element>
		<xsl:text>&#10;</xsl:text>
		<xsl:text>&#10;</xsl:text>

	</xsl:template>

	<!-- Filter any blank lines -->
	<xsl:template match="text()|@*"/>

</xsl:stylesheet>
