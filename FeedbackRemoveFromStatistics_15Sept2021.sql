-- =============================================
-- Author:
-- Create date:
-- Description:	<FeedBack disable Enable>
-- =============================================
CREATE PROCEDURE [dbo].[FeedbackRemoveFromStatistics_15Sept2021]
    @Type NVARCHAR(10) ,
    @ReportId VARCHAR(MAX) ,
    @Isdisable BIT ,
    @UserId BIGINT
AS
    BEGIN

        IF ( @Type = 'OUT' )
            BEGIN
                UPDATE  dbo.SeenClientAnswerMaster SET     IsDisabled = @Isdisable , DisabledOn = GETUTCDATE() , DisabledBy = @UserId WHERE EXISTS ( SELECT  Data FROM dbo.Split(@ReportId, ',') where Id = Data );

                UPDATE  dbo.SeenClientAnswers SET     IsDisabled = @Isdisable , DisabledOn = GETUTCDATE() , DisabledBy = @UserId WHERE EXISTS ( SELECT  Data FROM dbo.Split(@ReportId, ',') where SeenClientAnswerMasterId = Data);
            END;
        ELSE
            IF ( @Type = 'IN' )
                BEGIN
                    UPDATE  dbo.AnswerMaster SET     IsDisabled = @Isdisable , DisabledOn = GETUTCDATE() , DisabledBy = @UserId WHERE EXISTS ( SELECT  Data FROM dbo.Split(@ReportId, ',') where Id = Data ); 
					
					UPDATE  dbo.Answers SET     IsDisabled = @Isdisable , DisabledOn = GETUTCDATE() , DisabledBy = @UserId WHERE EXISTS ( SELECT  Data FROM dbo.Split(@ReportId, ',') where AnswerMasterId = Data );
                END;
    END;
