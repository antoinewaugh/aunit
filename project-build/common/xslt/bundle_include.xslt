<?xml version="1.0" standalone="yes"?> 
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xslt="http://xml.apache.org/xslt">

	<!--  The template to use for 'header' -->
	<xsl:template name="header">
		<xsl:attribute name="name"><xsl:value-of select="@name"/></xsl:attribute>
		<xsl:attribute name="type">monitorscript</xsl:attribute>
		<xsl:attribute name="singleton"><xsl:value-of select="@singleton"/></xsl:attribute>
		<xsl:element name="description"><xsl:value-of select="@description"/></xsl:element>
	</xsl:template>

	<!--  The template to use for 'dependencies' -->
	<xsl:template match="dependencies">
		<xsl:element name="dependencies">
			<!-- Loop through each 'dependency' tag -->
			<xsl:for-each select="dependency">
				<xsl:element name="dependency">
					<xsl:attribute name="bundle-filename"><xsl:value-of select="@bundle-filename"/></xsl:attribute>
					<!-- Only output catalog if its set -->
					<xsl:choose>
						<xsl:when test="@catalog != ''">
							<xsl:attribute name="catalog"><xsl:value-of select="@catalog"/></xsl:attribute>
						</xsl:when>
					</xsl:choose>
				</xsl:element>
			</xsl:for-each>
		</xsl:element>
	</xsl:template>

	<!--  The template to use for 'block-catalogs' -->
	<xsl:template match="block-catalogs">
		<xsl:element name="block-catalogs">
			<!-- Loop through each 'directory' tag -->
			<xsl:for-each select="directory">
				<xsl:element name="directory">
					<xsl:attribute name="location"><xsl:value-of select="@location"/></xsl:attribute>
				</xsl:element>
			</xsl:for-each>
		</xsl:element>
	</xsl:template>

	<!--  The template to use for 'function-catalogs' -->
	<xsl:template match="function-catalogs">
		<xsl:element name="function-catalogs">
			<!-- Loop through each 'directory' tag -->
			<xsl:for-each select="directory">
				<xsl:element name="directory">
					<xsl:attribute name="location"><xsl:value-of select="@location"/></xsl:attribute>
				</xsl:element>
			</xsl:for-each>
		</xsl:element>
	</xsl:template>

	<!--  The template to use for 'dashboard-files' -->
	<xsl:template match="dashboard-files">
		<xsl:element name="dashboard-files">
			<!-- Loop through each 'fileset' tag -->
			<xsl:for-each select="fileset">
				<xsl:element name="fileset">
					<xsl:attribute name="dir"><xsl:value-of select="../../@dir"/>/<xsl:value-of select="@dir"/></xsl:attribute>
					<!-- Loop through each 'include' tag -->
					<xsl:for-each select="include">
						<xsl:element name="include">
							<xsl:attribute name="name"><xsl:value-of select="@name"/></xsl:attribute>
						</xsl:element>
					</xsl:for-each>
				</xsl:element>
			</xsl:for-each>
		</xsl:element>
	</xsl:template>

	<!--  The template to use for 'events' -->
	<xsl:template match="events">
		<xsl:element name="events">
			<!-- Loop through each 'file' tag -->
			<xsl:for-each select="file">
				<xsl:element name="file">
					<xsl:attribute name="name"><xsl:value-of select="@name"/></xsl:attribute>
				</xsl:element>
			</xsl:for-each>
		</xsl:element>
	</xsl:template>

</xsl:stylesheet>
