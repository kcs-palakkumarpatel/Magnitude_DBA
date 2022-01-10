create view PB_VW_Masslift_Fact_LeadsStatus as

select sh.ReferenceNo,sh.StatusDateTime as Statustime,es.StatusName,
case when es.statusname='Lead sent' then 1 when es.statusname='Deal Won' then 2 when es.statusname='Lost deal' then 3 end as StatusSort  from StatusHistory sh 
inner join establishmentstatus es on sh.establishmentstatusid=es.id
inner join Appuser U on U.id=Sh.UserId and U.id not in (3722,3973)
inner join (select Am.id from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid
inner join Establishment E on  E.EstablishmentGroupId=EG.Id
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id Where (G.Id=463 and EG.Id =3855
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)))A on A.id=Sh.referenceno
