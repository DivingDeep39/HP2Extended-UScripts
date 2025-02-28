//================================================================================
// StatusItem.
//================================================================================

class StatusItem extends Actor
  Abstract; 

var StatusItem siNext;
var StatusGroup sgParent;
var string strHudIcon;
var Texture textureHudIcon;
var bool bDisplayCount;
var bool bDisplayMaxCount;
var bool bMenuModeOnly;
var int nCount;
var int nMaxCount;
var int nCurrCountPotential;
var int nActualIconW;
var int nActualIconH;
var int nCountMiddleX;
var int nCountMiddleY;
var string strToolTipId;
var bool bDisplayWhenCountZero;
var bool bIncrementPosWhenCountZero;
var bool bTravelStatus;

// Metallicafan212:	if we want smooth icons
var bool bSmoothIcons;

// Metallicafan212:	Icon scale
var float XScale;
var float YScale;

enum ECountColor 
{
	CountColor_Black,
	CountColor_NearWhite,
	CountColor_White
};

var ECountColor CountColor;
var ECountColor CountShadowColor;



event PreBeginPlay()
{
	if ( strHudIcon != "" )
	{
		textureHudIcon = Texture(DynamicLoadObject(strHudIcon,Class'Texture'));
	}
}

function IncrementCount (int nNum)
{
	SetCount(nCount + nNum);
}

function SetCount (int nNum)
{
	nCount = nNum;
	if ( nCount < 0 )
	{
		nCount = 0;
	} 
	else if ( nCurrCountPotential != 0 )
	{
		if ( nCount > nCurrCountPotential )
		{
			nCount = nCurrCountPotential;
		}
	} 
	else if ( nMaxCount != 0 )
	{
		if ( nCount > nMaxCount )
		{
			nCount = nMaxCount;
		}
	}
}

function int GetCount()
{
	return nCount;
}

function int GetPotentialCount()
{
	return nCurrCountPotential;
}

function IncrementCountPotential (int nNum)
{
	nCurrCountPotential += nNum;
	if ( nCurrCountPotential < 0 )
	{
		nCurrCountPotential = 0;
	} 
	else if ( (nMaxCount != 0) && (nCurrCountPotential > nMaxCount) )
	{
		nCurrCountPotential = nMaxCount;
	}
}

function SetCountToMaxPotential()
{
	nCount = nCurrCountPotential;
}

function float GetPotentialToMaxCountRatio()
{
	if ( nMaxCount != 0 )
	{
		return float(nCurrCountPotential) / float(nMaxCount);
	} 
	else 
	{
		Log("Divide by 0");
		return 0.0;
	}
}

function float GetCountToMaxCountRatio()
{
	if ( nMaxCount > 0 )
	{
		return float(nCount) / float(nMaxCount);
	} 
	else 
	{
		Log("Divide by 0");
		return 0.0;
	}
}

function float GetCountToCurrPotentialRatio()
{
	return float(nCount) / float(nCurrCountPotential);
}

function Color GetCountColor (optional bool bShadow)
{
	local Color colorRet;
	local ECountColor ColorToGet;

	if ( bShadow )
	{
		ColorToGet = CountShadowColor;
	} 
	else 
	{
		ColorToGet = CountColor;
	}
	switch (ColorToGet)
	{
		case CountColor_Black:
			colorRet.R = 0;
			colorRet.G = 0;
			colorRet.B = 0;
			break;
		case CountColor_White:
			colorRet.R = 255;
			colorRet.G = 255;
			colorRet.B = 255;
			break;
		case CountColor_NearWhite:
			colorRet.R = 206;
			colorRet.G = 200;
			colorRet.B = 190;
			break;
		default:
			break;
	}
	return colorRet;
}

function Font GetCountFont (Canvas Canvas)
{
	local Font fontRet;

	if ( Canvas.SizeX <= 512 )
	{
		fontRet = baseConsole(sgParent.smParent.PlayerHarry.Player.Console).LocalSmallFont;
	} 
	else if ( Canvas.SizeX <= 640 )
	{
		fontRet = baseConsole(sgParent.smParent.PlayerHarry.Player.Console).LocalMedFont;
	} 
	else 
	{
		fontRet = baseConsole(sgParent.smParent.PlayerHarry.Player.Console).LocalBigFont;
	}
	return fontRet;
}

function float GetHScale(Canvas Canvas)
{
	return (4.0 / 3.0) / (Canvas.SizeX / float(Canvas.SizeY));
}

function DrawItem (Canvas Canvas, int nCurrX, int nCurrY, float fScaleFactor)
{
	local float LocScale;
	local float UScale;
	local float VScale;
	
	local bool bSavedNoSmooth;
	
	local float HScale;
	
	// Metallicafan212:	Get the scale
	HScale = class'M212HScale'.static.CanvasGetHeightScale(Canvas);
	
	bSavedNoSmooth = Canvas.bNoSmooth;
	
	LocScale = fScaleFactor * HScale;
	
	// Metallicafan212:	Allow for scaling icons down to the "draw" coords
	UScale = XScale / textureHudIcon.USize;
	VScale = YScale / textureHudIcon.VSize;
	
	if(bSmoothIcons)
		Canvas.bNoSmooth = false;
	
	// Metallicafan212:	Scale it
	Canvas.SetPos(nCurrX, nCurrY * HScale);
	Canvas.DrawTile(textureHudIcon, textureHudIcon.USize * LocScale * UScale, textureHudIcon.VSize * LocScale * VScale, 0, 0, textureHudIcon.USize, textureHudIcon.VSize );
	
	if ( bDisplayCount )
	{
		DrawCount(Canvas, nCurrX, nCurrY * HScale, fScaleFactor * HScale);
	}
	
	Canvas.bNoSmooth = bSavedNoSmooth;
}

function DrawSpecifiedCount (Canvas Canvas, int nCurrX, int nCurrY, float fScaleFactor, int nLocalCount)
{
	local Font fontSave;
	local string strCountDisplay;
	local float fXTextLen;
	local float fYTextLen;
	local float fXPos;
	local float fYPos;
	
	// Metallicafan212:	Scale here, rather than above, to fix certain issues
	//local float HScale;
	
	//HScale = class'M212HScale'.Static.CanvasGetHeightScale(Canvas);

	fXTextLen = 0.0;
	fYTextLen = 0.0;
	fontSave = Canvas.Font;
	strCountDisplay = string(nLocalCount);
	if ( bDisplayMaxCount == True )
	{
		strCountDisplay = strCountDisplay $ "/" $ string(nMaxCount);
	}
	Canvas.Font = GetCountFont(Canvas);
	Canvas.TextSize(strCountDisplay, fXTextLen, fYTextLen);
	fXPos = nCurrX + nCountMiddleX * fScaleFactor - fXTextLen / 2;
	
	fYPos = (nCurrY + nCountMiddleY * fScaleFactor - fYTextLen / 2); //* HScale;
	
	if ( fXPos + fXTextLen > Canvas.SizeX )
	{
		fXPos = Canvas.SizeX - (fXTextLen - 2);
	}
	if ( fYPos + fYTextLen > Canvas.SizeY )
	{
		fYPos = Canvas.SizeY - (fYTextLen - 2);
	}
	Canvas.SetPos(fXPos, fYPos);
	Canvas.DrawShadowText(strCountDisplay, GetCountColor(), GetCountColor(True));
	Canvas.Font = fontSave;
}

function DrawCount (Canvas Canvas, int nCurrX, int nCurrY, float fScaleFactor)
{
	DrawSpecifiedCount(Canvas, nCurrX, nCurrY, fScaleFactor, nCount);
}

function int GetHudIconUSize()
{
	if ( nActualIconW == 0 )
	{
		return textureHudIcon.USize;
	} 
	else 
	{
		return nActualIconW;
	}
}

function int GetHudIconVSize()
{
	if ( nActualIconH == 0 )
	{
		return textureHudIcon.VSize;
	} 
	else 
	{
		return nActualIconH;
	}
}

function string GetToolTip()
{
	return Localize("All",strToolTipId,"HPMenu");
}

defaultproperties
{
    nCountMiddleX=50
    nCountMiddleY=58
    bDisplayWhenCountZero=True
    bIncrementPosWhenCountZero=True
    bTravelStatus=True
    CountColor=CountColor_NearWhite
    bHidden=True
    // DrawType=0
	DrawType=DT_None
	
	XScale=64
	YScale=64
}
