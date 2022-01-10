

CREATE view [dbo].[DFC_temp] as

select 
EstablishmentName,CapturedDate,ReferenceNo,SeenClientAnswerMasterId,SeenClientAnswerChildId,IsPositive,Status,PI,
--CAST ('<M>' + REPLACE(REPLACE(Replace(A.Detail,'&','&amp;'),'''','&apos;'), ',', '</M><M>') + '</M>' AS XML) AS Split_Detail
UserId,UserName,ResolvedDate,RepeatCount,
Longitude,Latitude, EndUser,
[Pipeline/Forecast],
[Customer],
[Forecast based on],
[Warehouse],
[End Customer],
[FORECAST RISK],
[NOTE: Special Note],
[Product at Risk],
[Atval Sector],
[Select ATVAL Size ],
[ATVAL Pressure],
[ATVAL Actuation],
[ATVAL Model],
[ATVAL QTY FORECAST],
[ATVAL Close Month],
[Biman Sector],
[Select BIMAN Size ],
[BIMAN Air Pressure],
[BIMAN Line],
[Biman Actuator],
[BIMAN ],
[BIMAN QTY FORECAST],
[BIMAN Close Month],
[RF Pinch Sector],
[RF PINCH Size],
[RF PINCH Pressure],
[RF Pinch Actuation],
[RF PINCH Model],
[RF PINCH QTY],
[RF Pinch Close],
[Insamcor Sector],
[INSAMCOR Size],
[INSAMCOR Pressure],
[INSAMCOR Model],
[Insamcor Actuation],
[INSAMCOR QTY],
[INSAMCOR Close],
[VOM NCV Sector],
[VOM NCV Size],
[VOM NCV Pressure],
[VOM NCV Model],
[VOM NCV QTY],
[VOM NCV Close],
[VOM AIR Sector],
[VOM AIR Siz],
[VOM AIR Pressure],
[VOM AIR Model],
[VOM AIR QTY],
[VOM AIR Close],
[Saunders Sector],
[SAUNDERS Size],
[Saunders Drilling ],
[Saunders Diaphragm],
[Saunders Material],
[Saunders MOdel],
[SAUNDERS QTY],
[SAUNDERS Close],
[SKG Sector],
[SKG Size ],
[SKG Pressure],
[SKG Actuation Type],
[Select SKG Model],
[Blade Type],
[SKG QTY FORECAST],
[SKG Close Month],
[VOSA Sector],
[VOSA Size ],
[VOSA Pressure],
[VOSA Model],
[VOSA Specs],
[VOSA QTY FORECAST],
[VOSA Close Month],
[Dragflow Sector],
[DRAGFLOW Outlet],
[DRAGFLOW Power],
[DRAGFLOW Model],
[DRAGFLOW QTY],
[DRAGFLOW Close],
[Components],
[Other Components],
[Component Descript],
[Component QTY],
[COMPONENTS Month]
from(
/*select
EstablishmentName,CapturedDate,ReferenceNo,
SeenClientAnswerMasterId,SeenClientAnswerChildId,IsPositive,Status,PI,
replace(replace (Split.a.value('.','varchar(400)') ,'&apos;',''''),'&amp;','&') as Answer,
Question ,UserId,UserName,ResolvedDate,RepeatCount,
Longitude,Latitude,EndUser
from( */
select 

E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
A.SeenClientAnswerMasterId,A.SeenClientAnswerChildId,AM.IsPositive,AM.IsResolved as Status,AM.PI,
--CAST ('<M>' + REPLACE(REPLACE(Replace(A.Detail,'&','&amp;'),'''','&apos;'), ',', '</M><M>') + '</M>' AS XML) AS Split_Detail
A.detail as Answer
,Q.ShortName as Question ,U.Id as UserId, u.name as UserName,RD.ResolvedDate,A.RepeatCount,
AM.Longitude,AM.Latitude,CD1.Detail + ' '+CD2.Detail as EndUser
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid
inner join Establishment E on  E.EstablishmentGroupId=EG.Id
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id
inner join SeenClientQuestions Q on Q.id=A.QuestionId
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join ContactDetails CD1 on CD1.contactMasterid=AM.ContactMasterid and CD1.contactQuestionId=2284 
left outer join ContactDetails CD2 on CD2.contactMasterid=AM.ContactMasterid and CD2.contactQuestionId=2285
Left Outer Join (
	Select CLA.SeenClientAnswerMasterid as ReferenceNo,max(dateadd(MINUTE,TimeOffSet,CLA.CreatedOn)) as ResolvedDate from 
	CloseLoopAction CLA 
	right outer join seenclientanswermaster SAM on SAM.Id=CLA.SeenClientAnswerMasterId
	Where (Conversation Like '%Resolved - Ref#%' or Conversation Like 'Resolved') And Conversation Not Like '%UnResolve%' and SAM.Isresolved='Resolved'
	group by CLA.SeenClientAnswerMasterId
) as RD on rD.ReferenceNo = Am.Id

Where (G.Id=366 and EG.Id =3803 --and Q.id not in (29854,29855,29856,29857,29954,29858,29859,30710,31548)
ANd (AM.IsDeleted=0 or AM.IsDeleted=null))-- and (AM.IsDisabled=0 or AM.IsDisabled is null) And Am.istransferred=0 ) 
And Q.IsRequiredInBI=1
--)AS X
--CROSS APPLY Split_Detail.nodes ('/M') AS Split(a) 




) S
Pivot (
Max(Answer)
For  Question In (

[Pipeline/Forecast],
[Customer],
[Forecast based on],
[Warehouse],
[End Customer],
[FORECAST RISK],
[NOTE: Special Note],
[Product at Risk],
[Atval Sector],
[Select ATVAL Size ],
[ATVAL Pressure],
[ATVAL Actuation],
[ATVAL Model],
[ATVAL QTY FORECAST],
[ATVAL Close Month],
[Biman Sector],
[Select BIMAN Size ],
[BIMAN Air Pressure],
[BIMAN Line],
[Biman Actuator],
[BIMAN ],
[BIMAN QTY FORECAST],
[BIMAN Close Month],
[RF Pinch Sector],
[RF PINCH Size],
[RF PINCH Pressure],
[RF Pinch Actuation],
[RF PINCH Model],
[RF PINCH QTY],
[RF Pinch Close],
[Insamcor Sector],
[INSAMCOR Size],
[INSAMCOR Pressure],
[INSAMCOR Model],
[Insamcor Actuation],
[INSAMCOR QTY],
[INSAMCOR Close],
[VOM NCV Sector],
[VOM NCV Size],
[VOM NCV Pressure],
[VOM NCV Model],
[VOM NCV QTY],
[VOM NCV Close],
[VOM AIR Sector],
[VOM AIR Siz],
[VOM AIR Pressure],
[VOM AIR Model],
[VOM AIR QTY],
[VOM AIR Close],
[Saunders Sector],
[SAUNDERS Size],
[Saunders Drilling ],
[Saunders Diaphragm],
[Saunders Material],
[Saunders MOdel],
[SAUNDERS QTY],
[SAUNDERS Close],
[SKG Sector],
[SKG Size ],
[SKG Pressure],
[SKG Actuation Type],
[Select SKG Model],
[Blade Type],
[SKG QTY FORECAST],
[SKG Close Month],
[VOSA Sector],
[VOSA Size ],
[VOSA Pressure],
[VOSA Model],
[VOSA Specs],
[VOSA QTY FORECAST],
[VOSA Close Month],
[Dragflow Sector],
[DRAGFLOW Outlet],
[DRAGFLOW Power],
[DRAGFLOW Model],
[DRAGFLOW QTY],
[DRAGFLOW Close],
[Components],
[Other Components],
[Component Descript],
[Component QTY],
[COMPONENTS Month]
))p

