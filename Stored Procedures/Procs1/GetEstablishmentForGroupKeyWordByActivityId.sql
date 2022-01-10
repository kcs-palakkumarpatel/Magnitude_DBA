-- =============================================
-- Author:		<Vasu Patel>
-- Create date: <08 Sep 2016>
-- Description:	<CustomerType Establishment list by Group id with out tell us>
-- Call:					GetEstablishmentForGroupKeywordByActivityId 2543,1,''
-- =============================================
CREATE PROCEDURE dbo.GetEstablishmentForGroupKeyWordByActivityId
    @ActivityId BIGINT,
    @Page INT,
    --@Rows INT ,
    @Search NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Start AS INT,
            @End INT,
            @Rows INT;
    SET @Rows = 50;
    SET @Start = ((@Page * @Rows) - @Rows) + 1;
    SET @End = @Start + @Rows - 1;
    SELECT EstablishmentName,
           Id,
           GroupSearch,
           Total,
           RowNum
    FROM
    (
        SELECT E.EstablishmentSequence,
               E.EstablishmentName,
               E.Id,
               EG.IsGroupSearch AS [GroupSearch],
               COUNT(*) OVER (PARTITION BY 1) AS Total,
               ROW_NUMBER() OVER (ORDER BY ISNULL(E.EstablishmentSequence, 0) ASC) AS RowNum
        FROM dbo.Establishment E WITH (NOLOCK)
            INNER JOIN dbo.EstablishmentGroup EG WITH (NOLOCK)
                ON EG.Id = E.EstablishmentGroupId
        WHERE EG.Id = @ActivityId
              AND EG.EstablishmentGroupType = 'Customer'
              AND EG.EstablishmentGroupId IS NOT NULL
              AND E.EstablishmentName LIKE '%' + @Search + '%'
              AND E.IsDeleted = 0
              AND EG.IsDeleted = 0
              AND E.DisplayGroupKeyword = 1
    ) AS A
    WHERE RowNum
    BETWEEN CONVERT(NVARCHAR(5), @Start) AND CONVERT(NVARCHAR(5), @End)
    ORDER BY ISNULL(A.EstablishmentSequence, 0),
             A.EstablishmentName ASC;
    SET NOCOUNT OFF;
END;
