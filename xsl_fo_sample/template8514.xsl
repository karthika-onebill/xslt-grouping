<?xml version="1.0"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:s="http://www.stylusstudio.com/xquery"
	xmlns:fo="http://www.w3.org/1999/XSL/Format">

	<!--I update the functionality to group by tax id - getting data based on taxid grouping id -->
	<xsl:key name="group-by-taxid" match="invoice/accountInvoiceElements/accountInvoiceElements/invoiceElements/lineItems/taxLineItem/lineItems" use="code" />


	<xsl:decimal-format name="dollar" decimal-separator="." grouping-separator="," />
	<xsl:key name="lineItems-by-subscriptionIdentifier" match="/invoice/invoiceElements/lineItems" use="subscriptionIdentifier" />

	<xsl:key name="addressLineItems-by-subscriptionIdentifier" match="invoiceElements/lineItems[usageLineItem and not(bundleLineItem)]" use="concat(subscriptionIdentifier,../../shippingAddId, ../../../accountId)" />

	<xsl:key name="addressLineItems-by-bundleIdentifier" match="invoiceElements/lineItems[usageLineItem and bundleLineItem]" use="concat(bundleIdentifier,../../shippingAddId, ../../../accountId)" />

	<xsl:key name="addressLineItems-by-subscriptionIdentifier-NoUsage" match="invoiceElements/lineItems[not(usageLineItem)]" use="subscriptionIdentifier" />

	<xsl:key name="chargeSummary-by-subscriptionIdentifier" match="lineItems" use="subscriptionIdentifier" />

	<xsl:key name="chargeSummary-by-subscriptionIdentifier-MRC" match="lineItems[eventType='Recurring']" use="subscriptionIdentifier" />

	<xsl:key name="chargeSummary-by-subscriptionIdentifier-NRC" match="lineItems[not(eventType='Recurring') and not(eventType='USAGE' )]" use="subscriptionIdentifier" />

	<xsl:key name="chargeSummary-by-subscriptionIdentifier-USAGE" match="lineItems[eventType='USAGE']" use="subscriptionIdentifier" />

	<xsl:key name="usage_by_UOM" match="usageLineItem" use="concat(uomName,../../subscriptionIdentifier)" />

	<xsl:key name="tax-by-address-description" match="taxLineItem/lineItems" use="concat(ancestor::accountInvoiceElements/shipTo/addressId, description)" />

	<xsl:key name="tax-by-SI" match="taxLineItem/lineItems" use="concat(ancestor::invoiceElements/subscriptionIdentifier, description)" />

	<xsl:key name="addressLineItems-by-planDescription" match="invoiceElements/lineItems[eventType='Recurring' and not(bundleLineItem)]" use="concat(planDescription,concat(startDate,'-',endDate),../../shippingAddId, ../../../accountId)" />

	<xsl:key name="addressLineItems-by-planDescription-bundle" match="invoiceElements/lineItems/bundleLineItem[eventType='Recurring']" use="concat(planDescription,concat(startDate,'-',endDate),../../../../shippingAddId, ../../../../../accountId)" />

	<xsl:key name="addressLineItems-by-planDescription-NRC" match="invoiceElements/lineItems[eventType='Onetime' and not(bundleLineItem)]" use="concat(planDescription,concat(startDate,'-',endDate),../../shippingAddId, ../../../accountId)" />

	<xsl:key name="addressLineItems-by-planDescription-NRC-bundle" match="invoiceElements/lineItems/bundleLineItem[eventType='Onetime']" use="concat(planDescription,concat(startDate,'-',endDate),../../../../shippingAddId, ../../../../../accountId)" />

	<xsl:key name="taxes-by-code" match="taxLineItem/lineItems[not(../../bundleLineItem)]" use="code" />


	<xsl:variable name="color" select="/invoice/color" />
	<xsl:variable name="lightcolor" select="/invoice/brightColor" />
	<xsl:variable name="credit" select="'CR'" />
	<xsl:variable name="bkgrnd_clr" select="'#E5E5E5'" />
	<xsl:variable name="heading_font" select="'#000000'" />
	<xsl:variable name="table_bkgrnd_clr" select="'#FCFCFC'" />
	<xsl:variable name="font_family" select="'Verdana, Arial, Helvetica, sans-serif'" />
	<xsl:variable name="decimal_value" select="'#,##0.00'" />
	<xsl:variable name="header_bkgrnd_clr" select="'#BFBFBF'" />
	<xsl:template name="space">
		<fo:block>
			<xsl:text>&#xA0;</xsl:text>
		</fo:block>
	</xsl:template>

	<xsl:template name="bill_Time_Transactions">
		<xsl:if test="//billTimeLineItems!=''">
			<xsl:if test="//billTimeLineItems/billTimeTax/lineItems!='' or //billTimeLineItems/billTimeDiscount!=''">
				<xsl:call-template name="space" />
				<xsl:call-template name="space" />

				<fo:block margin="0pt" background-color="{$color}" font-weight="bold" font-size="10px" padding-bottom="4px" padding-left="3px" padding-right="3px" padding-top="5px" color="white" border-bottom="#FFFFFF 1.0px solid">
					<xsl:text>Discounts and Credits</xsl:text>
				</fo:block>
				<xsl:call-template name="space" />
				<fo:block>

					<fo:table width="100%" border-style="none" font-family="{$font_family}" font-size="10px">


						<fo:table-column column-width="20%" />
						<fo:table-column column-width="60%" />
						<fo:table-column column-width="20%" />
						<fo:table-body>
							<fo:table-row>
								<fo:table-cell background-repeat="repeat" background-color="{$bkgrnd_clr}" padding-bottom="7px" padding-left="3px" padding-right="3px" padding-top="7px">
									<fo:block font-weight="bold" font-size="8px" color="#5F5F5F">
										<xsl:text>DATE</xsl:text>
									</fo:block>
								</fo:table-cell>
								<fo:table-cell background-color="{$bkgrnd_clr}" text-align="center" padding-bottom="7px" padding-left="3px" padding-right="3px" padding-top="7px">
									<fo:block font-weight="bold" font-size="8px" color="#5F5F5F">

										<xsl:text>DESCRIPTION</xsl:text>
									</fo:block>
								</fo:table-cell>
								<fo:table-cell background-color="{$bkgrnd_clr}" text-align="end" padding-bottom="7px" padding-left="3px" padding-right="3px" padding-top="7px">
									<fo:block font-weight="bold" font-size="8px" color="#5F5F5F">
										<xsl:text>AMOUNT</xsl:text>
									</fo:block>
								</fo:table-cell>
							</fo:table-row>



						</fo:table-body>
					</fo:table>

					<!-- Bill Time Tax -->
					<xsl:if test="//billTimeLineItems/billTimeTax/lineItems!=''">
						<fo:table width="100%" border-style="none" font-family="{$font_family}" font-size="10px">
							<fo:table-column column-width="20%" />
							<fo:table-column column-width="60%" />
							<fo:table-column column-width="20%" />
							<fo:table-body>
								<xsl:for-each select="//billTimeLineItems/billTimeTax/lineItems">
									<fo:table-row>
										<fo:table-cell background-color="#FCFCFC" background-repeat="repeat" display-align="before" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px">
											<fo:block color="#5F5F5F" font-size="8px" text-align='left'>
												<xsl:value-of select="/invoice/currentDate"/>
											</fo:block>
										</fo:table-cell>
										<fo:table-cell background-color="#FCFCFC" background-repeat="repeat" display-align="before" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px">
											<fo:block color="#5F5F5F" font-size="8px" text-align='center'>
												<xsl:value-of select="description"/>
											</fo:block>
										</fo:table-cell>
										<fo:table-cell background-repeat="repeat" display-align="after" text-align="right" padding-bottom="3px" padding-left="3px" padding-right="5px" padding-top="3px" background-color="#FCFCFC">
											<fo:block color="#5F5F5F" font-size="8px" text-align='end'>
												<xsl:choose>
													<xsl:when test="taxAmount >= 0">
														<xsl:value-of select="concat(' ',/invoice/currency,format-number(taxAmount,'#,##0.00','dollar'))" />
													</xsl:when>
													<xsl:otherwise>
														<xsl:value-of select="concat(' ',/invoice/currency,format-number(taxAmount*-1,'#,##0.00','dollar'),' ',$credit)" />
													</xsl:otherwise>
												</xsl:choose>
											</fo:block>
										</fo:table-cell>
									</fo:table-row>
								</xsl:for-each>
							</fo:table-body>
						</fo:table>
					</xsl:if>
					<!-- Bill Time Tax Ends -->

					<!-- Bill Time Discount-->
					<xsl:if test="//billTimeLineItems/billTimeDiscount!=''">
						<fo:table width="100%" border-style="none" font-family="{$font_family}" font-size="10px">
							<fo:table-column column-width="20%" />
							<fo:table-column column-width="60%" />
							<fo:table-column column-width="20%" />
							<fo:table-body>
								<xsl:for-each select="//billTimeLineItems/billTimeDiscount">
									<fo:table-row>
										<fo:table-cell background-color="#FCFCFC" background-repeat="repeat" display-align="before" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px">
											<fo:block color="#5F5F5F" font-size="8px" text-align='left'>
												<xsl:value-of select="/invoice/currentDate"/>
											</fo:block>
										</fo:table-cell>
										<fo:table-cell background-color="#FCFCFC" background-repeat="repeat" display-align="center" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px">
											<fo:block color="#5F5F5F" font-size="8px" text-align='center'>
												<xsl:choose>
													<xsl:when test="description='Bill Time Discount'">
														<xsl:text>Bill Discount</xsl:text>
													</xsl:when>
													<xsl:otherwise>
														<xsl:value-of select="description"/>
													</xsl:otherwise>
												</xsl:choose>
											</fo:block>
										</fo:table-cell>
										<fo:table-cell background-color="#FCFCFC" background-repeat="repeat" display-align="after" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px">
											<fo:block color="#5F5F5F" font-size="8px" text-align='end'>
												<xsl:choose>
													<xsl:when test="amount >= 0">
														<xsl:value-of select="concat(' ',/invoice/currency,format-number(amount,'#,##0.00','dollar'))" />
													</xsl:when>
													<xsl:otherwise>
														<xsl:value-of select="concat(' ',/invoice/currency,format-number(amount*-1,'#,##0.00','dollar'),' ',$credit)" />
													</xsl:otherwise>
												</xsl:choose>
											</fo:block>
										</fo:table-cell>
									</fo:table-row>
								</xsl:for-each>
							</fo:table-body>
						</fo:table>
					</xsl:if>
					<!-- Bill Time Discount Ends-->


					<xsl:variable name="billTimeTaxTotal" select="sum(//billTimeLineItems/billTimeTax/lineItems/taxAmount)" />
					<xsl:variable name="billTimeDiscountTotal" select="sum(//billTimeLineItems/billTimeDiscount/amount)" />

					<fo:table width="100%" background-repeat="repeat">
						<fo:table-column column-width="85%" />
						<fo:table-column column-width="15%" />

						<fo:table-body>
							<fo:table-row>

								<fo:table-cell background-repeat="repeat" display-align="center" text-align="end" padding-bottom="5px" padding-right="5px" padding-left="3px" padding-top="5px" background-color="{$lightcolor}">
									<fo:block color="#5F5F5F" font-size="8px" text-align='end'>
										<xsl:text>Total Charges</xsl:text>
									</fo:block>
								</fo:table-cell>
								<fo:table-cell background-repeat="repeat" display-align="center" text-align="right" padding-bottom="3px" padding-left="3px" padding-right="5px" padding-top="3px" background-color="{$lightcolor}">
									<fo:block color="#5F5F5F" font-size="8px">
										<xsl:choose>
											<xsl:when test="$billTimeTaxTotal+$billTimeDiscountTotal >= 0">
												<xsl:value-of select="concat(' ',/invoice/currency,format-number(($billTimeTaxTotal+$billTimeDiscountTotal),'#,##0.00','dollar'))" />
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="concat(' ',/invoice/currency,format-number(($billTimeTaxTotal+$billTimeDiscountTotal) * -1,'#,##0.00','dollar'),' ',$credit)" />
											</xsl:otherwise>
										</xsl:choose>
									</fo:block>
								</fo:table-cell>
							</fo:table-row>
						</fo:table-body>
					</fo:table>
				</fo:block>
				<xsl:call-template name="space" />
				<xsl:call-template name="space" />
				<xsl:call-template name="space" />
			</xsl:if>
		</xsl:if>
	</xsl:template>


	<xsl:template name="tax_GrpByAddress">
		<xsl:call-template name="space" />
		<fo:block>
			<fo:table width="100%" border-style="none" font-family="{$font_family}" font-size="10px">
				<fo:table-column column-width="50%" />
				<fo:table-column column-width="50%" />
				<fo:table-header font-weight="bold">
					<fo:table-row>
						<fo:table-cell background-repeat="repeat" background-color="{$bkgrnd_clr}" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px">
							<fo:block font-weight="bold" font-size="8px" color="{$heading_font}">
								<xsl:text>DESCRIPTION</xsl:text>
							</fo:block>
						</fo:table-cell>
						<fo:table-cell background-color="{$bkgrnd_clr}" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px">
							<fo:block font-weight="bold" font-size="8px" color="{$heading_font}" text-align="right">
								<xsl:text>TAX AMOUNT</xsl:text>
							</fo:block>
						</fo:table-cell>
					</fo:table-row>
				</fo:table-header>
				<fo:table-body>
					<xsl:for-each select=".//taxLineItem/lineItems[generate-id(.)=generate-id(key('tax-by-address-description', concat(ancestor::accountInvoiceElements/shipTo/addressId, description))[1])]">
						<xsl:sort select="description" />
						<fo:table-row>
							<fo:table-cell background-color="{$table_bkgrnd_clr}" background-repeat="repeat" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px" display-align="center">
								<fo:block color="{$heading_font}" font-size="7px">
									<xsl:value-of select="description" />
								</fo:block>
							</fo:table-cell>
							<fo:table-cell background-color="{$table_bkgrnd_clr}" background-repeat="repeat" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px" display-align="center" text-align="right">
								<fo:block color="{$heading_font}" font-size="7px">
									<xsl:value-of select="concat(' ',/invoice/currency,format-number(sum(key('tax-by-address-description', concat(ancestor::accountInvoiceElements/shipTo/addressId, description))/taxAmount),$decimal_value,'dollar'))" />
								</fo:block>
							</fo:table-cell>
						</fo:table-row>
					</xsl:for-each>
					<fo:table-row>
						<fo:table-cell background-repeat="repeat" background-color="{$bkgrnd_clr}" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px">
							<fo:block font-weight="bold" font-size="8px" color="{$heading_font}">
								<xsl:text>Total Tax</xsl:text>
							</fo:block>
						</fo:table-cell>
						<fo:table-cell background-color="{$bkgrnd_clr}" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px">
							<fo:block font-weight="bold" font-size="8px" color="{$heading_font}" text-align="right">
								<xsl:call-template name="format_Currency">
									<xsl:with-param name="value">
										<xsl:value-of select="taxTotal" />
									</xsl:with-param>
								</xsl:call-template>
							</fo:block>
						</fo:table-cell>
					</fo:table-row>
				</fo:table-body>
			</fo:table>
		</fo:block>
	</xsl:template>
	<xsl:template name="tax_GrpBySI">
		<fo:block>
			<xsl:if test="totalTax >0">
				<fo:block>
					<xsl:call-template name="space" />
					<fo:block color="{$heading_font}" font-size="8px" font-weight="bold">
						<xsl:value-of select="subscriptionIdentifier" />
					</fo:block>
				</fo:block>
				<fo:block>
					<fo:table width="100%" border-style="none" font-family="{$font_family}" font-size="10px">
						<fo:table-column column-width="50%" />
						<fo:table-column column-width="50%" />
						<fo:table-header font-weight="bold">
							<fo:table-row>
								<fo:table-cell background-repeat="repeat" background-color="{$bkgrnd_clr}" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px">
									<fo:block font-weight="bold" font-size="8px" color="{$heading_font}">
										<xsl:text>DESCRIPTION</xsl:text>
									</fo:block>
								</fo:table-cell>
								<fo:table-cell background-color="{$bkgrnd_clr}" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px">
									<fo:block font-weight="bold" font-size="8px" color="{$heading_font}" text-align="right">
										<xsl:text>TAX AMOUNT</xsl:text>
									</fo:block>
								</fo:table-cell>
							</fo:table-row>
						</fo:table-header>
						<fo:table-body>
							<xsl:for-each select=".//taxLineItem/lineItems[generate-id(.)=generate-id(key('tax-by-SI', concat(ancestor::invoiceElements/subscriptionIdentifier, description))[1])]">
								<xsl:sort select="description" />
								<fo:table-row>
									<fo:table-cell background-color="{$table_bkgrnd_clr}" background-repeat="repeat" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px" display-align="center">
										<fo:block color="{$heading_font}" font-size="7px">
											<xsl:value-of select="description" />
										</fo:block>
									</fo:table-cell>

									<fo:table-cell background-color="{$table_bkgrnd_clr}" background-repeat="repeat" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px" display-align="center" text-align="right">
										<fo:block color="{$heading_font}" font-size="7px">
											<xsl:value-of select="concat(' ',/invoice/currency,format-number(sum(key('tax-by-SI', concat(ancestor::invoiceElements/subscriptionIdentifier, description))/taxAmount),$decimal_value,'dollar'))" />
										</fo:block>
									</fo:table-cell>
								</fo:table-row>
							</xsl:for-each>
							<fo:table-row>
								<fo:table-cell background-repeat="repeat" background-color="{$bkgrnd_clr}" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px">
									<fo:block font-weight="bold" font-size="8px" color="{$heading_font}">
										<xsl:text>Total Tax</xsl:text>
									</fo:block>
								</fo:table-cell>
								<fo:table-cell background-color="{$bkgrnd_clr}" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px">
									<fo:block font-weight="bold" font-size="8px" color="{$heading_font}" text-align="right">
										<xsl:call-template name="format_Currency">
											<xsl:with-param name="value">
												<xsl:value-of select="totalTax" />
											</xsl:with-param>
										</xsl:call-template>
									</fo:block>
								</fo:table-cell>
							</fo:table-row>
						</fo:table-body>
					</fo:table>
				</fo:block>
			</xsl:if>
		</fo:block>
	</xsl:template>
	<xsl:template name="Payment_Slip">
		<fo:block>
			<xsl:text>----------------------------------------------------------------------------------------------------------------------------------------
			</xsl:text>
			<fo:inline font-family="{$font_family}" color="#5F5F5F" font-size="12px">
				<xsl:text>Payment Instructions </xsl:text>
			</fo:inline>
			<fo:inline font-family="{$font_family}" color="#5F5F5F" font-size="8px">
				<fo:block>
					<xsl:text>Please reference invoice number with your payment</xsl:text>
					<xsl:text>&#10;</xsl:text>
				</fo:block>
			</fo:inline>

			<fo:block>

				<fo:block>
					<fo:table width="100%" background-repeat="repeat">
						<fo:table-column column-width="30%" background-repeat="repeat" />
						<fo:table-column column-width="15%" background-repeat="repeat" />
						<fo:table-column column-width="20%" background-repeat="repeat" />
						<fo:table-column column-width="30%" background-repeat="repeat" />
						<fo:table-body>
							<fo:table-row>
								<fo:table-cell>
									<fo:table width="100%" background-repeat="repeat" border-width="0pt" padding="0pt">
										<fo:table-column column-width="100%" />
										<fo:table-body>
											<fo:table-row>
												<fo:table-cell border-style="none" width="4.5cm" padding="5" background-repeat="repeat" font-family="Verdana, Arial, Helvetica, sans-serif" font-size="8px">
													<fo:block font-weight="bold" font-size="8px" color="#5F5F5F">
														<xsl:text>Bill To:</xsl:text>
													</fo:block>
													<fo:block color="#5F5F5F" font-size="8px" margin="0pt" padding-top="0px" text-align="left">
														<xsl:value-of select="/invoice/billTo/companyName" />
													</fo:block>
													<fo:block color="#5F5F5F" font-size="8px" margin="0pt" padding-top="0px" text-align="left">
														<xsl:value-of select="/invoice/billTo/addressLine1" />
													</fo:block>
													<xsl:if test="/invoice/billTo/addressLine2 !=''">
														<fo:block color="#5F5F5F" font-size="8px" margin="0pt" padding-top="0px" text-align="left">
															<xsl:value-of select="/invoice/billTo/addressLine2" />
														</fo:block>
													</xsl:if>
													<fo:block color="#5F5F5F" font-size="8px" margin="0pt" padding-top="0px" text-align="left">
														<xsl:value-of select="/invoice/billTo/city" />
														<xsl:value-of select="concat(', ',/invoice/billTo/state,' - ',/invoice/billTo/postalCode)" />

													</fo:block>
												</fo:table-cell>
											</fo:table-row>
										</fo:table-body>
									</fo:table>
								</fo:table-cell>
								<fo:table-cell>
									<fo:block>
									</fo:block>
								</fo:table-cell>
								<fo:table-cell>
									<fo:table>
										<fo:table-column />
										<fo:table-body border="3px">
											<fo:table-row>
												<fo:table-cell background-repeat="repeat" font-size="8px" margin="2pt" padding-top="4px" padding-right="3px">
													<fo:block color="#5F5F5F" text-align="start">
														<xsl:text>Account Number:</xsl:text>
													</fo:block>
												</fo:table-cell>
											</fo:table-row>
											<fo:table-row>
												<fo:table-cell background-repeat="repeat" font-size="8px" margin="2pt" padding-right="4px">
													<fo:block color="#5F5F5F" text-align="start">
														<xsl:text>Invoice Number:</xsl:text>

													</fo:block>
												</fo:table-cell>
											</fo:table-row>
											<fo:table-row>
												<fo:table-cell background-repeat="repeat" font-size="8px" margin="2pt" padding-right="8px">
													<fo:block color="#5F5F5F" text-align="start">
														<xsl:text>Billing Date:</xsl:text>

														<xsl:text>&#xA0;</xsl:text>

														<xsl:text>&#xA0;</xsl:text>
													</fo:block>
													<xsl:call-template name="space" />
												</fo:table-cell>
											</fo:table-row>
											<fo:table-row>
												<fo:table-cell background-repeat="repeat" font-size="8px" margin="2pt" padding-top="4px" padding-right="1px">
													<fo:block color="#5F5F5F" text-align="start">
														<xsl:text>Current Charges:</xsl:text>
													</fo:block>
												</fo:table-cell>
											</fo:table-row>
											<fo:table-row>
												<fo:table-cell background-repeat="repeat" font-size="9px" margin="2pt" padding-right="5px" font-weight="bold">
													<fo:block color="#5F5F5F" text-align="start">
														<xsl:text>Total Due:</xsl:text>

														<xsl:text>&#xA0;</xsl:text>
														<xsl:text>&#xA0;</xsl:text>
													</fo:block>
												</fo:table-cell>
											</fo:table-row>
											<fo:table-row>
												<fo:table-cell background-repeat="repeat" font-size="8px" margin="2pt" padding-right="4px" font-weight="bold" padding-top="4px">
													<fo:block color="#5F5F5F" text-align="start">
														<xsl:call-template name="space" />
														<xsl:text>Amount Paid:</xsl:text>
														<xsl:text>&#xA0;</xsl:text>
														<xsl:call-template name="space" />
													</fo:block>
												</fo:table-cell>
											</fo:table-row>
										</fo:table-body>
									</fo:table>
								</fo:table-cell>
								<fo:table-cell>
									<fo:table>
										<fo:table-column column-width="50%" />
										<fo:table-body border="3px">
											<fo:table-row>
												<fo:table-cell background-repeat="repeat" font-size="8px" margin="2pt" padding-top="4px" padding-right="3px">
													<fo:block color="#5F5F5F" text-align="left">
														<xsl:value-of select="/invoice/accountNumber" />
													</fo:block>
												</fo:table-cell>
											</fo:table-row>
											<fo:table-row>
												<fo:table-cell background-repeat="repeat" font-size="8px" margin="2pt" padding-right="3px">
													<fo:block color="#5F5F5F" text-align="left">
														<xsl:value-of select="/invoice/invoiceNumber" />
													</fo:block>
												</fo:table-cell>
											</fo:table-row>
											<fo:table-row>
												<fo:table-cell background-repeat="repeat" font-size="8px" margin="2pt" padding-right="3px">
													<fo:block color="#5F5F5F" text-align="left">
														<xsl:value-of select="/invoice/currentDate" />
														<xsl:text>&#xA0;</xsl:text>
														<xsl:text>&#xA0;</xsl:text>
														<xsl:call-template name="space" />
													</fo:block>
												</fo:table-cell>
											</fo:table-row>
											<fo:table-row>
												<fo:table-cell background-repeat="repeat" font-size="8px" margin="2pt" padding-top="4px" padding-right="0px">
													<fo:block color="#5F5F5F" text-align="left">
														<xsl:value-of select="/invoice/currency" />
														<xsl:value-of select="/invoice/accountSummary/netAmount" />
													</fo:block>
												</fo:table-cell>
											</fo:table-row>
											<fo:table-row>
												<fo:table-cell background-repeat="repeat" font-size="8px" margin="2pt" padding-right="3px" font-weight="bold">
													<fo:block color="#5F5F5F" text-align="left">
														<xsl:value-of select="/invoice/currency" />
														<xsl:value-of select="/invoice/accountSummary/totalAmountDue" />
														<xsl:text>&#xA0;</xsl:text>
														<xsl:text>&#xA0;</xsl:text>
														<xsl:call-template name="space" />
													</fo:block>
												</fo:table-cell>
											</fo:table-row>
											<fo:table-row>
												<fo:table-cell background-repeat="repeat" font-size="8px" margin="2pt" padding-right="3px" font-weight="bold" padding-top="4px">
													<fo:block color="#5F5F5F" text-align="left">
														<xsl:value-of select="/invoice/currency" />
														<fo:inline>
															<xsl:text>________.__</xsl:text>
														</fo:inline>
														<xsl:text>&#xA0;</xsl:text>
														<xsl:text>&#xA0;</xsl:text>
														<xsl:call-template name="space" />
													</fo:block>
												</fo:table-cell>
											</fo:table-row>
										</fo:table-body>
									</fo:table>
								</fo:table-cell>

							</fo:table-row>
						</fo:table-body>
					</fo:table>
				</fo:block>
				<fo:block>
					<fo:table width="100%" background-repeat="repeat" border-width="0pt" padding="0pt">
						<fo:table-column column-width="100%" />
						<fo:table-body>
							<fo:table-row>
								<fo:table-cell padding="5">
									<fo:block>
										<xsl:text></xsl:text>

									</fo:block>

									<!-- <fo:block font-weight="bold" font-size="8px" color="#5F5F5F">
										<xsl:text>Mail Checkssss made payable to:</xsl:text>
									</fo:block>
									<fo:block color="{$heading_font}" font-size="8px" margin="0pt" padding-top="0px" text-align="left">
										<xsl:value-of select="/invoice/remitTo/sellerName" />
									</fo:block>
									<fo:block color="{$heading_font}" font-size="8px" margin="0pt" padding-top="0px" text-align="left">
										<xsl:value-of select="/invoice/remitTo/companyName" />
									</fo:block>
									<fo:block color="{$heading_font}" font-size="8px" margin="0pt" padding-top="0px" text-align="left">
										<xsl:value-of select="/invoice/remitTo/addressLine1" />
									</fo:block>
									<xsl:if test="/invoice/remitTo/addressLine2 !=''">
										<fo:block color="{$heading_font}" font-size="8px" margin="0pt" padding-top="0px" text-align="left">
											<xsl:value-of select="/invoice/remitTo/addressLine2" />
										</fo:block>
									</xsl:if>
									<xsl:if test="/invoice/remitTo/addressLine3 !=''">
										<fo:block color="{$heading_font}" font-size="8px" margin="0pt" padding-top="0px" text-align="left">
											<xsl:value-of select="/invoice/remitTo/addressLine3" />
										</fo:block>
									</xsl:if>
									<fo:block color="{$heading_font}" font-size="8px" margin="0pt" padding-top="0px" text-align="left">
										<xsl:if test="/invoice/remitTo/city !=''">
											<xsl:value-of select="/invoice/remitTo/city" />
										</xsl:if>

										<xsl:if test="/invoice/remitTo/state !=''"> <xsl:value-of select="concat(', ',/invoice/remitTo/state,' - ',/invoice/remitTo/postalCode)" />
										</xsl:if>
									</fo:block> -->
								</fo:table-cell>
							</fo:table-row>
						</fo:table-body>
					</fo:table>
				</fo:block>
			</fo:block>
		</fo:block>
	</xsl:template>
	<xsl:template name="logo">
		<fo:block>
			<xsl:choose>
				<xsl:when test="contains(/invoice/invoiceLogo,'/onebill')">
					<xsl:variable name="part1" select="substring-before(/invoice/invoiceLogo,'/onebill')" />
					<xsl:variable name="part2" select="substring-after(/invoice/invoiceLogo,'/onebill')" />
					<xsl:variable name="myURL" select="concat($part1,$part2)" />
					<fo:block margin-left="10pt">
						<fo:external-graphic background="transparent" width="90%" content-width="scale-to-fit" height="100%" content-height="scale-to-fit" src="url('{$myURL}')" />
					</fo:block>
				</xsl:when>
				<xsl:otherwise>
					<fo:block margin-left="10pt">
						<fo:external-graphic background="transparent" width="90%" content-width="scale-to-fit" height="100%" content-height="scale-to-fit" src="url('{/invoice/invoiceLogo}')" />
					</fo:block>
				</xsl:otherwise>
			</xsl:choose>
		</fo:block>
		<xsl:text></xsl:text>

	</xsl:template>
	<xsl:template name="remit_To">
		<fo:block color="{$heading_font}" font-weight="bold" font-size="8px" margin="0pt" padding-top="2px" text-align="end">
			<xsl:text>Remit To:</xsl:text>
		</fo:block>
		<fo:block color="{$heading_font}" font-size="8px" margin="0pt" padding-top="0px" text-align="end">
			<xsl:value-of select="/invoice/remitTo/sellerName" />
		</fo:block>
		<fo:block color="{$heading_font}" font-size="8px" margin="0pt" padding-top="0px" text-align="end">
			<xsl:value-of select="/invoice/remitTo/companyName" />
		</fo:block>
		<fo:block color="{$heading_font}" font-size="8px" margin="0pt" padding-top="0px" text-align="end">
			<xsl:value-of select="/invoice/remitTo/addressLine1" />
		</fo:block>
		<xsl:if test="/invoice/remitTo/addressLine2 !=''">
			<fo:block color="{$heading_font}" font-size="8px" margin="0pt" padding-top="0px" text-align="end">
				<xsl:value-of select="/invoice/remitTo/addressLine2" />
			</fo:block>
		</xsl:if>
		<xsl:if test="/invoice/remitTo/addressLine3 !=''">
			<fo:block color="{$heading_font}" font-size="8px" margin="0pt" padding-top="0px" text-align="end">
				<xsl:value-of select="/invoice/remitTo/addressLine3" />
			</fo:block>
		</xsl:if>
		<fo:block color="{$heading_font}" font-size="8px" margin="0pt" padding-top="0px" text-align="end">
			<xsl:if test="/invoice/remitTo/city !=''">
				<xsl:value-of select="/invoice/remitTo/city" />
			</xsl:if>

			<xsl:if test="/invoice/remitTo/state !=''">
				<xsl:value-of select="concat(', ',/invoice/remitTo/state,' - ',/invoice/remitTo/postalCode)" />
			</xsl:if>
		</fo:block>

	</xsl:template>
	<xsl:template name="total_Amount_Due">
		<fo:table width="100%" background-repeat="repeat">
			<fo:table-column column-width="20%" />
			<fo:table-column column-width="40%" />
			<fo:table-column column-width="40%" />
			<fo:table-body>
				<fo:table-row>
					<fo:table-cell>
						<fo:block></fo:block>
					</fo:table-cell>
					<fo:table-cell background-repeat="repeat" display-align="center" text-align="end" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px">
						<fo:block color="{$heading_font}" font-size="10px" font-weight="bold">
							<xsl:text>Total Amount Due</xsl:text>
						</fo:block>
					</fo:table-cell>
					<fo:table-cell border-style="none" font-family="{$font_family}" font-size="11px" display-align="center" text-align="end" padding-top="3px" padding-bottom="3px" background-color="{$color}" margin="1pt" color="white" padding-right="0px" padding-left="0px">
						<fo:block font-weight="bold" font-size="11px">
							<xsl:call-template name="format_Currency">
								<xsl:with-param name="value">
									<xsl:value-of select="/invoice/accountSummary/totalAmountDue" />
								</xsl:with-param>
							</xsl:call-template>
						</fo:block>
					</fo:table-cell>
				</fo:table-row>
				<fo:table-row>
					<fo:table-cell>
						<fo:block></fo:block>
					</fo:table-cell>
					<fo:table-cell background-repeat="repeat" text-align="end" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="0px">
						<fo:block color="{$heading_font}" font-size="8px"></fo:block>
					</fo:table-cell>
					<fo:table-cell border-style="none" padding-top="3px" padding-bottom="3px" font-family="Verdana, Arial, Helvetica, sans-serif" font-size="10px" margin="1pt" display-align="center" text-align="end" background-color="#f5f5f5">
						<fo:block color="#5F5F5F" font-weight="bold">
							<fo:inline color="{$color}">Due by</fo:inline>
							<xsl:value-of select="concat(' ',/invoice/invoiceDuedate)"/>
						</fo:block>
					</fo:table-cell>
				</fo:table-row>
			</fo:table-body>
		</fo:table>
	</xsl:template>
	<xsl:template name="billing_Summary">
		<fo:table>
			<fo:table-column column-width="50%" />
			<fo:table-column column-width="50%" />
			<fo:table-body>
				<fo:table-row>
					<fo:table-cell border-style="none" background-repeat="repeat" font-family="{$font_family}" font-size="8px">
						<fo:block margin="0pt" background-color="{$color}" font-weight="bold" font-size="10px" padding-bottom="4px" padding-left="3px" padding-right="3px" padding-top="5px" color="white" border-bottom="#FFFFFF 1.0px solid">
							<xsl:text>Billing Summary</xsl:text>
						</fo:block>
						<fo:block font-size="8px" background-color="{$bkgrnd_clr}" color="{$color}" margin="0pt" padding-bottom="4px" padding-left="3px" padding-right="3px" padding-top="4px" border-bottom="#FFFFFF 1.0px solid">
							<xsl:text>Previous Balance</xsl:text>
						</fo:block>
						<fo:block color="{$heading_font}" font-size="8px" background-color="{$bkgrnd_clr}" margin="0pt" padding-bottom="4px" padding-left="3px" padding-right="3px" padding-top="4px" border-bottom="#FFFFFF 1.0px solid">
							<xsl:text>Payment / Adjustment Applied</xsl:text>
						</fo:block>
						<fo:block color="{$heading_font}" font-size="8px" background-color="{$bkgrnd_clr}" margin="0pt" padding-bottom="4px" padding-left="3px" padding-right="3px" padding-top="4px" border-bottom="#FFFFFF 1.0px solid">
							<xsl:text>Balance Forward  </xsl:text>
							<fo:inline font-size="8px" color="{$color}"></fo:inline>
						</fo:block>
						<fo:block color="{$heading_font}" font-weight="bold" font-size="8px" margin="0pt" padding-bottom="4px" padding-left="3px" padding-right="3px" padding-top="4px" border-bottom="#FFFFFF 1.0px solid">
							<xsl:text>Account Charges &amp; Credits</xsl:text>
						</fo:block>
						<fo:block color="{$heading_font}" font-size="8px" background-color="{$bkgrnd_clr}" margin="0pt" padding-bottom="4px" padding-left="3px" padding-right="3px" padding-top="4px" border-bottom="#FFFFFF 1.0px solid">
							<xsl:text>Current Charges   </xsl:text>
						</fo:block>
						<fo:block color="{$heading_font}" font-size="8px" background-color="{$bkgrnd_clr}" margin="0pt" padding-bottom="4px" padding-left="3px" padding-right="3px" padding-top="4px" border-bottom="#FFFFFF 1.0px solid">
							<xsl:text>Taxes and Fees</xsl:text>
						</fo:block>
						<fo:block color="{$heading_font}" font-size="8px" background-color="{$bkgrnd_clr}" margin="0pt" padding-bottom="4px" padding-left="3px" padding-right="3px" padding-top="4px" border-bottom="#FFFFFF 1.0px solid">
							<xsl:text>Late fee </xsl:text>
						</fo:block>
						<fo:block color="{$heading_font}" font-size="8px" background-color="{$bkgrnd_clr}" margin="0pt" padding-bottom="4px" padding-left="3px" padding-right="3px" padding-top="4px" border-bottom="#FFFFFF 1.0px solid">
							<xsl:text>Payment / Credits / Transfers </xsl:text>
						</fo:block>
						<fo:block margin="0pt" background-color="{$color}" font-weight="bold" font-size="10px" padding-bottom="4px" padding-left="3px" padding-right="3px" padding-top="5px" color="white" border-bottom="#FFFFFF 1.0px solid">
							<xsl:text>Current Amount Due</xsl:text>
						</fo:block>
					</fo:table-cell>
					<fo:table-cell border-style="none" background-repeat="repeat" font-family="{$font_family}" font-size="8px">
						<fo:block margin="0pt" background-color="{$color}" font-size="10px" padding-bottom="4px" padding-left="0px" padding-right="3px" padding-top="5px" color="white" text-align="end" border-bottom="#FFFFFF 1.0px solid">
							<xsl:call-template name="billing_Summary_Cycle" />
						</fo:block>
						<fo:block color="{$heading_font}" font-size="8px" background-color="{$bkgrnd_clr}" margin="0pt" padding-bottom="4px" padding-left="0px" padding-right="3px" padding-top="4px" text-align="end" border-bottom="#FFFFFF 1.0px solid">
							<xsl:call-template name="format_Currency">
								<xsl:with-param name="value">
									<xsl:value-of select="/invoice/accountSummary/previousBalance" />
								</xsl:with-param>
							</xsl:call-template>
						</fo:block>
						<fo:block color="{$heading_font}" font-size="8px" background-color="{$bkgrnd_clr}" margin="0pt" padding-bottom="4px" padding-left="0px" padding-right="3px" padding-top="4px" text-align="end" border-bottom="#FFFFFF 1.0px solid">
							<xsl:call-template name="format_Currency">
								<xsl:with-param name="value">
									<xsl:value-of select="/invoice/accountSummary/amountRecieved" />
								</xsl:with-param>
							</xsl:call-template>
						</fo:block>
						<fo:block color="{$heading_font}" font-size="8px" background-color="{$bkgrnd_clr}" margin="0pt" padding-bottom="4px" padding-left="0px" padding-right="3px" padding-top="4px" text-align="end" font-weight="bold" border-bottom="#FFFFFF 1.0px solid">
							<xsl:call-template name="format_Currency">
								<xsl:with-param name="value">
									<xsl:value-of select="/invoice/accountSummary/balanceForward" />
								</xsl:with-param>
							</xsl:call-template>
						</fo:block>
						<fo:block color="{$heading_font}" font-weight="bold" font-size="8px" margin="0pt" padding-bottom="4px" padding-left="3px" padding-right="3px" padding-top="4px" border-bottom="#FFFFFF 1.0px solid">
							<xsl:text></xsl:text>
							<xsl:text>&#xA0;</xsl:text>
						</fo:block>
						<fo:block color="{$heading_font}" font-size="8px" background-color="{$bkgrnd_clr}" margin="0pt" padding-bottom="4px" padding-left="3px" padding-right="3px" padding-top="4px" text-align="end" border-bottom="#FFFFFF 1.0px solid">
							<xsl:call-template name="format_Currency">
								<xsl:with-param name="value">
									<xsl:value-of select="(/invoice/totalCurrentCharge - sum(//billTimeLineItems/chargeLineItem/amount))" />
								</xsl:with-param>
							</xsl:call-template>
						</fo:block>
						<fo:block color="{$heading_font}" font-size="8px" background-color="{$bkgrnd_clr}" margin="0pt" padding-bottom="4px" padding-left="3px" padding-right="3px" padding-top="4px" text-align="end" border-bottom="#FFFFFF 1.0px solid">
							<xsl:call-template name="format_Currency">
								<xsl:with-param name="value">
									<xsl:value-of select="(/invoice/accountSummary/taxAmount + sum(//billTimeLineItems/chargeLineItem/amount))" />
								</xsl:with-param>
							</xsl:call-template>
						</fo:block>
						<fo:block color="{$heading_font}" font-size="8px" background-color="{$bkgrnd_clr}" margin="0pt" padding-bottom="4px" padding-left="3px" padding-right="3px" padding-top="4px" text-align="end" border-bottom="#FFFFFF 1.0px solid">
							<xsl:value-of select="concat(' ',/invoice/currency,format-number(/invoice/accountSummary/lateFee,$decimal_value,'dollar'))" />
						</fo:block>
						<fo:block color="{$heading_font}" font-size="8px" background-color="{$bkgrnd_clr}" margin="0pt" padding-bottom="4px" padding-left="3px" padding-right="3px" padding-top="4px" text-align="end" border-bottom="#FFFFFF 1.0px solid">
							<xsl:call-template name="format_Currency">
								<xsl:with-param name="value">
									<xsl:value-of select="/invoice/accountSummary/creditAmount" />
								</xsl:with-param>
							</xsl:call-template>
						</fo:block>
						<fo:block margin="0pt" background-color="{$color}" font-weight="bold" font-size="10px" padding-bottom="4px" padding-left="3px" padding-right="3px" padding-top="5px" color="white" border-bottom="#FFFFFF 1.0px solid" text-align="end">
							<xsl:call-template name="format_Currency">
								<xsl:with-param name="value">
									<xsl:value-of select="/invoice/accountSummary/netAmount" />
								</xsl:with-param>
							</xsl:call-template>
						</fo:block>
					</fo:table-cell>
				</fo:table-row>
			</fo:table-body>
		</fo:table>


	</xsl:template>
	<xsl:template name="accountNo_InvoiceNo">
		<fo:table>
			<fo:table-column column-width="100%" />
			<fo:table-body>
				<fo:table-row>
					<fo:table-cell background-repeat="repeat" font-size="10px" margin="2pt" padding-top="4px" padding-bottom="2px">
						<fo:block color="{$heading_font}">
							<xsl:text>Account Number:
							</xsl:text>
							<xsl:text>
							</xsl:text>
							<xsl:value-of select="/invoice/accountNumber" />
						</fo:block>
					</fo:table-cell>
				</fo:table-row>
				<fo:table-row>
					<fo:table-cell background-repeat="repeat" font-size="10px" margin="2pt" padding-top="4px" padding-bottom="2px">
						<fo:block color="{$heading_font}">
							<xsl:text>Invoice Number:
							</xsl:text>
							<xsl:text>
							</xsl:text>
							<xsl:value-of select="/invoice/invoiceNumber" />
						</fo:block>
					</fo:table-cell>
				</fo:table-row>
				<fo:table-row>
					<fo:table-cell background-repeat="repeat" font-size="10px" margin="2pt" padding-top="4px" padding-bottom="2px">summary
						<fo:block color="{$heading_font}">
							<xsl:if test="/invoice/customerDetails/attributes/attribute/PIN">
								<xsl:text>PIN:
								</xsl:text>
								<xsl:text>
								</xsl:text>
								<xsl:value-of select="/invoice/customerDetails/attributes/attribute/PIN" />
							</xsl:if>
						</fo:block>
					</fo:table-cell>
				</fo:table-row>

			</fo:table-body>
		</fo:table>
	</xsl:template>
	<xsl:template name="bill_To_Details">
		<fo:table width="100%" background-repeat="repeat">
			<fo:table-column column-width="100%" />
			<fo:table-body>
				<fo:table-row>
					<fo:table-cell color="{$heading_font}">
						<fo:block font-weight="bold" font-size="8px" padding-top="4px">
							<xsl:text>Bill To:
							</xsl:text>
						</fo:block>
						<fo:block color="{$heading_font}">
							<xsl:value-of select="/invoice/billTo/companyName" />
						</fo:block>
						<fo:block color="{$heading_font}">

							<xsl:value-of select="/invoice/billTo/addressLine1" />


							<xsl:if test="/invoice/billTo/addressLine2 !=''">
								<xsl:value-of select="concat(', ',/invoice/billTo/addressLine2)" />
							</xsl:if>
						</fo:block>
						<fo:block color="{$heading_font}">


							<xsl:if test="/invoice/billTo/city !=''">
								<xsl:value-of select="/invoice/billTo/city" />
							</xsl:if>

							<xsl:if test="/invoice/billTo/state !=''">
								<xsl:value-of select="concat(', ',/invoice/billTo/state,'-',/invoice/billTo/postalCode)" />
							</xsl:if>

						</fo:block>
					</fo:table-cell>
				</fo:table-row>
				<fo:table-row>
					<fo:table-cell>
						<fo:block>
							<xsl:text>
							</xsl:text>
						</fo:block>
					</fo:table-cell>
				</fo:table-row>
				<fo:table-row>
					<fo:table-cell>
						<fo:block>
							<fo:external-graphic background="transparent" width="90%" content-width="scale-to-fit" height="100%" content-height="scale-to-fit" src="url('{/invoice/marketingImage}')" />
						</fo:block>
					</fo:table-cell>
				</fo:table-row>
			</fo:table-body>
		</fo:table>


	</xsl:template>
	<xsl:template name="table_Header_With_Tax">
		<fo:table-header font-weight="bold">
			<fo:table-row>
				<fo:table-cell background-repeat="repeat" background-color="{$bkgrnd_clr}" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px">
					<fo:block font-weight="bold" font-size="8px" color="{$heading_font}">
						<xsl:text>CHARGE DATE
						</xsl:text>
					</fo:block>
				</fo:table-cell>
				<fo:table-cell background-color="{$bkgrnd_clr}" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px">
					<fo:block font-weight="bold" font-size="8px" color="{$heading_font}">
						<xsl:text>SUBSCRIPTION PLAN
						</xsl:text>
					</fo:block>
				</fo:table-cell>
				<fo:table-cell background-color="{$bkgrnd_clr}" display-align="center" text-align="center" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px">
					<fo:block font-weight="bold" font-size="8px" color="{$heading_font}">
						<xsl:text>CHARGE DESCRIPTION
						</xsl:text>
					</fo:block>
				</fo:table-cell>
				<fo:table-cell background-color="{$bkgrnd_clr}" display-align="center" text-align="center" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px">
					<fo:block font-weight="bold" font-size="8px" color="{$heading_font}">
						<xsl:text>TAXES</xsl:text>
					</fo:block>
				</fo:table-cell>
				<fo:table-cell background-color="{$bkgrnd_clr}" display-align="after" text-align="end" padding-bottom="3px" padding-left="3px" padding-right="5px" padding-top="3px">
					<fo:block font-weight="bold" font-size="8px" color="{$heading_font}">
						<xsl:text>AMOUNT
						</xsl:text>
					</fo:block>
				</fo:table-cell>
			</fo:table-row>
		</fo:table-header>
	</xsl:template>
	<xsl:template name="table_Header_Notax">
		<fo:table-header font-weight="bold">
			<fo:table-row>
				<fo:table-cell background-repeat="repeat" background-color="{$bkgrnd_clr}" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px">
					<fo:block font-weight="bold" font-size="8px" color="{$heading_font}">
						<xsl:text>CHARGE DATE
						</xsl:text>
					</fo:block>
				</fo:table-cell>
				<fo:table-cell background-color="{$bkgrnd_clr}" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px">
					<fo:block font-weight="bold" font-size="8px" color="{$heading_font}">
						<xsl:text>SUBSCRIPTION PLAN
						</xsl:text>
					</fo:block>
				</fo:table-cell>
				<fo:table-cell background-color="{$bkgrnd_clr}" display-align="center" text-align="center" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px">
					<fo:block font-weight="bold" font-size="8px" color="{$heading_font}">
						<xsl:text>CHARGE DESCRIPTION
						</xsl:text>
					</fo:block>
				</fo:table-cell>
				<fo:table-cell background-color="{$bkgrnd_clr}" display-align="after" text-align="end" padding-bottom="3px" padding-left="3px" padding-right="5px" padding-top="3px">
					<fo:block font-weight="bold" font-size="8px" color="{$heading_font}">
						<xsl:text>AMOUNT
						</xsl:text>
					</fo:block>
				</fo:table-cell>
			</fo:table-row>
		</fo:table-header>
	</xsl:template>
	<xsl:template name="format_Currency">
		<xsl:param name="value" />
		<xsl:choose>
			<xsl:when test="$value &gt;= 0">
				<xsl:value-of select="concat(' ',/invoice/currency,format-number($value,$decimal_value,'dollar'))" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat(' ',/invoice/currency,format-number($value*-1,$decimal_value,'dollar'),' ',$credit)" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="billing_Summary_Cycle">
		<xsl:value-of select="/invoice/cycleEnd" />
	</xsl:template>
	<xsl:template name="usage_Summary_Template">
		<xsl:for-each select="usageLineItem">
			<fo:block font-size="8px" text-align="start">
				<fo:table width="100%" border-style="none" font-size="10px">
					<fo:table-column column-width="100%" />
					<fo:table-body>
						<fo:table-row>
							<xsl:variable name="accUsageLineItem" select="." />
							<fo:table-cell background-repeat="repeat" display-align="before" padding-bottom="3px" padding-right="3px" padding-top="0px">
								<fo:block color="{$heading_font}" font-size="8px">
									<xsl:if test="ruleBased = 1">
										<fo:inline color="{$heading_font}">
											<xsl:value-of select="concat(' ',format-number(unRoundedQuantity,'###0.0000'),'  ',uomName,'s',' ','  -  ',/invoice/currency,format-number(amount,'#,##0.00','dollar'))" />
										</fo:inline>
									</xsl:if>
									<xsl:if test="(ruleBased = 2)">
										<fo:inline color="{$heading_font}">
											<xsl:value-of select="concat(' ',format-number(unRoundedQuantity,'###0.0000'),'  ',uomName)" />
										</fo:inline>
										<fo:inline color="{$color}"> @
										</fo:inline>
										<fo:inline color="#000000">

											<xsl:call-template name="format_Currency">
												<xsl:with-param name="value">
													<xsl:value-of select="amount" />
												</xsl:with-param>
											</xsl:call-template>
										</fo:inline>
									</xsl:if>
									<xsl:for-each select="discountLineItem">
										<xsl:variable name="accDiscountLineItem" select="." />
										<xsl:if test="discountValue !=''">
											<fo:inline font-size="8px" color="{$color}"> [
											</fo:inline>
											<fo:inline color="{$heading_font}">
												<xsl:value-of select="concat(discountValue,'%','  ',description)" />
											</fo:inline>
											<fo:inline font-size="8px" color="{$color}"> ]
											</fo:inline>
										</xsl:if>
									</xsl:for-each>
								</fo:block>
							</fo:table-cell>
						</fo:table-row>
					</fo:table-body>
				</fo:table>
			</fo:block>
		</xsl:for-each>
	</xsl:template>
	<xsl:template name="discount_Template">
		<xsl:for-each select="discountLineItem">
			<fo:block font-size="8px" text-align="start">
				<fo:table width="100%" border-style="none" font-size="10px">
					<fo:table-column column-width="100%" />
					<fo:table-body>
						<fo:table-row>
							<xsl:variable name="accDiscountLineItem" select="." />
							<fo:table-cell background-repeat="repeat" display-align="before" padding-bottom="3px" padding-right="3px" padding-top="0px">
								<fo:block color="{$heading_font}" font-size="8px">
									<xsl:choose>
										<xsl:when test="trialDescription!=''">
											<fo:table width="100%" border-style="none" font-size="8px" border-bottom="1px dashed #9C9C9C" border-left="1px dashed #9C9C9C" border-right="1px dashed #9C9C9C" border-top="1px dashed #9C9C9C">
												<fo:table-column column-width="70" />
												<fo:table-body>
													<fo:table-row>
														<fo:table-cell background-repeat="repeat" display-align="before" text-align="center" padding-bottom="1px" padding-left="1px" padding-right="1px" padding-top="1px">
															<fo:block padding-bottom="0.2px" padding-left="1px" padding-right="1px" padding-top="0.2px" background-color="#FFE">
																<fo:inline font-size="6px" color="{$color}">
																	<xsl:value-of select="trialDescription" />
																</fo:inline>
															</fo:block>
														</fo:table-cell>
													</fo:table-row>
												</fo:table-body>
											</fo:table>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="concat('Discount',' : ','$',substring-after(amount,'-'))" />
											<xsl:if test="code!=''">
												<fo:inline font-size="8px" color="#999999">
													[Code :
													<xsl:value-of select="code" />
													]
												</fo:inline>
											</xsl:if>
										</xsl:otherwise>
									</xsl:choose>
								</fo:block>
							</fo:table-cell>
						</fo:table-row>
					</fo:table-body>
				</fo:table>
			</fo:block>
		</xsl:for-each>
	</xsl:template>
	<xsl:template name="ChargeSummary_Detailed_Template">
		<fo:block>
			<fo:table width="100%" border-style="none" font-family="{$font_family}" font-size="10px">
				<fo:table-column column-width="12%" />
				<fo:table-column column-width="32%" />
				<fo:table-column column-width="22%" />
				<fo:table-column column-width="24%" />
				<fo:table-column column-width="10%" />
				<xsl:call-template name="table_Header_With_Tax" />
				<fo:table-body>
					<xsl:for-each select="/invoice/invoiceElements/lineItems[generate-id(.)=generate-id(key('lineItems-by-subscriptionIdentifier', subscriptionIdentifier)[1])]">
						<!-- <xsl:for-each select="invoiceElements/lineItems"> -->
						<fo:table-row>
							<fo:table-cell number-columns-spanned="4">
								<fo:block>
									<xsl:if test="subscriptionIdentifier">
										<fo:block>
											<fo:inline font-weight="bold" font-size="8px">
												<xsl:value-of select="subscriptionIdentifier" />
											</fo:inline>
										</fo:block>
									</xsl:if>
								</fo:block>
							</fo:table-cell>
						</fo:table-row>
						<xsl:for-each select="key('lineItems-by-subscriptionIdentifier', subscriptionIdentifier)">
							<fo:table-row>

								<fo:table-cell background-color="{$table_bkgrnd_clr}" background-repeat="repeat" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px">
									<fo:block color="{$heading_font}" font-size="8px">
										<xsl:value-of select="eventDate" />
									</fo:block>
								</fo:table-cell>
								<fo:table-cell background-color="{$table_bkgrnd_clr}" background-repeat="repeat" display-align="center" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px">
									<fo:block>
										<fo:block>
											<fo:inline font-weight="bold" font-size="8px">
												<xsl:value-of select="chargeType" />
											</fo:inline>
											<xsl:text disable-output-escaping="yes">
											</xsl:text>
										</fo:block>
										<fo:block font-size="8px">
											<xsl:if test="(chargeType != 'Metered Charge') and (ruleBased = 1)">
												<fo:inline color="{$color}"> x
												</fo:inline>
												<fo:inline color="{$heading_font}">
													<xsl:value-of select="concat(' ',format-number(unRoundedQuantity,'###0.0000'),'  ',uomName)" />
												</fo:inline>
												<fo:inline color="{$color}"> at
												</fo:inline>
												<fo:inline color="{$heading_font}">
													<xsl:call-template name="format_Currency">
														<xsl:with-param name="value">
															<xsl:value-of select="unitPrice" />
														</xsl:with-param>
													</xsl:call-template>
												</fo:inline>
											</xsl:if>
											<xsl:if test="(chargeType != 'Metered Charge') and (ruleBased = 2)">
												<fo:inline color="{$heading_font}">
													<xsl:value-of select="concat(' ',format-number(unRoundedQuantity,'###0.0000'),'  ',uomName)" />
												</fo:inline>
												<fo:inline color="{$color}"> @
												</fo:inline>
												<fo:inline color="{$heading_font}">
													<xsl:call-template name="format_Currency">
														<xsl:with-param name="value">
															<xsl:value-of select="totalAmount" />
														</xsl:with-param>
													</xsl:call-template>
												</fo:inline>
											</xsl:if>
										</fo:block>

										<xsl:call-template name="usage_Summary_Template" />

										<xsl:call-template name="discount_Template" />

									</fo:block>
								</fo:table-cell>
								<fo:table-cell background-color="{$table_bkgrnd_clr}" background-repeat="repeat" display-align="center" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px">
									<fo:block color="{$heading_font}" font-size="8px" text-align="center">
										<xsl:value-of select="chargeDescription" />
									</fo:block>
									<fo:block font-size="8px" text-align="center" color="{$color}">
										<xsl:if test="not(bundleId)">
											<xsl:choose>
												<xsl:when test="(endDate !='-') and (endDate !='')">
													<xsl:value-of select="concat(startDate,'-',endDate)" />
												</xsl:when>
												<xsl:otherwise>
													<xsl:value-of select="startDate" />
												</xsl:otherwise>
											</xsl:choose>
										</xsl:if>
									</fo:block>
								</fo:table-cell>
								<fo:table-cell background-color="{$table_bkgrnd_clr}" background-repeat="repeat" padding-bottom="3px" padding-left="3px" padding-right="5px" padding-top="3px" display-align="center" text-align="center">
									<fo:block color="{$heading_font}" font-size="8px">
										<xsl:call-template name="format_Currency">
											<xsl:with-param name="value">
												<xsl:value-of select="taxAmount" />
											</xsl:with-param>
										</xsl:call-template>
									</fo:block>
								</fo:table-cell>
								<fo:table-cell background-repeat="repeat" display-align="center" text-align="right" padding-bottom="3px" padding-left="3px" padding-right="5px" padding-top="3px" background-color="{$bkgrnd_clr}">
									<fo:block color="{$heading_font}" font-size="8px" text-align="end">
										<xsl:call-template name="format_Currency">
											<xsl:with-param name="value">
												<xsl:value-of select="totalCharge" />
											</xsl:with-param>
										</xsl:call-template>
									</fo:block>
								</fo:table-cell>
							</fo:table-row>
						</xsl:for-each>
					</xsl:for-each>
					<fo:table-row>
						<fo:table-cell number-columns-spanned="4" background-repeat="repeat" display-align="center" text-align="end" padding-bottom="5px" padding-right="3px" padding-left="3px" padding-top="5px" background-color="{$lightcolor}">
							<fo:block color="{$heading_font}" font-size="8px" text-align="end">
								<xsl:text>Total Charges
								</xsl:text>
							</fo:block>
						</fo:table-cell>
						<fo:table-cell background-repeat="repeat" display-align="center" text-align="right" padding-bottom="3px" padding-left="3px" padding-right="5px" padding-top="3px" background-color="{$lightcolor}">
							<fo:block color="{$heading_font}" font-size="8px">
								<xsl:choose>
									<xsl:when test="/invoice/accountInvoiceElements">
										<!--xsl:value-of select="/invoice/parentTotalAmount" / -->
										<xsl:call-template name="format_Currency">
											<xsl:with-param name="value">
												<xsl:value-of select="parentTotalAmount" />
											</xsl:with-param>
										</xsl:call-template>
									</xsl:when>
									<xsl:otherwise>
										<!--xsl:value-of select="/invoice/totalCurrentCharge" / -->
										<xsl:call-template name="format_Currency">
											<xsl:with-param name="value">
												<xsl:value-of select="totalCurrentCharge" />
											</xsl:with-param>
										</xsl:call-template>
									</xsl:otherwise>
								</xsl:choose>
							</fo:block>
						</fo:table-cell>
					</fo:table-row>
				</fo:table-body>
			</fo:table>
		</fo:block>
	</xsl:template>

	<!-- ChargeSummary_Group by tax -->
	<xsl:template name="chargeSummary_GrpByAddress_WithTax">
		<fo:block>
			<fo:table width="100%" border-style="none" font-family="{$font_family}" font-size="10px">
				<fo:table-column column-width="12%" />
				<fo:table-column column-width="32%" />
				<fo:table-column column-width="22%" />
				<fo:table-column column-width="24%" />
				<fo:table-column column-width="10%" />
				<xsl:call-template name="table_Header_With_Tax" />
				<fo:table-body>
					<xsl:for-each select="invoiceElements/lineItems[generate-id(.)=generate-id(key('addressLineItems-by-subscriptionIdentifier-NoUsage', subscriptionIdentifier)[1])]">
						<fo:table-row>
							<fo:table-cell number-columns-spanned="5">
								<fo:block>
									<xsl:if test="subscriptionIdentifier">
										<fo:block>
											<fo:inline font-weight="bold" font-size="8px">
												<xsl:value-of select="subscriptionIdentifier" />
											</fo:inline>
										</fo:block>
									</xsl:if>
								</fo:block>
							</fo:table-cell>
						</fo:table-row>
						<xsl:for-each select="key('addressLineItems-by-subscriptionIdentifier-NoUsage', subscriptionIdentifier)">
							<fo:table-row>
								<fo:table-cell background-color="{$table_bkgrnd_clr}" background-repeat="repeat" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px" display-align="center">
									<fo:block color="{$heading_font}" font-size="8px">
										<xsl:value-of select="startDate" />
									</fo:block>
								</fo:table-cell>
								<fo:table-cell background-color="{$table_bkgrnd_clr}" background-repeat="repeat" display-align="center" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px">
									<fo:block>
										<fo:inline font-weight="bold" font-size="8px">
											<xsl:value-of select="chargeType" />
										</fo:inline>
										<xsl:text disable-output-escaping="yes">
										</xsl:text>
										<fo:block font-size="8px">
											<xsl:if test="(chargeType != 'Metered Charge') and (ruleBased = 1)">
												<fo:inline color="{$color}"> x
												</fo:inline>
												<fo:inline color="{$heading_font}">
													<xsl:value-of select="concat(' ',format-number(unRoundedQuantity,'###0.0000'),'  ',uomName)" />
												</fo:inline>
												<fo:inline color="{$color}"> at
												</fo:inline>
												<fo:inline color="{$heading_font}">
													<xsl:call-template name="format_Currency">
														<xsl:with-param name="value">
															<xsl:value-of select="unitPrice" />
														</xsl:with-param>
													</xsl:call-template>
													<!-- <xsl:value-of select="format-number(/invoice/totalCurrentCharge,$decimal_value,'dollar')" /> -->
												</fo:inline>
											</xsl:if>
											<xsl:if test="(chargeType != 'Metered Charge') and (ruleBased = 2)">
												<fo:inline color="{$heading_font}">
													<xsl:value-of select="concat(' ',format-number(unRoundedQuantity,'###0.0000'),'  ',uomName)" />
												</fo:inline>
												<fo:inline color="{$color}"> @
												</fo:inline>
												<fo:inline color="{$heading_font}">
													<!--xsl:value-of select="format-number(/invoice/totalCurrentCharge,$decimal_value,'dollar')"
														/ -->
													<xsl:call-template name="format_Currency">
														<xsl:with-param name="value">
															<xsl:value-of select="totalAmount" />
														</xsl:with-param>
													</xsl:call-template>
												</fo:inline>
											</xsl:if>
										</fo:block>
										<xsl:call-template name="discount_Template" />
									</fo:block>
								</fo:table-cell>
								<fo:table-cell background-color="{$table_bkgrnd_clr}" background-repeat="repeat" display-align="center" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px">
									<fo:block color="{$heading_font}" font-size="8px" text-align="center">
										<xsl:value-of select="chargeDescription" />
									</fo:block>
									<fo:block font-size="8px" text-align="center" color="{$color}">
										<xsl:if test="not(bundleId)">
											<xsl:choose>
												<xsl:when test="(endDate !='-') and (endDate !='')">
													<xsl:value-of select="concat(startDate,'-',endDate)" />
												</xsl:when>
												<xsl:otherwise>
													<xsl:value-of select="startDate" />
												</xsl:otherwise>
											</xsl:choose>
										</xsl:if>
									</fo:block>
								</fo:table-cell>
								<fo:table-cell background-color="{$table_bkgrnd_clr}" background-repeat="repeat" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px" text-align="center" display-align="after">
									<fo:block color="{$heading_font}" font-size="6px">
										<xsl:call-template name="taxTable_Template" />
									</fo:block>
								</fo:table-cell>
								<fo:table-cell background-repeat="repeat" display-align="after" text-align="right" padding-bottom="3px" padding-left="3px" padding-right="5px" padding-top="3px" background-color="{$bkgrnd_clr}">
									<xsl:choose>
										<xsl:when test="totalCharge">
											<fo:block color="{$heading_font}" font-size="8px" text-align="end">
												<!--xsl:value-of select="totalCharge" / -->
												<xsl:call-template name="format_Currency">
													<xsl:with-param name="value">
														<xsl:value-of select="totalCharge" />
													</xsl:with-param>
												</xsl:call-template>
											</fo:block>
										</xsl:when>
										<xsl:otherwise>
											<fo:block color="{$heading_font}" font-size="8px" text-align="end">
												<!--xsl:value-of select="totalAmount" / -->
												<xsl:call-template name="format_Currency">
													<xsl:with-param name="value">
														<xsl:value-of select="totalAmount" />
													</xsl:with-param>
												</xsl:call-template>
											</fo:block>
										</xsl:otherwise>
									</xsl:choose>
								</fo:table-cell>
							</fo:table-row>
						</xsl:for-each>
					</xsl:for-each>
					<fo:table-row>
						<fo:table-cell number-columns-spanned="3" background-repeat="repeat" display-align="center" text-align="end" padding-bottom="5px" padding-right="3px" padding-left="3px" padding-top="5px" background-color="{$lightcolor}">
							<fo:block color="{$heading_font}" font-size="8px" text-align='end'>
								<xsl:text>Total Charges
								</xsl:text>
							</fo:block>
						</fo:table-cell>
						<fo:table-cell number-columns-spanned="2" background-repeat="repeat" display-align="center" text-align="right" padding-bottom="3px" padding-left="3px" padding-right="5px" padding-top="3px" background-color="{$lightcolor}">
							<fo:block color="{$heading_font}" font-size="8px">
								<!--xsl:value-of select="totalAmount" / -->
								<xsl:call-template name="format_Currency">
									<xsl:with-param name="value">
										<xsl:value-of select="sum(invoiceElements/lineItems/totalCharge) - sum(invoiceElements/lineItems[usageLineItem]/totalCharge)" />
									</xsl:with-param>
								</xsl:call-template>
							</fo:block>
						</fo:table-cell>
					</fo:table-row>
				</fo:table-body>
			</fo:table>
		</fo:block>
	</xsl:template>
	<xsl:template name="accountNumber_Template">
		<fo:block>
			<xsl:if test="accountNumber != ''">

				<fo:table width="100%" background-repeat="repeat" color="{$heading_font}">
					<fo:table-column column-width="11%" />
					<fo:table-column column-width="89%" />
					<fo:table-body>
						<fo:table-row>
							<fo:table-cell border-style="none" margin="2pt" font-family="{$font_family}" font-size="10px" font-weight="bold">
								<fo:block padding-top="2px" padding-bottom="2px" text-align="start" color="{$heading_font}">
									<xsl:text>Account:
									</xsl:text>
								</fo:block>
							</fo:table-cell>
							<fo:table-cell border-style="none" font-family="{$font_family}" font-size="10px" font-weight="bold">
								<fo:block text-align="start" padding-top="2px" padding-bottom="2px">
									<fo:inline color="{$heading_font}">
										<xsl:value-of select="accountName" />
									</fo:inline>
									<fo:inline color="{$heading_font}">
										<xsl:value-of select="concat(' ','[',accountNumber, ']')" />
									</fo:inline>
								</fo:block>
							</fo:table-cell>
						</fo:table-row>
					</fo:table-body>
				</fo:table>
			</xsl:if>
		</fo:block>
	</xsl:template>
	<xsl:template name="shippingAddId_Template">
		<xsl:call-template name="space"/>
		<xsl:if test="shippingAddId != ''">
			<fo:table width="100%" background-repeat="repeat" color="{$heading_font}">
				<fo:table-column column-width="100%" />
				<fo:table-body>
					<xsl:if test="shipTo/addressLine3 !=''">
						<fo:table-row>
							<fo:table-cell border-style="none" font-family="{$font_family}" font-size="9px" font-weight="bold">
								<fo:block padding-top="2px" padding-bottom="2px" text-align="start" color="{$color}">
									<xsl:text>Sub-Account#: </xsl:text>
									<xsl:value-of select="shipTo/addressLine3" />
								</fo:block>
							</fo:table-cell>
						</fo:table-row>
					</xsl:if>
					<fo:table-row>
						<fo:table-cell border-style="none" font-weight="bold" text-decoration="underline" font-family="{$font_family}" font-size="9px">
							<fo:block padding-top="2px" padding-bottom="2px" text-align="start" color="{$heading_font}" font-weight="bold">
								<xsl:text>Customer Location:</xsl:text>
							</fo:block>
						</fo:table-cell>
					</fo:table-row>
					<fo:table-row>
						<fo:table-cell border-style="none" font-family="{$font_family}" font-size="9px" font-weight="bold">
							<fo:block color="{$heading_font}">
								<xsl:value-of select="shipTo/addressLine1" />
								<xsl:if test="shipTo/addressLine2 !=''">
									<xsl:value-of select="concat(', ',shipTo/addressLine2)" />
								</xsl:if>
								<xsl:if test="shipTo/city !=''">
									<xsl:value-of select="concat(', ',shipTo/city)" />
								</xsl:if>

								<xsl:if test="shipTo/state !=''">
									<xsl:value-of select="concat(', ',shipTo/state)" />
								</xsl:if>
								<xsl:if test="shipTo/postalCode !=''">
									<xsl:text>
									</xsl:text>
									<xsl:value-of select="concat(' ',shipTo/postalCode)" />
								</xsl:if>
							</fo:block>
						</fo:table-cell>
					</fo:table-row>
				</fo:table-body>
			</fo:table>
		</xsl:if>
	</xsl:template>
	<xsl:template name="usageTransactionDetails_Template">
		<fo:block>
			<xsl:for-each select="usageLineItem[generate-id(.)=generate-id(key('usage_by_UOM', concat(uomName,../../subscriptionIdentifier))[1])]">

				<fo:table width="100%" border-style="none" font-family="{$font_family}" font-size="10px">
					<fo:table-column column-width="12%" />
					<fo:table-column column-width="12%" />
					<fo:table-column column-width="12%" />
					<fo:table-column column-width="12%" />
					<fo:table-column column-width="22%" />
					<fo:table-column column-width="10%" />
					<fo:table-column column-width="10%" />
					<fo:table-column column-width="10%" />
					<fo:table-header>
						<fo:table-row>
							<fo:table-cell background-repeat="repeat" background-color="{$bkgrnd_clr}" padding-bottom="4px" padding-left="3px" padding-right="3px" padding-top="4px">
								<fo:block font-weight="bold" font-size="7px" color="{$heading_font}" text-align="left">
									<xsl:text>Date</xsl:text>
								</fo:block>
							</fo:table-cell>
							<fo:table-cell background-repeat="repeat" background-color="{$bkgrnd_clr}" padding-bottom="4px" padding-left="3px" padding-right="3px" padding-top="4px">
								<fo:block font-weight="bold" font-size="7px" color="{$heading_font}" text-align="left">
									<xsl:text>Time</xsl:text>
								</fo:block>
							</fo:table-cell>
							<fo:table-cell background-color="{$bkgrnd_clr}" padding-bottom="4px" padding-left="3px" padding-right="3px" padding-top="4px">
								<fo:block font-weight="bold" font-size="7px" color="{$heading_font}" text-align="center">
									<xsl:text>From</xsl:text>
								</fo:block>
							</fo:table-cell>
							<fo:table-cell background-color="{$bkgrnd_clr}" padding-bottom="4px" padding-left="3px" padding-right="3px" padding-top="4px">
								<fo:block font-weight="bold" font-size="7px" color="{$heading_font}" text-align="center">
									<xsl:text>To</xsl:text>
								</fo:block>
							</fo:table-cell>
							<fo:table-cell background-color="{$bkgrnd_clr}" padding-bottom="4px" padding-left="3px" padding-right="3px" padding-top="4px">
								<fo:block font-weight="bold" font-size="7px" color="{$heading_font}" text-align="center">
									<xsl:text>Description</xsl:text>
								</fo:block>
							</fo:table-cell>
							<fo:table-cell background-color="{$bkgrnd_clr}" padding-bottom="4px" padding-left="3px" padding-right="3px" padding-top="4px">
								<fo:block font-weight="bold" font-size="7px" color="{$heading_font}" text-align="right">
									<xsl:text>Duration</xsl:text>
									<xsl:text>&#10;</xsl:text>
									<xsl:value-of select="concat('(',uomName,'s',')')" />
								</fo:block>
							</fo:table-cell>
							<fo:table-cell background-color="{$bkgrnd_clr}" padding-bottom="4px" padding-left="3px" padding-right="3px" padding-top="4px">
								<fo:block font-weight="bold" font-size="7px" color="{$heading_font}" text-align="right">
									<xsl:text>Taxes</xsl:text>
								</fo:block>
							</fo:table-cell>
							<fo:table-cell background-color="{$bkgrnd_clr}" padding-bottom="4px" padding-left="3px" padding-right="3px" padding-top="4px">
								<fo:block font-weight="bold" font-size="7px" color="{$heading_font}" text-align="end">
									<xsl:text>Amount</xsl:text>
								</fo:block>
							</fo:table-cell>
						</fo:table-row>
					</fo:table-header>
					<fo:table-body>
						<xsl:for-each select="key('usage_by_UOM', concat(uomName,../../subscriptionIdentifier))/lstLineItems[amount>0]">
							<fo:table-row>
								<fo:table-cell background-color="{$table_bkgrnd_clr}" background-repeat="repeat" padding-bottom="1px" padding-left="3px" padding-right="3px" padding-top="1px">
									<fo:block color="{$heading_font}" font-size="7px" text-align="left">
										<xsl:value-of select="substring(eventDate,1,8)" />
									</fo:block>
								</fo:table-cell>
								<fo:table-cell background-color="{$table_bkgrnd_clr}" background-repeat="repeat" padding-bottom="1px" padding-left="3px" padding-right="3px" padding-top="1px">
									<fo:block color="{$heading_font}" font-size="7px" text-align="left">
										<xsl:value-of select="eventAttributes/eventAttribute/Start_Time" />
									</fo:block>
								</fo:table-cell>
								<fo:table-cell background-color="{$table_bkgrnd_clr}" background-repeat="repeat" padding-bottom="1px" padding-left="3px" padding-right="3px" padding-top="1px">
									<fo:block color="{$heading_font}" font-size="7px" text-align="center">
										<xsl:value-of select="eventAttributes/eventAttribute/SOURCE" />
									</fo:block>
								</fo:table-cell>
								<fo:table-cell background-color="{$table_bkgrnd_clr}" background-repeat="repeat" padding-bottom="1px" padding-left="3px" padding-right="3px" padding-top="1px">
									<fo:block color="{$heading_font}" font-size="7px" text-align="center">
										<xsl:value-of select="eventAttributes/eventAttribute/DESTINATION" />
									</fo:block>
								</fo:table-cell>
								<fo:table-cell background-color="{$table_bkgrnd_clr}" background-repeat="repeat" padding-bottom="1px" padding-left="3px" padding-right="3px" padding-top="1px">
									<fo:block color="{$heading_font}" font-size="7px" text-align="center">
										<xsl:value-of select="chargeType" />
									</fo:block>
								</fo:table-cell>
								<fo:table-cell background-color="{$table_bkgrnd_clr}" background-repeat="repeat" padding-bottom="1px" padding-left="3px" padding-right="3px" padding-top="1px">
									<fo:block color="{$heading_font}" font-size="7px" text-align="right">
										<xsl:value-of select="format-number(unRoundedQuantity,'###0.0000')" />
									</fo:block>
								</fo:table-cell>
								<fo:table-cell background-color="{$table_bkgrnd_clr}" background-repeat="repeat" padding-bottom="1px" padding-left="3px" padding-right="3px" padding-top="1px">
									<fo:block color="{$heading_font}" font-size="7px" text-align="right">
										<xsl:if test="taxAmount">
											<xsl:call-template name="format_Currency">
												<xsl:with-param name="value">
													<xsl:value-of select="taxAmount" />
												</xsl:with-param>
											</xsl:call-template>
										</xsl:if>
									</fo:block>
								</fo:table-cell>
								<fo:table-cell background-color="{$table_bkgrnd_clr}" background-repeat="repeat" padding-bottom="1px" padding-left="3px" padding-right="3px" padding-top="1px">
									<fo:block color="{$heading_font}" font-size="7px" text-align="end">
										<xsl:call-template name="format_Currency">
											<xsl:with-param name="value">
												<xsl:value-of select="amount" />
											</xsl:with-param>
										</xsl:call-template>
									</fo:block>
								</fo:table-cell>
							</fo:table-row>
						</xsl:for-each>
						<fo:table-row>
							<fo:table-cell background-repeat="repeat" number-columns-spanned="6" background-color="{$bkgrnd_clr}" padding-bottom="4px" padding-left="3px" padding-right="3px" padding-top="4px">
								<fo:block font-weight="bold" font-size="7px" color="{$heading_font}" text-align="left">
									<xsl:text>Total</xsl:text>
								</fo:block>
							</fo:table-cell>
							<fo:table-cell background-color="{$bkgrnd_clr}" padding-bottom="4px" padding-left="3px" padding-right="3px" padding-top="4px">
								<fo:block font-weight="bold" font-size="7px" color="{$heading_font}" text-align="right">
									<xsl:call-template name="format_Currency">
										<xsl:with-param name="value">
											<xsl:value-of select="sum(key('usage_by_UOM', concat(uomName,../../subscriptionIdentifier))/taxAmount)" />
										</xsl:with-param>
									</xsl:call-template>
								</fo:block>
							</fo:table-cell>
							<fo:table-cell background-color="{$bkgrnd_clr}" padding-bottom="4px" padding-left="3px" padding-right="3px" padding-top="4px">
								<fo:block font-weight="bold" font-size="7px" color="{$heading_font}" text-align="end">
									<xsl:call-template name="format_Currency">
										<xsl:with-param name="value">
											<xsl:value-of select="sum(key('usage_by_UOM', concat(uomName,../../subscriptionIdentifier))/amount)" />
										</xsl:with-param>
									</xsl:call-template>
								</fo:block>
							</fo:table-cell>
						</fo:table-row>
					</fo:table-body>
				</fo:table>
			</xsl:for-each>
		</fo:block>
	</xsl:template>
	<xsl:template name="taxTable_Template">
		<xsl:choose>
			<xsl:when test="taxLineItem/lineItems">
				<fo:table width="100%" background-repeat="repeat">
					<fo:table-column column-width="100%" />
					<fo:table-body>
						<fo:table-row background-repeat="repeat" display-align="center" text-align="right" padding-bottom="3px" padding-left="3px" padding-right="5px" padding-top="3px" background-color="#FFFFFF" color="{$heading_font}" font-size="6px">
							<fo:table-cell>
								<fo:block page-break-inside="avoid">
									<fo:table width="100%" background-repeat="repeat">
										<fo:table-column column-width="70%" />
										<fo:table-column column-width="30%" />
										<fo:table-header>
											<fo:table-row>
												<fo:table-cell background-color="{$bkgrnd_clr}" display-align="center" text-align="left" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px">
													<fo:block font-weight="bold" font-size="6px" color="{$heading_font}">
														<xsl:text>DESCRIPTION1</xsl:text>
													</fo:block>
												</fo:table-cell>
												<fo:table-cell background-color="{$bkgrnd_clr}" display-align="after" text-align="right" padding-bottom="3px" padding-left="3px" padding-right="5px" padding-top="3px">
													<fo:block font-weight="bold" font-size="6px" color="{$heading_font}">
														<xsl:text>AMOUNT</xsl:text>
													</fo:block>
												</fo:table-cell>
											</fo:table-row>
										</fo:table-header>
										<fo:table-body>
											<xsl:for-each select="taxLineItem/lineItems">
												<fo:table-row padding-left="3px" padding-right="3px">

													<fo:table-cell text-align='start'>
														<fo:block>
															<xsl:value-of select="description" />
														</fo:block>
													</fo:table-cell>
													<fo:table-cell display-align="after" text-align="right" padding-right="5px">
														<fo:block>
															<xsl:if test="taxAmount != ''">
																<xsl:call-template name="format_Currency">
																	<xsl:with-param name="value">
																		<xsl:value-of select="taxAmount" />
																	</xsl:with-param>
																</xsl:call-template>
															</xsl:if>
														</fo:block>
													</fo:table-cell>
												</fo:table-row>

											</xsl:for-each>
											<fo:table-row>
												<fo:table-cell background-color="{$bkgrnd_clr}" display-align="center" text-align="left" padding-bottom="3px" padding-right="3px" padding-top="3px">
													<fo:block font-weight="bold" font-size="6px" color="{$heading_font}">
														<xsl:text>TOTAL TAX</xsl:text>
													</fo:block>
												</fo:table-cell>
												<fo:table-cell background-color="{$bkgrnd_clr}" display-align="after" text-align="right" padding-bottom="3px" padding-left="3px" padding-right="5px" padding-top="3px">
													<fo:block font-weight="bold" font-size="6px" color="{$heading_font}">
														<xsl:call-template name="format_Currency">
															<xsl:with-param name="value">
																<xsl:value-of select="taxLineItem/totalTax" />
															</xsl:with-param>
														</xsl:call-template>
													</fo:block>
												</fo:table-cell>
											</fo:table-row>

										</fo:table-body>
									</fo:table>
								</fo:block>
							</fo:table-cell>

						</fo:table-row>
					</fo:table-body>
				</fo:table>
			</xsl:when>
			<xsl:otherwise>
				<fo:block display-align="after" text-align="right">

					<xsl:if test="taxAmount != ''">
						<xsl:call-template name="format_Currency">
							<xsl:with-param name="value">
								<xsl:value-of select="taxAmount" />
							</xsl:with-param>
						</xsl:call-template>
					</xsl:if>
				</fo:block>
			</xsl:otherwise>
		</xsl:choose>

	</xsl:template>


	<xsl:template name="chargeSummary_GrpByAddress_NoTax">
		<fo:block>
			<fo:table width="100%" border-style="none" font-family="{$font_family}" font-size="10px">
				<fo:table-column column-width="18%" />
				<fo:table-column column-width="38%" />
				<fo:table-column column-width="28%" />
				<fo:table-column column-width="16%" />
				<xsl:call-template name="table_Header_Notax" />
				<fo:table-body>
					<xsl:for-each select="invoiceElements/lineItems[not(usageLineItem)][generate-id()=generate-id(key('addressLineItems-by-planDescription', concat(priceplanName,concat(startDate,'-',endDate)))[1])]">
						<xsl:sort select="priceplanName" />
						<xsl:sort select="startDate" />
						<fo:table-row>
							<xsl:variable name="accLineItems" select="." />
							<fo:table-cell background-color="{$table_bkgrnd_clr}" background-repeat="repeat" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px" display-align="center">
								<fo:block color="{$heading_font}" font-size="8px">
									<xsl:value-of select="startDate" />
								</fo:block>
							</fo:table-cell>
							<fo:table-cell background-color="{$table_bkgrnd_clr}" background-repeat="repeat" display-align="center" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px">
								<fo:block>
									<fo:inline font-weight="bold" font-size="8px">
										<xsl:value-of select="chargeType" />
									</fo:inline>
									<xsl:text disable-output-escaping="yes">
									</xsl:text>
									<fo:block font-size="8px">
										<xsl:if test="(chargeType != 'Metered Charge') and (ruleBased = 1)">
											<fo:inline color="{$color}"> x
											</fo:inline>
											<fo:inline color="{$heading_font}">
												<xsl:value-of select="concat('',format-number(sum(key('addressLineItems-by-planDescription', concat(planDescription,concat(startDate,'-',endDate)))[amount >= 0]/unRoundedQuantity),'###0.000'),' ',uomName)" />
											</fo:inline>
											<fo:inline color="{$color}"> at
											</fo:inline>
											<fo:inline color="{$heading_font}">
												<xsl:call-template name="format_Currency">
													<xsl:with-param name="value">
														<xsl:value-of select="key('addressLineItems-by-planDescription', concat(planDescription,concat(startDate,'-',endDate)))[amount >= 0]/unitPrice" />
													</xsl:with-param>
												</xsl:call-template>
											</fo:inline>
										</xsl:if>
										<xsl:if test="(chargeType != 'Metered Charge') and (ruleBased = 2)">
											<fo:inline color="{$heading_font}">
												<xsl:value-of select="concat('',format-number(sum(key('addressLineItems-by-planDescription', concat(planDescription,concat(startDate,'-',endDate)))[amount >= 0]/unRoundedQuantity),'###0.000'),' ',uomName)" />
											</fo:inline>
											<fo:inline color="{$color}"> @
											</fo:inline>
											<fo:inline color="{$heading_font}">

												<xsl:call-template name="format_Currency">
													<xsl:with-param name="value">
														<xsl:value-of select="totalAmount" />
													</xsl:with-param>
												</xsl:call-template>
											</fo:inline>
										</xsl:if>
									</fo:block>
									<!--<xsl:call-template name="usage_Summary_Template" /> -->
									<xsl:call-template name="discount_Template" />
								</fo:block>
							</fo:table-cell>
							<fo:table-cell background-color="{$table_bkgrnd_clr}" background-repeat="repeat" display-align="center" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px">
								<fo:block color="{$heading_font}" font-size="8px" text-align="center">
									<xsl:value-of select="chargeDescription" />
								</fo:block>
								<fo:block font-size="8px" text-align="center" color="{$color}">
									<xsl:if test="not(bundleId)">
										<xsl:choose>
											<xsl:when test="(endDate !='-') and (endDate !='')">
												<xsl:value-of select="concat(startDate,'-',endDate)" />
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="startDate" />
											</xsl:otherwise>
										</xsl:choose>
									</xsl:if>
								</fo:block>
							</fo:table-cell>
							<fo:table-cell background-repeat="repeat" display-align="after" text-align="right" padding-bottom="3px" padding-left="3px" padding-right="5px" padding-top="3px" background-color="{$bkgrnd_clr}">

								<fo:block color="{$heading_font}" font-size="8px" text-align="end">
									<!--xsl:value-of select="totalAmount" / -->
									<xsl:call-template name="format_Currency">
										<xsl:with-param name="value">
											<xsl:value-of select="sum(key('addressLineItems-by-planDescription', concat(planDescription,concat(startDate,'-',endDate)))[amount != 0]/totalAmount)" />
										</xsl:with-param>
									</xsl:call-template>
								</fo:block>

							</fo:table-cell>
						</fo:table-row>
					</xsl:for-each>
					<fo:table-row>
						<fo:table-cell number-columns-spanned="3" background-repeat="repeat" display-align="center" text-align="end" padding-bottom="5px" padding-right="3px" padding-left="3px" padding-top="5px" background-color="{$lightcolor}">
							<fo:block color="{$heading_font}" font-size="8px" text-align="end">
								<xsl:text>Total Charges
								</xsl:text>
							</fo:block>
						</fo:table-cell>
						<fo:table-cell background-repeat="repeat" display-align="center" text-align="right" padding-bottom="3px" padding-left="3px" padding-right="5px" padding-top="3px" background-color="{$lightcolor}">
							<fo:block color="{$heading_font}" font-size="8px">
								<!--xsl:value-of select="totalAmount" / -->
								<xsl:call-template name="format_Currency">
									<xsl:with-param name="value">

										<xsl:value-of select="sum(invoiceElements/lineItems/totalAmount) - sum(invoiceElements/lineItems[usageLineItem]/totalAmount)" />

									</xsl:with-param>
								</xsl:call-template>
							</fo:block>
						</fo:table-cell>
					</fo:table-row>
				</fo:table-body>
			</fo:table>
		</fo:block>
	</xsl:template>
	<xsl:template name="chargeSummary_GrpBySI_WithTax">
		<fo:block>
			<fo:table width="100%" border-style="none" font-family="{$font_family}" font-size="10px">
				<fo:table-column column-width="12%" />
				<fo:table-column column-width="32%" />
				<fo:table-column column-width="22%" />
				<fo:table-column column-width="24%" />
				<fo:table-column column-width="10%" />
				<xsl:call-template name="table_Header_With_Tax" />
				<fo:table-body>
					<xsl:for-each select="lineItems[generate-id(.)=generate-id(key('chargeSummary-by-subscriptionIdentifier', subscriptionIdentifier)[1])]">
						<!-- <xsl:for-each select="invoiceElements/lineItems"> -->
						<fo:table-row>
							<fo:table-cell number-columns-spanned="5">
								<fo:block>
									<xsl:if test="subscriptionIdentifier">
										<fo:block>
											<fo:inline font-weight="bold" font-size="8px">
												<xsl:value-of select="subscriptionIdentifier" />
											</fo:inline>
										</fo:block>
									</xsl:if>
								</fo:block>
							</fo:table-cell>
						</fo:table-row>
						<xsl:for-each select="key('chargeSummary-by-subscriptionIdentifier', subscriptionIdentifier)">
							<fo:table-row>

								<fo:table-cell background-color="{$table_bkgrnd_clr}" background-repeat="repeat" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px" display-align="center">
									<fo:block color="{$heading_font}" font-size="8px">
										<xsl:value-of select="eventDate" />
									</fo:block>
								</fo:table-cell>
								<fo:table-cell background-color="{$table_bkgrnd_clr}" background-repeat="repeat" display-align="center" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px">
									<fo:block>
										<fo:inline font-weight="bold" font-size="8px">
											<xsl:value-of select="chargeType" />
										</fo:inline>
										<xsl:text disable-output-escaping="yes">
										</xsl:text>
										<fo:block font-size="8px">
											<xsl:if test="(chargeType != 'Metered Charge') and (ruleBased = 1)">
												<fo:inline color="{$color}"> x
												</fo:inline>
												<fo:inline color="{$heading_font}">
													<xsl:value-of select="concat(' ',format-number(unRoundedQuantity,'###0.0000'),'  ',uomName)" />
												</fo:inline>
												<fo:inline color="{$color}"> at
												</fo:inline>
												<fo:inline color="{$heading_font}">
													<xsl:call-template name="format_Currency">
														<xsl:with-param name="value">
															<xsl:value-of select="unitPrice" />
														</xsl:with-param>
													</xsl:call-template>
													<!-- <xsl:value-of select="format-number(/invoice/totalCurrentCharge,$decimal_value,'dollar')" /> -->
												</fo:inline>
											</xsl:if>
											<xsl:if test="(chargeType != 'Metered Charge') and (ruleBased = 2)">
												<fo:inline color="{$heading_font}">
													<xsl:value-of select="concat(' ',format-number(unRoundedQuantity,'###0.0000'),'  ',uomName)" />
												</fo:inline>
												<fo:inline color="{$color}"> @
												</fo:inline>
												<fo:inline color="{$heading_font}">
													<!--xsl:value-of select="format-number(/invoice/totalCurrentCharge,$decimal_value,'dollar')"
														/ -->
													<xsl:call-template name="format_Currency">
														<xsl:with-param name="value">
															<xsl:value-of select="totalAmount" />
														</xsl:with-param>
													</xsl:call-template>

												</fo:inline>
											</xsl:if>
										</fo:block>
										<xsl:call-template name="usage_Summary_Template" />
										<xsl:call-template name="discount_Template" />
									</fo:block>
								</fo:table-cell>
								<fo:table-cell background-color="{$table_bkgrnd_clr}" background-repeat="repeat" display-align="center" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px">
									<fo:block color="{$heading_font}" font-size="8px" text-align="center">
										<xsl:value-of select="chargeDescription" />
									</fo:block>
									<fo:block font-size="8px" text-align="center" color="{$color}">
										<xsl:if test="not(bundleId)">
											<xsl:choose>
												<xsl:when test="(endDate !='-') and (endDate !='')">
													<xsl:value-of select="concat(startDate,'-',endDate)" />
												</xsl:when>
												<xsl:otherwise>
													<xsl:value-of select="startDate" />
												</xsl:otherwise>
											</xsl:choose>
										</xsl:if>
									</fo:block>
								</fo:table-cell>
								<fo:table-cell background-color="{$table_bkgrnd_clr}" background-repeat="repeat" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px" text-align="center" display-align="after">
									<fo:block color="{$heading_font}" font-size="8px">
										<xsl:call-template name="taxTable_Template" />
									</fo:block>
								</fo:table-cell>
								<fo:table-cell background-repeat="repeat" display-align="after" text-align="right" padding-bottom="3px" padding-left="3px" padding-right="5px" padding-top="3px" background-color="{$bkgrnd_clr}">
									<xsl:choose>
										<xsl:when test="totalCharge">
											<fo:block color="{$heading_font}" font-size="8px" text-align="end">
												<!--xsl:value-of select="totalCharge" / -->
												<xsl:call-template name="format_Currency">
													<xsl:with-param name="value">
														<xsl:value-of select="totalCharge" />
													</xsl:with-param>
												</xsl:call-template>
											</fo:block>
										</xsl:when>
										<xsl:otherwise>
											<fo:block color="{$heading_font}" font-size="8px" text-align="end">
												<!--xsl:value-of select="totalAmount" / -->
												<xsl:call-template name="format_Currency">
													<xsl:with-param name="value">
														<xsl:value-of select="totalAmount" />
													</xsl:with-param>
												</xsl:call-template>
											</fo:block>
										</xsl:otherwise>
									</xsl:choose>
								</fo:table-cell>
							</fo:table-row>
						</xsl:for-each>
					</xsl:for-each>
					<fo:table-row>
						<fo:table-cell number-columns-spanned="4" background-repeat="repeat" display-align="center" text-align="end" padding-bottom="5px" padding-right="3px" padding-left="3px" padding-top="5px" background-color="{$lightcolor}">
							<fo:block color="{$heading_font}" font-size="8px" text-align='end'>
								<xsl:text>Total Charges
								</xsl:text>
							</fo:block>
						</fo:table-cell>
						<fo:table-cell number-columns-spanned="1" background-repeat="repeat" display-align="center" text-align="right" padding-bottom="3px" padding-left="3px" padding-right="5px" padding-top="3px" background-color="{$lightcolor}">
							<fo:block color="{$heading_font}" font-size="8px">
								<!--xsl:value-of select="totalAmount" / -->
								<xsl:call-template name="format_Currency">
									<xsl:with-param name="value">
										<xsl:value-of select="totalAmount" />
									</xsl:with-param>
								</xsl:call-template>
							</fo:block>
						</fo:table-cell>
					</fo:table-row>
				</fo:table-body>
			</fo:table>
		</fo:block>
	</xsl:template>
	<xsl:template name="chargeSummary_GrpBySI_NoTax">
		<fo:block>
			<xsl:call-template name="space" />
			<fo:table width="100%" border-style="none" font-family="{$font_family}" font-size="10px">
				<fo:table-column column-width="18%" />
				<fo:table-column column-width="38%" />
				<fo:table-column column-width="28%" />
				<fo:table-column column-width="16%" />
				<xsl:call-template name="table_Header_Notax" />
				<fo:table-body>
					<xsl:for-each select="lineItems[generate-id(.)=generate-id(key('chargeSummary-by-subscriptionIdentifier', subscriptionIdentifier)[1])]">
						<!-- <xsl:for-each select="invoiceElements/lineItems"> -->
						<fo:table-row>
							<fo:table-cell number-columns-spanned="4">
								<fo:block>
									<xsl:if test="subscriptionIdentifier">
										<fo:block>
											<fo:inline font-weight="bold" font-size="8px">
												<xsl:value-of select="subscriptionIdentifier" />
											</fo:inline>
										</fo:block>
									</xsl:if>
								</fo:block>
							</fo:table-cell>
						</fo:table-row>
						<xsl:for-each select="key('chargeSummary-by-subscriptionIdentifier', subscriptionIdentifier)">
							<fo:table-row>

								<fo:table-cell background-color="{$table_bkgrnd_clr}" background-repeat="repeat" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px" display-align="center">
									<fo:block color="{$heading_font}" font-size="8px">
										<xsl:value-of select="eventDate" />
									</fo:block>
								</fo:table-cell>
								<fo:table-cell background-color="{$table_bkgrnd_clr}" background-repeat="repeat" display-align="center" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px">
									<fo:block>
										<fo:inline font-weight="bold" font-size="8px">
											<xsl:value-of select="chargeType" />
										</fo:inline>
										<xsl:text disable-output-escaping="yes">
										</xsl:text>
										<fo:block font-size="8px">
											<xsl:if test="(chargeType != 'Metered Charge') and (ruleBased = 1)">
												<fo:inline color="{$color}"> x
												</fo:inline>
												<fo:inline color="{$heading_font}">
													<xsl:value-of select="concat(' ',format-number(unRoundedQuantity,'###0.0000'),'  ',uomName)" />
												</fo:inline>
												<fo:inline color="{$color}"> at
												</fo:inline>
												<fo:inline color="{$heading_font}">
													<xsl:call-template name="format_Currency">
														<xsl:with-param name="value">
															<xsl:value-of select="unitPrice" />
														</xsl:with-param>
													</xsl:call-template>
													<!-- <xsl:value-of select="format-number(/invoice/totalCurrentCharge,$decimal_value,'dollar')" /> -->
												</fo:inline>
											</xsl:if>
											<xsl:if test="(chargeType != 'Metered Charge') and (ruleBased = 2)">
												<fo:inline color="{$heading_font}">
													<xsl:value-of select="concat(' ',format-number(unRoundedQuantity,'###0.0000'),'  ',uomName)" />
												</fo:inline>
												<fo:inline color="{$color}"> @
												</fo:inline>
												<fo:inline color="{$heading_font}">
													<!--xsl:value-of select="format-number(/invoice/totalCurrentCharge,$decimal_value,'dollar')"
														/ -->
													<xsl:call-template name="format_Currency">
														<xsl:with-param name="value">
															<xsl:value-of select="totalAmount" />
														</xsl:with-param>
													</xsl:call-template>
												</fo:inline>
											</xsl:if>
										</fo:block>
										<xsl:call-template name="usage_Summary_Template" />
										<xsl:call-template name="discount_Template" />
									</fo:block>
								</fo:table-cell>
								<fo:table-cell background-color="{$table_bkgrnd_clr}" background-repeat="repeat" display-align="center" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px">
									<fo:block color="{$heading_font}" font-size="8px" text-align="center">
										<xsl:value-of select="chargeDescription" />
									</fo:block>
									<fo:block font-size="8px" text-align="center" color="{$color}">
										<xsl:if test="not(bundleId)">
											<xsl:choose>
												<xsl:when test="(endDate !='-') and (endDate !='')">
													<xsl:value-of select="concat(startDate,'-',endDate)" />
												</xsl:when>
												<xsl:otherwise>
													<xsl:value-of select="startDate" />
												</xsl:otherwise>
											</xsl:choose>
										</xsl:if>
									</fo:block>
								</fo:table-cell>
								<fo:table-cell background-repeat="repeat" display-align="after" text-align="right" padding-bottom="3px" padding-left="3px" padding-right="5px" padding-top="3px" background-color="{$bkgrnd_clr}">
									<fo:block color="{$heading_font}" font-size="8px" text-align="end">
										<!--xsl:value-of select="totalAmount" / -->
										<xsl:call-template name="format_Currency">
											<xsl:with-param name="value">
												<xsl:value-of select="totalAmount" />
											</xsl:with-param>
										</xsl:call-template>
									</fo:block>
								</fo:table-cell>
							</fo:table-row>
						</xsl:for-each>
					</xsl:for-each>
					<fo:table-row>
						<fo:table-cell number-columns-spanned="3" background-repeat="repeat" display-align="center" text-align="end" padding-bottom="5px" padding-right="3px" padding-left="3px" padding-top="5px" background-color="{$lightcolor}">
							<fo:block color="{$heading_font}" font-size="8px" text-align='end'>
								<xsl:text>Total Charges
								</xsl:text>
							</fo:block>
						</fo:table-cell>
						<fo:table-cell number-columns-spanned="1" background-repeat="repeat" display-align="center" text-align="right" padding-bottom="3px" padding-left="3px" padding-right="5px" padding-top="3px" background-color="{$lightcolor}">
							<fo:block color="{$heading_font}" font-size="8px">
								<!--xsl:value-of select="totalAmount" / -->
								<xsl:call-template name="format_Currency">
									<xsl:with-param name="value">
										<xsl:value-of select="totalDue" />
									</xsl:with-param>
								</xsl:call-template>
							</fo:block>
						</fo:table-cell>
					</fo:table-row>
				</fo:table-body>
			</fo:table>
		</fo:block>
	</xsl:template>
	<xsl:template name="summary_GrpBySI_NoTax">
		<fo:table>
			<fo:table-column column-width="25%" />
			<fo:table-column column-width="25%" />
			<fo:table-column column-width="25%" />
			<fo:table-column column-width="25%" />
			<fo:table-header font-weight="bold">
				<fo:table-row>
					<fo:table-cell background-repeat="repeat" background-color="{$bkgrnd_clr}" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px">
						<fo:block font-weight="bold" font-size="8px" color="{$heading_font}">
							<xsl:text>SUBSCRIPTION IDENTIFIER</xsl:text>
						</fo:block>
					</fo:table-cell>
					<fo:table-cell background-repeat="repeat" background-color="{$bkgrnd_clr}" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px" text-align="right">
						<fo:block font-weight="bold" font-size="8px" color="{$heading_font}">
							<xsl:text>RECURRING CHARGES</xsl:text>
						</fo:block>
					</fo:table-cell>
					<fo:table-cell background-repeat="repeat" background-color="{$bkgrnd_clr}" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px" text-align="right">
						<fo:block font-weight="bold" font-size="8px" color="{$heading_font}">
							<xsl:text>NON-RECURRING CHARGES</xsl:text>
						</fo:block>
					</fo:table-cell>
					<fo:table-cell background-repeat="repeat" background-color="{$bkgrnd_clr}" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px" text-align="right">
						<fo:block font-weight="bold" font-size="8px" color="{$heading_font}">
							<xsl:text>USAGE CHARGES</xsl:text>
						</fo:block>
					</fo:table-cell>
				</fo:table-row>
			</fo:table-header>
			<fo:table-body>
				<xsl:for-each select="/invoice/.//accountInvoiceElements/invoiceElements">
					<fo:table-row>
						<fo:table-cell background-color="{$table_bkgrnd_clr}" background-repeat="repeat" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px">
							<fo:block color="{$heading_font}" font-size="8px">
								<xsl:value-of select="subscriptionIdentifier" />
							</fo:block>
						</fo:table-cell>
						<fo:table-cell background-color="{$table_bkgrnd_clr}" background-repeat="repeat" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px" text-align="right">
							<fo:block color="{$heading_font}" font-size="8px">
								<xsl:call-template name="format_Currency">
									<xsl:with-param name="value">
										<xsl:value-of select="sum(lineItems[eventType='Recurring']/totalAmount)" />
									</xsl:with-param>
								</xsl:call-template>
							</fo:block>
						</fo:table-cell>
						<fo:table-cell background-color="{$table_bkgrnd_clr}" background-repeat="repeat" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px" text-align="right">
							<fo:block color="{$heading_font}" font-size="8px">
								<xsl:call-template name="format_Currency">
									<xsl:with-param name="value">
										<xsl:value-of select="sum(lineItems[eventType!='Recurring' and eventType !='USAGE']/totalAmount)" />
									</xsl:with-param>
								</xsl:call-template>
							</fo:block>
						</fo:table-cell>
						<fo:table-cell background-color="{$table_bkgrnd_clr}" background-repeat="repeat" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px" text-align="right">
							<fo:block color="{$heading_font}" font-size="8px">
								<xsl:call-template name="format_Currency">
									<xsl:with-param name="value">
										<xsl:value-of select="sum(lineItems[usageLineItem]/totalAmount)" />
									</xsl:with-param>
								</xsl:call-template>
							</fo:block>
						</fo:table-cell>
					</fo:table-row>
				</xsl:for-each>
			</fo:table-body>
		</fo:table>
	</xsl:template>
	<xsl:template name="summary_grpBySI_with_tax">
		<fo:table>
			<fo:table-column column-width="25%" />
			<fo:table-column column-width="25%" />
			<fo:table-column column-width="25%" />
			<fo:table-column column-width="25%" />
			<fo:table-header font-weight="bold">
				<fo:table-row>
					<fo:table-cell background-repeat="repeat" background-color="{$bkgrnd_clr}" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px">
						<fo:block font-weight="bold" font-size="8px" color="{$heading_font}">
							<xsl:text>SUBSCRIPTION IDENTIFIER</xsl:text>
						</fo:block>
					</fo:table-cell>
					<fo:table-cell background-repeat="repeat" background-color="{$bkgrnd_clr}" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px" text-align="right">
						<fo:block font-weight="bold" font-size="8px" color="{$heading_font}">
							<xsl:text>RECURRING CHARGES</xsl:text>
						</fo:block>
					</fo:table-cell>
					<fo:table-cell background-repeat="repeat" background-color="{$bkgrnd_clr}" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px">
						<fo:block font-weight="bold" font-size="8px" color="{$heading_font}" text-align="right">
							<xsl:text>NON-RECURRING CHARGES</xsl:text>
						</fo:block>
					</fo:table-cell>
					<fo:table-cell background-repeat="repeat" background-color="{$bkgrnd_clr}" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px">
						<fo:block font-weight="bold" font-size="8px" color="{$heading_font}" text-align="right">
							<xsl:text>USAGE CHARGES</xsl:text>
						</fo:block>
					</fo:table-cell>
				</fo:table-row>
			</fo:table-header>
			<fo:table-body>
				<xsl:for-each select="/invoice/.//accountInvoiceElements/invoiceElements">
					<fo:table-row>
						<fo:table-cell background-color="{$table_bkgrnd_clr}" background-repeat="repeat" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px">
							<fo:block color="{$heading_font}" font-size="8px">
								<xsl:value-of select="subscriptionIdentifier" />
							</fo:block>
						</fo:table-cell>
						<fo:table-cell background-color="{$table_bkgrnd_clr}" background-repeat="repeat" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px" text-align="right">
							<fo:block color="{$heading_font}" font-size="8px">
								<xsl:call-template name="format_Currency">
									<xsl:with-param name="value">
										<xsl:value-of select="sum(lineItems[eventType='Recurring']/totalCharge)" />
									</xsl:with-param>
								</xsl:call-template>
							</fo:block>
						</fo:table-cell>
						<fo:table-cell background-color="{$table_bkgrnd_clr}" background-repeat="repeat" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px" text-align="right">
							<fo:block color="{$heading_font}" font-size="8px">
								<xsl:call-template name="format_Currency">
									<xsl:with-param name="value">
										<xsl:value-of select="sum(lineItems[eventType!='Recurring' and eventType !='USAGE']/totalCharge)" />
									</xsl:with-param>
								</xsl:call-template>
							</fo:block>
						</fo:table-cell>
						<fo:table-cell background-color="{$table_bkgrnd_clr}" background-repeat="repeat" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px" text-align="right">
							<fo:block color="{$heading_font}" font-size="8px">
								<xsl:call-template name="format_Currency">
									<xsl:with-param name="value">
										<xsl:value-of select="sum(lineItems[usageLineItem]/totalCharge)" />
									</xsl:with-param>
								</xsl:call-template>
							</fo:block>
						</fo:table-cell>
					</fo:table-row>
				</xsl:for-each>
			</fo:table-body>
		</fo:table>
	</xsl:template>
	<xsl:template name="summary_grpByAddress_NoTax">
		<fo:table>
			<fo:table-column column-width="40%" />
			<fo:table-column column-width="22%" />
			<fo:table-column column-width="22%" />
			<fo:table-column column-width="16%" />
			<fo:table-header font-weight="bold">
				<fo:table-row>
					<fo:table-cell background-repeat="repeat" background-color="{$bkgrnd_clr}" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px" text-align="left">
						<fo:block font-weight="bold" font-size="8px" color="{$heading_font}">
							<xsl:text>LOCATION</xsl:text>
						</fo:block>
					</fo:table-cell>
					<fo:table-cell background-repeat="repeat" background-color="{$bkgrnd_clr}" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px" text-align="right">
						<fo:block font-weight="bold" font-size="8px" color="{$heading_font}">
							<xsl:text>RECURRING CHARGES</xsl:text>
						</fo:block>
					</fo:table-cell>
					<fo:table-cell background-repeat="repeat" background-color="{$bkgrnd_clr}" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px" text-align="right">
						<fo:block font-weight="bold" font-size="8px" color="{$heading_font}">
							<xsl:text>NON-RECURRING CHARGES</xsl:text>
						</fo:block>
					</fo:table-cell>
					<fo:table-cell background-repeat="repeat" background-color="{$bkgrnd_clr}" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px" text-align="right">
						<fo:block font-weight="bold" font-size="8px" color="{$heading_font}">
							<xsl:text>USAGE CHARGES</xsl:text>
						</fo:block>
					</fo:table-cell>
				</fo:table-row>
			</fo:table-header>
			<fo:table-body>
				<xsl:for-each select="accountInvoiceElements">
					<fo:table-row>
						<fo:table-cell background-color="{$table_bkgrnd_clr}" background-repeat="repeat" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px" text-align="left">
							<fo:block color="{$heading_font}" font-size="8px">
								<xsl:if test="shippingAddId != ''">
									<fo:block color="{$heading_font}">
										<xsl:value-of select="shipTo/addressLine1" />
										<xsl:if test="shipTo/addressLine2 !=''">
											<xsl:value-of select="concat(', ',shipTo/addressLine2)" />
										</xsl:if>
										<xsl:if test="shipTo/city !=''">
											<xsl:value-of select="concat(', ',shipTo/city)" />
										</xsl:if>
										<xsl:if test="shipTo/state !=''">
											<xsl:value-of select="concat(', ',shipTo/state)" />
										</xsl:if>
										<xsl:if test="shipTo/postalCode !=''">
											<xsl:text>
											</xsl:text>
											<xsl:value-of select="concat(' ',shipTo/postalCode)" />
										</xsl:if>
									</fo:block>
								</xsl:if>
							</fo:block>
						</fo:table-cell>
						<fo:table-cell background-color="{$table_bkgrnd_clr}" background-repeat="repeat" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px" text-align="right">
							<fo:block color="{$heading_font}" font-size="8px">
								<xsl:call-template name="format_Currency">
									<xsl:with-param name="value">
										<xsl:value-of select="sum(invoiceElements/lineItems[eventType='Recurring']/totalAmount)" />
									</xsl:with-param>
								</xsl:call-template>
							</fo:block>
						</fo:table-cell>
						<fo:table-cell background-color="{$table_bkgrnd_clr}" background-repeat="repeat" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px" text-align="right">
							<fo:block color="{$heading_font}" font-size="8px">
								<xsl:call-template name="format_Currency">
									<xsl:with-param name="value">
										<xsl:value-of select="sum(invoiceElements/lineItems[eventType!='Recurring' and not(usageLineItem)]/totalAmount)" />
									</xsl:with-param>
								</xsl:call-template>
							</fo:block>
						</fo:table-cell>
						<fo:table-cell background-color="{$table_bkgrnd_clr}" background-repeat="repeat" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px" text-align="right">
							<fo:block color="{$heading_font}" font-size="8px">
								<xsl:call-template name="format_Currency">
									<xsl:with-param name="value">
										<xsl:value-of select="sum(invoiceElements/lineItems[usageLineItem]/totalAmount)" />
									</xsl:with-param>
								</xsl:call-template>
							</fo:block>
						</fo:table-cell>
					</fo:table-row>
				</xsl:for-each>
			</fo:table-body>
		</fo:table>
	</xsl:template>
	<xsl:template name="summary_grpByAddress_with_tax">
		<fo:table>
			<fo:table-column column-width="40%" />
			<fo:table-column column-width="22%" />
			<fo:table-column column-width="22%" />
			<fo:table-column column-width="16%" />
			<fo:table-header font-weight="bold">
				<fo:table-row>
					<fo:table-cell background-repeat="repeat" background-color="{$bkgrnd_clr}" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px" text-align="left">
						<fo:block font-weight="bold" font-size="8px" color="{$heading_font}">
							<xsl:text>LOCATION</xsl:text>
						</fo:block>
					</fo:table-cell>
					<fo:table-cell background-repeat="repeat" background-color="{$bkgrnd_clr}" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px" text-align="right">
						<fo:block font-weight="bold" font-size="8px" color="{$heading_font}">
							<xsl:text>RECURRING CHARGES</xsl:text>
						</fo:block>
					</fo:table-cell>
					<fo:table-cell background-repeat="repeat" background-color="{$bkgrnd_clr}" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px" text-align="right">
						<fo:block font-weight="bold" font-size="8px" color="{$heading_font}">
							<xsl:text>NON-RECURRING CHARGES</xsl:text>
						</fo:block>
					</fo:table-cell>
					<fo:table-cell background-repeat="repeat" background-color="{$bkgrnd_clr}" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px" text-align="right">
						<fo:block font-weight="bold" font-size="8px" color="{$heading_font}">
							<xsl:text>USAGE CHARGES</xsl:text>
						</fo:block>
					</fo:table-cell>
				</fo:table-row>
			</fo:table-header>
			<fo:table-body>
				<xsl:for-each select="accountInvoiceElements">
					<fo:table-row>
						<fo:table-cell background-color="{$table_bkgrnd_clr}" background-repeat="repeat" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px" text-align="left">
							<fo:block color="{$heading_font}" font-size="8px">
								<xsl:if test="shippingAddId != ''">
									<fo:block color="{$heading_font}">
										<xsl:value-of select="shipTo/addressLine1" />
										<xsl:if test="shipTo/addressLine2 !=''">
											<xsl:value-of select="concat(', ',shipTo/addressLine2)" />
										</xsl:if>
										<xsl:if test="shipTo/city !=''">
											<xsl:value-of select="concat(', ',shipTo/city)" />
										</xsl:if>

										<xsl:if test="shipTo/state !=''">
											<xsl:value-of select="concat(', ',shipTo/state)" />
										</xsl:if>
										<xsl:if test="shipTo/postalCode !=''">
											<xsl:text>
											</xsl:text>
											<xsl:value-of select="concat(' ',shipTo/postalCode)" />
										</xsl:if>
									</fo:block>
								</xsl:if>
							</fo:block>
						</fo:table-cell>
						<fo:table-cell background-color="{$table_bkgrnd_clr}" background-repeat="repeat" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px" text-align="right">
							<fo:block color="{$heading_font}" font-size="8px">
								<xsl:call-template name="format_Currency">
									<xsl:with-param name="value">
										<xsl:value-of select="sum(invoiceElements/lineItems[eventType='Recurring']/totalCharge)" />
									</xsl:with-param>
								</xsl:call-template>
							</fo:block>
						</fo:table-cell>
						<fo:table-cell background-color="{$table_bkgrnd_clr}" background-repeat="repeat" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px" text-align="right">
							<fo:block color="{$heading_font}" font-size="8px">
								<xsl:call-template name="format_Currency">
									<xsl:with-param name="value">
										<xsl:value-of select="sum(invoiceElements/lineItems[eventType!='Recurring' and not(usageLineItem)]/totalCharge)" />
									</xsl:with-param>
								</xsl:call-template>
							</fo:block>
						</fo:table-cell>
						<fo:table-cell background-color="{$table_bkgrnd_clr}" background-repeat="repeat" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px" text-align="right">
							<fo:block color="{$heading_font}" font-size="8px">
								<xsl:call-template name="format_Currency">
									<xsl:with-param name="value">
										<xsl:value-of select="sum(invoiceElements/lineItems[usageLineItem]/totalCharge)" />
									</xsl:with-param>
								</xsl:call-template>
							</fo:block>
						</fo:table-cell>
					</fo:table-row>
				</xsl:for-each>
			</fo:table-body>
		</fo:table>
	</xsl:template>
	<xsl:template name="summary_grpByAddress_WithTaxSeparate">
		<fo:table>
			<fo:table-column column-width="40%" />
			<fo:table-column column-width="22%" />
			<fo:table-column column-width="22%" />
			<fo:table-column column-width="16%" />
			<fo:table-header font-weight="bold">
				<fo:table-row>
					<fo:table-cell background-repeat="repeat" background-color="{$bkgrnd_clr}" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px" text-align="left">
						<fo:block font-weight="bold" font-size="8px" color="{$heading_font}">
							<xsl:text>Location</xsl:text>
						</fo:block>
					</fo:table-cell>
					<fo:table-cell background-repeat="repeat" background-color="{$bkgrnd_clr}" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px" text-align="right">
						<fo:block font-weight="bold" font-size="8px" color="{$heading_font}">
							<xsl:text>Recurring Charges</xsl:text>
						</fo:block>
					</fo:table-cell>
					<fo:table-cell background-repeat="repeat" background-color="{$bkgrnd_clr}" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px" text-align="right">
						<fo:block font-weight="bold" font-size="8px" color="{$heading_font}">
							<xsl:text>Non-Recurring Charges</xsl:text>
						</fo:block>
					</fo:table-cell>
					<fo:table-cell background-repeat="repeat" background-color="{$bkgrnd_clr}" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px" text-align="right">
						<fo:block font-weight="bold" font-size="8px" color="{$heading_font}">
							<xsl:text>Usage Charges</xsl:text>
						</fo:block>
					</fo:table-cell>
				</fo:table-row>
			</fo:table-header>
			<fo:table-body>
				<xsl:for-each select="accountInvoiceElements">
					<fo:table-row>
						<fo:table-cell background-color="{$table_bkgrnd_clr}" background-repeat="repeat" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px" text-align="left">
							<fo:block color="{$heading_font}" font-size="8px">
								<xsl:if test="shippingAddId != ''">
									<fo:block color="{$heading_font}">
										<xsl:value-of select="shipTo/addressLine1" />
										<xsl:if test="shipTo/addressLine2 !=''">
											<xsl:value-of select="concat(', ',shipTo/addressLine2)" />
										</xsl:if>
										<xsl:if test="shipTo/city !=''">
											<xsl:value-of select="concat(', ',shipTo/city)" />
										</xsl:if>
										<xsl:if test="shipTo/state !=''">
											<xsl:value-of select="concat(', ',shipTo/state)" />
										</xsl:if>
										<xsl:if test="shipTo/postalCode !=''">
											<xsl:text>
											</xsl:text>
											<xsl:value-of select="concat(' ',shipTo/postalCode)" />
										</xsl:if>
									</fo:block>
								</xsl:if>
							</fo:block>
						</fo:table-cell>
						<fo:table-cell background-color="{$table_bkgrnd_clr}" background-repeat="repeat" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px" text-align="center">
							<fo:block color="{$heading_font}" font-size="8px">
								<xsl:call-template name="format_Currency">
									<xsl:with-param name="value">
										<xsl:value-of select="sum(invoiceElements/lineItems[eventType='Recurring' or bundleLineItem/eventType='Recurring']/totalAmount)" />
									</xsl:with-param>
								</xsl:call-template>
							</fo:block>
						</fo:table-cell>
						<fo:table-cell background-color="{$table_bkgrnd_clr}" background-repeat="repeat" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px" text-align="center">
							<fo:block color="{$heading_font}" font-size="8px">
								<xsl:call-template name="format_Currency">
									<xsl:with-param name="value">
										<xsl:value-of select="sum(invoiceElements/lineItems[eventType!='Recurring' and not(usageLineItem) or bundleLineItem/eventType!='Recurring' and bundleLineItem[not(usageLineItem)]]/totalAmount)" />
									</xsl:with-param>
								</xsl:call-template>
							</fo:block>
						</fo:table-cell>
						<fo:table-cell background-color="{$table_bkgrnd_clr}" background-repeat="repeat" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px" text-align="center">
							<fo:block color="{$heading_font}" font-size="8px">
								<xsl:call-template name="format_Currency">
									<xsl:with-param name="value">
										<xsl:value-of select="sum(invoiceElements/lineItems[usageLineItem or bundleLineItem/usageLineItem ]/totalAmount)" />
									</xsl:with-param>
								</xsl:call-template>
							</fo:block>
						</fo:table-cell>
					</fo:table-row>
				</xsl:for-each>
			</fo:table-body>
		</fo:table>
	</xsl:template>
	<xsl:template name="summary_grpByAddress_NoTax_OuterTemplate">
		<xsl:choose>
			<xsl:when test="/invoice/accountInvoiceElements/accountInvoiceElements">
				<xsl:for-each select="/invoice/accountInvoiceElements">
					<fo:block>
						<xsl:call-template name="accountNumber_Template" />
					</fo:block>
					<xsl:call-template name="summary_grpByAddress_NoTax" />
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<xsl:for-each select="/invoice">
					<fo:block>
						<xsl:call-template name="accountNumber_Template" />
					</fo:block>
					<xsl:call-template name="summary_grpByAddress_NoTax" />
				</xsl:for-each>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="summary_grpByAddress_WithTax_OuterTemplate">
		<xsl:choose>
			<xsl:when test="/invoice/accountInvoiceElements/accountInvoiceElements">
				<xsl:for-each select="/invoice/accountInvoiceElements">
					<fo:block>
						<xsl:call-template name="accountNumber_Template" />
					</fo:block>
					<xsl:call-template name="summary_grpByAddress_with_tax" />
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<xsl:for-each select="/invoice">
					<fo:block>
						<xsl:call-template name="accountNumber_Template" />
					</fo:block>
					<xsl:call-template name="summary_grpByAddress_with_tax" />
				</xsl:for-each>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="summary_grpByAddress_WithTaxSeparate_OuterTemplate">
		<xsl:choose>
			<xsl:when test="/invoice/accountInvoiceElements/accountInvoiceElements">
				<xsl:for-each select="/invoice/accountInvoiceElements">
					<fo:block>
						<xsl:call-template name="accountNumber_Template" />
					</fo:block>
					<xsl:call-template name="summary_grpByAddress_WithTaxSeparate" />
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<xsl:for-each select="/invoice">
					<fo:block>
						<xsl:call-template name="accountNumber_Template" />
					</fo:block>
					<xsl:call-template name="summary_grpByAddress_WithTaxSeparate" />
				</xsl:for-each>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="/">
		<fo:root xmlns:fo="http://www.w3.org/1999/XSL/Format">
			<fo:layout-master-set>
				<xsl:variable name="height" select="/invoice/height" />
				<xsl:variable name="width" select="/invoice/width" />
				<fo:simple-page-master master-name="first-page" page-height="{$height}" page-width="{$width}" margin-left="0.5in" margin-right="0.5in" margin-top="0.1in" margin-bottom="0.1in">
					<fo:region-body region-name="xsl-region-body" margin-top="0.1in" margin-bottom="0.3in" />
					<fo:region-after region-name="xsl-region-after" extent="0.1in" />
				</fo:simple-page-master>
				<fo:simple-page-master master-name="default-page" page-height="{$height}" page-width="{$width}" margin-left="0.5in" margin-right="0.5in" margin-top="0.1in" margin-bottom="0.2in">
					<fo:region-body region-name="xsl-region-body" margin-top="0.1in" margin-bottom="0.3in" />
					<fo:region-after region-name="xsl-region-after" extent="0.1in" />
				</fo:simple-page-master>
				<fo:simple-page-master master-name="Usage-Details" page-width="{$width}" margin-left="0.5in" margin-right="0.5in" margin-top="0.2in" margin-bottom="0.2in">
					<fo:region-body region-name="xsl-region-body" margin-top="0.2in" margin-bottom="0.3in" column-gap="5mm" />
					<fo:region-after region-name="xsl-region-after" extent="0.1in" />
				</fo:simple-page-master>
			</fo:layout-master-set>
			<fo:page-sequence master-reference="first-page">
				<fo:static-content flow-name="xsl-region-after" font-size="7pt" font-family="{$font_family}" color="{$heading_font}">
					<fo:block>
						<fo:table>
							<fo:table-column column-width="100%" />
							<fo:table-body>
								<fo:table-row>
									<fo:table-cell>
										<fo:block>
											<xsl:value-of select="/invoice/footer" disable-output-escaping="yes" />
										</fo:block>
									</fo:table-cell>
								</fo:table-row>
							</fo:table-body>
						</fo:table>
					</fo:block>
					<fo:block text-align="end">
						<fo:page-number />
					</fo:block>
				</fo:static-content>
				<fo:flow flow-name="xsl-region-body">
					<fo:block font-weight="normal">
						<fo:block>
							<fo:table width="100%" background-repeat="repeat" border-width="0pt" padding="0pt" border-bottom="#c0c0c0 0.5px dotted">
								<fo:table-column column-width="29%" />
								<fo:table-column column-width="46%" />
								<fo:table-column column-width="25%" />
								<fo:table-body>
									<fo:table-row>
										<fo:table-cell display-align="center">
											<xsl:call-template name="logo" />
										</fo:table-cell>
										<fo:table-cell>
											<fo:block></fo:block>
										</fo:table-cell>
										<fo:table-cell border-style="none" padding-right="5" background-repeat="repeat" font-family="{$font_family}" font-size="8px">
											<xsl:call-template name="remit_To" />
											<xsl:call-template name="space" />

										</fo:table-cell>
									</fo:table-row>
								</fo:table-body>
							</fo:table>
						</fo:block>
						<fo:block>
							<xsl:text>
							</xsl:text>
						</fo:block>
						<fo:block>
							<fo:table width="100%" background-repeat="repeat">
								<fo:table-column column-width="50%" />
								<fo:table-column column-width="50%" />
								<fo:table-body>
									<fo:table-row>
										<fo:table-cell border-style="none" font-family="{$font_family}" font-size="8px" text-align="left" padding-left="10px">
											<xsl:call-template name="bill_To_Details" />
										</fo:table-cell>
										<fo:table-cell>
											<xsl:call-template name="accountNo_InvoiceNo" />
											<fo:table>
												<fo:table-column column-width="100%" />
												<fo:table-body>
													<fo:table-row>
														<fo:table-cell>
															<xsl:call-template name="billing_Summary" />
														</fo:table-cell>
													</fo:table-row>
													<fo:table-row>
														<fo:table-cell>
															<xsl:call-template name="total_Amount_Due" />
														</fo:table-cell>
													</fo:table-row>
												</fo:table-body>
											</fo:table>
										</fo:table-cell>
									</fo:table-row>
								</fo:table-body>
							</fo:table>
						</fo:block>
						<fo:block>
							<fo:block>
								<xsl:text>&#xA0;</xsl:text>
							</fo:block>
							<fo:block margin="0pt" background-color="#f5f5f5" font-weight="normal" font-size="6px" padding-bottom="4px" padding-left="3px" padding-right="3px" padding-top="5px" color="#5F5F5F" border-bottom="#FFFFFF 1.0px solid">
								<fo:inline font-weight="bold">
									<xsl:text>Banking Instructions:</xsl:text>
								</fo:inline>
								Payments can be made by Wire/ACH Transfer, Credit Card or Electronic Check.
								<fo:block>
									<xsl:text>&#xA0;</xsl:text>
								</fo:block>
								Bank Name: Bank Leumi USA
								<fo:block></fo:block>
								Bank SWIFT: LUMIUS3N
								<fo:block></fo:block>
								Bank ABA/ Routing#: 026-002-794
								<fo:block></fo:block>
								Account Name: Rscom Business LLC
								<fo:block></fo:block>
								Account Number: 1441719700
								<fo:block>
									<xsl:text>&#xA0;</xsl:text>
								</fo:block>
								<fo:inline font-weight="bold">
									<xsl:text>Returned Payments</xsl:text>
								</fo:inline>
								In the event your Check for payment of your bill is returned
								by your bank for insufficient or uncollected funds, we may
								resubmit your Check for payment on your account. A one-time
								charge of $45.00 will be applied to your account for any
								payment returned due to insufficient funds in your bank
								account.
								<fo:block>
									<xsl:text>&#xA0;</xsl:text>
								</fo:block>
								<fo:inline font-weight="bold">
									<xsl:text>Late Payment Charge:</xsl:text>
								</fo:inline>
								A late payment charge may apply for unpaid/past due invoices, this charge
								will be applied on the following billing cycle and will be equal to 1.5% of the total outstanding balance.
								<fo:block>
									<xsl:text>&#xA0;</xsl:text>
								</fo:block>
								<fo:inline font-weight="bold">
									<xsl:text>Payment Methods</xsl:text>
								</fo:inline>

								For payment related questions, please feel free to contact us at 1 (888) 290 0488 or
								<fo:inline>
									<fo:basic-link external-destination="url('mailto:Invoices@SingleSource.Services')" color="blue" text-decoration="underline">
             Invoices@SingleSource.Services.
									</fo:basic-link>
								</fo:inline>
								<fo:block>
									<xsl:text>&#xA0;</xsl:text>
								</fo:block>
							</fo:block>
							<xsl:call-template name="Payment_Slip" />
						</fo:block>
					</fo:block>
				</fo:flow>
			</fo:page-sequence>
			<fo:page-sequence master-reference="default-page">
				<fo:static-content flow-name="xsl-region-after" font-size="7pt" font-family="{$font_family}" color="{$heading_font}">
					<fo:block>
						<fo:table>
							<fo:table-column column-width="100%" />
							<fo:table-body>
								<fo:table-row>
									<fo:table-cell>
										<fo:block>
											<xsl:value-of select="/invoice/footer" disable-output-escaping="yes" />
										</fo:block>
									</fo:table-cell>
								</fo:table-row>
							</fo:table-body>
						</fo:table>
					</fo:block>
					<fo:block text-align="left">
						<fo:inline padding-left= "5px">
							<xsl:value-of select="/invoice/remitTo/sellerName" />
							<xsl:text> Invoice #</xsl:text>
							<xsl:value-of select="/invoice/invoiceNumber" />
						</fo:inline>
					</fo:block>
					<fo:block text-align="right" padding-right= "8px">
						<fo:inline padding-bottom="10px">
							<fo:page-number />
						</fo:inline>
					</fo:block>
				</fo:static-content>
				<fo:flow flow-name="xsl-region-body">
					<fo:block font-weight="normal">
						<fo:block>
							<xsl:call-template name="space" />
							<fo:block font-family="{$font_family}" font-size="10px" color="#393536" font-weight="bold" margin-left="2px">
								<xsl:text>Location Based Summary</xsl:text>
							</fo:block>
							<xsl:call-template name="summary_grpByAddress_WithTaxSeparate_OuterTemplate" />
						</fo:block>
						<xsl:if test="/invoice/invoiceElements/lineItems">
							<xsl:call-template name="space" />
							<xsl:call-template name="ChargeSummary_Detailed_Template" />
							<xsl:call-template name="space" />
						</xsl:if>
						<!-- Account Hierarchy -->
						<!-- Non-Recurring charges -->
						<xsl:call-template name="space" />
						<fo:block>

							<xsl:for-each select="/invoice/accountInvoiceElements">
								<fo:block font-family="{$font_family}" font-size="10px" color="#393536" font-weight="bold" margin-left="2px">
									<xsl:text>Charge Details</xsl:text>
								</fo:block>
								<fo:block>
									<xsl:call-template name="accountNumber_Template" />
								</fo:block>
								<xsl:for-each select="accountInvoiceElements">
									<xsl:call-template name="shippingAddId_Template" />
									<xsl:if test="count(invoiceElements/lineItems[eventType='Onetime' or bundleLineItem/eventType='Onetime']) >0">

										<fo:block>
											<fo:block font-family="{$font_family}" font-size="10px" color="#393536" font-weight="bold">
												<xsl:text>Non-Recurring Charges (NRC)</xsl:text>
											</fo:block>
											<fo:block>
												<fo:table width="100%" border-style="none" font-family="{$font_family}" font-size="10px">
													<fo:table-column column-width="20%" />
													<fo:table-column column-width="40%" />
													<fo:table-column column-width="14%" />
													<fo:table-column column-width="14%" />
													<fo:table-column column-width="12%" />
													<fo:table-header font-weight="bold">
														<fo:table-row>
															<fo:table-cell background-repeat="repeat" background-color="{$bkgrnd_clr}" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px">
																<fo:block font-weight="bold" font-size="8px" color="{$heading_font}">
																	<xsl:text>Charge Date
																	</xsl:text>
																</fo:block>
															</fo:table-cell>
															<fo:table-cell background-color="{$bkgrnd_clr}" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px">
																<fo:block font-weight="bold" font-size="8px" color="{$heading_font}">
																	<xsl:text>Product Detail
																	</xsl:text>
																</fo:block>
															</fo:table-cell>
															<fo:table-cell background-color="{$bkgrnd_clr}" padding-bottom="3px" padding-top="3px">
																<fo:block font-weight="bold" font-size="8px" color="{$heading_font}" text-align="right">
																	<xsl:text>Qty
																	</xsl:text>
																</fo:block>
															</fo:table-cell>
															<fo:table-cell background-color="{$bkgrnd_clr}" padding-bottom="3px" padding-top="3px" padding-right="18px">
																<fo:block font-weight="bold" font-size="8px" color="{$heading_font}" text-align="right">
																	<xsl:text>Unit Price</xsl:text>
																</fo:block>
															</fo:table-cell>
															<fo:table-cell background-color="{$bkgrnd_clr}" padding-bottom="3px" padding-top="3px" padding-right="3px">
																<fo:block font-weight="bold" font-size="8px" color="{$heading_font}" text-align="right" padding-right="3px">
																	<xsl:text>Total</xsl:text>
																</fo:block>
															</fo:table-cell>
														</fo:table-row>
													</fo:table-header>

													<fo:table-body>
														<xsl:if test="count(invoiceElements/lineItems[eventType='Onetime' and not(bundleLineItem)]) >0">
															<xsl:for-each select="invoiceElements/lineItems [eventType='Onetime' and not(bundleLineItem) and amount != 0]">

																<xsl:sort select="substring(startDate,7,4)" order="descending"/>
																<xsl:sort select="substring(startDate,1,2)" order="descending"/>
																<xsl:sort select="substring(startDate,4,2)" order="descending"/>
																<!-- <xsl:if test="subscriptionIdentifier"> -->
																<xsl:if test="not(usageLineItem)">
																	<xsl:if test="not(usageLineItem)">
																		<fo:table-row>
																			<xsl:variable name="accLineItems" select="." />
																			<fo:table-cell background-color="{$table_bkgrnd_clr}" background-repeat="repeat" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px" display-align="center">
																				<fo:block color="#000000" font-size="8px">
																					<xsl:value-of select="startDate" />
																				</fo:block>
																			</fo:table-cell>
																			<fo:table-cell background-color="{$table_bkgrnd_clr}" background-repeat="repeat" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px">
																				<fo:block>
																					<fo:inline font-weight="bold" font-size="8px" text-align="right">
																						<xsl:value-of select="chargeType" />
																					</fo:inline>
																				</fo:block>
																			</fo:table-cell>
																			<fo:table-cell background-color="{$table_bkgrnd_clr}" background-repeat="repeat" padding-bottom="3px" padding-top="3px" padding-left="9px">
																				<fo:block color="#000000" font-size="8px" text-align="right">
																					<xsl:value-of select="concat(' ',format-number(unRoundedQuantity,'###0.0000'))" />
																				</fo:block>
																			</fo:table-cell>
																			<fo:table-cell background-color="{$table_bkgrnd_clr}" background-repeat="repeat" padding-bottom="3px" padding-right="20px" padding-top="3px">
																				<fo:block color="#000000" font-size="8px" text-align="right">
																					<xsl:call-template name="format_Currency">
																						<xsl:with-param name="value">
																							<xsl:value-of select="unitPrice" />
																						</xsl:with-param>
																					</xsl:call-template>
																				</fo:block>
																			</fo:table-cell>
																			<fo:table-cell background-color="{$table_bkgrnd_clr}" background-repeat="repeat" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px">
																				<xsl:choose>
																					<xsl:when test="totalAmount">
																						<fo:block color="#000000" font-size="8px" text-align='end'>
																							<xsl:choose>
																								<xsl:when test="totalAmount >= 0">
																									<xsl:value-of select="concat(' ',/invoice/currency,format-number(totalAmount,'#,##0.00','dollar'))" />
																								</xsl:when>
																								<xsl:otherwise>
																									<xsl:value-of select="concat(' ',/invoice/currency,format-number(totalAmount*-1,'#,##0.00','dollar'),' ',$credit)" />
																								</xsl:otherwise>
																							</xsl:choose>
																						</fo:block>
																					</xsl:when>
																					<xsl:otherwise>
																						<fo:block color="#000000" font-size="8px" text-align='end'>
																							<xsl:choose>
																								<xsl:when test="totalAmount >= 0">
																									<xsl:value-of select="concat(' ',/invoice/currency,format-number(totalAmount,'#,##0.00','dollar'))" />
																								</xsl:when>
																								<xsl:otherwise>
																									<xsl:value-of select="concat(' ',/invoice/currency,format-number(totalAmount*-1,'#,##0.00','dollar'),' ',$credit)" />
																								</xsl:otherwise>
																							</xsl:choose>
																						</fo:block>
																					</xsl:otherwise>
																				</xsl:choose>
																			</fo:table-cell>

																		</fo:table-row>

																	</xsl:if>
																</xsl:if>

															</xsl:for-each>
														</xsl:if>
														<xsl:if test="count(invoiceElements/lineItems/bundleLineItem[eventType='Onetime']) >0">
															<xsl:for-each select="invoiceElements/lineItems/bundleLineItem [eventType='Onetime' and amount != 0]">

																<xsl:sort select="substring(startDate,7,4)" order="descending"/>
																<xsl:sort select="substring(startDate,1,2)" order="descending"/>
																<xsl:sort select="substring(startDate,4,2)" order="descending"/>
																<!-- <xsl:if test="subscriptionIdentifier"> -->
																<xsl:if test="not(usageLineItem)">
																	<xsl:if test="not(usageLineItem)">
																		<fo:table-row>
																			<xsl:variable name="accLineItems" select="." />
																			<fo:table-cell background-color="{$table_bkgrnd_clr}" background-repeat="repeat" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px" display-align="center">
																				<fo:block color="#5F5F5F" font-size="8px">
																					<xsl:value-of select="startDate" />
																				</fo:block>
																			</fo:table-cell>
																			<fo:table-cell background-color="{$table_bkgrnd_clr}" background-repeat="repeat" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px">
																				<fo:block>
																					<fo:inline font-weight="bold" font-size="8px" text-align="right">
																						<xsl:value-of select="planDescription" />
																					</fo:inline>
																				</fo:block>
																			</fo:table-cell>
																			<fo:table-cell background-color="{$table_bkgrnd_clr}" background-repeat="repeat" padding-bottom="3px" padding-top="3px" padding-left="9px">
																				<fo:block color="{$heading_font}" font-size="8px" text-align="right">
																					<xsl:value-of select="concat(' ',format-number(unRoundedQuantity,'###0.0000'))" />
																				</fo:block>
																			</fo:table-cell>
																			<fo:table-cell background-color="{$table_bkgrnd_clr}" background-repeat="repeat" padding-bottom="3px" padding-right="20px" padding-top="3px">
																				<fo:block color="{$heading_font}" font-size="8px" text-align="right">
																					<xsl:call-template name="format_Currency">
																						<xsl:with-param name="value">
																							<xsl:value-of select="unitPrice" />
																						</xsl:with-param>
																					</xsl:call-template>
																				</fo:block>
																			</fo:table-cell>
																			<fo:table-cell background-color="{$table_bkgrnd_clr}" background-repeat="repeat" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px">
																				<xsl:choose>
																					<xsl:when test="totalAmount">
																						<fo:block color="#5F5F5F" font-size="8px" text-align='end'>
																							<xsl:choose>
																								<xsl:when test="totalAmount >= 0">
																									<xsl:value-of select="concat(' ',/invoice/currency,format-number(totalAmount,'#,##0.00','dollar'))" />
																								</xsl:when>
																								<xsl:otherwise>
																									<xsl:value-of select="concat(' ',/invoice/currency,format-number(totalAmount*-1,'#,##0.00','dollar'),' ',$credit)" />
																								</xsl:otherwise>
																							</xsl:choose>
																						</fo:block>
																					</xsl:when>
																					<xsl:otherwise>
																						<fo:block color="#5F5F5F" font-size="8px" text-align='end'>
																							<xsl:choose>
																								<xsl:when test="totalAmount >= 0">
																									<xsl:value-of select="concat(' ',/invoice/currency,format-number(totalAmount,'#,##0.00','dollar'))" />
																								</xsl:when>
																								<xsl:otherwise>
																									<xsl:value-of select="concat(' ',/invoice/currency,format-number(totalAmount*-1,'#,##0.00','dollar'),' ',$credit)" />
																								</xsl:otherwise>
																							</xsl:choose>
																						</fo:block>
																					</xsl:otherwise>
																				</xsl:choose>
																			</fo:table-cell>

																		</fo:table-row>

																	</xsl:if>
																</xsl:if>

															</xsl:for-each>
														</xsl:if>
														<fo:table-row>
															<fo:table-cell number-columns-spanned="4" background-repeat="repeat" display-align="center" text-align="end" padding-bottom="5px" padding-right="3px" padding-left="3px" padding-top="5px" background-color="{$bkgrnd_clr}">
																<fo:block color="{$heading_font}" font-size="8px" text-align='end'>
																	<xsl:text>Non-Recurring Total
																	</xsl:text>
																</fo:block>
															</fo:table-cell>
															<fo:table-cell background-repeat="repeat" display-align="center" text-align="right" padding-bottom="3px" padding-left="3px" padding-right="5px" padding-top="3px" background-color="{$bkgrnd_clr}">
																<fo:block color="{$heading_font}" font-size="8px">
																	<!--xsl:value-of select="totalAmount" / -->
																	<xsl:call-template name="format_Currency">
																		<xsl:with-param name="value">
																			<xsl:value-of select="sum(invoiceElements/lineItems[eventType = 'Onetime']/totalAmount) + sum(invoiceElements/lineItems/bundleLineItem[eventType = 'Onetime']/totalAmount)" />
																		</xsl:with-param>
																	</xsl:call-template>
																</fo:block>
															</fo:table-cell>
														</fo:table-row>

													</fo:table-body>
												</fo:table>
											</fo:block>
										</fo:block>
									</xsl:if>
									<xsl:call-template name="space" />
									<!-- Monthly Recurring Charges -->
									<fo:block>
										<xsl:if test="count(invoiceElements/lineItems[eventType='Recurring' or bundleLineItem/eventType='Recurring'] ) >0">
											<fo:block>

												<fo:block font-family="{$font_family}" font-size="10px" color="#393536" font-weight="bold">
										Monthly Recurring Charges (MRC)
												</fo:block>
												<fo:block>
													<fo:table width="100%" border-style="none" font-family="{$font_family}" font-size="10px">
														<fo:table-column column-width="20%" />
														<fo:table-column column-width="40%" />
														<fo:table-column column-width="14%" />
														<fo:table-column column-width="14%" />
														<fo:table-column column-width="12%" />
														<fo:table-header font-weight="bold">
															<fo:table-row>
																<fo:table-cell background-repeat="repeat" background-color="{$bkgrnd_clr}" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px">
																	<fo:block font-weight="bold" font-size="8px" color="{$heading_font}">
																		<xsl:text>Charge Date
																		</xsl:text>
																	</fo:block>
																</fo:table-cell>
																<fo:table-cell background-color="{$bkgrnd_clr}" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px">
																	<fo:block font-weight="bold" font-size="8px" color="{$heading_font}">
																		<xsl:text>Product Detail
																		</xsl:text>
																	</fo:block>
																</fo:table-cell>
																<fo:table-cell background-color="{$bkgrnd_clr}" padding-bottom="3px" padding-top="3px">
																	<fo:block font-weight="bold" font-size="8px" color="{$heading_font}" text-align="right">
																		<xsl:text>Qty
																		</xsl:text>
																	</fo:block>
																</fo:table-cell>
																<fo:table-cell background-color="{$bkgrnd_clr}" padding-bottom="3px" padding-top="3px" padding-right="18px">
																	<fo:block font-weight="bold" font-size="8px" color="{$heading_font}" text-align="right">
																		<xsl:text>Unit Price</xsl:text>
																	</fo:block>
																</fo:table-cell>
																<fo:table-cell background-color="{$bkgrnd_clr}" padding-bottom="3px" padding-top="3px">
																	<fo:block font-weight="bold" font-size="8px" color="{$heading_font}" text-align="right" padding-right="3px">
																		<xsl:text>Monthly Total
																		</xsl:text>
																	</fo:block>
																</fo:table-cell>
															</fo:table-row>
														</fo:table-header>

														<fo:table-body>
															<xsl:if test="count(invoiceElements/lineItems[eventType='Recurring' and not(bundleLineItem)]) >0">
																<xsl:for-each select="invoiceElements/lineItems [eventType='Recurring' and not(bundleLineItem) and amount != 0]">



																	<xsl:if test="not(usageLineItem)">
																		<xsl:if test="not(usageLineItem)">
																			<fo:table-row>
																				<xsl:variable name="accLineItems" select="." />
																				<fo:table-cell background-color="{$table_bkgrnd_clr}" background-repeat="repeat" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="1px" display-align="center">
																					<fo:block color="#000000" font-size="8px">
																						<xsl:value-of select="concat(startDate, '-', endDate)" />
																					</fo:block>
																				</fo:table-cell>
																				<fo:table-cell background-color="{$table_bkgrnd_clr}" background-repeat="repeat" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px">
																					<fo:block>
																						<fo:inline font-weight="bold" font-size="8px" text-align="right">
																							<xsl:value-of select="chargeType" />
																						</fo:inline>
																					</fo:block>
																					<!--<xsl:call-template name="usage_Summary_Template" />-->
																					<xsl:call-template name="discount_Template" />

																				</fo:table-cell>
																				<fo:table-cell background-color="{$table_bkgrnd_clr}" background-repeat="repeat" padding-bottom="3px" padding-top="3px" padding-left="9px">
																					<fo:block color="#000000" font-size="8px" text-align="right">
																						<xsl:value-of select="concat(' ',format-number(unRoundedQuantity,'###0.0000'))" />
																					</fo:block>
																				</fo:table-cell>
																				<fo:table-cell background-color="{$table_bkgrnd_clr}" background-repeat="repeat" padding-bottom="3px" padding-right="20px" padding-top="3px">
																					<fo:block color="#000000" font-size="8px" text-align="right">
																						<xsl:call-template name="format_Currency">
																							<xsl:with-param name="value">
																								<xsl:value-of select="unitPrice" />
																							</xsl:with-param>
																						</xsl:call-template>
																					</fo:block>
																				</fo:table-cell>
																				<fo:table-cell background-color="{$table_bkgrnd_clr}" background-repeat="repeat" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px">
																					<xsl:choose>
																						<xsl:when test="totalAmount">
																							<fo:block color="#000000" font-size="8px" text-align='end'>
																								<xsl:choose>
																									<xsl:when test="totalAmount >= 0">
																										<xsl:value-of select="concat(' ',/invoice/currency,format-number(totalAmount,'#,##0.00','dollar'))" />
																									</xsl:when>
																									<xsl:otherwise>
																										<xsl:value-of select="concat(' ',/invoice/currency,format-number(totalAmount*-1,'#,##0.00','dollar'),' ',$credit)" />
																									</xsl:otherwise>
																								</xsl:choose>
																							</fo:block>
																						</xsl:when>
																						<xsl:otherwise>
																							<fo:block color="#000000" font-size="8px" text-align='end'>
																								<xsl:choose>
																									<xsl:when test="totalAmount >= 0">
																										<xsl:value-of select="concat(' ',/invoice/currency,format-number(totalAmount,'#,##0.00','dollar'))" />
																									</xsl:when>
																									<xsl:otherwise>
																										<xsl:value-of select="concat(' ',/invoice/currency,format-number(totalAmount*-1,'#,##0.00','dollar'),' ',$credit)" />
																									</xsl:otherwise>
																								</xsl:choose>
																							</fo:block>
																						</xsl:otherwise>
																					</xsl:choose>
																				</fo:table-cell>
																			</fo:table-row>
																		</xsl:if>
																	</xsl:if>
																</xsl:for-each>


															</xsl:if>

															<xsl:if test="count(invoiceElements/lineItems/bundleLineItem[eventType='Recurring']) >0">
																<xsl:for-each select="invoiceElements/lineItems/bundleLineItem [eventType='Recurring' and amount != 0]">

																	<xsl:sort select="substring(startDate,7,4)" order="descending"/>
																	<xsl:sort select="substring(startDate,1,2)" order="descending"/>
																	<xsl:sort select="substring(startDate,4,2)" order="descending"/>
																	<!-- <xsl:if test="subscriptionIdentifier"> -->
																	<xsl:if test="not(usageLineItem)">
																		<xsl:if test="not(usageLineItem)">
																			<fo:table-row>
																				<xsl:variable name="accLineItems" select="." />
																				<fo:table-cell background-color="{$table_bkgrnd_clr}" background-repeat="repeat" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="1px" display-align="center">
																					<fo:block color="#5F5F5F" font-size="8px">
																						<xsl:value-of select="concat(startDate, '-', endDate)" />
																					</fo:block>
																				</fo:table-cell>
																				<fo:table-cell background-color="{$table_bkgrnd_clr}" background-repeat="repeat" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px">
																					<fo:block>
																						<fo:inline font-weight="bold" font-size="8px" text-align="right">
																							<xsl:value-of select="planDescription" />
																						</fo:inline>
																					</fo:block>
																				</fo:table-cell>
																				<fo:table-cell background-color="{$table_bkgrnd_clr}" background-repeat="repeat" padding-bottom="3px" padding-top="3px" padding-left="9px">
																					<fo:block color="{$heading_font}" font-size="8px" text-align="right">
																						<xsl:value-of select="concat(' ',format-number(unRoundedQuantity,'###0.0000'))" />
																					</fo:block>
																				</fo:table-cell>
																				<fo:table-cell background-color="{$table_bkgrnd_clr}" background-repeat="repeat" padding-bottom="3px" padding-right="20px" padding-top="3px">
																					<fo:block color="{$heading_font}" font-size="8px" text-align="right">
																						<xsl:call-template name="format_Currency">
																							<xsl:with-param name="value">
																								<xsl:value-of select="unitPrice" />
																							</xsl:with-param>
																						</xsl:call-template>
																					</fo:block>
																				</fo:table-cell>
																				<fo:table-cell background-color="{$table_bkgrnd_clr}" background-repeat="repeat" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px">
																					<xsl:choose>
																						<xsl:when test="totalAmount">
																							<fo:block color="#5F5F5F" font-size="8px" text-align='end'>
																								<xsl:choose>
																									<xsl:when test="totalAmount >= 0">
																										<xsl:value-of select="concat(' ',/invoice/currency,format-number(totalAmount,'#,##0.00','dollar'))" />
																									</xsl:when>
																									<xsl:otherwise>
																										<xsl:value-of select="concat(' ',/invoice/currency,format-number(totalAmount*-1,'#,##0.00','dollar'),' ',$credit)" />
																									</xsl:otherwise>
																								</xsl:choose>
																							</fo:block>
																						</xsl:when>
																						<xsl:otherwise>
																							<fo:block color="#5F5F5F" font-size="8px" text-align='end'>
																								<xsl:choose>
																									<xsl:when test="totalAmount >= 0">
																										<xsl:value-of select="concat(' ',/invoice/currency,format-number(totalAmount,'#,##0.00','dollar'))" />
																									</xsl:when>
																									<xsl:otherwise>
																										<xsl:value-of select="concat(' ',/invoice/currency,format-number(totalAmount*-1,'#,##0.00','dollar'),' ',$credit)" />
																									</xsl:otherwise>
																								</xsl:choose>
																							</fo:block>
																						</xsl:otherwise>
																					</xsl:choose>
																				</fo:table-cell>
																			</fo:table-row>

																		</xsl:if>
																	</xsl:if>
																</xsl:for-each>
															</xsl:if>
															<fo:table-row>
																<fo:table-cell number-columns-spanned="4" background-repeat="repeat" display-align="center" text-align="end" padding-bottom="5px" padding-right="3px" padding-left="3px" padding-top="5px" background-color="{$bkgrnd_clr}">
																	<fo:block color="#000000" font-size="8px" font-weight="bold" text-align='end'>
																		<xsl:text>Monthly Recurring Total
																		</xsl:text>
																	</fo:block>
																</fo:table-cell>
																<fo:table-cell background-repeat="repeat" display-align="center" text-align="right" padding-bottom="3px" padding-left="3px" padding-right="5px" padding-top="3px" background-color="{$bkgrnd_clr}">
																	<fo:block color="#000000" font-size="8px" font-weight="bold">
																		<!--xsl:value-of select="totalAmount" / -->
																		<xsl:call-template name="format_Currency">
																			<xsl:with-param name="value">

																				<xsl:value-of select="sum(invoiceElements/lineItems[eventType = 'Recurring']/totalAmount) + sum(invoiceElements/lineItems/bundleLineItem[eventType = 'Recurring']/totalAmount)" />
																			</xsl:with-param>
																		</xsl:call-template>
																	</fo:block>
																</fo:table-cell>
															</fo:table-row>
														</fo:table-body>
													</fo:table>
												</fo:block>
											</fo:block>
										</xsl:if>
									</fo:block>
									<xsl:call-template name="space" />
									<!--Usage Summary Start -->
									<xsl:if test="sum(invoiceElements/lineItems[(usageLineItem) and not(bundleLineItem)]/totalAmount) !=0">
										<xsl:call-template name="space"/>
										<fo:block font-family="{$font_family}" font-size="10px" color="#393536" font-weight="bold">
											<xsl:text>Usage Summary</xsl:text>
										</fo:block>
										<fo:block>
											<fo:table width="100%" border-style="none" font-family="Verdana, Arial, Helvetica, sans-serif" font-size="10px">
												<fo:table-column column-width="33%" />
												<fo:table-column column-width="33%" />
												<fo:table-column column-width="34%" />
												<fo:table-header font-weight="bold">

													<fo:table-row>
														<fo:table-cell background-color="#E5E5E5" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px">
															<fo:block font-weight="bold" font-size="8px" color="#5F5F5F">
																<xsl:text>DID / User</xsl:text>
															</fo:block>
														</fo:table-cell>
														<fo:table-cell background-color="#E5E5E5" padding-bottom="3px" padding-left="15px" padding-right="0px" padding-top="3px" text-align="right">
															<fo:block font-weight="bold" font-size="8px" color="#5F5F5F">
																<xsl:text>Quantity</xsl:text>
															</fo:block>
														</fo:table-cell>
														<fo:table-cell background-color="#E5E5E5" text-align="end" padding-bottom="3px" padding-left="3px" padding-right="5px" padding-top="3px">
															<fo:block font-weight="bold" font-size="8px" color="#5F5F5F">
																<xsl:text>Charge</xsl:text>
															</fo:block>
														</fo:table-cell>
													</fo:table-row>

												</fo:table-header>
												<fo:table-body>
													<xsl:for-each select="invoiceElements/lineItems[count(. | key('addressLineItems-by-subscriptionIdentifier', concat(subscriptionIdentifier,../../shippingAddId, ../../../accountId))[1])=1]">
														<xsl:sort select="subscriptionIdentifier"/>
														<xsl:if test="subscriptionIdentifier">
															<xsl:if test="count(key('addressLineItems-by-subscriptionIdentifier', concat(subscriptionIdentifier,../../shippingAddId, ../../../accountId))/usageLineItem[summary='false'])>0">
																<xsl:if test="count(key('addressLineItems-by-subscriptionIdentifier', concat(subscriptionIdentifier,../../shippingAddId, ../../../accountId))/usageLineItem/lstLineItems[amount>0])>0">
																	<fo:table-row>
																		<xsl:variable name="accLineItems" select="." />
																		<fo:table-cell>
																			<fo:block>
																				<fo:inline font-size="8px" color="#5F5F5F" padding-left="3px">
																					<xsl:value-of select="subscriptionIdentifier" />
																				</fo:inline>
																			</fo:block>
																		</fo:table-cell>


																		<fo:table-cell>
																			<fo:block>
																				<xsl:variable name="totalseconds" select="sum(key('addressLineItems-by-subscriptionIdentifier', concat(subscriptionIdentifier,../../shippingAddId, ../../../accountId))/usageLineItem/lstLineItems[amount>0]/unRoundedQuantity)" />
																				<fo:block font-size="8px" text-align="right">
																					<fo:block color="#5F5F5F" font-size="8px">

																						<fo:inline color="#5F5F5F">

																							<xsl:value-of select="format-number($totalseconds,'#,##0')" />

																						</fo:inline>

																					</fo:block>

																				</fo:block>
																			</fo:block>
																		</fo:table-cell>
																		<fo:table-cell background-repeat="repeat" text-align="right" padding-bottom="3px" padding-left="3px" padding-right="5px" padding-top="0px">
																			<fo:block color="#5F5F5F" font-size="8px" text-align='end'>
																				<xsl:choose>
																					<xsl:when test="totalAmount >= 0">
																						<xsl:value-of select="concat(' ',/invoice/currency,format-number(sum(key('addressLineItems-by-subscriptionIdentifier', concat(subscriptionIdentifier,../../shippingAddId, ../../../accountId))/totalAmount),'#,##0.00','dollar'))" />
																					</xsl:when>
																					<xsl:otherwise>
																						<xsl:value-of select="concat(' ',/invoice/currency,format-number(sum(key('addressLineItems-by-subscriptionIdentifier', concat(subscriptionIdentifier,../../shippingAddId, ../../../accountId))/totalAmount)*-1,'#,##0.00','dollar'),' ',$credit)" />
																					</xsl:otherwise>
																				</xsl:choose>
																			</fo:block>

																		</fo:table-cell>
																	</fo:table-row>
																</xsl:if>
															</xsl:if>
														</xsl:if>
														<xsl:if test="count(key('addressLineItems-by-subscriptionIdentifier', concat(subscriptionIdentifier,../../shippingAddId, ../../../accountId))/usageLineItem[summary='true'])>0">
															<xsl:if test="count(key('addressLineItems-by-subscriptionIdentifier', concat(subscriptionIdentifier,../../shippingAddId, ../../../accountId))/usageLineItem/lstLineItems[amount>0])>0">
																<fo:table-row>
																	<xsl:variable name="accLineItems" select="." />
																	<fo:table-cell>
																		<fo:block>
																			<fo:inline font-size="8px" color="#5F5F5F" padding-left="3px">
																				<xsl:value-of select="subscriptionIdentifier" />
																			</fo:inline>
																		</fo:block>
																	</fo:table-cell>


																	<fo:table-cell>
																		<fo:block>
																			<xsl:variable name="totalseconds" select="sum(key('addressLineItems-by-subscriptionIdentifier', concat(subscriptionIdentifier,../../shippingAddId, ../../../accountId))/usageLineItem/lstLineItems[amount>0]/unRoundedQuantity)" />
																			<fo:block font-size="8px" text-align="right">
																				<fo:block color="#5F5F5F" font-size="8px">

																					<fo:inline color="#5F5F5F">

																						<xsl:value-of select="format-number($totalseconds,'#,##0')" />

																					</fo:inline>

																				</fo:block>

																			</fo:block>
																		</fo:block>
																	</fo:table-cell>
																	<fo:table-cell background-repeat="repeat" text-align="right" padding-bottom="3px" padding-left="3px" padding-right="5px" padding-top="0px">
																		<fo:block color="#5F5F5F" font-size="8px" text-align='end'>
																			<xsl:choose>
																				<xsl:when test="totalAmount >= 0">
																					<xsl:value-of select="concat(' ',/invoice/currency,format-number(sum(key('addressLineItems-by-subscriptionIdentifier', concat(subscriptionIdentifier,../../shippingAddId, ../../../accountId))/totalAmount),'#,##0.00','dollar'))" />
																				</xsl:when>
																				<xsl:otherwise>
																					<xsl:value-of select="concat(' ',/invoice/currency,format-number(sum(key('addressLineItems-by-subscriptionIdentifier', concat(subscriptionIdentifier,../../shippingAddId, ../../../accountId))/totalAmount)*-1,'#,##0.00','dollar'),' ',$credit)" />
																				</xsl:otherwise>
																			</xsl:choose>
																		</fo:block>

																	</fo:table-cell>
																</fo:table-row>
															</xsl:if>
														</xsl:if>
													</xsl:for-each>
													<fo:table-row>
														<fo:table-cell background-repeat="repeat" display-align="center" text-align="end" padding-bottom="5px" padding-right="3px" padding-left="3px" padding-top="5px" background-color="{$bkgrnd_clr}">
															<fo:block color="#5F5F5F" font-size="8px" text-align='left'>
																<xsl:text>Total</xsl:text>
															</fo:block>
														</fo:table-cell>
														<fo:table-cell background-repeat="repeat" display-align="center" text-align="end" padding-bottom="5px" padding-right="3px" padding-left="3px" padding-top="5px" background-color="{$bkgrnd_clr}">
															<fo:block color="#5F5F5F" font-size="8px" text-align='end'>
																<xsl:text></xsl:text>
															</fo:block>
														</fo:table-cell>
														<fo:table-cell background-repeat="repeat" display-align="center" text-align="right" padding-bottom="3px" padding-left="3px" padding-right="5px" padding-top="3px" background-color="{$bkgrnd_clr}">
															<fo:block color="#5F5F5F" font-size="8px">
																<xsl:choose>
																	<xsl:when test="sum(invoiceElements/lineItems[usageLineItem and not(bundleLineItem)]/totalAmount) >= 0">
																		<xsl:value-of select="concat(' ',/invoice/currency,format-number(sum(invoiceElements/lineItems[usageLineItem and not(bundleLineItem)]/totalAmount),'#,##0.00','dollar'))" />
																	</xsl:when>
																	<xsl:otherwise>
																		<xsl:value-of select="concat(' ',/invoice/currency,format-number(sum(invoiceElements/lineItems[usageLineItem and not(bundleLineItem)]/totalAmount)*-1,'#,##0.00','dollar'),' ',$credit)" />
																	</xsl:otherwise>
																</xsl:choose>
															</fo:block>
														</fo:table-cell>
													</fo:table-row>
												</fo:table-body>
											</fo:table>
										</fo:block>
										<xsl:call-template name="space" />
									</xsl:if>

									<!-- Usage summary for Bundle -->
									<xsl:if test="sum(invoiceElements/lineItems[(usageLineItem) and bundleLineItem]/totalAmount) !=0">
										<xsl:call-template name="space"/>
										<fo:block font-family="{$font_family}" font-size="10px" color="#393536" font-weight="bold">
											<xsl:text>Usage Summary</xsl:text>
										</fo:block>
										<fo:block>
											<fo:table width="100%" border-style="none" font-family="Verdana, Arial, Helvetica, sans-serif" font-size="10px">
												<fo:table-column column-width="34%" />
												<fo:table-column column-width="33%" />
												<fo:table-column column-width="33%" />
												<fo:table-header font-weight="bold">

													<fo:table-row>
														<fo:table-cell background-color="#E5E5E5" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px">
															<fo:block font-weight="bold" font-size="8px" color="#5F5F5F">
																<xsl:text>DID / User</xsl:text>
															</fo:block>
														</fo:table-cell>
														<fo:table-cell background-color="#E5E5E5" padding-bottom="3px" padding-left="15px" padding-right="0px" padding-top="3px" text-align="right">
															<fo:block font-weight="bold" font-size="8px" color="#5F5F5F">
																<xsl:text>Quantity</xsl:text>
															</fo:block>
														</fo:table-cell>
														<fo:table-cell background-color="#E5E5E5" text-align="end" padding-bottom="3px" padding-left="3px" padding-right="5px" padding-top="3px">
															<fo:block font-weight="bold" font-size="8px" color="#5F5F5F">
																<xsl:text>Charge</xsl:text>
															</fo:block>
														</fo:table-cell>

													</fo:table-row>

												</fo:table-header>
												<fo:table-body>
													<xsl:for-each select="invoiceElements/lineItems[count(. | key('addressLineItems-by-bundleIdentifier', concat(bundleIdentifier,../../shippingAddId, ../../../accountId))[1])=1]">
														<xsl:sort select="bundleIdentifier"/>
														<xsl:if test="bundleIdentifier">
															<xsl:if test="count(key('addressLineItems-by-bundleIdentifier', concat(bundleIdentifier,../../shippingAddId, ../../../accountId))/usageLineItem[summary='false'])>0">
																<xsl:if test="count(key('addressLineItems-by-bundleIdentifier', concat(bundleIdentifier,../../shippingAddId, ../../../accountId))/usageLineItem/lstLineItems[amount>0])>0">
																	<fo:table-row>
																		<xsl:variable name="accLineItems" select="." />
																		<fo:table-cell>
																			<fo:block>
																				<fo:inline font-size="8px" color="#5F5F5F" padding-left="3px">
																					<xsl:value-of select="bundleIdentifier" />
																				</fo:inline>
																			</fo:block>
																		</fo:table-cell>


																		<fo:table-cell>
																			<fo:block>
																				<xsl:variable name="totalseconds" select="sum(key('addressLineItems-by-bundleIdentifier', concat(bundleIdentifier,../../shippingAddId, ../../../accountId))/usageLineItem/lstLineItems[amount>0]/unRoundedQuantity)" />
																				<fo:block font-size="8px" text-align="right">
																					<fo:block color="#5F5F5F" font-size="8px">

																						<fo:inline color="#5F5F5F">

																							<xsl:value-of select="format-number($totalseconds,'#,##0')" />

																						</fo:inline>

																					</fo:block>

																				</fo:block>
																			</fo:block>
																		</fo:table-cell>
																		<fo:table-cell background-repeat="repeat" text-align="right" padding-bottom="3px" padding-left="3px" padding-right="5px" padding-top="0px">
																			<fo:block color="#5F5F5F" font-size="8px" text-align='end'>
																				<xsl:choose>
																					<xsl:when test="totalAmount >= 0">
																						<xsl:value-of select="concat(' ',/invoice/currency,format-number(sum(key('addressLineItems-by-bundleIdentifier', concat(bundleIdentifier,../../shippingAddId, ../../../accountId))/totalAmount),'#,##0.00','dollar'))" />
																					</xsl:when>
																					<xsl:otherwise>
																						<xsl:value-of select="concat(' ',/invoice/currency,format-number(sum(key('addressLineItems-by-bundleIdentifier', concat(bundleIdentifier,../../shippingAddId, ../../../accountId))/totalAmount)*-1,'#,##0.00','dollar'),' ',$credit)" />
																					</xsl:otherwise>
																				</xsl:choose>
																			</fo:block>

																		</fo:table-cell>
																	</fo:table-row>
																</xsl:if>
															</xsl:if>
														</xsl:if>
														<xsl:if test="count(key('addressLineItems-by-bundleIdentifier', concat(bundleIdentifier,../../shippingAddId, ../../../accountId))/usageLineItem[summary='true'])>0">
															<xsl:if test="count(key('addressLineItems-by-bundleIdentifier', concat(bundleIdentifier,../../shippingAddId, ../../../accountId))/usageLineItem/lstLineItems[amount>0])>0">
																<fo:table-row>
																	<xsl:variable name="accLineItems" select="." />
																	<fo:table-cell>
																		<fo:block>
																			<fo:inline font-size="8px" color="#5F5F5F" padding-left="3px">
																				<xsl:value-of select="bundleIdentifier" />
																			</fo:inline>
																		</fo:block>
																	</fo:table-cell>


																	<fo:table-cell>
																		<fo:block>
																			<xsl:variable name="totalseconds" select="sum(key('addressLineItems-by-bundleIdentifier', concat(bundleIdentifier,../../shippingAddId, ../../../accountId))/usageLineItem/lstLineItems[amount>0]/unRoundedQuantity)" />
																			<fo:block font-size="8px" text-align="right">
																				<fo:block color="#5F5F5F" font-size="8px">

																					<fo:inline color="#5F5F5F">

																						<xsl:value-of select="format-number($totalseconds,'#,##0')" />

																					</fo:inline>

																				</fo:block>

																			</fo:block>
																		</fo:block>
																	</fo:table-cell>
																	<fo:table-cell background-repeat="repeat" text-align="right" padding-bottom="3px" padding-left="3px" padding-right="5px" padding-top="0px">
																		<fo:block color="#5F5F5F" font-size="8px" text-align='end'>
																			<xsl:choose>
																				<xsl:when test="totalAmount >= 0">
																					<xsl:value-of select="concat(' ',/invoice/currency,format-number(sum(key('addressLineItems-by-bundleIdentifier', concat(bundleIdentifier,../../shippingAddId, ../../../accountId))/totalAmount),'#,##0.00','dollar'))" />
																				</xsl:when>
																				<xsl:otherwise>
																					<xsl:value-of select="concat(' ',/invoice/currency,format-number(sum(key('addressLineItems-by-bundleIdentifier', concat(bundleIdentifier,../../shippingAddId, ../../../accountId))/totalAmount)*-1,'#,##0.00','dollar'),' ',$credit)" />
																				</xsl:otherwise>
																			</xsl:choose>
																		</fo:block>

																	</fo:table-cell>
																</fo:table-row>
															</xsl:if>
														</xsl:if>
													</xsl:for-each>
													<fo:table-row>
														<fo:table-cell background-repeat="repeat" display-align="center" text-align="end" padding-bottom="5px" padding-right="3px" padding-left="3px" padding-top="5px" background-color="{$bkgrnd_clr}">
															<fo:block color="#5F5F5F" font-size="8px" text-align='left'>
																<xsl:text>Total</xsl:text>
															</fo:block>
														</fo:table-cell>
														<fo:table-cell background-repeat="repeat" display-align="center" text-align="end" padding-bottom="5px" padding-right="3px" padding-left="3px" padding-top="5px" background-color="{$bkgrnd_clr}">
															<fo:block color="#5F5F5F" font-size="8px" text-align='end'>
																<xsl:text></xsl:text>
															</fo:block>
														</fo:table-cell>
														<fo:table-cell background-repeat="repeat" display-align="center" text-align="right" padding-bottom="3px" padding-left="3px" padding-right="5px" padding-top="3px" background-color="{$bkgrnd_clr}">
															<fo:block color="#5F5F5F" font-size="8px">
																<xsl:choose>
																	<xsl:when test="sum(invoiceElements/lineItems[(usageLineItem) and bundleLineItem]/totalAmount) >= 0">
																		<xsl:value-of select="concat(' ',/invoice/currency,format-number(sum(invoiceElements/lineItems[(usageLineItem) and bundleLineItem]/totalAmount),'#,##0.00','dollar'))" />
																	</xsl:when>
																	<xsl:otherwise>
																		<xsl:value-of select="concat(' ',/invoice/currency,format-number(sum(invoiceElements/lineItems[(usageLineItem) and bundleLineItem]/totalAmount)*-1,'#,##0.00','dollar'),' ',$credit)" />
																	</xsl:otherwise>
																</xsl:choose>
															</fo:block>
														</fo:table-cell>
													</fo:table-row>
												</fo:table-body>
											</fo:table>
										</fo:block>
										<xsl:call-template name="space" />
									</xsl:if>

									<!-- Usage Summary End -->
								</xsl:for-each>

							</xsl:for-each>

							<xsl:call-template name="space" />
							<xsl:if test="sum(invoice/.//accountInvoiceElements/invoiceElements/lineItems/taxAmount)">
								<fo:block font-family="{$font_family}" font-size="10px" color="#393536" font-weight="bold">
									<xsl:text>Taxes and Fees</xsl:text>
								</fo:block>
								<fo:table width="100%" border-style="none" font-family="{$font_family}" font-size="10px">
									<fo:table-column column-width="90%" />
									<fo:table-column column-width="10%" />
									<fo:table-header font-weight="bold">
										<fo:table-row>
											<fo:table-cell background-repeat="repeat" background-color="{$bkgrnd_clr}" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px" text-align="left">
												<fo:block font-weight="bold" font-size="8px" color="{$heading_font}">
													<xsl:text>Description</xsl:text>
												</fo:block>
											</fo:table-cell>
											<fo:table-cell background-repeat="repeat" background-color="{$bkgrnd_clr}" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px" text-align="end">
												<fo:block font-weight="bold" font-size="8px" color="{$heading_font}">
													<xsl:text>Amount</xsl:text>
												</fo:block>
											</fo:table-cell>
										</fo:table-row>
									</fo:table-header>
									<fo:table-body>
										<xsl:if test="sum(invoice/.//accountInvoiceElements/invoiceElements/lineItems/taxAmount)">


											<!-- I changed tax summary based on tax code (302)-->

											<xsl:for-each select=".//taxLineItem/lineItems [code=302]">
												<fo:table-row>
													<fo:table-cell background-color="{$table_bkgrnd_clr}" background-repeat="repeat" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px" display-align="center">
														<fo:block color="#000000" font-size="7px">
															<xsl:value-of select="description" />

														</fo:block>
													</fo:table-cell>
													<fo:table-cell background-color="{$table_bkgrnd_clr}" background-repeat="repeat" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px" display-align="center" text-align="end">
														<fo:block color="#000000" font-size="8px">
															<xsl:value-of select="concat(' ',/invoice/currency,format-number(sum(key('taxes-by-code', code)/taxAmount),'#,##0.00','dollar'))" />
														</fo:block>
													</fo:table-cell>
												</fo:table-row>
											</xsl:for-each>

										</xsl:if>
										<!-- Bill Time Charge -->
										<xsl:if test="//billTimeLineItems/chargeLineItem!=''">
											<xsl:for-each select="//billTimeLineItems/chargeLineItem">
												<fo:table-row>
													<fo:table-cell background-color="{$table_bkgrnd_clr}" background-repeat="repeat" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px" display-align="center">
														<fo:block color="#000000" font-size="7px">
															<xsl:value-of select="description"/>
														</fo:block>
													</fo:table-cell>
													<fo:table-cell background-color="{$table_bkgrnd_clr}" background-repeat="repeat" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px" display-align="center" text-align="end">
														<fo:block color="#000000" font-size="8px">
															<xsl:value-of select="concat(' ',/invoice/currency,format-number(amount,'#,##0.00','dollar'))" />
														</fo:block>
													</fo:table-cell>
												</fo:table-row>
											</xsl:for-each>
										</xsl:if>
										<!-- Bill Time Charge Ends-->

										<xsl:variable name="billTimeChargeTotal" select="sum(//billTimeLineItems/chargeLineItem/amount)" />

										<fo:table-row>
											<fo:table-cell background-repeat="repeat" display-align="center" text-align="end" padding-bottom="5px" padding-right="3px" padding-left="3px" padding-top="5px" background-color="{$bkgrnd_clr}">
												<fo:block color="#000000" font-size="8px" font-weight="bold" text-align='end'>
													<xsl:text>Total Tax Charges</xsl:text>
												</fo:block>
											</fo:table-cell>
											<fo:table-cell background-repeat="repeat" display-align="center" text-align="end" padding-bottom="5px" padding-right="3px" padding-left="3px" padding-top="5px" background-color="{$bkgrnd_clr}">
												<fo:block color="#000000" font-size="8px" font-weight="bold" text-align='end'>
													<xsl:choose>
														<xsl:when test="sum(invoice/.//accountInvoiceElements/invoiceElements/lineItems/bundleLineItem/taxAmount) !=0">
															<xsl:value-of select="concat(' ',/invoice/currency,format-number(sum(invoice/.//accountInvoiceElements/invoiceElements/lineItems[not(bundleLineItem)]/taxAmount) + sum(invoice/.//accountInvoiceElements/invoiceElements/lineItems/bundleLineItem/taxAmount) + $billTimeChargeTotal ,'#,##0.00','dollar'))" />
														</xsl:when>
														<xsl:otherwise>
															<xsl:value-of select="concat(' ',/invoice/currency,format-number(sum(invoice/.//accountInvoiceElements/invoiceElements/lineItems[not(bundleLineItem)]/taxAmount) + $billTimeChargeTotal,'#,##0.00','dollar'))" />
														</xsl:otherwise>
													</xsl:choose>
												</fo:block>
											</fo:table-cell>
										</fo:table-row>
									</fo:table-body>
								</fo:table>

							</xsl:if>
							<xsl:if test="/invoice/arEvents/paymentArEventItem or /invoice/arEvents/adjustmentArEventItem">
								<fo:block page-break-after="always">
								</fo:block>
							</xsl:if>
						</fo:block>

						<!-- start of AR Events -->

						<fo:block>
							<xsl:if test="/invoice/arEvents/paymentArEventItem">
								<xsl:call-template name="space" />
								<fo:block>
									<fo:block font-family="{$font_family}" font-size="10px" color="#393536" font-weight="bold">
										<xsl:text>Payment Transactions</xsl:text>
									</fo:block>
									<fo:table width="100%" border-style="none" font-family="{$font_family}" font-size="10px">
										<fo:table-column column-width="14%" />
										<fo:table-column column-width="45%" />
										<fo:table-column column-width="41%" />
										<fo:table-body>
											<fo:table-row>
												<fo:table-cell background-repeat="repeat" background-color="{$bkgrnd_clr}" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px">
													<fo:block font-weight="bold" font-size="8px" color="{$heading_font}">
														<xsl:text>Date</xsl:text>
													</fo:block>
												</fo:table-cell>
												<fo:table-cell background-color="{$bkgrnd_clr}" text-align="center" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px">
													<fo:block font-weight="bold" font-size="8px" color="{$heading_font}">
														<xsl:text>Details</xsl:text>
													</fo:block>
												</fo:table-cell>
												<fo:table-cell background-color="{$bkgrnd_clr}" text-align="end" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px">
													<fo:block font-weight="bold" font-size="8px" color="{$heading_font}">
														<xsl:text>Amount</xsl:text>
													</fo:block>
												</fo:table-cell>
											</fo:table-row>
										</fo:table-body>
									</fo:table>
								</fo:block>
								<fo:block>
									<xsl:for-each select="/invoice/arEvents/paymentArEventItem">
										<xsl:if test="eventName='PAYMENT_SUCCESS'">
											<fo:block>
												<fo:table width="100%" border-style="none" border-bottom="#FFFFFF 2px solid" font-family="{$font_family}" font-size="10px">
													<fo:table-column column-width="14%" />
													<fo:table-column column-width="45%" />
													<fo:table-column column-width="41%" />
													<fo:table-body>
														<fo:table-row>
															<xsl:variable name="paymentArEventItem" select="." />
															<fo:table-cell background-color="{$table_bkgrnd_clr}" background-repeat="repeat" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px">
																<fo:block color="{$heading_font}" font-size="8px">
																	<xsl:value-of select="date" />
																</fo:block>
															</fo:table-cell>
															<fo:table-cell background-color="{$table_bkgrnd_clr}" background-repeat="repeat" text-align="center" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px">
																<fo:block color="{$heading_font}" font-size="8px">
																	<xsl:value-of select="paymentMethod" />
																	<xsl:text>(</xsl:text>
																	<xsl:value-of select="paymentReceiptNumber" />
																	<xsl:text>)</xsl:text>
																</fo:block>
															</fo:table-cell>
															<fo:table-cell background-color="{$table_bkgrnd_clr}" background-repeat="repeat" text-align="end" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px">
																<fo:block color="{$heading_font}" font-size="8px">
																	<xsl:call-template name="format_Currency">
																		<xsl:with-param name="value">
																			<xsl:value-of select="amount" />
																		</xsl:with-param>
																	</xsl:call-template>
																</fo:block>
															</fo:table-cell>
														</fo:table-row>
													</fo:table-body>
												</fo:table>
											</fo:block>
										</xsl:if>
									</xsl:for-each>
								</fo:block>
								<fo:block>
									<xsl:for-each select="/invoice/arEvents/paymentReversalArEventItem">
										<xsl:if test="eventName='PAYMENT_REVERSAL'">
											<fo:block>
												<fo:table width="100%" border-style="none" border-bottom="#FFFFFF 2px solid" font-family="{$font_family}" font-size="10px">
													<fo:table-column column-width="14%" />
													<fo:table-column column-width="45%" />
													<fo:table-column column-width="41%" />
													<fo:table-body>
														<fo:table-row>
															<xsl:variable name="paymentReversalArEventItem" select="." />
															<fo:table-cell background-color="{$table_bkgrnd_clr}" background-repeat="repeat" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px">
																<fo:block color="{$heading_font}" font-size="8px">
																	<xsl:value-of select="date" />
																</fo:block>
															</fo:table-cell>
															<fo:table-cell background-color="{$table_bkgrnd_clr}" background-repeat="repeat" text-align="center" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px">
																<fo:block color="{$heading_font}" font-size="8px">
																	<xsl:text>REVERSED(</xsl:text>
																	<xsl:value-of select="paymentReceiptNumber" />
																	<xsl:text>)</xsl:text>
																</fo:block>
															</fo:table-cell>
															<fo:table-cell background-color="{$table_bkgrnd_clr}" background-repeat="repeat" text-align="end" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px">
																<fo:block color="{$heading_font}" font-size="8px">
																	<xsl:call-template name="format_Currency">
																		<xsl:with-param name="value">
																			<xsl:value-of select="amount" />
																		</xsl:with-param>
																	</xsl:call-template>
																</fo:block>
															</fo:table-cell>
														</fo:table-row>
													</fo:table-body>
												</fo:table>
											</fo:block>
										</xsl:if>
									</xsl:for-each>
								</fo:block>
								<fo:block>
									<fo:table width="100%" background-repeat="repeat">
										<fo:table-column column-width="85%" />
										<fo:table-column column-width="15%" />
										<fo:table-body>
											<fo:table-row>
												<fo:table-cell background-repeat="repeat" display-align="center" text-align="end" padding-bottom="5px" padding-right="3px" padding-left="3px" padding-top="5px" background-color="{$bkgrnd_clr}">
													<fo:block color="{$heading_font}" font-size="8px" text-align="end">
														<xsl:text>Total Payments</xsl:text>
													</fo:block>
												</fo:table-cell>
												<fo:table-cell background-repeat="repeat" display-align="center" text-align="right" padding-bottom="3px" padding-left="3px" padding-right="5px" padding-top="3px" background-color="{$bkgrnd_clr}">
													<fo:block color="{$heading_font}" font-size="8px">
														<xsl:call-template name="format_Currency">
															<xsl:with-param name="value">
																<xsl:value-of select="/invoice/arEvents/totalPayments" />
															</xsl:with-param>
														</xsl:call-template>
													</fo:block>
												</fo:table-cell>
											</fo:table-row>
										</fo:table-body>
									</fo:table>
								</fo:block>
							</xsl:if>
							<!--Bill Time Transactions-->

							<fo:block>
								<xsl:call-template name="bill_Time_Transactions" />
							</fo:block>

							<xsl:if test="/invoice/arEvents/adjustmentArEventItem">
								<fo:block>
									<xsl:text></xsl:text>
								</fo:block>
								<fo:block>
									<xsl:text></xsl:text>
								</fo:block>
								<fo:block>
									<fo:block>
										<xsl:text>&#xA0;</xsl:text>
									</fo:block>
									<fo:block font-family="{$font_family}" font-size="10px" color="#393536" font-weight="bold">
										<xsl:text>Adjustments</xsl:text>
									</fo:block>
									<fo:block>
										<xsl:text>&#xA0;</xsl:text>
									</fo:block>
									<fo:table width="100%" border-style="none" font-family="{$font_family}" font-size="10px">
										<fo:table-column column-width="20%" />
										<fo:table-column column-width="60%" />
										<fo:table-column column-width="20%" />
										<fo:table-body>
											<fo:table-row>
												<fo:table-cell background-repeat="repeat" background-color="{$bkgrnd_clr}" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px">
													<fo:block font-weight="bold" font-size="8px" color="{$heading_font}">
														<xsl:text>Date</xsl:text>
													</fo:block>
												</fo:table-cell>
												<fo:table-cell background-color="{$bkgrnd_clr}" text-align="left" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px">
													<fo:block font-weight="bold" font-size="8px" color="{$heading_font}">
														<xsl:text>Description</xsl:text>
													</fo:block>
												</fo:table-cell>
												<fo:table-cell background-color="{$bkgrnd_clr}" text-align="end" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px">
													<fo:block font-weight="bold" font-size="8px" color="{$heading_font}">
														<xsl:text>Amount</xsl:text>
													</fo:block>
												</fo:table-cell>
											</fo:table-row>
										</fo:table-body>
									</fo:table>
								</fo:block>
								<fo:block>
									<xsl:for-each select="/invoice/arEvents/adjustmentArEventItem">
										<fo:block>
											<fo:table width="100%" border-style="none" border-bottom="#FFFFFF 2px solid" font-family="{$font_family}" font-size="10px">
												<fo:table-column column-width="20%" />
												<fo:table-column column-width="60%" />
												<fo:table-column column-width="20%" />
												<fo:table-body>
													<fo:table-row>
														<xsl:variable name="adjustmentArEventItem" select="." />
														<fo:table-cell background-color="{$table_bkgrnd_clr}" background-repeat="repeat" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px">
															<fo:block color="{$heading_font}" font-size="8px">
																<xsl:value-of select="date" />
															</fo:block>
														</fo:table-cell>
														<fo:table-cell background-color="{$table_bkgrnd_clr}" background-repeat="repeat" text-align="left" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px">
															<fo:block color="{$heading_font}" font-size="8px">
																<xsl:value-of select="adjustmentDescription" />
															</fo:block>
														</fo:table-cell>
														<fo:table-cell background-color="{$table_bkgrnd_clr}" background-repeat="repeat" text-align="end" padding-bottom="3px" padding-left="3px" padding-right="3px" padding-top="3px">
															<fo:block color="{$heading_font}" font-size="8px">
																<xsl:call-template name="format_Currency">
																	<xsl:with-param name="value">
																		<xsl:value-of select="amount" />
																	</xsl:with-param>
																</xsl:call-template>
															</fo:block>
														</fo:table-cell>
													</fo:table-row>
												</fo:table-body>
											</fo:table>
										</fo:block>
									</xsl:for-each>
								</fo:block>
								<fo:block>
									<fo:table width="100%" background-repeat="repeat">
										<fo:table-column column-width="85%" />
										<fo:table-column column-width="15%" />
										<fo:table-body>
											<fo:table-row>
												<fo:table-cell background-repeat="repeat" display-align="center" text-align="end" padding-bottom="5px" padding-right="3px" padding-left="3px" padding-top="5px" background-color="{$bkgrnd_clr}">
													<fo:block color="{$heading_font}" font-size="8px" text-align="end">
														<xsl:text>Total Adjustments</xsl:text>
													</fo:block>
												</fo:table-cell>
												<fo:table-cell background-repeat="repeat" display-align="center" text-align="right" padding-bottom="3px" padding-left="3px" padding-right="5px" padding-top="3px" background-color="{$bkgrnd_clr}">
													<fo:block color="{$heading_font}" font-size="8px">
														<xsl:call-template name="format_Currency">
															<xsl:with-param name="value">
																<xsl:value-of select="/invoice/arEvents/totalAdjustments" />
															</xsl:with-param>
														</xsl:call-template>
													</fo:block>
												</fo:table-cell>
											</fo:table-row>
										</fo:table-body>
									</fo:table>
								</fo:block>
							</xsl:if>
						</fo:block>
						<!-- end of AR Events -->


						<fo:block>
							<xsl:text>&#xA0;</xsl:text>
						</fo:block>
					</fo:block>
					<fo:block id="last-page"></fo:block>
				</fo:flow>
			</fo:page-sequence>
			<xsl:for-each select="//invoiceElements[usagePresent = 1]">
				<xsl:if test="count(lineItems/usageLineItem/lstLineItems[amount!=0]) >0">
					<fo:page-sequence master-reference="Usage-Details">
						<fo:static-content flow-name="xsl-region-after" font-size="7pt" font-family="{$font_family}" color="{$heading_font}">
							<fo:block>
								<fo:table>
									<fo:table-column column-width="100%" />
									<fo:table-body>
										<fo:table-row>
											<fo:table-cell>
												<fo:block>
													<xsl:value-of select="/invoice/footer" disable-output-escaping="yes" />
												</fo:block>
											</fo:table-cell>
										</fo:table-row>
									</fo:table-body>
								</fo:table>
							</fo:block>
							<fo:block text-align="left">
								<fo:inline padding-left= "5px">
									<xsl:value-of select="/invoice/remitTo/sellerName" />
									<xsl:text> Invoice #</xsl:text>
									<xsl:value-of select="/invoice/invoiceNumber" />
								</fo:inline>
							</fo:block>
							<fo:block text-align="right" padding-right= "8px">
								<fo:inline padding-bottom="10px">
									<fo:page-number />
								</fo:inline>
							</fo:block>
						</fo:static-content>
						<fo:flow flow-name="xsl-region-body">
							<fo:block>
								<xsl:if test="/invoice/invoiceFormat">
									<xsl:if test="/invoice/invoiceElements/usagePresent = 1 or /invoice/accountInvoiceElements/accountInvoiceElements/invoiceElements/usagePresent = 1 or
								 /invoice/accountInvoiceElements/invoiceElements/usagePresent = 1">
										<fo:block font-family="{$font_family}" font-size="10px" color="#393536" font-weight="bold">
											<xsl:text>Usage Transaction Details</xsl:text>
										</fo:block>
									</xsl:if>
								</xsl:if>
							</fo:block>
							<!-- Added for detailed table in case of markup and metered -->
							<xsl:if test="/invoice/invoiceFormat">
								<xsl:if test="usagePresent = 1">
									<fo:block>
										<xsl:for-each select="lineItems">
											<!-- <xsl:if test="(description = 'Metered Charge') or (description = 'Markup Charge')"> -->
											<xsl:if test="usageLineItem">
												<xsl:call-template name="space" />
												<fo:block font-size="8px" color="{$heading_font}" font-weight="bold">
													<xsl:text>Subscription ID : </xsl:text>
													<fo:inline font-size="10px" color="{$heading_font}" font-weight="bold">
														<xsl:if test="subscriptionIdentifier">
															<xsl:value-of select="subscriptionIdentifier" />
														</xsl:if>
													</fo:inline>
												</fo:block>
												<xsl:call-template name="usageTransactionDetails_Template" />
											</xsl:if>
										</xsl:for-each>
									</fo:block>
								</xsl:if>
							</xsl:if>
						</fo:flow>
					</fo:page-sequence>
				</xsl:if>
			</xsl:for-each>
		</fo:root>
	</xsl:template>
</xsl:stylesheet>
