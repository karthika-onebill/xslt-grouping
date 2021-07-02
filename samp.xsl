<?xml version="1.0" ?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <!-- Based on TAX code grouping the data -->
    <xsl:key name="group-by-taxid" match="invoice/accountInvoiceElements/accountInvoiceElements/invoiceElements/lineItems/taxLineItem/lineItems" use="code" />
    <xsl:template match="/">
        <html>
            <head>
                <title>TAX INFORMATION</title>
            </head>
            <body>
                <center>
                    <h3>TAX INFORMATION</h3>

                    <table border="1px" cellspacing="15px" cellpadding="10px" style="border-collapse:collapse">
                        <tr>
                            <th>Tax Code</th>
                            <th>Description</th>

                            <th>oneTimeEvent</th>
                            <th> Tax Amount</th>

                        </tr>
                        <!-- here, I statically give taxcode - 302 value for grouping data -->
                        <xsl:for-each select="invoice/accountInvoiceElements/accountInvoiceElements/invoiceElements/lineItems/taxLineItem/lineItems[code=302]">
                            <tr>
                                <td>

                                    <xsl:value-of select="code"></xsl:value-of>
                                </td>
                                <td>
                                    <xsl:value-of select="description"></xsl:value-of>
                                </td>

                                <td>
                                    <xsl:value-of select="oneTimeEvent"></xsl:value-of>
                                </td>
                                <td>
                                    <xsl:value-of select="taxAmount"></xsl:value-of>
                                </td>

                            </tr>

                        </xsl:for-each>
                        <!-- print total tax amount -->
                        <tr>
                            <th colspan="3" style="text-align:end;">
                                <bold>Total Tax Amount   </bold>
                            </th>
                            <th>$                                <xsl:value-of select="sum(invoice/accountInvoiceElements/accountInvoiceElements/invoiceElements/lineItems/taxLineItem/lineItems[code=302]/taxAmount)" />
                            </th>
                        </tr>
                    </table>
                </center>
            </body>
        </html>
    </xsl:template>



</xsl:stylesheet>