unit AsphyreImages;
//---------------------------------------------------------------------------
// AsphyreImages.pas                                    Modified: 24-Jan-2006
// The implementation of 2D images/texturing                      Version 2.0
//---------------------------------------------------------------------------
// Important Notice:
//
// If you modify/use this code or one of its parts either in original or
// modified form, you must comply with Mozilla Public License v1.1,
// specifically section 3, "Distribution Obligations". Failure to do so will
// result in the license breach, which will be resolved in the court.
// Remember that violating author's rights is considered a serious crime in
// many countries. Thank you!
//
// !! Please *read* Mozilla Public License 1.1 document located at:
//  http://www.mozilla.org/MPL/
//
// If you require any clarifications about the license, feel free to contact
// us or post your question on our forums at: http://www.afterwarp.net
//---------------------------------------------------------------------------
// The contents of this file are subject to the Mozilla Public License
// Version 1.1 (the "License"); you may not use this file except in
// compliance with the License. You may obtain a copy of the License at
// http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS"
// basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
// License for the specific language governing rights and limitations
// under the License.
//
// The Original Code is AsphyreImages.pas.
//
// The Initial Developer of the Original Code is M. Sc. Yuriy Kotsarenko.
// Portions created by M. Sc. Yuriy Kotsarenko are Copyright (C) 2007,
// Afterwarp Interactive. All Rights Reserved.
//---------------------------------------------------------------------------
interface

//---------------------------------------------------------------------------
uses
 Windows, Direct3D9, D3DX9, Types, SysUtils, AsphyreAsserts, AsphyreTextures,
 MediaImages, AsphyreDef, MediaUtils
 {$IFDEF DebugMode}, AsphyreDebug{$ENDIF};

//---------------------------------------------------------------------------
type
 TAsphyreImages = class;

//---------------------------------------------------------------------------
 TAsphyreCustomImage = class
 private
  FOwner: TAsphyreImages;
  FImageIndex: Integer;

  // NoExclude indicates that the component should not exclude itself
  // from the owner.
  NoExclude: Boolean;
 protected
  FName: string;
  FInitialized: Boolean;

  function GetTextureCount(): Integer; virtual;
  function GetTexture(TexNum: Integer): TAsphyreCustomTexture; virtual;
 public
  // The reference to the image holder.
  property Owner: TAsphyreImages read FOwner;

  // The unique image identifier
  property Name: string read FName;

  // The index assigned by the owner.
  property ImageIndex: Integer read FImageIndex;

  // Determines whether the image has been initialized successfully.
  property Initialized: Boolean read FInitialized;

  // Indicates the number of available textures.
  property TextureCount: Integer read GetTextureCount;

  // Retreives the texture for the specific level.
  property Texture[TexNum: Integer]: TAsphyreCustomTexture read GetTexture;

  function Initialize(Desc: PImageDesc): Boolean; virtual; abstract;
  procedure Finalize(); virtual; abstract;

  constructor Create(AOwner: TAsphyreImages); virtual;
  destructor Destroy(); override;
 end;

//---------------------------------------------------------------------------
 TAsphyreImage = class(TAsphyreCustomImage)
 private
  Textures: array of TAsphyrePlainTexture;

  FPatternSize : TPoint;
  FPatternCount: Integer;
  FPadding: TPoint;

  procedure ReleaseAll();

  procedure SetPatternSize(const Value: TPoint);
  procedure SetPadding(const Value: TPoint);
  function FindPatternTex(Pattern: Integer; out PatInRow,
   PatInCol: Integer): TAsphyrePlainTexture;
  procedure FindPatternMapping(Pattern, PatInRow, PatInCol: Integer;
   Tex: TAsphyrePlainTexture; Mapping: PPoint4); overload;
  procedure FindPatternMapping(Pattern, PatInRow, PatInCol, AddX, AddY, ViewX,
   ViewY: Integer; Tex: TAsphyrePlainTexture; Mapping: PPoint4); overload;
  function GetVisibleSize(): TPoint;
 protected
  function GetTextureCount(): Integer; override;
  function GetTexture(TexNum: Integer): TAsphyreCustomTexture; override;
 public
  // The size of individual sub-images inside the large image. Set to the
  // size of original image if not used; in this case, PatternCount is to
  // be set to 1.
  property PatternSize : TPoint read FPatternSize write SetPatternSize;
  property PatternCount: Integer read FPatternCount write FPatternCount;

  // The following parameter indicates how many pixels are skipped both
  // horizontally and vertically when drawing. This way, the image will
  // most likely appear smaller or stretched. The padding is centered
  // around the image so a value of 2 will cut the image by 1 pixel on
  // both left and right sides.
  property Padding: TPoint read FPadding write SetPadding;

  // The following property calculates the visible area of the image based
  // on previous padding parameter.
  property VisibleSize: TPoint read GetVisibleSize;

  // These routines attempt to find the selected sub-image inside the
  // large image and return its texture. 
  function RetreiveTex(Pattern: Integer;
   Mapping: PPoint4): TAsphyrePlainTexture; overload;
  function RetreiveTex(Pattern, SrcX, SrcY, SrcWidth, SrcHeight: Integer;
   Mirror, Flip: Boolean; Mapping: PPoint4): TAsphyrePlainTexture; overload;

  function Initialize(Desc: PImageDesc): Boolean; override;
  procedure Finalize(); override;
 end;

//---------------------------------------------------------------------------
 TAsphyreSurface = class(TAsphyreCustomImage)
 private
  FRenderTarget: TAsphyreRenderTarget;
 protected
  function GetTexture(TexNum: Integer): TAsphyreCustomTexture; override;
 public
  property RenderTarget: TAsphyreRenderTarget read FRenderTarget;

  function Initialize(Desc: PImageDesc): Boolean; override;
  procedure Finalize(); override;
 end;

//---------------------------------------------------------------------------
 TAsphyreDraft = class(TAsphyreCustomImage)
 private
  FDraft: TAsphyreDynamicTexture;
 protected
  function GetTexture(TexNum: Integer): TAsphyreCustomTexture; override;
 public
  property Draft: TAsphyreDynamicTexture read FDraft;

  function Initialize(Desc: PImageDesc): Boolean; override;
  procedure Finalize(); override;
 end;

//---------------------------------------------------------------------------
 TAsphyreImages = class
 private
  FOwnerDevice: TObject;
  Data: array of TAsphyreCustomImage;

  SearchObjects: array of Integer;
  SearchDirty  : Boolean;
  FMediaOption : string;

  FOnSymbolResolve: TMediaSymbolEvent;
  FOnSymbolLoad   : TMediaSymbolEvent;
  FOnResolveFailed: TMediaSymbolEvent;

  function GetCount(): Integer;
  function GetItem(Num: Integer): TAsphyreCustomImage;
  function CountSearchObjects(): Integer;
  procedure FillSearchObjects(Amount: Integer);
  procedure SortSearchObjects(Left, Right: Integer);
  procedure PrepareSearchObjects();
  function GetImage(const Name: string): TAsphyreCustomImage;
  procedure EventCallback(Sender: TObject; EventNo, EventRef: Integer;
   var Success: Boolean);
 protected
  function FindEmptySlot(): Integer;
  function Insert(Element: TAsphyreCustomImage): Integer;
  function Include(Element: TAsphyreCustomImage): Integer;
  procedure Exclude(Element: TAsphyreCustomImage);
  procedure ReleaseVolatileObjects(); virtual;
 public
  property OwnerDevice: TObject read FOwnerDevice;

  property MediaOption: string read FMediaOption write FMediaOption;

  property OnSymbolResolve: TMediaSymbolEvent read FOnSymbolResolve write FOnSymbolResolve;
  property OnSymbolLoad   : TMediaSymbolEvent read FOnSymbolLoad write FOnSymbolLoad;
  property OnResolveFailed: TMediaSymbolEvent read FOnResolveFailed write FOnResolveFailed;

  property Count: Integer read GetCount;
  property Items[Num: Integer]: TAsphyreCustomImage read GetItem; default;
  property Image[const Name: string]: TAsphyreCustomImage read GetImage;

  function IndexOf(Element: TAsphyreCustomImage): Integer; overload;
  function IndexOf(const uid: string): Integer; overload;
  procedure Remove(Num: Integer);
  procedure RemoveAll();

  function ResolveImage(uid: string): Integer;

  procedure UnloadGroup(const GroupName: string);

  constructor Create(AOwnerDevice: TObject);
  destructor Destroy(); override;
 end;

//---------------------------------------------------------------------------
implementation

//---------------------------------------------------------------------------
uses
 AsphyreEvents, AsphyreDevices;

//---------------------------------------------------------------------------
constructor TAsphyreCustomImage.Create(AOwner: TAsphyreImages);
begin
 inherited Create();

 FImageIndex:= -1;
 Assert(AOwner <> nil, msgInvalidOwner);

 FOwner:= AOwner;
 FInitialized:= False;
 NoExclude:= False;

 FOwner.Insert(Self);
end;

//---------------------------------------------------------------------------
destructor TAsphyreCustomImage.Destroy();
begin
 if (FInitialized) then Finalize();
 if (not NoExclude) then FOwner.Exclude(Self);

 inherited;
end;

//---------------------------------------------------------------------------
function TAsphyreCustomImage.GetTextureCount(): Integer;
begin
 Result:= 1;
end;

//---------------------------------------------------------------------------
function TAsphyreCustomImage.GetTexture(TexNum: Integer): TAsphyreCustomTexture;
begin
 Result:= nil;
end;

//---------------------------------------------------------------------------
function TAsphyreImage.GetTextureCount(): Integer;
begin
 Result:= Length(Textures);
end;

//---------------------------------------------------------------------------
function TAsphyreImage.GetTexture(TexNum: Integer): TAsphyreCustomTexture;
begin
 Assert((TexNum >= 0)and(TexNum < Length(Textures)), msgIndexOutOfBounds);
 Result:= Textures[TexNum];
end;

//---------------------------------------------------------------------------
procedure TAsphyreImage.ReleaseAll();
var
 i: Integer;
begin
 for i:= 0 to Length(Textures) - 1 do
  if (Textures[i] <> nil) then
   begin
    Textures[i].Free();
    Textures[i]:= nil;
   end;

 SetLength(Textures, 0);
end;

//---------------------------------------------------------------------------
procedure TAsphyreImage.SetPatternSize(const Value: TPoint);
var
 i: Integer;
begin
 FPatternSize:= Value;

 for i:= 0 to Length(Textures) - 1 do
  Textures[i].PatternSize:= Value;
end;

//---------------------------------------------------------------------------
procedure TAsphyreImage.SetPadding(const Value: TPoint);
var
 i: Integer;
begin
 FPadding:= Value;

 for i:= 0 to Length(Textures) - 1 do
  Textures[i].Padding:= Value;
end;

//---------------------------------------------------------------------------
function TAsphyreImage.GetVisibleSize(): TPoint;
begin
 Result.X:= FPatternSize.X - FPadding.X;
 Result.Y:= FPatternSize.Y - FPadding.Y;
end;

//---------------------------------------------------------------------------
function TAsphyreImage.Initialize(Desc: PImageDesc): Boolean;
var
 i: Integer;
begin
 Assert(not FInitialized, msgAlreadyInitialized);

 Result:= False;

 // (1) Specify pattern information.
 FPatternSize := Desc.PatSize;
 FPatternCount:= Desc.PatCount;
 FPadding:= Desc.PatPadSize;

 // (2) Create individual textures.
 SetLength(Textures, Length(Desc.Textures));

 for i:= 0 to Length(Textures) - 1 do
  begin
   Textures[i]:= TAsphyrePlainTexture.Create(Owner.OwnerDevice);
   Textures[i].PatternSize:= Desc.PatSize;
   Textures[i].Format     := Desc.Format;
   Textures[i].MipLevels  := Desc.MipLevels;
   Textures[i].Padding    := Desc.PatPadSize;

   Result:= Textures[i].InitializeEx(Desc.Textures[i], Desc.ColorKey);
   if (not Result) then
    begin
     ReleaseAll();
     Break;
    end;
  end;

 FInitialized:= Result;
end;

//---------------------------------------------------------------------------
procedure TAsphyreImage.Finalize();
begin
 ReleaseAll();
 FInitialized:= False;
end;

//---------------------------------------------------------------------------
function TAsphyreImage.FindPatternTex(Pattern: Integer; out PatInRow,
 PatInCol: Integer): TAsphyrePlainTexture;
var
 TexIndex, PatInTex: Integer;
begin
 TexIndex:= 0;
 PatInTex:= -1;
 PatInRow:= 1;
 PatInCol:= 1;

 // Cycle through textures to find where Pattern is located.
 while (TexIndex < Length(Textures)) do
  begin
   PatInRow:= Textures[TexIndex].OrigSize.X div FPatternSize.X;
   PatInCol:= Textures[TexIndex].OrigSize.Y div FPatternSize.Y;
   PatInTex:= PatInRow * PatInCol;

   if (Pattern >= PatInTex) then
    begin
     Inc(TexIndex);
     Dec(Pattern, PatInTex);
    end else Break;
  end;

 // If couldn't find the desired texture, just exit.
 if (TexIndex >= Length(Textures))or(Pattern >= PatInTex) then
  begin
   Result:= nil;
   Exit;
  end;

 Result:= Textures[TexIndex];
end;

//---------------------------------------------------------------------------
procedure TAsphyreImage.FindPatternMapping(Pattern, PatInRow,
 PatInCol: Integer; Tex: TAsphyrePlainTexture; Mapping: PPoint4);
var
 SrcX, SrcY, EndX, EndY: Integer;
begin
 SrcX:= (Pattern mod PatInRow) * FPatternSize.X + (FPadding.X div 2);
 SrcY:= ((Pattern div PatInRow) mod PatInCol) * FPatternSize.Y + (FPadding.Y div 2);
 EndX:= SrcX + FPatternSize.X - FPadding.X;
 EndY:= SrcY + FPatternSize.Y - FPadding.Y;

 Mapping[0].x:= SrcX / Tex.OrigSize.X;
 Mapping[0].y:= SrcY / Tex.OrigSize.Y;

 Mapping[1].x:= EndX / Tex.OrigSize.X;
 Mapping[1].y:= Mapping[0].y;

 Mapping[2].x:= Mapping[1].x;
 Mapping[2].y:= EndY / Tex.OrigSize.Y;

 Mapping[3].x:= Mapping[0].x;
 Mapping[3].y:= Mapping[2].y;
end;

//---------------------------------------------------------------------------
procedure TAsphyreImage.FindPatternMapping(Pattern, PatInRow,
 PatInCol, AddX, AddY, ViewX, ViewY: Integer; Tex: TAsphyrePlainTexture;
 Mapping: PPoint4);
var
 SrcX, SrcY, EndX, EndY: Integer;
begin
 SrcX:= (Pattern mod PatInRow) * FPatternSize.X + (FPadding.X div 2) + AddX;
 SrcY:= ((Pattern div PatInRow) mod PatInCol) * FPatternSize.Y +
  (FPadding.Y div 2) + AddY;
 EndX:= SrcX + ViewX - FPadding.X;
 EndY:= SrcY + ViewY - FPadding.Y;

 Mapping[0].x:= SrcX / Tex.OrigSize.X;
 Mapping[0].y:= SrcY / Tex.OrigSize.Y;

 Mapping[1].x:= EndX / Tex.OrigSize.X;
 Mapping[1].y:= Mapping[0].y;

 Mapping[2].x:= Mapping[1].x;
 Mapping[2].y:= EndY / Tex.OrigSize.Y;

 Mapping[3].x:= Mapping[0].x;
 Mapping[3].y:= Mapping[2].y;
end;

//---------------------------------------------------------------------------
function TAsphyreImage.RetreiveTex(Pattern: Integer;
 Mapping: PPoint4): TAsphyrePlainTexture;
var
 PatInRow, PatInCol: Integer;
begin
 Assert(FInitialized, msgNotInitialized);

 Result:= FindPatternTex(Pattern, PatInRow, PatInCol);
 if (Result = nil) then Exit;

 FindPatternMapping(Pattern, PatInRow, PatInCol, Result, Mapping);
end;

//---------------------------------------------------------------------------
function TAsphyreImage.RetreiveTex(Pattern, SrcX, SrcY, SrcWidth,
 SrcHeight: Integer; Mirror, Flip: Boolean;
 Mapping: PPoint4): TAsphyrePlainTexture;
var
 PatInRow, PatInCol: Integer;
 Aux: Single;
begin
 Assert(FInitialized, msgNotInitialized);

 Result:= FindPatternTex(Pattern, PatInRow, PatInCol);
 if (Result = nil) then Exit;

 FindPatternMapping(Pattern, PatInRow, PatInCol, SrcX, SrcY, SrcWidth,
  SrcHeight, Result, Mapping);

 if (Mirror) then
  begin
   Aux:= Mapping[0].x;

   Mapping[0].x:= Mapping[1].x;
   Mapping[3].x:= Mapping[1].x;
   Mapping[1].x:= Aux;
   Mapping[2].x:= Aux;
  end;
 if (Flip) then
  begin
   Aux:= Mapping[0].y;

   Mapping[0].y:= Mapping[2].y;
   Mapping[1].y:= Mapping[2].y;
   Mapping[2].y:= Aux;
   Mapping[3].y:= Aux;
  end;
end;

//---------------------------------------------------------------------------
function TAsphyreSurface.Initialize(Desc: PImageDesc): Boolean;
begin
 Assert(not FInitialized, msgAlreadyInitialized);

 FRenderTarget:= TAsphyreRenderTarget.Create(Owner.OwnerDevice);
 FRenderTarget.Size     := Desc.Size;
 FRenderTarget.Format   := Desc.Format;
 FRenderTarget.MipLevels:= Desc.MipLevels;
 FRenderTarget.UseDepthStencil:= Desc.DepthStencil;

 Result:= FRenderTarget.Initialize();
 if (not Result) then
  begin
   FRenderTarget.Free();
   FRenderTarget:= nil;
  end;

 FInitialized:= Result;
end;

//---------------------------------------------------------------------------
procedure TAsphyreSurface.Finalize();
begin
 if (FRenderTarget <> nil) then
  begin
   FRenderTarget.Free();
   FRenderTarget:= nil;
  end;

 FInitialized:= False;
end;

//---------------------------------------------------------------------------
function TAsphyreSurface.GetTexture(TexNum: Integer): TAsphyreCustomTexture;
begin
 Result:= FRenderTarget;
end;

//---------------------------------------------------------------------------
function TAsphyreDraft.Initialize(Desc: PImageDesc): Boolean;
begin
 Assert(not FInitialized, msgAlreadyInitialized);

 FDraft:= TAsphyreDynamicTexture.Create(Owner.OwnerDevice);
 FDraft.Size     := Desc.Size;
 FDraft.Format   := Desc.Format;
 FDraft.MipLevels:= Desc.MipLevels;

 Result:= FDraft.Initialize();
 if (not Result) then
  begin
   FDraft.Free();
   FDraft:= nil;
  end;

 FInitialized:= Result;
end;

//---------------------------------------------------------------------------
procedure TAsphyreDraft.Finalize();
begin
 if (FDraft <> nil) then
  begin
   FDraft.Free();
   FDraft:= nil;
  end;

 FInitialized:= False;
end;

//---------------------------------------------------------------------------
function TAsphyreDraft.GetTexture(TexNum: Integer): TAsphyreCustomTexture;
begin
 Result:= FDraft;
end;

//---------------------------------------------------------------------------
constructor TAsphyreImages.Create(AOwnerDevice: TObject);
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
destructor TAsphyreImages.Destroy();
begin
 RemoveAll();

 TAsphyreDevice(FOwnerDevice).Events.Exclude(EventCallback);

 inherited;
end;

//---------------------------------------------------------------------------
function TAsphyreImages.GetCount(): Integer;
begin
 Result:= Length(Data);
end;

//---------------------------------------------------------------------------
function TAsphyreImages.GetItem(Num: Integer): TAsphyreCustomImage;
begin
 Assert((Num >= 0)and(Num < Length(Data)), msgIndexOutOfBounds);
 Result:= Data[Num];
end;

//---------------------------------------------------------------------------
function TAsphyreImages.IndexOf(Element: TAsphyreCustomImage): Integer;
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
function TAsphyreImages.CountSearchObjects(): Integer;
var
 i: Integer;
begin
 Result:= 0;

 for i:= 0 to Length(Data) - 1 do
  if (Data[i] <> nil) then Inc(Result);
end;

//---------------------------------------------------------------------------
procedure TAsphyreImages.FillSearchObjects(Amount: Integer);
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
procedure TAsphyreImages.SortSearchObjects(Left, Right: Integer);
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
procedure TAsphyreImages.PrepareSearchObjects();
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
function TAsphyreImages.IndexOf(const uid: string): Integer;
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
function TAsphyreImages.FindEmptySlot(): Integer;
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
function TAsphyreImages.Insert(Element: TAsphyreCustomImage): Integer;
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
 Element.FImageIndex:= Slot;

 SearchDirty:= True;
 Result:= Slot;
end;

//---------------------------------------------------------------------------
function TAsphyreImages.Include(Element: TAsphyreCustomImage): Integer;
begin
 Result:= IndexOf(Element);
 if (Result = -1) then Result:= Insert(Element);
end;

//---------------------------------------------------------------------------
procedure TAsphyreImages.Exclude(Element: TAsphyreCustomImage);
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
procedure TAsphyreImages.Remove(Num: Integer);
begin
 Assert((Num >= 0)and(Num < Length(Data)), msgIndexOutOfBounds);

 Data[Num].NoExclude:= True;
 Data[Num].Free();
 Data[Num]:= nil;

 SearchDirty:= True;
end;

//---------------------------------------------------------------------------
procedure TAsphyreImages.RemoveAll();
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
function TAsphyreImages.ResolveImage(uid: string): Integer;
var
 Index: Integer;
 ImageDesc: PImageDesc;
 Instance : TAsphyreCustomImage;
begin
 // (1) Identifiers are not case-sensitive.
 uid:= LowerCase(uid);

 // (2) Check whether the image has been previously loaded
 Index:= IndexOf(uid);
 if (Index <> -1) then
  begin
   Result:= Index;
   Exit;
  end;

 // (3) Notify about symbol resolution.
 if (Assigned(FOnSymbolResolve)) then FOnSymbolResolve(Self, uid);

 // (4) Determine if description for the image exists.
 ImageDesc:= ImageGroups.Find(uid, MediaOption);
 if (ImageDesc = nil) then
  begin
   {$IFDEF DebugMode}
   DebugLog('!! Unresolved image symbol: "' + uid + '".');
   {$ENDIF}

   if (Assigned(FOnResolveFailed)) then FOnResolveFailed(Self, uid);

   Result:= -1;
   Exit;
  end;

 // (5) Create the particular image type.
 Instance:= nil;
 case ImageDesc.DescType of
  idtImage:
   Instance:= TAsphyreImage.Create(Self);

  idtSurface:
   Instance:= TAsphyreSurface.Create(Self);

  idtDraft:
   Instance:= TAsphyreDraft.Create(Self);
 end;

 // (6) Notify about symbol load.
 if (Assigned(FOnSymbolLoad)) then FOnSymbolLoad(Self, uid);

 // (7) Load and initialize image specification.
 Instance.FName:= LowerCase(uid);

 if (not Instance.Initialize(ImageDesc)) then
  begin
   {$IFDEF DebugMode}
   DebugLog('!! Resolution failed for image symbol "' + uid + '".');
   {$ENDIF}

   if (Assigned(FOnResolveFailed)) then FOnResolveFailed(Self, uid);
   
   Instance.Free();
   Result:= -1;
   Exit;
  end;

 // (8) Ok, we have a new image symbol in the list.
 Result:= Instance.ImageIndex;
end;

//---------------------------------------------------------------------------
function TAsphyreImages.GetImage(const Name: string): TAsphyreCustomImage;
var
 Index: Integer;
begin
 Index:= ResolveImage(Name);
 if (Index <> -1) then Result:= Data[Index] else Result:= nil;
end;

//---------------------------------------------------------------------------
procedure TAsphyreImages.ReleaseVolatileObjects();
var
 i: Integer;
begin
 for i:= 0 to Length(Data) - 1 do
  if (Data[i] <> nil)and((Data[i] is TAsphyreSurface)or(Data[i] is TAsphyreDraft)) then
   begin
    Data[i].NoExclude:= True;
    Data[i].Free();
    Data[i]:= nil;
   end;

 SearchDirty:= True;  
end;

//---------------------------------------------------------------------------
procedure TAsphyreImages.EventCallback(Sender: TObject; EventNo,
 EventRef: Integer; var Success: Boolean);
begin
 case EventNo of
  aevFinalize:
   RemoveAll();

  aevDeviceLost:
   ReleaseVolatileObjects();
 end;
end;

//---------------------------------------------------------------------------
procedure TAsphyreImages.UnloadGroup(const GroupName: string);
var
 i: Integer;
 Group: TImageGroup;
 Desc: PImageDesc;
begin
 Group:= ImageGroups.Group[GroupName];
 if (Group = nil) then Exit;

 for i:= 0 to Length(Data) - 1 do
  begin
   Desc:= Group.Find(Data[i].Name);
   if (Desc <> nil) then Remove(i);
  end;
end;

//---------------------------------------------------------------------------
end.
