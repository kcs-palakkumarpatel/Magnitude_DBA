-- =============================================
-- Author:
-- Create date:
-- Description:	<FeedBack disable Enable>
-- =============================================
CREATE PROCEDURE [dbo].[FeedbackRemoveFromStatistics]
    @Type NVARCHAR(10) ,
    @ReportId VARCHAR(MAX) ,
    @Isdisable BIT ,
    @UserId BIGINT
AS
    BEGIN

        IF ( @Type = 'OUT' )
            BEGIN
                UPDATE  dbo.SeenClientAnswerMaster SET     IsDisabled = @Isdisable , DisabledOn = GETUTCDATE() , DisabledBy = @UserId WHERE   Id IN ( SELECT  Data FROM dbo.Split(@ReportId, ',') );

                UPDATE  dbo.SeenClientAnswers SET     IsDisabled = @Isdisable , DisabledOn = GETUTCDATE() , DisabledBy = @UserId WHERE   SeenClientAnswerMasterId IN ( SELECT  Data FROM dbo.Split(@ReportId, ',') );
            END;
        ELSE
            IF ( @Type = 'IN' )
                BEGIN
                    UPDATE  dbo.AnswerMaster SET     IsDisabled = @Isdisable , DisabledOn = GETUTCDATE() , DisabledBy = @UserId WHERE   Id IN ( SELECT  Data FROM dbo.Split(@ReportId, ',') ); 
					
					UPDATE  dbo.Answers SET     IsDisabled = @Isdisable , DisabledOn = GETUTCDATE() , DisabledBy = @UserId WHERE   AnswerMasterId IN ( SELECT  Data FROM dbo.Split(@ReportId, ',') );
                END;
    END;
