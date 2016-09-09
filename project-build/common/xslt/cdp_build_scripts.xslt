<?xml version="1.0" standalone="yes"?> 
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<!-- Get params from ANT -->
	<xsl:param name="manifest_extension"/>
	<xsl:param name="manifest_dir"/>
	<xsl:param name="ext"/>
	<xsl:param name="source_dir"/>
	<xsl:param name="macro_dir"/>

	<xsl:output omit-xml-declaration="yes" method="xml" encoding="UTF-8" indent="no"/>
	<xsl:strip-space elements="*"/>

	<!--  Find matching nested <bundle><cdp> tags -->
	<xsl:apply-templates select="/bundle/cdp"/>

	<!--  The template to use for 'cdp' -->
	<xsl:template match="cdp">
		<!-- Pull out the variables from the 'cdp' tag -->
		<xsl:variable name="extension" select="@ext"/>
		<!-- Match the ext to the variable extension-->
		<xsl:choose>
			<xsl:when test="$ext = $extension">
				<xsl:element name="mkdir">
					<xsl:attribute name="dir"><xsl:value-of select="$macro_dir"/></xsl:attribute>
				</xsl:element>
				<xsl:text>&#10;</xsl:text>
				<xsl:element name="engine-package">
					<!-- Loop through each 'fileset' tag -->
					<xsl:for-each select="fileset">
						<xsl:attribute name="dir"><xsl:value-of select="$source_dir"/></xsl:attribute>
						<!-- Loop through each 'include' tag -->
						<xsl:for-each select="include">
							<xsl:attribute name="manifest"><xsl:value-of select="concat($manifest_dir, '/', ../../../@name, $manifest_extension)"/></xsl:attribute>
							<xsl:attribute name="output"><xsl:value-of select="concat($macro_dir, '/', @name)"/></xsl:attribute>
							<xsl:attribute name="dir"><xsl:value-of select="$source_dir"/></xsl:attribute>
						</xsl:for-each>
					</xsl:for-each>
				</xsl:element>
				
				<!-- Loop through each 'fileset' tag -->
				<xsl:for-each select="fileset">
					<!-- Loop through each 'include' tag -->
					<xsl:for-each select="include">
						<xsl:text>&#10;</xsl:text>
						<xsl:element name="loadfile">
							<xsl:attribute name="property"><xsl:value-of select="translate(concat(../../../@name, $manifest_extension), ' ', '_')"/></xsl:attribute>
							<xsl:attribute name="srcFile"><xsl:value-of select="concat($manifest_dir, '/', ../../../@name, $manifest_extension)"/></xsl:attribute>
							<xsl:attribute name="failonerror">true</xsl:attribute>
						</xsl:element>
						<xsl:text>&#10;</xsl:text>
						
						<xsl:element name="for">
							<xsl:attribute name="param">line</xsl:attribute>
							<xsl:attribute name="list">${<xsl:value-of select="translate(concat(../../../@name, $manifest_extension), ' ', '_')"/>}</xsl:attribute>
							<xsl:attribute name="delimiter">${line.separator}</xsl:attribute>
							<xsl:text>&#10;</xsl:text>
						
							<xsl:element name="sequential">
								<xsl:element name="create-hash">
									<xsl:attribute name="file"><xsl:value-of select="concat($source_dir, '/@{line}')"/></xsl:attribute>
								</xsl:element>
							</xsl:element>
							<xsl:text>&#10;</xsl:text>
						</xsl:element>
					</xsl:for-each>
				</xsl:for-each>

				<xsl:text>&#10;</xsl:text>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<!-- Filter any blank lines -->
	<xsl:template match="text()|@*"/>

</xsl:stylesheet>
