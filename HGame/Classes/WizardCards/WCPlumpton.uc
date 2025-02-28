//================================================================================
// WCPlumpton.
//================================================================================

class WCPlumpton extends BronzeCards;

//texture imports -AdamJD
#exec Texture Import File=Textures\Icons\WizCardPlumptonBigTexture.PNG	GROUP=Icons	Name=WizCardPlumptonBigTexture COMPRESSION=P8 UPSCALE=1 Mips=0 Flags=2
#exec Texture Import File=Textures\Skins\WizardCardPlumptonTex0.PNG	GROUP=Skins	Name=WizardCardPlumptonTex0 COMPRESSION=3 UPSCALE=1 Mips=1 Flags=0

function PostBeginPlay()
{
  WizardName = "Roderic Plumpton";
  Super.PostBeginPlay();
}

defaultproperties
{
    Id=83

    bVendorsCanSell=True

    strVendorOwnedAfterGState="GSTATE110"

    textureBig=Texture'HGame.Icons.WizCardPlumptonBigTexture'

    strDescriptionId="WizCard_0077"

    Skin=Texture'HGame.Skins.WizardCardPlumptonTex0'

}
