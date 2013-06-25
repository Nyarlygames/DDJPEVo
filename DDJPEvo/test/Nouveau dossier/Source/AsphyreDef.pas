unit AsphyreDef;

//---------------------------------------------------------------------------
interface

//---------------------------------------------------------------------------
uses
 Windows, Types, Direct3D9, Vectors2;

//---------------------------------------------------------------------------
type
 TDeviceNotifyEvent = procedure(Sender: TObject;
  Dev9: IDirect3DDevice9) of object;

//---------------------------------------------------------------------------
 PPoint4px = ^TPoint4px;
 TPoint4px = array[0..3] of TPoint;

//---------------------------------------------------------------------------
 PPoint4 = ^TPoint4;
 TPoint4 = array[0..3] of TPoint2;

//---------------------------------------------------------------------------
 PColor4 = ^TColor4;
 TColor4 = array[0..3] of Cardinal;

//---------------------------------------------------------------------------
 TImageDescType = (idtImage, idtSurface, idtDraft);
 TFontDescType = (fdtSystem, fdtBitmap);

//---------------------------------------------------------------------------
const
 clWhite4  : TColor4 = ($FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF);
 clBlack4  : TColor4 = ($FF000000, $FF000000, $FF000000, $FF000000);
 clMaroon4 : TColor4 = ($FF800000, $FF800000, $FF800000, $FF800000);
 clGreen4  : TColor4 = ($FF008000, $FF008000, $FF008000, $FF008000);
 clOlive4  : TColor4 = ($FF808000, $FF808000, $FF808000, $FF808000);
 clNavy4   : TColor4 = ($FF000080, $FF000080, $FF000080, $FF000080);
 clPurple4 : TColor4 = ($FF800080, $FF800080, $FF800080, $FF800080);
 clTeal4   : TColor4 = ($FF008080, $FF008080, $FF008080, $FF008080);
 clGray4   : TColor4 = ($FF808080, $FF808080, $FF808080, $FF808080);
 clSilver4 : TColor4 = ($FFC0C0C0, $FFC0C0C0, $FFC0C0C0, $FFC0C0C0);
 clRed4    : TColor4 = ($FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000);
 clLime4   : TColor4 = ($FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00);
 clYellow4 : TColor4 = ($FFFFFF00, $FFFFFF00, $FFFFFF00, $FFFFFF00);
 clBlue4   : TColor4 = ($FF0000FF, $FF0000FF, $FF0000FF, $FF0000FF);
 clFuchsia4: TColor4 = ($FFFF00FF, $FFFF00FF, $FFFF00FF, $FFFF00FF);
 clAqua4   : TColor4 = ($FF00FFFF, $FF00FFFF, $FF00FFFF, $FF00FFFF);
 clLtGray4 : TColor4 = ($FFC0C0C0, $FFC0C0C0, $FFC0C0C0, $FFC0C0C0);
 clDkGray4 : TColor4 = ($FF808080, $FF808080, $FF808080, $FF808080);
 clOpaque4 : TColor4 = ($00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF);

//---------------------------------------------------------------------------
 TexFull4: TPoint4 = ((x: 0.0; y: 0.0), (x: 1.0; y: 0.0), (x: 1.0; y: 1.0),
  (x: 0.0; y: 1.0));

//---------------------------------------------------------------------------
// Point4 helper routines
//---------------------------------------------------------------------------
// point values -> TPoint4
function Point4(x1, y1, x2, y2, x3, y3, x4, y4: Real): TPoint4; overload;
function Point4(const p1, p2, p3, p4: TPoint2): TPoint4; overload;
// rectangle coordinates -> TPoint4
function pRect4(const Rect: TRect): TPoint4;
// rectangle coordinates -> TPoint4
function pBounds4(_Left, _Top, _Width, _Height: Real): TPoint4;
// rectangle coordinates, scaled -> TPoint4
function pBounds4s(_Left, _Top, _Width, _Height, Theta: Real): TPoint4;
// rectangle coordinates, scaled / centered -> TPoint4
function pBounds4sc(_Left, _Top, _Width, _Height, Theta: Real): TPoint4;
// mirrors the coordinates
function pMirror4(const Point4: TPoint4): TPoint4;
// flips the coordinates
function pFlip4(const Point4: TPoint4): TPoint4;
// shift the given points by the specified amount
function pShift4(const Points: TPoint4; const ShiftBy: TPoint2): TPoint4;
// rotated rectangle (Origin + Size) around (Middle) with Angle and Scale
function pRotate4(const Origin, Size, Middle: TPoint2; Angle: Real;
 Theta: Real): TPoint4;
function pRotate4c(const Origin, Size: TPoint2; Angle: Real;
 Theta: Real): TPoint4;

//---------------------------------------------------------------------------
// Color helper routines
//---------------------------------------------------------------------------
function cRGB4(r, g, b: Cardinal; a: Cardinal = 255): TColor4; overload;
function cRGB4(r1, g1, b1, a1, r2, g2, b2, a2: Cardinal): TColor4; overload;
function cColor4(Color: Cardinal): TColor4; overload;
function cColor4(Color1, Color2, Color3, Color4: Cardinal): TColor4; overload;
function cGray4(Gray: Cardinal): TColor4; overload;
function cGray4(Gray1, Gray2, Gray3, Gray4: Cardinal): TColor4; overload;
function cAlpha4(Alpha: Cardinal): TColor4; overload;
function cAlpha4(Alpha1, Alpha2, Alpha3, Alpha4: Cardinal): TColor4; overload;
function cColorAlpha4(Color, Alpha: Cardinal): TColor4; overload;
function cColorAlpha4(Color1, Color2, Color3, Color4, Alpha1, Alpha2, Alpha3,
 Alpha4: Cardinal): TColor4; overload;

function cRGB1(r, g, b: Cardinal; a: Cardinal = 255): Cardinal;
function cGray1(Gray: Cardinal): Cardinal;
function cAlpha1(Alpha: Cardinal): Cardinal;

//---------------------------------------------------------------------------
function ColorAvg(c1, c2: Cardinal): Cardinal;
function CubicTheta(x0, x1, x2, x3, Theta: Real): Real;
function BlendPixels(Px0, Px1: Longword; Alpha: Integer): Longword; stdcall;
function ModulateAlpha(Color: Cardinal; Beta: Real): Cardinal;

//---------------------------------------------------------------------------
// Unicode <> Ansi string conversion using specified code page.
// This is a somewhat improved version of code originally written and posted
// on Torry by Primoz Gabrijelcic.
//---------------------------------------------------------------------------
function WideStringToString(const Text: WideString;
 CodePage: Integer): AnsiString;
function StringToWideString(const Text: AnsiString;
 CodePage: Integer): WideString;

//---------------------------------------------------------------------------
// returns True if the given point is within the specified rectangle
//---------------------------------------------------------------------------
function PointInRect(const Point: TPoint; const Rect: TRect): Boolean;

//---------------------------------------------------------------------------
// returns True if the given rectangle is within the specified rectangle
//---------------------------------------------------------------------------
function RectInRect(const Rect1, Rect2: TRect): Boolean;

//---------------------------------------------------------------------------
// returns True if the specified rectangles overlap
//---------------------------------------------------------------------------
function OverlapRect(const Rect1, Rect2: TRect): Boolean;

//---------------------------------------------------------------------------
implementation

//---------------------------------------------------------------------------
function Point4(x1, y1, x2, y2, x3, y3, x4, y4: Real): TPoint4;
begin
 Result[0].x:= x1;
 Result[0].y:= y1;
 Result[1].x:= x2;
 Result[1].y:= y2;
 Result[2].x:= x3;
 Result[2].y:= y3;
 Result[3].x:= x4;
 Result[3].y:= y4;
end;

//---------------------------------------------------------------------------
function Point4(const p1, p2, p3, p4: TPoint2): TPoint4;
begin
 Result:= Point4(p1.x, p1.y, p2.x, p2.y, p3.x, p3.y, p4.x, p4.y);
end;

//---------------------------------------------------------------------------
function pRect4(const Rect: TRect): TPoint4;
begin
 Result[0].x:= Rect.Left;
 Result[0].y:= Rect.Top;
 Result[1].x:= Rect.Right;
 Result[1].y:= Rect.Top;
 Result[2].x:= Rect.Right;
 Result[2].y:= Rect.Bottom;
 Result[3].x:= Rect.Left;
 Result[3].y:= Rect.Bottom;
end;

//---------------------------------------------------------------------------
function pBounds4(_Left, _Top, _Width, _Height: Real): TPoint4;
begin
 Result[0].X:= _Left;
 Result[0].Y:= _Top;
 Result[1].X:= _Left + _Width;
 Result[1].Y:= _Top;
 Result[2].X:= _Left + _Width;
 Result[2].Y:= _Top + _Height;
 Result[3].X:= _Left;
 Result[3].Y:= _Top + _Height;
end;

//---------------------------------------------------------------------------
function pBounds4s(_Left, _Top, _Width, _Height, Theta: Real): TPoint4;
begin
 Result:= pBounds4(_Left, _Top, Round(_Width * Theta), Round(_Height * Theta));
end;

//---------------------------------------------------------------------------
function pBounds4sc(_Left, _Top, _Width, _Height, Theta: Real): TPoint4;
var
 Left, Top: Real;
 Width, Height: Real;
begin
 if (Theta = 1.0) then
  Result:= pBounds4(_Left, _Top, _Width, _Height)
 else
  begin
   Width := _Width * Theta;
   Height:= _Height * Theta;
   Left  := _Left + ((_Width - Width) * 0.5);
   Top   := _Top + ((_Height - Height) * 0.5);
   Result:= pBounds4(Left, Top, Round(Width), Round(Height));
  end;
end;

//---------------------------------------------------------------------------
function pMirror4(const Point4: TPoint4): TPoint4;
begin
 Result[0].X:= Point4[1].X;
 Result[0].Y:= Point4[0].Y;
 Result[1].X:= Point4[0].X;
 Result[1].Y:= Point4[1].Y;
 Result[2].X:= Point4[3].X;
 Result[2].Y:= Point4[2].Y;
 Result[3].X:= Point4[2].X;
 Result[3].Y:= Point4[3].Y;
end;

//---------------------------------------------------------------------------
function pFlip4(const Point4: TPoint4): TPoint4;
begin
 Result[0].X:= Point4[0].X;
 Result[0].Y:= Point4[2].Y;
 Result[1].X:= Point4[1].X;
 Result[1].Y:= Point4[3].Y;
 Result[2].X:= Point4[2].X;
 Result[2].Y:= Point4[0].Y;
 Result[3].X:= Point4[3].X;
 Result[3].Y:= Point4[1].Y;
end;

//---------------------------------------------------------------------------
function pShift4(const Points: TPoint4; const ShiftBy: TPoint2): TPoint4;
begin
 Result[0].x:= Points[0].x + ShiftBy.x;
 Result[0].y:= Points[0].y + ShiftBy.y;
 Result[1].x:= Points[1].x + ShiftBy.x;
 Result[1].y:= Points[1].y + ShiftBy.y;
 Result[2].x:= Points[2].x + ShiftBy.x;
 Result[2].y:= Points[2].y + ShiftBy.y;
 Result[3].x:= Points[3].x + ShiftBy.x;
 Result[3].y:= Points[3].y + ShiftBy.y;
end;

//---------------------------------------------------------------------------
function pRotate4(const Origin, Size, Middle: TPoint2; Angle: Real;
 Theta: Real): TPoint4;
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
   Points[Index].x:= Points[Index].x * Theta;
   Points[Index].y:= Points[Index].y * Theta;

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
 Theta: Real): TPoint4;
begin
 Result:= pRotate4(Origin, Size, Point2(Size.x * 0.5, Size.y * 0.5), Angle,
  Theta);
end;

//---------------------------------------------------------------------------
function cRGB1(r, g, b: Cardinal; a: Cardinal = 255): Cardinal;
begin
 Result:= r or (g shl 8) or (b shl 16) or (a shl 24);
end;

//---------------------------------------------------------------------------
function cRGB4(r, g, b: Cardinal; a: Cardinal = 255): TColor4;
begin
 Result:= cColor4(cRGB1(r, g, b, a));
end;

//---------------------------------------------------------------------------
function cRGB4(r1, g1, b1, a1, r2, g2, b2, a2: Cardinal): TColor4;
begin
 Result[0]:= cRGB1(r1, g1, b1, a1);
 Result[1]:= Result[0];
 Result[2]:= cRGB1(r2, g2, b2, a2);
 Result[3]:= Result[2];
end;

//---------------------------------------------------------------------------
function cColor4(Color: Cardinal): TColor4;
begin
 Result[0]:= Color;
 Result[1]:= Color;
 Result[2]:= Color;
 Result[3]:= Color;
end;

//---------------------------------------------------------------------------
function cColor4(Color1, Color2, Color3, Color4: Cardinal): TColor4;
begin
 Result[0]:= Color1;
 Result[1]:= Color2;
 Result[2]:= Color3;
 Result[3]:= Color4;
end;

//---------------------------------------------------------------------------
function cGray4(Gray: Cardinal): TColor4;
begin
 Result:= cColor4(((Gray and $FF) or ((Gray and $FF) shl 8) or
  ((Gray and $FF) shl 16)) or $FF000000);
end;

//---------------------------------------------------------------------------
function cGray4(Gray1, Gray2, Gray3, Gray4: Cardinal): TColor4;
begin
 Result[0]:= ((Gray1 and $FF) or ((Gray1 and $FF) shl 8) or ((Gray1 and $FF) shl 16)) or $FF000000;
 Result[1]:= ((Gray2 and $FF) or ((Gray2 and $FF) shl 8) or ((Gray2 and $FF) shl 16)) or $FF000000;
 Result[2]:= ((Gray3 and $FF) or ((Gray3 and $FF) shl 8) or ((Gray3 and $FF) shl 16)) or $FF000000;
 Result[3]:= ((Gray4 and $FF) or ((Gray4 and $FF) shl 8) or ((Gray4 and $FF) shl 16)) or $FF000000;
end;

//---------------------------------------------------------------------------
function cAlpha4(Alpha: Cardinal): TColor4;
begin
 Result:= cColor4($FFFFFF or ((Alpha and $FF) shl 24));
end;

//---------------------------------------------------------------------------
function cAlpha4(Alpha1, Alpha2, Alpha3, Alpha4: Cardinal): TColor4;
begin
 Result[0]:= $FFFFFF or ((Alpha1 and $FF) shl 24);
 Result[1]:= $FFFFFF or ((Alpha2 and $FF) shl 24);
 Result[2]:= $FFFFFF or ((Alpha3 and $FF) shl 24);
 Result[3]:= $FFFFFF or ((Alpha4 and $FF) shl 24);
end;

//---------------------------------------------------------------------------
function cColorAlpha4(Color, Alpha: Cardinal): TColor4; overload;
begin
 Result:= cColor4((Color and $FFFFFF) or ((Alpha and $FF) shl 24));
end;

//---------------------------------------------------------------------------
function cColorAlpha4(Color1, Color2, Color3, Color4, Alpha1, Alpha2, Alpha3,
 Alpha4: Cardinal): TColor4;
begin
 Result[0]:= (Color1 and $FFFFFF) or ((Alpha1 and $FF) shl 24);
 Result[1]:= (Color2 and $FFFFFF) or ((Alpha2 and $FF) shl 24);
 Result[2]:= (Color3 and $FFFFFF) or ((Alpha3 and $FF) shl 24);
 Result[3]:= (Color4 and $FFFFFF) or ((Alpha4 and $FF) shl 24);
end;

//---------------------------------------------------------------------------
function cColor1(Color: Cardinal): TColor4;
begin
 Result[0]:= Color;
 Result[1]:= Color;
 Result[2]:= Color;
 Result[3]:= Color;
end;

//---------------------------------------------------------------------------
function cGray1(Gray: Cardinal): Cardinal;
begin
 Result:= ((Gray and $FF) or ((Gray and $FF) shl 8) or ((Gray and $FF) shl 16))
  or $FF000000;
end;

//---------------------------------------------------------------------------
function cAlpha1(Alpha: Cardinal): Cardinal;
begin
 Result:= $FFFFFF or ((Alpha and $FF) shl 24);
end;

//---------------------------------------------------------------------------
function ColorAvg(c1, c2: Cardinal): Cardinal;
begin
 Result:= (((c1 and $FF) + (c2 and $FF)) div 2) +
  (((((c1 shr 8) and $FF) + ((c2 shr 8) and $FF)) div 2) shl 8) +
  (((((c1 shr 16) and $FF) + ((c2 shr 16) and $FF)) div 2) shl 16) +
  (((((c1 shr 24) and $FF) + ((c2 shr 24) and $FF)) div 2) shl 24);
end;

//---------------------------------------------------------------------------
function CubicTheta(x0, x1, x2, x3, Theta: Real): Real;
begin
 Result:= 0.5 * ((2.0 * x1) + Theta * (-x0 + x2 + Theta * (2.0 * x0 - 5.0 *
  x1 + 4.0 * x2 - x3 + Theta * (-x0 + 3.0 * x1 - 3.0 * x2 + x3))));
end;

//---------------------------------------------------------------------------
(*function BlendPixels(Px0, Px1: Longword; Alpha: Integer): Longword;
asm { params: eax, edx, ecx }
 pxor mm7, mm7

 movd mm0, edx
 movd mm1, eax

 punpcklbw mm0, mm7
 punpcklbw mm1, mm7

 mov eax, 0FFFFFFFFh
 movd mm6, eax
 punpcklbw mm6, mm7    // MM6 -> 255,255,255,255 (words)

 mov eax, 01010101h
 movd mm0, eax
 punpcklbw mm0, mm7    // MM0 -> 1, 1, 1, 1 (words)

 paddusw mm6, mm0      // MM6 -> 256,256,256,256 (words)

 mov eax, ecx
 and eax, 0FFh
 mov ecx, eax
 shl ecx, 8
 or  eax, ecx
 shl ecx, 8
 or  eax, ecx
 shl ecx, 8
 or eax, ecx

 movd mm2, eax
 punpcklbw mm2, mm7    // MM2 -> alpha,alpha,alpha

 pmullw mm0, mm2
 psrlw mm0, 8

 psubusw mm6, mm2

 pmullw mm1, mm6
 psrlw mm1, 8

 paddusw mm0, mm1
 packuswb  mm0, mm7

 movd eax, mm0

 emms
end;*)
//---------------------------------------------------------------------------
function BlendPixels(Px0, Px1: Longword; Alpha: Integer): Longword; stdcall;
asm
 pxor mm7, mm7

 mov eax, 0FFFFFFFFh
 movd mm6, eax
 punpcklbw mm6, mm7    // MM6 -> 255,255,255,255 (words)

 mov eax, 01010101h
 movd mm0, eax
 punpcklbw mm0, mm7    // MM0 -> 1, 1, 1, 1 (words)

 paddusw mm6, mm0      // MM6 -> 256,256,256,256 (words)

 mov eax, Alpha
 and eax, 0FFh
 mov ecx, eax
 shl ecx, 8
 or  eax, ecx
 shl ecx, 8
 or  eax, ecx
 shl ecx, 8
 or eax, ecx

 movd mm2, eax
 punpcklbw mm2, mm7    // MM2 -> alpha,alpha,alpha

 movd mm0, Px0
 movd mm1, Px1

 punpcklbw mm0, mm7
 punpcklbw mm1, mm7

 pmullw mm0, mm2
 psrlw mm0, 8

 psubusw mm6, mm2

 pmullw mm1, mm6
 psrlw mm1, 8

 paddusw mm0, mm1
 packuswb  mm0, mm7

 movd eax, mm0

 emms

 mov Result, eax
end;

//---------------------------------------------------------------------------
function ModulateAlpha(Color: Cardinal; Beta: Real): Cardinal;
begin
 Result:= (Color and $FFFFFF) or (Round((Color shr 24) * Beta) shl 24);
end;

//---------------------------------------------------------------------------
function WideStringToString(const Text: WideString;
 CodePage: Integer): AnsiString;
var
 StrLen: Integer;
begin
 if (Text = '') then
  begin
   Result:= '';
   Exit;
  end;

 StrLen:= WideCharToMultiByte(CodePage, WC_COMPOSITECHECK or WC_DISCARDNS or
  WC_SEPCHARS or WC_DEFAULTCHAR, @Text[1], Length(Text), nil, 0, nil, nil);

 SetLength(Result, StrLen - 1);

 if (StrLen > 0) then
  WideCharToMultiByte(CodePage, WC_COMPOSITECHECK or WC_DISCARDNS or
   WC_SEPCHARS or WC_DEFAULTCHAR, @Result[1], Length(Text), @Result[1],
   StrLen - 1, nil, nil);
end;

//---------------------------------------------------------------------------
function StringToWideString(const Text: AnsiString;
 CodePage: Integer): WideString;
var
 StrLen: integer;
begin
 if (Text = '') then
  begin
   Result:= '';
   Exit;
  end;

 StrLen:= MultiByteToWideChar(CodePage, MB_PRECOMPOSED, PChar(@Text[1]),
  Length(Text), nil, 0);

 SetLength(Result, StrLen - 1);

 if (StrLen > 1) then
  MultiByteToWideChar(CodePage, MB_PRECOMPOSED, PChar(@Text[1]), Length(Text),
  PWideChar(@Result[1]), StrLen - 1);
end;

//-----------------------------------------------------------------------------
function PointInRect(const Point: TPoint; const Rect: TRect): Boolean;
begin
 Result:= (Point.X >= Rect.Left)and(Point.X <= Rect.Right)and
  (Point.Y >= Rect.Top)and(Point.Y <= Rect.Bottom);
end;

//---------------------------------------------------------------------------
function RectInRect(const Rect1, Rect2: TRect): Boolean;
begin
 Result:= (Rect1.Left >= Rect2.Left)and(Rect1.Right <= Rect2.Right)and
  (Rect1.Top >= Rect2.Top)and(Rect1.Bottom <= Rect2.Bottom);
end;

//---------------------------------------------------------------------------
function OverlapRect(const Rect1, Rect2: TRect): Boolean;
begin
 Result:= (Rect1.Left < Rect2.Right)and(Rect1.Right > Rect2.Left)and
  (Rect1.Top < Rect2.Bottom)and(Rect1.Bottom > Rect2.Top);
end;

//---------------------------------------------------------------------------
end.
