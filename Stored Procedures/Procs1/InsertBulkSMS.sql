-- =============================================
-- Author:		<Disha Patel>
-- Create date: <07-AUG-2015>
-- Description:	<Insert Bulk SMS in Pending SMS>
-- Call SP:		InsertBulkSMS
-- =============================================
CREATE PROCEDURE [dbo].[InsertBulkSMS]
    @MobileNo NVARCHAR(50) ,
    @SmsText NVARCHAR(2000) ,
    @AppUserId BIGINT ,
    @ActivityId BIGINT
AS
    BEGIN
        IF @MobileNo <> ''
            AND @MobileNo IS NOT NULL
            BEGIN
                INSERT  INTO dbo.PendingSMS
                        ( ModuleId ,
                          MobileNo ,
                          SMSText ,
                          IsSent ,
                          ScheduleDateTime ,
                          RefId ,
                          RefId1 ,
                          CreatedOn ,
                          CreatedBy 
				        )
                VALUES  ( 9 , -- ModuleId - bigint
                          @MobileNo , -- MobileNo - nvarchar(1000)
                          @SmsText , -- SMSText - nvarchar(1000)
                          0 , -- IsSent - bit
                          GETUTCDATE() ,
                          @ActivityId , -- RefId - bigint
                          0 ,
                          GETUTCDATE() , -- CreatedOn - datetime
                          @AppUserId -- CreatedBy - bigint
				        );

                SELECT  SCOPE_IDENTITY() AS InsertedId;
            END;                  
    END;