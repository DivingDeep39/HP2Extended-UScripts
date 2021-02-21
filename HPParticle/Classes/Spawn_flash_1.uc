//================================================================================
// Spawn_flash_1.
//================================================================================

class Spawn_flash_1 extends ParticleFX;

defaultproperties
{
    ParticlesPerSec=(Base=5.00,Rand=0.00)

    Speed=(Base=20.00,Rand=30.00)

    Lifetime=(Base=0.50,Rand=0.00)

    ColorStart=(Base=(R=172,G=40,B=242,A=0),Rand=(R=0,G=0,B=0,A=0))

    ColorEnd=(Base=(R=23,G=52,B=249,A=0),Rand=(R=0,G=0,B=0,A=0))

    SizeWidth=(Base=120.00,Rand=50.00)

    SizeLength=(Base=120.00,Rand=50.00)

    SpinRate=(Base=-5.00,Rand=10.00)

    SizeDelay=2.00

    Chaos=3.00

    ChaosDelay=0.50

    ParticlesAlive=5

    ParticlesMax=5

    Textures=Texture'HPParticle.hp_fx.Particles.flare4'

    CollisionRadius=40.00

    CollisionHeight=40.00
}
