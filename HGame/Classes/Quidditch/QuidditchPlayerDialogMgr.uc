//================================================================================
// QuidditchPlayerDialogMgr.
//================================================================================

class QuidditchPlayerDialogMgr extends Actor;

const fMinTimeBeforeLineRepeat= 90.0;
const fMaxGapTimeBetweenLines= 10.0;
const fMinGapTimeBetweenLines= 1.6;
const fNoGapTimeBetweenLines= 0.1;
const QC_MAX_DIALOG_VARIANTS= 30;
const MAX_QUID_DIALOG_SEX_NAMES=2;
const MAX_QUID_DIALOG_HOUSE_NAMES=6;

enum HouseAffiliation {
  HA_Gryffindor,
  HA_Ravenclaw,
  HA_Hufflepuff,
  HA_Slytherin,
  HA_Neutral,
  HA_Opponent,
  HA_NumHouses
};

enum Sex {
  SX_Male,
  SX_Female,
  SX_Neutral
};

enum TeamAffiliation {
  TA_Gryffindor,
  TA_Opponent,
  TA_Neutral,
  TA_NumAffiliations
};

struct Candidate
{
  var HouseAffiliation eHouse;
  var int Variant;
  var float fWeight;
};

struct DialogInfo
{
  var string DlgName;
  var Sound dlgSound;
  var string DlgText;
  var bool bHasBeenSaid;
  var float fTimeLastSaid;
};

struct VarDialogInfo
{
  var DialogInfo Variant[30];
  var int Variations;
  var bool bHasBeenSaid;
  var float fTimeLastSaid;
};

struct HouseDependentDialogInfo
{
  var VarDialogInfo House[6];
  var bool bHasBeenSaid;
  var float fTimeLastSaid;
};

var BroomHarry harry;
var string QuidDialogHouseNames[6];
var string QuidDialogSexNames[2];
var HouseDependentDialogInfo Dialog[2];
var Candidate Candidates[90];
var int NumCandidates;
var HouseAffiliation eOpponent;
var float fNextTimeALineCanBeSaid;
var float fGapTime;
var QuidditchPlayer SpeakingPlayers;
var int NumSpeakingPlayers;
var QuidditchPlayer CurrentSpeakingPlayer;

function PostBeginPlay()
{
  local int Variant;
  local QuidditchPlayer Player;

  Super.PostBeginPlay();
  foreach AllActors(Class'BroomHarry',harry)
  {
	break;
  }
  SpeakingPlayers = None;
  NumSpeakingPlayers = 0;
  foreach AllActors(Class'QuidditchPlayer',Player)
  {
    if ( (Player.Team != TeamAffiliation.TA_Neutral) && (Seeker(Player) == None) )
    {
      Player.NextSpeakingPlayer = SpeakingPlayers;
      SpeakingPlayers = Player;
      ++NumSpeakingPlayers;
    }
  }
  CurrentSpeakingPlayer = SpeakingPlayers;
  PickNextSpeakingPlayer();
  fNextTimeALineCanBeSaid = 0.0;
  fGapTime = FRand() * (fMaxGapTimeBetweenLines - fMinGapTimeBetweenLines) + fMinGapTimeBetweenLines;
  fillDialogArray();
}

function SetOpponent (HouseAffiliation eNewOpponent)
{
  eOpponent = eNewOpponent;
  Log("QuidditchPlayerDialogMgr: Opponent = " $ string(eOpponent) $ ".");
}

function StartDialog()
{
  fNextTimeALineCanBeSaid = Level.TimeSeconds + (FRand() * 1.0) + 1.0;
  SetTimer((fNextTimeALineCanBeSaid + fGapTime) - Level.TimeSeconds,False);
}

function StopDialog()
{
  SetTimer(0.0,False);
}

event Timer()
{
  SayADialogLine();
  SetTimer(FMax(fNoGapTimeBetweenLines,(fNextTimeALineCanBeSaid + fGapTime) - Level.TimeSeconds),False);
}

function PickNextSpeakingPlayer()
{
  local int nSkip;

  if ( (CurrentSpeakingPlayer == None) || (NumSpeakingPlayers <= 1) )
  {
    return;
  }
  nSkip = Rand(NumSpeakingPlayers - 1) + 1;
  while (nSkip > 0)
  {
    CurrentSpeakingPlayer = CurrentSpeakingPlayer.NextSpeakingPlayer;
    if ( CurrentSpeakingPlayer == None )
    {
      CurrentSpeakingPlayer = SpeakingPlayers;
    }
    --nSkip;
  }
}

function SayADialogLine()
{
  PickNextSpeakingPlayer();
  if (  !SayDialogLine(True) )
  {
    Log("QuidditchPlayerDialogMgr: Dialog not said.");
  }
}

function float TimeLeftUntilSafeToSayALine (optional bool bNoGap)
{
  local float fTimeLeft;

  fTimeLeft = fNextTimeALineCanBeSaid - Level.TimeSeconds + fNoGapTimeBetweenLines;
  if ( bNoGap )
  {
    fTimeLeft += fNoGapTimeBetweenLines;
  } else {
    fTimeLeft += fGapTime;
  }
  return fTimeLeft;
}

function bool DialogLineHasBeenSaidBefore (Sex eSex)
{
  if ( eSex == SX_Neutral )
  {
    return Dialog[0].bHasBeenSaid || Dialog[1].bHasBeenSaid;
  } else {
    return Dialog[eSex].bHasBeenSaid;
  }
}

function bool SayDialogLine (optional bool bNoGap)
{
  local bool bSaid;
  local Sex eSex;
  local TeamAffiliation eTeam;
  local HouseAffiliation ePlayerHouse;
  local HouseAffiliation eHouse;
  local bool bDone;
  local int Variant;
  local int iCandidate;
  local float fAge;
  local float fTotalWeight;
  local float fChoice;
  local Sound dlgSound;

  bSaid = False;
  if ( bNoGap )
  {
    if ( Level.TimeSeconds < fNextTimeALineCanBeSaid + fNoGapTimeBetweenLines )
    {
      return False;
    }
  } else {
    if ( Level.TimeSeconds < fNextTimeALineCanBeSaid + fGapTime )
    {
      return False;
    }
  }
  switch (CurrentSpeakingPlayer.eSex)
  {
    case SX_Male:
    eSex =  SX_Male;
    break;
    case SX_Female:
    eSex =  SX_Female;
    break;
    case SX_Neutral:
    eSex =  SX_Neutral;
    break;
    default:
  }
  switch (CurrentSpeakingPlayer.Team)
  {
    case TA_Gryffindor:
    eTeam =  TA_Gryffindor;
    break;
    case TA_Opponent:
    eTeam =  TA_Opponent;
    break;
    case TA_Neutral:
    eTeam =  TA_Neutral;
    break;
    default:
  }
  switch (CurrentSpeakingPlayer.eHouse)
  {
    case HA_Gryffindor:
    ePlayerHouse =  HA_Gryffindor;
    break;
    case HA_Ravenclaw:
    ePlayerHouse =  HA_Ravenclaw;
    break;
    case HA_Hufflepuff:
    ePlayerHouse =  HA_Hufflepuff;
    break;
    case HA_Slytherin:
    ePlayerHouse =  HA_Slytherin;
    break;
    default:
  }
  eHouse = ePlayerHouse;
  iCandidate = 0;
  fTotalWeight = 0.0;
  bDone = False;
  Variant = 0;
  
  //do and while loops -AdamJD
  do
  {
	  // if ( Variant < Dialog[bool(eSex)].House[bool(eHouse)].Variations )
	  while ( Variant < Dialog[eSex].House[eHouse].Variations )
	  {
		if (  !Dialog[eSex].House[eHouse].Variant[Variant].bHasBeenSaid )
		{
		  fAge = 300.0;
		} else {
		  fAge = Level.TimeSeconds - (Dialog[eSex].House[eHouse].Variant[Variant].fTimeLastSaid + fMinTimeBeforeLineRepeat);
		  if ( fAge > 300 )
		  {
			fAge = 300.0;
		  }
		}
		if ( fAge > 0.0 )
		{
		  Candidates[iCandidate].eHouse = eHouse;
		  Candidates[iCandidate].Variant = Variant;
		  Candidates[iCandidate].fWeight = fAge;
		  fTotalWeight += Candidates[iCandidate].fWeight;
		  ++iCandidate;
		}
		++Variant;
	  }
	  switch (eHouse)
	  {
		// case 4:
		case HA_Neutral:
		bDone = True;
		break;
		// case 0:
		case HA_Gryffindor:
		// case 5:
		case HA_Opponent:
		eHouse =  HA_Neutral;
		break;
		default:
		eHouse =  HA_Opponent;
		break;
	  }
  }
  until(bDone);
  
  NumCandidates = iCandidate;
  if ( NumCandidates <= 0 )
  {
    Log("QuidditchPlayerDialogMgr: No viable dialog candidates for player right now (Sex=" $ string(eSex) $ ", House=" $ string(ePlayerHouse) $ ").");
    return False;
  }
  iCandidate = 0;
  fChoice = FRand() * fTotalWeight;
  while ( iCandidate < NumCandidates - 1 )
  {
    if ( Candidates[iCandidate].fWeight > fChoice )
    {
	  break;
    } else {
      fChoice -= Candidates[iCandidate].fWeight;
      ++iCandidate;
    }
  }
  eHouse = Candidates[iCandidate].eHouse;
  Variant = Candidates[iCandidate].Variant;
  dlgSound = Dialog[eSex].House[eHouse].Variant[Variant].dlgSound;
  if ( dlgSound != None )
  {
    CurrentSpeakingPlayer.PlaySound(dlgSound,SLOT_Talk,0.333,,5000.0);
    bSaid = True;
  } else {
    Log("QuidditchPlayerDialogMgr: Failed to say dialog for dialog line; DlgName = " $ Dialog[eSex].House[eHouse].Variant[Variant].DlgName $ ".");
  }
  Dialog[eSex].House[eHouse].Variant[Variant].fTimeLastSaid = Level.TimeSeconds;
  Dialog[eSex].House[eHouse].fTimeLastSaid = Level.TimeSeconds;
  Dialog[eSex].fTimeLastSaid = Level.TimeSeconds;
  Dialog[eSex].House[eHouse].Variant[Variant].bHasBeenSaid = True;
  Dialog[eSex].House[eHouse].bHasBeenSaid = True;
  Dialog[eSex].bHasBeenSaid = True;
  if ( dlgSound != None )
  {
    fNextTimeALineCanBeSaid = Level.TimeSeconds + GetSoundDuration(dlgSound);
    fGapTime = FRand() * (fMaxGapTimeBetweenLines - fMinGapTimeBetweenLines) + fMinGapTimeBetweenLines;
  }
  return bSaid;
}

function string GetDialogLineId (int Sex, int House, int Variant)
{
  local string Key;
  local string Id;

  Key = "G"$QuidDialogSexNames[Sex]$QuidDialogHouseNames[House]$"_QuidPlayer";
  Id = Localize(Key,"line" $Variant,"QuidSet");
  if ( InStr(Id,"<") > -1 )
  {
    return "";
  } else {
    return Id;
  }
}

function fillDialogArray()
{
  local int S;
  local int H;
  local int V;
  local string sndId;

  for(S = 0; S < MAX_QUID_DIALOG_SEX_NAMES; S++)
  {
	for(H = 0; H < MAX_QUID_DIALOG_HOUSE_NAMES; H++)
    {
      Dialog[S].House[H].Variations = QC_MAX_DIALOG_VARIANTS;
	  for(V = 0; V < QC_MAX_DIALOG_VARIANTS; V++)
      {
        sndId = GetDialogLineId(S,H,V);
        if ( sndId != "" )
        {
          Dialog[S].House[H].Variant[V].DlgName = sndId;
          Dialog[S].House[H].Variant[V].dlgSound = Sound(DynamicLoadObject("AllDialog." $sndId,Class'Sound'));
        } else {
          Dialog[S].House[H].Variations = V;
		  break;
        }
      }
    }
  }
}

defaultproperties
{
    QuidDialogHouseNames(0)="G"

    QuidDialogHouseNames(1)="R"

    QuidDialogHouseNames(2)="H"

    QuidDialogHouseNames(3)="S"

    QuidDialogHouseNames(4)="N"

    QuidDialogHouseNames(5)="O"

    QuidDialogSexNames(0)="M"

    QuidDialogSexNames(1)="F"

    // eOpponent=1
	eOpponent=HA_Ravenclaw

    bHidden=True

    Texture=Texture'Engine.S_Flag'
}
