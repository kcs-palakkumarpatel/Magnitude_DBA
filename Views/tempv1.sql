 CREATE view tempv1 as
 select EstablishmentName,CapturedDate,ReferenceNo,IsPositive,Status,UserId, UserName,ResolvedDate,RepeatCount,
[Customer],
[Forecast based on],
[Warehouse],
[FORECAST CAPTURE I],
[End Customer],
[Sector],
[Close Month],
[QTY Forecast],
[Select ATVAL Size ],
[ATVAL Pressure],
[ATVAL Actuation],
[ATVAL Model],
[Select BIMAN Size ],
[BIMAN Air Pressure],
[BIMAN Line],
[Biman Actuator],
[BIMAN ],
[RF PINCH Size],
[RF PINCH Pressure],
[RF Pinch Actuation],
[RF PINCH Model],
[INSAMCOR Size],
[INSAMCOR Pressure],
[INSAMCOR Model],
[Insamcor Actuation],
[VOM NCV Size],
[VOM NCV Pressure],
[VOM NCV Model],
[VOM AIR Siz],
[VOM AIR Pressure],
[VOM AIR Model],
[SAUNDERS Size],
[Saunders Material],
[SKG Size ],
[SKG Pressure],
[SKG Actuation Type],
[Select SKG Model],
[VOSA Size ],
[VOSA Pressure],
[VOSA Model],
[VOSA Specs],
[DRAGFLOW Outlet],
[DRAGFLOW Power],
[DRAGFLOW Model],
[FORECAST RISK] ,
[Product at Risk],
[Pipeline/Forecast],
[Saunders Drilling ],
[Components],
[Other Components],
[Component Descript],
[Saunders MOdel],
case when [Close Month]='January' then 1 
when [Close Month]='February' then 2
when [Close Month]='March' then 3
when [Close Month]='April ' then 4
when [Close Month]='May' then 5
when [Close Month]='June' then 6
when [Close Month]='July' then 7
when [Close Month]='August' then 8
when [Close Month]='September' then 9
when [Close Month]='October' then 10
when [Close Month]='November' then 11
when [Close Month]='December' then 12
end as CloseMonthSort
from
(


Select EstablishmentName,CapturedDate,ReferenceNo,IsPositive,Status,UserId, UserName,ResolvedDate,RepeatCount,
[Customer],
[Forecast based on],
[Warehouse],
[FORECAST CAPTURE I],
[End Customer],
[Sector],
[Close Month],
[QTY Forecast],
[Select ATVAL Size ],
[ATVAL Pressure],
[ATVAL Actuation],
[ATVAL Model],
[Select BIMAN Size ],
[BIMAN Air Pressure],
[BIMAN Line],
[Biman Actuator],
[BIMAN ],
[RF PINCH Size],
[RF PINCH Pressure],
[RF Pinch Actuation],
[RF PINCH Model],
[INSAMCOR Size],
[INSAMCOR Pressure],
[INSAMCOR Model],
[Insamcor Actuation],
[VOM NCV Size],
[VOM NCV Pressure],
[VOM NCV Model],
[VOM AIR Siz],
[VOM AIR Pressure],
[VOM AIR Model],
[SAUNDERS Size],
[Saunders Material],
[SKG Size ],
[SKG Pressure],
[SKG Actuation Type],
[Select SKG Model],
[VOSA Size ],
[VOSA Pressure],
[VOSA Model],
[VOSA Specs],
[DRAGFLOW Outlet],
[DRAGFLOW Power],
[DRAGFLOW Model],
[FORECAST RISK] ,
[Product at Risk],
[Pipeline/Forecast],
[Saunders Drilling ],
[Components],
[Other Components],
[Component Descript],
[Saunders MOdel]
from 
(

select
EstablishmentName,CapturedDate,ReferenceNo,
SeenClientAnswerMasterId,SeenClientAnswerChildId,IsPositive,Status,PI,
replace (Split.a.value('.','varchar(400)') ,'&apos;','''') as Answer,
Question ,UserId,UserName,ResolvedDate,RepeatCount,
Longitude,Latitude
from(
select 

E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
A.SeenClientAnswerMasterId,A.SeenClientAnswerChildId,AM.IsPositive,AM.IsResolved as Status,AM.PI,
CAST ('<M>' + REPLACE(REPLACE(A.Detail,'''','&apos;'), ',', '</M><M>') + '</M>' AS XML) AS Split_Detail

,Q.ShortName as Question ,U.Id as UserId, u.name as UserName,RD.ResolvedDate,A.RepeatCount,
AM.Longitude,AM.Latitude
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid
inner join Establishment E on  E.EstablishmentGroupId=EG.Id
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id
inner join SeenClientQuestions Q on Q.id=A.QuestionId
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
Left Outer Join (
	Select CLA.SeenClientAnswerMasterid as ReferenceNo,max(dateadd(MINUTE,TimeOffSet,CLA.CreatedOn)) as ResolvedDate from 
	CloseLoopAction CLA 
	right outer join seenclientanswermaster SAM on SAM.Id=CLA.SeenClientAnswerMasterId
	Where (Conversation Like '%Resolved - Ref#%' or Conversation Like 'Resolved') And Conversation Not Like '%UnResolve%' and SAM.Isresolved='Resolved'
	group by CLA.SeenClientAnswerMasterId
) as RD on rD.ReferenceNo = Am.Id

Where (G.Id=366 and EG.Id =3803 --and Q.id not in (29854,29855,29856,29857,29954,29858,29859,30710,31548)
ANd (AM.IsDeleted=0 or AM.IsDeleted=null))-- and (AM.IsDisabled=0 or AM.IsDisabled is null) And Am.istransferred=0 ) 
And Q.id in (29860,29862,29863,29864,29865,29869,29870,29871,29872,
29877,29878,29879,29880,29881,29887,29888,29889,29890,29895,29896,29897,29898,29903,29904,
29905,29910,29911,29912,29917,29919,29925,29926,29927,29928,29934,29935,29936,29937,29939,
29949,29950,29951,29953,29954,29956,30048,30715,30716,30717,30718,31547,32799)
)AS X
CROSS APPLY Split_Detail.nodes ('/M') AS Split(a) 


union all
select
EstablishmentName,CapturedDate,ReferenceNo,
SeenClientAnswerMasterId,SeenClientAnswerChildId,IsPositive,Status,PI,
replace (Split.a.value('.','varchar(400)') ,'&amp;','&') as Answer,
'Sector' as Question ,UserId,UserName,ResolvedDate,RepeatCount,
Longitude,Latitude
from(
select
E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
A.SeenClientAnswerMasterId,A.SeenClientAnswerChildId,AM.IsPositive,AM.IsResolved as Status,AM.PI,
CAST ('<M>' + REPLACE(REPLACE(A.Detail,'&','&amp;'), ',', '</M><M>') + '</M>' AS XML) AS Split_Detail,
'Sector' as Question ,U.Id as UserId, u.name as UserName,RD.ResolvedDate,A.RepeatCount,
AM.Longitude,AM.Latitude

from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid
inner join Establishment E on  E.EstablishmentGroupId=EG.Id
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id
inner join SeenClientQuestions Q on Q.id=A.QuestionId
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
Left Outer Join (
	Select CLA.SeenClientAnswerMasterid as ReferenceNo,max(dateadd(MINUTE,TimeOffSet,CLA.CreatedOn)) as ResolvedDate from 
	CloseLoopAction CLA 
	right outer join seenclientanswermaster SAM on SAM.Id=CLA.SeenClientAnswerMasterId
	Where (Conversation Like '%Resolved - Ref#%' or Conversation Like 'Resolved') And Conversation Not Like '%UnResolve%' and SAM.Isresolved='Resolved'
	group by CLA.SeenClientAnswerMasterId
) as RD on rD.ReferenceNo = Am.Id

Where (G.Id=366 and EG.Id =3803 --and Q.id not in (29854,29855,29856,29857,29954,29858,29859,30710,31548)
ANd (AM.IsDeleted=0 or AM.IsDeleted=null))-- and (AM.IsDisabled=0 or AM.IsDisabled is null) And Am.istransferred=0 ) 
And Q.id in (30720,30721,30722,30723,30724,30725,30726,30728,30729,30730,29932,29867,29885,29893,29901,29908,29915,29923,29932,29947)
)AS X
CROSS APPLY Split_Detail.nodes ('/M') AS Split(a) 

union all
select 
E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
A.SeenClientAnswerMasterId,A.SeenClientAnswerChildId,AM.IsPositive,AM.IsResolved as Status,AM.PI,A.Detail as Answer,
'Close Month' as Question ,U.Id as UserId, u.name as UserName,RD.ResolvedDate,A.RepeatCount,
AM.Longitude,AM.Latitude


from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid
inner join Establishment E on  E.EstablishmentGroupId=EG.Id
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id
inner join SeenClientQuestions Q on Q.id=A.QuestionId
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
Left Outer Join (
	Select CLA.SeenClientAnswerMasterid as ReferenceNo,max(dateadd(MINUTE,TimeOffSet,CLA.CreatedOn)) as ResolvedDate from 
	CloseLoopAction CLA 
	right outer join seenclientanswermaster SAM on SAM.Id=CLA.SeenClientAnswerMasterId
	Where (Conversation Like '%Resolved - Ref#%' or Conversation Like 'Resolved') And Conversation Not Like '%UnResolve%' and SAM.Isresolved='Resolved'
	group by CLA.SeenClientAnswerMasterId
) as RD on rD.ReferenceNo = Am.Id

Where (G.Id=366 and EG.Id =3803 --and Q.id not in (29854,29855,29856,29857,29954,29858,29859,30710,31548)
ANd (AM.IsDeleted=0 or AM.IsDeleted=null))-- and (AM.IsDisabled=0 or AM.IsDisabled is null) And Am.istransferred=0 ) 
And Q.id in (29930,29914,29922,29907,29900,29892,29883,29874)
union all
select 
E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
A.SeenClientAnswerMasterId,A.SeenClientAnswerChildId,AM.IsPositive,AM.IsResolved as Status,AM.PI,A.Detail as Answer,
'QTY Forecast' as Question ,U.Id as UserId, u.name as UserName,RD.ResolvedDate,A.RepeatCount,
AM.Longitude,AM.Latitude


from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid
inner join Establishment E on  E.EstablishmentGroupId=EG.Id
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id
inner join SeenClientQuestions Q on Q.id=A.QuestionId
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
Left Outer Join (
	Select CLA.SeenClientAnswerMasterid as ReferenceNo,max(dateadd(MINUTE,TimeOffSet,CLA.CreatedOn)) as ResolvedDate from 
	CloseLoopAction CLA 
	right outer join seenclientanswermaster SAM on SAM.Id=CLA.SeenClientAnswerMasterId
	Where (Conversation Like '%Resolved - Ref#%' or Conversation Like 'Resolved') And Conversation Not Like '%UnResolve%' and SAM.Isresolved='Resolved'
	group by CLA.SeenClientAnswerMasterId
) as RD on rD.ReferenceNo = Am.Id

Where (G.Id=366 and EG.Id =3803 --and Q.id not in (29854,29855,29856,29857,29954,29858,29859,30710,31548)
ANd (AM.IsDeleted=0 or AM.IsDeleted=null))-- and (AM.IsDisabled=0 or AM.IsDisabled is null) And Am.istransferred=0 and Q.IsDeleted=0) 
And Q.id in (29873,29882,29891,29899,29906,29913,29921,29929,29938,29952,30719)



) S
Pivot (
Max(Answer)
For  Question In (
[Customer],
[Forecast based on],
[Warehouse],
[FORECAST CAPTURE I],
[End Customer],
[Sector],
[Close Month],
[QTY Forecast],
[Select ATVAL Size ],
[ATVAL Pressure],
[ATVAL Actuation],
[ATVAL Model],
[Select BIMAN Size ],
[BIMAN Air Pressure],
[BIMAN Line],
[Biman Actuator],
[BIMAN ],
[RF PINCH Size],
[RF PINCH Pressure],
[RF Pinch Actuation],
[RF PINCH Model],
[INSAMCOR Size],
[INSAMCOR Pressure],
[INSAMCOR Model],
[Insamcor Actuation],
[VOM NCV Size],
[VOM NCV Pressure],
[VOM NCV Model],
[VOM AIR Siz],
[VOM AIR Pressure],
[VOM AIR Model],
[SAUNDERS Size],
[Saunders Material],
[SKG Size ],
[SKG Pressure],
[SKG Actuation Type],
[Select SKG Model],
[VOSA Size ],
[VOSA Pressure],
[VOSA Model],
[VOSA Specs],
[DRAGFLOW Outlet],
[DRAGFLOW Power],
[DRAGFLOW Model],
[FORECAST RISK],
[Product at Risk],
[Pipeline/Forecast],
[Saunders Drilling ],
[Components],
[Other Components],
[Component Descript],
[Saunders MOdel]))P
	)z

