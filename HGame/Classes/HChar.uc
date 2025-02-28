//================================================================================
// HChar.
//================================================================================

class HChar extends HPawn; 

const WATCH_FOR_HARRY_ARRAY_SIZE= 3;
enum EEnemyBar 
{
	EnemyBar_Aragog,
	EnemyBar_Basilisk,
	EnemyBar_Duellist,
	EnemyBar_Peeves,
	EnemyBar_Seeker,
	EnemyBar_None
};
var(EnemyHealth) EEnemyBar EnemyHealthBar;
var name SavedState;
var(Movement) float RunSpeed;
var(SpellEffects) bool bFlipPushable;
var(SpellEffects) float fFlipPushForceXY;
var(SpellEffects) float fFlipPushForceZ;
var Actor aHolding;
var(Fidgets) bool bPlayFidgetAnims;
var name CurrFidgetAnimName;
var name CurrIdleAnimName;
var int FidgetNums;
var int IdleNums;
var(Fidgets) int iMinIdleSeconds;
var(Fidgets) int iMaxIdleSeconds;
var(BumpLines) bool bUseBumpLine;
var(BumpLines) bool bBumpCaptureHarry;
var(BumpLines) string BumpLineSet;
var(BumpLines) string BumpLineSetPrefix;
var(BumpLines) bool bDoRandomBumpLine;
var int lastRandomBumpLine;
var int curBumpLine;
var name SavedPreBumpState;
var Rotator SavedPreBumpRot;
var float LastBumpTime;
var Sound soundFalling[10];
var() float fFallSoundDist;
var Sound soundCurrFalling;
var(WatchForHarry) bool bCouldWatchForHarry;
var int HowManyBaseAnims;
var int HowManyBaseSounds;
var int HowManyAlarmAnims;
var int HowManyAlarmSounds;
var float fCurrTime;
var float fDuration;
var Vector vTemp;
var int iCanSeeHarryCounter;
var bool bTempDontLookForHarry;
var Vector vLastPosition;

// DD39: DivingDeep39: Replaced with float var fStuckTimer
//var int iStuckCounter;
var float fStuckTimer;

var bool bDoStuckChecking;
var(WatchForHarry) name BaseWatchAnim[3];
var(WatchForHarry) string BaseWatchSound[3];
var(WatchForHarry) name BaseAlarmAnim[3];
var(WatchForHarry) string BaseAlarmSound[3];
var(WatchForHarry) float fWatchForHarryDist;
var(WatchForHarry) float fCutSceneTime;
var(WatchForHarry) float fNotifyOthersHearDistance;
var(WatchForHarry) name EventName;
var Actor aListenToMe;
var bool bCapturedFromStateIdle;
//DD39: Adding var for custom director
var DD39Adv7SneakDirector Director;
//DD39: Bool to allow backwards compatibility
var (WatchForHarry) bool bUseDirector;
//DD39: Bool to destroy the secret area cutscene in Adv7
var (WatchForHarry) bool bDestroyCut;
//DD39: Bool to check if the aforementioned cutscene is destroyed
var bool bCutDestroyed;

// DD39: DivingDeep39: New variables for Bump Lines customization.
var(BumpLinesM212) string BumpSetFile;
var(BumpLinesM212) string LocalizationFile;
var(BumpLinesM212) string Package;
var(BumpLinesM212) string Section;


function bool ShouldStartLookingForHarry()
{
	return True;
}

function bool IsHuntingHarry()
{
	return False;
}

function bool CanSeeHarry (optional bool bLookingForHarry, optional bool bDontCareAboutFOV)
{
	local Vector V;
	local float f;

	if ( PlayerHarry.bIsGoyle )
	{
		return False;
	}
	V = PlayerHarry.Location - Location;
	f = VSize(V);
	if (  !bLookingForHarry )
	{
		if ( f > fWatchForHarryDist )
		{
			return False;
		}
	}
	if ( bLookingForHarry && (f < 350) )
	{
		bDontCareAboutFOV = True;
	}
	if (  !bDontCareAboutFOV && (Normal((PlayerHarry.Location - Location) * vect(1.00,1.00,0.00)) Dot Vector(Rotation)) < -0.69999999 )
	{
		return False;
	}
	V = Normal(V Cross vect(0.00,0.00,1.00));
	if (  !FastTrace(PlayerHarry.Location + (V * PlayerHarry.CollisionRadius) * 0.5) )
	{
		return False;
	}
	if (  !FastTrace(PlayerHarry.Location - (V * PlayerHarry.CollisionRadius) * 0.5) )
	{
		return False;
	}
	return True;
}

function float PlayRandomSoundAndAnimFirstTime()
{
	local int randNumber;
	local float duration;

	if ( HowManyBaseSounds > 0 )
	{
		randNumber = Rand(HowManyBaseSounds);
		duration = DeliverLocalizedDialog(BaseWatchSound[randNumber],True,0.0);
	} 
	else 
	{
		duration = 0.01;
	}
	if ( HowManyBaseAnims == 0 )
	{
		PlayAnim('Idle');
	} 
	else 
	{
		randNumber = Rand(HowManyBaseAnims);
		PlayAnim(BaseWatchAnim[randNumber]);
	}
	return duration;
}

function float PlayRandomSoundAndAnimSecondTime()
{
	local int randNumber;
	local float duration;

	if ( HowManyAlarmSounds > 0 )
	{
		randNumber = Rand(HowManyAlarmSounds);
		duration = DeliverLocalizedDialog(BaseAlarmSound[randNumber],True,0.0);
	} 
	else 
	{
		duration = 0.01;
	}
	if ( HowManyAlarmAnims > 0 )
	{
		randNumber = Rand(HowManyAlarmAnims);
		PlayAnim(BaseAlarmAnim[randNumber]);
	}
	return duration;
}

state StartFollowingHarry
{
	//UTPT added this for some reason -AdamJD
	//ignores  Tick;
  
	function bool ShouldStartLookingForHarry()
	{
		return False;
	}
  
	function bool IsHuntingHarry()
	{
		return True;
	}
	
	//UTPT didn't add this for some reason -AdamJD
	function Tick(float DeltaTime)
	{
		Global.Tick(DeltaTime);
		DesiredRotation.Yaw = rotator(aListenToMe.Location - Location).Yaw;
	}
	
	begin:
		//Log("In state " $GetStateName()); 
		Velocity = vect(0.00,0.00,0.00);
		Acceleration = vect(0.00,0.00,0.00);
		LoopAnim(IdleAnimName,RandRange(0.80,1.20),0.2);
		Sleep(RandRange(1.5,3.0));
		fDuration = PlayRandomSoundAndAnimFirstTime();
		fDuration -= 1.5;
		Sleep(fDuration);
		GotoState('followHarry');
}

state followHarry
{
	function bool ShouldStartLookingForHarry()
	{
		return False;
	}
  
	function bool IsHuntingHarry()
	{
		return True;
	}
  
	function BeginState()
	{
		vLastPosition = vect(0.00,0.00,0.00);
		
		// DD39: DivingDeep39: Setting default to 4.0 seconds
		//iStuckCounter = 0;
		fStuckTimer = 4.0;
		
		iCanSeeHarryCounter = 0;
		//DD39: run function in custom director
		if ( bUseDirector )
		{
		  Director.HarrySpotted();
		} else {
		  TriggerEvent('SilenceTwo',None,None);
		  TriggerEvent('ChaseMusic',None,None);
		}
	}
	
	function Tick (float dtime)
	{
		if ( VSize2D(Location - vLastPosition) < 1 )
		{
			// DD39: DivingDeep39: Instead of counting up, let's count down
			//iStuckCounter++;
			fStuckTimer -= dtime;
			
			// DD39: DivingDeep39: If countdown reaches 0, change state
			//if ( iStuckCounter > 4 )
			if ( fStuckTimer <= 0.0 )
			{
				bTempDontLookForHarry = True;
				GotoState('RandomLookForHarry');
			}
		} 
		else 
		{
			// DD39: DivingDeep39: Setting default to 4.0 seconds
			//iStuckCounter = 0;
			fStuckTimer = 4.0;
		}
		vLastPosition = Location;
	}
	begin:
		//Log("In state " $GetStateName()); 
		GroundSpeed = GroundRunSpeed + 175;
		LoopAnim(RunAnimName,,0.75);
		vTemp = PlayerHarry.Location - Location;
		vTemp = Location + 2 * vTemp / VSize(vTemp);
		MoveTo(vTemp);
		DesiredRotation.Yaw = rotator(PlayerHarry.Location - Location).Yaw;
		if (  !CanSeeHarry(True,True) )
		{
			iCanSeeHarryCounter++;
			if ( iCanSeeHarryCounter > 2 )
			{
				GotoState('RandomLookForHarry');
			}
		}
		
		GotoState('followHarry');
}

state RandomLookForHarry
{
	//UTPT added this for some reason -AdamJD
	//ignores  Tick;
	
	function bool ShouldStartLookingForHarry()
	{
		return False;
	}
  
	function bool IsHuntingHarry()
	{
		return True;
	}
  
	function BeginState()
	{
		vLastPosition = vect(0.00,0.00,0.00);
		
		// DD39: DivingDeep39: Setting default to 4.0 seconds
		//iStuckCounter = 0;
		fStuckTimer = 4.0;
		
		bDoStuckChecking = True;
		iCanSeeHarryCounter = 0;
		bPlayRunAnim = True;
		FindNewVTempBasedOnNormal((PlayerHarry.Location - Location) * vect(1.00,1.00,0.00));
	}
	
	//UTPT didn't add this for some reason -AdamJD
	function Tick (float dtime)
	{ 
	  Global.Tick(dtime);
	  if ( (Rand(6) == 0) &&  !bTempDontLookForHarry && CanSeeHarry(True,True) )
	  {
	      GotoState('followHarry');
	  }
	  if ( bDoStuckChecking )
	  {
		  if ( VSize2D(Location - vLastPosition) < 1 )
		  {
		      // DD39: DivingDeep39: Instead of counting up, let's count down
			  //iStuckCounter++;
			  fStuckTimer -= dtime;
			  
		      // DD39: DivingDeep39: If countdown reaches 0, change state
			  //if ( iStuckCounter > 4 )
			  if ( fStuckTimer <= 0.0 )
		      {
		          vLastPosition = vect(0.00,0.00,0.00);
				  
			      // DD39: DivingDeep39: Setting default to 4.0 seconds
				  //iStuckCounter = 0;
				  fStuckTimer = 4.0;
				  
			      FindNewVTempBasedOnNormal(PlayerHarry.Location - Location);
			      GotoState('RandomLookForHarry');
		      }
		  }
		  else
		  {
		      // DD39: DivingDeep39: Setting default to 4.0 seconds
			  //iStuckCounter = 0;
			  fStuckTimer = 4.0;
		  }
	  }
	  vLastPosition = Location;
	}
  
	function EndState()
	{
		bTempDontLookForHarry = False;
	}
  
	function HitWall (Vector HitNormal, Actor HitWall)
	{
		FindNewVTempBasedOnNormal(HitNormal);
		GotoState('RandomLookForHarry');
	}
  
	function FindNewVTempBasedOnNormal (Vector HitNormal)
	{
		local Rotator R;
  
		R.Yaw = rotator(HitNormal).Yaw;
		R.Yaw = R.Yaw + RandRange(-15000.0,15000.0) & 65535;
		
		vTemp = Location + Normal(vector(R)) * 75; //figured this bit out for the students to move towards Harry when they see him like in the retail game because UTPT couldn't decompile it -AdamJD
	}
  
	begin:
		//Log("In state " $GetStateName());
		if ( bPlayRunAnim )
		{
			GroundSpeed = GroundRunSpeed + 175;
			LoopAnim(RunAnimName,,0.75);
		} 
		else 
		{
			GroundSpeed = GroundWalkSpeed;
			LoopAnim(WalkAnimName,,0.75);
		}
		MoveTo(vTemp);
		bTempDontLookForHarry = False;
		bDoStuckChecking = False;
		DesiredRotation.Yaw = Rotation.Yaw + Rand(65536);
		Velocity = vect(0.00,0.00,0.00);
		Acceleration = vect(0.00,0.00,0.00);
		LoopAnim(IdleAnimName,RandRange(0.80,1.20),0.25);
		Sleep(RandRange(0.75,1.5));
		FindNewVTempBasedOnNormal((PlayerHarry.Location - Location) * vect(1.00,1.00,0.00));
		TurnTo(vTemp);
		bDoStuckChecking = True;
		
		// DD39: DivingDeep39: Setting default to 4.0 seconds
		//iStuckCounter = 0;
		fStuckTimer = 4.0;
		
		iCanSeeHarryCounter++;
		if ( iCanSeeHarryCounter > 2 )
		{
			bPlayRunAnim = False;
		}
		if ( CanSeeHarry(True,True) )
		{
			GotoState('followHarry');
		} 
		else 
		{
			GotoState('RandomLookForHarry');
		}
}

state LookForHarryIdle
{
	function bool IsHuntingHarry()
	{
		return True;
	}
  
	function bool ShouldStartLookingForHarry()
	{
		return False;
	}
	begin:
		//Log("In state " $GetStateName()); 
		Velocity = vect(0.00,0.00,0.00);
		Acceleration = vect(0.00,0.00,0.00);
		LoopAnim(IdleAnimName,RandRange(0.80,1.20),0.2);
}

state CaughtHarry
{
	function bool ShouldStartLookingForHarry()
	{
		return False;
	}
  
	function bool IsHuntingHarry()
	{
		return True;
	}
  
	function BeginState()
	{
		local Characters A;
  
		foreach AllActors(Class'Characters',A)
		{
			if ( (A != self) && A.bCouldWatchForHarry )
			{
				A.GotoState('LookForHarryIdle');
			}
		}
		//DD39: run function in custom director
		if ( bUseDirector )
		{
		  Director.HarryCaught();
		}
		//DD39: Destroy the secret area cutscene in Adv7
		if ( bDestroyCut && !bCutDestroyed )
		{
		  bCutDestroyed = True;
		  TriggerEvent('DD39DestroyBannerStatueCut',None,None);
		}
	}
	begin:
		//Log("In state " $GetStateName());
		Velocity = vect(0.00,0.00,0.00);
		Acceleration = vect(0.00,0.00,0.00);
		LoopAnim(IdleAnimName,RandRange(0.80,1.20),0.2);
		TurnTo(PlayerHarry.Location);
		PlayerHarry.ClientMessage("Start to say something second time................" $ string(self));
		fDuration = PlayRandomSoundAndAnimSecondTime();
		Sleep(fDuration);
		PlayerHarry.ClientMessage("End   to say something second time................" $ string(self));
		//DD39: run function in custom director
		if ( bUseDirector )
		{
		  Director.TriggerCaughtEvent();
		} else {
		if ( EventName != 'None' )
		{
		  PlayerHarry.ClientMessage("Trigger Event................" $ string(EventName));
		  TriggerEvent(EventName,None,None);
		}
	}
}

state SaySomethingFirstTime
{
	//UTPT added this for some reason -AdamJD
	//ignores  Tick;
  
	function bool ShouldStartLookingForHarry()
	{
		return False;
	}
  
	function bool IsHuntingHarry()
	{
		return True;
	}
  
	function BeginState()
	{
		Acceleration = vect(0.00,0.00,0.00);
		Velocity = vect(0.00,0.00,0.00);
		//DD39: Destroy the secret area cutscene in Adv7
		if ( bDestroyCut && !bCutDestroyed )
		{
		  bCutDestroyed = True;
		  TriggerEvent('DD39DestroyBannerStatueCut',None,None);
		}
	}
	
	//UTPT didn't add this for some reason -AdamJD
	function Tick(float DeltaTime)
	{
		Global.Tick(DeltaTime);
		DesiredRotation.Yaw = rotator(playerHarry.Location - Location).Yaw;
	}
	
	begin:
		//Log("In state " $GetStateName());
		PlayerHarry.ClientMessage("Start to say something first time................." $ string(self));
		fDuration = PlayRandomSoundAndAnimFirstTime();
		fDuration -= 1.5;
		Sleep(fDuration * 0.2);
		NotifyOthersOfHarry();
		Sleep(fDuration * 0.8);
		PlayerHarry.ClientMessage("End   to say something first time................." $ string(self));
		GotoState('followHarry');
}

function NotifyOthersOfHarry()
{
	local HChar A;

	foreach AllActors(Class'HChar',A)
	{
		if ( A.bCouldWatchForHarry && VSize(Location - A.Location) < fNotifyOthersHearDistance && A.ShouldStartLookingForHarry() )
		{
			aListenToMe = self;
			A.GotoState('StartFollowingHarry');
		}
	}
}

function Tick (float DeltaTime)
{
	Super.Tick(DeltaTime);
	if ( ActorToLinkToWeapBone != None )
	{
		ActorToLinkToWeapBone.SetLocation(WeaponLoc);
		ActorToLinkToWeapBone.SetRotation(WeaponRot);
	}
	if ( soundFalling[0] != None )
	{
		HandleFallSounds();
	}
	if (  !bCouldWatchForHarry )
	{
		return;
	}
	fCurrTime += DeltaTime;
	if ( fCurrTime < 1.0 )
	{
		return;
	}
	fCurrTime = 0.0;
	if (  !IsHuntingHarry() && CanSeeHarry(False) )
	{
		SaveState();
		GotoState('SaySomethingFirstTime');
		return;
	}
}

function PreBeginPlay()
{
	local string AnimName;
	local int I;
	local name nm;

	Super.PreBeginPlay();
	
	FidgetNums = 0;
	for(I = 1; I <= 16; I++)
	{
		AnimName = "fidget_" $I;
		nm = StringToAnimName(AnimName);
		if ( nm == 'None' )
		{
			FidgetNums = I - 1;
			break;
		} 
	}
	
	IdleNums = 0;
	for(I = 1; I <= 16; I++)
	{
		AnimName = "idle_" $I;
		nm = StringToAnimName(AnimName);
		if ( nm == 'None' )
		{
			IdleNums = I - 1;
			break;
		}
	}
	
	HowManyBaseAnims = 0;
	HowManyBaseSounds = 0;
	HowManyAlarmAnims = 0;
	HowManyAlarmSounds = 0;
	
	if (  !bCouldWatchForHarry )
	{
		return;
	}
	
	//DD39: find the custom director
	if (  bCouldWatchForHarry && bUseDirector )
	{
		foreach AllActors(Class'DD39Adv7SneakDirector',Director)
		{
		  break;
		  
		 //DD39: if it can't find it, set the bool to False
		  if ( Director == None )
		  {
		    bUseDirector = False;
		  }
		}
	}

	
	for(I = 0; I < WATCH_FOR_HARRY_ARRAY_SIZE; I++)
	{
		if ( BaseWatchAnim[I] == 'None' )
		{
			break;
		}
	}
	HowManyBaseAnims = I;
	
	for(I = 0; I < WATCH_FOR_HARRY_ARRAY_SIZE; I++)
	{
		if ( BaseWatchSound[I] == "" )
		{
			break;
		}
	}
	HowManyBaseSounds = I;
	
	for(I = 0; I < WATCH_FOR_HARRY_ARRAY_SIZE; I++)
	{
		if ( BaseAlarmAnim[I] == 'None' )
		{
			break;
		}
	}
	HowManyAlarmAnims = I;
	
	for(I = 0; I < WATCH_FOR_HARRY_ARRAY_SIZE; I++)
	{
		if ( BaseAlarmSound[I] == "" )
		{
			break;
		}
	}
	HowManyAlarmSounds = I;
	
	if ( PlayerHarry.Difficulty == DifficultyMedium )
	{
		GroundRunSpeed = 240.0;
	} 
	else if ( PlayerHarry.Difficulty == DifficultyHard )
    {
      GroundRunSpeed = 270.0;
    }
}

function name GetCurrFidgetAnimName()
{
	local string AnimName;
	//local int Index;
	local int iIndex;
	local name nm;

	if ( FidgetNums == 0 )
	{
		return IdleAnimName;
	}
	iIndex = 1 + Rand(FidgetNums);
	AnimName = "fidget_" $iIndex;
	nm = StringToAnimName(AnimName);
	return nm;
}

function name GetCurrIdleAnimName()
{
	local string AnimName;
	//local int Index;
	local int iIndex;
	local name nm;

	if ( IdleNums == 0 )
	{
		return IdleAnimName;
	}
	iIndex = Rand(IdleNums + 1);
	if ( iIndex == 0 )
	{
		AnimName = "idle";
	} 
	else 
	{
		AnimName = "idle_" $iIndex;
	}
	nm = StringToAnimName(AnimName);
	return nm;
}

event Bump (Actor Other)
{
	local HChar A;
	local bool bDoBump;
	
	// DD39: If Harry is dead, return.
	if ( PlayerHarry.bHarryKilled )
	{
		return;
	}
	
	if ( Other.IsA('harry') && bCouldWatchForHarry && !PlayerHarry.bIsGoyle )
	{
		if ( (EventName != 'None') &&  !HPHud(PlayerHarry.myHUD).bCutSceneMode )
		{
			PlayerHarry.ClientMessage("Trigger Event................" $ string(EventName));
			PlayerHarry.GotoState('stateCutIdle');
			//DD39: enable bool to fix Harry sliding when caught in mid-air
			PlayerHarry.bIsCaught = True;
			GotoState('CaughtHarry');
		}
		return;
	}
	if ( bUseBumpLine && (Other == Level.PlayerHarryActor) )
	{
		// DD39: If Harry is in a cutscene, don't do bump lines.
		if ( PlayerHarry.bIsCaptured )
		{
			return;
		}
		
		bDoBump = True;
		foreach AllActors(Class'HChar',A)
		{
			if ( A.IsInState('DoingBumpLine') )
			{
				bDoBump = False;
				break;
			} 
			//else 
			//{
			//}
		}
		if ( bDoBump && (Level.TimeSeconds - LastBumpTime > 0.75) )
		{
			DoBumpLine();
		}
		return;
	}
	Super.Bump(Other);
}

function DoBumpLine (optional bool bJustTalk, optional string AlternateBumpLineSet)
{
	local string sSetID;
	local string sSayTextID;
	local string sSayText;
	local Sound dlgSound;
	local float sndLen;
	local TimedCue tcue;
	local int ri;
	local int rm;

	if (  !bUseBumpLine &&  !bJustTalk )
	{
		return;
	}
	if ( (CutNotifyActor != None) &&  !bJustTalk )
	{
		return;
	}
	if ( (BumpLineSet == "") && (AlternateBumpLineSet == "") )
	{
		Level.PlayerHarryActor.ClientMessage("ERROR BUMPLINES:" $ string(self) $ " has no BumpLineSet");
		return;
	}
	if ( AlternateBumpLineSet != "" )
	{
		sSetID = AlternateBumpLineSet;
		Level.PlayerHarryActor.ClientMessage("BUMPLINES:" $ string(self) $ " looking for BumpLineSet:" $ sSetID);
		// DD39: DivingDeep39: Replaced "BumpSet" with the BumpSetFile var.
		//sSayTextID = Localize(sSetID, "line" $(Rand(int(Localize(sSetID, "Count", "BumpSet")))), "BumpSet");
		sSayTextID = Localize(sSetID, "line" $(Rand(int(Localize(sSetID, "Count", BumpSetFile)))), BumpSetFile);
	} 
	else 
	{
		if ( BumpLineSetPrefix != "" )
		{
			sSetID = BumpLineSetPrefix $"_" $BumpLineSet;
		} 
		else 
		{
			sSetID = BumpLineSet;
		}
		//log(sSetID);
		Level.PlayerHarryActor.ClientMessage("BUMPLINES:" $ string(self) $ " looking for BumpLineSet:" $ BumpLineSet);
		if ( bDoRandomBumpLine )
		{
			// DD39: DivingDeep39: Replaced "BumpSet" with the BumpSetFile var.
			//rm = int(Localize(sSetID, "Count", "BumpSet"));
			rm = int(Localize(sSetID, "Count", BumpSetFile));
			ri = Rand(rm);
			if ( ri == lastRandomBumpLine )
			{
				ri = (ri + 1) % rm;
				lastRandomBumpLine = ri;
			}
			// DD39: DivingDeep39: Replaced "BumpSet" with the BumpSetFile var.
			//sSayTextID = Localize(sSetID, "line" $ri,"BumpSet");
			sSayTextID = Localize(sSetID, "line" $ri,BumpSetFile);
		} 
		else 
		{
			// DD39: DivingDeep39: Replaced "BumpSet" with the BumpSetFile var.
			//sSayTextID = Localize(sSetID, "line" $curBumpLine,"BumpSet");
			sSayTextID = Localize(sSetID, "line" $curBumpLine,BumpSetFile);
			curBumpLine++ ;
			if ( InStr(sSayTextID,"<") > -1 )
			{
				curBumpLine = 0;
				// DD39: DivingDeep39: Replaced "BumpSet" with the BumpSetFile var.
				//sSayTextID = Localize(sSetID,"line" $curBumpLine,"BumpSet");
				sSayTextID = Localize(sSetID,"line" $curBumpLine,BumpSetFile);
			}
		}
		if ( InStr(sSayTextID, "<") > -1 )
		{
			Level.PlayerHarryActor.ClientMessage("ERROR BUMPLINES:" $ string(self) $ " couldn't find BumpLineSet:" $ BumpLineSet);
			return;
		}
	}
	Level.PlayerHarryActor.ClientMessage("BUMPLINES:" $ string(self) $ " looking for BumpLine ID:" $ sSayTextID);
	// DD39: DivingDeep39: Replaced " "all" " and "BumpDialog" with the Section and LocalizationFile vars.
	//sSayText = Localize("all",sSayTextID,"BumpDialog");
	sSayText = Localize(Section,sSayTextID,LocalizationFile);
	if ( InStr(sSayText,"<?") > -1 )
	{
		Level.PlayerHarryActor.ClientMessage("ERROR BUMPLINES:" $ string(self) $ " couldn't find BumpLine ID:" $ sSayTextID $ " from BumpLineSet:" $ BumpLineSet);
		return;
	}
	SavedPreBumpState = GetStateName();
	SavedPreBumpRot = Rotation;
	if ( bBumpCaptureHarry && (Level.PlayerHarryActor.CutNotifyActor != None) )
	{
		Level.PlayerHarryActor.CutNotifyActor = self;
		Level.PlayerHarryActor.CutCommand("capture");
	}
	CutNotifyActor = self;
	// DD39: DivingDeep39: Replaced "AllDialog" with the Package var.
	//dlgSound = Sound(DynamicLoadObject("AllDialog." $sSayTextID,Class'Sound'));
	dlgSound = Sound(DynamicLoadObject(Package$"."$sSayTextID,Class'Sound'));
	if ( dlgSound != None )
	{
		sndLen = GetSoundDuration(dlgSound);
		PlaySound(dlgSound,SLOT_Talk,1.39999998,,100000.0,,True);
	} 
	else 
	{
		sndLen = Len(sSayText) * 0.01 + 3.0;
	}
	
	// Metallicafan212:	This wasn't here for some reason
	sSayText = HandleFacialExpression( sSayText, sndLen );
	
	if( !bJustTalk )
	{
		//create a TimedCue to cue object after sndLen seconds.
		tcue=spawn(class 'TimedCue');
		tcue.CutNotifyActor=Self;		//Tell me when done. This is auto passed back to the CutNotifyActor if any.
										//Or it can be used by the talk to find out when the talk is finished.
		tcue.SetupTimer(sndLen+0.5,"_BumpLineCue"); //little extra time for slop
	}

	//show text
	level.playerHarryActor.MyHud.SetSubtitleText(sSayText, sndLen);
	
	if( !bJustTalk )
	{
		GotoState('DoingBumpLine');
	}
}

state DoingBumpLine
{
	function BeginState()
	{
		Acceleration = vect(0.00,0.00,0.00);
		Velocity = vect(0.00,0.00,0.00);
		PlayAnim('Idle',1.0,0.5);
	}
  
	event Bump (Actor Other)
	{
		Super.Bump(Other);
	}
  
	function CutCue (string cue)
	{
		if ( bBumpCaptureHarry )
		{
			Level.PlayerHarryActor.CutCommand("release");
			Level.PlayerHarryActor.CutNotifyActor = None;
		}
		CutNotifyActor = None;
		GotoState(SavedPreBumpState);
		DesiredRotation = SavedPreBumpRot;
		LastBumpTime = Level.TimeSeconds;
	}
	begin:
		TurnTo(LocationSameZ(PlayerHarry.Location));
		goto ('Begin');
}

function bool ObjectPickup (Actor obj, name nHoldingBone)
{
	if ( obj.Owner != None )
	{
		PlayerHarry.ClientMessage(" ERROR when " $ string(Name) $ " is trying to pickup an object!");
		return False;
	}
	aHolding = obj;
	aHolding.SetOwner(self);
	aHolding.AttachToOwner(nHoldingBone);
	aHolding.SetCollision(False,False,False);
	PlaySound(Sound'pickup11');
	return True;
}

function ObjectThrow (Vector vThrow, bool bCollideActors, bool bCollideWorld)
{
	if ( aHolding == None )
	{
		PlayerHarry.ClientMessage(" ERROR when " $ string(Name) $ " is trying to throw an object!");
		return;
	}
	aHolding.SetPhysics(PHYS_Falling);
	aHolding.AnimBone = 0;
	aHolding.SetCollision(bCollideActors);
	aHolding.bCollideWorld = bCollideWorld;
	aHolding.Velocity = vThrow;
	aHolding.SetOwner(None);
	aHolding = None;
}

function bool HandleSpellFlipendo (optional baseSpell spell, optional Vector vHitLocation)
{
	Super.HandleSpellFlipendo(spell,vHitLocation);
	if ( bFlipPushable == True )
	{
		SetPhysics(PHYS_Falling);
		Velocity = Normal(Location - PlayerHarry.Location) * fFlipPushForceXY;
		Velocity.Z = fFlipPushForceZ;
	}
	return True;
}

function Landed (Vector HitNormal)
{
	Super.Landed(HitNormal);
	ClientMessage("HChar Landed");
	if ( bFlipPushable == True )
	{
		SetPhysics(PHYS_Walking);
		Acceleration = vect(0.00,0.00,0.00);
		Velocity = vect(0.00,0.00,0.00);
	}
}

function DoPickup (Actor A)
{
}

function DoAttack (name AttackType)
{
}

function DoAction (name Action)
{
}

function DoPossess()
{
}

function DoUnPossess()
{
}

function CanAttack()
{
}

function OnTouch()
{
}

// Metallicafan212:	That return was a goto for some reason
//					May need to investigate
function OnEvent (name EventName)
{
	if (EventName != 'ActionDone' )
	{
		//looks like KW left this empty -AdamJD
	}
}

function bool CutCommand (string Command, optional string cue, optional bool bFastFlag)
{
	local string sActualCommand;
	local string sCutName;
	local Actor A;

	sActualCommand = ParseDelimitedString(Command," ",1,False);
	if ( sActualCommand ~= "Capture" )
	{
		if ( IsInState('stateIdle') )
		{
			bCapturedFromStateIdle = True;
			GotoState('stateCutCapture');
		}
	} 
	else if ( sActualCommand ~= "Release" )
	{
		if ( bCapturedFromStateIdle && IsInState('stateCutCapture') )
		{
			GotoState('stateIdle');
		}
	}
	if ( sActualCommand ~= "Set" )
	{
		return CutCommand_HandleSet(Command,cue,bFastFlag);
	}
	return Super.CutCommand(Command,cue,bFastFlag);
}

function bool CutCommand_HandleSet (string Command, optional string cue, optional bool bFastFlag)
{
	local Actor A;
	local string sVarName;
	local string sVarValue;
	local int I;

	sVarName = ParseDelimitedString(Command," ",2,False);
	sVarValue = ParseDelimitedString(Command," ",3,False);
	sVarName = Caps(sVarName);
	switch (sVarName)
	{
		case "BUMPSET":
			cm(string(self) $ " Setting BumpLineSet to:" $ sVarValue);
			BumpLineSet = sVarValue;
			break;
		case "BUMPPREFIX":
			cm(string(self) $ " Setting BumpLineSetPrefix to:" $ sVarValue);
			BumpLineSetPrefix = sVarValue;
			break;
		default:
	}
	CutCue(cue);
	return True;
}

auto state patrol
{
}

state stateIdle
{	
	begin:
		//Log("In state " $GetStateName());
		if ( bPlayFidgetAnims )
		{
			CurrFidgetAnimName = GetCurrFidgetAnimName();
			CurrIdleAnimName = GetCurrIdleAnimName();
			if ( FidgetNums != 0 )
			{
				LoopAnim(CurrIdleAnimName,RandRange(0.80,1.20),[TweenTime]0.5);
				Sleep(RandRange(iMinIdleSeconds,iMaxIdleSeconds));
				FinishAnim();
				PlayAnim(CurrFidgetAnimName,RandRange(0.80,1.20),[TweenTime]0.2);
				FinishAnim();
			} 
			else
			{
				if ( HasAnim(CurrIdleAnimName) )
				{
					PlayAnim(CurrIdleAnimName,RandRange(0.80,1.20),[TweenTime]0.2);
					FinishAnim();
					Sleep(0.01);
				} 
				else 
				{
					Sleep(0.1);
				}
			}
		}
		Sleep(0.0001);
		goto ('Begin');
}

state stateCutCapture
{
}

function SaveState()
{
	SavedState = GetStateName();
}

function RestoreState()
{
	GotoState(SavedState);
}

simulated function PlayFootStep()
{
	local Sound Step;
	local float decision;
	local Texture HitTexture;
	local int Flags;
	local Sound Footstep1;
	local Sound Footstep2;
	local Sound Footstep3;

	// DD39: Omega: Make sure we don't play these if not relevant in gamestate
    if( !bInCurrentGameState )
    {
        return;
    }
	
	if ( FootRegion.Zone.bWaterZone )
	{
		PlaySound(WaterStep,SLOT_Interact,1.0,False,1000.0,1.0);
		return;
	}
	HitTexture = TraceTexture(Location + vect(0.00,0.00,-128.00),Location,Flags);
	Footstep1 = Sound'HAR_foot_stone1';
	Footstep2 = Sound'HAR_foot_stone2';
	Footstep3 = Sound'HAR_foot_stone3';
	switch (HitTexture.FootstepSound)
	{
		case FOOTSTEP_Wood:
			Footstep1 = Sound'HAR_foot_wood1';
			Footstep2 = Sound'HAR_foot_wood2';
			Footstep3 = Sound'HAR_foot_wood3';
			break;
		case FOOTSTEP_Rug:
			Footstep1 = Sound'HAR_foot_rug1';
			Footstep2 = Sound'HAR_foot_rug2';
			Footstep3 = Sound'HAR_foot_rug3';
			break;
		case FOOTSTEP_Stone:
			Footstep1 = Sound'HAR_foot_stone1';
			Footstep2 = Sound'HAR_foot_stone2';
			Footstep3 = Sound'HAR_foot_stone3';
			break;
		case FOOTSTEP_Cave:
			Footstep1 = Sound'HAR_foot_cave1';
			Footstep2 = Sound'HAR_foot_cave2';
			Footstep3 = Sound'HAR_foot_cave3';
			break;
		case FOOTSTEP_Cloud:
			Footstep1 = Sound'HAR_foot_cloud1';
			Footstep2 = Sound'HAR_foot_cloud2';
			Footstep3 = Sound'HAR_foot_cloud3';
			break;
		case FOOTSTEP_Wet:
			Footstep1 = Sound'HAR_foot_wet1';
			Footstep2 = Sound'HAR_foot_wet2';
			Footstep3 = Sound'HAR_foot_wet3';
			break;
		case FOOTSTEP_Grass:
			Footstep1 = Sound'HAR_foot_grass1';
			Footstep2 = Sound'HAR_foot_grass2';
			Footstep3 = Sound'HAR_foot_grass3';
			break;
		case FOOTSTEP_Metal:
			Footstep1 = Sound'HAR_foot_metal1';
			Footstep2 = Sound'HAR_foot_metal2';
			Footstep3 = Sound'HAR_foot_metal3';
			break;
		default:
	}
	decision = FRand();
	if ( decision < 0.34 )
	{
		Step = Footstep1;
	} 
	else if ( decision < 0.67 )
	{
		Step = Footstep2;
	}
    else 
	{
      Step = Footstep3;
    }
	PlaySound(Step,SLOT_Interact,GetFootStepVol() * RandRange(0.69999999,1.0),False,1000.0,RandRange(0.69999999,1.29999995));
}

function float GetFootStepVol()
{
	return 0.5;
}

function float GetHealth()
{
	return Health;
}

function Sound GetRandomFallSound()
{
	local int nActualSounds;

	for(nActualSounds = 0; nActualSounds < ArrayCount(soundFalling); nActualSounds++)
	{
		if ( soundFalling[nActualSounds] == None )
		{
			break;
		}
	}
	if ( nActualSounds > 0 )
	{
		return soundFalling[Rand(nActualSounds)];
	} 
	else 
	{
		return None;
	}
}

function HandleFallSounds()
{
	local Vector vUnderLocation;

	if ( soundFalling[0] == None )
	{
		return;
	}
	if ( Physics == PHYS_Falling )
	{
		if ( soundCurrFalling == None )
		{
			vUnderLocation = Location + Vec(0.0,0.0, -fFallSoundDist);
			if ( FastTrace(vUnderLocation,Location) )
			{
				soundCurrFalling = GetRandomFallSound();
				PlaySound(soundCurrFalling, SLOT_None);
			}
		}
	} 
	else 
	{
		if ( soundCurrFalling != None )
		{
			StopSound(soundCurrFalling, SLOT_None);
			soundCurrFalling = None;
		}
	}
}

defaultproperties
{
    EnemyHealthBar=EnemyBar_None

    fFlipPushForceXY=200.00

    fFlipPushForceZ=250.00

    bPlayFidgetAnims=True

    iMinIdleSeconds=5

    iMaxIdleSeconds=10

    bDoRandomBumpLine=True

    lastRandomBumpLine=99

    fFallSoundDist=100.00

    fWatchForHarryDist=512.00

    fCutSceneTime=10.00

    fNotifyOthersHearDistance=600.00

    EventName=CallSnape

    ShadowClass=Class'Engine.ActorShadow'

    bCantStandOnMe=True

    bCanWalk=True

    GroundSpeed=200.00

    AirSpeed=100.00

    AccelRate=1024.00

    SightRadius=1000.00

    PeripheralVision=0.85

    BaseEyeHeight=40.75

    EyeHeight=40.75

    Physics=PHYS_Walking

    bGestureFaceHorizOnly=False

    Buoyancy=118.80
	
	// DD39: DivingDeep39: New vars' defaults for stock compatibility
	BumpSetFile="BumpSet"
	
	LocalizationFile="BumpDialog"	
	
	Package="AllDialog"
	
	Section="All"
}