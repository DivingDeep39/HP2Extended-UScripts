//================================================================================
// HPMenuOptionCombo.
//================================================================================

class HPMenuOptionCombo extends UWindowComboControl;

//texture imports -AdamJD
#exec Texture Import File=Textures\Icons\FEComboIdleTexture.PNG	GROUP=Icons	Name=FEComboIdleTexture COMPRESSION=3 UPSCALE=1 Mips=1 Flags=2
#exec Texture Import File=Textures\Icons\FEComboOverTexture.PNG	GROUP=Icons	Name=FEComboOverTexture COMPRESSION=3 UPSCALE=1 Mips=1 Flags=2

var Texture IdleTexture;
var Texture OverTexture;

//texture vars for importing -AdamJD
var Texture textureIdle;
var Texture textureOver;


function Created ()
{
  Super.Created();
  IdleTexture = textureIdle; 	//Texture'FEComboIdleTexture';
  OverTexture = textureOver; 	//Texture'FEComboOverTexture';
}

function CreateEditBox ()
{
  EditBox = HPMenuOptionEditBox(CreateWindow(Class'HPMenuOptionEditBox',0.0,0.0,WinWidth,WinHeight));
}

function CreateComboButton ()
{
  Button = HPMenuOptionComboButton(CreateWindow(Class'HPMenuOptionComboButton',0.0,0.0,WinWidth,WinHeight));
}

function CreateComboList ()
{
  List = HPMenuOptionComboList(Root.CreateWindow(ListClass,0.0,0.0,WinWidth,WinHeight));
}

function BeforePaint (Canvas C, float X, float Y)
{
  local float W;
  local float H;

  C.Font = Root.Fonts[Font];
  List.bLeaveOnscreen = bListVisible && bLeaveOnscreen;
  TextSize(C,Text,W,H);
  TextY = (WinHeight - H) / 2;
  TextX = WinWidth - W - 20 - EditBoxWidth;
}

function Paint (Canvas C, float X, float Y)
{
  if ( Text != "" )
  {
    C.DrawColor = TextColor;
    ClipText(C,TextX,TextY,Text);
    C.DrawColor.R = 255;
    C.DrawColor.G = 255;
    C.DrawColor.B = 255;
  }
  if ( bListVisible )
  {
    DrawClippedTexture(C,WinWidth - EditBoxWidth,1.0,OverTexture);
  } else //{
    if ( MouseIsOver() || EditBox.MouseIsOver() || Button.MouseIsOver() )
    {
      DrawClippedTexture(C,WinWidth - EditBoxWidth,1.0,OverTexture);
    } else {
      DrawClippedTexture(C,WinWidth - EditBoxWidth,1.0,IdleTexture);
    }
  //}
}

function CloseUpWithNoSound ()
{
  bListVisible = False;
  EditBox.SetEditable(bCanEdit);
  EditBox.SelectAll();
  List.HideWindow();
}

defaultproperties
{
    ListClass=Class'HPMenuOptionComboList'
	
	//get the imported textures -AdamJD
	textureIdle=FEComboIdleTexture
	
	textureOver=FEComboOverTexture
}
