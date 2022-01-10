-- =============================================
-- Author:			Sunil Vaghasiya
-- Create date:	24-Apr-2017
-- Description:	Get all active questions by questionnaire id for mobi form 363617
-- Call SP    :		dbo.GetUrlForOtherInstance 1851875
-- =============================================
CREATE PROCEDURE dbo.GetUrlForOtherInstance
(
		@seenClientAnswerMasterId BIGINT = 0,
        @EstablishmentId BIGINT = 0,
        @SeenClientAnswerChildId BIGINT = 0,
        @GroupId BIGINT = 0,
        @ActivityId BIGINT = 0,
        @OnceHistoryId BIGINT = 0
)
AS
BEGIN
    SET NOCOUNT ON;


    IF @seenClientAnswerMasterId > 0
        (SELECT TOP 1
             @GroupId = E.GroupId
         FROM dbo.SeenClientAnswerMaster SCAM
             INNER JOIN dbo.Establishment E
                 ON E.Id = SCAM.EstablishmentId
         WHERE SCAM.Id = @seenClientAnswerMasterId);

    IF @EstablishmentId > 0
        (SELECT TOP 1
             @GroupId = GroupId
         FROM dbo.Establishment
         WHERE Id = @EstablishmentId);


    IF @SeenClientAnswerChildId > 0
        (SELECT TOP 1
             @GroupId = E.GroupId
         FROM dbo.SeenClientAnswerChild SCA
             INNER JOIN dbo.SeenClientAnswerMaster SCAM
                 ON SCAM.Id = SCA.SeenClientAnswerMasterId
             INNER JOIN dbo.Establishment E
                 ON E.Id = SCAM.EstablishmentId
         WHERE SCA.Id = @SeenClientAnswerChildId);

    IF @ActivityId > 0
        (SELECT TOP 1
             @GroupId = GroupId
         FROM dbo.EstablishmentGroup
         WHERE Id = @ActivityId);

    DECLARE @RedirectURL VARCHAR(255) = '';

    IF EXISTS
    (
        SELECT [Data]
        FROM dbo.Split(
                          '76,101,193,194,367,387,388,394,408,409,419,426,427,428,431,436,471,479,490,501,503,542,545,546,554,559,574,578,668,672,708,721,727,738,739,740,761,786',
                          ','
                      )
        WHERE Data = @GroupId
    )
    BEGIN

        SET @RedirectURL = 'http://m.tsebo.magnitudefb.com/';

    END;

	IF EXISTS
    (
        SELECT [Data]
        FROM dbo.Split(
                          '907,906,754,913,887,875,876,877,878,879,880,881,882,883,884,885',
                          ','
                      )
        WHERE Data = @GroupId
    )
    BEGIN

        SET @RedirectURL = 'http://m.popia.magnitudefb.com/';

    END;
	SELECT @RedirectURL AS RedirectURL

    SET NOCOUNT OFF;
END;
