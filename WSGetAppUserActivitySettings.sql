
-- =============================================
-- Author:			D3
-- Create date:	07-Dec-2017
-- Description:	
-- Call SP:			dbo.WSGetAppUserActivitySettings 551, 429
-- =============================================
CREATE PROCEDURE [dbo].[WSGetAppUserActivitySettings]
    @AppUserId BIGINT ,
    @ActivityId BIGINT
AS 
    BEGIN
	SET DEADLOCK_PRIORITY NORMAL;
	
	BEGIN TRY
        DECLARE @TellUsSubmitted BIT = 0 ,
            @QuestionnaireId BIGINT
		
        SELECT  @QuestionnaireId = ISNULL(Eg1.QuestionnaireId, 0)
        FROM    dbo.EstablishmentGroup AS Eg
		INNER JOIN dbo.EstablishmentGroup AS Eg1 ON Eg.EstablishmentGroupId = Eg1.Id
        WHERE   Eg.Id = @ActivityId

        IF EXISTS ( SELECT  Id
                    FROM    dbo.AnswerMaster
                    WHERE   AppUserId = @AppUserId
                            AND QuestionnaireId = @QuestionnaireId
                            AND IsDeleted = 0 ) 
            BEGIN
                SET @TellUsSubmitted = 1
            END

        SELECT  ISNULL(EG.SeenClientId, 0) AS SeenClientId ,
                ISNULL(TellUs.QuestionnaireId, 0) AS QuestionnaireId ,
                EG.AllowRecurring AS IsAllowedRecurring ,
                EG.AllowToChangeDelayTime AS IsAllowToChangeDelayTime ,
                ISNULL(UE.DelayTime, EG.DelayTime) AS DelayTime ,
                HW.HowItWorks ,
                ISNULL(@TellUsSubmitted, 0) AS IsTellUsSubmitted
        FROM    dbo.EstablishmentGroup AS EG
                INNER JOIN dbo.HowItWorks AS HW ON EG.HowItWorksId = HW.Id
                INNER JOIN dbo.Vw_Establishment AS E ON EG.Id = E.EstablishmentGroupId
                INNER JOIN dbo.AppUserEstablishment AS UE ON E.Id = UE.EstablishmentId
                                                             AND AppUserId = @AppUserId
                LEFT OUTER JOIN dbo.EstablishmentGroup AS TellUs ON EG.EstablishmentGroupId = TellUs.Id
        WHERE   EG.Id = @ActivityId AND E.IsDeleted = 0 AND EG.IsDeleted = 0 AND UE.IsDeleted = 0
        GROUP BY EG.SeenClientId ,
                EG.EstablishmentGroupId ,
                EG.AllowRecurring ,
                EG.AllowToChangeDelayTime ,
                UE.DelayTime ,
                EG.DelayTime ,
                HW.HowItWorks,
				TellUs.QuestionnaireId
				END TRY

BEGIN CATCH
	INSERT INTO dbo.ErrorLog
        (
            PageId,
            MethodName,
            ErrorType,
            ErrorMessage,
            ErrorDetails,
            ErrorDate,
            UserId,
            Solution,
            CreatedOn,
            CreatedBy
        )
        VALUES
        (ERROR_LINE(),
         'dbo.WSGetAppUserActivitySettings',
         N'DATABASE',
         ERROR_MESSAGE(),
         ('ERROR_NUMBER=' + CONVERT(VARCHAR(100), ERROR_NUMBER()) + ',ERROR_STATE='
          + CONVERT(VARCHAR(20), ERROR_STATE()) + ',ERROR_SEVERITY=' + CONVERT(VARCHAR(20), ERROR_SEVERITY())
         )  ,
         GETUTCDATE(),
         ISNULL(@AppUserId,0),
         @AppUserId+','+@ActivityId,
         GETUTCDATE(),
         ISNULL(@AppUserId,0)
        );
END CATCH
    END
