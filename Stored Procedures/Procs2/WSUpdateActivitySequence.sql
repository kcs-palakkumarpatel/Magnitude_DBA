-- =============================================
-- Author:			D#3
-- Create date		01-Mar-2018
-- Description:	Insert or update  Activity LastDays by App User.
-- Call SP:			dbo.WSUpdateActivityLastDays
-- =============================================
CREATE PROCEDURE [dbo].[WSUpdateActivitySequence]
    @ActivityIdSequenceId NVARCHAR(MAX) ,
    @AppUserId BIGINT
AS
    BEGIN
        DECLARE @TempTable TABLE
            (
              ActiviyId BIGINT ,
              SequenceId INT
            );

        INSERT  INTO @TempTable
                SELECT  LEFT(Data, CHARINDEX('|', Data) - 1) AS ActivityId ,
                        RIGHT(Data, CHARINDEX('|', REVERSE(Data)) - 1) AS [Sequence]
                FROM    dbo.Split(@ActivityIdSequenceId, ',');
        
        UPDATE  UE
        SET     UE.ActivitySequence = TT.SequenceId ,
                UE.UpdatedOn = GETUTCDATE() ,
                UE.UpdatedBy = @AppUserId
        FROM    dbo.AppUserEstablishment AS UE
                INNER JOIN dbo.Establishment AS E ON UE.EstablishmentId = E.Id
                INNER JOIN @TempTable AS TT ON ActiviyId = E.EstablishmentGroupId
        WHERE   E.IsDeleted = 0
                AND UE.IsDeleted = 0
                AND UE.AppUserId = @AppUserId;

        RETURN 1;
    END;
