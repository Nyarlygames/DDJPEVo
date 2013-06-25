//-------------------------------------------------------------------------------
//    Interface for SpriteEngine(Based on DraculaLin  24-July-2006)
//-------------------------------------------------------------------------------
unit SpriteInterface;
//-------------------------------------------------------------------------------
//    huaosft(http://www.huosoft.com)               Modified:3-Jan-2007
//-------------------------------------------------------------------------------
//    huaosft(http://www.huosoft.com)               Created:3-May-2006
//-------------------------------------------------------------------------------

interface
uses
     Windows, Types, Classes, SysUtils, Math, AsphyreDef, AsphyreDevices, AsphyreCanvas,
     AsphyreImages, Direct3D9,Vectors2,AsphyreEffects;
const

 fxuSrcColorAdd   = $200;
 fxuInvert        = $201;
 fxuSrcBright     = $202;
 fxuDestBright    = $203;
 fxuInvSrcBright  = $204;
 fxuInvDestBright = $205;
 fxuMultiplyAlpha = $206;

 fxuAdd2X         = $207;
 fxuLight         = $208;
 fxuLightAdd      = $209;
 fxuBright        = $20A;
 fxuBrightAdd     = $20B;
 fxuGrayScale     = $20C;
 fxuOneColor      = $20D;
type
 //---------------------------------------------------------------------------
 PPolygon = ^TPolygon;
 TPolygon = array of TPoint2;

function pBounds4s2(_Left, _Top, _Width, _Height, ScaleX, ScaleY: Real): TPoint4;
function pBounds4sc2(_Left, _Top, _Width, _Height, ScaleX, ScaleY: Real): TPoint4;
// rotated rectangle (Origin + Size) around (Middle) with Angle and Scale
function pRotate4(const Origin, Size, Middle: TPoint2; Angle: Real;
 Scale: Real=1.0): TPoint4;
function pRotate42(const Origin, Size, Middle: TPoint2; Angle: Real;
 ScaleX, ScaleY: Real ): TPoint4;
 function pRotate4c(const Origin, Size: TPoint2; Angle: Real;
 Scale: Real=1.0): TPoint4;
function pRotate4c2(const Origin, Size: TPoint2; Angle,
 ScaleX, ScaleY: Real): TPoint4;
function pRotateTransForm(const X, Y, X1, Y1, X2, Y2, X3, Y3, X4, Y4 ,
 CenterX, CenterY, Angle: Real; Scale: Real = 1.0): TPoint4;
function pRotateTransForm2(const X, Y, X1, Y1, X2, Y2, X3, Y3, X4, Y4 ,
 CenterX, CenterY, Angle, ScaleX, ScaleY: Real): TPoint4;

function RectInRect(const Rect1, Rect2: TRect): Boolean;
function PointInRect(const Point: TPoint; const Rect: TRect): Boolean;
function OverlapRect(const Rect1, Rect2: TRect): Boolean;
function OverlapQuadrangle(Q1, Q2: TPoint4): Boolean;
function OverlapPolygon(P1, P2: TPolygon): Boolean;
//---------------------------------------------------------------------------
//  precalculate   Sin Table, Cos Table
//---------------------------------------------------------------------------
function Cos8(i: Integer): Double;
function Sin8(i: Integer): Double;
function Cos16(i: Integer): Double;
function Sin16(i: Integer): Double;
function Cos32(i: Integer): Double;
function Sin32(i: Integer): Double;
function Cos64(i: Integer): Double;
function Sin64(i: Integer): Double;
function Cos128(i: Integer):Double;
function Sin128(i: Integer):Double;
function Cos256(i: Integer):Double;
function Sin256(i: Integer):Double;
function Cos512(i: Integer):Double;
function Sin512(i: Integer):Double;


type
  TAsphyreCanvasEx = class(TAsphyreCanvas)
  public

// set screen gamma
//  procedure SetGamma(Red, Green, Blue, Brightness, Contrast: Byte);
  // extended draw  routines
  procedure DrawEx(Image: TAsphyreImage; PatternIndex: Integer; X, Y, ScaleX, ScaleY: Real;
    DoCenter, MirrorX, MirrorY: Boolean; Color: TColor4; DrawFx: Integer); overload;
  procedure DrawEx(Image: TAsphyreImage; PatternIndex: Integer; X, Y, Scale: Real;
    DoCenter: Boolean; Color: TColor4; DrawFx: Integer); overload;
  procedure DrawEx(Image: TAsphyreImage; PatternIndex: Integer; X, Y: Real;
    Color: TColor4; DrawFx: Integer); overload;
  procedure DrawColor1(Image: TAsphyreImage; PatternIndex: Integer; X, Y, ScaleX, ScaleY: Real;
    DoCenter, MirrorX, MirrorY: Boolean; Red, Green, Blue, Alpha: Byte; DrawFx: Integer); overload;
  procedure DrawColor1(Image: TAsphyreImage; PatternIndex: Integer; X, Y, Scale: Real;
    DoCenter: Boolean; Red, Green, Blue, Alpha: Byte; DrawFx: Integer); overload;
  procedure DrawColor1(Image: TAsphyreImage; PatternIndex: Integer; X, Y: Real;
    Red, Green, Blue, Alpha: Byte; DrawFx: Integer); overload;
  procedure DrawAlpha1(Image: TAsphyreImage; PatternIndex: Integer; X, Y, ScaleX, ScaleY: Real;
    DoCenter, MirrorX, MirrorY: Boolean; Alpha: Byte; DrawFx: Integer); overload;
  procedure DrawAlpha1(Image: TAsphyreImage; PatternIndex: Integer; X, Y, Scale: Real;
    DoCenter: Boolean; Alpha: Byte; DrawFx: Integer); overload;
  procedure DrawAlpha1(Image: TAsphyreImage; PatternIndex: Integer; X, Y: Real;
    Alpha: Byte; DrawFx: Integer); overload;
  procedure DrawColor4(Image: TAsphyreImage; PatternIndex: Integer; X, Y, ScaleX, ScaleY: Real;
    DoCenter, MirrorX, MirrorY: Boolean; Color1, Color2, Color3, Color4: Cardinal; DrawFx: Integer); overload;
  procedure DrawColor4(Image: TAsphyreImage; PatternIndex: Integer; X, Y, Scale: Real;
    DoCenter: Boolean; Color1, Color2, Color3, Color4: Cardinal; DrawFx: Integer); overload;
  procedure DrawColor4(Image: TAsphyreImage; PatternIndex: Integer; X, Y: Real;
    Color1, Color2, Color3, Color4: Byte; DrawFx: Integer); overload;
  procedure DrawAlpha4(Image: TAsphyreImage; PatternIndex: Integer; X, Y, ScaleX, ScaleY: Real;
    DoCenter, MirrorX, MirrorY: Boolean; Alpha1, Alpha2, Alpha3, Alpha4: Byte; DrawFx: Integer); overload;
  procedure DrawAlpha4(Image: TAsphyreImage; PatternIndex: Integer; X, Y, Scale: Real;
    DoCenter: Boolean; Alpha1, Alpha2, Alpha3, Alpha4: Byte; DrawFx: Integer); overload;
  procedure DrawAlpha4(Image: TAsphyreImage; PatternIndex: Integer; X, Y: Real;
    Alpha1, Alpha2, Alpha3, Alpha4: Byte; DrawFx: Integer); overload;
  procedure DrawStretch(Image: TAsphyreImage; PatternIndex: Integer; X1, Y1, X2, Y2: Integer;
    MirrorX, MirrorY: Boolean; Color: TColor4; DrawFx: Integer); overload;
  procedure DrawStretch(Image: TAsphyreImage; PatternIndex: Integer; X, Y, Width, Height,
    ScaleX, ScaleY: Real; DoCenter, MirrorX, MirrorY: Boolean; Color: TColor4; DrawFx: Integer); overload;
  procedure DrawPortion(Image: TAsphyreImage; PatternIndex: Integer; X, Y: Real;
    SrcX1, SrcY1, SrcX2, SrcY2: Integer; ScaleX, ScaleY: Real;
    DoCenter, MirrorX, MirrorY: Boolean; Color: TColor4; DrawFx: Integer); overload;
  procedure DrawPortion(Image: TAsphyreImage; PatternIndex: Integer; X, Y: Real;
    SrcX1, SrcY1, SrcX2, SrcY2: Integer; Color: TColor4; DrawFx: Integer); overload;
  procedure DrawRectStretch(Image: TAsphyreImage; PatternIndex: Integer; X1, y1, X2, Y2: Real;
    SrcX1, SrcY1, SrcX2, SrcY2: Integer; MirrorX, MirrorY: Boolean; Color: TColor4; DrawFx: Integer);
  procedure DrawTransForm(Image: TAsphyreImage; PatternIndex: Integer; X1, Y1, X2, Y2,
    X3, Y3, X4, Y4: Real; MirrorX, MirrorY: Boolean; Color: TColor4; DrawFx: Integer);
  procedure DrawRectTransForm(Image: TAsphyreImage; PatternIndex: Integer; X1, Y1, X2, Y2,
    X3, Y3, X4, Y4: Real; SrcX1, SrcY1, SrcX2, SrcY2: Integer;
    MirrorX, MirrorY: Boolean; Color: TColor4; DrawFx: Integer);
  procedure DrawRotateC(Image: TAsphyreImage; PatternIndex: Integer; X, Y, Angle: Real;
    Color: TColor4; DrawFx: Integer); overload;
  procedure DrawRotateC(Image: TAsphyreImage; PatternIndex: Integer; X, Y, Angle,
    ScaleX, ScaleY: Real; Color: TColor4; DrawFx: Integer); overload;
  procedure DrawRotateC(Image: TAsphyreImage; PatternIndex: Integer; X, Y, Angle,
    ScaleX, ScaleY: Real; MirrorX, MirrorY: Boolean; Color: TColor4; DrawFx: Integer); overload;
  procedure DrawRotate(Image: TAsphyreImage; PatternIndex: Integer; X, Y, CenterX, CenterY,
    Angle: Real; Color: TColor4; DrawFx: Integer); overload;
  procedure DrawRotate(Image: TAsphyreImage; PatternIndex: Integer; X, Y, CenterX, CenterY,
    Angle, ScaleX, ScaleY: Real; MirrorX, MirrorY: Boolean; Color: TColor4; DrawFx: Integer); overload;
  procedure DrawRotate(Image: TAsphyreImage; PatternIndex: Integer; X, Y, CenterX, CenterY,
    Angle, ScaleX, ScaleY: Real; Color: TColor4; DrawFx: Integer); overload;
  procedure DrawRotateStretchC(Image: TAsphyreImage; PatternIndex: Integer; X, Y,
    Width, Height, Angle: Real; Color: TColor4; DrawFx: Integer); overload;
  procedure DrawRotateStretchC(Image: TAsphyreImage; PatternIndex: Integer; X, Y,
    Width, Height, Angle, ScaleX, ScaleY: Real; Color: TColor4; DrawFx: Integer); overload;
  procedure DrawRotateStretchC(Image: TAsphyreImage; PatternIndex: Integer; X, Y,
    Width, Height, Angle, ScaleX, ScaleY: Real; MirrorX, MirrorY: Boolean;
    Color: TColor4; DrawFx: Integer); overload;
  procedure DrawRotateStretch(Image: TAsphyreImage; PatternIndex: Integer; X, Y,
    Width, Height, CenterX, CenterY, Angle: Real; Color: TColor4; DrawFx: Integer); overload;
  procedure DrawRotateStretch(Image: TAsphyreImage; PatternIndex: Integer; X, Y,
    Width, Height, CenterX, CenterY, Angle, ScaleX, ScaleY: Real; Color: TColor4; DrawFx: Integer); overload;
  procedure DrawRotateStretch(Image: TAsphyreImage; PatternIndex: Integer; X, Y,
    Width, Height, CenterX, CenterY, Angle, ScaleX, ScaleY: Real; MirrorX, MirrorY: Boolean;
    Color: TColor4; DrawFx: Integer); overload;
  procedure DrawRotateRect(Image: TAsphyreImage; PatternIndex: Integer; X, Y, Angle,
    ScaleX, ScaleY: Real; SrcX1, SrcY1, SrcX2, SrcY2: Integer; MirrorX, MirrorY: Boolean;
    Color: TColor4; DrawFx: Integer); overload;
  procedure DrawRotateRect(Image: TAsphyreImage; PatternIndex: Integer; X, Y, Angle,
    CenterX, CenterY, ScaleX, ScaleY: Real; SrcX1, SrcY1, SrcX2, SrcY2: Integer;
    MirrorX, MirrorY: Boolean; Color: TColor4; DrawFx: Integer); overload;
  procedure DrawRotateRect(Image: TAsphyreImage; PatternIndex: Integer; X, Y, Width, Height, Angle,
    CenterX, CenterY, ScaleX, ScaleY: Real; SrcX1, SrcY1, SrcX2, SrcY2: Integer;
    MirrorX, MirrorY: Boolean; Color: TColor4; DrawFx: Integer); overload;

end;

  ///<version>310</version>
  TSpriteBase = class
  private
    FCanvas: TAsphyreCanvasEx;
  public
  procedure ExtendEffectHandler(Sender: TObject; Dev9: IDirect3DDevice9;
    var Code: Integer; var Handled: Boolean);
  property Canvas: TAsphyreCanvasEx read FCanvas write FCanvas;
  constructor Create();
  end;

implementation

//procedure TAsphyreCanvasEx.SetGamma(Red, Green, Blue, Brightness, Contrast: Byte);
//var
//  FGammaRamp: TD3DGammaRamp;
//  k: Single;
//  k2, i: Integer;
//begin
//  for i := 0 to 255 do
//  begin
//    FGammaRamp.Red[i] := i * (Red + 1);
//    FGammaRamp.Green[i] := i * (Green + 1);
//    FGammaRamp.Blue[i] := i * (Blue + 1);
//  end;
//
//  with FGammaRamp do
//  begin
//    k := (Contrast / 128) - 1;
//    if (k < 1) then
//      for i := 0 to 255 do
//      begin
//        if (Red[i] > 32767.5) then
//          Red[i] := Min(Round(Red[i] + (Red[i] - 32767.5) * k), 65535)
//        else Red[i] := Max(Round(Red[i] - (32767.5 - Red[i]) * k), 0);
//        if (Green[i] > 32767.5) then
//          Green[i] := Min(Round(Green[i] + (Green[i] - 32767.5) * k), 65535)
//        else Green[i] := Max(Round(Green[i] - (32767.5 - Green[i]) * k), 0);
//        if (Blue[i] > 32767.5) then
//          Blue[i] := Min(Round(Blue[i] + (Blue[i] - 32767.5) * k), 65535)
//        else Blue[i] := Max(Round(Blue[i] - (32767.5 - Blue[i]) * k), 0);
//      end else
//      for i := 0 to 255 do
//      begin
//        if (Red[i] > 32767.5) then
//          Red[i] := Max(Round(Red[i] - (Red[i] - 32767.5) * k), 32768)
//        else Red[i] := Min(Round(Red[i] + (32767.5 - Red[i]) * k), 32768);
//        if (Green[i] > 32767.5) then
//          Green[i] := Max(Round(Green[i] - (Green[i] - 32767.5) * k), 32768)
//        else Green[i] := Min(Round(Green[i] + (32767.5 - Green[i]) * k), 32768);
//        if (Blue[i] > 32767.5) then
//          Blue[i] := Max(Round(Blue[i] - (Blue[i] - 32767.5) * k), 32768)
//        else Blue[i] := Min(Round(Blue[i] + (32767.5 - Blue[i]) * k), 32768);
//      end;
//
//    k2 := Round(((Brightness / 128) - 1) * 65535);
//    if (k2 < 0) then
//      for i := 0 to 255 do
//      begin
//        Red[i] := Max(Red[i] + k2, 0);
//        Green[i] := Max(Green[i] + k2, 0);
//        Blue[i] := Max(Blue[i] + k2, 0);
//      end
//    else
//      for i := 0 to 255 do
//      begin
//        Red[i] := Min(Red[i] + k2, 65535);
//        Green[i] := Min(Green[i] + k2, 65535);
//        Blue[i] := Min(Blue[i] + k2, 65535);
//      end;
//  end;
//
//  Direct3DDevice.SetGammaRamp(0, D3DSGR_CALIBRATE, FGammaRamp);
//end;

procedure TAsphyreCanvasEx.DrawEx(Image: TAsphyreImage; PatternIndex: Integer; X, Y, ScaleX, ScaleY: Real;
  DoCenter, MirrorX, MirrorY: Boolean; Color: TColor4; DrawFx: Integer);
begin
  UseImage(Image,PatternIndex,0,0,Image.PatternSize.X, Image.PatternSize.Y,MirrorX,MirrorY);
  case DoCenter of
    True:
      begin
        TexMap(pBounds4sc2(X, Y, Image.PatternSize.X, Image.PatternSize.Y, ScaleX, ScaleY),
          Color, DrawFx);
      end;
    False:
      begin
        TexMap(pBounds4s2(X, Y, Image.PatternSize.X, Image.PatternSize.Y, ScaleX, ScaleY),
          Color, DrawFx);
      end;
  end;
end;

procedure TAsphyreCanvasEx.DrawEx(Image: TAsphyreImage; PatternIndex: Integer; X, Y, Scale: Real;
  DoCenter: Boolean; Color: TColor4; DrawFx: Integer);
begin
   UseImage(Image,PatternIndex);
  case DoCenter of
    True:
      begin
        TexMap( pBounds4sc(X, Y, Image.PatternSize.X, Image.PatternSize.Y, Scale),
          Color, DrawFx);
      end;
    False:
      begin
        TexMap( pBounds4s(X, Y, Image.PatternSize.X, Image.PatternSize.Y, Scale),
          Color,  DrawFx);
      end;
  end;
end;

procedure TAsphyreCanvasEx.DrawEx(Image: TAsphyreImage; PatternIndex: Integer; X, Y: Real;
  Color: TColor4; DrawFx: Integer);
begin
  UseImage(Image,PatternIndex);
  TexMap( pBounds4(X, Y, Image.PatternSize.X, Image.PatternSize.Y),
    Color,  DrawFx);
end;

procedure TAsphyreCanvasEx.DrawColor1(Image: TAsphyreImage; PatternIndex: Integer; X, Y, ScaleX, ScaleY: Real;
  DoCenter, MirrorX, MirrorY: Boolean; Red, Green, Blue, Alpha: Byte; DrawFx: Integer);
begin
  DrawEx(Image, PatternIndex, X, Y, ScaleX, ScaleY,
    DoCenter, MirrorX, MirrorY, cRGB4(Red, Green, Blue, Alpha), DrawFx);
end;

procedure TAsphyreCanvasEx.DrawColor1(Image: TAsphyreImage; PatternIndex: Integer; X, Y, Scale: Real;
  DoCenter: Boolean; Red, Green, Blue, Alpha: Byte; DrawFx: Integer);
begin
  DrawEx(Image, PatternIndex, X, Y, Scale, DoCenter, cRGB4(Red, Green, Blue, Alpha), DrawFx);
end;

procedure TAsphyreCanvasEx.DrawColor1(Image: TAsphyreImage; PatternIndex: Integer; X, Y: Real;
  Red, Green, Blue, Alpha: Byte; DrawFx: Integer);
begin
   UseImage(Image,PatternIndex);
  TexMap( pBounds4(X, Y, Image.PatternSize.X, Image.PatternSize.Y),
    cRGB4(Red, Green, Blue, Alpha),  DrawFx);
end;

procedure TAsphyreCanvasEx.DrawAlpha1(Image: TAsphyreImage; PatternIndex: Integer; X, Y, ScaleX, ScaleY: Real;
  DoCenter, MirrorX, MirrorY: Boolean; Alpha: Byte; DrawFx: Integer);
begin
  DrawEx(Image, PatternIndex, X, Y, ScaleX, ScaleY,
    DoCenter, MirrorX, MirrorY, cAlpha4(Alpha), DrawFx);
end;

procedure TAsphyreCanvasEx.DrawAlpha1(Image: TAsphyreImage; PatternIndex: Integer; X, Y, Scale: Real;
  DoCenter: Boolean; Alpha: Byte; DrawFx: Integer);
begin
  DrawEx(Image, PatternIndex, X, Y, Scale, DoCenter, cAlpha4(Alpha), DrawFx);
end;

procedure TAsphyreCanvasEx.DrawAlpha1(Image: TAsphyreImage; PatternIndex: Integer; X, Y: Real;
  Alpha: Byte; DrawFx: Integer);
begin
   UseImage(Image,PatternIndex);
  TexMap( pBounds4(X, Y, Image.PatternSize.X, Image.PatternSize.Y),
    cAlpha4(Alpha), DrawFx);
end;

procedure TAsphyreCanvasEx.DrawColor4(Image: TAsphyreImage; PatternIndex: Integer; X, Y, ScaleX, ScaleY: Real;
  DoCenter, MirrorX, MirrorY: Boolean; Color1, Color2, Color3, Color4: Cardinal; DrawFx: Integer);
begin
  DrawEx(Image, PatternIndex, X, Y, ScaleX, ScaleY, DoCenter,
    MirrorX, MirrorY, cColor4(Color1, Color2, Color3, Color4), DrawFx);
end;

procedure TAsphyreCanvasEx.DrawColor4(Image: TAsphyreImage; PatternIndex: Integer; X, Y, Scale: Real;
  DoCenter: Boolean; Color1, Color2, Color3, Color4: Cardinal; DrawFx: Integer);
begin
  DrawEx(Image, PatternIndex, X, Y, Scale, DoCenter,
    cColor4(Color1, Color2, Color3, Color4), DrawFx);
end;

procedure TAsphyreCanvasEx.DrawColor4(Image: TAsphyreImage; PatternIndex: Integer; X, Y: Real;
  Color1, Color2, Color3, Color4: Byte; DrawFx: Integer);
begin
   UseImage(Image,PatternIndex);
  TexMap( pBounds4(X, Y, Image.PatternSize.X, Image.PatternSize.Y),
    cColor4(Color1, Color2, Color3, Color4),DrawFx);
end;

procedure TAsphyreCanvasEx.DrawAlpha4(Image: TAsphyreImage; PatternIndex: Integer; X, Y, ScaleX, ScaleY: Real;
  DoCenter, MirrorX, MirrorY: Boolean; Alpha1, Alpha2, Alpha3, Alpha4: Byte; DrawFx: Integer);
begin
  DrawEx(Image, PatternIndex, X, Y, ScaleX, ScaleY, DoCenter,
    MirrorX, MirrorY, cAlpha4(Alpha1, Alpha2, Alpha3, Alpha4), DrawFx);
end;

procedure TAsphyreCanvasEx.DrawAlpha4(Image: TAsphyreImage; PatternIndex: Integer; X, Y, Scale: Real;
  DoCenter: Boolean; Alpha1, Alpha2, Alpha3, Alpha4: Byte; DrawFx: Integer);
begin
  DrawEx(Image, PatternIndex, X, Y, Scale, DoCenter,
    cAlpha4(Alpha1, Alpha2, Alpha3, Alpha4), DrawFx);
end;

procedure TAsphyreCanvasEx.DrawAlpha4(Image: TAsphyreImage; PatternIndex: Integer; X, Y: Real;
  Alpha1, Alpha2, Alpha3, Alpha4: Byte; DrawFx: Integer);
begin
   UseImage(Image,PatternIndex);
  TexMap( pBounds4(X, Y, Image.PatternSize.X, Image.PatternSize.Y),
    cAlpha4(Alpha1, Alpha2, Alpha3, Alpha4), DrawFx);
end;

procedure TAsphyreCanvasEx.DrawStretch(Image: TAsphyreImage; PatternIndex: Integer; X1, Y1, X2, Y2: Integer;
  MirrorX, MirrorY: Boolean; Color: TColor4; DrawFx: Integer);
begin
  UseImage(Image,PatternIndex,0,0,Image.PatternSize.X, Image.PatternSize.Y,MirrorX,MirrorY);
  TexMap( pRect4(Rect(X1, Y1, X2, Y2)), Color,  DrawFx);
end;

procedure TAsphyreCanvasEx.DrawStretch(Image: TAsphyreImage; PatternIndex: Integer; X, Y, Width, Height,
  ScaleX, ScaleY: Real; DoCenter, MirrorX, MirrorY: Boolean; Color: TColor4; DrawFx: Integer);
begin
  UseImage(Image,PatternIndex,0,0,Image.PatternSize.X, Image.PatternSize.Y,MirrorX,MirrorY);
  case DoCenter of
    True: TexMap( pBounds4sc2(X, Y, Width, Height, ScaleX, ScaleY), Color,  DrawFx);
    False: TexMap( pBounds4s2(X, Y, Width, Height, ScaleX, ScaleY), Color,  DrawFx);
  end;
end;

procedure TAsphyreCanvasEx.DrawPortion(Image: TAsphyreImage; PatternIndex: Integer; X, Y: Real;
  SrcX1, SrcY1, SrcX2, SrcY2: Integer; ScaleX, ScaleY: Real;
  DoCenter, MirrorX, MirrorY: Boolean; Color: TColor4; DrawFx: Integer);
begin
  UseImage(Image,PatternIndex,SrcX1,SrcY1,SrcX2-SrcX1, SrcY2-SrcY1,MirrorX,MirrorY);
  case DoCenter of
    True: TexMap( pBounds4sc2(X, Y, SrcX2-SrcX1, SrcY2-SrcY1, ScaleX, ScaleY),
        Color,  DrawFx);

    False: TexMap( pBounds4s2(X, Y, SrcX2-SrcX1, SrcY2-SrcY1, ScaleX, ScaleY),
        Color,  DrawFx);
  end;
end;

procedure TAsphyreCanvasEx.DrawPortion(Image: TAsphyreImage; PatternIndex: Integer; X, Y: Real;
  SrcX1, SrcY1, SrcX2, SrcY2: Integer; Color: TColor4; DrawFx: Integer);
begin
  UseImage(Image,PatternIndex,SrcX1,SrcY1,SrcX2-SrcX1, SrcY2-SrcY1, false, false);
  TexMap(pBounds4(X, Y, SrcX2-SrcX1, SrcY2-SrcY1), Color,  DrawFx);

end;

procedure TAsphyreCanvasEx.DrawRectStretch(Image: TAsphyreImage; PatternIndex: Integer; X1, Y1, X2, Y2: Real;
  SrcX1, SrcY1, SrcX2, SrcY2: Integer; MirrorX, MirrorY: Boolean; Color: TColor4; DrawFx: Integer);
begin
  UseImage(Image,PatternIndex,SrcX1,SrcY1,SrcX2-SrcX1, SrcY2-SrcY1, false, false);
  TexMap(pBounds4(X1, Y1, X2, Y2), Color,  DrawFx);
end;

procedure TAsphyreCanvasEx.DrawTransForm(Image: TAsphyreImage; PatternIndex: Integer; X1, Y1, X2, Y2,
  X3, Y3, X4, Y4: Real; MirrorX, MirrorY: Boolean; Color: TColor4; DrawFx: Integer);
begin
  UseImage(Image,PatternIndex,0,0,Image.PatternSize.X, Image.PatternSize.Y,MirrorX,MirrorY);
  TexMap( Point4(X1, Y1, X2, Y2, X3, Y3, X4, Y4), Color,  DrawFx);
end;

procedure TAsphyreCanvasEx.DrawRectTransForm(Image: TAsphyreImage; PatternIndex: Integer; X1, Y1, X2, Y2,
  X3, Y3, X4, Y4: Real; SrcX1, SrcY1, SrcX2, SrcY2: Integer;
  MirrorX, MirrorY: Boolean; Color: TColor4; DrawFx: Integer);
begin
  UseImage(Image,PatternIndex,SrcX1,SrcY1,SrcX2-SrcX1, SrcY2-SrcY1, MirrorX, MirrorY);
  TexMap( Point4(X1, Y1, X2, Y2, X3, Y3, X4, Y4), Color,  DrawFx);
end;

procedure TAsphyreCanvasEx.DrawRotateC(Image: TAsphyreImage; PatternIndex: Integer; X, Y, Angle: Real;
  Color: TColor4; DrawFx: Integer);
begin
   UseImage(Image,PatternIndex);
  TexMap( pRotate4c(Point2(X, Y), Point2(Image.PatternSize.X, Image.PatternSize.Y), Angle),
    Color, DrawFx);
end;

procedure TAsphyreCanvasEx.DrawRotateC(Image: TAsphyreImage; PatternIndex: Integer; X, Y, Angle,
  ScaleX, ScaleY: Real; Color: TColor4; DrawFx: Integer);
begin
   UseImage(Image,PatternIndex);
  TexMap( pRotate4c2(Point2(X, Y), Point2(Image.PatternSize.X, Image.PatternSize.Y), Angle, ScaleX, ScaleY),
    Color,  DrawFx);
end;

procedure TAsphyreCanvasEx.DrawRotateC(Image: TAsphyreImage; PatternIndex: Integer; X, Y, Angle,
  ScaleX, ScaleY: Real; MirrorX, MirrorY: Boolean; Color: TColor4; DrawFx: Integer);
begin
  UseImage(Image,PatternIndex,0,0,Image.PatternSize.X, Image.PatternSize.Y,MirrorX,MirrorY);

  TexMap( pRotate4c2(Point2(X, Y), Point2(Image.PatternSize.X, Image.PatternSize.Y), Angle, ScaleX, ScaleY),
    Color,  DrawFx);
end;

procedure TAsphyreCanvasEx.DrawRotate(Image: TAsphyreImage; PatternIndex: Integer; X, Y, CenterX, CenterY,
  Angle: Real; Color: TColor4; DrawFx: Integer);
begin
  UseImage(Image,PatternIndex);
  TexMap( pRotate4(Point2(X, Y), Point2(Image.PatternSize.X, Image.PatternSize.Y),
    Point2(CenterX, CenterY), Angle), Color,  DrawFx);
end;

procedure TAsphyreCanvasEx.DrawRotate(Image: TAsphyreImage; PatternIndex: Integer; X, Y, CenterX, CenterY,
  Angle, ScaleX, ScaleY: Real; Color: TColor4; DrawFx: Integer);
begin
  UseImage(Image,PatternIndex);
  TexMap( pRotate42(Point2(X, Y), Point2(Image.PatternSize.X, Image.PatternSize.Y),
    Point2(CenterX, CenterY), Angle, ScaleX, ScaleY), Color, DrawFx);
end;

procedure TAsphyreCanvasEx.DrawRotate(Image: TAsphyreImage; PatternIndex: Integer; X, Y, CenterX, CenterY,
  Angle, ScaleX, ScaleY: Real; MirrorX, MirrorY: Boolean; Color: TColor4; DrawFx: Integer);
begin
  UseImage(Image,PatternIndex,0,0,Image.PatternSize.X, Image.PatternSize.Y,MirrorX,MirrorY);
  TexMap( pRotate42(Point2(X, Y), Point2(Image.PatternSize.X, Image.PatternSize.Y), Point2(CenterX, CenterY),
    Angle, ScaleX, ScaleY), Color,  DrawFx);
end;

procedure TAsphyreCanvasEx.DrawRotateStretchC(Image: TAsphyreImage; PatternIndex: Integer; X, Y,
  Width, Height, Angle: Real; Color: TColor4; DrawFx: Integer);
begin
  UseImage(Image,PatternIndex);
  TexMap( pRotate4c(Point2(X, Y), Point2(Width, Height), Angle),
    Color, DrawFx);
end;

procedure TAsphyreCanvasEx.DrawRotateStretchC(Image: TAsphyreImage; PatternIndex: Integer; X, Y,
  Width, Height, Angle, ScaleX, ScaleY: Real; Color: TColor4; DrawFx: Integer);
begin
  UseImage(Image,PatternIndex);
  TexMap( pRotate4c2(Point2(X, Y), Point2(Width, Height), Angle, ScaleX, ScaleY),
    Color, DrawFx);
end;

procedure TAsphyreCanvasEx.DrawRotateStretchC(Image: TAsphyreImage; PatternIndex: Integer; X, Y,
  Width, Height, Angle, ScaleX, ScaleY: Real; MirrorX, MirrorY: Boolean;
  Color: TColor4; DrawFx: Integer);
begin
  UseImage(Image,PatternIndex,0,0,Image.PatternSize.X, Image.PatternSize.Y,MirrorX,MirrorY);
  TexMap( pRotate4c2(Point2(X, Y), Point2(Width, Height), Angle, ScaleX, ScaleY),
    Color,  DrawFx);
end;

procedure TAsphyreCanvasEx.DrawRotateStretch(Image: TAsphyreImage; PatternIndex: Integer; X, Y,
  Width, Height, CenterX, CenterY, Angle: Real; Color: TColor4; DrawFx: Integer);
begin
  UseImage(Image,PatternIndex);
  TexMap( pRotate4(Point2(X, Y), Point2(Width, Height), Point2(CenterX, CenterY), Angle),
    Color,  DrawFx);
end;

procedure TAsphyreCanvasEx.DrawRotateStretch(Image: TAsphyreImage; PatternIndex: Integer; X, Y,
  Width, Height, CenterX, CenterY, Angle, ScaleX, ScaleY: Real; Color: TColor4; DrawFx: Integer);
begin
  UseImage(Image,PatternIndex);
  TexMap( pRotate42(Point2(X, Y), Point2(Width, Height), Point2(CenterX, CenterY), Angle,
    ScaleX, ScaleY), Color, DrawFx);
end;

procedure TAsphyreCanvasEx.DrawRotateStretch(Image: TAsphyreImage; PatternIndex: Integer; X, Y,
  Width, Height, CenterX, CenterY, Angle, ScaleX, ScaleY: Real; MirrorX, MirrorY: Boolean;
  Color: TColor4; DrawFx: Integer);
begin
  UseImage(Image,PatternIndex);
  TexMap( pRotate42(Point2(X, Y), Point2(Width, Height), Point2(CenterX, CenterY), Angle,
    ScaleX, ScaleY), Color,  DrawFx);
end;

procedure TAsphyreCanvasEx.DrawRotateRect(Image: TAsphyreImage; PatternIndex: Integer; X, Y, Angle,
  ScaleX, ScaleY: Real; SrcX1, SrcY1, SrcX2, SrcY2: Integer; MirrorX, MirrorY: Boolean;
  Color: TColor4; DrawFx: Integer);
begin
  UseImage(Image,PatternIndex,SrcX1,SrcY1,SrcX2-SrcX1, SrcY2-SrcY1, MirrorX, MirrorY);
  TexMap( pRotate4c2(Point2(X, Y), Point2(SrcX2-SrcX1, SrcY2-SrcY1), Angle,
    ScaleX, ScaleY), Color,  DrawFx);
end;

procedure TAsphyreCanvasEx.DrawRotateRect(Image: TAsphyreImage; PatternIndex: Integer; X, Y, Angle,
  CenterX, CenterY, ScaleX, ScaleY: Real; SrcX1, SrcY1, SrcX2, SrcY2: Integer;
  MirrorX, MirrorY: Boolean; Color: TColor4; DrawFx: Integer);
begin
  UseImage(Image,PatternIndex,SrcX1,SrcY1,SrcX2-SrcX1, SrcY2-SrcY1, MirrorX, MirrorY);
  TexMap(pRotate42(Point2(X, Y), Point2(SrcX2-SrcX1, SrcY2-SrcY1),
    Point2(CenterX, CenterY), Angle, ScaleX, ScaleY), Color,  DrawFx);

end;

procedure TAsphyreCanvasEx.DrawRotateRect(Image: TAsphyreImage; PatternIndex: Integer; X, Y, Width, Height, Angle,
  CenterX, CenterY, ScaleX, ScaleY: Real; SrcX1, SrcY1, SrcX2, SrcY2: Integer;
  MirrorX, MirrorY: Boolean; Color: TColor4; DrawFx: Integer);
begin
  UseImage(Image,PatternIndex,SrcX1,SrcY1,SrcX2-SrcX1, SrcY2-SrcY1, MirrorX, MirrorY);
  TexMap( pRotate42(Point2(X, Y), Point2(Width, Height),
    Point2(CenterX, CenterY), Angle, ScaleX, ScaleY), Color,  DrawFx);
end;


//---------------------------------------------------------------------------
{ algorithm by Paul Bourke }
function PtInPolygon(Pt : TPoint2 ; Pg : TPolygon):Boolean;
var
  N, Counter , I : Integer;
  XInters : Real;
  P1, P2 : TPoint2;
begin
  N := High(Pg);
  Counter := 0;
  P1 := Pg[0];
  for I := 1 to N do
  begin
    P2 := Pg[I mod N];
    if Pt.y > Min(P1.y, P2.y) then
      if Pt.y <= Max(P1.y, P2.y) then
        if Pt.x <= Max(P1.x, P2.x) then
          if P1.y <> P2.y then
          begin
            XInters := (Pt.y - P1.y) * (P2.x - P1.x) / (P2.y - P1.y) + P1.x;
            if (P1.x = P2.x) or (Pt.x <= XInters) then Inc(Counter);
          end;
    P1 := P2;
  end;
  Result := (Counter mod 2 <> 0);
end;

//---------------------------------------------------------------------------
// last points of polygons must be the first one ( P1[0] = P1[N]  ; P2[0] = P2[N] )
function OverlapPolygon(P1, P2: TPolygon): Boolean;
var
  Poly1, Poly2 : TPolygon;
  Collide : Boolean;
  I : Integer;
begin
  Collide := False;
  { make loop on polygon with fewer points }
  if High(P1) < High(P2) then
  begin
    Poly1 := P1;
    Poly2 := P2;
  end
  else
  begin
    Poly1 := P2;
    Poly2 := P1;
  end;
  for I := 0 to High(Poly1)  do
    Collide := Collide or PtInPolygon(Poly1[I], Poly2);
  Result := Collide;

end;

var
  CosTable512: array[0..511] of Double;
  CosTable256: array[0..255] of Double;
  CosTable128: array[0..127] of Double;
  CosTable64 : array[0..63]  of Double;
  CosTable32 : array[0..31]  of Double;
  CosTable16 : array[0..15]  of Double;
  CosTable8  : array[0..7]   of Double;

function Cos8(i: Integer): Double;
begin
  Result := CosTable8[i and 7];
end;

function Cos16(i: Integer): Double;
begin
  Result := CosTable16[i and 15];
end;

function Cos32(i: Integer): Double;
begin
  Result := CosTable32[i and 31];
end;

function Cos64(i: Integer): Double;
begin
  Result := CosTable64[i and 63];
end;

function Cos128(i: Integer): Double;
begin
  Result := CosTable128[i and 127];
end;

function Cos256(i: Integer): Double;
begin
  Result := CosTable256[i and 255];
end;

function Cos512(i: Integer): Double;
begin
  Result := CosTable512[i and 511];
end;

function pBounds4s2(_Left, _Top, _Width, _Height, ScaleX, ScaleY: Real): TPoint4;
begin
 Result:= pBounds4(_Left, _Top, Round(_Width * ScaleX), Round(_Height * ScaleY));
end;

function pBounds4sc2(_Left, _Top, _Width, _Height, ScaleX, ScaleY: Real): TPoint4;
var
 Left, Top: Real;
 Width, Height: Real;
begin
 if (ScaleX = 1.0) and (ScaleY=1.0) then
  Result:= pBounds4(_Left, _Top, _Width, _Height)
 else
  begin
   Width := _Width * ScaleX;
   Height:= _Height * ScaleY;
   Left  := _Left + Round((_Width - Width) * 0.5);
   Top   := _Top + Round((_Height - Height) * 0.5);
   Result:= pBounds4(Left, Top, Round(Width), Round(Height));
  end;
end;


//---------------------------------------------------------------------------
function pRotate4(const Origin, Size, Middle: TPoint2; Angle: Real;
 Scale: Real): TPoint4;
var
 CosPhi: Real;
 SinPhi: Real;
 Index : Integer;
 Points: TPoint4;
 Point : TPoint2;
begin
 CosPhi:= Cos(Angle);
 SinPhi:= Sin(Angle);

 // create 4 points centered at (0, 0)
 Points:= pBounds4(-Middle.x, -Middle.y, Size.x, Size.y);

 // process the created points
 for Index:= 0 to 3 do
  begin
   // scale the point
   Points[Index].x:= Points[Index].x * Scale;
   Points[Index].y:= Points[Index].y * Scale;

   // rotate the point around Phi
   Point.x:= (Points[Index].x * CosPhi) - (Points[Index].y * SinPhi);
   Point.y:= (Points[Index].y * CosPhi) + (Points[Index].x * SinPhi);

   // translate the point to (Origin)
   Points[Index].x:= Point.x + Origin.x;
   Points[Index].y:= Point.y + Origin.y;
  end;

 Result:= Points; 
end;
function pRotate42(const Origin, Size, Middle: TPoint2; Angle: Real;
 ScaleX, ScaleY: Real ): TPoint4;
var
 CosPhi: Real;
 SinPhi: Real;
 Index : Integer;
 Points: TPoint4;
 Point : TPoint2;
begin
 CosPhi:= Cos(Angle);
 SinPhi:= Sin(Angle);

 // create 4 points centered at (0, 0)
 Points:= pBounds4(-Middle.X, -Middle.Y, Size.X, Size.Y);

 // process the created points
 for Index:= 0 to 3 do
  begin
   // scale the point
   Points[Index].x:= Points[Index].x * ScaleX;
   Points[Index].y:= Points[Index].y * ScaleY;

   // rotate the point around Phi
   Point.x:= (Points[Index].x * CosPhi) - (Points[Index].y * SinPhi);
   Point.y:= (Points[Index].y * CosPhi) + (Points[Index].x * SinPhi);

   // translate the point to (Origin)
   Points[Index].x:= Point.x + Origin.x;
   Points[Index].y:= Point.y + Origin.y;
  end;

 Result:= Points;
end;

//---------------------------------------------------------------------------
function pRotate4c(const Origin, Size: TPoint2; Angle: Real;
 Scale: Real): TPoint4;
begin
 Result:= pRotate4(Origin, Size, Point2(Size.x * 0.5, Size.y * 0.5), Angle,
  Scale);
end;


function pRotate4c2(const Origin, Size: TPoint2; Angle,
 ScaleX, ScaleY: Real): TPoint4;
begin
 Result:= pRotate42(Origin, Size, Point2(Size.x * 0.5, Size.y * 0.5), Angle, ScaleX, ScaleY);
end;

function pRotateTransForm(const X, Y, X1, Y1, X2, Y2, X3, Y3, X4, Y4 ,
 CenterX, CenterY, Angle: Real; Scale: Real = 1.0): TPoint4;
var
 CosPhi: Real;
 SinPhi: Real;
 Index : Integer;
 Points: TPoint4;
 Point : TPoint2;
begin
 CosPhi:= Cos(Angle);
 SinPhi:= Sin(Angle);

 // create 4 points centered at (0, 0)
 Points:= Point4(X1-CenterX, Y1-CenterY, X2-CenterX, Y2-CenterY,
                  X3-CenterX, Y3-CenterY, X4-CenterX, Y4-CenterY);

 // process the created points
 for Index:= 0 to 3 do
  begin
   // scale the point
   Points[Index].X:= Points[Index].X * Scale;
   Points[Index].Y:= Points[Index].Y * Scale;

   // rotate the point around Phi
   Point.x:= (Points[Index].X * CosPhi) - (Points[Index].Y * SinPhi);
   Point.y:= (Points[Index].Y * CosPhi) + (Points[Index].X * SinPhi);

   // translate the point to (Origin)
   Points[Index].X:= Point.X + X ;
   Points[Index].Y:= Point.Y + Y ;
  end;

 Result:= Points;
end;

function pRotateTransForm2(const X, Y, X1, Y1, X2, Y2, X3, Y3, X4, Y4 ,
 CenterX, CenterY, Angle, ScaleX, ScaleY: Real): TPoint4;
var
 CosPhi: Real;
 SinPhi: Real;
 Index : Integer;
 Points: TPoint4;
 Point : TPoint2;
begin
 CosPhi:= Cos(Angle);
 SinPhi:= Sin(Angle);

 // create 4 points centered at (0, 0)
 Points:= Point4(X1-CenterX, Y1-CenterY, X2-CenterX, Y2-CenterY,
                  X3-CenterX, Y3-CenterY, X4-CenterX, Y4-CenterY);

 // process the created points
 for Index:= 0 to 3 do
  begin
   // scale the point
   Points[Index].X:= Points[Index].X * ScaleX;
   Points[Index].Y:= Points[Index].Y * ScaleY;

   // rotate the point around Phi
   Point.x:= (Points[Index].X * CosPhi) - (Points[Index].Y * SinPhi);
   Point.y:= (Points[Index].Y * CosPhi) + (Points[Index].X * SinPhi);

   // translate the point to (Origin)
   Points[Index].X:= Point.X + X ;
   Points[Index].Y:= Point.Y + Y ;
  end;

 Result:= Points;
end;

function Sin8(i: Integer): Double;
begin
  Result := CosTable8[(i+6) and 7];
end;

function Sin16(i: Integer): Double;
begin
  Result := CosTable16[(i+12) and 15];
end;

function Sin32(i: Integer): Double;
begin
  Result := CosTable32[(i+24) and 31];
end;

function Sin64(i: Integer): Double;
begin
  Result := CosTable64[(i+48) and 63];
end;

function Sin128(i: Integer): Double;
begin
  Result := CosTable128[(i+96) and 127];
end;

function Sin256(i: Integer): Double;
begin
  Result := CosTable256[(i+192) and 255];
end;

function Sin512(i: Integer): Double;
begin
  Result := CosTable512[(i+384) and 511];
end;

procedure InitCosTable;
var
  i: Integer;
begin
   for i:=0 to 7 do
    CosTable8[i] := Cos((i/8)*2*PI);

   for i:=0 to 15 do
    CosTable16[i] := Cos((i/16)*2*PI);

   for i:=0 to 31 do
    CosTable32[i] := Cos((i/32)*2*PI);

   for i:=0 to 63 do
    CosTable64[i] := Cos((i/64)*2*PI);

   for i:=0 to 127 do
    CosTable128[i] := Cos((i/128)*2*PI);

   for i:=0 to 255 do
    CosTable256[i] := Cos((i/256)*2*PI);

   for i:=0 to 511 do
    CosTable512[i] := Cos((i/512)*2*PI);
end;

//---------------------------------------------------------------------------
function RectInRect(const Rect1, Rect2: TRect): Boolean;
begin
 Result:= (Rect1.Left >= Rect2.Left)and(Rect1.Right <= Rect2.Right)and
  (Rect1.Top >= Rect2.Top)and(Rect1.Bottom <= Rect2.Bottom);
end;

//---------------------------------------------------------------------------
function PointInRect(const Point: TPoint; const Rect: TRect): Boolean;
begin
 Result:= (Point.X >= Rect.Left)and(Point.X <= Rect.Right)and
  (Point.Y >= Rect.Top)and(Point.Y <= Rect.Bottom);
end;

//---------------------------------------------------------------------------
function OverlapRect(const Rect1, Rect2: TRect): Boolean;
begin
 Result:= (Rect1.Left < Rect2.Right)and(Rect1.Right > Rect2.Left)and
  (Rect1.Top < Rect2.Bottom)and(Rect1.Bottom > Rect2.Top);
end;

function OverlapQuadrangle(Q1, Q2: TPoint4): Boolean;
var
 d1, d2, d3, d4: Single;
begin

 d1 := (Q1[2].X - Q1[1].X) * (Q2[0].X - Q1[0].X) + (Q1[2].Y - Q1[1].Y) * (Q2[0].Y - Q1[0].Y);
 d2 := (Q1[3].X - Q1[2].X) * (Q2[0].X - Q1[1].X) + (Q1[3].Y - Q1[2].Y) * (Q2[0].Y - Q1[1].Y);
 d3 := (Q1[0].X - Q1[3].X) * (Q2[0].X - Q1[2].X) + (Q1[0].Y - Q1[3].Y) * (Q2[0].Y - Q1[2].Y);
 d4 := (Q1[1].X - Q1[0].X) * (Q2[0].X - Q1[3].X) + (Q1[1].Y - Q1[0].Y) * (Q2[0].Y - Q1[3].Y);
 if (d1 >= 0) and (d2 >= 0) and (d3 >= 0) and (d4 >= 0) then
 begin
  Result := True;
  Exit;
 end;

 d1 := (Q1[2].X - Q1[1].X) * (Q2[1].X - Q1[0].X) + (Q1[2].Y - Q1[1].Y) * (Q2[1].Y - Q1[0].Y);
 d2 := (Q1[3].X - Q1[2].X) * (Q2[1].X - Q1[1].X) + (Q1[3].Y - Q1[2].Y) * (Q2[1].Y - Q1[1].Y);
 d3 := (Q1[0].X - Q1[3].X) * (Q2[1].X - Q1[2].X) + (Q1[0].Y - Q1[3].Y) * (Q2[1].Y - Q1[2].Y);
 d4 := (Q1[1].X - Q1[0].X) * (Q2[1].X - Q1[3].X) + (Q1[1].Y - Q1[0].Y) * (Q2[1].Y - Q1[3].Y);
 if (d1 >= 0) and (d2 >= 0) and (d3 >= 0) and (d4 >= 0) then
 begin
  Result := True;
  Exit;
 end;

 d1 := (Q1[2].X - Q1[1].X) * (Q2[2].X - Q1[0].X) + (Q1[2].Y - Q1[1].Y) * (Q2[2].Y - Q1[0].Y);
 d2 := (Q1[3].X - Q1[2].X) * (Q2[2].X - Q1[1].X) + (Q1[3].Y - Q1[2].Y) * (Q2[2].Y - Q1[1].Y);
 d3 := (Q1[0].X - Q1[3].X) * (Q2[2].X - Q1[2].X) + (Q1[0].Y - Q1[3].Y) * (Q2[2].Y - Q1[2].Y);
 d4 := (Q1[1].X - Q1[0].X) * (Q2[2].X - Q1[3].X) + (Q1[1].Y - Q1[0].Y) * (Q2[2].Y - Q1[3].Y);
 if (d1 >= 0) and (d2 >= 0) and (d3 >= 0) and (d4 >= 0) then
 begin
  Result := True;
  Exit;
 end;

 d1 := (Q1[2].X - Q1[1].X) * (Q2[3].X - Q1[0].X) + (Q1[2].Y - Q1[1].Y) * (Q2[3].Y - Q1[0].Y);
 d2 := (Q1[3].X - Q1[2].X) * (Q2[3].X - Q1[1].X) + (Q1[3].Y - Q1[2].Y) * (Q2[3].Y - Q1[1].Y);
 d3 := (Q1[0].X - Q1[3].X) * (Q2[3].X - Q1[2].X) + (Q1[0].Y - Q1[3].Y) * (Q2[3].Y - Q1[2].Y);
 d4 := (Q1[1].X - Q1[0].X) * (Q2[3].X - Q1[3].X) + (Q1[1].Y - Q1[0].Y) * (Q2[3].Y - Q1[3].Y);
 if (d1 >= 0) and (d2 >= 0) and (d3 >= 0) and (d4 >= 0) then
 begin
  Result := True;
  Exit;
 end;

 Result := False;
end;

{ TSpriteBase }

constructor TSpriteBase.Create;
begin
   EffectManager.Include(ExtendEffectHandler);
end;

procedure TSpriteBase.ExtendEffectHandler(Sender: TObject; Dev9: IDirect3DDevice9;
  var Code: Integer; var Handled: Boolean);
begin
 case Code of
  fxuSrcColorAdd:
   begin
    Dev9.SetRenderState(D3DRS_SRCBLEND,  D3DBLEND_SRCCOLOR);
    Dev9.SetRenderState(D3DRS_DESTBLEND, D3DBLEND_ONE);
    Dev9.SetRenderState(D3DRS_BLENDOP,   D3DBLENDOP_ADD);

    Handled:= True;
   end;

  fxuInvert:
   begin
    Dev9.SetRenderState(D3DRS_SRCBLEND,  D3DBLEND_INVDESTCOLOR);
    Dev9.SetRenderState(D3DRS_DESTBLEND, D3DBLEND_ZERO);
    Dev9.SetRenderState(D3DRS_BLENDOP,   D3DBLENDOP_ADD);

    Handled:= True;
   end;

  fxuSrcBright:
   begin
    Dev9.SetRenderState(D3DRS_SRCBLEND,  D3DBLEND_SRCCOLOR);
    Dev9.SetRenderState(D3DRS_DESTBLEND, D3DBLEND_SRCCOLOR);
    Dev9.SetRenderState(D3DRS_BLENDOP,   D3DBLENDOP_ADD);

    Handled:= True;
   end;

  fxuDestBright:
   begin
    Dev9.SetRenderState(D3DRS_SRCBLEND,  D3DBLEND_DESTCOLOR);
    Dev9.SetRenderState(D3DRS_DESTBLEND, D3DBLEND_DESTCOLOR);
    Dev9.SetRenderState(D3DRS_BLENDOP,   D3DBLENDOP_ADD);

    Handled:= True;
   end;

  fxuInvSrcBright:
   begin
    Dev9.SetRenderState(D3DRS_SRCBLEND,  D3DBLEND_INVSRCCOLOR);
    Dev9.SetRenderState(D3DRS_DESTBLEND, D3DBLEND_INVSRCCOLOR);
    Dev9.SetRenderState(D3DRS_BLENDOP,   D3DBLENDOP_ADD);

    Handled:= True;
   end;

  fxuInvDestBright:
   begin
    Dev9.SetRenderState(D3DRS_SRCBLEND,  D3DBLEND_INVDESTCOLOR);
    Dev9.SetRenderState(D3DRS_DESTBLEND, D3DBLEND_INVDESTCOLOR);
    Dev9.SetRenderState(D3DRS_BLENDOP,   D3DBLENDOP_ADD);

    Handled:= True;
   end;

  fxuMultiplyAlpha:
   begin
    Dev9.SetRenderState(D3DRS_SRCBLEND,  D3DBLEND_ZERO);
    Dev9.SetRenderState(D3DRS_DESTBLEND, D3DBLEND_SRCALPHA);
    Dev9.SetRenderState(D3DRS_BLENDOP,   D3DBLENDOP_ADD);

    Handled:= True;
   end;

  fxuAdd2X:
   begin
    Dev9.SetRenderState(D3DRS_SRCBLEND,  D3DBLEND_SRCALPHA);
    Dev9.SetRenderState(D3DRS_DESTBLEND, D3DBLEND_ONE);
    Dev9.SetRenderState(D3DRS_BLENDOP,   D3DBLENDOP_ADD);
    Dev9.SetTextureStageState(0, D3DTSS_COLOROP, D3DTOP_MODULATE2X);
    Dev9.SetTextureStageState(0, D3DTSS_ALPHAOP, D3DTOP_MODULATE);

    Handled:= True;
   end;

  fxuLight:
   begin
    Dev9.SetRenderState(D3DRS_SRCBLEND,  D3DBLEND_DESTCOLOR);
    Dev9.SetRenderState(D3DRS_DESTBLEND, D3DBLEND_ONE);
    Dev9.SetRenderState(D3DRS_BLENDOP,   D3DBLENDOP_ADD);
    Dev9.SetTextureStageState(0, D3DTSS_COLOROP, D3DTOP_MODULATE2X);
    Dev9.SetTextureStageState(0, D3DTSS_ALPHAOP, D3DTOP_MODULATE);

    Handled:= True;
   end;

  fxuLightAdd:
   begin
    Dev9.SetRenderState(D3DRS_SRCBLEND,  D3DBLEND_DESTCOLOR);
    Dev9.SetRenderState(D3DRS_DESTBLEND, D3DBLEND_ONE);
    Dev9.SetRenderState(D3DRS_BLENDOP,   D3DBLENDOP_ADD);
    Dev9.SetTextureStageState(0, D3DTSS_COLOROP, D3DTOP_MODULATE4X);
    Dev9.SetTextureStageState(0, D3DTSS_ALPHAOP, D3DTOP_MODULATE);

    Handled:= True;
   end;

  fxuBright:
   begin
    Dev9.SetRenderState(D3DRS_SRCBLEND,  D3DBLEND_SRCALPHA);
    Dev9.SetRenderState(D3DRS_DESTBLEND, D3DBLEND_INVSRCALPHA);
    Dev9.SetRenderState(D3DRS_BLENDOP,   D3DBLENDOP_ADD);
    Dev9.SetTextureStageState(0, D3DTSS_COLOROP, D3DTOP_MODULATE2X);
    Dev9.SetTextureStageState(0, D3DTSS_ALPHAOP, D3DTOP_MODULATE);

    Handled:= True;
   end;

  fxuBrightAdd:
   begin
    Dev9.SetRenderState(D3DRS_SRCBLEND,  D3DBLEND_SRCALPHA);
    Dev9.SetRenderState(D3DRS_DESTBLEND, D3DBLEND_INVSRCALPHA);
    Dev9.SetRenderState(D3DRS_BLENDOP,   D3DBLENDOP_ADD);
    Dev9.SetTextureStageState(0, D3DTSS_COLOROP, D3DTOP_MODULATE4X);
    Dev9.SetTextureStageState(0, D3DTSS_ALPHAOP, D3DTOP_MODULATE);

    Handled:= True;
   end;

  fxuGrayScale:
   begin
    Dev9.SetRenderState(D3DRS_TextureFactor,Integer((cRGB1(155, 255, 155, 155))));
    Dev9.SetTextureStageState(0, D3DTSS_COLOROP, D3DTOP_DOTPRODUCT3);
    Dev9.SetTextureStageState(0, D3DTSS_COLORARG2, D3DTA_TFACTOR);

    Handled:= True;
   end;

  fxuOneColor:
   begin
    Dev9.SetRenderState(D3DRS_SRCBLEND,  D3DBLEND_SRCALPHA);
    Dev9.SetRenderState(D3DRS_DESTBLEND, D3DBLEND_INVSRCALPHA);
    Dev9.SetTextureStageState(0, D3DTSS_COLOROP, 25);
    Dev9.SetTextureStageState(0, D3DTSS_ALPHAOP, D3DTOP_MODULATE);

    Handled:= True;
   end;
 end;

end;

initialization
  InitCosTable;
  
end.
