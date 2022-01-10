-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,08 Oct 2015>
-- Description:	<Description,,>
-- Call SP:		InsertSMSLog
-- =============================================
CREATE PROCEDURE [dbo].[InsertSMSLog]
    @ApiId NVARCHAR(50) ,
    @SMSFrom NVARCHAR(50) ,
    @SMSTo NVARCHAR(50) ,
    @SMSTimeStamp NVARCHAR(50) ,
    @SMSText NVARCHAR(MAX) ,
    @Charset NVARCHAR(50) ,
    @Udh NVARCHAR(500) ,
    @MoMsgId NVARCHAR(500) ,
    @IsReceived BIT
AS
    BEGIN
        INSERT  INTO dbo.SMSLog
                ( ApiId ,
                  SMSFrom ,
                  SMSTo ,
                  SMSTimeStamp ,
                  SMSText ,
                  Charset ,
                  udh ,
                  moMsgId ,
                  IsReceived ,
                  CreatedOn
	            )
        VALUES  ( @ApiId , -- ApiId - nvarchar(50)
                  @SMSFrom , -- SMSFrom - nvarchar(50)
                  @SMSTo , -- SMSTo - nvarchar(max)
                  @SMSTimeStamp , -- SMSTimeStamp - nvarchar(50)
                  @SMSText , -- SMSText - nvarchar(max)
                  @Charset , -- Charset - nvarchar(500)
                  @Udh , -- udh - nvarchar(500)
                  @MoMsgId , -- moMsgId - nvarchar(500)
                  @IsReceived , -- IsReceived - bit
                  GETDATE()  -- CreatedOn - datetime
	            );

        SELECT  SCOPE_IDENTITY() AS InsertedId;
    END;