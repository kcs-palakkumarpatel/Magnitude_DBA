
-- =============================================
-- Author:		<Vasu Patel>
-- Create date: <17 Nov 2016>
-- Description:	<GroupId For .mobi link>
-- Exec:		GetGroupIdForExcludeLink  11056,'e'
-- =============================================
CREATE PROCEDURE [dbo].[GetGroupIdForExcludeLink_111721]
    @Id BIGINT,
    @Type CHAR(1)
AS
BEGIN
    SET NOCOUNT ON;
    IF (@Type = 'E') ---- Establishment
    BEGIN
        SELECT GroupId
        FROM dbo.Establishment WITH (NOLOCK)
        WHERE Id = @Id
        ORDER BY Id DESC;
    END;
    ELSE IF (@Type = 'A') ---- Activity
    BEGIN
        SELECT GroupId
        FROM dbo.EstablishmentGroup WITH (NOLOCK)
        WHERE Id = @Id
        ORDER BY Id DESC;
    END;
    ELSE IF (@Type = 'S') ------ SeenclientMaster Captureform
    BEGIN
        SELECT E.GroupId
        FROM dbo.SeenClientAnswerMaster SAM WITH (NOLOCK)
            INNER JOIN dbo.Establishment E WITH (NOLOCK)
                ON E.Id = SAM.EstablishmentId
        WHERE SAM.Id = @Id;
    END;
    ELSE IF (@Type = 'O') ------ FeedbackHistory 
    BEGIN
        SELECT E.GroupId
        FROM dbo.FeedbackOnceHistory F WITH (NOLOCK)
            INNER JOIN dbo.Establishment E WITH (NOLOCK)
                ON F.EstablishmentId = E.Id
        WHERE F.Id = @Id
        ORDER BY F.Id DESC;
    END;
    SET NOCOUNT OFF;
END;
