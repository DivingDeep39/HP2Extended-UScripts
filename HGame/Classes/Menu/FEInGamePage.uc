//================================================================================
// FEInGamePage.
//================================================================================

class FEInGamePage extends baseFEPage;

/*
// Metallicafan212:	Textures for the new layout
#exec Texture Import File=Textures\InGamePage\Bottom.png	GROUP=FEBook	Name=FEBottom 	COMPRESSION=3 UPSCALE=1 Mips=1 Flags=536870914
#exec Texture Import File=Textures\InGamePage\Top.png		GROUP=FEBook	Name=FETop 		COMPRESSION=3 UPSCALE=1 Mips=1 Flags=536870914
#exec Texture Import File=Textures\InGamePage\LTop.png		GROUP=FEBook	Name=FETLeft	COMPRESSION=3 UPSCALE=1 Mips=1 Flags=536870914
#exec Texture Import File=Textures\InGamePage\LBot.png		GROUP=FEBook	Name=FEBLeft	COMPRESSION=3 UPSCALE=1 Mips=1 Flags=536870914
#exec Texture Import File=Textures\InGamePage\RTop.png		GROUP=FEBook	Name=FETRight	COMPRESSION=3 UPSCALE=1 Mips=1 Flags=536870914
#exec Texture Import File=Textures\InGamePage\RBot.png		GROUP=FEBook	Name=FEBRight	COMPRESSION=3 UPSCALE=1 Mips=1 Flags=536870914
#exec Texture Import File=Textures\InGamePage\Back.png		GROUP=FEBook	Name=FEBack		COMPRESSION=1 UPSCALE=1 Mips=1 Flags=0

// Metallicafan212:	Test
#exec Texture Import File=Textures\DeusEx.png				GROUP=FEBook	Name=FEDX		COMPRESSION=1 UPSCALE=1 MIPS=1 FLAGS=0

// Metallicafan212:	Texture vars for these
var Texture FEBot;
var Texture FETop;
var Texture FETL;
var Texture FEBL;
var Texture FETR;
var Texture FEBR;
var Texture FEBackground;

// Metallicafan212:	Optional middle "flavor" texture
var Texture FEMid;
*/

var HPMessageBox ConfirmQuit;
var bool bSetupAfterPageSwitch;
var HGameButton BeansButton;
var HGameButton HousepointsButton;
var HGameButton SecretsButton;
var HGameButton PotionsButton;
var HGameButton FMucusButton;
var HGameButton WBarkButton;
var HGameButton ChallengesButton;
var HGameButton DuelButton;
var HGameButton FolioButton;
var HGameButton MapButton;
var HGameButton QuidditchButton;

//DD39: adding Stars button
var HGameButton StarsButton;

var HGameButton QuitButton;
var HGameButton InputButton;
var HGameButton CreditsButton;
var HGameButton SoundVideoButton;
var HGameSmallButton VersionButton;
var Texture textureChallengesRO;
var Texture textureMapRO;
var Texture textureDuelRO;
var Texture textureQuidRO;
var Texture textureQuitRO;
var Texture textureInputRO;
var Texture textureSoundRO;
var Texture textureCreditsRO;
var Texture textureFolioRO;
var Texture textureGryffRO;
var string strCurrToolTip;
var string strSecretsCount;
var Sound soundTopClick;
var Sound soundMiddleClick;
var Sound soundFolioClick;
var Sound soundBottomClick;
var Sound soundTopRO;
var Sound soundMiddleRO;
var Sound soundFolioRO;
var Sound soundBottomRO;
const nCOUNT_MID_Y= 58;
const nCOUNT_MID_X= 50;
const nTOOLTIP_TEXT_H= 46;
const nTOOLTIP_TEXT_Y= 424;
const nTOOLTIP_TEXT_X= 6;
const nOBJECTIVE_CLIP_X= 626;
const nOBJECTIVE_TEXT_H= 58;
const nOBJECTIVE_TEXT_W= 640;
const nOBJECTIVE_TEXT_Y= 416;
const nOBJECTIVE_TEXT_X= 14;
const nOBJECTIVE_LABEL_H= 16;
const nOBJECTIVE_LABEL_Y= 400;
const nBOTTOM_BAR_Y= 392;
const nTOP_BAR_Y=   0;
const nBAR_H=  88;
const nBAR_X=   0;

function Paint (Canvas Canvas, float X, float Y)
{
	local float fScaleFactor;
	local bool bHaveObjectiveText;
	
	local float HScale, MidUSize, MidVSize;
	
	HScale = Class'M212HScale'.Static.CanvasGetHeightScale(Canvas);

	fScaleFactor = Canvas.SizeX / WinWidth;
	if ( strCurrToolTip != "" )
	{
		PaintToolTipText(Canvas,fScaleFactor);
	} 
	else 
	{
		PaintObjectiveText(Canvas,fScaleFactor);
	}
	
	/*
	// Metallicafan212:	Height scale
	fScaleFactor *= HScale;
	
	// Metallicafan212:	Paint the background layer
	Canvas.bNoUVClamp = true;
	Canvas.SetPos(0, 0);
	Canvas.SetClip(Canvas.SizeX, Canvas.SizeY);
	Canvas.DrawTileClipped(FEBackground, Canvas.SizeX, Canvas.SizeY, 0.0, 0.0, Canvas.SizeX * 2.5, Canvas.SizeY * 2.5);
	
	// Metallicafan212:	We need to scale the pos to the middle of the screen
	if(FEMid != none)
	{
		if(FEMid.USize > FEMid.VSize)
		{
			MidUSize = 137.0 * fScaleFactor * (FEMid.USize / float(FEMid.VSize));
			MidVSize = 137.0 * fScaleFactor;
			
			//Log(MidUSize $ " " $ MidVSize);
			
			// Metallicafan212:	Optional middle icon
			Canvas.SetPos((Canvas.SizeX / 2.0) - MidUSize, (Canvas.SizeY / 2.0) - MidVSize);
			Canvas.DrawTile(FEMid, fScaleFactor * 274.0 * (FEMid.USize / float(FEMid.VSize)), fScaleFactor * 274.0, 0.0, 0.0, FEMid.USize, FEMid.VSize);
		}
		else
		{
			MidUSize = 137.0 * fScaleFactor;
			MidVSize = 137.0 * fScaleFactor * (FEMid.VSize / float(FEMid.USize));
			
			//Log(MidUSize $ " " $ MidVSize);
			
			// Metallicafan212:	Optional middle icon
			Canvas.SetPos((Canvas.SizeX / 2.0) - MidUSize, (Canvas.SizeY / 2.0) - MidVSize);
			Canvas.DrawTile(FEMid, fScaleFactor * 274.0, fScaleFactor * 274.0 * (FEMid.VSize / float(FEMid.USize)), 0.0, 0.0, FEMid.USize, FEMid.VSize);
		}
	}
	
	// Metallicafan212:	Now draw the top
	// 					Middle first
	Canvas.SetPos(0, 0);
	Canvas.DrawTile(FETop, Canvas.SizeX, 128 * fScaleFactor, 0.0, 0.0, FETop.USize, FETop.VSize);
	
	// Metallicafan212:	Left bracket
	Canvas.SetPos(0, 0);
	Canvas.DrawIcon(FETL, fScaleFactor * (128.0 / FETL.VSize));
	
	// Metallicafan212:	Right bracket
	Canvas.SetPos(Canvas.SizeX - (128.0 * fScaleFactor), 0);
	Canvas.DrawIcon(FETR, fScaleFactor * (128.0 / FETL.VSize));
	
	// Metallicafan212:	Draw the bottom
	//					Middle first
	Canvas.SetPos(0, Canvas.SizeY - (128.0 * fScaleFactor));
	
	Canvas.DrawTile(FEBot, Canvas.SizeX, 128 * fScaleFactor, 0.0, 0.0, FETop.USize, FETop.VSize);
	
	// Metallicafan212:	Left bracket
	Canvas.SetPos(0, Canvas.SizeY - (128.0 * fScaleFactor));
	Canvas.DrawIcon(FEBL, fScaleFactor * (128.0 / FETL.VSize));
	
	// Metallicafan212:	Right bracket
	Canvas.SetPos(Canvas.SizeX - (128.0 * fScaleFactor), Canvas.SizeY - (128.0 * fScaleFactor));
	Canvas.DrawIcon(FEBR, fScaleFactor * (128.0 / FETL.VSize));
	
	Canvas.bNoUVClamp = false;
	*/
	
	Super.Paint(Canvas, X, Y);
}

function AfterPaint (Canvas Canvas, float X, float Y)
{
	local float fScaleFactor;
	local bool bHaveObjectiveText;
	local int nSaveStyle;

	fScaleFactor = Canvas.SizeX / WinWidth;
	PaintCountText(Canvas,fScaleFactor);
	
	Super.AfterPaint(Canvas,X,Y);
}

function PaintToolTipText (Canvas Canvas, float fScaleFactor)
{
	local Font fontText;
	local Color colorText;
	local harry PlayerHarry;
	
	// Metallicafan212:	Move it up
	local float HScale;
	
	HScale = Class'M212HScale'.Static.UWindowGetHeightScale(Root);

	PlayerHarry = harry(Root.Console.Viewport.Actor);
	if ( Canvas.SizeX <= 512 )
	{
		fontText = baseConsole(PlayerHarry.Player.Console).LocalSmallFont;
	} 
	else 
	{
		if ( Canvas.SizeX <= 800 )
		{
			fontText = baseConsole(PlayerHarry.Player.Console).LocalMedFont;
		} 
		else 
		{
			fontText = baseConsole(PlayerHarry.Player.Console).LocalBigFont;
		}
	}
	
	colorText.R = 255;
	colorText.G = 255;
	colorText.B = 255;
	HPHud(PlayerHarry.myHUD).DrawCutStyleText(Canvas, strCurrToolTip, nTOOLTIP_TEXT_X * fScaleFactor, nTOOLTIP_TEXT_Y * fScaleFactor * HScale, nTOOLTIP_TEXT_H * fScaleFactor, colorText, fontText);
}

function PaintObjectiveText (Canvas Canvas, float fScaleFactor)
{
	local string strObjectiveId;
	local string strObjective;
	local Font fontText;
	local Color colorText;
	local harry PlayerHarry;
	// DivingDeep39: Used for setting the localization file and section
	local string strObjectiveIntFile, strObjectiveSection;
	

	PlayerHarry = harry(Root.Console.Viewport.Actor);
	strObjectiveId = PlayerHarry.strObjectiveId;
	
	// DivingDeep39: Grab the Section and Localization File from Harry.uc
	strObjectiveSection = PlayerHarry.strObjectiveSection;
	strObjectiveIntFile = PlayerHarry.strObjectiveIntFile;

	if ( strObjectiveId != "" )
	{
		// DivingDeep39: Replaced with function below
		//strObjective = Localize("All",strObjectiveId,"HPDialog");
		strObjective = Localize(strObjectiveSection,strObjectiveId,strObjectiveIntFile);
		
		strObjective = PlayerHarry.HandleFacialExpression(strObjective,0,True);
		if ( Canvas.SizeX <= 512 )
		{
			fontText = baseConsole(PlayerHarry.Player.Console).LocalSmallFont;
		} 
		else 
		{
			fontText = baseConsole(PlayerHarry.Player.Console).LocalMedFont;
		}
		colorText.R = 255;
		colorText.G = 255;
		colorText.B = 255;
	
		HPHud(PlayerHarry.myHUD).DrawCutStyleText(Canvas,GetLocalFEString("InGameMenu_0027"), nOBJECTIVE_TEXT_X * fScaleFactor, nOBJECTIVE_LABEL_Y * fScaleFactor * Class'M212HScale'.Static.UWindowGetHeightScale(Root), nOBJECTIVE_LABEL_H * fScaleFactor, colorText, fontText);
		HPHud(PlayerHarry.myHUD).DrawCutStyleText(Canvas,strObjective, nOBJECTIVE_TEXT_X * fScaleFactor, nOBJECTIVE_TEXT_Y * fScaleFactor * Class'M212HScale'.Static.UWindowGetHeightScale(Root), nOBJECTIVE_TEXT_H * fScaleFactor, colorText, fontText, nOBJECTIVE_CLIP_X * fScaleFactor);
	}
}

function PaintCountText (Canvas Canvas, float fScaleFactor)
{
	local StatusManager managerStatus;
	local StatusItem si;
	
	local float hScale;
	
	// Metallicafan212:	Calc once
	hScale = Class'M212HScale'.Static.UWindowGetHeightScale(Root);

	managerStatus = harry(Root.Console.Viewport.Actor).managerStatus;
	si = managerStatus.GetStatusItem(Class'StatusGroupHousePoints',Class'StatusItemGryffindorPts');
	si.DrawCount(Canvas,HousepointsButton.WinLeft * fScaleFactor, HousepointsButton.WinTop * fScaleFactor * hScale, fScaleFactor * hScale);
	si = managerStatus.GetStatusItem(Class'StatusGroupJellybeans',Class'StatusItemJellybeans');
	si.DrawCount(Canvas,BeansButton.WinLeft * fScaleFactor, BeansButton.WinTop * fScaleFactor * hScale, fScaleFactor * hScale);
	si = managerStatus.GetStatusItem(Class'StatusGroupPotions',Class'StatusItemWiggenwell');
	si.DrawCount(Canvas,PotionsButton.WinLeft * fScaleFactor, PotionsButton.WinTop * fScaleFactor * hScale, fScaleFactor * hScale);
	si = managerStatus.GetStatusItem(Class'StatusGroupPotionIngr',Class'StatusItemFlobberMucus');
	si.DrawCount(Canvas,FMucusButton.WinLeft * fScaleFactor, FMucusButton.WinTop * fScaleFactor * hScale, fScaleFactor * hScale);
	si = managerStatus.GetStatusItem(Class'StatusGroupPotionIngr',Class'StatusItemWiggenBark');
	si.DrawCount(Canvas,WBarkButton.WinLeft * fScaleFactor, WBarkButton.WinTop * fScaleFactor * hScale, fScaleFactor * hScale);
	
	//DD39: adding Stars Paint Count Text
	si = managerStatus.GetStatusItem(Class'StatusGroupStars',Class'StatusItemStars');
	si.DrawCount(Canvas,StarsButton.WinLeft * fScaleFactor, StarsButton.WinTop * fScaleFactor * hScale, fScaleFactor * hScale);
	
	DrawCount(Canvas, fScaleFactor, SecretsButton.WinLeft, SecretsButton.WinTop, strSecretsCount);
}

function DrawCount (Canvas Canvas, float fScaleFactor, int nButtonLeft, int nButtonTop, string strCount)
{
	local Font fontSave;
	local StatusManager managerStatus;
	local StatusItem si;
	local float fXTextLen;
	local float fYTextLen;
	
	local float hScale;
	
	// Metallicafan212:	Calc once
	hScale = Class'M212HScale'.Static.UWindowGetHeightScale(Root);

	fontSave = Canvas.Font;
	managerStatus = harry(Root.Console.Viewport.Actor).managerStatus;
	si = managerStatus.GetStatusItem(Class'StatusGroupJellybeans',Class'StatusItemJellybeans');
	Canvas.DrawColor = si.GetCountColor();
	Canvas.Font = si.GetCountFont(Canvas);
	Canvas.TextSize(strCount,fXTextLen,fYTextLen);
	Canvas.SetPos(((nButtonLeft + (nCOUNT_MID_X * HScale)) * fScaleFactor - fXTextLen / 2), (nButtonTop + nCOUNT_MID_Y) * (fScaleFactor * hScale) - fYTextLen / 2);
	Canvas.DrawShadowText(strCount, si.GetCountColor(), si.GetCountColor(True));
	Canvas.Font = fontSave;
}

function int GetObjectiveAreaTop (int nCanvasSizeX, int nCanvasSizeY)
{
	local float fScaleFactor;

	fScaleFactor = nCanvasSizeX / WinWidth;
	//return nCanvasSizeY - 88 * fScaleFactor = return;
	return (nCanvasSizeY - nBAR_H * fScaleFactor * Class'M212HScale'.Static.UWindowGetHeightScale(Root));
}

function Created()
{
	// Metallicafan212:	Move the buttons
	//local float HScale;
	
	//HScale = GetHeightScale();
	
	// Metallicafan212:	Weld button
	PotionsButton = HGameButton(CreateAlignedControl(Class'HGameButton', 30.0, 16.0, 64.0, 64.0,,AT_Left));
	PotionsButton.ToolTipString = GetLocalFEString("InGameMenu_0020");
	PotionsButton.UpTexture = Texture(DynamicLoadObject("HP2_Menu.Icons.HP2MenuWPotion",Class'Texture'));
	PotionsButton.OverTexture = PotionsButton.UpTexture;
	PotionsButton.DownTexture = PotionsButton.OverTexture;
	PotionsButton.DownSound = None;
  
	FMucusButton = HGameButton(CreateAlignedControl(Class'HGameButton',110.0,16.0,64.0,64.0,,AT_Left));
	FMucusButton.ToolTipString = GetLocalFEString("InGameMenu_0008");
	FMucusButton.UpTexture = Texture(DynamicLoadObject("HP2_Menu.Icons.HP2MenuFMucus",Class'Texture'));
	FMucusButton.OverTexture = FMucusButton.UpTexture;
	FMucusButton.DownTexture = FMucusButton.OverTexture;
	FMucusButton.DownSound = None;
	
	WBarkButton = HGameButton(CreateAlignedControl(Class'HGameButton',192.0,16.0,64.0,64.0,,AT_Left));
	WBarkButton.ToolTipString = GetLocalFEString("InGameMenu_0019");
	WBarkButton.UpTexture = Texture(DynamicLoadObject("HP2_Menu.Icons.HP2MenuWBark",Class'Texture'));
	WBarkButton.OverTexture = WBarkButton.UpTexture;
	WBarkButton.DownTexture = WBarkButton.OverTexture;
	WBarkButton.DownSound = None;
	
	//DD39: creating Stars button 
	StarsButton = HGameButton(CreateAlignedControl(Class'HGameButton',378.0,16.0,64.0,64.0,,AT_Right));
	StarsButton.ToolTipString = GetLocalFEString("InGameMenu_0018");
	//DD39: using the og Menu Challenges icon because it fits better
	//		StarsButton.UpTexture = Texture(DynamicLoadObject("HP2_Menu.Icons.HP2starcounter",Class'Texture'));
	StarsButton.UpTexture = Texture(DynamicLoadObject("HP2_Menu.Icons.HP2MenuChallenges",Class'Texture'));
	StarsButton.OverTexture = StarsButton.UpTexture;
	StarsButton.DownTexture = StarsButton.OverTexture;
	StarsButton.DownSound = None;
  
	//DD39: original pos 416 instead of 462
	//BeansButton = HGameButton(CreateAlignedControl(Class'HGameButton',416.0,16.0,64.0,64.0,,AT_Right));
	BeansButton = HGameButton(CreateAlignedControl(Class'HGameButton',462.0,16.0,64.0,64.0,,AT_Right));
	BeansButton.ToolTipString = GetLocalFEString("InGameMenu_0013");
	BeansButton.UpTexture = Texture(DynamicLoadObject("HP2_Menu.Icons.HP2MenuJellyBeans",Class'Texture'));
	BeansButton.OverTexture = BeansButton.UpTexture;
	BeansButton.DownTexture = BeansButton.OverTexture;
	BeansButton.DownSound = None;
	
	//DD39: original pos 532 instead of 546
	//SecretsButton = HGameButton(CreateAlignedControl(Class'HGameButton',532.0,16.0,64.0,64.0,,AT_Right));
	SecretsButton = HGameButton(CreateAlignedControl(Class'HGameButton',546.0,16.0,64.0,64.0,,AT_Right));
	SecretsButton.ToolTipString = GetLocalFEString("Report_Card_0006");
	SecretsButton.UpTexture = Texture(DynamicLoadObject("HP2_Menu.Icons.HP2MenuSecrets",Class'Texture'));
	SecretsButton.OverTexture = SecretsButton.UpTexture;
	SecretsButton.DownTexture = SecretsButton.OverTexture;
	SecretsButton.DownSound = None;
  
	HousepointsButton = HGameButton(CreateAlignedControl(Class'HGameButton',278.0,5.0,70.0,98.0,,AT_Center));
	HousepointsButton.ToolTipString = GetLocalFEString("InGameMenu_0046");
	HousepointsButton.UpTexture = Texture(DynamicLoadObject("HP2_Menu.Icons.HP2GriffindorCrest",Class'Texture'));
	HousepointsButton.OverTexture = HousepointsButton.UpTexture;
	HousepointsButton.DownTexture = HousepointsButton.OverTexture;
	HousepointsButton.DownSound = soundTopClick;
	
	ChallengesButton = HGameButton(CreateAlignedControl(Class'HGameButton',146.0,114.0,64.0,64.0,,AT_Center));
	ChallengesButton.ToolTipString = GetLocalFEString("InGameMenu_0044");
	//DD39: changing the Menu Challenges icon with a custom one
	//ChallengesButton.UpTexture = Texture(DynamicLoadObject("HP2_Menu.Icons.HP2MenuChallenges",Class'Texture'));
	ChallengesButton.UpTexture = Texture(DynamicLoadObject("Extended_Textures.Icons.HP2MenuChallenges",Class'Texture'));
	ChallengesButton.OverTexture = ChallengesButton.UpTexture;
	ChallengesButton.DownTexture = ChallengesButton.OverTexture;
	ChallengesButton.DownSound = soundMiddleClick;
	
	DuelButton = HGameButton(CreateAlignedControl(Class'HGameButton',146.0,248.0,64.0,64.0,,AT_Center));
	DuelButton.ToolTipString = GetLocalFEString("InGameMenu_0043");
	DuelButton.UpTexture = Texture(DynamicLoadObject("HP2_Menu.Icons.HP2MenuWizardDuel",Class'Texture'));
	DuelButton.OverTexture = DuelButton.UpTexture;
	DuelButton.DownTexture = DuelButton.OverTexture;
	DuelButton.DownSound = soundMiddleClick;
  
	FolioButton = HGameButton(CreateAlignedControl(Class'HGameButton',252.0,134.0,136.0,168.0,,AT_Center));
	FolioButton.ToolTipString = GetLocalFEString("InGameMenu_0004");
	FolioButton.UpTexture = Texture(DynamicLoadObject("HP2_Menu.Icons.HP2MenuFolioButtonIdle",Class'Texture'));
	FolioButton.OverTexture = FolioButton.UpTexture;
	FolioButton.DownTexture = FolioButton.OverTexture;
	FolioButton.DownSound = soundFolioClick;
  
	MapButton = HGameButton(CreateAlignedControl(Class'HGameButton',438.0,114.0,64.0,64.0,,AT_Center));
	MapButton.ToolTipString = GetLocalFEString("InGameMenu_0045");
	MapButton.UpTexture = Texture(DynamicLoadObject("HP2_Menu.Icons.HP2Maps",Class'Texture'));
	MapButton.OverTexture = MapButton.UpTexture;
	MapButton.DownTexture = MapButton.OverTexture;
	MapButton.DownSound = soundMiddleClick;
  
	QuidditchButton = HGameButton(CreateAlignedControl(Class'HGameButton',438.0,248.0,64.0,64.0,,AT_Center));
	QuidditchButton.ToolTipString = GetLocalFEString("InGameMenu_0042");
	QuidditchButton.UpTexture = Texture(DynamicLoadObject("HP2_Menu.Icons.HP2MenuQuidditch",Class'Texture'));
	QuidditchButton.OverTexture = QuidditchButton.UpTexture;
	QuidditchButton.DownTexture = QuidditchButton.OverTexture;
	QuidditchButton.DownSound = soundMiddleClick;
  
	QuitButton = HGameButton(CreateAlignedControl(Class'HGameButton',12.0,338.0,48.0,48.0,,AT_Left));
	QuitButton.ToolTipString = GetLocalFEString("InGameMenu_0002");
	QuitButton.UpTexture = Texture(DynamicLoadObject("HP2_Menu.Icons.HP2MenuQuit",Class'Texture'));
	QuitButton.OverTexture = QuitButton.UpTexture;
	QuitButton.DownTexture = QuitButton.OverTexture;
	QuitButton.DownSound = soundBottomClick;
  
	InputButton = HGameButton(CreateAlignedControl(Class'HGameButton',72.0,338.0,48.0,48.0,,AT_Left));
	InputButton.ToolTipString = GetLocalFEString("InGameMenu_0047");
	InputButton.UpTexture = Texture(DynamicLoadObject("HP2_Menu.Icons.HP2Options",Class'Texture'));
	InputButton.OverTexture = InputButton.UpTexture;
	InputButton.DownTexture = InputButton.OverTexture;
	InputButton.DownSound = soundBottomClick;
  
	SoundVideoButton = HGameButton(CreateAlignedControl(Class'HGameButton',520.0,338.0,48.0,48.0,,AT_Right));
	SoundVideoButton.ToolTipString = GetLocalFEString("InGameMenu_0048");
	SoundVideoButton.UpTexture = Texture(DynamicLoadObject("HP2_Menu.Icons.HP2MenuSoundOptions",Class'Texture'));
	SoundVideoButton.OverTexture = SoundVideoButton.UpTexture;
	SoundVideoButton.DownTexture = SoundVideoButton.OverTexture;
	SoundVideoButton.DownSound = soundBottomClick;
  
	//DD39: changin the Menu Challenges wet icon with a custom one
	//textureChallengesRO = Texture(DynamicLoadObject("HP2_Menu.HP2ChallengesBarWet",Class'WetTexture'));
	textureChallengesRO = Texture(DynamicLoadObject("Extended_Textures.Icons.HP2MenuChallengesWet",Class'WetTexture'));
	textureMapRO = Texture(DynamicLoadObject("HP2_Menu.Icons.HP2MapsWet",Class'WetTexture'));
	textureDuelRO = Texture(DynamicLoadObject("HP2_Menu.Icons.HP2MenuWizardDuelWet",Class'WetTexture'));
	textureQuidRO = Texture(DynamicLoadObject("HP2_Menu.Icons.HP2MenuQuidditchWet",Class'WetTexture'));
	textureQuitRO = Texture(DynamicLoadObject("HP2_Menu.Icons.HP2MenuQuitWet",Class'WetTexture'));
	textureInputRO = Texture(DynamicLoadObject("HP2_Menu.Icons.HP2OptionsWet",Class'WetTexture'));
	textureSoundRO = Texture(DynamicLoadObject("HP2_Menu.Icons.HP2MenuSoundOptionsWet",Class'WetTexture'));
	textureFolioRO = Texture(DynamicLoadObject("HP2_Menu.Icons.HP2MenuFolioButtonIdle",Class'Texture'));
	textureGryffRO = Texture(DynamicLoadObject("HP2_Menu.Icons.HP2GriffindorCrestWet",Class'WetTexture'));
  
	CreateBackPageButton(578,338);
	
	if ( HPConsole(Root.Console).bDebugMode )
	{
		CreditsButton = HGameButton(CreateAlignedControl(Class'HGameButton',135.0,338.0,48.0,48.0,,AT_Left));
		CreditsButton.ToolTipString = "Credits";
		CreditsButton.UpTexture = InputButton.UpTexture;
		CreditsButton.OverTexture = CreditsButton.UpTexture;
		CreditsButton.DownTexture = CreditsButton.DownTexture;
		textureCreditsRO = textureInputRO;
		SoundVideoButton.DownSound = soundBottomClick;
	}
  
	VersionButton = HGameSmallButton(CreateControl(Class'HGameSmallButton',550.0,462.0,84.0,25.0));
	VersionButton.SetFont(0);
	VersionButton.TextColor.R = 250;
	VersionButton.TextColor.G = 250;
	VersionButton.TextColor.B = 250;
	VersionButton.Align = TA_Right;
	VersionButton.SetText(Class'Version'.Default.Version);
	
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
			case InputButton:
				FEBook(book).ChangePageNamed("INPUT");
				break;
      
			case SoundVideoButton:
				FEBook(book).ChangePageNamed("SOUNDVIDEO");
				break;
      
			case QuitButton:
				ConfirmQuit = doHPMessageBox(GetLocalFEString("InGameMenu_0026"), GetLocalFEString("Shared_Menu_0003"), GetLocalFEString("Shared_Menu_0004"));
				break;
      
			case BackPageButton:
				FEBook(book).CloseBook();
				break;
      
			case FolioButton:
				FEBook(book).ChangePageNamed("FOLIO");
				break;
      
			case QuidditchButton:
				FEBook(book).ChangePageNamed("QUIDDITCH");
				break;
      
			case DuelButton:
				FEBook(book).ChangePageNamed("DUEL");
				break;
      
			case ChallengesButton:
				FEBook(book).ChangePageNamed("CHALLENGES");
				break;
      
			case MapButton:
				FEBook(book).ChangePageNamed("MAP");
				break;
      
			case CreditsButton:
				FEBook(book).ChangePageNamed("CREDITSPAGE");
				break;
     
			case HousepointsButton:
				FEBook(book).ChangePageNamed("HPOINTS");
				break;
			
			default:
				break;
		}
	} 
	else 
	{
		if ( E == DE_MouseEnter )
		{
			switch (C)
			{
				case DuelButton:
					SetRollover(DuelButton,textureDuelRO,soundMiddleRO,True);
					break;
				
				case ChallengesButton:
					SetRollover(ChallengesButton,textureChallengesRO,soundMiddleRO,True);
					break;
				
				case MapButton:
					SetRollover(MapButton,textureMapRO,soundMiddleRO,True);
					break;
				
				case QuidditchButton:
					SetRollover(QuidditchButton,textureQuidRO,soundMiddleRO,True);
					break;
				
				case QuitButton:
					SetRollover(QuitButton,textureQuitRO,soundBottomRO,True);
					break;
				
				case InputButton:
					SetRollover(InputButton,textureInputRO,soundBottomRO,True);
					break;
				
				case SoundVideoButton:
					SetRollover(SoundVideoButton,textureSoundRO,soundBottomRO,True);
					break;
				
				case FolioButton:
					SetRollover(FolioButton,textureFolioRO,soundFolioRO,False);
					break;
				
				case CreditsButton:
					SetRollover(CreditsButton,textureCreditsRO,soundBottomRO,True);
					break;
				
				case HousepointsButton:
					SetRollover(HousepointsButton,textureGryffRO,soundTopRO,True);
					break;
			}
		} 
		else 
		{
			if ( E == DE_MouseLeave )
			{
				switch (C)
				{
					case DuelButton:
					case ChallengesButton:
					case MapButton:
					case QuidditchButton:
					case QuitButton:
					case InputButton:
					case SoundVideoButton:
					case FolioButton:
					case CreditsButton:
					case HousepointsButton:
						ClearRollover();
						break;
				}
			}
		}
	}
	
	Super.Notify(C,E);
}

function PreSwitchPage()
{
	Super.PreSwitchPage();
	strSecretsCount = GetSecretsCount();
	if ( HPConsole(Root.Console).bDebugMode )
	{
		VersionButton.ShowWindow();
	} 
	else 
	{
		VersionButton.HideWindow();
	}
}

function ToolTip (string strSetTip)
{
	strCurrToolTip = strSetTip;
}

function string GetSecretsCount()
{
	local string strSecrets;
	local int nNumSecrets;
	local int nNumSecretsFound;
	local SecretAreaMarker Marker;

	foreach Root.Console.Viewport.Actor.AllActors(Class'SecretAreaMarker',Marker)
	{
		nNumSecrets++;
		if ( Marker.bFound )
		{
			nNumSecretsFound++;
		}
	}
	
	strSecrets = string(nNumSecretsFound) $ "/" $ string(nNumSecrets);
  
	return strSecrets;
}

defaultproperties
{
    soundTopClick=Sound'HPSounds.menu_sfx.GUI_Esc_Click3'

    soundMiddleClick=Sound'HPSounds.menu_sfx.GUI_Esc_Click1'

    soundFolioClick=Sound'HPSounds.menu_sfx.GUI_Esc_Click2'

    soundBottomClick=Sound'HPSounds.menu_sfx.GUI_Esc_Click5'

    soundTopRO=Sound'HPSounds.menu_sfx.GUI_Esc_Rollover1'

    soundMiddleRO=Sound'HPSounds.menu_sfx.GUI_Esc_Rollover2'

    soundFolioRO=Sound'HPSounds.menu_sfx.GUI_Esc_Rollover3'

    soundBottomRO=Sound'HPSounds.menu_sfx.GUI_Esc_Rollover4'
	
	//FEMid=Texture'HGame.LoadingScreen.FELoadingScreen'
}