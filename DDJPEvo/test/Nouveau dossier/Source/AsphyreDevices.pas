unit AsphyreDevices;
//---------------------------------------------------------------------------
// AsphyreDevices.pas                                   Modified: 23-Jan-2007
// Asphyre Device encapsulating Direct3D functionality            Version 4.0
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
// The Original Code is AsphyreDevices.pas.
//
// The Initial Developer of the Original Code is M. Sc. Yuriy Kotsarenko.
// Portions created by M. Sc. Yuriy Kotsarenko are Copyright (C) 2007,
// Afterwarp Interactive. All Rights Reserved.
//---------------------------------------------------------------------------
interface

//---------------------------------------------------------------------------
uses
 Windows, Direct3D9, AsphyreEvents, AsphyreCanvas, AsphyreImages,
 AsphyreFonts;

//---------------------------------------------------------------------------
type
 TDepthStencilType = (dsNone, dsDepthOnly, dsDepthStencil);

//---------------------------------------------------------------------------
 TBitDepthType = (bd15bit, bd16bit, bd24bit, bd30bit);

//---------------------------------------------------------------------------
 TDisplayInfo = record
  Adapter        : Integer;
  Driver         : string;
  Description    : string;
  DeviceName     : string;
  DriverVersionLo: Longword;
  DriverVersionHi: Longword;
  VendorID       : Longword;
  DeviceID       : Longword;
  SubSysID       : Longword;
  Revision       : Longword;
  DeviceGuid     : TGuid;
 end;

//---------------------------------------------------------------------------
 TScreenConfig = record
  Adapter      : Integer;
  Width        : Integer;
  Height       : Integer;
  Windowed     : Boolean;
  VSync        : Boolean;
  BitDepth     : TBitDepthType;
  WindowHandle : THandle;
  HardwareTL   : Boolean;
  DepthStencil : TDepthStencilType;
 end;

//---------------------------------------------------------------------------
 TAsphyreDevice = class;

//---------------------------------------------------------------------------
 TAsphyreDevices = class;

//---------------------------------------------------------------------------
 TScreenConfigEvent = procedure(Sender: TAsphyreDevice; Tag: TObject;
  var Config: TScreenConfig) of object;

//---------------------------------------------------------------------------
 TScreenConfigExEvent = procedure(Sender: TAsphyreDevice; Tag: TObject;
  var Adapter, WindowHandle: Integer; var UsingDepthBuffer, UsingStencilBuffer,
  HardwareTL: Boolean; var Params: TD3DPresentParameters) of object;

//---------------------------------------------------------------------------
 TDeviceResetEvent = procedure(Sender: TAsphyreDevice; Tag: TObject;
  var Params: TD3DPresentParameters) of object;

//---------------------------------------------------------------------------
 TDeviceTagEvent = procedure(Sender: TAsphyreDevice; Tag: TObject) of object;

//---------------------------------------------------------------------------
 TDevicePureEvent = procedure(Sender: TAsphyreDevice) of object;

//---------------------------------------------------------------------------
 TAsphyreDevice = class
 private
  FOwner : TAsphyreDevices;
  FIndex : Integer;
  FEvents: TEventCallbacks;
  FDev9  : IDirect3DDevice9;
  FCaps9 : TD3DCaps9;
  FParams: TD3DPresentParameters;
  FCanvas: TAsphyreCanvas;
  FImages: TAsphyreImages;
  FFonts : TAsphyreFonts;

  FInitialized : Boolean;
  NotifiedLost : Boolean;
  UsingDepthBuf: Boolean;
  UsingStencil : Boolean;
 protected
  function GetDefaultConfig(): TScreenConfig;
  function ConfigToParams(const Config: TScreenConfig): TD3DPresentParameters;
  function GetDefaultParams(): TD3DPresentParameters;
 public
  property Owner: TAsphyreDevices read FOwner;
  property Index: Integer read FIndex;

  property Events: TEventCallbacks read FEvents;

  property Dev9  : IDirect3DDevice9 read FDev9;
  property Caps9 : TD3DCaps9 read FCaps9;
  property Params: TD3DPresentParameters read FParams;

  property Canvas: TAsphyreCanvas read FCanvas;
  property Images: TAsphyreImages read FImages;
  property Fonts : TAsphyreFonts read FFonts;

  property Initialized: Boolean read FInitialized;

  function FindBackFormat(Depth: TBitDepthType; Adapter, Width,
   Height: Integer): TD3DFormat;
  function FindDepthFormat(Depth: TDepthStencilType; BackFormat: TD3DFormat;
   Adapter: Integer): TD3DFormat;

  function Reset(Event: TDeviceResetEvent; Tag: TObject): Boolean;
  function Flip(): Boolean; overload;
  function Flip(WindowHandle: THandle): Boolean; overload;
  procedure Clear(Color: Cardinal; DepthValue: Real; StencilValue: Cardinal);
  procedure BeginScene();
  procedure EndScene();

  function Initialize(CfgEvent: TScreenConfigEvent; Tag: TObject): Boolean;
  function InitializeEx(Event: TScreenConfigExEvent; Tag: TObject): Boolean;
  procedure Finalize();

  function ChangeParams(NewWidth, NewHeight: Integer;
   Windowed: Boolean): Boolean;

  procedure DrawOnSurf(ImageIndex: Integer; Event: TDeviceTagEvent;
   Tag: TObject); overload;
  procedure DrawOnSurf(ImageIndex: Integer; Event: TDeviceTagEvent;
   Tag: TObject; Bkgrnd: Cardinal); overload;
  procedure DrawOnSurf(ImageIndex: Integer; Event: TDeviceTagEvent;
   Tag: TObject; Bkgrnd: Cardinal; DepthValue: Real;
   StencilValue: Cardinal); overload;

  procedure DrawOnSurf(const SurfName: string; Event: TDeviceTagEvent;
   Tag: TObject); overload;
  procedure DrawOnSurf(const SurfName: string; Event: TDeviceTagEvent;
   Tag: TObject; Bkgrnd: Cardinal); overload;
  procedure DrawOnSurf(const SurfName: string; Event: TDeviceTagEvent;
   Tag: TObject; Bkgrnd: Cardinal; DepthValue: Real;
   StencilValue: Cardinal); overload;

  procedure Render(WindowHandle: THandle; Event: TDeviceTagEvent;
   Tag: TObject); overload;
  procedure Render(WindowHandle: THandle; Event: TDeviceTagEvent; Tag: TObject;
   Bkgrnd: Cardinal); overload;
  procedure Render(WindowHandle: THandle; Event: TDeviceTagEvent; Tag: TObject;
   Bkgrnd: Cardinal; DepthValue: Real; StencilValue: Cardinal); overload;

  procedure Render(Event: TDeviceTagEvent; Tag: TObject); overload;
  procedure Render(Event: TDeviceTagEvent; Tag: TObject;
   Bkgrnd: Cardinal); overload;
  procedure Render(Event: TDeviceTagEvent; Tag: TObject; Bkgrnd: Cardinal;
   DepthValue: Real; StencilValue: Cardinal); overload;

  constructor Create(AOwner: TAsphyreDevices; AIndex: Integer);
  destructor Destroy(); override;
 end;

//---------------------------------------------------------------------------
 TAsphyreDevices = class
 private
  Data: array of TAsphyreDevice;
  FDriver: IDirect3D9;

  FInitEvent: TDevicePureEvent;
  FDoneEvent: TDevicePureEvent;
  FPreloadEvent: TDevicePureEvent;

  function GetCount(): Integer;
  function GetDevice(Num: Integer): TAsphyreDevice;
  procedure SetCount(const Value: Integer);

  function Insert(): Integer;
  procedure Remove(Num: Integer);
  procedure RemoveAll();
  function GetDisplayCount(): Integer;
  function GetDisplayInfo(Num: Integer): TDisplayInfo;
 public
  property Count: Integer read GetCount write SetCount;
  property Device[Num: Integer]: TAsphyreDevice read GetDevice; default;

  property InitEvent: TDevicePureEvent read FInitEvent write FInitEvent;
  property DoneEvent: TDevicePureEvent read FDoneEvent write FDoneEvent;
  property PreloadEvent: TDevicePureEvent read FPreloadEvent write FPreloadEvent;

  property Driver: IDirect3D9 read FDriver;
  property DisplayCount: Integer read GetDisplayCount;
  property DisplayInfo[Num: Integer]: TDisplayInfo read GetDisplayInfo;

  // initialize the screen using intuitive parameters
  function Initialize(CfgEvent: TScreenConfigEvent; Tag: TObject): Boolean;

  // initialize the screen using user-defined Direct3D parameters
  function InitializeEx(Event: TScreenConfigExEvent; Tag: TObject): Boolean;
  procedure Finalize();

  constructor Create();
  destructor Destroy(); override;
 end;

//---------------------------------------------------------------------------
var
 Devices: TAsphyreDevices = nil;

 // The reference to the default device. 
 DefDevice: TAsphyreDevice = nil;

//---------------------------------------------------------------------------
implementation

//---------------------------------------------------------------------------
uses
 AsphyreAsserts;

//---------------------------------------------------------------------------
const
 BackFormats: array[0..5] of TD3DFormat = (
  {  0 } D3DFMT_A2R10G10B10,
  {  1 } D3DFMT_A8R8G8B8,
  {  2 } D3DFMT_X8R8G8B8,
  {  3 } D3DFMT_A1R5G5B5,
  {  4 } D3DFMT_X1R5G5B5,
  {  5 } D3DFMT_R5G6B5);

//---------------------------------------------------------------------------
 DepthStencilFormats: array[0..6] of TD3DFormat = (
  {  0 } D3DFMT_D24S8,
  {  1 } D3DFMT_D24FS8,
  {  2 } D3DFMT_D24X4S4,
  {  3 } D3DFMT_D15S1,

  {  4 } D3DFMT_D32,
  {  5 } D3DFMT_D24X8,
  {  6 } D3DFMT_D16);

//---------------------------------------------------------------------------
constructor TAsphyreDevice.Create(AOwner: TAsphyreDevices; AIndex: Integer);
begin
 inherited Create();

 Assert(AOwner <> nil, msgNoOwnerSpecified);

 FOwner := AOwner;
 FIndex := AIndex;
 FEvents:= TEventCallbacks.Create();

 FCanvas:= TAsphyreCanvas.Create(Self);
 FImages:= TAsphyreImages.Create(Self);
 FFonts := TAsphyreFonts.Create(Self);

 FInitialized:= False;
end;

//---------------------------------------------------------------------------
destructor TAsphyreDevice.Destroy();
begin
 if (FInitialized) then Finalize();

 FFonts.Free();
 FImages.Free();
 FCanvas.Free();
 FEvents.Free();

 inherited;
end;

//---------------------------------------------------------------------------
function TAsphyreDevice.GetDefaultConfig(): TScreenConfig;
begin
 Result.Adapter := D3DADAPTER_DEFAULT;
 Result.Width   := 640;
 Result.Height  := 480;
 Result.Windowed:= True;
 Result.VSync   := False;
 Result.BitDepth:= bd24bit;

 Result.WindowHandle:= 0;
 Result.HardwareTL  := True;
 Result.DepthStencil:= dsDepthStencil;
end;

//---------------------------------------------------------------------------
function TAsphyreDevice.FindBackFormat(Depth: TBitDepthType; Adapter, Width,
 Height: Integer): TD3DFormat;
const
 FormatIndexes: array[TBitDepthType, 0..5] of Integer = ((4, 3, 5, 1, 2, 0),
  (3, 4, 5, 1, 2, 0), (1, 2, 0, 5, 3, 4), (0, 1, 2, 5, 3, 4));
var
 FormatNo : Integer;
 Format   : TD3DFormat;
 ModeCount: Integer;
 ModeNo   : Integer;
 Mode     : TD3DDisplayMode;
begin
 Result:= D3DFMT_UNKNOWN;

 // search through the list of available back-buffer formats
 for FormatNo:= 0 to 5 do
  begin
   // determine Direct3D back-buffer format
   Format:= BackFormats[FormatIndexes[Depth, FormatNo]];

   // check all existing modes for the specified format
   ModeCount:= FOwner.Driver.GetAdapterModeCount(Adapter, Format);
   for ModeNo:= 0 to ModeCount - 1 do
    begin
     // verify whether the specified mode is compatible
     if (Succeeded(FOwner.Driver.EnumAdapterModes(Adapter, Format, ModeNo, Mode)))and
      (Integer(Mode.Width) = Width)and(Integer(Mode.Height) = Height) then
      begin
       Result:= Format;
       Exit;
      end;
    end;
  end;
end;

//---------------------------------------------------------------------------
function TAsphyreDevice.FindDepthFormat(Depth: TDepthStencilType;
 BackFormat: TD3DFormat; Adapter: Integer): TD3DFormat;
const
 FormatIndexes: array[TDepthStencilType, 0..6] of Integer = (
  (-1, -1, -1, -1, -1, -1, -1), (4, 5, 0, 2, 1, 6, 3), (0, 1, 2, 3, 4, 5, 6));
var
 FormatNo : Integer;
 Format   : TD3DFormat;
 ModeCount: Integer;
 ModeNo   : Integer;
begin
 Result:= D3DFMT_UNKNOWN;
 if (Depth = dsNone) then Exit;

 // search through the list of available depth-buffer formats
 for FormatNo:= 0 to 6 do
  begin
   // determine Direct3D back-buffer format
   Format:= DepthStencilFormats[FormatIndexes[Depth, FormatNo]];

   // check all existing modes for the specified format
   ModeCount:= FOwner.Driver.GetAdapterModeCount(Adapter, BackFormat);
   for ModeNo:= 0 to ModeCount - 1 do
    begin
     // verify whether the specified mode is compatible
     if (Succeeded(FOwner.Driver.CheckDeviceFormat(Adapter, D3DDEVTYPE_HAL,
      BackFormat, D3DUSAGE_DEPTHSTENCIL, D3DRTYPE_SURFACE, Format))) then
      begin
       Result:= Format;
       Exit;
      end;
    end;
  end;
end;

//---------------------------------------------------------------------------
function TAsphyreDevice.ConfigToParams(const Config: TScreenConfig): TD3DPresentParameters;
var
 Mode: TD3DDisplayMode;
begin
 FillChar(Result, SizeOf(TD3DPresentParameters), 0);

 Result.BackBufferWidth := Config.Width;
 Result.BackBufferHeight:= Config.Height;
 Result.Windowed        := Config.Windowed;
 Result.hDeviceWindow   := Config.WindowHandle;
 Result.SwapEffect      := D3DSWAPEFFECT_DISCARD;

 // specify Presentation Interval
 Result.PresentationInterval:= D3DPRESENT_INTERVAL_IMMEDIATE;
 if (Config.VSync) then Result.PresentationInterval:= D3DPRESENT_INTERVAL_ONE;

 // specify Back Buffer Format
 if (Config.Windowed) then
  begin
   Result.BackBufferFormat:= D3DFMT_UNKNOWN;

   if (Succeeded(FOwner.Driver.GetAdapterDisplayMode(Config.Adapter, Mode))) then
    Result.BackBufferFormat:= Mode.Format;
  end else Result.BackBufferFormat:= FindBackFormat(Config.BitDepth,
   Config.Adapter, Config.Width, Config.Height);

 // specify Depth Stencil Buffer Format
 if (Config.DepthStencil <> dsNone) then
  begin
   Result.EnableAutoDepthStencil:= True;
   Result.Flags:= D3DPRESENTFLAG_DISCARD_DEPTHSTENCIL;
   Result.AutoDepthStencilFormat:= FindDepthFormat(Config.DepthStencil,
    Result.BackBufferFormat, Config.Adapter);
  end;
end;

//---------------------------------------------------------------------------
function TAsphyreDevice.Initialize(CfgEvent: TScreenConfigEvent;
 Tag: TObject): Boolean;
var
 Res: Integer;
 Config: TScreenConfig;
begin
 // (1) Verify conditions.
 Assert(not FInitialized, msgAlreadyInitialized);
 Assert(Assigned(CfgEvent), msgNoConfigEvent);

 // (2) Retreive configuration.
 Config:= GetDefaultConfig();
 CfgEvent(Self, Tag, Config);

 // (3) Make present parameters.
 FParams:= ConfigToParams(Config);

 UsingDepthBuf := (Config.DepthStencil <> dsNone);
 UsingStencil  := (Config.DepthStencil = dsDepthStencil);

 // (5) Attempt to use hardware vertex processing.
 if (Config.HardwareTL) then
  begin
   Res:= FOwner.Driver.CreateDevice(Config.Adapter, D3DDEVTYPE_HAL,
    Config.WindowHandle, D3DCREATE_HARDWARE_VERTEXPROCESSING,
    @FParams, FDev9);
  end else Res:= D3D_OK; // for the next call

 // -> if FAILED, try software vertex processing
 if (Failed(Res))or(not Config.HardwareTL) then
  Res:= FOwner.Driver.CreateDevice(Config.Adapter, D3DDEVTYPE_HAL,
   Config.WindowHandle, D3DCREATE_SOFTWARE_VERTEXPROCESSING,
   @FParams, FDev9);

 // -> if STILL FAILED, then we cannot proceed
 Result:= Succeeded(Res);

 // (6) Retreive device capabilities.
 if (Result) then
  Result:= Succeeded(FDev9.GetDeviceCaps(FCaps9));

 // (7) Mark that we have not lost the device.
 NotifiedLost:= False;

 // (8) Update initialized status.
 FInitialized:= Result;
 if (Result) then
  begin
   // (9) Broadcast Initialize notification to subscribed components
   Result:= FEvents.Notify(Self, aevInitialize, 0);
   if (not Result) then Finalize();
  end;

 // (10) Invoke relevant event.
 if (Assigned(FOwner.InitEvent)) then FOwner.InitEvent(Self);
 if (Assigned(FOwner.PreloadEvent)) then FOwner.PreloadEvent(Self);
end;

//---------------------------------------------------------------------------
function TAsphyreDevice.GetDefaultParams(): TD3DPresentParameters;
begin
 FillChar(Result, SizeOf(TD3DPresentParameters), 0);

 Result.BackBufferWidth := 640;
 Result.BackBufferHeight:= 480;
 Result.BackBufferFormat:= D3DFMT_UNKNOWN;
 Result.BackBufferCount := 1;
 Result.SwapEffect      := D3DSWAPEFFECT_DISCARD;
 Result.Windowed        := True;
 Result.Flags           := D3DPRESENTFLAG_DISCARD_DEPTHSTENCIL;
 Result.PresentationInterval:= D3DPRESENT_INTERVAL_DEFAULT;
end;

//---------------------------------------------------------------------------
function TAsphyreDevice.InitializeEx(Event: TScreenConfigExEvent;
 Tag: TObject): Boolean;
var
 Res: Integer;
 Adapter, WindowHandle: Integer;
 HardwareTL: Boolean;
begin
 // (1) Verify conditions.
 Assert(not FInitialized, msgAlreadyInitialized);
 Assert(Assigned(Event), msgNoConfigEvent);

 // (2) Retreive present parameters.
 FParams:= GetDefaultParams();
 Event(Self, Tag, Adapter, WindowHandle, UsingDepthBuf, UsingStencil,
  HardwareTL, FParams);

 // (4) Attempt to use hardware vertex processing.
 if (HardwareTL) then
  begin
   Res:= FOwner.Driver.CreateDevice(Adapter, D3DDEVTYPE_HAL,
    WindowHandle, D3DCREATE_HARDWARE_VERTEXPROCESSING, @FParams, FDev9);
  end else Res:= D3D_OK; // for the next call

 // -> if FAILED, try software vertex processing
 if (Failed(Res))or(not HardwareTL) then
  Res:= FOwner.Driver.CreateDevice(Adapter, D3DDEVTYPE_HAL, WindowHandle,
   D3DCREATE_SOFTWARE_VERTEXPROCESSING, @FParams, FDev9);

 // -> if STILL FAILED, then we cannot proceed
 Result:= Succeeded(Res);

 // (5) Retreive device capabilities.
 if (Result) then
  Result:= Succeeded(FDev9.GetDeviceCaps(FCaps9));

 // (6) Mark that we have not lost the device.
 NotifiedLost:= False;

 // (7) Update initialized status.
 FInitialized:= Result;
 if (Result) then
  begin
   // (8) Broadcast Initialize notification to subscribed components
   Result:= FEvents.Notify(Self, aevInitialize, 0);
   if (not Result) then Finalize();
  end;
end;

//---------------------------------------------------------------------------
procedure TAsphyreDevice.Finalize();
begin
 // (1) Verify conditions (no assertions).
 if (not FInitialized) then Exit;

 // (2) Invoke finalization event.
 if (Assigned(FOwner.DoneEvent)) then FOwner.DoneEvent(Self);

 // (3) Broadcast Finalize notification to subscribed components
 FEvents.Notify(Self, aevFinalize, 0);

 // (4) Release Direct3D objects.
 if (FDev9 <> nil) then FDev9:= nil;

 // (5) Change status to [not DeviceActive]
 FInitialized:= False;
end;

//---------------------------------------------------------------------------
procedure TAsphyreDevice.Render(WindowHandle: THandle; Event: TDeviceTagEvent;
 Tag: TObject; Bkgrnd: Cardinal; DepthValue: Real; StencilValue: Cardinal);
begin
 if (not FInitialized) then Exit;

 Clear(Bkgrnd, DepthValue, StencilValue);
 BeginScene();

 Event(Self, Tag);
 EndScene();
 Flip(WindowHandle);
end;

//---------------------------------------------------------------------------
procedure TAsphyreDevice.Render(WindowHandle: THandle; Event: TDeviceTagEvent;
 Tag: TObject; Bkgrnd: Cardinal);
begin
 Render(WindowHandle, Event, Tag, Bkgrnd, 1.0, 0);
end;

//---------------------------------------------------------------------------
procedure TAsphyreDevice.Render(WindowHandle: THandle; Event: TDeviceTagEvent;
 Tag: TObject);
begin
 if (not FInitialized) then Exit;
 
 BeginScene();

 Event(Self, Tag);
 EndScene();
 Flip(WindowHandle);
end;

//---------------------------------------------------------------------------
procedure TAsphyreDevice.Render(Event: TDeviceTagEvent; Tag: TObject;
 Bkgrnd: Cardinal; DepthValue: Real; StencilValue: Cardinal);
begin
 Render(0, Event, Tag, Bkgrnd, DepthValue, StencilValue);
end;

//---------------------------------------------------------------------------
procedure TAsphyreDevice.Render(Event: TDeviceTagEvent; Tag: TObject;
 Bkgrnd: Cardinal);
begin
 Render(0, Event, Tag, Bkgrnd, 1.0, 0);
end;

//---------------------------------------------------------------------------
procedure TAsphyreDevice.Render(Event: TDeviceTagEvent; Tag: TObject);
begin
 Render(0, Event, Tag);
end;

//---------------------------------------------------------------------------
function TAsphyreDevice.Reset(Event: TDeviceResetEvent; Tag: TObject): Boolean;
begin
 Assert(FInitialized, msgNotInitialized);

 FEvents.Notify(Self, aevDeviceLost, 0);

 // reconfigure present parameters
 if (Assigned(Event)) then Event(Self, Tag, FParams);

 // try resetting the device
 Result:= Succeeded(FDev9.Reset(FParams));
 if (Result) then
  begin
   Events.Notify(Self, aevDeviceRecover, 0);
   if (Assigned(FOwner.PreloadEvent)) then FOwner.PreloadEvent(Self);
  end;
end;

//---------------------------------------------------------------------------
function TAsphyreDevice.Flip(): Boolean;
begin
 Result:= Flip(0);
end;

//---------------------------------------------------------------------------
function TAsphyreDevice.Flip(WindowHandle: THandle): Boolean;
var
 Res: Integer;
begin
 // (1) Verify conditions.
 Assert(FInitialized, msgNotInitialized);

 // (2) Present the scene.
 Res:= FDev9.Present(nil, nil, WindowHandle, nil);

 // (3) Device has been lost?
 if (Res = D3DERR_DEVICELOST) then
  begin
   // notify everyone that we've lost our device
   if (not NotifiedLost) then
    begin
     FEvents.Notify(Self, aevDeviceLost, 0);
     NotifiedLost:= True;
    end;

   // can the device be restored?
   Res:= FDev9.TestCooperativeLevel();

   // try to restore the device
   if (Res = D3DERR_DEVICENOTRESET) then
    begin
     Res:= FDev9.Reset(FParams);
     if (Succeeded(Res))and(NotifiedLost) then
      begin
       FEvents.Notify(Self, aevDeviceRecover, 0);
       if (Assigned(FOwner.PreloadEvent)) then FOwner.PreloadEvent(Self);
       NotifiedLost:= False;
      end;
    end;
  end;

 // (4) Driver error? try resetting...
 if (Res = D3DERR_DRIVERINTERNALERROR) then
  begin
   Res:= FDev9.Reset(FParams);
   // if cannot reset the device - we're done, finalize the device
   if (Failed(Res)) then Finalize();
  end;

 // (5) Verify the result.
 Result:= Succeeded(Res);
end;

//---------------------------------------------------------------------------
procedure TAsphyreDevice.Clear(Color: Cardinal; DepthValue: Real;
 StencilValue: Cardinal);
var
 Flags: Cardinal;
begin
 Assert(FInitialized, msgNotInitialized);

 Flags:= D3DCLEAR_TARGET;

 if (UsingDepthBuf) then
  begin
   Flags:= Flags or D3DCLEAR_ZBUFFER;
   if (UsingStencil) then Flags:= Flags or D3DCLEAR_STENCIL;
  end;

 FDev9.Clear(0, nil, Flags, Color, DepthValue, StencilValue);
end;

//---------------------------------------------------------------------------
procedure TAsphyreDevice.BeginScene();
begin
 Assert(FInitialized, msgNotInitialized);

 if (Succeeded(FDev9.BeginScene())) then
  FEvents.Notify(Self, aevBeginScene, 0);
end;

//---------------------------------------------------------------------------
procedure TAsphyreDevice.EndScene();
begin
 Assert(FInitialized, msgNotInitialized);

 Events.Notify(Self, aevEndScene, 0);
 FDev9.EndScene();
end;

//---------------------------------------------------------------------------
procedure TAsphyreDevice.DrawOnSurf(ImageIndex: Integer;
 Event: TDeviceTagEvent; Tag: TObject; Bkgrnd: Cardinal; DepthValue: Real;
 StencilValue: Cardinal);
var
 Image: TAsphyreSurface;
begin
 Image:= TAsphyreSurface(Images[ImageIndex]);
 if (Image = nil)or(Image.RenderTarget = nil) then Exit;

 if (not Image.RenderTarget.BeginDraw()) then Exit;

 Clear(Bkgrnd, DepthValue, StencilValue);
 BeginScene();

 Event(Self, Tag);
 EndScene();

 Image.RenderTarget.EndDraw();
end;

//---------------------------------------------------------------------------
procedure TAsphyreDevice.DrawOnSurf(ImageIndex: Integer;
 Event: TDeviceTagEvent; Tag: TObject; Bkgrnd: Cardinal);
begin
 DrawOnSurf(ImageIndex, Event, Tag, Bkgrnd, 1.0, 0);
end;

//---------------------------------------------------------------------------
procedure TAsphyreDevice.DrawOnSurf(ImageIndex: Integer;
 Event: TDeviceTagEvent; Tag: TObject);
var
 Image: TAsphyreSurface;
begin
 Image:= TAsphyreSurface(Images[ImageIndex]);
 if (Image = nil)or(Image.RenderTarget = nil) then Exit;

 if (not Image.RenderTarget.BeginDraw()) then Exit;

 BeginScene();

 Event(Self, Tag);
 EndScene();

 Image.RenderTarget.EndDraw();
end;

//---------------------------------------------------------------------------
procedure TAsphyreDevice.DrawOnSurf(const SurfName: string;
 Event: TDeviceTagEvent; Tag: TObject; Bkgrnd: Cardinal; DepthValue: Real;
 StencilValue: Cardinal);
var
 ImageIndex: Integer;
begin
 ImageIndex:= Images.ResolveImage(SurfName);
 if (ImageIndex <> -1) then DrawOnSurf(ImageIndex, Event, Tag, Bkgrnd,
  DepthValue, StencilValue);
end;

//---------------------------------------------------------------------------
procedure TAsphyreDevice.DrawOnSurf(const SurfName: string;
 Event: TDeviceTagEvent; Tag: TObject; Bkgrnd: Cardinal);
var
 ImageIndex: Integer;
begin
 ImageIndex:= Images.ResolveImage(SurfName);
 if (ImageIndex <> -1) then DrawOnSurf(ImageIndex, Event, Tag, Bkgrnd,
  1.0, 0);
end;

//---------------------------------------------------------------------------
procedure TAsphyreDevice.DrawOnSurf(const SurfName: string;
 Event: TDeviceTagEvent; Tag: TObject);
var
 ImageIndex: Integer;
begin
 ImageIndex:= Images.ResolveImage(SurfName);
 if (ImageIndex <> -1) then DrawOnSurf(ImageIndex, Event, Tag);
end;

//---------------------------------------------------------------------------
function TAsphyreDevice.ChangeParams(NewWidth, NewHeight: Integer;
 Windowed: Boolean): Boolean;
begin
 Assert(FInitialized, msgNotInitialized);

 FEvents.Notify(Self, aevDeviceLost, 0);

 FParams.BackBufferWidth := NewWidth;
 FParams.BackBufferHeight:= NewHeight;
 FParams.Windowed        := Windowed;

 // try resetting the device
 Result:= Succeeded(FDev9.Reset(FParams));
 if (Result) then
  begin
   Events.Notify(Self, aevDeviceRecover, 0);
   if (Assigned(FOwner.PreloadEvent)) then FOwner.PreloadEvent(Self);
  end;
end;

//---------------------------------------------------------------------------
constructor TAsphyreDevices.Create();
begin
 inherited;

 FDriver:= Direct3DCreate9(D3D_SDK_VERSION);
 Assert(FDriver <> nil, msgDriverCreateFail);
end;

//---------------------------------------------------------------------------
destructor TAsphyreDevices.Destroy();
begin
 RemoveAll();

 if (FDriver <> nil) then FDriver:= nil;

 inherited;
end;

//---------------------------------------------------------------------------
function TAsphyreDevices.GetCount(): Integer;
begin
 Result:= Length(Data);
end;

//---------------------------------------------------------------------------
procedure TAsphyreDevices.SetCount(const Value: Integer);
begin
 while (Length(Data) > Value)and(Length(Data) > 0) do
  Remove(Length(Data) - 1);

 while (Length(Data) < Value) do Insert();

 if (Length(Data) > 0) then DefDevice:= Data[0] else DefDevice:= nil;
end;

//---------------------------------------------------------------------------
function TAsphyreDevices.GetDevice(Num: Integer): TAsphyreDevice;
begin
 Assert((Num >= 0)and(Num < Length(Data)), msgDeviceIndexFail);
 Result:= Data[Num];
end;

//---------------------------------------------------------------------------
function TAsphyreDevices.Insert(): Integer;
var
 Index: Integer;
begin
 Index:= Length(Data);
 SetLength(Data, Index + 1);

 Data[Index]:= TAsphyreDevice.Create(Self, Index);
 Result:= Index;
end;

//---------------------------------------------------------------------------
procedure TAsphyreDevices.Remove(Num: Integer);
var
 i: Integer;
begin
 Assert((Num >= 0)and(Num < Length(Data)), msgDeviceIndexFail);

 Data[Num].Free();

 for i:= Num to Length(Data) - 2 do
  Data[i]:= Data[i + 1];

 SetLength(Data, Length(Data) - 1);
end;

//---------------------------------------------------------------------------
procedure TAsphyreDevices.RemoveAll();
var
 i: Integer;
begin
 for i:= 0 to Length(Data) - 1 do
  Data[i].Free();

 SetLength(Data, 0);
end;

//---------------------------------------------------------------------------
function TAsphyreDevices.GetDisplayCount(): Integer;
begin
 Result:= FDriver.GetAdapterCount();
end;

//---------------------------------------------------------------------------
function TAsphyreDevices.GetDisplayInfo(Num: Integer): TDisplayInfo;
var
 Identifier: TD3DAdapterIdentifier9;
begin
 Assert((Num >= 0)and(Num < GetDisplayCount()), msgDisplayIndexFail);

 if (Failed(FDriver.GetAdapterIdentifier(Num, 0, Identifier))) then
  begin
   FillChar(Result, SizeOf(TDisplayInfo), 0);
   Exit;
  end;

 Result.Adapter        := Num; 
 Result.Driver         := Identifier.Driver;
 Result.Description    := Identifier.Description;
 Result.DeviceName     := Identifier.DeviceName;
 Result.DriverVersionLo:= Identifier.DriverVersion and $FFFFFFFF;
 Result.DriverVersionHi:= Identifier.DriverVersion shr 32;
 Result.VendorID       := Identifier.VendorId;
 Result.DeviceID       := Identifier.DeviceId;
 Result.SubSysID       := Identifier.SubSysId;
 Result.Revision       := Identifier.Revision;
 Result.DeviceGuid     := Identifier.DeviceIdentifier;
end;

//---------------------------------------------------------------------------
function TAsphyreDevices.Initialize(CfgEvent: TScreenConfigEvent;
 Tag: TObject): Boolean;
var
 i: Integer;
begin
 Result:= False;

 for i:= 0 to Length(Data) - 1 do
  if (not Data[i].Initialized) then
   begin
    Result:= Data[i].Initialize(CfgEvent, Tag);
    if (not Result) then Break;
   end;
end;

//---------------------------------------------------------------------------
function TAsphyreDevices.InitializeEx(Event: TScreenConfigExEvent;
 Tag: TObject): Boolean;
var
 i: Integer;
begin
 Result:= False;

 for i:= 0 to Length(Data) - 1 do
  if (not Data[i].Initialized) then
   begin
    Result:= Data[i].InitializeEx(Event, Tag);
    if (not Result) then Break;
   end;
end;

//---------------------------------------------------------------------------
procedure TAsphyreDevices.Finalize();
var
 i: Integer;
begin
 for i:= 0 to Length(Data) - 1 do
  if (Data[i].Initialized) then Data[i].Finalize();
end;

//---------------------------------------------------------------------------
initialization
 Devices:= TAsphyreDevices.Create();
 Devices.Count:= 1;

//---------------------------------------------------------------------------
finalization
 Devices.Free();
 Devices:= nil;

//---------------------------------------------------------------------------
end.
