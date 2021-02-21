//================================================================================
// Ring3.
//================================================================================

class Ring3 extends ParticleFX;

defaultproperties
{
    ParticlesPerSec=(Base=175.00,Rand=0.00)

    SourceWidth=(Base=0.00,Rand=0.00)

    SourceHeight=(Base=0.00,Rand=0.00)

    bSteadyState=True

    Speed=(Base=20.00,Rand=0.00)

    Lifetime=(Base=1.00,Rand=0.50)

    ColorStart=(Base=(R=99,G=243,B=44,A=0),Rand=(R=0,G=0,B=0,A=0))

    ColorEnd=(Base=(R=247,G=254,B=107,A=0),Rand=(R=0,G=0,B=0,A=0))

    SizeWidth=(Base=35.00,Rand=15.00)

    SizeLength=(Base=35.00,Rand=15.00)

    SizeEndScale=(Base=-1.00,Rand=0.00)

    Distribution=DIST_OwnerMesh

    GravityModifier=0.10

    Textures=Texture'HPParticle.hp_fx.Particles.flare4'

    Rotation=(Pitch=16640,Yaw=0,Roll=0)
}
