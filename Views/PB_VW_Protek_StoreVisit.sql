CREATE VIEW PB_VW_Protek_StoreVisit AS

SELECT EstablishmentName,CapturedDate,ReferenceNo,Status,UserName,Longitude,Latitude,CustomerName,CustomerMobile,CustomerEmail,
[Store name],[Time check in],[Check out time],[Type of store],
REPLACE(REPLACE([How many drops are their in the store?],'.',''),',','') AS [How many drops are their in the store?],
REPLACE(REPLACE([How many drops does Protek have?],'.',''),',','') AS [How many drops does Protek have?],
REPLACE(REPLACE([How many drops does the opposition have?],'.',''),',','') AS [How many drops does the opposition have?],
[Who is the opposition?],[If other, who?],[Is there a promoter on store?],[If yes, what is the promotors name?],[Did you do an order?],[Did you do a proforma?],[Did stock rotation take place in store?],[Is there aged stock in the store?],[If yes, was the stock collected?],[If yes, did you get an order?],[If No, why did we not get an order?],[Do we have a gondola?],[Do you have a bin?],[Did you build a display?],CONCAT([Name],' ',[Surname]) AS [Contact person],[Mobile] AS [Contact number],[Email] AS [Contact email]
from (
select
E.EstablishmentName,cast(dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as date) as CapturedDate,AM.id as ReferenceNo,
AM.IsResolved as Status,
A.Detail as Answer
,Q.Questiontitle as Question,u.name as UserName,
AM.Longitude ,AM.Latitude,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3060
) as CustomerEmail,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3059
) as CustomerMobile,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3057
)+' '+
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 --and CD.Detail<>'' 
and CD.contactQuestionId=3058
) as CustomerName
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 505 and eg.id=5373
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (43009,43010,43011,44697,44698,44699,44705,43021,43022,43023,43024,43026,43028,43029,43030,43031,43032,43033,43035,43037,44701,44702,44703,44704,43039)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId
)s
pivot(
Max(Answer)
For  Question In (
[Store name],[Time check in],[Check out time],[Type of store],[How many drops are their in the store?],[How many drops does Protek have?],[How many drops does the opposition have?],[Who is the opposition?],[If other, who?],[Is there a promoter on store?],[If yes, what is the promotors name?],[Did you do an order?],[Did you do a proforma?],[Did stock rotation take place in store?],[Is there aged stock in the store?],[If yes, was the stock collected?],[If yes, did you get an order?],[If No, why did we not get an order?],[Do we have a gondola?],[Do you have a bin?],[Did you build a display?],[Name],[Surname],[Mobile],[Email]
))p

