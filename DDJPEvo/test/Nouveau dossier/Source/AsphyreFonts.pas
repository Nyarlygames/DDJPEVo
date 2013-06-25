unit AsphyreFonts;

//---------------------------------------------------------------------------
interface

//---------------------------------------------------------------------------
uses
 Windows, Types, SysUtils, D3DX9, AsphyreAsserts, MediaFonts, AsphyreDef,
 AsphyreEvents, AsphyreImages, MediaUtils
 {$IFDEF DebugMode}, AsphyreDebug{$ENDIF};

//---------------------------------------------------------------------------
type
 TAsphyreFonts = class;

//---------------------------------------------------------------------------
 TAsphyreCustomFont = class
 private
  FOwner: TAsphyreFonts;
  FFontIndex: Integer;

  FDropShadow  : Boolean;
  FShadowAlpha : Integer;
  FShadowDepthX: Integer;
  FShadowDepthY: Integer;

  // NoExclude indicates that the component should not exclude itself
  // from the owner.
  NoExclude: Boolean;
 protected
  FName: string;
  FInitialized: Boolean;
 public
  // The reference to the font holder.
  property Owner: TAsphyreFonts read FOwner;

  // The unique image identifier
  property Name: string read FName;

  // The index assigned by the owner.
  property FontIndex: Integer read FFontIndex;

  // Determines whether the font has been initialized successfully.
  property Initialized: Boolean read FInitialized;

  property DropShadow  : Boolean read FDropShadow write FDropShadow;
  property ShadowAlpha : Integer read FShadowAlpha write FShadowAlpha;
  property ShadowDepthX: Integer read FShadowDepthX write FShadowDepthX;
  property ShadowDepthY: Integer read FShadowDepthY write FSHadowDepthY;

  //-------------------------------------------------------------------------
  // Draws the text at the specified position, filled with linear gradient
  // from top to bottom and using the specified draw operation. The complete
  // functionality may not be fully supported and the method can use only one
  // color and simple blit operation instead.
  //
  // Normally, this method is supported for bitmap fonts and unsupported for
  // system fonts.
  //-------------------------------------------------------------------------
  procedure TextOutFx(const Text: string; x, y: Integer; TopColor,
   BottomColor: Cardinal; DrawFx: Integer); overload; virtual; abstract;
  procedure TextOutFx(const Text: string; x, y: Integer; TopColor,
   BottomColor: Cardinal); overload;

  //-------------------------------------------------------------------------
  // Draw the text at the specified position and color.
  //-------------------------------------------------------------------------
  procedure TextOut(const Text: string; x, y: Integer;
   Color: Cardinal); virtual; abstract;

  //-------------------------------------------------------------------------
  // Similar to TextOut function, but supports Unicode.
  // This is most likely supported by system fonts only.
  //-------------------------------------------------------------------------
  procedure TextOutW(const Text: WideString; x, y: Integer;
   Color: Cardinal); virtual; abstract;

  //-------------------------------------------------------------------------
  // Determines the rectangular dimensions of the rendered text in pixels.
  //-------------------------------------------------------------------------
  function TextExtent(const Text: string): TPoint; virtual; abstract;

  //-------------------------------------------------------------------------
  // Determines the rectangular dimensions of the rendered text in pixels.
  // Unicode version.
  //-------------------------------------------------------------------------
  function TextExtentW(const Text: WideString): TPoint; virtual; abstract;

  //-------------------------------------------------------------------------
  // Estimates the width/height of text in pixels.
  //-------------------------------------------------------------------------
  function TextWidth(const Text: string): Integer;
  function TextHeight(const Text: string): Integer;
  function TextWidthW(const Text: WideString): Integer;
  function TextHeightW(const Text: WideString): Integer;

  function Initialize(Desc: PFontDesc): Boolean; virtual; abstract;
  procedure Finalize(); virtual; abstract;

  constructor Create(AOwner: TAsphyreFonts); virtual;
  destructor Destroy(); override;
 end;

//---------------------------------------------------------------------------
 TAsphyreSystemFont = class(TAsphyreCustomFont)
 private
  FDriver: ID3DXFont;
 protected
  procedure NotifyDeviceLost(); virtual;
  procedure NotifyDeviceRecover(); virtual;
 public
  property Driver: ID3DXFont read FDriver;

  procedure TextOutFx(const Text: string; x, y: Integer; TopColor,
   BottomColor: Cardinal; DrawFx: Integer); override;

  procedure TextOut(const Text: string; x, y: Integer;
   Color: Cardinal); override;
  procedure TextOutW(const Text: WideString; x, y: Integer;
   Color: Cardinal); override;

  function TextExtent(const Text: string): TPoint; override;
  function TextExtentW(const Text: WideString): TPoint; override;

  function Initialize(Desc: PFontDesc): Boolean; override;
  procedure Finalize(); override;

  constructor Create(AOwner: TAsphyreFonts); override;
 end;

//---------------------------------------------------------------------------
 TAsphyreBitmapFont = class(TAsphyreCustomFont)
 private
  CharWidths  : array of Integer;
  FFirstLetter: Integer;
  FLetterCount: Integer;
  FInterleave : Integer;
  FImageIndex : Integer;
  FBlankSpace : Integer;
  FPatternSize: TPoint;

  FScale  : Integer;
  FKerning: Integer;

  procedure InitCharWidths();
  procedure OutBasicText(const Text: string; x, y: Integer; TopColor,
   BottomColor: Cardinal; DrawFx: Integer);
 public
  property FirstLetter: Integer read FFirstLetter;
  property LetterCount: Integer read FLetterCount;
  property Interleave : Integer read FInterleave;
  property BlankSpace : Integer read FBlankSpace;
  property ImageIndex : Integer read FImageIndex;
  property PatternSize: TPoint read FPatternSize;

  property Scale  : Integer read FScale write FScale;
  property Kerning: Integer read FKerning write FKerning;

  procedure TextOutFx(const Text: string; x, y: Integer; TopColor,
   BottomColor: Cardinal; DrawFx: Integer); override;

  procedure TextOut(const Text: string; x, y: Integer;
   Color: Cardinal); override;
  procedure TextOutW(const Text: WideString; x, y: Integer;
   Color: Cardinal); override;

  function TextExtent(const Text: string): TPoint; override;
  function TextExtentW(const Text: WideString): TPoint; override;

  function Initialize(Desc: PFontDesc): Boolean; override;
  procedure Finalize(); override;

  constructor Create(AOwner: TAsphyreFonts); override;
 end;

//---------------------------------------------------------------------------
 TAsphyreFonts = class
 private
  FOwnerDevice: TObject;
  Data: array of TAsphyreCustomFont;

  SearchObjects: array of Integer;
  SearchDirty  : Boolean;
  FMediaOption : string;

  FOnSymbolResolve: TMediaSymbolEvent;
  FOnSymbolLoad   : TMediaSymbolEvent;
  FOnResolveFailed: TMediaSymbolEvent;

  function GetCount(): Integer;
  function GetItem(Num: Integer): TAsphyreCustomFont;
  function CountSearchObjects(): Integer;
  procedure FillSearchObjects(Amount: Integer);
  procedure SortSearchObjects(Left, Right: Integer);
  procedure PrepareSearchObjects();
  function GetFont(const Name: string): TAsphyreCustomFont;

  procedure NotifyDeviceLost();
  procedure NotifyDeviceRecover();
  procedure EventCallback(Sender: TObject; EventNo, EventRef: Integer;
   var Success: Boolean);
 protected
  function FindEmptySlot(): Integer;
  function Insert(Element: TAsphyreCustomFont): Integer;
  function Include(Element: TAsphyreCustomFont): Integer;
  procedure Exclude(Element: TAsphyreCustomFont);
 public
  property OwnerDevice: TObject read FOwnerDevice;

  property MediaOption: string read FMediaOption write FMediaOption;

  property OnSymbolResolve: TMediaSymbolEvent read FOnSymbolResolve write FOnSymbolResolve;
  property OnSymbolLoad   : TMediaSymbolEvent read FOnSymbolLoad write FOnSymbolLoad;
  property OnResolveFailed: TMediaSymbolEvent read FOnResolveFailed write FOnResolveFailed;

  property Count: Integer read GetCount;
  property Items[Num: Integer]: TAsphyreCustomFont read GetItem; default;
  property Font[const Name: string]: TAsphyreCustomFont read GetFont;

  function IndexOf(Element: TAsphyreCustomFont): Integer; overload;
  function IndexOf(const uid: string): Integer; overload;
  procedure Remove(Num: Integer);
  procedure RemoveAll();

  function ResolveFont(uid: string): Integer;

  procedure UnloadGroup(const GroupName: string);
  
  constructor Create(AOwnerDevice: TObject);
  destructor Destroy(); override;
 end;

//---------------------------------------------------------------------------
implementation

//---------------------------------------------------------------------------
uses
 AsphyreDevices, AsphyreEffects, DrawingUtils;

//---------------------------------------------------------------------------
var
 PixelsPerInch: Integer = 1;

//---------------------------------------------------------------------------
constructor TAsphyreCustomFont.Create(AOwner: TAsphyreFonts);
begin
 inherited Create();

 FFontIndex:= -1;
 Assert(AOwner <> nil, msgInvalidOwner);

 FOwner:= AOwner;
 FInitialized:= False;
 NoExclude:= False;

 FShadowDepthX:= 1;
 FShadowDepthY:= 1;
 FShadowAlpha := 128;

 FOwner.Insert(Self);
end;

//---------------------------------------------------------------------------
destructor TAsphyreCustomFont.Destroy();
begin
 if (FInitialized) then Finalize();
 if (not NoExclude) then FOwner.Exclude(Self);

 inherited;
end;

//---------------------------------------------------------------------------
function TAsphyreCustomFont.TextWidth(const Text: string): Integer;
begin
 Result:= TextExtent(Text).X;
end;

//---------------------------------------------------------------------------
function TAsphyreCustomFont.TextHeight(const Text: string): Integer;
begin
 Result:= TextExtent(Text).Y;
end;

//---------------------------------------------------------------------------
function TAsphyreCustomFont.TextWidthW(const Text: WideString): Integer;
begin
 Result:= TextExtentW(Text).X;
end;

//---------------------------------------------------------------------------
function TAsphyreCustomFont.TextHeightW(const Text: WideString): Integer;
begin
 Result:= TextExtentW(Text).Y;
end;

//---------------------------------------------------------------------------
procedure TAsphyreCustomFont.TextOutFx(const Text: string; x, y: Integer;
 TopColor, BottomColor: Cardinal);
begin
 TextOutFx(Text, x, y, TopColor, BottomColor, fxuBlend or fxfDiffuse);
end;

//---------------------------------------------------------------------------
constructor TAsphyreSystemFont.Create(AOwner: TAsphyreFonts);
begin
 inherited;

 FDriver:= nil;
end;

//---------------------------------------------------------------------------
function TAsphyreSystemFont.Initialize(Desc: PFontDesc): Boolean;
var
 Size: Integer;
begin
 Assert(not FInitialized, msgAlreadyInitialized);

 Size:= -MulDiv(Desc.FontSize, PixelsPerInch, 72);

 Result:= Succeeded(D3DXCreateFont(TAsphyreDevice(FOwner.OwnerDevice).Dev9,
  Size, 0, Desc.Weight, 1, False, Desc.Charset,
  OUT_DEFAULT_PRECIS, Desc.Quality, DEFAULT_PITCH or FF_DONTCARE,
  PChar(Desc.FontName), FDriver));

 FInitialized:= Result;
end;

//---------------------------------------------------------------------------
procedure TAsphyreSystemFont.NotifyDeviceLost();
begin
 if (FDriver <> nil) then FDriver.OnLostDevice();
end;

//---------------------------------------------------------------------------
procedure TAsphyreSystemFont.NotifyDeviceRecover;
begin
 if (FDriver <> nil) then FDriver.OnResetDevice();
end;

//---------------------------------------------------------------------------
procedure TAsphyreSystemFont.TextOut(const Text: string; x, y: Integer;
 Color: Cardinal);
var
 DrawRect: TRect;
begin
 TAsphyreDevice(FOwner.OwnerDevice).Events.Notify(Self, aevDrawFlush, 0);

 if (DropShadow) then
  begin
   DrawRect:= Bounds(x + ShadowDepthX, y + ShadowDepthY, 1, 1);

   Driver.DrawTextA(nil, PChar(Text), Length(Text), @DrawRect, DT_LEFT or
    DT_TOP or DT_NOCLIP or DT_SINGLELINE, $000000 or
    (Cardinal(ShadowAlpha) shl 24));
  end;

 DrawRect:= Bounds(x, y, 1, 1);

 Driver.DrawTextA(nil, PChar(Text), Length(Text), @DrawRect, DT_LEFT or
  DT_TOP or DT_NOCLIP or DT_SINGLELINE, Color);
end;

//---------------------------------------------------------------------------
procedure TAsphyreSystemFont.TextOutW(const Text: WideString; x, y: Integer;
 Color: Cardinal);
var
 DrawRect: TRect;
begin
 TAsphyreDevice(FOwner.OwnerDevice).Events.Notify(Self, aevDrawFlush, 0);

 if (DropShadow) then
  begin
   DrawRect:= Bounds(x + ShadowDepthX, y + ShadowDepthY, 1, 1);

   Driver.DrawTextW(nil, PWideChar(Text), Length(Text), @DrawRect, DT_LEFT or
    DT_TOP or DT_NOCLIP or DT_SINGLELINE, $FFFFFF or
    (Cardinal(ShadowAlpha) shl 24));
  end;

 DrawRect:= Bounds(x, y, 1, 1);

 Driver.DrawTextW(nil, PWideChar(Text), Length(Text), @DrawRect, DT_LEFT or
  DT_TOP or DT_NOCLIP or DT_SINGLELINE, Color);
end;

//---------------------------------------------------------------------------
procedure TAsphyreSystemFont.TextOutFx(const Text: string; x, y: Integer;
 TopColor, BottomColor: Cardinal; DrawFx: Integer);
begin
 TextOut(Text, x, y, ColorAvg(TopColor, BottomColor));
end;

//---------------------------------------------------------------------------
function TAsphyreSystemFont.TextExtent(const Text: string): TPoint;
var
 DrawRect: TRect;
begin
 DrawRect:= Bounds(0, 0, 1, 1);

 Driver.DrawTextA(nil, PChar(Text), Length(Text), @DrawRect, DT_LEFT or
  DT_TOP or DT_NOCLIP or DT_SINGLELINE or DT_CALCRECT , 0);

 Result.X:= DrawRect.Right - DrawRect.Left;
 Result.Y:= DrawRect.Bottom - DrawRect.Top;
end;

//---------------------------------------------------------------------------
function TAsphyreSystemFont.TextExtentW(const Text: WideString): TPoint;
var
 DrawRect: TRect;
begin
 DrawRect:= Bounds(0, 0, 1, 1);

 Driver.DrawTextW(nil, PWideChar(Text), Length(Text), @DrawRect, DT_LEFT or
  DT_TOP or DT_NOCLIP or DT_SINGLELINE or DT_CALCRECT , 0);

 Result.X:= DrawRect.Right - DrawRect.Left;
 Result.Y:= DrawRect.Bottom - DrawRect.Top;
end;

//---------------------------------------------------------------------------
procedure TAsphyreSystemFont.Finalize();
begin
 if (FDriver <> nil) then FDriver:= nil;

 FInitialized:= False;
end;

//---------------------------------------------------------------------------
procedure RetreivePixelsPerInch();
var
 DC: HDC;
begin
 DC:= GetDC(0);
 PixelsPerInch:= GetDeviceCaps(DC, LOGPIXELSY);
 ReleaseDC(0, DC);
end;

//---------------------------------------------------------------------------
constructor TAsphyreBitmapFont.Create(AOwner: TAsphyreFonts);
begin
 inherited;

 FKerning:= 0;
 FScale  := 1024;
 FImageIndex:= -1;

 FDropShadow  := False;
 FShadowAlpha := 255;
 FShadowDepthX:= 2;
 FShadowDepthY:= 2;
end;

//---------------------------------------------------------------------------
procedure TAsphyreBitmapFont.InitCharWidths();
var
 i: Integer;
begin
 SetLength(CharWidths, FLetterCount);

 for i:= 0 to Length(CharWidths) - 1 do
  CharWidths[i]:= FBlankSpace;
end;

//---------------------------------------------------------------------------
function TAsphyreBitmapFont.Initialize(Desc: PFontDesc): Boolean;
var
 Images: TAsphyreImages;
 i: Integer;
begin
 Images:= TAsphyreDevice(FOwner.FOwnerDevice).Images;

 // try to resolve the image symbol
 FImageIndex:= Images.ResolveImage(Desc.Image);
 Result:= (FImageIndex <> -1)and(Images[FImageIndex] is TAsphyreImage);
 if (not Result) then Exit;

 // configure font parameters
 FFirstLetter:= Desc.FirstLetter;
 FLetterCount:= Desc.PatCount;
 FInterleave := Desc.Interleave;
 FBlankSpace := Round((Desc.PatSize.X - 2) * Desc.BlankSpace);
 FPatternSize:= Desc.PatSize;

 // override image pattern information
 TAsphyreImage(Images[FImageIndex]).PatternSize := Desc.PatSize;
 TAsphyreImage(Images[FImageIndex]).PatternCount:= Desc.PatCount;
 TAsphyreImage(Images[FImageIndex]).Padding     := Point(2, 2);

 // configure character widths
 InitCharWidths();

 for i:= 0 to Length(Desc.CharInfo) - 1 do
  CharWidths[Desc.CharInfo[i].AsciiCode - Desc.FirstLetter]:= Desc.CharInfo[i].Width;

 FInitialized:= True;
end;

//---------------------------------------------------------------------------
procedure TAsphyreBitmapFont.Finalize();
begin
 FImageIndex := -1;
 FInitialized:= False;
end;

//---------------------------------------------------------------------------
procedure TAsphyreBitmapFont.OutBasicText(const Text: string; x, y: Integer;
 TopColor, BottomColor: Cardinal; DrawFx: Integer);
var
 CharIndex, xPos, CharCode: Integer;
 CachedColors: TColor4;
begin
 Assert(FImageIndex <> -1);

 xPos:= x;
 CharIndex:= 1;
 CachedColors:= cColor4(TopColor, TopColor, BottomColor, BottomColor);

 while (CharIndex <= Length(Text)) do
  begin
   CharCode:= Byte(Text[CharIndex]) - FFirstLetter;
   if (CharCode < 0)or(CharCode > Length(CharWidths)) then
    begin
     Inc(xPos, FBlankSpace + FKerning);
     Continue;
    end;

   DrawScaled(TAsphyreDevice(FOwner.FOwnerDevice).Canvas,
    TAsphyreDevice(FOwner.FOwnerDevice).Images[FImageIndex], xPos, y, CharCode,
    CachedColors, FScale, DrawFx);

   Inc(xPos, CharWidths[CharCode] + FKerning);
   Inc(CharIndex);
  end;
end;

//---------------------------------------------------------------------------
procedure TAsphyreBitmapFont.TextOutFx(const Text: string; x, y: Integer;
 TopColor, BottomColor: Cardinal; DrawFx: Integer);
var
 ShadowCol: Cardinal;
begin
 if (DropShadow) then
  begin
   ShadowCol:= $FFFFFF or (Cardinal(ShadowAlpha) shl 24);
   OutBasicText(Text, x + ShadowDepthX, y + ShadowDepthY, ShadowCol,
    ShadowCol, fxuShadow or fxfDiffuse);
  end;

 OutBasicText(Text, x, y, TopColor, BottomColor, DrawFx);
end;

//---------------------------------------------------------------------------
procedure TAsphyreBitmapFont.TextOut(const Text: string; x, y: Integer;
 Color: Cardinal);
begin
 TextOutFx(Text, x, y, Color, Color, fxuBlend or fxfDiffuse);
end;

//---------------------------------------------------------------------------
function TAsphyreBitmapFont.TextExtent(const Text: string): TPoint;
var
 CharIndex, CharCode: Integer;
begin
 Result.Y:= FPatternSize.Y;
 Result.X:= 0;

 CharIndex:= 1;

 while (CharIndex <= Length(Text)) do
  begin
   CharCode:= Byte(Text[CharIndex]) - FFirstLetter;
   if (CharCode < 0)or(CharCode > Length(CharWidths)) then
    begin
     Inc(Result.X, FBlankSpace + FKerning);
     Continue;
    end;

   Inc(Result.X, CharWidths[CharCode] + FKerning);
   Inc(CharIndex);
  end;
end;

//---------------------------------------------------------------------------
procedure TAsphyreBitmapFont.TextOutW(const Text: WideString; x, y: Integer;
 Color: Cardinal);
begin
 TextOut(Text, x, y, Color);
end;

//---------------------------------------------------------------------------
function TAsphyreBitmapFont.TextExtentW(const Text: WideString): TPoint;
begin
 Result:= TextExtent(Text);
end;

//---------------------------------------------------------------------------
constructor TAsphyreFonts.Create(AOwnerDevice: TObject);
begin
 inherited Create();

 Assert((AOwnerDevice <> nil)and(AOwnerDevice is TAsphyreDevice),
  msgNoDeviceOwner);

 FOwnerDevice:= AOwnerDevice;
 TAsphyreDevice(FOwnerDevice).Events.Include(EventCallback);

 FMediaOption:= '';
 SearchDirty := False;
end;

//---------------------------------------------------------------------------
destructor TAsphyreFonts.Destroy();
begin
 RemoveAll();

 TAsphyreDevice(FOwnerDevice).Events.Exclude(EventCallback);

 inherited;
end;

//---------------------------------------------------------------------------
function TAsphyreFonts.GetCount(): Integer;
begin
 Result:= Length(Data);
end;

//---------------------------------------------------------------------------
function TAsphyreFonts.GetItem(Num: Integer): TAsphyreCustomFont;
begin
 Assert((Num >= 0)and(Num < Length(Data)), msgIndexOutOfBounds);
 Result:= Data[Num];
end;

//---------------------------------------------------------------------------
function TAsphyreFonts.IndexOf(Element: TAsphyreCustomFont): Integer;
var
 i: Integer;
begin
 Result:= -1;
 for i:= 0 to Length(Data) - 1 do
  if (Data[i] = Element) then
   begin
    Result:= i;
    Break;
   end;
end;

//---------------------------------------------------------------------------
function TAsphyreFonts.CountSearchObjects(): Integer;
var
 i: Integer;
begin
 Result:= 0;

 for i:= 0 to Length(Data) - 1 do
  if (Data[i] <> nil) then Inc(Result);
end;

//---------------------------------------------------------------------------
procedure TAsphyreFonts.FillSearchObjects(Amount: Integer);
var
 i, DestIndex: Integer;
begin
 SetLength(SearchObjects, Amount);

 DestIndex:= 0;
 for i:= 0 to Length(Data) - 1 do
  if (Data[i] <> nil) then
   begin
    SearchObjects[DestIndex]:= i;
    Inc(DestIndex);
   end;
end;

//---------------------------------------------------------------------------
procedure TAsphyreFonts.SortSearchObjects(Left, Right: Integer);
var
 Lo, Hi: Integer;
 TempIndex: Integer;
 MidValue: string;
begin
 Lo:= Left;
 Hi:= Right;
 MidValue:= Data[SearchObjects[(Left + Right) shr 1]].Name;

 repeat
  while (Data[SearchObjects[Lo]].Name < MidValue) do Inc(Lo);
  while (MidValue < Data[SearchObjects[Hi]].Name) do Dec(Hi);

  if (Lo <= Hi) then
   begin
    TempIndex:= SearchObjects[Lo];
    SearchObjects[Lo]:= SearchObjects[Hi];
    SearchObjects[Hi]:= TempIndex;

    Inc(Lo);
    Dec(Hi);
   end;
 until (Lo > Hi);

 if (Left < Hi) then SortSearchObjects(Left, Hi);
 if (Lo < Right) then SortSearchObjects(Lo, Right);
end;

//---------------------------------------------------------------------------
procedure TAsphyreFonts.PrepareSearchObjects();
var
 Amount: Integer;
begin
 Amount:= CountSearchObjects();

 FillSearchObjects(Amount);

 if (Amount > 0) then
  SortSearchObjects(0, Amount - 1);

 SearchDirty:= False;
end;

//---------------------------------------------------------------------------
function TAsphyreFonts.IndexOf(const uid: string): Integer;
var
 Lo, Hi, Mid: Integer;
begin
 if (SearchDirty) then PrepareSearchObjects();

 Result:= -1;

 Lo:= 0;
 Hi:= Length(SearchObjects) - 1;

 while (Lo <= Hi) do
  begin
   Mid:= (Lo + Hi) div 2;

   if (Data[SearchObjects[Mid]].Name = uid) then
    begin
     Result:= SearchObjects[Mid];
     Break;
    end;

   if (Data[SearchObjects[Mid]].Name > uid) then Hi:= Mid - 1
    else Lo:= Mid + 1;
 end;
end;

//---------------------------------------------------------------------------
function TAsphyreFonts.FindEmptySlot(): Integer;
var
 i: Integer;
begin
 Result:= -1;

 for i:= 0 to Length(Data) - 1 do
  if (Data[i] = nil) then
   begin
    Result:= i;
    Break;
   end;
end;

//---------------------------------------------------------------------------
function TAsphyreFonts.Insert(Element: TAsphyreCustomFont): Integer;
var
 Slot: Integer;
begin
 Slot:= FindEmptySlot();
 if (Slot = -1) then
  begin
   Slot:= Length(Data);
   SetLength(Data, Slot + 1);
  end;

 Data[Slot]:= Element;
 Element.FFontIndex:= Slot;

 SearchDirty:= True;
 Result:= Slot;
end;

//---------------------------------------------------------------------------
function TAsphyreFonts.Include(Element: TAsphyreCustomFont): Integer;
begin
 Result:= IndexOf(Element);
 if (Result = -1) then Result:= Insert(Element);
end;

//---------------------------------------------------------------------------
procedure TAsphyreFonts.Exclude(Element: TAsphyreCustomFont);
var
 Index: Integer;
begin
 Index:= IndexOf(Element);
 if (Index <> -1) then
  begin
   Data[Index]:= nil;
   SearchDirty:= True;
  end;
end;

//---------------------------------------------------------------------------
procedure TAsphyreFonts.Remove(Num: Integer);
begin
 Assert((Num >= 0)and(Num < Length(Data)), msgIndexOutOfBounds);

 Data[Num].NoExclude:= True;
 Data[Num].Free();
 Data[Num]:= nil;

 SearchDirty:= True;
end;

//---------------------------------------------------------------------------
procedure TAsphyreFonts.RemoveAll();
var
 i: Integer;
begin
 for i:= 0 to Length(Data) - 1 do
  if (Data[i] <> nil) then
   begin
    Data[i].NoExclude:= True;
    Data[i].Free();
    Data[i]:= nil;
   end;

 SetLength(Data, 0);
 SetLength(SearchObjects, 0);
 SearchDirty:= False;
end;

//---------------------------------------------------------------------------
function TAsphyreFonts.ResolveFont(uid: string): Integer;
var
 Index: Integer;
 FontDesc: PFontDesc;
 Instance: TAsphyreCustomFont;
begin
 // (1) Identifiers are not case-sensitive.
 uid:= LowerCase(uid);

 // (2) Check whether the font has been previously loaded
 Index:= IndexOf(uid);
 if (Index <> -1) then
  begin
   Result:= Index;
   Exit;
  end;

 // (3) Notify about symbol resolution.
 if (Assigned(FOnSymbolResolve)) then FOnSymbolResolve(Self, uid);

 // (4) Determine if description for the font exists.
 FontDesc:= FontGroups.Find(uid, MediaOption);
 if (FontDesc = nil) then
  begin
   {$IFDEF DebugMode}
   DebugLog('!! Unresolved font symbol: "' + uid + '".');
   {$ENDIF}

   if (Assigned(FOnResolveFailed)) then FOnResolveFailed(Self, uid);

   Result:= -1;
   Exit;
  end;

 // (5) Create the particular image type.
 Instance:= nil;
 case FontDesc.DescType of
  fdtSystem:
   Instance:= TAsphyreSystemFont.Create(Self);

  fdtBitmap:
   Instance:= TAsphyreBitmapFont.Create(Self);
 end;

 // (6) Notify about symbol load.
 if (Assigned(FOnSymbolLoad)) then FOnSymbolLoad(Self, uid);

 // (7) Load and initialize image specification.
 Instance.FName:= LowerCase(uid);

 if (not Instance.Initialize(FontDesc)) then
  begin
   {$IFDEF DebugMode}
   DebugLog('!! Resolution failed for font symbol "' + uid + '".');
   {$ENDIF}

   if (Assigned(FOnResolveFailed)) then FOnResolveFailed(Self, uid);

   Instance.Free();
   Result:= -1;
   Exit;
  end;

 // (8) Ok, we have a new font symbol in the list.
 Result:= Instance.FontIndex;
end;

//---------------------------------------------------------------------------
function TAsphyreFonts.GetFont(const Name: string): TAsphyreCustomFont;
var
 Index: Integer;
begin
 Index:= ResolveFont(Name);
 if (Index <> -1) then Result:= Data[Index] else Result:= nil;
end;

//---------------------------------------------------------------------------
procedure TAsphyreFonts.NotifyDeviceLost();
var
 i: Integer;
begin
 for i:= 0 to Length(Data) - 1 do
  if (Data[i] is TAsphyreSystemFont) then
   TAsphyreSystemFont(Data[i]).NotifyDeviceLost();
end;

//---------------------------------------------------------------------------
procedure TAsphyreFonts.NotifyDeviceRecover();
var
 i: Integer;
begin
 for i:= 0 to Length(Data) - 1 do
  if (Data[i] is TAsphyreSystemFont) then
   TAsphyreSystemFont(Data[i]).NotifyDeviceRecover();
end;

//---------------------------------------------------------------------------
procedure TAsphyreFonts.EventCallback(Sender: TObject; EventNo,
 EventRef: Integer; var Success: Boolean);
begin
 case EventNo of
  aevFinalize:
   RemoveAll();

  aevDeviceLost:
   NotifyDeviceLost();

  aevDeviceRecover:
   NotifyDeviceRecover();
 end;
end;

//---------------------------------------------------------------------------
procedure TAsphyreFonts.UnloadGroup(const GroupName: string);
var
 i: Integer;
 Group: TFontGroup;
 Desc: PFontDesc;
begin
 Group:= FontGroups.Group[GroupName];
 if (Group = nil) then Exit;

 for i:= 0 to Length(Data) - 1 do
  begin
   Desc:= Group.Find(Data[i].Name);
   if (Desc <> nil) then Remove(i);
  end;
end;

//---------------------------------------------------------------------------
initialization
 RetreivePixelsPerInch();

//---------------------------------------------------------------------------
end.
