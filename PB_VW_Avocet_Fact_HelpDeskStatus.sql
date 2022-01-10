Create view PB_VW_Avocet_Fact_HelpDeskStatus as

WITH cte AS (
SELECT * ,
  ROW_NUMBER() OVER (PARTITION BY ReferenceNo ORDER BY Statustime ASC) AS rn
FROM (
select distinct A.Activity, U.Id AS AppUserId,sh.ReferenceNo,sh.StatusDateTime as Statustime,convert(date,statusdatetime) as StatusDate,es.StatusName,U.Name as UserName,
 case when  StatusName='Planned for Today' then 1 when  StatusName='Arrived On-Site' then 2 when StatusName='Complete' then 3
 else 0 end as StatusSort,SH.Latitude,SH.Longitude from StatusHistory sh 
inner join establishmentstatus es on sh.establishmentstatusid=es.id and es.IsDeleted=0
inner join Appuser U on U.id=Sh.UserId 
inner join (select Am.id,EG.EstablishmentGroupName as Activity from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id
Where (G.Id=469 and EG.Id IN(4349)
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)))A on A.id=Sh.referenceno

 


  

union all
select distinct A.Activity,U.Id AS AppUserId,A.Id as ReferenceNo,DATEADD(minute,120,GETDATE()) as Statustime,convert(date,getdate()) as StatusDate,'Arrived On-Site' as StatusName,U.Name as UserName,
100 as StatusSort,SH.Latitude,SH.Longitude from StatusHistory sh 
inner join establishmentstatus es on sh.establishmentstatusid=es.id and es.IsDeleted=0
inner join Appuser U on U.id=Sh.UserId 
inner join (select Am.id,EG.EstablishmentGroupName as Activity from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id Where (G.Id=469 and EG.Id IN(4349)
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)))A on A.id=Sh.referenceno
 


)P

 


)

 

 

 

 

 

SELECT B.Activity,B.ReferenceNo, B.AppUserId,B.UserName,B.StatusName,B.Statustime,B.StatusSort,B. Endtime AS EndTime,A.[TotalTime] AS TotalTime,B.Latitude,B.Longitude from
(select c3.*,case when c3.statusname='Complete' then null else c4.statustime end as endtime 
from (select * from cte where statussort<>100) c3
left JOIN (select * from cte where statussort<>100) c4
  ON c3.ReferenceNo = c4.ReferenceNo 
  AND c3.rn = c4.rn - 1
  and c3.statusdate=c4.statusdate )B 
 left outer join
(SELECT 
    c1.ReferenceNo,c1.StatusDate
   , SUM(DATEDIFF(MINUTE, c1.Statustime, c2.Statustime)) AS [TotalTime]
FROM cte c1
JOIN cte c2
  ON c1.ReferenceNo = c2.ReferenceNo 
  AND c1.rn = c2.rn - 1
  and c1.StatusDate=c2.StatusDate
WHERE c1.StatusName = 'Arrived On-Site'
GROUP BY c1.ReferenceNo,c1.StatusDate)A

 


 on A.ReferenceNo=B.ReferenceNo and A.Statusdate=B.StatusDate  where B.statussort<>100

