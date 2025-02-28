//================================================================================
// Hedwig.
//================================================================================

class Hedwig extends Characters;

const BOOL_DEBUG_AI= false;
var Vector vHome;
var() name HedwigPaths[5];
var() int shortestTimeBetweenSpells;
var() int longestTimeBetweenSpells;
var name HedwigCurrentPath;
var() bool bDoNothingAtStartup;
// DD39: Added custom bools
var() bool bCapturable;

function PreBeginPlay()
{
  Super.PreBeginPlay();
  vHome = Location;
  HedwigCurrentPath = 'dummyPath';
  LoopAnim('Breathe');
}

function OnEvent (name EventName)
{
  if ( EventName == 'ActionDone' )
  {
    SetMyTimer();
  }
}

function SetMyTimer (optional float Time)
{
  local int minTimer;
  local int maxTimer;

  minTimer = shortestTimeBetweenSpells;
  maxTimer = longestTimeBetweenSpells;
  if ( Time == 0 )
  {
    SetTimer(minTimer + Rand(maxTimer - minTimer),False);
  } else {
    SetTimer(Time,False);
  }
}

function StopOnSpline()
{
  IPSpeed = 0.000001;
}

function ContinueOnSpline()
{
  IPSpeed = 0.0;
}

function GotoNewPath()
{
  local int Select;
  local int Count;
  local int numPaths;
  local name TempName;
  local name singlePath;

  // Count = 0;
  // if ( Count < 5 )
  for(Count = 0; Count < 5; Count++)
  {
    TempName = HedwigPaths[Count];
    if ( TempName != 'None' )
    {
      numPaths++;
      singlePath = TempName;
    }
    // Count++;
    // goto JL0007;
  }
  switch (numPaths)
  {
    case 0:
    Log(string('You must enter a pathname for Hedwig'));
    break;
    case 1:
    HedwigCurrentPath = singlePath;
    break;
    default:
    Select = Rand(5);
    // if ( HedwigPaths[Select] == HedwigCurrentPath )
	while ( HedwigPaths[Select] == HedwigCurrentPath )
    {
      Select = Rand(5);
      // goto JL0084;
    }
    HedwigCurrentPath = HedwigPaths[Select];
    break;
  }
  cm("Hedwig in on a path : " $ string(HedwigCurrentPath));
  FollowSplinePath(HedwigCurrentPath,SplineSpeed,0.0,);
}

function PlayerCutCapture()
{
  // DD39: If bCapturable, go to CutIdle:
  if ( bCapturable )
  {
    cm("Hedwig has been captured" $ CutName);
    GotoState('CutIdle');
    return;
  }
  
  // DD39: Removed as it's unnecessary:
 /*if ( CutName != "CreditsHedwig" )
  {
    cm("Hedwig has been captured" $ CutName);
    GotoState('CutIdle');
  }*/
}

function PlayerCutRelease()
{
  // DD39: If bCapturable, return from CutIdle.
  if ( bCapturable )
  {
    cm("Hedwig has been released");
    GotoState('stateIdle');
  }
}

// DD39: Added function to handle spellAlohomora
function bool HandleSpellAlohomora (optional baseSpell spell, optional Vector vHitLocation)
{
  if ( eVulnerableToSpell == SPELL_Alohomora )
  {
	Super.HandleSpellAlohomora(spell,vHitLocation);
	eVulnerableToSpell = SPELL_None;
	TriggerEvent(Event,None,None);
	return True;
  }
}

auto state stateIdle
{
begin:
  cm("This is where Hedwig begins");
  if (  !bDoNothingAtStartup )
  {
    if ( BOOL_DEBUG_AI )
    {
      PlayerHarry.ClientMessage("" $ string(Name) $ ": auto stateIdle");
    }
	// DD39: It's best she just flies off:
    /*LoopAnim('Breathe');
    Sleep(2.0);
    PlayAnim('takeoff');
	Sleep(0.3666666667);*/
	LoopAnim('Fly');
    GotoNewPath();
  }
}

function Tick (float DeltaTime)
{
  Super.Tick(DeltaTime);
}

state CutIdle
{
begin:
  DestroyControllers();
  Acceleration = vect(0.00,0.00,0.00);
  Velocity = vect(0.00,0.00,0.00);
  // DD39: New animation:
  LoopAnim('Drop');
}

state patrolFollowSpline
{
  //UTPT added this for some reason -AdamJD
  // ignores  Tick; 
  
  function EndState()
  {
    Super.EndState();
    // SetPhysics(4);
	SetPhysics(PHYS_Flying);
    SetMyTimer(0.0);
  }
  
  //UTPT didn't add this for some reason -AdamJD
  function Tick(float DeltaTime)
  {
    Global.Tick(DeltaTime);
  }
  
  function Timer()
  {
    SetMyTimer(3.0);
  }
  
}

defaultproperties
{
    shortestTimeBetweenSpells=5

    longestTimeBetweenSpells=30

    ShadowScale=0.00

    SightRadius=4000.00

    PeripheralVision=0.00

    MenuName="Hedwig"

    bDoEyeBlinks=False

    // Physics=4
	Physics=PHYS_Flying

    Mesh=SkeletalMesh'HPModels.skowlbarnMesh'

    RotationRate=(Pitch=100000,Yaw=100000,Roll=100000)
}
