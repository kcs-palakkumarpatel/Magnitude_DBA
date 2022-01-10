CREATE VIEW PB_VW_Enviroloo_Service AS

select EstablishmentName,CAST(CapturedDate AS DATE) AS CapturedDate,ReferenceNo,Status,UserName,P.Latitude,P.Longitude,P.PI,P.[Company Name],P.[Project Name],P.[Order no./Quote ref no.],P.[House Name/Number],P.[Street Name or Ward],P.[Suburb or Village],P.[Contact Person (School Principle or Owner)],P.[Contact Person Mobile],P.[Contact person E-mail],
[Type],[Site Name Board],[Service Number],[Cubicle Number],[Block Number],[Before Raking Pic],
substring([Serviceable],1,case when CHARINDEX(',',[Serviceable])=0 then len([Serviceable])+1 else charindex(',',[Serviceable]) end -1) [Serviceable],
substring([Serviceable],case when CHARINDEX(',',[Serviceable])=0 then len([Serviceable]) else charindex(',',[Serviceable]) end +1,len([Serviceable])) [Serviceable1],
substring([Waste Raked],1,case when CHARINDEX(',',[Waste Raked])=0 then len([Waste Raked])+1 else charindex(',',[Waste Raked]) end -1) [Waste Raked],
substring([Waste Raked],case when CHARINDEX(',',[Waste Raked])=0 then len([Waste Raked]) else charindex(',',[Waste Raked]) end +1,len([Waste Raked])) [Waste Raked1],
substring([Waste Removed],1,case when CHARINDEX(',',[Waste Removed])=0 then len([Waste Removed])+1 else charindex(',',[Waste Removed]) end -1) [Waste Removed],
substring([Waste Removed],case when CHARINDEX(',',[Waste Removed])=0 then len([Waste Removed]) else charindex(',',[Waste Removed]) end +1,len([Waste Removed])) [Waste Removed1],
substring([Waste To DryingBox],1,case when CHARINDEX(',',[Waste To DryingBox])=0 then len([Waste To DryingBox])+1 else charindex(',',[Waste To DryingBox]) end -1) [Waste To DryingBox],
substring([Waste To DryingBox],case when CHARINDEX(',',[Waste To DryingBox])=0 then len([Waste To DryingBox]) else charindex(',',[Waste To DryingBox]) end +1,len([Waste To DryingBox])) [Waste To DryingBox1],
[Foreign Waste Foun],
[Foreign Waste Type],
[Other ForeignWaste],
substring([ForWaste Removed],1,case when CHARINDEX(',',[ForWaste Removed])=0 then len([ForWaste Removed])+1 else charindex(',',[ForWaste Removed]) end -1) [ForWaste Removed],
substring([ForWaste Removed],case when CHARINDEX(',',[ForWaste Removed])=0 then len([ForWaste Removed]) else charindex(',',[ForWaste Removed]) end +1,len([ForWaste Removed])) [ForWaste Removed1],
substring([F/WasteInSealedBag],1,case when CHARINDEX(',',[F/WasteInSealedBag])=0 then len([F/WasteInSealedBag])+1 else charindex(',',[F/WasteInSealedBag]) end -1) [F/WasteInSealedBag],
substring([F/WasteInSealedBag],case when CHARINDEX(',',[F/WasteInSealedBag])=0 then len([F/WasteInSealedBag]) else charindex(',',[F/WasteInSealedBag]) end +1,len([F/WasteInSealedBag])) [F/WasteInSealedBag1],
[Liquid Level After],
substring([Liquid Pumped],1,case when CHARINDEX(',',[Liquid Pumped])=0 then len([Liquid Pumped])+1 else charindex(',',[Liquid Pumped]) end -1) [Liquid Pumped],
substring([Liquid Pumped],case when CHARINDEX(',',[Liquid Pumped])=0 then len([Liquid Pumped]) else charindex(',',[Liquid Pumped]) end +1,len([Liquid Pumped])) [Liquid Pumped1],
substring([Worms Found],1,case when CHARINDEX(',',[Worms Found])=0 then len([Worms Found])+1 else charindex(',',[Worms Found]) end -1) [Worms Found],
substring([Worms Found],case when CHARINDEX(',',[Worms Found])=0 then len([Worms Found]) else charindex(',',[Worms Found]) end +1,len([Worms Found])) [Worms Found1],
substring([Compost Applied],1,case when CHARINDEX(',',[Compost Applied])=0 then len([Compost Applied])+1 else charindex(',',[Compost Applied]) end -1) [Compost Applied],
substring([Compost Applied],case when CHARINDEX(',',[Compost Applied])=0 then len([Compost Applied]) else charindex(',',[Compost Applied]) end +1,len([Compost Applied])) [Compost Applied1],
substring([Enzymes Applied],1,case when CHARINDEX(',',[Enzymes Applied])=0 then len([Enzymes Applied])+1 else charindex(',',[Enzymes Applied]) end -1) [Enzymes Applied],
substring([Enzymes Applied],case when CHARINDEX(',',[Enzymes Applied])=0 then len([Enzymes Applied]) else charindex(',',[Enzymes Applied]) end +1,len([Enzymes Applied])) [Enzymes Applied1],
substring([Lime Applied],1,case when CHARINDEX(',',[Lime Applied])=0 then len([Lime Applied])+1 else charindex(',',[Lime Applied]) end -1) [Lime Applied],
substring([Lime Applied],case when CHARINDEX(',',[Lime Applied])=0 then len([Lime Applied]) else charindex(',',[Lime Applied]) end +1,len([Lime Applied])) [Lime Applied1],
[Lime Quantity Appl],
[After Raking Pic],
[Components Check],
[Couldn't Fix],
[Pan Hygiene],
[Toilet Cleaner],
[Toilet Seat Pic],
[Rear View Pic],
[Rate Odour Level],
[Insp Tank Position],
[WindM Rotation],
substring([Vandalised],1,case when CHARINDEX(',',[Vandalised])=0 then len([Vandalised])+1 else charindex(',',[Vandalised]) end -1) [Vandalised],
substring([Vandalised],case when CHARINDEX(',',[Vandalised])=0 then len([Vandalised]) else charindex(',',[Vandalised]) end +1,len([Vandalised])) [Vandalised1],
[Vandalism Pic],
substring([Backf&Comp Intact],1,case when CHARINDEX(',',[Backf&Comp Intact])=0 then len([Backf&Comp Intact])+1 else charindex(',',[Backf&Comp Intact]) end -1) [Backf&Comp Intact],
substring([Backf&Comp Intact],case when CHARINDEX(',',[Backf&Comp Intact])=0 then len([Backf&Comp Intact]) else charindex(',',[Backf&Comp Intact]) end +1,len([Backf&Comp Intact])) [Backf&Comp Intact1],
[Erosion Pic],
substring([User Trained],1,case when CHARINDEX(',',[User Trained])=0 then len([User Trained])+1 else charindex(',',[User Trained]) end -1) [User Trained],
substring([User Trained],case when CHARINDEX(',',[User Trained])=0 then len([User Trained]) else charindex(',',[User Trained]) end +1,len([User Trained])) [User Trained1],
[Reason for NoTrain],
[Topics Covered],
[Estimate Users],
substring([Waste for CHAMDOR],1,case when CHARINDEX(',',[Waste for CHAMDOR])=0 then len([Waste for CHAMDOR])+1 else charindex(',',[Waste for CHAMDOR]) end -1) [Waste for CHAMDOR],
substring([Waste for CHAMDOR],case when CHARINDEX(',',[Waste for CHAMDOR])=0 then len([Waste for CHAMDOR]) else charindex(',',[Waste for CHAMDOR]) end +1,len([Waste for CHAMDOR])) [Waste for CHAMDOR1],
[Bags for CHAMDOR],
substring([Harvesting NextSer],1,case when CHARINDEX(',',[Harvesting NextSer])=0 then len([Harvesting NextSer])+1 else charindex(',',[Harvesting NextSer]) end -1) [Harvesting NextSer],
substring([Harvesting NextSer],case when CHARINDEX(',',[Harvesting NextSer])=0 then len([Harvesting NextSer]) else charindex(',',[Harvesting NextSer]) end +1,len([Harvesting NextSer])) [Harvesting NextSer1],
[Other Comments]
From(
select
E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsResolved as Status,A.Detail as Answer,Q.ShortName as Question ,U.Name as UserName,AM.Latitude,AM.Longitude,AM.PI,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=1388
) as [Company Name],
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=1389
) as [Project Name],
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=1500
) as [Order no./Quote ref no.],
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=1494
) as [House Name/Number],
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=1495
) AS [Street Name or Ward],
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=1496
) AS [Suburb or Village],
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=1490
) as [Contact Person (School Principle or Owner)],
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=1491
) as [Contact Person Mobile],
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=1492
) as [Contact person E-mail]
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 196 and eg.id=1269
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (26159,9106,7873,7893,7894,6970,7750,6972,6974,6973,20678,7751,7752,6976,6977,6978,6979,6980,6981,6982,6983,6984,6971,6985,6987,6989,8015,7754,6988,8016,6991,6992,6993,6994,6995,6996,6997,6999,6998,8017,7001,7002,7003,7004)
LEFT outer join dbo.[Appuser] u on u.Id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
)S
pivot(
Max(Answer)
For  Question In (
[Type],[Site Name Board],[Service Number],[Cubicle Number],[Block Number],[Before Raking Pic],[Serviceable],[Waste Raked],[Waste Removed],[Waste To DryingBox],[Foreign Waste Foun],[Foreign Waste Type],[Other ForeignWaste],[ForWaste Removed],[F/WasteInSealedBag],[Liquid Level After],[Liquid Pumped],[Worms Found],[Compost Applied],[Enzymes Applied],[Lime Applied],[Lime Quantity Appl],[After Raking Pic],[Components Check],[Couldn't Fix],[Pan Hygiene],[Toilet Cleaner],[Toilet Seat Pic],[Rear View Pic],[Rate Odour Level],[Insp Tank Position],[WindM Rotation],[Vandalised],[Vandalism Pic],[Backf&Comp Intact],[Erosion Pic],[User Trained],[Reason for NoTrain],[Topics Covered],[Estimate Users],[Waste for CHAMDOR],[Bags for CHAMDOR],[Harvesting NextSer],[Other Comments]
))P

