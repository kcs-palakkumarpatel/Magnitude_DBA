
-- =============================================
-- Author:		GD
-- Create date: 29 Jul 2015
-- Description:	Get Today Feedback Count By ActivityId
-- Call SP:		WSGetTodayFeedbackCountByActivityId 3 
-- =============================================
CREATE PROCEDURE [dbo].[WSGetTodayFeedbackCountByActivityId_111921] 
		@ActivityId BIGINT,
		@AppuserId BIGINT
AS
    BEGIN
        DECLARE @TodayDate DATE ,
            @TimeOffSet INT;

			DECLARE @EstablishmentId VARCHAR(2000)
			select @EstablishmentId =  dbo.AllEstablishmentByAppUserAndActivity(@AppuserId,@ActivityId)
			DECLARE @userId VARCHAR(2000)
			select @userId =  dbo.AllUserSelected(@AppuserId,@EstablishmentId,@ActivityId)

        SELECT TOP 1
                @TimeOffSet = TimeOffSet
        FROM    dbo.EstablishmentGroup AS Eg
                INNER JOIN dbo.Establishment AS E ON Eg.Id = E.EstablishmentGroupId
        WHERE   Eg.Id = @ActivityId
                AND E.IsDeleted = 0;
        
        SELECT  @TodayDate = DATEADD(MINUTE, @TimeOffSet, GETUTCDATE());
		
        SELECT  ISNULL(COUNT(1), 0) AS ReportCount
        FROM    dbo.View_AnswerMaster AS Am
        WHERE   Am.ActivityId = @ActivityId
                AND CAST(Am.CreatedOn AS DATE) = @TodayDate
				AND Am.EstablishmentId IN (SELECT data FROM dbo.Split(@EstablishmentId,','))
				AND Am.AppUserId IN (SELECT data FROM dbo.Split(@userId,','));
    END;
