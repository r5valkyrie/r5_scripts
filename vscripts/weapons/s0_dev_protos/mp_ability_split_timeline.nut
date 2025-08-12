//Weapons handling fixed by @CafeFPS
//This ability is so cool omg

global function OnWeaponPrimaryAttack_split_timeline
global function MpAbilitySplitTimelineWeapon_Init
global function MpAbilitySplitTimelineWeapon_OnWeaponTossPrep

// #if SERVER
// global function BurnMeter_SplitTimeline
// #endif //SERVER

const SHIFTER_WARMUP_TIME = 0.0
const SHIFTER_WARMUP_TIME_FAST = 0.0

const string PHASEEXIT_IMPACT_TABLE_PROJECTILE	= "default"
const string PHASEEXIT_IMPACT_TABLE_TRACE		= "superSpectre_groundSlam_impact"

const asset SPLIT_TIMELINE_BASE_MDL = $"mdl/Weapons/sentry_shield/sentry_shield_proj.rmdl"

const string SPLIT_TIMELINE_WARNING_BEEP = "leviathan_footstep_distant"

global const float SPLIT_TIMELINE_DURATION 	= 60.0 //How long ability lasts and player returns to single timeline.

global int SPLIT_TIMELINES_TRAIL_FX_FRIENDLY
global int SPLIT_TIMELINES_TRAIL_FX_ENEMY

const DECOY_FX = $"P_flag_fx_foe"

struct TimelineWeaponData
{
	string weaponName = ""
	array<string> weaponMods
	int weaponAmmo
}

struct TimelineData
{
	vector origin
	vector angles
	vector cameraOrigin
	vector cameraAngles
	vector velocity
	entity holoMarker
	entity holoBase
	int statusEffectID
	bool wasCrouched
	bool wasInContextAction
	bool wasDoubleJumping
	int health
	int shield
	int ammoPool

	TimelineWeaponData& activeMainWeapon
	TimelineWeaponData& activeAltHandWeapon
	array<TimelineWeaponData> otherWeapons
}

struct SplitData
{
	TimelineData& activeTimeline
	TimelineData& otherTimeline
}

struct CameraFlickerData
{
	float duration 			//Duration of time for camera to flicker between player view and camera ent.
	float frequencyStart	//Frequency of camera flicker to camera ent at start of duration.
	float frequencyEnd		//Frequency of camera flicker to camera ent at end of duration.
	float frequencyVariance	//Amount of random variance in flicker frequency
	float holdTimeStart		//Time to hold view through camera ent at start of duration.
	float holdTimeEnd		//Time to hold view through camera ent at end of duration.
	float holdTimeVariance	//Amount of random variance in hold time.
}

struct
{
	int phaseExitExplodeImpactTable

	#if SERVER
	table < entity, SplitData > splitTimelines
	table < entity, vector > lastActivateAngles
	table < entity, TimelineWeaponData > swappedOffhands
	#endif //SERVER

	#if CLIENT
	int colorCorrection
	bool hasTimeline = false
	#endif //CLIENT
} file

void function MpAbilitySplitTimelineWeapon_Init()
{
	file.phaseExitExplodeImpactTable = PrecacheImpactEffectTable( PHASEEXIT_IMPACT_TABLE_PROJECTILE )
	PrecacheImpactEffectTable( PHASEEXIT_IMPACT_TABLE_TRACE )

	PrecacheModel( SPLIT_TIMELINE_BASE_MDL )

	SPLIT_TIMELINES_TRAIL_FX_FRIENDLY = PrecacheParticleSystem( $"P_ar_holopilot_trail" )
	SPLIT_TIMELINES_TRAIL_FX_ENEMY = PrecacheParticleSystem( $"P_ar_holopilot_trail_enemy" )

	RegisterSignal( "SplitTimeline_ChangePlayerStance" )
	RegisterSignal( "SplitTimeline_ForceSwitch" )
	RegisterSignal( "SplitTimeline_ForceAbilityEnd" )
	RegisterSignal( "SplitTimeline_AbilityEndWeaponSwap" )

	#if CLIENT
		RegisterSignal( "SplitTimeline_StopColorCorrection" )
		file.colorCorrection = ColorCorrection_Register( "materials/correction/ability_shadow_duel.raw_hdr" )
		StatusEffect_RegisterEnabledCallback( eStatusEffect.split_timeline, SplitTimeline_StartVisualEffect )
		StatusEffect_RegisterDisabledCallback( eStatusEffect.split_timeline, SplitTimeline_StopVisualEffect )
	#endif
}

void function MpAbilitySplitTimelineWeapon_OnWeaponTossPrep( entity weapon, WeaponTossPrepParams prepParams )
{
	entity weaponOwner = weapon.GetWeaponOwner()
	weapon.SetScriptTime0( 0.0 )
}

var function OnWeaponPrimaryAttack_split_timeline( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	float warmupTime = SHIFTER_WARMUP_TIME

	entity weaponOwner = weapon.GetWeaponOwner()
	Assert ( weaponOwner.IsPlayer() )

	//Save the exact angle the player was facing the moment they activated the weapon. It's disorienting to have any angle changes occuring during the activate
	//animation affect the angle you are facing when you switch timelines.
	#if SERVER
	if ( !( weaponOwner in file.lastActivateAngles ) )
		file.lastActivateAngles[ weaponOwner ] <- weaponOwner.GetAngles()
	else
		file.lastActivateAngles[ weaponOwner ] = weaponOwner.GetAngles()
	#endif //SERVER

	bool hasTimeline = false
	#if SERVER
		hasTimeline = ( weaponOwner in file.splitTimelines )
	#else
		hasTimeline = file.hasTimeline
	#endif //SERVER

	#if SERVER
		if ( !hasTimeline )
		{
			if ( weapon.GetWeaponPrimaryClipCount() < weapon.GetWeaponSettingInt( eWeaponVar.ammo_per_shot ) )
				return 0
		}
	#endif

	//If we have a marked spot, recall to that spot
	if ( hasTimeline )
	{
		int phaseResult = PhaseShift( weaponOwner, warmupTime, weapon.GetWeaponSettingFloat( eWeaponVar.fire_duration ) )
		if ( phaseResult )
		{
			#if BATTLECHATTER_ENABLED && SERVER
				TryPlayWeaponBattleChatterLine( weaponOwner, weapon )
			#endif

			//recall player
			#if SERVER

				//Force the timeline to switch
				weaponOwner.Signal( "SplitTimeline_ForceSwitch" )
				thread SplitTimelineScreenFX( weaponOwner, 1.0, 1.0, 0.0 ) //Time split Screen FX

			#endif

			return 0//weapon.GetWeaponSettingInt( eWeaponVar.ammo_min_to_fire )
		}
	}

	//If we do not have a marked spot, store the current location as a marked spot.
	#if SERVER
		int phaseResult = PhaseShift( weaponOwner, warmupTime, weapon.GetWeaponSettingFloat( eWeaponVar.fire_duration ) )
		if ( phaseResult )
		{
			thread SplitTimelines( weaponOwner, SPLIT_TIMELINE_DURATION )

			return weapon.GetWeaponSettingInt( eWeaponVar.ammo_per_shot )
		}
	#endif //SERVER

	PlayerUsedOffhand( weaponOwner, weapon )

	return 0
}

void function DoPhaseExitExplosion( entity player, entity phaseWeapon )
{
#if CLIENT
	if ( !phaseWeapon.ShouldPredictProjectiles() )
		return
#endif //

	player.PhaseShiftCancel()

	vector origin = player.GetWorldSpaceCenter() + player.GetForwardVector() * 16.0

	//DebugDrawLine( player.GetWorldSpaceCenter(), origin, 255, 0, 0, true, 5.0 )

	int damageType = (DF_RAGDOLL | DF_EXPLOSION | DF_ELECTRICAL)
	WeaponFireGrenadeParams fireGrenadeParams
	fireGrenadeParams.pos = origin
	fireGrenadeParams.vel = <0,0,1>
	fireGrenadeParams.angVel = <0,0,0>
	fireGrenadeParams.fuseTime = 0.01
	fireGrenadeParams.scriptTouchDamageType = damageType
	fireGrenadeParams.scriptExplosionDamageType = damageType
	fireGrenadeParams.clientPredicted = true
	fireGrenadeParams.lagCompensated = true
	fireGrenadeParams.useScriptOnDamage = true
	entity nade = phaseWeapon.FireWeaponGrenade( fireGrenadeParams )
	if ( !nade )
		return

	player.PhaseShiftBegin( 0, 1.0 )

	nade.SetImpactEffectTable( file.phaseExitExplodeImpactTable )
	nade.GrenadeExplode( <0,0,0> )

#if SERVER
	PlayImpactFXTable( player.GetOrigin(), player, PHASEEXIT_IMPACT_TABLE_TRACE, SF_ENVEXPLOSION_INCLUDE_ENTITIES )
#endif //
}

#if SERVER
void function CreateTimelinesForPlayer( entity player )
{
	Assert ( !( player in file.splitTimelines ) )

	//Add color correction for time split
	int statusID = StatusEffect_AddTimed( player, eStatusEffect.split_timeline, 1.0, SPLIT_TIMELINE_DURATION, SPLIT_TIMELINE_DURATION )

	//if the player is mantling, put them in a safe spot.
	if ( player.IsMantling() )
		player.ClearTraverse()

	TimelineData activeTimeline
	activeTimeline.origin 			= player.GetOrigin()
	activeTimeline.angles 			= file.lastActivateAngles[ player ]
	activeTimeline.cameraOrigin		= player.CameraPosition()
	activeTimeline.cameraAngles  	= player.CameraAngles()
	activeTimeline.velocity 		= player.GetVelocity()
	activeTimeline.wasCrouched		= player.IsCrouched()
	activeTimeline.wasInContextAction = player.ContextAction_IsActive()
	activeTimeline.wasDoubleJumping = player.IsDoubleJumping()
	activeTimeline.health			= player.GetHealth()
	activeTimeline.shield 			= player.GetShieldHealth()
	activeTimeline.ammoPool			= player.AmmoPool_GetCount( eAmmoPoolType.bullet )
	activeTimeline.statusEffectID 	= statusID
	PackageTimelineWeaponDataForPlayer( player, activeTimeline )

	TimelineData otherTimeline
	otherTimeline.origin 			= player.GetOrigin()
	otherTimeline.angles 			= file.lastActivateAngles[ player ]
	otherTimeline.cameraOrigin		= player.CameraPosition()
	otherTimeline.cameraAngles  	= player.CameraAngles()
	otherTimeline.velocity 			= player.GetVelocity()
	otherTimeline.wasCrouched		= player.IsCrouched()
	otherTimeline.wasInContextAction = player.ContextAction_IsActive()
	otherTimeline.wasDoubleJumping  = player.IsDoubleJumping()
	otherTimeline.health			= player.GetHealth()
	otherTimeline.shield 			= player.GetShieldHealth()
	otherTimeline.ammoPool			= player.AmmoPool_GetCount( eAmmoPoolType.bullet )
	otherTimeline.statusEffectID 	= statusID

	CreateHoloPilotTimelineMarker( player, otherTimeline )
	SetHoloVisibilityFlags( otherTimeline, ENTITY_VISIBLE_TO_OWNER )
	PackageTimelineWeaponDataForPlayer( player, otherTimeline )

	SplitData splitData
	splitData.activeTimeline = activeTimeline
	splitData.otherTimeline = otherTimeline

	file.splitTimelines[ player ] <- splitData
}

void function UpdateActiveTimelineForPlayer( entity player )
{
	Assert ( player in file.splitTimelines )

	//if the player is mantling, put them in a safe spot.
	if ( player.IsMantling() )
		player.ClearTraverse()

	TimelineData data 		= file.splitTimelines[ player ].activeTimeline
	data.origin 			= player.GetOrigin()
	data.angles 			= file.lastActivateAngles[ player ]
	data.cameraOrigin		= player.CameraPosition()
	data.cameraAngles  		= player.CameraAngles()
	data.velocity 			= player.GetVelocity()
	data.wasCrouched		= player.IsCrouched()
	data.wasInContextAction = player.ContextAction_IsActive()
	data.wasDoubleJumping  	= player.IsDoubleJumping()
	data.health				= player.GetHealth()
	data.shield 			= player.GetShieldHealth()
	data.ammoPool			= player.AmmoPool_GetCount( eAmmoPoolType.bullet )

	CreateHoloPilotTimelineMarker( player, data )

	PackageTimelineWeaponDataForPlayer( player, data )

	file.splitTimelines[ player ].activeTimeline = data
}

void function SwitchActiveTimelineForPlayer( entity player )
{
	Assert ( player in file.splitTimelines )
	TimelineData currentActive = file.splitTimelines[ player ].activeTimeline
	TimelineData currentOther  = file.splitTimelines[ player ].otherTimeline

	DestroyTimelineHoloEntsForPlayer( player, currentOther )

	file.splitTimelines[ player ].activeTimeline = currentOther
	file.splitTimelines[ player ].otherTimeline  = currentActive
}

void function DestroySplitTimelinesForPlayer( entity player )
{
	Assert ( player in file.splitTimelines )
	TimelineData currentOther  = file.splitTimelines[ player ].otherTimeline

	//Stop color correction
	int statusID = currentOther.statusEffectID
	StatusEffect_Stop( player, statusID )

	DestroyTimelineHoloEntsForPlayer( player, currentOther )
	delete file.splitTimelines[ player ]
}

void function DestroyTimelineHoloEntsForPlayer( entity player, TimelineData data )
{
	data.holoMarker.Decoy_Die()
	data.holoBase.Destroy()
}

void function SyncPlayerToActiveTimeline( entity player )
{
	Assert ( player in file.splitTimelines )

	TimelineData data = file.splitTimelines[ player ].activeTimeline

	vector startOrigin	= player.GetOrigin()
	vector timelineOrigin = data.origin

	player.SetOrigin( timelineOrigin )
	player.SetAngles( data.angles )

	if ( data.wasCrouched )
		thread SplitTimelineCrouchPlayer( player )
	else
		thread SplitTimelineStandPlayer( player )

	if ( data.wasDoubleJumping )
		player.ConsumeDoubleJump()
	else
		player.TouchGround()

	entity groundEnt = player.GetGroundEntity()
	bool safeTeleport = PlayerCanTeleportHere( player, timelineOrigin )
	vector ornull clampSafeSpot = NavMesh_ClampPointForHull( timelineOrigin, HULL_HUMAN )
	vector safeSpot = clampSafeSpot == null ? startOrigin : expect vector ( clampSafeSpot )

	//If we would recall to a spot where we are stuck in geo, put us in a safe location.

	if ( !safeTeleport )
		PutEntityInSafeSpot( player, null, groundEnt, timelineOrigin + < 0, 0, 64 >, safeSpot )

	//Set velocity after force crouch to perserve slide momentum.
	player.SetVelocity( data.velocity )

	player.SetHealth( data.health )
	player.SetShieldHealth( data.shield )
	player.AmmoPool_SetCount( eAmmoPoolType.bullet, data.ammoPool )

	SyncWeaponTimelineDataForPlayer( player, data )
}

void function PackageTimelineWeaponDataForPlayer( entity player, TimelineData data ) //Cafe was here. Just a workaround for the videos to avoid melee crash. Melee does not has to be removed / given. Only primary weapons. Probably save slot to give them in the proper slot.
{
	entity lastActiveMainWeapon = player.GetLatestPrimaryWeaponForIndexZeroOrOne( eActiveInventorySlot.mainHand )
	entity activeAltHandWeapon = player.GetActiveWeapon( eActiveInventorySlot.altHand )

	// array<TimelineWeaponData> otherWeapons
	array<entity> weapons = SURVIVAL_GetPrimaryWeaponsSorted( player ) //player.GetMainWeapons()
	// foreach ( entity weapon in weapons )
	// {
		TimelineWeaponData weaponData0
		if( weapons.len() > 0 )
		{
			weaponData0.weaponName = weapons[0].GetWeaponClassName()
			weaponData0.weaponMods = weapons[0].GetMods()
			weaponData0.weaponAmmo = weapons[0].GetWeaponPrimaryClipCount()
		}

		TimelineWeaponData weaponData1
		if( weapons.len() > 1 )
		{
			weaponData1.weaponName = weapons[1].GetWeaponClassName()
			weaponData1.weaponMods = weapons[1].GetMods()
			weaponData1.weaponAmmo = weapons[1].GetWeaponPrimaryClipCount()
		}
		
		// if ( lastActiveMainWeapon == weapon )
			data.activeMainWeapon = weaponData0
		// else if ( activeAltHandWeapon == weapon )
			data.activeAltHandWeapon = weaponData1
		// else if ( DoesWeaponTriggerMeleeAttack( weapon ) ) // TODO: fix for kunai and other melee
			// otherWeapons.append( weaponData )
	// }
	// data.otherWeapons = otherWeapons
}

void function SyncWeaponTimelineDataForPlayer( entity player, TimelineData data )
{
	TakeAllGuns( player )

	//If the player did not have an active weapon in this timeline, early out.
	if ( data.activeMainWeapon.weaponName == "" )
	{
		player.SetActiveWeaponBySlot(eActiveInventorySlot.mainHand, WEAPON_INVENTORY_SLOT_PRIMARY_2 ) //Player didn't have primary weapons, set melee active.
		return
	}

	entity activeMainWeapon = player.GiveWeapon( data.activeMainWeapon.weaponName, WEAPON_INVENTORY_SLOT_PRIMARY_0, data.activeMainWeapon.weaponMods )

	if ( activeMainWeapon.GetWeaponSettingInt( eWeaponVar.ammo_clip_size ) )
		activeMainWeapon.SetWeaponPrimaryClipCount( data.activeMainWeapon.weaponAmmo )

	// activeMainWeapon.DeployInstant()

	if ( data.activeAltHandWeapon.weaponName != "" )
	{
		entity altHandWeapon = player.GiveWeapon( data.activeAltHandWeapon.weaponName, WEAPON_INVENTORY_SLOT_PRIMARY_1, data.activeAltHandWeapon.weaponMods )

		if ( altHandWeapon.GetWeaponSettingInt( eWeaponVar.ammo_clip_size ) )
			altHandWeapon.SetWeaponPrimaryClipCount( data.activeAltHandWeapon.weaponAmmo )

		// player.SetActiveWeaponByName( eActiveInventorySlot.altHand, altHandWeapon.GetWeaponClassName() )
	}

	// foreach ( TimelineWeaponData wData in data.otherWeapons )
	// {
		// entity weapon = player.GiveWeapon( wData.weaponName, WEAPON_INVENTORY_SLOT_ANY, wData.weaponMods )
		// if ( weapon.GetWeaponSettingInt( eWeaponVar.ammo_clip_size ) )
			// weapon.SetWeaponPrimaryClipCount( wData.weaponAmmo )
	// }

	player.SetActiveWeaponBySlot(eActiveInventorySlot.mainHand, WEAPON_INVENTORY_SLOT_PRIMARY_0 )
}

//This function actually splits and updates the timelines.
void function SplitTimelines( entity player, float duration )
{
	Assert ( IsNewThread(), "Must be threaded off." )
	player.EndSignal( "OnDeath" )
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "SplitTimeline_ForceAbilityEnd" )

	//Make the duel timelines
	CreateTimelinesForPlayer( player )

	OnThreadEnd(
	function() : ( player )
		{
			if ( IsValid( player ) )
			{
				FadeOutSoundOnEntity( player, "amb_emit_s2s_rushing_wind_strong_v2_04", 0.5 )
				DestroySplitTimelinesForPlayer( player )
			}
		}
	)

	EmitSoundOnEntityOnlyToPlayer( player, player, "amb_emit_s2s_rushing_wind_strong_v2_04" )
	thread UpdatePlayerSplitTimelineVisuals( player, duration, 1.0, 0.0 ) //Time split Screen FX
	thread SplitTimelineHUDTimeUpdate( player, duration )
	thread SplitTimelineEndAfterTime( player, duration )
	while ( true )
	{
		player.WaitSignal( "SplitTimeline_ForceSwitch" )
		UpdateActiveTimelineForPlayer( player )
		SwitchActiveTimelineForPlayer( player )
		SyncPlayerToActiveTimeline( player )
		WaitFrame()
	}
}

void function SplitTimelineHUDTimeUpdate( entity player, float duration )
{
	Assert ( IsNewThread(), "Must be threaded off." )
	player.EndSignal( "OnDeath" )
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "SplitTimeline_ForceAbilityEnd" )

	OnThreadEnd(
	function() : ( player )
		{
			if ( IsValid( player ) )
			{
				//( IsAlive( player ) )
				//	SendHudMessage( player, "Timeline Normalized", -1, 0.4, 255, 0, 0, 0, 0.0, 4.0, 0.0 )
			}
		}
	)

	//SendHudMessage( player, "Timelines Deviated", -1, 0.4, 255, 0, 0, 0, 0.5, 4.0, 0.5 )

	float endTime = Time() + duration
	float nextBeepTime = Time()

	while ( Time() <= endTime )
	{
		float timeRemaining = endTime - Time()
		float progressFrac 	= GraphCapped( timeRemaining, 0.0, duration, 1.0, 0.0 )

		float progressPercent = floor( progressFrac * 100 )

		if ( Time() >= nextBeepTime )
		{
			EmitSoundOnEntityOnlyToPlayer( player, player, SPLIT_TIMELINE_WARNING_BEEP )
			thread SplitTimelineScreenFX( player, 0.5, 0.5, 0.0 ) //Time split Screen FX

			if ( timeRemaining <= 5.0 )
				nextBeepTime = Time() + 1.0
			else if ( timeRemaining <= 30.0 )
				nextBeepTime = Time() + 5.0
			else
				nextBeepTime = Time() + 5.0
		}

		WaitFrame()
	}
}

void function SplitTimelineEndAfterTime( entity player, float duration )
{
	Assert ( IsNewThread(), "Must be threaded off." )
	player.EndSignal( "OnDeath" )
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "SplitTimeline_ForceAbilityEnd" )
	wait duration
	player.Signal( "SplitTimeline_AbilityEndWeaponSwap" )
	player.Signal( "SplitTimeline_ForceAbilityEnd" )
}

void function SplitTimelineCrouchPlayer( entity player )
{
	Assert ( IsNewThread(), "Must be threaded off." )
	Signal( player, "SplitTimeline_ChangePlayerStance" )
	EndSignal( player, "OnDeath" )
	EndSignal( player, "SplitTimeline_ChangePlayerStance" )
	player.ForceCrouch()
	OnThreadEnd(
	function() : ( player )
		{
			if ( IsValid( player ) )
			{
				player.UnforceCrouch()
			}
		}
	)
	wait 0.2
}

void function SplitTimelineStandPlayer( entity player )
{
	Assert ( IsNewThread(), "Must be threaded off." )
	Signal( player, "SplitTimeline_ChangePlayerStance" )
	EndSignal( player, "OnDeath" )
	EndSignal( player, "SplitTimeline_ChangePlayerStance" )
	player.ForceStand()
	OnThreadEnd(
	function() : ( player )
		{
			if ( IsValid( player ) )
			{
				player.UnforceStand()
			}
		}
	)
	wait 0.2
}

void function CreateHoloPilotTimelineMarker( entity player, TimelineData data )
{
	Assert( player )
	Assert( !IsValid( data.holoMarker ) )
	Assert( !IsValid( data.holoBase ) )

	float displacementDistance = 30.0

	float stickPercentToRun = 0.65

	//CreateAnimatedPlayerDecoy
	entity decoy = player.CreatePlayerDecoy( $"", $"", -1, -1, stickPercentToRun, false )
	decoy.SetMaxHealth( 50 )
	decoy.SetHealth( 50 )
	decoy.SetTakeDamageType( DAMAGE_NO )
	decoy.SetOwner( player )
	SetTeam( decoy, player.GetTeam() )
	SetObjectCanBeMeleed( decoy, false )
	decoy.SetTimeout( -1 )
	decoy.kv.VisibilityFlags = ENTITY_VISIBLE_TO_OWNER
	decoy.Hide()

	SetupDecoy_SplitTimeline( player, decoy )

	entity base = CreatePropDynamic( SPLIT_TIMELINE_BASE_MDL, decoy.GetOrigin(), decoy.GetAngles(), 0 )
	base.DisableHibernation()
	base.SetOwner( player )
	base.kv.VisibilityFlags = ENTITY_VISIBLE_TO_OWNER
	//DropToGround( base )
	base.Hide()

	thread MarkBaseUpdate( base, decoy ) //TEMP PROTOTYPE HACK: Force decoy to stay put regardless of player movement.

	data.holoMarker = decoy
	data.holoBase 	= base
}

void function SetupDecoy_SplitTimeline( entity player, entity decoy )
{
	decoy.SetDeathNotifications( false )
	decoy.SetPassThroughThickness( 0 )
	decoy.SetNameVisibleToOwner( true )
	decoy.SetNameVisibleToFriendly( false )
	decoy.SetNameVisibleToEnemy( false )
	decoy.SetFlickerRate( 1.0 )
	decoy.SetDecoyRandomPulseRateMax( 0.5 ) //pulse amount per second
	decoy.SetFadeDistance( DECOY_FADE_DISTANCE )
	decoy.SetNoTarget( true )
	decoy.SetNoTargetSmartAmmo( true )
	//decoy.SetTitle( "#WPN_MARK_RECALL_TITLE" )

	int friendlyTeam = decoy.GetTeam()
	EmitSoundOnEntityOnlyToPlayer( decoy, player, "holopilot_loop" ) //loopingSound
	decoy.decoy.loopingSounds = [ "holopilot_loop" ]

	Highlight_SetFriendlyHighlight( decoy, "friendly_player_decoy" )
	Highlight_SetOwnedHighlight( decoy, "friendly_player_decoy" )
	decoy.e.hasDefaultEnemyHighlight = player.e.hasDefaultEnemyHighlight
	SetDefaultMPEnemyHighlight( decoy )

	int attachID = decoy.LookupAttachment( "CHESTFOCUS" )

	var childEnt = player.FirstMoveChild()
	while ( childEnt != null )
	{
		expect entity( childEnt )

		bool isBattery = false
		bool createHologram = false
		switch ( childEnt.GetClassName() )
		{
			case "item_titan_battery":
			{
				isBattery = true
				createHologram = true
				break
			}

			case "item_flag":
			{
				createHologram = true
				break
			}
		}

		asset modelName = childEnt.GetModelName()
		if ( createHologram && modelName != $"" && childEnt.GetParentAttachment() != "" )
		{
			entity decoyChildEnt = CreatePropDynamic( modelName, <0,0,0>, <0,0,0>, 0 )
			decoyChildEnt.Highlight_SetInheritHighlight( true )
			decoyChildEnt.SetParent( decoy, childEnt.GetParentAttachment() )

			thread Decoy_FlagFX( decoy, decoyChildEnt )
		}

		childEnt = childEnt.NextMovePeer()
	}

	entity holoPilotTrailFXFriendly = StartParticleEffectOnEntity_ReturnEntity( decoy, SPLIT_TIMELINES_TRAIL_FX_FRIENDLY, FX_PATTACH_POINT_FOLLOW, attachID )
	SetTeam( holoPilotTrailFXFriendly, friendlyTeam )
	holoPilotTrailFXFriendly.SetOwner( player )
	holoPilotTrailFXFriendly.kv.VisibilityFlags = ENTITY_VISIBLE_TO_FRIENDLY | ENTITY_VISIBLE_TO_OWNER

	entity holoPilotTrailFXEnemy = StartParticleEffectOnEntity_ReturnEntity( decoy, SPLIT_TIMELINES_TRAIL_FX_ENEMY, FX_PATTACH_POINT_FOLLOW, attachID )
	SetTeam( holoPilotTrailFXEnemy, friendlyTeam )
	holoPilotTrailFXEnemy.SetOwner( player )
	holoPilotTrailFXEnemy.kv.VisibilityFlags = ENTITY_VISIBLE_TO_ENEMY

	decoy.decoy.fxHandles.append( holoPilotTrailFXFriendly )
	decoy.decoy.fxHandles.append( holoPilotTrailFXEnemy )
	decoy.SetFriendlyFire( false )
	decoy.SetKillOnCollision( false )
}

void function MarkBaseUpdate( entity base, entity decoy )
{
	Assert ( IsNewThread(), "Must be threaded off." )
	base.EndSignal( "OnDestroy" )
	decoy.EndSignal( "OnDestroy" )

	decoy.SetParent( base, "", true )
	vector localOffset = decoy.GetLocalOrigin()

	while ( true )
	{
		decoy.SetLocalOrigin( localOffset )
		WaitFrame()
	}
}

void function SetHoloVisibilityFlags( TimelineData data, int visFlag )
{
	entity holoMarker 	= data.holoMarker
	entity holoBase		= data.holoBase
	holoMarker.kv.VisibilityFlags = visFlag
	holoBase.kv.VisibilityFlags = visFlag
	foreach ( entity fx in holoMarker.decoy.fxHandles )
	{
		fx.kv.VisibilityFlags = visFlag
	}
}

void function FlickerTimelineViewCamera( entity player, CameraFlickerData flickerData )
{
	Assert ( IsNewThread(), "Must be threaded off." )
	player.EndSignal( "OnDeath" )
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "SplitTimeline_ForceAbilityEnd" )

	TimelineData data = file.splitTimelines[ player ].otherTimeline

	entity camera = CreateEntity( "point_viewcontrol" )
	camera.kv.spawnflags = 56 // infinite hold time, snap to goal angles, make player non-solid

	camera.SetOrigin( data.cameraOrigin )
	camera.SetAngles( data.cameraAngles )
	DispatchSpawn( camera )

	OnThreadEnd(
	function() : ( player, camera )
		{
			if ( IsValid( player ) )
			{
				player.SetPredictionEnabled( true )
				player.ClearViewEntity()
			}

			if ( IsValid( camera ) )
				camera.Destroy()
		}
	)

	float viewUpdateTime  = Time()
	bool awayView = false

	float endTime = Time() + flickerData.duration
	while ( Time() <= endTime )
	{
		WaitFrame()
		float timeRemaining 	= endTime - Time()
		float frequency 		= GraphCapped( timeRemaining, 0.0, flickerData.duration, flickerData.frequencyEnd, flickerData.frequencyStart )
		frequency += RandomFloatRange( -flickerData.frequencyVariance, flickerData.frequencyVariance )

		float holdTime 			= GraphCapped( timeRemaining, 0.0, flickerData.duration, flickerData.holdTimeEnd, flickerData.holdTimeStart )
		holdTime += RandomFloatRange( -flickerData.holdTimeVariance, flickerData.holdTimeVariance )

		data = file.splitTimelines[ player ].otherTimeline
		camera.SetOrigin( data.cameraOrigin )
		camera.SetAngles( data.cameraAngles )

		if ( viewUpdateTime <= Time() )
		{
			float nextTime = frequency
			if ( awayView )
			{
				awayView = false
				player.ClearViewEntity()
				player.SetPredictionEnabled( true )
			}
			else
			{
				awayView = true
				player.SetViewEntity( camera, true )
				player.SetPredictionEnabled( false )
				nextTime = holdTime
			}

			viewUpdateTime = Time() + nextTime
		}
	}
}

void function UpdatePlayerSplitTimelineVisuals( entity player, float duration, float startIntensity, float endIntensity )
{
	Assert ( IsNewThread(), "Must be threaded off." )
	player.EndSignal( "OnDeath" )
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "SplitTimeline_ForceAbilityEnd" )

	CameraFlickerData flickerData
	flickerData.duration = 1.00
	flickerData.frequencyStart = 0.0625
	flickerData.frequencyEnd = 0.25
	flickerData.frequencyVariance = 0.0625
	flickerData.holdTimeStart = 0.0625
	flickerData.holdTimeEnd	= 0.0625
	flickerData.holdTimeVariance = 0.0

	float endTime = Time() + ( duration - 5.0 )

	EmitSoundOnEntityOnlyToPlayer( player, player, EMP_IMPARED_SOUND )
	thread FlickerTimelineViewCamera( player, flickerData )
	thread SplitTimelineScreenFX( player, 2.0, 1.0, 0.0 )
	wait 2.0

	printt ( endTime - Time() )
	thread SplitTimelineScreenFX( player, endTime - Time(), 0.05, 0.05 )
	wait ( endTime - Time() )
	thread SplitTimelineScreenFX( player, 5.0, 0.0, 1.0 )
	//wait 5.0
	EmitSoundOnEntityOnlyToPlayer( player, player, EMP_IMPARED_SOUND )
	flickerData.duration = 1.00
	flickerData.frequencyStart = 0.0625
	flickerData.frequencyEnd = 0.25
	flickerData.frequencyVariance = 0.0625
	flickerData.holdTimeStart = 0.0625
	flickerData.holdTimeEnd	= 0.0625
	flickerData.holdTimeVariance = 0.0
	thread FlickerTimelineViewCamera( player, flickerData )
	wait 5.0
}

void function SplitTimelineScreenFX( entity player, float duration, float startIntensity, float endIntensity )
{
	Assert ( IsNewThread(), "Must be threaded off." )
	player.EndSignal( "OnDeath" )
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "SplitTimeline_ForceAbilityEnd" )

	const SCREEN_DISTORT_SCREEN_EFFECTS 	= 1.0
	const SCREEN_DISTORT_DURATION			= 0.35
	const SCREEN_DISTORT_FADEOUT_DURATION	= 0.35

	const DESYNC_PULSE_SCREEN_EFFECTS		= 1.0
	const DESYNC_PULSE_DURATION				= 1.5
	const DESYNC_PULSE_FADEOUT_DURATION		= 0.5

	float pulseUpdateTime = Time()
	float viewUpdateTime  = Time() + ( duration / 2 )

	float endTime = Time() + duration
	while ( Time() <= endTime )
	{
		WaitFrame()

		float timeRemaining = endTime - Time()
		float progressFrac 	= GraphCapped( timeRemaining, duration, 0.0, 0.0, 1.0 )

		float empFxStart 	= SCREEN_DISTORT_SCREEN_EFFECTS * startIntensity
		float empFxEnd 		= SCREEN_DISTORT_SCREEN_EFFECTS * endIntensity

		float desyncFxStart	= DESYNC_PULSE_SCREEN_EFFECTS * startIntensity
		float desyncFxEnd 	= DESYNC_PULSE_SCREEN_EFFECTS * endIntensity

		float screenEffectAmplitude = GraphCapped( progressFrac, 0.0, 1.0, empFxStart, empFxEnd )
		float desyncEffectAmplitude = GraphCapped( progressFrac, 0.0, 1.0, desyncFxStart, desyncFxEnd )

		StatusEffect_AddTimed( player, eStatusEffect.emp, screenEffectAmplitude, SCREEN_DISTORT_DURATION, SCREEN_DISTORT_FADEOUT_DURATION )

		if ( pulseUpdateTime <= Time() )
		{
		//	StatusEffect_AddTimed( player, eStatusEffect.timeshift_visual_effect, desyncEffectAmplitude, DESYNC_PULSE_DURATION, DESYNC_PULSE_FADEOUT_DURATION )
			pulseUpdateTime = Time() + DESYNC_PULSE_DURATION
		}
	}
}


void function TakeAllGuns( entity player )
{
	array<entity> weapons = SURVIVAL_GetPrimaryWeapons( player ) //player.GetMainWeapons()
	foreach ( index, weaponEnt in weapons )
	{
		string weapon = weaponEnt.GetWeaponClassName()
		player.TakeWeaponNow( weapon )
	}
}

void function Decoy_FlagFX( entity decoy, entity decoyChildEnt )
{
	decoy.EndSignal( "OnDeath" )
	decoy.EndSignal( "CleanupFXAndSoundsForDecoy" )

	SetTeam( decoyChildEnt, decoy.GetTeam() )
	entity flagTrailFX = StartParticleEffectOnEntity_ReturnEntity( decoyChildEnt, GetParticleSystemIndex( DECOY_FX ), FX_PATTACH_POINT_FOLLOW, decoyChildEnt.LookupAttachment( "fx_end" ) )
	flagTrailFX.kv.VisibilityFlags = ENTITY_VISIBLE_TO_ENEMY

	OnThreadEnd(
		function() : ( flagTrailFX, decoyChildEnt )
		{
			if ( IsValid( flagTrailFX ) )
				flagTrailFX.Destroy()

			if ( IsValid( decoyChildEnt ) )
				decoyChildEnt.Destroy()
		}
	)

	WaitForever()
}


#endif //SERVER

#if CLIENT
void function UpdatePlayerScreenColorCorrectionSplitTimeline( entity player, vector recallOrigin )
{
	Assert ( IsNewThread(), "Must be threaded off." )
	Assert ( player == GetLocalViewPlayer() )

	player.EndSignal( "OnDeath" )
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "SplitTimeline_StopColorCorrection" )

	OnThreadEnd(
	function() : ( )
		{
			ColorCorrection_SetWeight( file.colorCorrection, 0.0 )
			ColorCorrection_SetExclusive( file.colorCorrection, false )
		}
	)

	ColorCorrection_SetExclusive( file.colorCorrection, true )
	ColorCorrection_SetWeight( file.colorCorrection, 1.0 )
	WaitForever()
}

void function SplitTimeline_StartVisualEffect( entity ent, int statusEffect, bool actuallyChanged )
{
	if ( !actuallyChanged )
		return

	if ( ent != GetLocalViewPlayer() )
		return

	file.hasTimeline = true
	thread UpdatePlayerScreenColorCorrectionSplitTimeline( ent, ent.GetOrigin() )

}

void function SplitTimeline_StopVisualEffect( entity ent, int statusEffect, bool actuallyChanged )
{
	if ( !actuallyChanged )
		return

	if ( ent != GetLocalViewPlayer() )
		return

	file.hasTimeline = false
	ent.Signal( "SplitTimeline_StopColorCorrection" )
}

#endif //CLIENT

//Titan
#if SERVER
void function BurnMeter_SplitTimeline( entity player )
{
	player.Signal( "SplitTimeline_ForceAbilityEnd" )
	if ( !( player in file.swappedOffhands ) )
	{
		entity offhandWeapon = player.GetOffhandWeapon( 1 )
		string offhandName = offhandWeapon.GetWeaponClassName()
		int offhandAmmo = offhandWeapon.GetWeaponPrimaryClipCount()
		array<string> offhandMods = offhandWeapon.GetMods()

		TimelineWeaponData data
		data.weaponName = offhandName
		data.weaponMods = offhandMods
		data.weaponAmmo = offhandAmmo
		file.swappedOffhands[ player ] <- data

		player.TakeOffhandWeapon( 1 )

		array< string > mods
		player.GiveOffhandWeapon( "mp_ability_split_timeline", 1, mods )
		entity splitTimeline = player.GetOffhandWeapon( 1 )
		splitTimeline.SetWeaponPrimaryClipCount( 1 )

		thread SplitTimelineHandleWeaponSwap( player )
	}

	entity weapon = player.GetOffhandWeapon( 1 )

	int phaseResult = PhaseShift( player, 0.0, weapon.GetWeaponSettingFloat( eWeaponVar.fire_duration ) )
	if ( phaseResult )
	{
		if ( !( player in file.lastActivateAngles ) )
			file.lastActivateAngles[ player ] <- player.GetAngles()
		else
			file.lastActivateAngles[ player ] = player.GetAngles()

		thread SplitTimelines( player, SPLIT_TIMELINE_DURATION )
	}
}

void function SplitTimelineHandleWeaponSwap( entity player )
{
	Assert ( IsNewThread(), "Must be threaded off." )
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "OnDeath" )

	OnThreadEnd(
	function() : ( player )
		{
			if ( IsValid( player ) )
			{
				if ( IsAlive( player ) )
				{
					player.TakeOffhandWeapon( 1 )
					string offhandName = file.swappedOffhands[ player ].weaponName
					array<string> offhandMods = file.swappedOffhands[ player ].weaponMods
					int offhandAmmo = file.swappedOffhands[ player ].weaponAmmo
					player.GiveOffhandWeapon( offhandName, 1, offhandMods )
					entity offhandWeapon = player.GetOffhandWeapon( 1 )
					offhandWeapon.SetWeaponPrimaryClipCount( offhandAmmo )
				}

				delete file.swappedOffhands[ player ]
			}
		}
	)

	player.WaitSignal( "SplitTimeline_AbilityEndWeaponSwap" )

	if ( player.IsTitan() )
		waitthread SplitTimelineWaitForExitTitan( player )
}

//HACKY HACK: THIS IS JUST TO HANDLE THE ABILITY ENDING WHILE THE PLAYER IS IN A TITAN UNTIL WE MAKE THE SYSTEM MORE ROBUST.
void function SplitTimelineWaitForExitTitan( entity player )
{
	Assert ( IsNewThread(), "Must be threaded off." )
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "OnDeath" )

	while ( player.IsTitan() )
	{
		WaitFrame()
	}
}

#endif //SERVER
