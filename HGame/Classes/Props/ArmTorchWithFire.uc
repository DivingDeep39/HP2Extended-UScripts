//================================================================================
// ArmTorchWithFire.
//================================================================================

class ArmTorchWithFire extends ArmTorch;

defaultproperties
{
    attachedParticleClass(0)=Class'HPParticle.FireHP2'

    attachedParticleOffset(0)=(X=-18.00,Y=-4.00,Z=14.00)

    AmbientSound=Sound'HPSounds.General.torch01'

    SoundRadius=16

    SoundVolume=96
}
