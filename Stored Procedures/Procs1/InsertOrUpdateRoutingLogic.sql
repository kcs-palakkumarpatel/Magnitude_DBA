-- =============================================
-- Author:		<Ankit,,GD>
-- Create date: <Create Date,, 17 Mar 2015>
-- Description:	<Description,,InsertOrUpdateSeenClient>
-- Call SP    :	InsertOrUpdateSeenClient
-- =============================================
CREATE PROCEDURE [dbo].[InsertOrUpdateRoutingLogic] @RoutingLogicTableType RoutingLogicTableType READONLY
AS
BEGIN

    INSERT INTO dbo.RoutingLogic
    (
        OptionId,
        QueueQuestionId,
        CreatedBy,
        CreatedOn
    )
    SELECT RLT.OptionId,
           RLT.QueueQuestionId,
           RLT.CreatedBy,
           GETUTCDATE()
    FROM @RoutingLogicTableType RLT
        LEFT JOIN dbo.RoutingLogic RL
            ON RL.OptionId = RLT.OptionId
    WHERE RLT.IsDeleted = 0
          AND RL.Id IS NULL
          AND LEN(LTRIM(RTRIM(RLT.QueueQuestionId))) > 0;

    ;
    WITH RLTUPDATE
    AS (SELECT OptionId,
               QueueQuestionId,
               UpdatedBy
        FROM @RoutingLogicTableType
        WHERE LEN(LTRIM(RTRIM(UpdatedBy))) > 0
       )
    UPDATE RoutingLogic
    SET OptionId = RLTUPDATE.OptionId,
        QueueQuestionId = RLTUPDATE.QueueQuestionId,
        UpdatedOn = GETUTCDATE(),
        UpdatedBy = RLTUPDATE.UpdatedBy,
        DeletedOn = NULL,
        DeletedBy = NULL,
        IsDeleted = 0
    FROM dbo.RoutingLogic AS RL
        INNER JOIN RLTUPDATE
            ON RL.OptionId = RLTUPDATE.OptionId;

    ;
    WITH RLTDELETE
    AS (SELECT OptionId,
               DeletedBy
        FROM @RoutingLogicTableType
        WHERE IsDeleted = 1
       )
    UPDATE RoutingLogic
    SET DeletedOn = GETUTCDATE(),
        DeletedBy = RLTDELETE.DeletedBy,
        IsDeleted = 1
    FROM dbo.RoutingLogic AS RL
        INNER JOIN RLTDELETE
            ON RL.OptionId = RLTDELETE.OptionId;

END;
