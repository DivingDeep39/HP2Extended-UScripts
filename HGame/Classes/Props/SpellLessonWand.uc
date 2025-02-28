//================================================================================
// SpellLessonWand.
//================================================================================

class SpellLessonWand extends HProp;

var SpellLessonTrigger LessonTrigger;
var float fWandSpeed;

function SetParentLessonTrigger (SpellLessonTrigger Trigger)
{
  LessonTrigger = Trigger;
}

function StartWand (float fSetSpeed)
{
  fWandSpeed = fSetSpeed;
  GotoState('PlayGame');
}

function StopWand()
{
  DestroyControllers();
  GotoState('Idle');
}

auto state Idle
{
}

state PlayGame
{
  function bool PawnAtInterpolationPoint (InterpolationPoint IPoint, InterpolationManager IManager)
  {
    return LessonTrigger.WandAtInterpolationPoint(IPoint,IManager);
  }
  
  function BeginState()
  {
    killAttachedParticleFX(0.0);
    CreateAttachedParticleFX();
    FollowSplinePath(LessonTrigger.nameSplinePath,fWandSpeed,0.0,LessonTrigger.nameIPStart,LessonTrigger.nameIPEnd,False,MOVE_TYPE_LINEAR,True);
  }
  
  function EndState()
  {
    killAttachedParticleFX(0.0);
  }
  
}

defaultproperties
{
    attachedParticleClass(0)=Class'HPParticle.LessonSparks1'

    // ePatrolType=2
	ePatrolType=PATROLTYPE_SPLINE_FOLLOW

    bIgnoreStationRotations=True

	//DD39: new mesh to fix the wand's orientation
	Mesh=SkeletalMesh'Extended_Meshes.skDD39WandMesh'

    DrawScale=1.50

    AmbientGlow=250

    CollisionRadius=10.00

    CollisionHeight=10.00

    bBlockActors=False

    bBlockPlayers=False

    bAlignBottom=False

    bBlockCamera=False

    bRotateToDesired=False
}
