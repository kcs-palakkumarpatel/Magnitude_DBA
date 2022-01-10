CREATE PROCEDURE dbo.GetContactandContactGroupDetailsForSeenClient
    @EstablishmentGroupId BIGINT,
    @ContactGroupId BIGINT,
    @IsFromWeb BIT
AS
BEGIN
    EXEC dbo.WsGetContactGroupDetilsForSeenClientById @EstablishmentGroupId = @EstablishmentGroupId, -- bigint
                                                      @ContactGroupId = @ContactGroupId,             -- bigint
                                                      @IsFromWeb = @IsFromWeb;                       -- bit
    EXEC dbo.WsGetContactDetailsForSeenClientByGroupId @ContactGroupId = @ContactGroupId; -- bigint

END;
