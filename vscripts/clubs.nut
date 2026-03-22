// Club native constants not exposed by engine
global const int CLUB_PRIVACY_OPEN = 0
global const int CLUB_PRIVACY_OPEN_WITH_REQ = 1
global const int CLUB_PRIVACY_BY_REQUEST = 2
global const int CLUB_PRIVACY_INVITE_ONLY = 3
global const int CLUB_PRIVACY_SEARCH_ANY = -1

global const int CLUB_RANK_GRUNT = 0
global const int CLUB_RANK_CAPTAIN = 1
global const int CLUB_RANK_ADMIN = 2
global const int CLUB_RANK_CREATOR = 3

global const int CLUB_EVENT_PROGRESS = 0
global const int CLUB_EVENT_EDIT = 1
global const int CLUB_EVENT_KICK = 2
global const int CLUB_EVENT_MATCH_COMPLETED = 3
global const int CLUB_EVENT_RANK_CHANGE = 4
global const int CLUB_EVENT_REPORT = 5
global const int CLUB_EVENT_LEAVE = 6
global const int CLUB_EVENT_JOIN = 7
global const int CLUB_EVENT_USER_AUTOBLOCKED = 8

global const int CLUB_ERROR_CODE_UNDEFINED = -1
global const int CLUB_ERROR_CODE_CROSSPLAY_INCOMPAT = 1
global const int CLUB_ERROR_CODE_INSUFFICENT_PERMISSIONS = 2
global const int CLUB_ERROR_CODE_VALIDATION = 3
global const int CLUB_ERROR_CODE_NO_SUCH_GROUP = 4
global const int CLUB_ERROR_CODE_INAPPROPRIATE = 5
global const int CLUB_ERROR_CODE_MEMBERSHIP_LIMIT = 6
global const int CLUB_ERROR_CODE_FULL = 7
global const int CLUB_ERROR_CODE_KICK_COOL_OFF = 8
global const int CLUB_ERROR_CODE_JOIN_COOL_OFF = 9
global const int CLUB_ERROR_CODE_HOP_COOL_OFF = 10
global const int CLUB_ERROR_CODE_DUPLICATE_NAME = 11
global const int CLUB_ERROR_CODE_AUTH = 12

global function Clubs_Init

#if UI
global function Club_GetErrorStringForCode
global function Club_SetKickedForCrossplayIncompat
global function Clubs_CreateNewClub
global function Clubs_EditClubSettings
global function Clubs_FinalizeNewClub
global function Clubs_CanLeaveClub
global function Clubs_LeaveClub
global function Clubs_FinalizeLeaveClub
global function Clubs_GetDescStringForMinAccountLevel
global function Clubs_GetDescStringForPrivacyLevel
global function Clubs_GetDescStringForMinRank
global function Clubs_GetMinLevelFromSetting
global function Clubs_SetClubMemberRank
global function Clubs_CanKickUsers
global function Clubs_CanKickClubMember
global function Clubs_KickMember
global function Clubs_JoinClub
global function Clubs_SwitchClubsThread
global function Clubs_FinalizeClubSwitchThread
global function Clubs_SetIsSwitchingClubs
global function Clubs_IsSwitchingClubs
global function Clubs_FinalizeJoinClub
global function Clubs_GetJoinRequestsString
global function Clubs_DoesMeetJoinRequirements
global function ClubRequest_AcceptJoinRequest
global function Clubs_Search
global function Clubs_CompletedSearch
global function Clubs_InitSearchResultButton
global function Clubs_CompletedClubInviteQuery
global function GetAllClubLogoElementFlavors
global function GetAllClubLogoElementFlavorsOfType
global function GetRandomClubLogoElementFlavor
global function ClubLogo_GetLogoElementImage
global function ClubLogo_GetLogoSecondaryColorMask
global function ClubLogo_GetLogoFrameMask
global function ClubLogo_GetLogoElementName
global function ClubLogo_GetLogoElementType
global function ClubLogo_GetLogoVerticalOffset
global function ClubLogo_GetLogoColorTable
global function ClubLogo_GetColorSwatchCount
global function GenerateRandomClubLogo
global function ClubLogo_ConvertLogoToString
global function ClubLogo_ConvertLogoStringToLogo
global function ClubLogoUI_CreateNestedClubLogo
global function ClubSearchTag_GetAllEnabledSearchTags
global function ClubSearchTag_CreateSearchTagBitMask
global function ClubSearchTag_GetItemFlavorFromBitMaskAddress
global function ClubSearchTag_GetItemFlavorsFromBitMask
global function ClubSearchTag_GetTagString
global function ClubSearchTag_GetTagType
global function ClubSearchTag_GetSearchTagNamesFromBitmask
global function ClubSearchTag_AddSearchTagToSelection
global function ClubSearchTag_RemoveSearchTagFromSelection
global function ClubSearchTag_GetSelectedSearchTags
global function ClubSearchTag_ClearSelectedSearchTags
global function ClubSearchTag_GetNamesOfSearchTagsFromArray
global function Clubs_AreObituaryTagsEnabledByPlaylist
global function Clubs_IsValidClubTag
global function ClubTag_CreateNestedClubTag
global function ServerToUI_AddPlayerDataForPlacementReport
global function ServerToUI_Clubs_UpdateLastMatchTimes
global function Clubs_ReportMatchPlacementToClub
global function DEV_ReportFakePlacementEvent
global function Clubs_Report
global function ClubRegulation_GetReasonString
global function ClubRegulation_GetComplaintsForMember
global function Clubs_IsEnabled
global function Clubs_AreDisabledByPlaylist
global function Clubs_UpdateCrossplayVar
global function Clubs_UIToClient_SetCrossplayVar
global function Clubs_SetMyStoredClubName
global function Clubs_GetMyStoredClubName
global function ClubDataUpdateThread
global function Clubs_UpdateMyData
global function AddCallback_OnClubDataUpdated
global function RemoveCallback_OnClubDataUpdated
global function Clubs_CheckClubPersistenceThread
global function Clubs_PopulateClubDetails
global function Clubs_ConfigureRankTooltip
global function Clubs_ConfigurePrivacyTooltip
global function Clubs_ConfigureMinLevelAndRankTooltip
global function Clubs_IsUserAClubmate
global function Clubs_GetClubMemberNameFromNucleus
global function Clubs_GetClubMemberRankString
global function Clubs_GetPromotableRanks
global function Clubs_TryCloseAllClubMenus
global function Clubs_SetClubTabUserCount
global function Clubs_DoIMeetMinimumLevelRequirement
global function Clubs_MonitorCrossplayChangeThread
global function Clubs_AttemptRequeryThread
global function Clubs_SetClubQueryState
global function Clubs_GetClubQueryState
global function Clubs_IsClubQueryProcessing
global function AddCallback_OnClubQuerySuccessful
global function Clubs_OpenErrorStringDialog
global function Clubs_OpenErrorDialog
global function Clubs_OpenClubJoinedDialog
global function Clubs_ShouldShowClubJoinedDialog
global function Clubs_OpenClubKickedDialog
global function Clubs_ShouldShowClubKickedDialog
global function Clubs_OpenJoinRequestDeniedDialog
global function Clubs_ShouldShowClubJoinRequestDeniedDialog
global function Clubs_OpenJoinReqsConfirmDialog
global function Clubs_OpenReportClubConfirmDialog
global function Clubs_OpenClubCreateBlockedByJoinDialog
global function Clubs_OpenClubCreateBlockedByMatchmakingDialog
global function Clubs_OpenClubEditBlockedByMatchmakingDialog
global function Clubs_OpenClubManagementBlockedByMatchmakingDialog
global function Clubs_ShouldShowClubAnnouncementDialog
global function Clubs_OpenClubAnnouncementCooldownDialog
global function Clubs_OpenMemberManagementResetConfirmationDialog
global function Clubs_OpenCrossplayChangeDialog
global function Clubs_OpenCrossplayChangeConfirmationDialog
global function Clubs_OpenAcceptInviteConfirmationDialog
global function Clubs_OpenKickTargetIsNotAMemberDialog
global function Clubs_OpenJoinReqsChangedDialog
global function Clubs_OpenTooLowRankToInviteDialog
global function Clubs_OpenJoinRegionConfirmationDialog
global function Clubs_OpenSwitchClubsConfirmDialog
global function ClubGetMyMemberRank
global function ClubGetHeader
global function ClubGetMembers
global function ClubIsValid
global function ClubInviteUser
global function ClubReportMember
#endif

// Constants
global const int CLUB_QUERY_RETRY_MAX = 5
global const string CLUB_REQUERY_SIGNAL = "ClubAttemptRequery"
global const string CLUB_UPDATE_TAB_SIGNAL = "ClubUpdateTabSignal"
global const int CLUB_LOGO_LAYER_MAX = 3
global const int CLUB_LOGO_LAYER_PROPERTY_COUNT = 3
global const string CLUB_LOGO_LAYER_DELIMITER = ";"
global const string CLUB_LOGO_PROPERTY_DELIMITER = ","
global const string CLUB_LOGO_COLORVEC_DELIMITER = "_"
global const string CLUB_EVENT_DELIMITER = "%"
global const float CLUB_LOGO_ROTATION_STEP = 45.0
global const int CLUB_SEARCH_MAX_RESULTS = 50
global const int CLUB_SEARCH_TAG_SELECTION_MAX = 5
global const int CLUB_TAG_LENGTH_MIN = 3
global const int CLUB_NAME_LENGTH_MIN = 4
global const int CLUB_ANNOUNCE_COOLDOWN_MINUTES = 15
global const int CLUB_JOIN_MIN_ACCOUNT_LEVEL = 9
global const string INVALID_CLUB_ID = ""
global const string PENDING_CLUB_REQUEST = "PendingClubRequest"
global const int INVALID_ANNOUNCE_VIEW_TIME = -1
global const array<string> ILLEGAL_CHAT_CHARS = ["%", "`"]
global const string CLUBCMD_REPORT_PLACEMENT_ADDPLAYER = "ServerToUI_AddPlayerDataForPlacementReport"
global const string CLUBCMD_UPDATE_LAST_MATCH_TIME = "ServerToUI_Clubs_UpdateLastMatchTimes"

// Enums
global enum eClubLogoElementType
{
	CLUBLOGOTYPE_FRAME,
	CLUBLOGOTYPE_EMBLEM,
	CLUBLOGOTYPE_BACKGROUNDS,
	_count
}

global enum eClubMinAccountLevel
{
	MINLVL_10,
	MINLVL_50,
	MINLVL_100,
	MINLVL_200,
	MINLVL_300,
	MINLVL_400,
	MINLVL_500,
	_count
}

global enum eClubMinRank
{
	MINRANK_BRONZE,
	MINRANK_SILVER,
	MINRANK_GOLD,
	MINRANK_PLATINUM,
	MINRANK_DIAMOND,
	MINRANK_MASTER,
	MINRANK_APEXPREDATOR,
	_count
}

global enum eClubInviteDisplayLevel
{
	DISABLED,
	ENABLED,
	_count
}

global enum eClubSearchTagFlags
{
	MODES_RANKED = (1 << 0)
	MODES_UNRANKED = (1 << 1)
	MODES_DUOS = (1 << 2)
	MODES_ANY = (1 << 4)
	PLAYSTYLE_COMPETITIVE = (1 << 5)
	PLAYSTYLE_CASUAL = (1 << 6)
	PLAYSTYLE_ALLSTYLES = (1 << 7)
	PLAYSTYLE_LONEWOLVES = (1 << 8)
	PLAYSTYLE_TEAMPLAYERS = (1 << 9)
	EXP_BEGINNERS = (1 << 10)
	EXP_WILLHELPBEGINNERS = (1 << 11)
	EXP_EXPERIENCED = (1 << 12)
	EXP_ALLSKILLS = (1 << 13)
	COMMS_MIC_ONLY = (1 << 14)
	COMMS_MIC_OPTIONAL = (1 << 15)
	COMMS_MIC_NO = (1 << 16)
	SOC_FAMILY_FRIENDLY = (1 << 17)
	SOC_MATURE = (1 << 18)
	SOC_YOUNG = (1 << 19)
	SOC_LGBT = (1 << 20)
	SOC_DISABLED_GAMERS = (1 << 21)
	SOC_SWEARING_OK = (1 << 22)
	SOC_SWEARING_NO = (1 << 23)
	SOC_TRASHTALK_OK = (1 << 24)
	SOC_TRASHTALK_NO = (1 << 25)
}

global enum eClubSearchTagType
{
	CLUBTAGTYPE_GAMEMODE,
	CLUBTAGTYPE_PLAYSTYLE,
	CLUBTAGTYPE_EXPERIENCE,
	CLUBTAGTYPE_COMMUNICATION,
	CLUBTAGTYPE_SOCIAL,
	CLUBTAGTYPE_PLATFORM,
	_count
}

global enum eClubInternalReportReason
{
	REASON_CHAT_OFFENSIVE,
	REASON_CHAT_SPAM,
	REASON_CHAT_HARASSMENT,
	REASON_CHAT_HATESPEECH,
	REASON_CHAT_SUICIDETHREAT,
	_chat_count,
	REASON_GAME_OFFENSIVE,
	REASON_GAME_RUDETOCLUBMATES,
	REASON_GAME_RUDETORANDOMS,
	REASON_GAME_CHEATS,
	_count,
}

global enum eClubQueryState
{
	INACTIVE,
	PROCESSING,
	FAILED,
	SUCCESSFUL,
	_count,
}

global const int CLUB_OP_GET_CURRENT = 0
global const int CLUB_OP_JOIN = 1
global const int CLUB_OP_CREATE = 2

// Structs
global struct ClubLogoLayer
{
	ItemFlavor& elementFlav
	int         elementType
	vector      pos = <0.0,0.0,0.0>
	vector      scale = <1.0,1.0,0>
	float       rotation = 0.0
	vector      primaryColorOverride = <255,255,255>
	float       verticalOffset = 0.0
	vector      secondaryColorOverride = <255,255,255>
	float       secondaryColorAlpha = 1.0
	asset       frameMask
}

global struct ClubLogo
{
	array<ClubLogoLayer> logoLayers
	bool isInvite = false
}

global struct ClubSquadSummaryPlayerData
{
	string nucleusID
	int kills
	int damageDealt
}

// ============================================================================
// Stub implementations — clubs require EA backend, not functional in r5sdk
// ============================================================================

void function Clubs_Init()
{
}

#if UI

struct ClubSearchTag
{
	ItemFlavor& flav
}

struct
{
	array< void functionref() > onClubDataUpdatedCallbacks
	array< void functionref() > onClubQuerySuccessfulCallbacks
	array<ClubSearchTag> selectedSearchTags
	int clubQueryState = eClubQueryState.INACTIVE
	bool isSwitchingClubs = false
	string myStoredClubName = ""
} file

string function Club_GetErrorStringForCode( int errorCode )
{
	return ""
}

void function Club_SetKickedForCrossplayIncompat()
{
}

void function Clubs_CreateNewClub( ClubHeader clubHeader )
{
}

void function Clubs_EditClubSettings( ClubHeader clubHeader )
{
}

void function Clubs_FinalizeNewClub( ... )
{
}

bool function Clubs_CanLeaveClub()
{
	return false
}

void function Clubs_LeaveClub()
{
}

void function Clubs_FinalizeLeaveClub()
{
}

string function Clubs_GetDescStringForMinAccountLevel( int level )
{
	return ""
}

string function Clubs_GetDescStringForPrivacyLevel( int level )
{
	return ""
}

string function Clubs_GetDescStringForMinRank( int rank )
{
	return ""
}

int function Clubs_GetMinLevelFromSetting( int setting )
{
	return 0
}

void function Clubs_SetClubMemberRank( ClubMember member, int rank )
{
}

bool function Clubs_CanKickUsers()
{
	return false
}

bool function Clubs_CanKickClubMember( ClubMember member )
{
	return false
}

void function Clubs_KickMember( ClubMember member )
{
}

void function Clubs_JoinClub( ... )
{
}

void function Clubs_SwitchClubsThread( ... )
{
}

void function Clubs_FinalizeClubSwitchThread( ... )
{
}

void function Clubs_SetIsSwitchingClubs( bool switching )
{
	file.isSwitchingClubs = switching
}

bool function Clubs_IsSwitchingClubs()
{
	return file.isSwitchingClubs
}

void function Clubs_FinalizeJoinClub( ... )
{
}

string function Clubs_GetJoinRequestsString()
{
	return ""
}

bool function Clubs_DoesMeetJoinRequirements( ClubHeader clubHeader )
{
	return false
}

void function ClubRequest_AcceptJoinRequest( ClubJoinRequest request, bool accept )
{
}

void function Clubs_Search( string clubName, string clubTag, int privacy, int accountLvl, int rank, array<ItemFlavor> tags, int maxResults, bool anyDataCenter )
{
}

void function Clubs_CompletedSearch( ... )
{
}

void function Clubs_InitSearchResultButton( var button, ClubHeader clubHeader, bool isShowingInvites = false )
{
}

void function Clubs_CompletedClubInviteQuery( ... )
{
}

array<ItemFlavor> function GetAllClubLogoElementFlavors()
{
	array<ItemFlavor> empty
	return empty
}

array<ItemFlavor> function GetAllClubLogoElementFlavorsOfType( int logoType )
{
	array<ItemFlavor> empty
	return empty
}

ItemFlavor ornull function GetRandomClubLogoElementFlavor( int logoType )
{
	return null
}

asset function ClubLogo_GetLogoElementImage( ItemFlavor flav )
{
	return $""
}

asset function ClubLogo_GetLogoSecondaryColorMask( ItemFlavor flav )
{
	return $""
}

asset function ClubLogo_GetLogoFrameMask( ItemFlavor flav )
{
	return $""
}

string function ClubLogo_GetLogoElementName( ItemFlavor flav )
{
	return ""
}

int function ClubLogo_GetLogoElementType( ItemFlavor flav )
{
	return 0
}

float function ClubLogo_GetLogoVerticalOffset( ItemFlavor flav )
{
	return 0.0
}

table<int, array<vector> > function ClubLogo_GetLogoColorTable()
{
	table<int, array<vector> > empty
	return empty
}

int function ClubLogo_GetColorSwatchCount( table<int, array<vector> > colorSwatches = {} )
{
	return 0
}

ClubLogo function GenerateRandomClubLogo( string clubID = "" )
{
	ClubLogo logo
	return logo
}

string function ClubLogo_ConvertLogoToString( ClubLogo logo )
{
	return ""
}

ClubLogo function ClubLogo_ConvertLogoStringToLogo( string logoStr )
{
	ClubLogo logo
	return logo
}

void function ClubLogoUI_CreateNestedClubLogo( var rui, string argName, ClubLogo logo )
{
}

array<ItemFlavor> function ClubSearchTag_GetAllEnabledSearchTags()
{
	array<ItemFlavor> empty
	return empty
}

int function ClubSearchTag_CreateSearchTagBitMask( array<ItemFlavor> tags )
{
	return 0
}

ItemFlavor ornull function ClubSearchTag_GetItemFlavorFromBitMaskAddress( int bitmask )
{
	return null
}

array<ItemFlavor> function ClubSearchTag_GetItemFlavorsFromBitMask( int bitmask )
{
	array<ItemFlavor> empty
	return empty
}

string function ClubSearchTag_GetTagString( ItemFlavor flav )
{
	return ""
}

int function ClubSearchTag_GetTagType( ItemFlavor flav )
{
	return 0
}

array<string> function ClubSearchTag_GetSearchTagNamesFromBitmask( int bitmask )
{
	array<string> empty
	return empty
}

void function ClubSearchTag_AddSearchTagToSelection( ItemFlavor flav )
{
}

void function ClubSearchTag_RemoveSearchTagFromSelection( ItemFlavor flav )
{
}

array<ItemFlavor> function ClubSearchTag_GetSelectedSearchTags()
{
	array<ItemFlavor> empty
	return empty
}

void function ClubSearchTag_ClearSelectedSearchTags()
{
}

string function ClubSearchTag_GetNamesOfSearchTagsFromArray( array<string> searchTags )
{
	string tagListString
	foreach ( name in searchTags )
	{
		string delimiter = searchTags.find( name ) == searchTags.len() - 1 ? "" : ", "
		tagListString = tagListString + Localize( name ) + delimiter
	}

	return tagListString
}

bool function Clubs_AreObituaryTagsEnabledByPlaylist()
{
	return false
}

bool function Clubs_IsValidClubTag( string tag )
{
	return false
}

void function ClubTag_CreateNestedClubTag( ... )
{
}

void function ServerToUI_AddPlayerDataForPlacementReport( ... )
{
}

void function ServerToUI_Clubs_UpdateLastMatchTimes( ... )
{
}

void function Clubs_ReportMatchPlacementToClub()
{
}

void function DEV_ReportFakePlacementEvent()
{
}

void function Clubs_Report( ... )
{
}

string function ClubRegulation_GetReasonString( int reason )
{
	return ""
}

array<ClubEvent> function ClubRegulation_GetComplaintsForMember( ClubMember member )
{
	array<ClubEvent> empty
	return empty
}

bool function Clubs_IsEnabled()
{
	return false
}

bool function Clubs_AreDisabledByPlaylist()
{
	return true
}

void function Clubs_UpdateCrossplayVar()
{
}

void function Clubs_UIToClient_SetCrossplayVar( ... )
{
}

void function Clubs_SetMyStoredClubName( string name )
{
	file.myStoredClubName = name
}

string function Clubs_GetMyStoredClubName()
{
	return file.myStoredClubName
}

void function ClubDataUpdateThread()
{
}

void function Clubs_UpdateMyData()
{
}

void function AddCallback_OnClubDataUpdated( void functionref() callback )
{
	file.onClubDataUpdatedCallbacks.append( callback )
}

void function RemoveCallback_OnClubDataUpdated( void functionref() callback )
{
	file.onClubDataUpdatedCallbacks.fastremovebyvalue( callback )
}

void function Clubs_CheckClubPersistenceThread()
{
}

void function Clubs_PopulateClubDetails( ClubHeader clubHeader, var panel, bool arg1 = false, bool arg2 = false )
{
}

void function Clubs_ConfigureRankTooltip( ... )
{
}

void function Clubs_ConfigurePrivacyTooltip( ... )
{
}

void function Clubs_ConfigureMinLevelAndRankTooltip( ... )
{
}

bool function Clubs_IsUserAClubmate( ... )
{
	return false
}

string function Clubs_GetClubMemberNameFromNucleus( ... )
{
	return ""
}

string function Clubs_GetClubMemberRankString( int rank )
{
	return ""
}

array<int> function Clubs_GetPromotableRanks( int currentRank )
{
	array<int> empty
	return empty
}

void function Clubs_TryCloseAllClubMenus()
{
}

void function Clubs_SetClubTabUserCount( ... )
{
}

bool function Clubs_DoIMeetMinimumLevelRequirement( ... )
{
	return false
}

void function Clubs_MonitorCrossplayChangeThread()
{
}

void function Clubs_AttemptRequeryThread()
{
}

void function Clubs_SetClubQueryState( int state )
{
	file.clubQueryState = state
}

int function Clubs_GetClubQueryState( int op = CLUB_OP_GET_CURRENT )
{
	return file.clubQueryState
}

bool function Clubs_IsClubQueryProcessing( int op = CLUB_OP_GET_CURRENT )
{
	return file.clubQueryState == eClubQueryState.PROCESSING
}

void function AddCallback_OnClubQuerySuccessful( int op, void functionref() callback )
{
	file.onClubQuerySuccessfulCallbacks.append( callback )
}

void function Clubs_OpenErrorStringDialog( ... )
{
}

void function Clubs_OpenErrorDialog( ... )
{
}

void function Clubs_OpenClubJoinedDialog()
{
}

bool function Clubs_ShouldShowClubJoinedDialog()
{
	return false
}

void function Clubs_OpenClubKickedDialog()
{
}

bool function Clubs_ShouldShowClubKickedDialog()
{
	return false
}

void function Clubs_OpenJoinRequestDeniedDialog()
{
}

bool function Clubs_ShouldShowClubJoinRequestDeniedDialog()
{
	return false
}

void function Clubs_OpenJoinReqsConfirmDialog( ClubHeader clubHeader )
{
}

void function Clubs_OpenReportClubConfirmDialog( ClubHeader clubHeader )
{
}

void function Clubs_OpenClubCreateBlockedByJoinDialog()
{
}

void function Clubs_OpenClubCreateBlockedByMatchmakingDialog()
{
}

void function Clubs_OpenClubEditBlockedByMatchmakingDialog()
{
}

void function Clubs_OpenClubManagementBlockedByMatchmakingDialog()
{
}

bool function Clubs_ShouldShowClubAnnouncementDialog()
{
	return false
}

void function Clubs_OpenClubAnnouncementCooldownDialog()
{
}

void function Clubs_OpenMemberManagementResetConfirmationDialog()
{
}

void function Clubs_OpenCrossplayChangeDialog()
{
}

void function Clubs_OpenCrossplayChangeConfirmationDialog( ... )
{
}

void function Clubs_OpenAcceptInviteConfirmationDialog( ClubHeader clubHeader )
{
}

void function Clubs_OpenKickTargetIsNotAMemberDialog( ClubMember member )
{
}

void function Clubs_OpenJoinReqsChangedDialog( ClubHeader clubHeader )
{
}

void function Clubs_OpenTooLowRankToInviteDialog()
{
}

void function Clubs_OpenJoinRegionConfirmationDialog( ClubHeader clubHeader )
{
}

void function Clubs_OpenSwitchClubsConfirmDialog( ClubHeader clubHeader )
{
}

int function ClubGetMyMemberRank()
{
	return CLUB_RANK_GRUNT
}

ClubHeader function ClubGetHeader()
{
	ClubHeader header
	return header
}

array<ClubMember> function ClubGetMembers()
{
	array<ClubMember> members
	return members
}

bool function ClubIsValid()
{
	return false
}

void function ClubInviteUser( ... )
{
}

void function ClubReportMember( ... )
{
}

#endif // UI
