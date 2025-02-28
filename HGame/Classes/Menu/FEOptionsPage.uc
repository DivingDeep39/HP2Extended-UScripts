//================================================================================
// FEOptionsPage.
//================================================================================

class FEOptionsPage extends baseFEPage;

const fOBJECTIVE_Y_TOP= 420.0;
const fOBJECTIVE_Y_MIDDLE= 440.0;
const fOBJECTIVE_Y_BOTTOM= 460.0;
const fOBJECTIVE_H= 20;
const fOBJECTIVE_W= 640;
const fOBJECTIVE_X= 0;
var HPMessageBox ConfirmQuit;
var bool bSetupAfterPageSwitch;
var HGameButton HudButtonList[30];
var HGameButton QuitButton;
var HGameButton InputButton;
var HGameButton SoundVideoButton;
var HGameLabelControl QuitLabel;
var HGameLabelControl InputLabel;
var HGameLabelControl SoundVideoLabel;
var HGameLabelControl ObjectiveLabel;
var Texture textureLionClick;
var Texture textureLionIdle;
var Texture textureLionRO; 


function BeforePaint (Canvas C, float X, float Y)
{
	Super.BeforePaint(C,X,Y);
}

function Paint (Canvas Canvas, float X, float Y)
{
	local float fScaleFactor;
	local bool bHaveObjectiveText;

	fScaleFactor = Canvas.SizeX / WinWidth;
	Super.Paint(Canvas,X,Y);
}

function int GetObjectiveAreaTop (int nCanvasSizeX, int nCanvasSizeY)
{
	local float fScaleFactor;

	fScaleFactor = nCanvasSizeX / WinWidth;
	/*
	if ( ObjectiveLabel.WindowIsVisible() )
	{
		return ObjectiveLabel.WinTop * fScaleFactor = } else {;
		return nCanvasSizeY;
	}
	*/
 
	if ( ObjectiveLabel.WindowIsVisible() )
	{
		return ObjectiveLabel.WinTop * fScaleFactor; 
	}
	else 
	{
		return nCanvasSizeY;
	}
}

function Created()
{
  textureLionClick = Texture(DynamicLoadObject("HP_Menu.Hud.MenuLionButtonClick",Class'Texture'));
  textureLionIdle = Texture(DynamicLoadObject("HP_Menu.Hud.MenuLionButtonIdle",Class'Texture'));
  textureLionRO = Texture(DynamicLoadObject("HP_Menu.Hud.MenuLionButtonRO",Class'Texture'));
  InputButton = HGameButton(CreateControl(Class'HGameButton',182.0,310.0,60.0,60.0));
  InputButton.UpTexture = textureLionIdle;
  InputButton.DownTexture = textureLionClick;
  InputButton.OverTexture = textureLionRO;
  InputLabel = HGameLabelControl(CreateControl(Class'HGameLabelControl',182.0 - 50,310.0 + 60,200.0,64.0));
  InputLabel.SetFont(F_HPMenuLarge);
  InputLabel.TextColor.R = 215;
  InputLabel.TextColor.G = 0;
  InputLabel.TextColor.B = 215;
  // InputLabel.Align = 2;
  InputLabel.Align = TA_Center; //from UWindowBase.uc in the proto -AdamJD 
  InputLabel.bShadowText = True;
  InputLabel.SetText(GetLocalFEString("Options_0040"));
  SoundVideoButton = HGameButton(CreateControl(Class'HGameButton',252.0,120.0,136.0,106.0));
  SoundVideoButton.UpTexture = textureLionIdle;
  SoundVideoButton.DownTexture = textureLionClick;
  SoundVideoButton.OverTexture = textureLionRO;
  SoundVideoLabel = HGameLabelControl(CreateControl(Class'HGameLabelControl',252.0 - 50,120.0 + 108,200.0,64.0));
  SoundVideoLabel.SetFont(F_HPMenuLarge);
  SoundVideoLabel.TextColor.R = 215;
  SoundVideoLabel.TextColor.G = 0;
  SoundVideoLabel.TextColor.B = 215;
  // SoundVideoLabel.Align = 2;
  SoundVideoLabel.Align = TA_Center; //from UWindowBase.uc in the proto -AdamJD 
  SoundVideoLabel.bShadowText = True;
  SoundVideoLabel.SetText(GetLocalFEString("Options_0041"));
  QuitButton = HGameButton(CreateControl(Class'HGameButton',394.0,310.0,60.0,60.0));
  QuitButton.UpTexture = textureLionIdle;
  QuitButton.DownTexture = textureLionClick;
  QuitButton.OverTexture = textureLionRO;
  QuitLabel = HGameLabelControl(CreateControl(Class'HGameLabelControl',394.0 + 30 - 50,310.0 + 62,200.0,64.0));
  QuitLabel.SetFont(F_HPMenuLarge);
  QuitLabel.TextColor.R = 215;
  QuitLabel.TextColor.G = 0;
  QuitLabel.TextColor.B = 215;
  // QuitLabel.Align = 2;
  QuitLabel.Align = TA_Center; //from UWindowBase.uc in the proto -AdamJD 
  QuitLabel.bShadowText = True;
  QuitLabel.SetText(GetLocalFEString("InGameMenu_0025"));
  Super.Created();
}

function WindowDone (UWindowWindow W)
{
  if ( W == ConfirmQuit )
  {
    if ( ConfirmQuit.Result == ConfirmQuit.button1.Text )
    {
      Root.DoQuitGame();
    }
    ConfirmQuit = None;
  }
}

function bool KeyEvent(EInputKey Key, EInputAction Action, float Delta)
{
	return False;
}

function Notify (UWindowDialogControl C, byte E)
{
  local int I;

  if ( E == DE_Click )
  {
    switch (C)
    {
      case QuitButton:
      ConfirmQuit = doHPMessageBox(GetLocalFEString("InGameMenu_0026"),GetLocalFEString("Shared_Menu_0003"),GetLocalFEString("Shared_Menu_0004"));
      break;
      case InputButton:
      FEBook(book).ChangePageNamed("INPUT");
      break;
      case SoundVideoButton:
      FEBook(book).ChangePageNamed("SOUNDVIDEO");
      break;
      default:
	  break;
    }
  }
}

function PreSwitchPage()
{
  Super.PreSwitchPage();
}

