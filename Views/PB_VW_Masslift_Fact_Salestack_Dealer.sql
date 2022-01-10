CREATE VIEW dbo.PB_VW_Masslift_Fact_Salestack_Dealer AS
with cte as(

SELECT [Year],Month,sum([New]) as New,Sum([Used]) as Used,[Dealer ],count(RN)as dealerCount FROM(
SELECT [Year],[Month],
case when [New or used ]='New' then 1 else 0 end as [New],
case when [New or used ]='Used' then 1 else 0 end as [Used],
[Dealer ], RN from
(
SELECT e.EstablishmentName AS[En],scm.Id AS [RN],scm.IsResolved AS [Status],scm.Latitude,scm.Longitude,
sa.Detail AS [answers],sq.ShortName AS [questions],scm.CreatedOn AS [cap],YEAR(DATEADD(MINUTE,e.TimeOffSet,scm.CreatedOn)) AS [Year],DATENAME(month, DATEADD(MINUTE,e.TimeOffSet,scm.CreatedOn))AS [Month] FROM 

dbo.[Group] g
INNER JOIN
dbo.EstablishmentGroup eg ON g.id=eg.GroupId
INNER JOIN
dbo.Establishment e ON e.EstablishmentGroupId=eg.Id
INNER JOIN
dbo.SeenClientAnswerMaster scm ON scm.EstablishmentId=e.Id

INNER JOIN
dbo.SeenClientAnswers sa ON sa.SeenClientAnswerMasterId=scm.Id
INNER JOIN
dbo.SeenClientQuestions sq ON sa.QuestionId=sq.id

WHERE g.Id=463 AND eg.Id=3997 AND sq.id in (64746,64742)
)S
PIVOT(MAX(answers)
FOR questions IN(
[New or used ],
[Dealer ]
))P
)A GROUP BY year,month,[Dealer ]
)


 Select * From Masslift_SalesStack_Dealer union all
   select  [Year],Month,
    (select sum([New]) as New from cte B where B.year=A.year and B.month=A.month) as New,
	 (select sum([Used]) as New from cte B where B.year=A.year and B.month=A.month) as Used,[Dealer ],DealerCount 
	 from cte A

