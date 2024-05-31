//================================================================================
// DD39JustinInfirmary.
//================================================================================

class DD39JustinInfirmary extends Characters;

defaultproperties
{
    Mesh=SkeletalMesh'Extended_Meshes.skJustinInfirmaryMesh'
	
	AmbientGlow=10
	
	bBlockActors=False
	
	bCollideActors=False
	
	CollisionHeight=30.00

    CollisionRadius=30.00

    CollisionWidth=65.00

    //CollideType=2
	CollideType=CT_Box
	
	Physics=PHYS_Falling
	
	ShadowClass=None
}