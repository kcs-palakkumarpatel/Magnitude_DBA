CREATE view PB_VW_TseboCleaning_Fact_LastStatus
 AS



WITH cte AS (
SELECT *, 
  ROW_NUMBER() OVER (PARTITION BY ReferenceNo ORDER BY Statustime ASC) AS rn
FROM (
select distinct sh.ReferenceNo,sh.StatusDateTime as Statustime,convert(date,statusdatetime) as StatusDate,es.StatusName,U.Name as UserName
 from StatusHistory sh 
inner join establishmentstatus es on sh.establishmentstatusid=es.id and es.IsDeleted=0
inner join Appuser U on U.id=Sh.UserId 
inner join (select Am.id from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid
inner join Establishment E on  E.EstablishmentGroupId=EG.Id
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id Where (G.id=503 and EG.id=6231
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)))A on A.id=Sh.referenceno where SH.IsDeleted=0
)P

)


select distinct  B.ReferenceNo,B.StatusName,null as Statustime,
B.UserName,A.StatusName as LastStatus from
(select * from cte )B 
 left outer join
(SELECT 
    c1.ReferenceNo
   ,c1.StatusName
FROM cte c1
JOIN cte c2
  ON c1.ReferenceNo = c2.ReferenceNo 
  AND c1.rn = c2.rn - 1
WHERE c2.StatusName = 'No further tracking required'
and c1.StatusName<>'No further tracking required'
)A

 on A.ReferenceNo=B.ReferenceNo  where B.StatusName='No further tracking required'--A.StatusName is not null 


