//================================================================================
// Imp.
//================================================================================

class Imp extends HChar;

const BOOL_DEBUG_AI= false;
var Vector vHome;
var name SavedState;
var Vector vTargetDir;
var Rotator currentRotation;
var float attackDistance;
var bool bPlayedWarning;
var bool flag;
var float randomRunningSpeed;
var float runningForHarry;
var float BreathingTimeInterval;
var Sound impTalkSound;
var Sound impStruggleSound;
var Sound impThrownSound;
var Vector vTemp;
var() int numAttacksDefault;
var int numAttacks;
var() float fDamageAmount;
var() name GroupName;
var() float timeStunnedDefault;
var float timeStunned;
var bool bStunned;
var bool bCarried;
var() float timeWarningWhileCarried;
var() bool bWaitForTrigger;
var float timeIdleFidgit;
var bool bFidgit;
// DD39: 2 new vars for GroupName:
var() Imp myFriends[3];
var int numFriends;
// DD39: Handles the HitWall timer in stateRunAway:
var bool bTimerSet;


event KilledBy (Pawn EventInstigator)
{
  cm(string(Name) $ " has received a KilledBy event");
  GotoState('stateDied');
}

function PreBeginPlay()
{
  Super.PreBeginPlay();
  vHome = Location;
  bFlipPushable = True;
  lockSpell = True;
  LoopAnim('Idle');
}

function PostBeginPlay()
{
  local Imp tempImp;

  Super.PostBeginPlay();
  vHome = Location;
  attackDistance = PlayerHarry.CollisionRadius + CollisionRadius + 5;
  // DD39 (start): Look for Imps with matching GroupName:
  if ( GroupName != 'None' )
  {
    foreach AllActors(Class'Imp',tempImp)
    {
      if ( tempImp != self )
      {
        if ( tempImp.GroupName == GroupName )
        {
          myFriends[numFriends] = tempImp;
          numFriends++;
        }
      }
    }
  }
  // DD39 (end).
}

function SetDifficulty()
{
  randomRunningSpeed = GroundRunSpeed - 10 + FRand() * 35;
  cm("What is difficulty: " $ string(Level.Game.Difficulty));
  switch (Level.Game.Difficulty)
  {
    case 0:
    numAttacksDefault = numAttacksDefault;
    timeStunnedDefault = timeStunnedDefault + 2;
    randomRunningSpeed = randomRunningSpeed - 5;
    BreathingTimeInterval = BreathingTimeInterval - 2;
    timeWarningWhileCarried = timeWarningWhileCarried + 2;
    break;
    case 1:
    numAttacksDefault = numAttacksDefault;
    timeStunnedDefault = timeStunnedDefault;
    randomRunningSpeed = randomRunningSpeed;
    BreathingTimeInterval = BreathingTimeInterval;
    timeWarningWhileCarried = timeWarningWhileCarried;
    break;
    case 2:
    numAttacksDefault = numAttacksDefault + 2;
    timeStunnedDefault = timeStunnedDefault - 5;
    BreathingTimeInterval = BreathingTimeInterval + 2;
    randomRunningSpeed = randomRunningSpeed + 5;
    timeWarningWhileCarried = timeWarningWhileCarried - 2;
    case 3:
    numAttacksDefault = numAttacksDefault + 2;
    timeStunnedDefault = timeStunnedDefault - 7;
    BreathingTimeInterval = BreathingTimeInterval + 3;
    randomRunningSpeed = randomRunningSpeed + 10;
    timeWarningWhileCarried = timeWarningWhileCarried - 3;
    break;
    default:
  }
  if ( timeStunnedDefault < 7 )
  {
    timeStunnedDefault = 7.0;
  }
  if ( timeWarningWhileCarried < 2 )
  {
    timeWarningWhileCarried = 2.0;
  }
  numAttacks = numAttacksDefault;
  timeStunned = timeStunnedDefault;
  runningForHarry = BreathingTimeInterval;
}

function PlayerCutCapture()
{
  // DD39: Save state only in these cases, otherwise run away:
  if ( GetStateName() == 'patrol' || GetStateName() == 'stateIdle' || GetStateName() == 'stateWaitForTrigger' || GetStateName() == 'RandomWait' || GetStateName() == 'stateRunAway' )
  {
    SavedState = GetStateName();
	cm(string(Name) $ " saved state : " $ string(SavedState));
    GotoState('CutIdle');
  }
  
  if ( IsInState('stateMoveTowardHarry') || IsInState('takeABreather') || IsInState('stateBiteHarry') || IsInState('stateBeingCarried') || IsInState('stateGetAwayFromHarry')
		|| IsInState('stateGotAwayFromHarry') || IsInState('HarryGotAway') )
  {
    bStunned = False;
	bCarried = False;
	bObjectCanBePickedUp = False;
	GotoState('stateRunAway');
  }
}

state CutIdle
{
  function Trigger (Actor Other, Pawn EventInstigator)
  {
    if ( bWaitForTrigger )
	{
		cm(string(self.Name) $ " has been triggered in a cutscene");
		bWaitForTrigger = False;
		SavedState = 'RandomWait';
	}
  }
  
 begin:
  Acceleration = vect(0.00,0.00,0.00);
  Velocity = vect(0.00,0.00,0.00);
  LoopAnim('Idle');
}

function PlayerCutRelease()
{
  // DD39: Added check:
  if ( IsInState('CutIdle') )
  {
    GotoState(SavedState);
  }
}

function playHitSound()
{
  local Sound HitSound;
  local int randNum;

  randNum = Rand(5);
  switch (randNum)
  {
    case 0:
    HitSound = Sound'imp_ouch_01';
    break;
    case 1:
    HitSound = Sound'imp_ouch_02';
    break;
    case 2:
    HitSound = Sound'imp_ouch_03';
    break;
    case 3:
    HitSound = Sound'imp_ouch_04';
    break;
    case 4:
    HitSound = Sound'imp_ouch_05';
    break;
    default:
    HitSound = Sound'imp_ouch_01';
    break;
  }
  PlaySound(HitSound,SLOT_None,RandRange(0.6,1.0),,95000.0,RandRange(0.80,1.20),,False);
}

function playDieSound()
{
  local Sound HitSound;
  local int randNum;

  randNum = Rand(3);
  switch (randNum)
  {
    case 0:
    HitSound = Sound'imp_die_01';
    break;
    case 1:
    HitSound = Sound'imp_die_04';
    break;
    case 2:
    HitSound = Sound'imp_die_05';
    break;
    default:
    HitSound = Sound'imp_die_01';
    break;
  }
  PlaySound(HitSound,SLOT_None,RandRange(0.6,1.0),,95000.0,RandRange(0.80,1.20),,False);
}

function playAttackSound()
{
  local Sound HitSound;
  local int randNum;

  randNum = Rand(5);
  switch (randNum)
  {
    case 0:
    HitSound = Sound'imp_attack_01';
    break;
    case 1:
    HitSound = Sound'imp_attack_02';
    break;
    case 2:
    HitSound = Sound'imp_attack_03';
    break;
    case 3:
    HitSound = Sound'imp_attack_04';
    break;
    case 4:
    HitSound = Sound'imp_attack_05';
    break;
    default:
    HitSound = Sound'imp_attack_01';
    break;
  }
  PlaySound(HitSound,SLOT_None,RandRange(0.6,1.0),,95000.0,RandRange(0.80,1.20),,False);
}

function playThrownSound()
{
  impThrownSound = Sound'imp_scream';
  PlaySound(impThrownSound,SLOT_None,RandRange(0.6,1.0),,95000.0,RandRange(0.80,1.20),,False);
}

function playBiteSound()
{
  local Sound biteSound;
  local int randNum;

  randNum = Rand(2);
  switch (randNum)
  {
    case 0:
    biteSound = Sound'imp_bite_01';
    break;
    case 1:
    biteSound = Sound'imp_bite_02';
    break;
    default:
    biteSound = Sound'imp_bite_01';
    break;
  }
  PlaySound(biteSound,SLOT_None,RandRange(0.6,1.0),,10000.0,RandRange(0.80,1.20),,False);
}

function bool HandleSpellFlipendo (optional baseSpell spell, optional Vector vHitLocation)
{
  Super.HandleSpellFlipendo(spell,vHitLocation);
  GotoState('stateHitByFlipendo');
  return True;
}

function Landed (Vector HitNormal)
{
  if ( BOOL_DEBUG_AI )
  {
    PlayerHarry.ClientMessage("" $ string(Name) $ ": In function Landed");
  }
  Super.Landed(HitNormal);
  StopSound(impStruggleSound,SLOT_Misc);
  if ( IsInState('stateGetAwayFromHarry') || IsInState('stateBeingCarried') )
  {
    GotoState('stateGotAwayFromHarry');
  }
}

function ThrownLanded (Vector HitNormal)
{
  local float newR;
  local float NewH;

  newR = Default.CollisionRadius * DrawScale / Default.DrawScale;
  NewH = Default.CollisionHeight * DrawScale / Default.DrawScale;
  if ( NewH < 13 )
  {
    NewH = 13.0;
  }
  SetCollisionSize(newR,NewH);
  StopSound(impStruggleSound,SLOT_Misc);
  StopSound(impThrownSound,SLOT_None);
  if ( !bDespawned )
  {
    GotoState('HitGroundWhenThrown');
  } else {
    if ( GetStateName() != 'stateDied' )
    {
      GotoState('stateDied');
    }
  }
}

function bool GoAfterHarry()
{
  local bool bRet;
  local Vector vVectorToHarry;

  bRet = False;
  vVectorToHarry = PlayerHarry.Location - Location;
  // DD39: Replacing VSize2D with VSize to fix Imp seeing Harry up high (Z coordinate)
  //	  and adding "&& PlayerCanSeeMe() && !PlayerHarry.bIsCaptured && !PlayerHarry.bKeepStationary && !PlayerHarry.IsInState('CelebrateCardSet')":
  if ( VSize(vVectorToHarry) < SightRadius && PlayerCanSeeMe() && !PlayerHarry.bIsCaptured && !PlayerHarry.bKeepStationary && !PlayerHarry.IsInState('CelebrateCardSet') )
  {
    bRet = True;
  }
  return bRet;
}

function bool ReadyPosition()
{
  if ( VSize2D(PlayerHarry.Location - Location) < attackDistance )
  {
    return True;
  }
  return False;
}

function Trigger (Actor Other, Pawn EventInstigator)
{
  if ( bWaitForTrigger )
  {
	cm(string(self.Name) $ " has been triggered");
	bWaitForTrigger = False;
	GotoState('RandomWait');
  }
}

function Tick (float DeltaTime)
{
  // DD39: New local var for GroupName:
  local int I;
  
  Super.Tick(DeltaTime);
  if ( bStunned == True )
  {
    timeStunned -= DeltaTime;
    if ( bCarried == True )
    {
      if ( (timeStunned <= timeWarningWhileCarried) && (bPlayedWarning == False) )
      {
        bPlayedWarning = True;
        impStruggleSound = Sound'imp_attack_01';
        PlaySound(impStruggleSound,SLOT_Misc,RandRange(0.6,1.0),,95000.0,RandRange(0.80,1.20),,True);
        LoopAnim('struggle');
      }
      if ( timeStunned <= 0 )
      {
        GotoState('stateGetAwayFromHarry');
      }
    } else {
      if ( timeStunned <= 0 )
      {
        GotoState('stateUpFromStunned');
      }
    }
  }
  // DD39 (start): Added to fix Imp not despawning when pushed into the hole with Flipendo:
  if ( ( IsInState('stateBeingThrown') ) || ( IsInState('stateHitByFlipendo') ) )
  {
    bDespawnable = True;
  } else {
    bDespawnable = False;
  }
  if ( bDespawned )
  {
    bDespawnable = True;
    if ( ( !IsInState('stateDied') ) )
    {
      GotoState('stateDied');
    }
  }
  // DD39 (end).
  if ( IsInState('patrol') )
  {
    if ( GoAfterHarry() )
    {
      // DD39 (start): Warn friends of Harry's presence:
	  if ( numFriends != 0 )
	  {
		for(I = 0; I < numFriends; I++)
		{
		  if ( myFriends[I] != None )
		  {
		    if ( myFriends[I].IsInState('RandomWait') )
			{
			  myFriends[I].GotoState('stateMoveTowardHarry');
			}
			if ( myFriends[I].IsInState('patrol') )
			{
			  myFriends[I].vHome = myFriends[I].Location;
			  myFriends[I].GotoState('stateMoveTowardHarry');
			}
		  }
		}
	  }
	  // DD39 (end).
	  vHome = Location;
      GotoState('stateMoveTowardHarry');
    }
  }
  if ( bObjectCanBePickedUp == True )
  {
    if ( (Owner == PlayerHarry) && (GetStateName() != 'stateBeingCarried') &&  !IsInState('stateGetAwayFromHarry') )
    {
      GotoState('stateBeingCarried');
    }
  }
  if ( IsInState('stateMoveTowardHarry') )
  {
    runningForHarry -= DeltaTime;
    if ( runningForHarry <= 0 )
    {
      GotoState('takeABreather');
    }
  }
  if ( (IsInState('stateMoveTowardHarry') || IsInState('stateBiteHarry')) && (VSize(Location - vHome) > SightRadius) )
  {
    GotoState('HarryGotAway');
  }
  if ( IsInState('stateMoveTowardHarry') && (ReadyPosition() == True) )
  {
    GotoState('stateBiteHarry');
  }
}

auto state stateIdle
{
begin:
  if ( BOOL_DEBUG_AI )
  {
    PlayerHarry.ClientMessage("" $ string(Name) $ ": auto stateIdle");
  }
  Sleep(0.2);
  SetDifficulty();
  GroundSpeed = GroundWalkSpeed;
  LoopAnim('Walk');
  if ( bWaitForTrigger == True )
  {
    GotoState('stateWaitForTrigger');
  } else {
    GroundSpeed = GroundWalkSpeed;
    LoopAnim('Walk');
    GotoState('RandomWait');
  }
}

state RandomWait
{
begin:
  cm(string(self.Name) $ " Entered random wait. Should start patrol");
  Sleep(FRand() + 0.5);
  GotoState('patrol');
}

state stateMoveTowardHarry
{
  function BeginState()
  {
    runningForHarry = BreathingTimeInterval;
  }
  
 begin:
  if ( BOOL_DEBUG_AI )
  {
    PlayerHarry.ClientMessage("" $ string(Name) $ ": state MoveTowardHarry");
  }
  Velocity = Vec(0.0,0.0,0.0);
  Acceleration = Vec(0.0,0.0,0.0);
  LoopAnim('fidget_1');
  Sleep(1.0);
  playAttackSound();
  GroundSpeed = randomRunningSpeed;
  LoopAnim('run',1.5);
 loop:
  MoveToward(PlayerHarry);
  currentRotation = Rotation;
  currentRotation.Pitch = 0;
  SetRotation(currentRotation);
  Sleep(0.2);
  goto ('Loop');
}

state takeABreather
{
  function BeginState()
  {
    runningForHarry = BreathingTimeInterval;
  }
  
 begin:
  currentRotation = Rotation;
  currentRotation.Pitch = 0;
  DesiredRotation = currentRotation;
  SetRotation(currentRotation);
  // DD39: Moved accel and vel here to prevent sliding:
  Acceleration = vect(0.00,0.00,0.00);
  Velocity = vect(0.00,0.00,0.00);
  PlayAnim('Idle');
  FinishAnim();
  // DD39: Moving these up:
  //Acceleration = vect(0.00,0.00,0.00);
  //Velocity = vect(0.00,0.00,0.00);
  LoopAnim('fidget_1');
  Sleep(FRand() + 2.5);
  // DD39: Check if Harry is still in sight:
  if ( GoAfterHarry() )
  {
    GotoState('stateMoveTowardHarry');
  } else {
    GotoState('stateRunAway');
  }
}

state stateBiteHarry
{
begin:
  Velocity = vect(0.00,0.00,0.00);
  Acceleration = vect(0.00,0.00,0.00);
  vTargetDir = PlayerHarry.Location;
  vTargetDir.Z = Location.Z;
  TurnTo(vTargetDir);
  if ( VSize(PlayerHarry.Location - Location) < attackDistance + 12 )
  {
    PlayAnim('Attack',2.0);
    Sleep(0.4);
    playBiteSound();
    if ( VSize(PlayerHarry.Location - Location) < attackDistance + 12 )
    {
      PlayerHarry.TakeDamage(fDamageAmount,Pawn(Owner),Location,Velocity * 1,'Imp');
    }
  } else {
    PlayAnim('fidget_1');
    FinishAnim();
  }
  Sleep(0.2);
  GotoState('stateRunAway');
}

state stateRunAway
{
  // DD39: Added BeginState
  event BeginState()
  {
    bTimerSet = False;
  }
  
  // DD39: If you get stuck in a wall, start the timer:
  event HitWall( vector HitNormal, actor HitWall )
  {
	if ( !bTimerSet )
	{
	  bTimerSet = True;
	  SetTimer(20.00,false);
	}
  }

  // DD39: When the timer runs out, set a new home:
  event Timer()
  {
	Velocity = vect(0.0,0.0,0.0);
	Acceleration = vect(0.0,0.0,0.0);
	flag = True;
	SetTimer(0.00,false);
	vHome = Location;
	GroundSpeed = GroundWalkSpeed;
	RunAnimName = 'Walk';
    LoopAnim('Idle');
    GotoState('RandomWait');
  }
  
  // DD39: Stop the timer at the end of this state:
  event EndState()
  {
	SetTimer(0.00,false);
	bTimerSet = False;
  }

begin:
  if ( BOOL_DEBUG_AI )
  {
    PlayerHarry.ClientMessage("" $ string(Name) $ ": stateRunAway");
  }
  LoopAnim('run',1.5);
  flag = False;
  // if ( (VSize2D(Location - vHome) > 18) && (flag == False) )
  while ( (VSize2D(Location - vHome) > 18) && (flag == False) )
  {
	MoveTo(vHome);
    Sleep(0.1);
    if ( (VSize(Location - vHome) < SightRadius) && (ReadyPosition() == True) )
    {
      flag = True;
    }
    // goto JL0044;
  }
  // DD39: Stop the timer when you reach home:
  SetTimer(0.00,false);
  GroundSpeed = GroundWalkSpeed;
  // DD39: Replaced Walk with Idle to prevent walking on the spot:
  //LoopAnim('Walk');
  LoopAnim('Idle');
  GotoState('RandomWait');
}

state HarryGotAway
{
begin:
  Velocity = vect(0.00,0.00,0.00);
  Acceleration = vect(0.00,0.00,0.00);
  SetLocation(OldLocation);
  vTemp = Vec(PlayerHarry.Location.X,PlayerHarry.Location.Y,Location.Z);
  vTargetDir = Normal(vTemp - Location);
  DesiredRotation = rotator(vTargetDir);
  LoopAnim('fidget_1');
  playHitSound();
  Sleep(1.5);
  GotoState('stateRunAway');
}

state stateBeingThrown
{
  function BeginState()
  {
    SetCollisionSize(5.0,13.0);
  }
  
 begin:
  StopSound(impStruggleSound,SLOT_Misc);
  playThrownSound();
  PlayAnim('thrown');
  FinishAnim();
  LoopAnim('thrownLoop');
  Sleep(3.0);
}

state stateHitByFlipendo
{
begin:
  if ( BOOL_DEBUG_AI )
  {
    PlayerHarry.ClientMessage("" $ string(Name) $ ": stateHitByFlipendo");
  }
  playHitSound();
  if (  --numAttacks <= 0 )
  {
    numAttacks = numAttacksDefault;
    bStunned = True;
    bObjectCanBePickedUp = True;
    timeStunned = timeStunnedDefault;
    playDieSound();
    PlayAnim('KnockBack');
    FinishAnim();
  } else {
    PlayAnim('KnockBack');
    FinishAnim();
    LoopAnim('Stunned');
    Sleep(0.1);
    PlayAnim('wakingup2run');
    FinishAnim();
    GotoState('stateRunAway');
  }
}

state stateUpFromStunned
{
  // DD39: Added BeginState
  event BeginState()
  {
    bObjectCanBePickedUp = False;
    bStunned = False;
	numAttacks = numAttacksDefault;
  }
  
begin:
  PlayAnim('wakingup2run');
  FinishAnim();
  GotoState('stateRunAway');
}

state HitGround
{
begin:
  LoopAnim('Stunned');
}

state HitGroundWhenThrown
{
  function BeginState()
  {
    timeStunned = timeStunnedDefault;
    bStunned = True;
    bObjectCanBePickedUp = True;
  }
  
 begin:
  playHitSound();
  LoopAnim('Stunned');
}

state stateBeingCarried
{
  function BeginState()
  {
    bCarried = True;
  }
  
  function EndState()
  {
    bCarried = False;
    bStunned = False;
    bPlayedWarning = False;
    bObjectCanBePickedUp = False;
  }
  
 begin:
  LoopAnim('Carried');
}

state stateGetAwayFromHarry
{
begin:
  PlayAnim('Attack',2.0);
  Sleep(0.4);
  PlayerHarry.TakeDamage(fDamageAmount,Pawn(Owner),Location,Velocity * 1,'Imp');
}

state stateGotAwayFromHarry
{
begin:
  LoopAnim('fidget_1');
  vTemp = Vec(PlayerHarry.Location.X,PlayerHarry.Location.Y,Location.Z);
  vTargetDir = Normal(vTemp - Location);
  DesiredRotation = rotator(vTargetDir);
  Sleep(1.5);
  GotoState('stateRunAway');
}

state stateWaitForTrigger
{
  // ignores  Tick; //UTPT added this for some reason -AdamJD
  
  //UTPT didn't add this for some reason -AdamJD
  function Tick(float DeltaTime)
  {
	Global.Tick(DeltaTime);

	timeIdleFidgit -= DeltaTime;

	if ( timeIdleFidgit <= 0 )
	{
		bFidgit = true;
	}
  }
  
 begin:
  LoopAnim('Idle');
 loop:
  if ( bFidgit == True )
  {
    bFidgit = False;
    PlayAnim('fidget_1');
    FinishAnim();
    timeIdleFidgit = 10.0;
    LoopAnim('Idle');
  }
  Sleep(0.5);
  goto ('Loop');
}

state stateDied
{
begin:
  StopSound(impThrownSound,SLOT_None);
  PlaySound(Sound'horklump_mushroom_head_explode',SLOT_None,RandRange(0.6,1.0),,70000.0,RandRange(0.80,1.20),,False);
  if ( Rand(2) == 0 )
  {
    Spawn(Class'DustCloud01_tiny',self,,Location,Rotation);
  } else {
    Spawn(Class'DustCloud02_small',self,,Location,Rotation);
  }
  Destroy();
}

defaultproperties
{
    BreathingTimeInterval=5.00

    impTalkSound=Sound'HPSounds.Critters_sfx.pixie_dust_loop'

    numAttacksDefault=1

    fDamageAmount=2.00

    timeStunnedDefault=20.00

    timeWarningWhileCarried=5.00

    timeIdleFidgit=10.00

    soundFalling(0)=Sound'HPSounds.Critters_sfx.imp_scream'

    // DD39: Let the Tick function handle it:
	//bDespawnable=True

    bThrownObjectDamage=True

    bAccurateThrowing=True

    GroundSpeed=150.00

    AirSpeed=150.00

    SightRadius=600.00

    PeripheralVision=1.00

    GroundRunSpeed=150.00

    // eVulnerableToSpell=13
	eVulnerableToSpell=SPELL_Flipendo

    Mesh=SkeletalMesh'HPModels.skimpMesh'

    DrawScale=1.30

    AmbientGlow=75

    Fatness=140

    CollisionRadius=10.00

    CollisionHeight=15.00

    RotationRate=(Pitch=200000,Yaw=200000,Roll=200000)
}
