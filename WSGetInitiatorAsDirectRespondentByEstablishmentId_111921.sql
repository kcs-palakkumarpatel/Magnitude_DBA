
-- =============================================
-- Author:		Matthew Grinaker
-- Create date: 2020/05/18
-- Description:	WSGetInitiatorAsDirectRespondentByEstablishmentId 2301
-- =============================================

CREATE PROCEDURE [dbo].[WSGetInitiatorAsDirectRespondentByEstablishmentId_111921] @EstablishmentId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ISNULL((SELECT ISNULL(InitiatorAsRespondent, 0) AS InitiatorAsDirectRespondent
    FROM dbo.Establishment WITH
        (NOLOCK)
    WHERE Id = @EstablishmentId), 0) AS InitiatorAsDirectRespondent;
END;
