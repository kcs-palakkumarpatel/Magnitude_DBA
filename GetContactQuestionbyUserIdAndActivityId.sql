-- =============================================
-- Author:		<Vasu Patel>
-- Create date: <29 Dec 2015>
-- Description:	<Contact Question by userId and Activity Id>
-- Call: GetContactQuestionbyUserIdAndActivityId 20013,20037
-- =============================================
CREATE FUNCTION [dbo].[GetContactQuestionbyUserIdAndActivityId]
(
	@AppUserId BIGINT,
	@ActivityId BIGINT,
	@LastServerDate DATETIME
)
RETURNS NVARCHAR(4000)

AS
BEGIN
	DECLARE @ConcatString VARCHAR(4000)
		          
        SELECT  @ConcatString = COALESCE(@ConcatString + ', ', '') + CAST(CQ.id AS NVARCHAR(10))
        FROM    dbo.ContactQuestions AS CQ
                INNER JOIN [Group] AS G ON CQ.ContactId = G.ContactId
                INNER JOIN dbo.Establishment AS E ON E.GroupId = G.Id
                INNER JOIN dbo.EstablishmentGroup AS Eg ON E.EstablishmentGroupId = Eg.Id
                INNER JOIN dbo.HowItWorks AS HIW ON Eg.HowItWorksId = HIW.Id
                INNER JOIN AppUserEstablishment AS AE ON E.Id = AE.EstablishmentId
        WHERE   AE.AppUserId = @AppUserId AND eg.Id = @ActivityId
						AND AE.IsDeleted = 0
                AND ( ISNULL(AE.UpdatedOn, AE.CreatedOn) >= @LastServerDate
                      OR ISNULL(Eg.UpdatedOn, Eg.CreatedOn) >= @LastServerDate
                      OR @LastServerDate IS NULL
                    )
					RETURN @ConcatString
END