//========== Copyright � 2008, Valve Corporation, All rights reserved. ========
//  Purpose: Script initially run after squirrel VM is initialized
//
//  !!!NOTE: Reference script only; changes made to this script will not work in game.
//=============================================================================

// Platform defines not present in PC engine
global const bool NX_PROG = false
global const bool PLAYSTATION_PROG = false
global const bool PS5_PROG = false
global const bool XB5_PROG = false
global const bool XBOX_PROG = false
global const bool PC_PROG_NX_UI = false

global function printl
global function CodeCallback_Precompile

global struct LocPair
{
    vector origin = <0, 0, 0>
    vector angles = <0, 0, 0>
}

global enum eScriptWindEvalStatus
{
	INCOMPLETE,
	COMPLETE,
	EXPIRED,
    INVALID
}

global struct ScriptWindEvalResult
{
    vector vec
	int status
}

global struct EchoTestStruct
{
	int test1
	bool test2
	bool test3
	float test4
	vector test5
	int[5] test6
}

global struct RemoteClientInfoFromMatchInfo
{
	string name
	int teamNum
	int score
	int kills
	int deaths
}

global struct RemoteMatchInfo
{
	string datacenter
	string gamemode
	string playlist
	string map
	int maxClients
	int numClients
	int maxRounds
	int roundsWonIMC
	int roundsWonMilitia
	int timeLimitSecs
	int timeLeftSecs
	int teamsLeft
	int maxScore
	array<RemoteClientInfoFromMatchInfo> clients
	array<int> teamScores
}

global struct InboxMessage
{
	int messageId
	string messageType
	bool deletable
	bool deleting
	bool reportable
	bool doneResolving

	string dateSent
	string senderHardware
	string senderUID
	string senderName
	int communityID
	string communityName
	string messageText
	string actionLabel
	string actionURL
}

global struct MainMenuPromos
{
	int prot,
	int version,
	string layout,
	string promoRpak,
	string miniPromoRpak
}

global struct CommunitySettings
{
	int communityId
	bool verified
	bool doneResolving
	string name
	string clanTag
	string motd
	string communityType
	string membershipType
	string visibility
	string category
	string micPolicy
	string language1
	string language2
	string language3
	string region1
	string region2
	string region3
	string region4
	string region5
	int happyHourStart
	int matches
	int wins
	int losses
	string kills
	string deaths
	string xp
	int ownerCount
	int adminCount
	int memberCount
	int onlineNow
	bool invitesAllowed
	bool chatAllowed
	string creatorUID
	string creatorName
}

global struct BrowseFilters
{
	string name
	string clantag
	string communityType
	string membershipType
	string category
	string playtime
	string micPolicy
	int pageNum
	int minMembers
}

global struct VehicleSim
{
	float  startGametime
	float  time
	vector pos
	vector vel
	vector ang
	vector angVel
	bool   isEngineStarted = false
	float  engineStartTime
	bool   didCollide
	bool   wasColliding
	bool   isResting
}

global const int BREACH_TRACE_RESULT_SUCCESS = 0
global const int BREACH_TRACE_RESULT_WALL_TOO_THIN = 1
global const int BREACH_TRACE_RESULT_WALL_TOO_THICK = 2
global const int BREACH_TRACE_RESULT_INVALID_END_POINT = 3
global const int BREACH_TRACE_RESULT_FAILURE = 4
global const int BREACH_TRACE_RESULT_COUNT = 5

global struct TraceResults
{
	entity hitEnt
	vector endPos
	vector surfaceNormal
	string surfaceName
	int surfaceProp
	float fraction
	float fractionLeftSolid
	int hitGroup
	int staticPropID
	bool startSolid
	bool allSolid
	bool hitSky
	bool hitBackFace
	int contents
}

global struct BreachTraceResults
{
	int result
	vector endPos
	vector surfaceNormal
}

global struct GrenadeIndicatorData
{
	vector hitPos
	vector hitNormal
	entity hitEnt
}

global struct VisibleEntityInCone
{
	entity ent
	vector visiblePosition
	int visibleHitbox
	bool solidBodyHit
	vector approxClosestHitboxPos
	int extraMods
}

global struct PlayerDidDamageParams
{
	entity victim
	vector damagePosition
	int hitBox
	int damageType
	float damageAmount
	int damageFlags
	int hitGroup
	entity weapon
	float distanceFromAttackOrigin
}

global struct Attachment
{
	vector position
	vector angle
}

global struct EntityScreenSpaceBounds
{
	float x0
	float y0
	float x1
	float y1
	bool outOfBorder
}

global struct BackendError
{
	int serialNum
	string errorString
}

global struct CommunityFriends
{
	bool isValid
	array<string> ids
	array<string> hardware
	array<string> names
}

global struct CupsMatchStatInformation
{
	string statRef
	int statChange
	int pointsGained
}

global struct CupsPlayerMatchSummary
{
	int									playerPlacement
	string								playerLegendName
	string								playerUID
	string								playerHardware
	int 								playerCalculatedScore
	array< CupsMatchStatInformation > 	statInformation
}

global struct CupMatchSummary
{
	int								squadCalculatedScore
	array< CupsPlayerMatchSummary >	playerSummaries
}

global struct CupEntry
{
	int cupID
	string squadID
	int currSquadPosition
	int leaderboardCount
	float positionPercentage
	int currSquadScore
	int reRollCount
	array< CupMatchSummary > matchSummaryData
	array< int > tierScoreBounds
}

global struct CupPlayerMMRBucket
{
	int cupID
	int bucket
}

global struct UserFullCupData
{
	array< CupEntry > enteredCups
	array< CupPlayerMMRBucket > cupPlayerMMRData
}

global struct CupPlayerInfo
{
	string playerUID
	string hardware
	string name
}

global struct CupLeaderboardEntry
{
	string squadID
	array<CupPlayerInfo> squadInfo
	int squadScore
	array<CupMatchSummary> matchHistoryData
}

global struct CupTierRewardData
{
	asset		reward
	int        	quantity
}

global struct CupTierData
{
	int		tierType
	int		bound

	asset	icon

	array<CupTierRewardData> rewardData
}

global struct CommunityUserInfo
{
	string hardware
	string uid
	string name
	string tag
	string kills
	int wins
	int matches
	int banReason
	int banSeconds
	int eliteStreak
	int rankScore
	string rankedPeriodName
	int rankedLadderPos
	int arenaScore
	string arenaPeriodName
	int arenaLadderPos
	int lastCharIdx
	bool isLivestreaming
	bool isOnline
	bool isJoinable
	bool hasGraduatedBotsQueue
	bool partyFull
	bool partyInMatch
	float lastServerChangeTime
	string privacySetting
	array<int> charData
	int numCommunities
	int rumbleRankScore
	int rumbleRankedLadderPos
}

global struct PartyMember
{
	string name
	string uid
	string hardware
	bool ready
	bool present
	string eaid
	string clubTag
	int boostCount
	string unspoofedHardware
	string unspoofedUID
}

global struct OpenInvite
{
	string inviteType
	string playlistName
	string originatorName
	string originatorUID
	int numSlots
	int numClaimedSlots
	int numFreeSlots
	float timeLeft
	bool amIInThis
	bool amILeader
	array<PartyMember> members
}


global struct Party
{
	string partyType
	string playlistName
	string originatorName
	string originatorUID
	int numSlots
	int numClaimedSlots
	int numFreeSlots
	float timeLeft
	bool amIInThis
	bool amILeader
	bool searching
	array<PartyMember> members
}

global struct NetTraceRouteResults
{
	string address
	int sent
	int received
	int bestRttMs
	int worstRttMs
	int lastRttMs
	int averageRttMs
}

#if UI || CLIENT
global struct MatchmakingDatacenterETA
{
	int datacenterIdx
	string datacenterName
	int latency
	int packetLoss
	int etaSeconds
	int idealStartUTC
	int idealEndUTC
}
#endif // UI || CLIENT

#if SERVER || UI || CLIENT
global struct GRXCraftingOffer
{
	int itemIdx
	int craftingPrice
}

global struct GRXStoreOfferItem
{
	int itemIdx
	int itemQuantity
	int itemType
}

global struct GRXStoreOfferPrice
{
	string priceAlias
	array< int > currencies
}

global struct GRXStoreOffer
{
	array< int > items                  // engine populates as array<int>, not array<GRXStoreOfferItem>
	array< array< int > > prices       // engine populates as array<array<int>>, not array<GRXStoreOfferPrice>
	array< GRXStoreOfferItem > items1
	array< GRXStoreOfferPrice > prices1
	table< string, string > attrs
	int offerType
	string offerAlias
	bool isSparkable
	int purchaseCount
	int ineligibilityCode
}

global struct GRXGetOfferInfo
{
	bool isEligible
	array< array< int > > prices
}
#endif // SERVER || UI || CLIENT

#if UI || CLIENT
global struct GRXScriptInboxMessage
{
	array<int> itemIndex
	array<int> itemCount
	bool       isNew
	int        timestamp
	string     senderNucleusPid
	string     gifterName
}
#endif

#if UI
global struct GRXStoreScenario
{
	string key
	string field
	table<string, string> variants
}

global struct GRXStoreItem
{
	string offerAlias = ""
	string imageRef = ""
	string mainLocalization = ""
	string subLocalization = ""
	string linkType = ""
	string link = ""
	string telemetryId
	int type = -1
	float tint1 = 0.0
	float tint2 = 0.0
	float tint3 = 0.0
}

global struct GRXStoreSection
{
	string localization = ""
	string imageRef = ""
	int markedAsNewDate = 0
	int startDate = 0
	int endDate = 0
	int id = -1
	float tint1 = 0.0
	float tint2 = 0.0
	float tint3 = 0.0
	array<GRXStoreItem> items
	array<GRXStoreScenario> scenarios
}

global struct GRXStoreTab
{
	string alias = ""
	string localization = ""
	array<GRXStoreSection> sections
}
#endif // UI

global struct GRXContainerInfo
{
	int type
	string containerId
	array< int > itemIndices
	array< int > itemCounts
	bool isNew
	int timestamp
	string senderNucleusPid
	string senderName
}

global struct GRXUserInfoBalances
{
	int balance
	int nextCurrencyExpirationAmt
	int nextCurrencyExpirationTime
}

global struct GRXUserInfo
{
	int inventoryState

	array<GRXUserInfoBalances> currencies

	int queryGoal
	int queryOwner
	int queryState
	int querySeqNum

	array< int > balances
	int nextCurrencyExpirationAmt
	int nextCurrencyExpirationTime

	array< GRXContainerInfo > containers

	int sparkleLimitCounter
	int sparkleLimitResetDate

	int marketplaceEdition

	bool isOfferRestricted
}

#if UI || CLIENT
global struct ClubHeader
{
	string clubID
	string name
	string tag
	string logoString
	string creatorID
	string dataCenter
	int memberCount
	int privacySetting	// CLUB_PRIVACY_*
	int minLevel
	int minRating
	int searchTags
	int hardware
	bool allowCrossplay
	int lastActive
}

global struct ClubMember
{
	string memberID
	string memberName
	string platformUserID
	int memberHardware
	int rank
}

global struct ClubJoinRequest
{
	string userID
	string userName
	int userHardware
	string platformUid
	int expireTime
}

global struct ClubEvent
{
	int eventTime
	int eventType	// CLUB_EVENT_*
	int eventParam
	string eventText
	string memberName
	string memberID
}

global struct ClubData
{
	array< ClubMember > members
	array< ClubJoinRequest > joinRequests
	array< ClubEvent > eventLog
	array< ClubEvent > chatLog
}

global struct ClubInvite
{
	string clubID
	string name
}

global struct ClubDisplay{
	string clubID
	string name
	string tag
	string logoString
	string dataCenter
	int lastActive
	int numMembers
	int maxMembers
	float activityMetric
}
#endif // UI || CLIENT


global struct VortexBulletHit
{
	entity vortex
	vector hitPos
}

global struct AnimRefPoint
{
	vector origin
	vector angles
}

global struct LevelTransitionStruct
{
	// only ints, floats, bools, vectors, and other structs or fixed-size arrays containing those are allowed.
	// "ornull" may also be used.

	int startPointIndex

	int[3] ints

	int[2] pilot_mainWeapons = [-1,-1]
	int[2] pilot_offhandWeapons = [-1,-1]
	int ornull[2] pilot_weaponMods = [null,null]
	int pilot_ordnanceAmmo = -1

	int titan_mainWeapon = -1
	int titan_unlocksBitfield = 0

	int difficulty = 0
}

global struct WeaponOwnerChangedParams
{
	entity oldOwner
	entity newOwner
}

global struct WeaponTossPrepParams
{
	bool isPullout
}

global struct WeaponPrimaryAttackParams
{
	vector pos
	vector dir
	bool firstTimePredicted
	int burstIndex
	int barrelIndex
}

global struct WeaponRedirectParams
{
	entity projectile
	vector projectilePos
}

global struct WeaponBulletHitParams
{
	entity hitEnt
	vector startPos
	vector hitPos
	vector hitNormal
	vector dir
}

global struct WeaponFireBulletSpecialParams
{
	vector pos
	vector dir
	int bulletCount
	int scriptDamageType
	bool skipAntiLag
	bool dontApplySpread
	bool doDryFire
	bool noImpact
	bool noTracer
	bool activeShot
	bool doTraceBrushOnly
}

global struct WeaponFireBoltParams
{
	vector pos
	vector dir
	float speed
	int scriptTouchDamageType
	int scriptExplosionDamageType
	bool clientPredicted
	int additionalRandomSeed
	bool dontApplySpread
	int projectileIndex
	bool deferred // (2019-12-01 dw): This doesn't seem to do anything.
}

global struct WeaponFireGrenadeParams
{
	vector pos
	vector vel
	vector angVel
	float fuseTime
	int scriptTouchDamageType
	int scriptExplosionDamageType
	bool clientPredicted
	bool lagCompensated
	bool useScriptOnDamage
	bool isZiplineGrenade = false
	string ziplineGrenadeRopeMaterial = "cable/zipline"
	int projectileIndex
}

global struct WeaponFireMissileParams
{
	vector pos
	vector dir
	float speed
	int scriptTouchDamageType
	int scriptExplosionDamageType
	bool doRandomVelocAndThinkVars
	bool clientPredicted
	int projectileIndex
}

global struct WeaponMissileMultipleTargetData
{
	vector pos
	vector normal
	float delay
}

global struct ModInventoryItem
{
	int slot
	string mod
	string weapon
	int count
}

global struct OpticAppearanceOverride
{
	array<string>	bodygroupNames
	array<int>		bodygroupValues
	array<string>	uiDataNames
}

global struct ArtifactViewmodelData
{
	int bladeGUID
	int powerSourceGUID
}

global struct ConsumableInventoryItem
{
	int slot
	int type
	int count
}

global struct OutsourceViewer_SkinDetails
{
	string skinName
	asset skinAssetName
	int skinTier
}

global struct PingCollection
{
	entity latestPing
	array<entity> locations
	array<entity> loots
}

global struct HudInputContext
{
	bool functionref(int) keyInputCallback
	bool functionref(float, float) viewInputCallback
	bool functionref(float, float) moveInputCallback
	int hudInputFlags
}

global struct SmartAmmoTarget
{
	entity ent
	float fraction
	float prevFraction
	bool visible
	float lastVisibleTime
	bool activeShot
	float trackTime
}

global struct StaticPropRui
{
	//------------------------------
	// These values are ignored by RuiCreateOnStaticProp. They are given to ClientCodeCallback_OnEnumStaticPropRui to be informative.
	//
	// If you create a StaticPropRui struct from scratch to pass to RuiCreateOnStaticProp, you can leave these blank.

	string scriptName           // "script_name" in LevelEd.
	string mockupName           // Name of the mockup material in Maya.
	string modelName            // Name of the model.
	vector spawnOrigin			// World coordinates of the model's origin when spawned. Parented static props can move away from here.
	vector spawnMins			// Minimum world coordinates of the model's bounding box when spawned. This can be wrong for parented static props once the level starts.
	vector spawnMaxs			// Maximum world coordinates of the model's bounding box when spawned. This can be wrong for parented static props once the level starts.

	vector spawnForward
	vector spawnRight
	vector spawnUp

	//------------------------------
	// These values are used by RuiCreateOnStaticProp to create a RUI on a static prop.
	// They are initialized to default values in ClientCodeCallback_OnEnumStaticPropRui.
	// You can change them to customize behavior.
	//
	// If you create a StaticPropRui struct from scratch to pass to RuiCreateOnStaticProp, you must initialize "ruiName", but "args" can be left empty.

	asset ruiName               // Name of the RUI asset to create
	table<string, string> args  // Arg overrides.

	//------------------------------
	// This magic number is how code knows which prop and RUI mesh to use for the topology. Do not remember this across levels, and do not modify it.
	// If you want to remember a RUI mesh on a static prop at startup so that you can create a RUI on it later, this is all you have to remember.
	//
	// If you create a StaticPropRui struct from scratch to pass to RuiCreateOnStaticProp, this must be initialized to the value you remembered from
	// ClientCodeCallback_OnEnumStaticPropRui.

	int magicId
}

global struct ScriptAnimWindow
{
	entity ent
	asset settingsAsset
	string stringID
	string windowName
	float startCycle
	float endCycle
}

global struct ZiplineStationSpots
{
	asset beginStationModel
	vector beginStationOrigin
	vector beginStationAngles
	entity beginStationMoveParent
	string beginStationAnimation
	vector beginZiplineOrigin

	asset endStationModel
	vector endStationOrigin
	vector endStationAngles
	entity endStationMoveParent
	string endStationAnimation
	vector endZiplineOrigin
}

global struct WaypointClusterInfo
{
	vector clusterPos
	int numPointsNear
}

global struct PlayersInViewInfo
{
	entity player
	bool hasLOS
	float distanceSqr
	float dot
}

global struct NavMesh_FindMeshPath_Result
{
	bool navMeshOK
	bool startPolyOK
	bool goalPolyOK
	bool pathFound
	bool pathIsPartialPath
	array<vector> points
	float pathLength
}

global struct PrivateMatchStatsStruct
{
	string playerName
	string teamName
	string characterName
	string platformUid
	string hardware
	int survivalTime
	int kills
	int assists
	int knockdowns
	int damageDealt
	int shots
	int hits
	int headshots
	int revivesGiven
	int respawnsGiven
	int teamNum
	int teamPlacement
	bool alive
}

global struct PrivateMatchAdminChatConfigStruct
{
	int		chatMode
	int		targetIndex
	bool	spectatorChat
}

global struct PrivateMatchChatConfigStruct
{
	bool	adminOnly
}

global typedef SettingsAssetGUID int

#if CLIENT || UI

global enum eRichPresenceSubstitutionMode
{												//S1				S2				S3
	NONE,										//
	MODE_MAP,									//gamemode			mapName
	MODE_MAP_SQUADSLEFT,						//gamemode			mapName			#SURVIVAL_SQUADS_REMAIN (%s1=survival_squadsRemaining, %s2=#SURVIVAL_SQUADS_REMAIN)
	MODE_MAP_FRIENDLYSCORE_ENEMYSCORE,			//gamemode			mapName			#SURVIVAL_TEAM_SCORES_2 (%s1=teams_friendlyScore, %s2=teams_enemyScore)
	MODE_MAP_FRIENDLYSCORE_ENEMYSCORE_PERCENTAGE,//gamemode			mapName			#SURVIVAL_TEAM_SCORES_2 (%s1=teams_friendlyScore, %s2=teams_enemyScore)
	PARTYSLOTSUSED_PARTYSLOTSMAX,				//party_slotsUsed	party_slotsMax	#RICHPRESENCE_PARTY_LOBBY
}

global struct PresenceState
{
	string 			layout
	int				substitutionMode
	string 			mapName
	string 			gamemode
	int				matchStartTime
	int 			party_slotsUsed
	int 			party_slotsMax
	int 			survival_squadsRemaining
	int				teams_friendlyScore
	int				teams_enemyScore
}

global struct CustomMatch_LobbyPlayer
{
	string uid
	string uidHashed
	string eaid
	string firstPartyID
	string hardware
	string name
	string clubTag
	bool isAdmin = false
	int team = 1
	int flags = 0
}

global struct CustomMatch_MatchHistory
{
	int matchNumber
	int endTime
}

global struct CustomMatch_LobbyState
{
	//int change = 1
	int maxTeams = 20
	int maxPlayers = 60
	int maxSpectators = 20
	int matchState = 0
	int tokenVer = 1
	int selfIdx = -1
	string playlist
	bool adminChat = false
	bool teamRename = false
	bool selfAssign = true
	bool aimAssist = true
	bool anonMode = false
	array<CustomMatch_LobbyPlayer> players
	array<CustomMatch_MatchHistory> matches
	table<int, string> teamNames
}

global struct CustomMatch_MatchPlayer
{
	string uid
	string hardware
	string name
	string clubTag
	string character
	int status
	int kills
	int damageDealt
}

global struct CustomMatch_MatchTeam
{
	int index
	string name
	int placement
	int killCount
	array<CustomMatch_MatchPlayer> players
}

global struct CustomMatch_MatchSummary
{
	string gamemode
	bool inProgress
	array<CustomMatch_MatchTeam> teams
}

global struct CustomMatch_LobbyHistory
{
	array<CustomMatch_MatchHistory> matches
}

#endif // CLIENT || UI

#if UI || CLIENT
global struct CustomMatch_SettingsForUpdate
{
	string playlist
	bool adminChat
	bool teamRename
	bool selfAssign
	bool aimAssist
	bool anonMode
}

global struct  EadpPresenceData
{
	int			hardware
	PresenceState ornull 	presence
	bool		partyInMatch
	bool		partyIsFull
	string		privacySetting
	string		name
	bool		online
	bool		ingame
	bool		away
	string      firstPartyId
	bool        isJoinable
}

global struct EadpPeopleData
{
	string eaid
	string name
	string platformName
	string platformHardware
	string ea_pid
	string psn_pid
	string xbox_pid
	string steam_pid
	string switch_pid
	int ea_has_played
	int psn_has_played
	int xbox_has_played
	int steam_has_played
	int switch_has_played
	int friendCreationTime
	array< EadpPresenceData > presences
}

global struct EadpPeopleList
{
	bool   isValid
	array< EadpPeopleData > people
}

global struct EadpQuerryPlayerData
{
	string	eaid
	string	name
	int		hardware
}

global struct EadpQuerryPlayerDataList
{
	bool   isValid
	array< EadpQuerryPlayerData > players
}


global struct EadpInviteToPlayData
{
	string	eaid
	string	name
	int		hardware
	int		reason
	EadpPresenceData ornull eadpPresence
}

global struct EadpInviteToPlayList
{
	bool   isValid
	array< EadpInviteToPlayData > invitations
}

global const string DISCOVERABLE_EVERYONE = "EVERYONE"
global const string DISCOVERABLE_NOONE = "NO_ONE"

global struct EadpPrivacySetting
{
	bool	isValid
	string	psnIdDiscoverable
	string	xboxTagDiscoverable
	string	displayNameDiscoverable
	string	steamNameDiscoverable
	string	nintendoNameDiscoverable
}

global enum eFriendStatus
{
	ONLINE_INGAME,
	ONLINE,
	ONLINE_AWAY,
	OFFLINE,
	REQUEST,
	COUNT
}

global struct Friend
{
	string id
	string unspoofedid = ""
	string hardware
	string unspoofedHardware = ""
	string name = "Unknown"
	string presence = ""
	int    status = eFriendStatus.OFFLINE
	bool   ingame = false
	bool   inparty = false
	bool   away = false
	bool   inleaderboard = false

	EadpPresenceData ornull eadpPresenceData
	EadpPeopleData ornull eadpData
}

global struct FriendsData
{
	array<Friend> friends
	bool          isValid
}

global struct CodeRedemptionGrant
{
	string alias
	int qty
	int type
}

global struct CommunityFriendsData
{
	string id
	string hardware
	string name
	string presence
	bool online
	bool ingame
	bool away
	EadpPresenceData ornull eadpPresenceData
}

global struct CommunityFriendsWithPresence
{
	bool isValid
	array<CommunityFriendsData> friends
}

global struct XProgProfileInfo
{
	int    platformId
	string nickname
}

global struct XProgMigrateData
{
	bool coolingDown
	int retryMinutes
	int processStatus
	bool hasMultipleProfiles

	string nickname
	int level

	int apexPacks
	int cosmetics
	int credits
	int crafting
	int premium
	int premiumNx
	int heirloom
	int heirloomShards

	string eaId
	array<XProgProfileInfo> profiles
}

global struct UMAttribute
{
	string key
	string value
}

global struct UMItem
{
	string type
	string name
	string value
	array<UMAttribute> attributes
}

global struct UMAction
{
	string name
	string trackingId
	array<UMItem> items
}

global struct UMData
{
	string triggerId
	string triggerName
	array<UMAction> actions
}
#endif // UI || CLIENT

#if CLIENT && DEVELOPER
global struct ChallengeDebugDataStruct // must match Code definition in c_challenge_debugger.cpp
{
	int guid
	int category
	bool complete
	string ref
	string debugInfo
}
#endif // #if CLIENT

//-----------------------------------------------------------------------------
// General
//-----------------------------------------------------------------------------

void function printl( var text )
{
	return print( text + "\n" )
}

void function CodeCallback_Precompile()
{
#if DEVELOPER
	// save the const table for later printing when documenting code consts
	//if ( Dev_CommandLineHasParm( "-scriptdocs" ) )
		getroottable().originalConstTable <- clone getconsttable()
#endif
}

