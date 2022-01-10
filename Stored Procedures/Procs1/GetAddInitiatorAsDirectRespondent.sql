

-- =============================================
-- Author:		<Author,,ADMIN>
-- Create date: <Create Date,, 26 May 2015>
-- Description:	<Description,,GetQuestionsById>
-- Call SP    :	GetQuestionsById
-- =============================================
CREATE PROCEDURE [dbo].[GetAddInitiatorAsDirectRespondent] @EstablishmentId BIGINT
AS
    BEGIN
		SELECT  1 AS AddInitiatorAsDirectRespondent
        --SELECT  [addInitiatorAsDirectRespondent] AS AddInitiatorAsDirectRespondent
        FROM    dbo.[Establishment]
        WHERE   [Id] = @EstablishmentId;
    END;
