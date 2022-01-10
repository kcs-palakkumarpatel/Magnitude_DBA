CREATE VIEW PB_VW_Converged_QR AS

select ResponseDate, ResponseReferenceNo,PI, IIF(P.PI=100,'Pass','Fail') AS Result,
 [Name],[Surname],[Email],[Mobile],[Travelled in past],[Exposed],[Cough],[Sore throat],[Breath Shortness],[Body aches],[Loss taste/smell],[Fever],[Fever or history ],[Facilitate Care],[Pneumonia],[Flu Symptoms],[Response Lat],
[Response long]
 from(
select
dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as ResponseDate,u.username as [Username],AM.id as ResponseReferenceNo,
AM.SeenClientAnswerMasterId,am.pi,AM.IsPositive,Q.shortname as Question,A.Detail as Answer,AM.Latitude as [Response Lat],AM.Longitude as [Response long]
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid
inner join Establishment E on  E.EstablishmentGroupId=EG.Id
inner join AnswerMaster AM on AM.EstablishmentId=E.id
inner join [Answers] A on A.AnswerMasterId=AM.id
inner join Questions Q on Q.id=A.QuestionId
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy and U.Isactive=1
LEFT OUTER JOIN dbo.SeenClientAnswerMaster SAM ON SAM.Id = AM.SeenClientAnswerMasterId
LEFT OUTER JOIN dbo.SeenClientAnswerChild SAC ON SAC.Id = (CASE WHEN SAM.IsSubmittedForGroup = 1 THEN AM.SeenClientAnswerChildId ELSE NULL END)
Where (G.Id=712 and EG.Id =8031 
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) 
and Q.id in (61525,61526,61527,61528,61529,61531,61533,61534,61535,61537,61538,61545,61546,61547,61548,61549)
) S
Pivot (
Max(Answer)
For  Question In (
[Name],[Surname],[Email],[Mobile],[Travelled in past],[Exposed],[Cough],[Sore throat],[Breath Shortness],[Body aches],[Loss taste/smell],[Fever],[Fever or history ],[Facilitate Care],[Pneumonia],[Flu Symptoms]
))P

