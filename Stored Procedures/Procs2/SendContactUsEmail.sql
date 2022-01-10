-- =============================================
-- Author:		<Disha>
-- Create date: <1 Oct 2014>
-- Description:	<Send Client Support Email>
-- Call SP:		SendContactUsEmail 3
-- =============================================
CREATE PROCEDURE [dbo].[SendContactUsEmail] @Id BIGINT
AS
    BEGIN
        DECLARE @CustName NVARCHAR(100) ,
            @Mobile NVARCHAR(15) ,
            @Email NVARCHAR(100) ,
            @Comments NVARCHAR(MAX) ,
            @EmailBody NVARCHAR(MAX);
        SELECT  @CustName = CustomerName ,
                @Mobile = Mobile ,
                @Email = Email ,
                @Comments = Comment
        FROM    ContactUs
        WHERE   Id = @Id;
	
        SET @EmailBody = N'<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>Untitled Document</title>
</head>
<body>
    <div>
        <table width="1250" border="0" align="center" cellpadding="0" cellspacing="0" style="padding: 0px;    
    font-family: Verdana; font-size: 12px; color: #000000; line-height: 18px">
            <tr>
                <td>
                    <table width="100%" border="0" cellspacing="0" cellpadding="0">
                        <tr>
                            <td valign="top" align="left">
                                <table width="95%" cellspacing="0" cellpadding="0" border="0">
                                    <tbody>
                                        <tr>
                                            <td align="left">
                                                Dear Admin,
                                                <br />
                                                <br />
                                                Magnitude Gold: Mail for Client Support Request
                                                <br />
                                                <br />
                                                Name: ' + @CustName + '
                                                <br />
                                                <br />
                                                Phone: ' + @Mobile + '
                                                <br />
                                                <br />
                                                Email: ' + @Email + '
                                                <br />
                                                <br />
                                                Comments: ' + @Comments + '
                                                <br />
                                                <br />
                                                Note: This is an auto generated response. Please do not respond to this mail.
                                            </td>
                                        </tr>
                                    </tbody>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td align="left" valign="top">
                                <table width="95%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td height="15" align="left" valign="top" style="font-family: Verdana;
                                            font-size: 12px; color: #000000; font-weight: normal; line-height: 18px">
                                        </td>
                                    </tr>
                                    <tr>
                                        <td align="left" valign="top" style="font-family: Verdana; font-size: 12px;
                                            color: #000000; font-weight: normal; line-height: 18px">
                                            <span style="font-family: Verdana; font-size: 12px; color: #004E90;
                                                font-weight: bold; line-height: 18px">Thanks,<br />
                                                Magnitude Team</span>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td height="15" align="left" valign="top" style="font-family: Verdana;
                                            font-size: 12px; color: #000000; font-weight: normal; line-height: 18px">
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>    
                 <td  style="height: 65px; border-color: #28B3FF">    
                  <table width="100%" border="0" cellspacing="0" cellpadding="0">    
                   <tr>    
                    <td>    
                    </td>    
                    <td align="left">    
                     <img src="http://web.magnitudefb.com/content/image/logo-magnitude.png" style="margin: 5px 0px;" />    
                    </td>    
                    <td>    
                    </td>    
                   </tr>    
                  </table>    
                 </td>    
               </tr>    
                    </table>
                </td>
            </tr>
        </table>
    </div>
</body>
</html>';

	
	   
    

    END;