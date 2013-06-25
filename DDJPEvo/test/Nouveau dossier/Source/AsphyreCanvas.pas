unit AsphyreCanvas;
//---------------------------------------------------------------------------
// AsphyreCanvas.pas                                    Modified: 24-Jan-2007
// Hardware-accelerated 2D implementation                        Version 2.01
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
// The Original Code is AsphyreCanvas.pas.
//
// The Initial Developer of the Original Code is M. Sc. Yuriy Kotsarenko.
// Portions created by M. Sc. Yuriy Kotsarenko are Copyright (C) 2007,
// Afterwarp Interactive. All Rights Reserved.
//---------------------------------------------------------------------------
interface

//---------------------------------------------------------------------------
uses
 Windows, Direct3D9, D3DX9, Types, AsphyreAsserts, AsphyreEvents,
 AsphyreEffects, Vectors2, AsphyreDef, TrueColors, AsphyreTextures,
 AsphyreImages, AsphyrePalettes
 {$IFDEF DebugMode}, AsphyreDebug{$ENDIF};

//---------------------------------------------------------------------------
// The following options control the way how primitives are rendered.
// Generally, there are two ways to render a single primitive:
//   a) Using lists of triangles that are cached together
//   b) Using triangle strips or fans individually
//
// Although the second option reduces the bandwidth usage by producing
// considerably less vertices (and may not need indexes at all), it is
// generally much slower because of Direct3D overhead.
//
// Therefore, the ideal would be using option a) and drawing everything in
// groups of similar primitives, e.g.: first draw all rectangles, then all
// images with the same index/pattern, then all text, etc.
//
// However, grouping similar primitives may not be possible in some cases,
// such as when drawing GUI that need to be "layered".
//
// The options below specify how individual primitive is rendered. Enable
// each one of the option to use the option b) for rendering primitives, by
// removing the dot before "$DEFINE". If you want to use option a) for
// rendering, then disable the declaration by adding dot to the define,
// thus effectively disabling it, e.g.:
//  {.$DEFINE FillTriUncached} -> use option a) for drawing filled triangles.
//  {$DEFINE FillTriUncached}  -> use option b) for drawing filled triangles.
//---------------------------------------------------------------------------

{.$DEFINE FillTriUncached}
{.$DEFINE FillQuadUncached}
{.$DEFINE FillQuadExUncached}
{.$DEFINE FillArcUncached}
{.$DEFINE FillRibbonUncached}
{.$DEFINE FrameRibbonUncached}
{.$DEFINE TexMapUncached}
{.$DEFINE TexTriUncached}

//---------------------------------------------------------------------------
type
 TDrawingMode = (dmUnspecified, dmPointList, dmLineList, dmLineStrip,
  dmTriangleList, dmTriangleStrip, dmTriangleFan);

//---------------------------------------------------------------------------
 TAsphyreCanvas = class
 private
  FOwnerDevice: TObject;
  FInitialized: Boolean;
  FVertexCache: Integer;
  FIndexCache : Integer;
  BuffersLost : Boolean;

  VertexBuffer: IDirect3DVertexBuffer9;
  IndexBuffer : IDirect3DIndexBuffer9;
  LineDriver  : ID3DXLine;

  VertexArray : Pointer;
  IndexArray  : Pointer;

  FDrawingMode: TDrawingMode;
  FIndexedMode: Boolean;
  FVertexCount: Integer;
  FIndexCount : Integer;
  FPrimitives : Integer;
  FCacheStall : Integer;
  FResetEvent : TDeviceNotifyEvent;
  FDithering  : Boolean;
  FAntialias  : Boolean;
  FAlphaTest  : Boolean;
  CachedDrawFx: Integer;
  CachedTex   : TAsphyreCustomTexture;
  ActiveTex   : TAsphyreCustomTexture;
  QuadMapping : TPoint4;

  procedure SetVertexCache(const Value: Integer);
  procedure SetIndexCache(const Value: Integer);
  procedure SetAntialias(const Value: Boolean);
  procedure SetDithering(const Value: Boolean);
  function GetLineAntialias(): Boolean;
  function GetLineWidth(): Real;
  procedure SetLineAntialias(const Value: Boolean);
  procedure SetLineWidth(const Value: Real);
  function CreateVertexBuffer(): Boolean;
  function CreateIndexBuffer(): Boolean;
  procedure PrepareVertexArray();
  function AllocateBuffers(): Boolean;
  procedure ReleaseBuffers();
  function GetClipRect(): TRect;
  procedure SetClipRect(const Value: TRect);
 protected
  AfterFlush: Boolean;

  function Initialize(): Boolean; virtual;
  function Finalize(): Boolean; virtual;
  function UploadVertexBuffer(): Boolean; virtual;
  function UploadIndexBuffer(): Boolean; virtual;
  function PrepareDraw(): Boolean; virtual;
  function BufferDraw(): Boolean; virtual;
  procedure ResetCache(); virtual;
  procedure DeviceReset(); virtual;
  procedure EventCallback(Sender: TObject; EventNo, EventRef: Integer;
   var Success: Boolean); virtual;
  function NextVertexEntry(): Pointer;
  procedure AddIndexEntry(Index: Integer);
  procedure RequestCache(Mode: TDrawingMode; Indexed: Boolean; Vertices,
   Indices, DrawFx: Integer; ReqTex: TAsphyreCustomTexture); virtual;
 public
  // This property should always point to a valid and active TAsphyreDevice.
  property OwnerDevice: TObject read FOwnerDevice;

  // Indicates whether the canvas has been initialized properly.
  property Initialized: Boolean read FInitialized;

  // The following properties indicate the current type of buffer cache.
  property DrawingMode: TDrawingMode read FDrawingMode;
  property IndexedMode: Boolean read FIndexedMode;

  // The following properties indicate the current status of buffer cache.
  property VertexCache: Integer read FVertexCache write SetVertexCache;
  property IndexCache : Integer read FIndexCache write SetIndexCache;
  property VertexCount: Integer read FVertexCount;
  property IndexCount : Integer read FIndexCount;
  property Primitives : Integer read FPrimitives;

  // Whether the image should be antialiased while rendering.
  property Antialias: Boolean read FAntialias write SetAntialias;

  // Whether the image should be dithered, when rendered on lower-quality
  // surface.
  property Dithering: Boolean read FDithering write SetDithering;

  // Enable this option to discard the pixels with alpha = 0. This can
  // improve the performance slightly when drawing many transparent sprites. 
  property AlphaTest: Boolean read FAlphaTest write FAlphaTest;

  // The clipping rectangle used for rendering. Nothing will be visible
  // outside of this rectangle.
  property ClipRect: TRect read GetClipRect write SetClipRect;

  // Parameters that indicate the appearance of lines when drawing them
  // using methods ending with "Ex", e.g. LineEx().
  property LineWidth    : Real read GetLineWidth write SetLineWidth;
  property LineAntialias: Boolean read GetLineAntialias write SetLineAntialias;

  // Indicates how many times the buffer has been flushed out inside current
  // scene block.
  property CacheStall: Integer read FCacheStall;

  // This event is called when you start working with canvas. It can be used
  // to insert additional state changes before drawing anything.
  property ResetEvent: TDeviceNotifyEvent read FResetEvent write FResetEvent;

  // Flushes the buffer cache. 
  procedure Flush(); virtual;

  // Pixel drawing routines.
  procedure PutPixel(const Point: TPoint2; Color: Cardinal;
   DrawFx: Integer); overload;
  procedure PutPixel(x, y: Single; Color: Cardinal; DrawFx: Integer); overload;

  // Line drawing routines which support antialiased lines with custom width.
  procedure LineEx(const Src, Dest: TPoint2; Color: Cardinal); overload;
  procedure LineEx(x1, y1, x2, y2: Single; Color: Cardinal); overload;
  procedure LineEx(const Src, Dest: TPoint; Color: Cardinal); overload;

  // Hardware line drawing routines. These are much faster than LineEx,
  // but they are not always antialiased and you can't change their width.
  procedure LineHw(const Src, Dest: TPoint2; Color0, Color1: Cardinal;
   DrawFx: Integer); overload;
  procedure LineHw(x1, y1, x2, y2: Single; Color0, Color1: Cardinal;
   DrawFx: Integer); overload;
  procedure LineHw(const Src, Dest: TPoint; Color0, Color1: Cardinal;
   DrawFx: Integer); overload;

  // The following routines draw antialiased lines in fixed width. They
  // are useful if you need to interpolate the color between two vertices.
  // These routines use PutPixel to draw the line and may be considerably
  // slower than other alternatives.
  procedure WuLine(Src, Dest: TPoint2; Color0, Color1: Cardinal;
   DrawFx: Integer); overload;
  procedure WuLine(x1, y1, x2, y2: Single; Color1, Color2: Cardinal;
   DrawFx: Integer); overload;

  // These routines render filled triangles.
  procedure FillTri(const p1, p2, p3: TPoint2; c1, c2, c3: Cardinal;
   DrawFx: Integer); overload;
  procedure FillTri(x1, y1, x2, y2, x3, y3: Single; c1, c2, c3: Cardinal;
   DrawFx: Integer); overload;

  // This routine renders filled quad.
  procedure FillQuad(const Points: TPoint4; const Colors: TColor4;
   DrawFx: Integer);

  // This does the same job as FillQuad(), but uses subdivision to provide
  // better gradient-filling precision. It draws 6 triangles instead of 2.
  procedure FillQuadEx(const Points: TPoint4; const Colors: TColor4;
   DrawFx: Integer);

  // Draws lines along the specified 4 corners to complete a rectangle.
  // This uses hardware lines (e.g. LineHw). 
  procedure WireQuadHw(const Points: TPoint4; const Colors: TColor4;
   DrawFx: Integer);

  // Draws lines across four specified points using LineEx() approach. 
  procedure WireQuadEx(const Points: TPoint4; Color: Cardinal);

  // The following functions call FillQuad() to render filled rectangles. 
  procedure FillRect(const Rect: TRect; const Colors: TColor4;
   DrawFx: Integer); overload;
  procedure FillRect(const Rect: TRect; Color: Cardinal;
   DrawFx: Integer); overload;
  procedure FillRect(Left, Top, Width, Height: Integer; Color: Cardinal;
   DrawFx: Integer); overload;

  // The following routines draw rectangles using WireQuadHw.
  procedure FrameRect(const Rect: TRect; const Colors: TColor4;
   DrawFx: Integer); overload;
  procedure FrameRect(const Rect: TRect; Color: Cardinal;
   DrawFx: Integer); overload;
  procedure FrameRect(Left, Top, Width, Height: Integer; Color: Cardinal;
   DrawFx: Integer); overload;

  // Draws a filled arc.
  procedure FillArc(x, y, RadiusX, RadiusY, InitPhi, EndPhi: Single;
   Steps: Integer; const Colors: TColor4; DrawFx: Integer);

  // The following routines draw filled ellipses and circles. 
  procedure FillEllipse(x, y, RadiusX, RadiusY: Single; Steps: Integer;
   const Colors: TColor4; DrawFx: Integer);
  procedure FillCircle(x, y, Radius: Single; Steps: Integer;
   const Colors: TColor4; DrawFx: Integer); overload;

  // The following routines draw ellipses and circles using LineEx routines.
  procedure Ellipse(x, y, RadiusX, RadiusY: Single; Steps: Integer;
   Color: Cardinal);
  procedure Circle(x, y, Radius: Single; Steps: Integer; Color: Cardinal);

  // The following routines draw a filled-ribbon, which is an arc with a
  // hole inside it.
  procedure FillRibbon(x, y, InRadiusX, InRadiusY, OutRadiusX, OutRadiusY,
   InitPhi, EndPhi: single; Steps: Integer; const Colors: TColor4;
   DrawFx: Integer); overload;
  procedure FillRibbon(x, y, InRadiusX, InRadiusY, OutRadiusX, OutRadiusY,
   InitPhi, EndPhi: Single; Steps: Integer; Palette: TAsphyrePalette;
   DrawFx: Integer); overload;

  // The following routines draw a border made of lines for the ribbon,
  // which is drawn with the above FillRibbon routines.
  procedure FrameRibbonHw(x, y, InRadiusX, InRadiusY, OutRadiusX, OutRadiusY,
   InitPhi, EndPhi: Single; Steps: Integer; Color: Cardinal;
   DrawFx: Integer);
  procedure FrameRibbonEx(x, y, InRadiusX, InRadiusY, OutRadiusX, OutRadiusY,
   InitPhi, EndPhi: Single; Steps: Integer; Color: Cardinal);

  // Specify texture coordinates for rendering textured quads.
  procedure UseImage(Image: TAsphyreCustomImage;
   const Mapping: TPoint4); overload;
  procedure UseImage(Image: TAsphyreCustomImage;
   const Mapping: TPoint4px); overload;
  procedure UseImage(Image: TAsphyreCustomImage; Pattern: Integer); overload;
  procedure UseImage(Image: TAsphyreCustomImage; Pattern, SrcX, SrcY,
   SrcWidth, SrcHeight: Integer; Mirror, Flip: Boolean); overload;
  procedure UseImage(Image: TAsphyreCustomImage; TexNum: Integer;
   const Mapping: TPoint4); overload;

  // Renders the textured quad.
  procedure TexMap(const Points: TPoint4; const Colors: TColor4;
   DrawFx: Integer);

  // Specify texture coordinates for rendering textured triangles.
  procedure UseImageTri(Image: TAsphyreCustomImage; const tx0, tx1,
   tx2: TPoint2); overload;
  procedure UseImageTri(Image: TAsphyreCustomImage; const tx0, tx1,
   tx2: TPoint); overload;

  // Renders the textured triangle.
  procedure TexTri(const p1, p2, p3: TPoint2; c1, c2, c3: Cardinal;
   DrawFx: Integer);

  constructor Create(AOwnerDevice: TObject);
  destructor Destroy(); override;
 end;

//---------------------------------------------------------------------------
implementation

//---------------------------------------------------------------------------
uses
 AsphyreDevices;

const
 VertexType = D3DFVF_XYZRHW or D3DFVF_DIFFUSE or D3DFVF_TEX1;

//--------------------------------------------------------------------------
type
 PVertexRecord = ^TVertexRecord;
 TVertexRecord = record
  Vertex: TD3DVector;
  rhw   : Single;
  Color : Longword;
  u, v  : Single;
 end;

//--------------------------------------------------------------------------
constructor TAsphyreCanvas.Create(AOwnerDevice: TObject);
begin
 inherited Create();

 Assert((AOwnerDevice <> nil)and(AOwnerDevice is TAsphyreDevice),
  msgNoDeviceOwner);

 FOwnerDevice:= AOwnerDevice;
 TAsphyreDevice(FOwnerDevice).Events.Include(EventCallback);

 FInitialized:= False;
 FVertexCache:= 8192;
 FIndexCache := 8192;
 BuffersLost := False;
 FAntialias  := True;
 FDithering  := False;
 FAlphaTest  := True;
end;

//--------------------------------------------------------------------------
destructor TAsphyreCanvas.Destroy();
begin
 if (FInitialized) then Finalize();

 TAsphyreDevice(FOwnerDevice).Events.Exclude(EventCallback);

 inherited;
end;

//---------------------------------------------------------------------------
procedure TAsphyreCanvas.SetVertexCache(const Value: Integer);
begin
 if (not FInitialized) then
  begin
   FVertexCache:= Value;

   if (FVertexCache and $03 > 0) then
    Inc(FVertexCache, 4 - (FVertexCache and $03));

   if (FVertexCache < 512) then FVertexCache:= 512;
   if (FVertexCache > $10000) then FVertexCache:= $10000;
  end;
end;

//---------------------------------------------------------------------------
procedure TAsphyreCanvas.SetIndexCache(const Value: Integer);
begin
 if (not FInitialized) then
  begin
   FIndexCache:= Value;

   if (FIndexCache and $03 > 0) then
    Inc(FIndexCache, 4 - (FIndexCache and $03));

   if (FIndexCache < 512) then FIndexCache:= 512;
   if (FIndexCache > $10000) then FIndexCache:= $10000;
  end;
end;

//---------------------------------------------------------------------------
procedure TAsphyreCanvas.SetAntialias(const Value: Boolean);
begin
 FAntialias:= Value;

 if (FInitialized) then
  begin
   ResetCache();

   with TAsphyreDevice(FOwnerDevice).Dev9 do
    if (FAntialias) then
     begin
      SetSamplerState(0, D3DSAMP_MAGFILTER, D3DTEXF_LINEAR);
      SetSamplerState(0, D3DSAMP_MINFILTER, D3DTEXF_LINEAR);
     end else
     begin
      SetSamplerState(0, D3DSAMP_MAGFILTER, D3DTEXF_POINT);
      SetSamplerState(0, D3DSAMP_MINFILTER, D3DTEXF_POINT);
     end;
  end;
end;

//---------------------------------------------------------------------------
procedure TAsphyreCanvas.SetDithering(const Value: Boolean);
begin
 FDithering:= Value;

 if (FInitialized) then
  begin
   ResetCache();
   TAsphyreDevice(FOwnerDevice).Dev9.SetRenderState(D3DRS_DITHERENABLE,
    Cardinal(FDithering));
  end;
end;

//---------------------------------------------------------------------------
function TAsphyreCanvas.GetLineAntialias(): Boolean;
begin
 Assert(FInitialized, msgNotInitialized);

 Result:= LineDriver.GetAntialias();
end;

//---------------------------------------------------------------------------
procedure TAsphyreCanvas.SetLineAntialias(const Value: Boolean);
begin
 Assert(FInitialized, msgNotInitialized);

 LineDriver.SetAntialias(Value);
end;

//---------------------------------------------------------------------------
function TAsphyreCanvas.GetLineWidth(): Real;
begin
 Result:= LineDriver.GetWidth();
end;

//---------------------------------------------------------------------------
procedure TAsphyreCanvas.SetLineWidth(const Value: Real);
begin
 Assert(FInitialized, msgNotInitialized);

 LineDriver.SetWidth(Value);
end;

//--------------------------------------------------------------------------
function TAsphyreCanvas.CreateVertexBuffer(): Boolean;
begin
 Result:= Succeeded(TAsphyreDevice(FOwnerDevice).Dev9.CreateVertexBuffer(FVertexCache *
  SizeOf(TVertexRecord), D3DUSAGE_WRITEONLY or D3DUSAGE_DYNAMIC, VertexType,
  D3DPOOL_DEFAULT, VertexBuffer, nil));
end;

//--------------------------------------------------------------------------
function TAsphyreCanvas.CreateIndexBuffer(): Boolean;
begin
 Result:= Succeeded(TAsphyreDevice(FOwnerDevice).Dev9.CreateIndexBuffer(FIndexCache *
  SizeOf(Word), D3DUSAGE_WRITEONLY or D3DUSAGE_DYNAMIC, D3DFMT_INDEX16,
  D3DPOOL_DEFAULT, IndexBuffer, nil));
end;

//---------------------------------------------------------------------------
function TAsphyreCanvas.AllocateBuffers(): Boolean;
begin
 Result:= CreateVertexBuffer();
 if (Result) then Result:= CreateIndexBuffer();

 FDrawingMode:= dmUnspecified;
 FIndexedMode:= False;
 FVertexCount:= 0;
 FIndexCount := 0;
 FPrimitives := 0;

 CachedDrawFx:= fxUndefined;
 CachedTex   := nil;
 ActiveTex   := nil;
end;

//---------------------------------------------------------------------------
procedure TAsphyreCanvas.PrepareVertexArray();
var
 Entry: PVertexRecord;
 Index: Integer;
begin
 Entry:= VertexArray;
 for Index:= 0 to FVertexCache - 1 do
  begin
   FillChar(Entry^, SizeOf(TVertexRecord), 0);

   Entry.Vertex.z:= 0.0;
   Entry.rhw     := 1.0;

   Inc(Entry);
  end;
end;

//---------------------------------------------------------------------------
function TAsphyreCanvas.Initialize(): Boolean;
begin
 Result:= not Initialized;

 if (Result) then
  Result:= AllocateBuffers();

 if (Result) then
  begin
   Result:= Succeeded(D3DXCreateLine(TAsphyreDevice(FOwnerDevice).Dev9,
    LineDriver));
   if (not Result) then ReleaseBuffers() else LineDriver.SetAntialias(True);
  end;

 if (Result) then
  begin
   VertexArray:= AllocMem(FVertexCache * SizeOf(TVertexRecord));
   IndexArray := AllocMem(FIndexCache * SizeOf(Word));
   PrepareVertexArray();
  end;

 AfterFlush  := True;
 FInitialized:= Result;
end;

//---------------------------------------------------------------------------
procedure TAsphyreCanvas.ReleaseBuffers();
begin
 if (IndexBuffer <> nil) then IndexBuffer:= nil;
 if (VertexBuffer <> nil) then VertexBuffer:= nil;
end;

//---------------------------------------------------------------------------
function TAsphyreCanvas.Finalize(): Boolean;
begin
 if (LineDriver <> nil) then LineDriver:= nil;
 
 ReleaseBuffers();

 if (VertexArray <> nil) then
  begin
   FreeMem(VertexArray);
   VertexArray:= nil;
  end;

 if (IndexArray <> nil) then
  begin
   FreeMem(IndexArray);
   IndexArray:= nil;
  end;

 Result:= True;
 FInitialized:= False;
end;

//---------------------------------------------------------------------------
function TAsphyreCanvas.UploadVertexBuffer(): Boolean;
var
 MemAddr: Pointer;
 BufSize: Integer;
begin
 BufSize:= FVertexCount * SizeOf(TVertexRecord);
 Result:= Succeeded(VertexBuffer.Lock(0, BufSize, MemAddr, D3DLOCK_DISCARD));

 if (Result) then
  begin
   Move(VertexArray^, MemAddr^, BufSize);
   Result:= Succeeded(VertexBuffer.Unlock());
  end;
end;

//---------------------------------------------------------------------------
function TAsphyreCanvas.UploadIndexBuffer(): Boolean;
var
 MemAddr: Pointer;
 BufSize: Integer;
begin
 BufSize:= FIndexCount * SizeOf(Word);
 Result:= Succeeded(IndexBuffer.Lock(0, BufSize, MemAddr, D3DLOCK_DISCARD));

 if (Result) then
  begin
   Move(IndexArray^, MemAddr^, BufSize);
   Result:= Succeeded(IndexBuffer.Unlock());
  end;
end;

//---------------------------------------------------------------------------
function TAsphyreCanvas.PrepareDraw(): Boolean;
begin
 with TAsphyreDevice(FOwnerDevice).Dev9 do
  begin
   // (1) Use our vertex buffer for displaying primitives.
   Result:= Succeeded(SetStreamSource(0, VertexBuffer, 0,
    SizeOf(TVertexRecord)));

   // (2) Use our index buffer to indicate the vertices of our primitives.
   if (FIndexedMode)and(Result) then
    Result:= Succeeded(SetIndices(IndexBuffer));

   // (3) Disable vertex shader.
   if (Result) then
    Result:= Succeeded(SetVertexShader(nil));

   // (4) Set the flexible vertex format of our vertex buffer.
   if (Result) then
    Result:= Succeeded(SetFVF(VertexType));
  end;
end;

//---------------------------------------------------------------------------
function TAsphyreCanvas.BufferDraw(): Boolean;
var
 Primitive: TD3DPrimitiveType;
begin
 // (1) Determine primitive type.
 Primitive:= D3DPT_TRIANGLELIST;
 case FDrawingMode of
  dmPointList    : Primitive:= D3DPT_POINTLIST;
  dmLineList     : Primitive:= D3DPT_LINELIST;
  dmLineStrip    : Primitive:= D3DPT_LINESTRIP;
  dmTriangleStrip: Primitive:= D3DPT_TRIANGLESTRIP;
  dmTriangleFan  : Primitive:= D3DPT_TRIANGLEFAN;
 end;

 // (2) Render uploaded primitives.
 with TAsphyreDevice(FOwnerDevice).Dev9 do
  if (FIndexedMode) then
   begin
    Result:= Succeeded(DrawIndexedPrimitive(Primitive, 0, 0, FVertexCount, 0,
     FPrimitives));
   end else
   begin
    Result:= Succeeded(DrawPrimitive(Primitive, 0, FPrimitives));
   end;
end;

//---------------------------------------------------------------------------
procedure TAsphyreCanvas.ResetCache();
begin
 // (1) Flush the cache, if needed.
 if (FVertexCount > 0)and(FPrimitives > 0)and(not BuffersLost) then
  begin
   if (UploadVertexBuffer())and(UploadIndexBuffer())and(PrepareDraw()) then
    BufferDraw();

   Inc(FCacheStall);
  end;

 // (2) Reset buffer info.
 FVertexCount:= 0;
 FIndexCount := 0;
 FPrimitives := 0;
 FDrawingMode:= dmUnspecified;
end;

//---------------------------------------------------------------------------
procedure TAsphyreCanvas.DeviceReset();
var
 i: Integer;
begin
 FVertexCount:= 0;
 FIndexCount := 0;
 FPrimitives := 0;
 FDrawingMode:= dmUnspecified;

 CachedDrawFx:= fxUndefined;
 CachedTex   := nil;
 ActiveTex   := nil;

 with TAsphyreDevice(FOwnerDevice).Dev9 do
  begin
   //========================================================================
   // In the following code, we try to disable any Direct3D states that might
   // affect or disrupt our behavior.
   //========================================================================
   SetRenderState(D3DRS_LIGHTING,  iFalse);
   SetRenderState(D3DRS_CULLMODE,  D3DCULL_NONE);
   SetRenderState(D3DRS_ZENABLE,   D3DZB_FALSE);
   SetRenderState(D3DRS_FOGENABLE, iFalse);

   SetRenderState(D3DRS_ANTIALIASEDLINEENABLE, iTrue);

   SetRenderState(D3DRS_ALPHAFUNC, D3DCMP_GREATEREQUAL);
   SetRenderState(D3DRS_ALPHAREF, $00000001);
   SetRenderState(D3DRS_ALPHATESTENABLE, iFalse);

   for i:= 0 to 7 do
    begin
     SetTextureStageState(i, D3DTSS_TEXCOORDINDEX, 0);
     SetTextureStageState(i, D3DTSS_TEXTURETRANSFORMFLAGS, D3DTTFF_DISABLE);

     SetTexture(i, nil);

     SetTextureStageState(i, D3DTSS_COLORARG1, D3DTA_TEXTURE);
     SetTextureStageState(i, D3DTSS_ALPHAARG1, D3DTA_TEXTURE);

     SetTextureStageState(i, D3DTSS_COLORARG2, D3DTA_DIFFUSE);
     SetTextureStageState(i, D3DTSS_ALPHAARG2, D3DTA_DIFFUSE);
    end;

   //==========================================================================
   // Update user-specified states.
   //==========================================================================
   SetRenderState(D3DRS_DITHERENABLE, Cardinal(FDithering));

   if (FAntialias) then
    begin
     SetSamplerState(0, D3DSAMP_MAGFILTER, D3DTEXF_LINEAR);
     SetSamplerState(0, D3DSAMP_MINFILTER, D3DTEXF_LINEAR);
     end else
    begin
     SetSamplerState(0, D3DSAMP_MAGFILTER, D3DTEXF_POINT);
     SetSamplerState(0, D3DSAMP_MINFILTER, D3DTEXF_POINT);
    end;
  end;

 if (Assigned(ResetEvent)) then
  ResetEvent(Self, TAsphyreDevice(FOwnerDevice).Dev9);

 AfterFlush := False;
 FCacheStall:= 0;
end;

//---------------------------------------------------------------------------
procedure TAsphyreCanvas.EventCallback(Sender: TObject; EventNo,
 EventRef: Integer; var Success: Boolean);
begin
 case EventNo of
  aevInitialize:
   Success:= Initialize();

  aevFinalize:
   Success:= Finalize();

  aevDeviceLost:
   if (FInitialized) then
    begin
     ReleaseBuffers();
     LineDriver.OnLostDevice();
     BuffersLost:= True;
    end;

  aevDeviceRecover:
   if (FInitialized) then
    begin
     if (not AllocateBuffers()) then Finalize();
     if (Failed(LineDriver.OnResetDevice())) then Finalize();
     BuffersLost:= False;
    end;

  aevEndScene, aevMultiCanvasIni, aevDrawFlush:
   Flush();
 end;
end;

//---------------------------------------------------------------------------
procedure TAsphyreCanvas.Flush();
begin
 if (FInitialized) then
  begin
   ResetCache();
   AfterFlush:= True;
  end;
end;

//---------------------------------------------------------------------------
function TAsphyreCanvas.GetClipRect(): TRect;
var
 vp: TD3DViewport9;
begin
 FillChar(vp, SizeOf(vp), 0);
 TAsphyreDevice(FOwnerDevice).Dev9.GetViewport(vp);

 Result.Left  := vp.X;
 Result.Top   := vp.Y;
 Result.Right := vp.X + vp.Width;
 Result.Bottom:= vp.Y + vp.Height;
end;

//---------------------------------------------------------------------------
procedure TAsphyreCanvas.SetClipRect(const Value: TRect);
var
 vp: TD3DViewport9;
begin
 if (FInitialized) then
  begin
   ResetCache();

   vp.X:= Value.Left;
   vp.Y:= Value.Top;
   vp.Width := (Value.Right - Value.Left);
   vp.Height:= (Value.Bottom - Value.Top);
   vp.MinZ:= 0.0;
   vp.MaxZ:= 1.0;

   TAsphyreDevice(FOwnerDevice).Dev9.SetViewport(vp);
  end;
end;

//---------------------------------------------------------------------------
procedure TAsphyreCanvas.RequestCache(Mode: TDrawingMode; Indexed: Boolean;
 Vertices, Indices, DrawFx: Integer; ReqTex: TAsphyreCustomTexture);
var
 NeedReset: Boolean;
begin
 // (1) Reset device, if needed.
 if (AfterFlush) then DeviceReset();

 // (2) Check whether reset should be applied
 NeedReset:= (FVertexCount + Vertices > FVertexCache);
 NeedReset:= NeedReset or ((Indexed)and(FIndexCount + Indices > FIndexCache));
 NeedReset:= NeedReset or (FDrawingMode = dmUnspecified) or
  (FDrawingMode <> Mode) or (FIndexedMode <> Indexed);
 NeedReset:= NeedReset or (CachedDrawFx <> DrawFx) or (CachedTex <> ReqTex);

 // (3) Apply reset, if needed.
 if (NeedReset) then
  begin
   ResetCache();

   // Update currently active texture.
   if (FDrawingMode = dmUnspecified)or(CachedTex <> ReqTex) then
    with TAsphyreDevice(FOwnerDevice).Dev9 do
     begin
      if (ReqTex <> nil) then ReqTex.Activate(0) else SetTexture(0, nil);

     CachedTex:= ReqTex;
    end;

   // Update currently active effect.
   if (CachedDrawFx = fxUndefined)or(CachedDrawFx <> DrawFx) then
    EffectManager.HandleCode(Self, TAsphyreDevice(FOwnerDevice).Dev9, DrawFx);

   FIndexedMode:= Indexed;
   FDrawingMode:= Mode;
   CachedDrawFx:= DrawFx;
  end;
end;

//---------------------------------------------------------------------------
function TAsphyreCanvas.NextVertexEntry(): Pointer;
begin
 Result:= Pointer(Integer(VertexArray) + (FVertexCount * SizeOf(TVertexRecord)));
end;

//---------------------------------------------------------------------------
procedure TAsphyreCanvas.PutPixel(const Point: TPoint2; Color: Cardinal;
 DrawFx: Integer);
var
 Entry: PVertexRecord;
begin
 RequestCache(dmPointList, False, 1, 0, DrawFx, nil);

 Entry:= NextVertexEntry();
 Entry.Vertex.x:= Point.x;
 Entry.Vertex.y:= Point.y;
 Entry.Color   := Color;

 Inc(FVertexCount);
 Inc(FPrimitives);
end;

//---------------------------------------------------------------------------
procedure TAsphyreCanvas.PutPixel(x, y: Single; Color: Cardinal; DrawFx: Integer);
begin
 PutPixel(Point2(x, y), Color, DrawFx);
end;

//---------------------------------------------------------------------------
procedure TAsphyreCanvas.LineHw(const Src, Dest: TPoint2; Color0, Color1: Cardinal;
 DrawFx: Integer);
var
 Entry: PVertexRecord;
begin
 RequestCache(dmLineList, False, 2, 0, DrawFx, nil);

 // -> 1st point
 Entry:= NextVertexEntry();
 Entry.Vertex.x:= Src.x;
 Entry.Vertex.y:= Src.y;
 Entry.Color   := Color0;
 Inc(FVertexCount);
 // -> 2nd point
 Entry:= NextVertexEntry();
 Entry.Vertex.x:= Dest.x;
 Entry.Vertex.y:= Dest.y;
 Entry.Color   := Color1;
 Inc(FVertexCount);

 Inc(FPrimitives);
end;

//---------------------------------------------------------------------------
procedure TAsphyreCanvas.LineHw(x1, y1, x2, y2: Single; Color0, Color1: Cardinal;
 DrawFx: Integer);
begin
 LineHw(Point2(x1, y1), Point2(x2, y2), Color0, Color1, DrawFx);
end;

//---------------------------------------------------------------------------
procedure TAsphyreCanvas.LineHw(const Src, Dest: TPoint; Color0, Color1: Cardinal;
 DrawFx: Integer);
begin
 LineHw(Point2(Src.X, Src.Y), Point2(Dest.X, Dest.Y), Color0, Color1, DrawFx);
end;

//---------------------------------------------------------------------------
procedure TAsphyreCanvas.LineEx(const Src, Dest: TPoint2; Color: Cardinal);
var
 Vertices: array[0..1] of TD3DXVector2;
begin
 Flush();

 Vertices[0]:= TD3DXVector2(Src);
 Vertices[1]:= TD3DXVector2(Dest);
 LineDriver.Draw(@Vertices[0], 2, Color);
end;

//---------------------------------------------------------------------------
procedure TAsphyreCanvas.LineEx(x1, y1, x2, y2: Single;
 Color: Cardinal);
var
 Vertices: array[0..1] of TD3DXVector2;
begin
 Flush();

 Vertices[0].x:= x1;
 Vertices[0].y:= y1;
 Vertices[1].x:= x2;
 Vertices[1].y:= y2;
 LineDriver.Draw(@Vertices[0], 2, Color);
end;

//---------------------------------------------------------------------------
procedure TAsphyreCanvas.LineEx(const Src, Dest: TPoint;
 Color: Cardinal);
var
 Vertices: array[0..1] of TD3DXVector2;
begin
 Flush();

 Vertices[0].x:= Src.X;
 Vertices[0].y:= Src.Y;
 Vertices[1].x:= Dest.X;
 Vertices[1].y:= Dest.Y;
 LineDriver.Draw(@Vertices[0], 2, Color);
end;

//---------------------------------------------------------------------------
procedure TAsphyreCanvas.WireQuadEx(const Points: TPoint4;
 Color: Cardinal);
var
 Vertices: array[0..4] of TD3DXVector2;
begin
 Flush();

 Vertices[0]:= TD3DXVector2(Points[0]);
 Vertices[1]:= TD3DXVector2(Points[1]);
 Vertices[2]:= TD3DXVector2(Points[2]);
 Vertices[3]:= TD3DXVector2(Points[3]);
 Vertices[4]:= TD3DXVector2(Points[0]);

 LineDriver.Draw(@Vertices[0], 5, Color);
end;

//---------------------------------------------------------------------------
procedure TAsphyreCanvas.WireQuadHw(const Points: TPoint4;
 const Colors: TColor4; DrawFx: Integer);
var
 MyPts: TPoint4;
begin
 MyPts:= Points;

 // last pixel fix -> not very good implementation :(
 if (MyPts[0].y = MyPts[1].y)and(MyPts[2].y = MyPts[3].y)and
  (MyPts[0].x = MyPts[3].x)and(MyPts[1].x = MyPts[2].x) then
  begin
   MyPts[1].x:= MyPts[1].x - 1.0;
   MyPts[2].x:= MyPts[2].x - 1.0;
   MyPts[2].y:= MyPts[2].y - 1.0;
   MyPts[3].y:= MyPts[3].y - 1.0;
  end;

 LineHw(MyPts[0], MyPts[1], Colors[0], Colors[1], DrawFx);
 LineHw(MyPts[1], MyPts[2], Colors[1], Colors[2], DrawFx);
 LineHw(MyPts[2], MyPts[3], Colors[2], Colors[3], DrawFx);
 LineHw(MyPts[3], MyPts[0], Colors[3], Colors[0], DrawFx);
end;

//---------------------------------------------------------------------------
procedure TAsphyreCanvas.AddIndexEntry(Index: Integer);
var
 Entry: PWord;
begin
 Entry:= Pointer(Integer(IndexArray) + (FIndexCount * SizeOf(Word)));
 Entry^:= Index;

 Inc(FIndexCount);
end;

//---------------------------------------------------------------------------
procedure TAsphyreCanvas.FillTri(const p1, p2, p3: TPoint2; c1, c2, c3: Cardinal;
 DrawFx: Integer);
var
 Entry: PVertexRecord;
begin
 {$IFDEF FillTriUncached}
 // request non-indexed triangle list to reduce bandwidth
 RequestCache(dmTriangleList, False, 3, 0, DrawFx, nil);
 {$ELSE}
 // request indexed triangle list to improve cache performance
 RequestCache(dmTriangleList, True, 3, 3, DrawFx, nil);
 {$ENDIF}

 {$IFNDEF FillTriUncached}
 // insert index entries, if using index buffers
 AddIndexEntry(FVertexCount);
 AddIndexEntry(FVertexCount + 1);
 AddIndexEntry(FVertexCount + 2);
 {$ENDIF}

 // insert vertices
 Entry:= NextVertexEntry();
 Entry.Vertex.x:= p1.x;
 Entry.Vertex.y:= p1.y;
 Entry.Color   := c1;
 Inc(FVertexCount);

 Entry:= NextVertexEntry();
 Entry.Vertex.x:= p2.x;
 Entry.Vertex.y:= p2.y;
 Entry.Color   := c2;
 Inc(FVertexCount);

 Entry:= NextVertexEntry();
 Entry.Vertex.x:= p3.x;
 Entry.Vertex.y:= p3.y;
 Entry.Color   := c3;
 Inc(FVertexCount);

 Inc(FPrimitives);
end;

//---------------------------------------------------------------------------
procedure TAsphyreCanvas.FillTri(x1, y1, x2, y2, x3, y3: Single; c1, c2,
 c3: Cardinal; DrawFx: Integer);
begin
 FillTri(Point2(x1, y1), Point2(x2, y2), Point2(x3, y3), c1, c2, c3, DrawFx);
end;

//---------------------------------------------------------------------------
procedure TAsphyreCanvas.FillQuad(const Points: TPoint4; const Colors: TColor4;
 DrawFx: Integer);
var
 Entry: PVertexRecord;
begin
 {$IFDEF FillQuadUncached}
 // request non-indexed triangle strip to reduce bandwidth
 RequestCache(dmTriangleStrip, False, 4, 0, DrawFx, nil);
 {$ELSE}
 // request indexed triangle list to improve cache performance
 RequestCache(dmTriangleList, True, 4, 6, DrawFx, nil);
 {$ENDIF}

 {$IFNDEF FillQuadUncached}
 // insert index entries, if using index buffers
 AddIndexEntry(FVertexCount + 2);
 AddIndexEntry(FVertexCount);
 AddIndexEntry(FVertexCount + 1);
 AddIndexEntry(FVertexCount + 3);
 AddIndexEntry(FVertexCount + 2);
 AddIndexEntry(FVertexCount + 1);
 {$ENDIF}

 // insert vertices
 Entry:= NextVertexEntry();
 Entry.Vertex.x:= Points[0].x;
 Entry.Vertex.y:= Points[0].y;
 Entry.Color   := Colors[0];
 Inc(FVertexCount);

 Entry:= NextVertexEntry();
 Entry.Vertex.x:= Points[1].x;
 Entry.Vertex.y:= Points[1].y;
 Entry.Color   := Colors[1];
 Inc(FVertexCount);

 Entry:= NextVertexEntry();
 Entry.Vertex.x:= Points[3].x;
 Entry.Vertex.y:= Points[3].y;
 Entry.Color   := Colors[3];
 Inc(FVertexCount);

 Entry:= NextVertexEntry();
 Entry.Vertex.x:= Points[2].x;
 Entry.Vertex.y:= Points[2].y;
 Entry.Color   := Colors[2];
 Inc(FVertexCount);

 Inc(FPrimitives, 2);

 {$IFDEF FillQuadUncached}
 ResetCache();
 {$ENDIF}
end;

//---------------------------------------------------------------------------
procedure TAsphyreCanvas.FillQuadEx(const Points: TPoint4;
 const Colors: TColor4; DrawFx: Integer);
var
 i: Integer;
 Entry: PVertexRecord;
begin
 RequestCache(dmTriangleList, True, 8, 18, DrawFx, nil);

 // Insert indexes.
 AddIndexEntry(FVertexCount + 0);
 AddIndexEntry(FVertexCount + 4);
 AddIndexEntry(FVertexCount + 7);

 AddIndexEntry(FVertexCount + 4);
 AddIndexEntry(FVertexCount + 1);
 AddIndexEntry(FVertexCount + 5);

 AddIndexEntry(FVertexCount + 4);
 AddIndexEntry(FVertexCount + 6);
 AddIndexEntry(FVertexCount + 7);

 AddIndexEntry(FVertexCount + 4);
 AddIndexEntry(FVertexCount + 5);
 AddIndexEntry(FVertexCount + 6);

 AddIndexEntry(FVertexCount + 7);
 AddIndexEntry(FVertexCount + 6);
 AddIndexEntry(FVertexCount + 3);

 AddIndexEntry(FVertexCount + 5);
 AddIndexEntry(FVertexCount + 2);
 AddIndexEntry(FVertexCount + 6);

 // Insert first four vertices.
 for i:= 0 to 3 do
  begin
   Entry:= NextVertexEntry();
   Entry.Vertex.x:= Points[i].x;
   Entry.Vertex.y:= Points[i].y;
   Entry.Color   := Colors[i];
   Inc(FVertexCount);
  end;

 // Insert subdivision vertices.
 Entry:= NextVertexEntry();
 Entry.Vertex.x:= (Points[0].x + Points[1].x) * 0.5;
 Entry.Vertex.y:= (Points[0].y + Points[1].y) * 0.5;
 Entry.Color   := ColorAvg(Colors[0], Colors[1]);
 Inc(FVertexCount);

 Entry:= NextVertexEntry();
 Entry.Vertex.x:= (Points[1].x + Points[2].x) * 0.5;
 Entry.Vertex.y:= (Points[1].y + Points[2].y) * 0.5;
 Entry.Color   := ColorAvg(Colors[1], Colors[2]);
 Inc(FVertexCount);

 Entry:= NextVertexEntry();
 Entry.Vertex.x:= (Points[2].x + Points[3].x) * 0.5;
 Entry.Vertex.y:= (Points[2].y + Points[3].y) * 0.5;
 Entry.Color   := ColorAvg(Colors[2], Colors[3]);
 Inc(FVertexCount);

 Entry:= NextVertexEntry();
 Entry.Vertex.x:= (Points[3].x + Points[0].x) * 0.5;
 Entry.Vertex.y:= (Points[3].y + Points[0].y) * 0.5;
 Entry.Color   := ColorAvg(Colors[3], Colors[0]);
 Inc(FVertexCount);

 Inc(FPrimitives, 6);
end;

//---------------------------------------------------------------------------
procedure TAsphyreCanvas.FillRect(const Rect: TRect; const Colors: TColor4;
 DrawFx: Integer);
begin
 FillQuad(pRect4(Rect), Colors, DrawFx);
end;

//---------------------------------------------------------------------------
procedure TAsphyreCanvas.FillRect(const Rect: TRect; Color: Cardinal;
 DrawFx: Integer);
begin
 FillRect(Rect, cColor4(Color), DrawFx);
end;

//---------------------------------------------------------------------------
procedure TAsphyreCanvas.FillRect(Left, Top, Width, Height: Integer;
 Color: Cardinal; DrawFx: Integer);
begin
 FillRect(Bounds(Left, Top, Width, Height), Color, DrawFx);
end;

//---------------------------------------------------------------------------
procedure TAsphyreCanvas.FrameRect(const Rect: TRect; const Colors: TColor4;
 DrawFx: Integer);
begin
 WireQuadHw(pRect4(Rect), Colors, DrawFx);
end;

//---------------------------------------------------------------------------
procedure TAsphyreCanvas.FrameRect(const Rect: TRect; Color: Cardinal;
 DrawFx: Integer);
begin
 FrameRect(Rect, cColor4(Color), DrawFx);
end;

//---------------------------------------------------------------------------
procedure TAsphyreCanvas.FrameRect(Left, Top, Width, Height: Integer;
 Color: Cardinal; DrawFx: Integer);
begin
 FrameRect(Bounds(Left, Top, Width, Height), Color, DrawFx);
end;

//---------------------------------------------------------------------------
procedure TAsphyreCanvas.FillArc(x, y, RadiusX, RadiusY, InitPhi,
 EndPhi: Single; Steps: Integer; const Colors: TColor4; DrawFx: Integer);
var
 x1, y1, x2, y2: Real;
 cs: TTrueColor4;
 i: Integer;
 Alpha0, xAlpha, yAlpha: Real;
 CurPt: TPoint2;
 Entry: PVertexRecord;
 {$IFNDEF FillArcUncached}VertexZero: Integer;{$ENDIF}
begin
 if (Steps < 1) then
  begin
   {$IFDEF DebugMode}
   DebugLog('! FillArc: Steps must be greater than zero.');
   {$ENDIF}

   Exit;
  end;

 // (1) Convert 32-bit RGBA colors to floating-point color set.
 cs:= TrueColor4to4(Colors);

 // (2) Find (x, y) margins for color interpolation.
 x1:= x - RadiusX;
 x2:= x + RadiusX;
 y1:= y - RadiusY;
 y2:= y + RadiusY;

 // (3) Before doing anything else, check cache availability.
 {$IFDEF FillArcUncached}
 // request non-indexed triangle fan to reduce bandwidth
 RequestCache(dmTriangleFan, False, Steps + 2, 0, DrawFx, nil);
 {$ELSE}
 // request indexed triangle list to improve cache performance
 RequestCache(dmTriangleList, True, Steps + 2, Steps * 3, DrawFx, nil);
 {$ENDIF}

 {$IFNDEF FillArcUncached}
 VertexZero:= FVertexCount;
 {$ENDIF}

 // (4) Insert initial vertex placed at the arc's center
 Entry:= NextVertexEntry();
 Entry.Vertex.x:= x;
 Entry.Vertex.y:= y;
 Entry.Color   := (cs[0] + cs[1] + cs[2] + cs[3]) * 0.25;
 Inc(FVertexCount);

 // (5) Insert the rest of vertices
 for i:= 0 to Steps - 1 do
  begin
   // initial and final angles for this vertex
   Alpha0:= (i * (EndPhi - InitPhi) / Steps) + InitPhi;

   // determine second and third points of the processed vertex
   CurPt.x:= x + Cos(Alpha0) * RadiusX;
   CurPt.y:= y - Sin(Alpha0) * RadiusY;

   // find color interpolation values
   xAlpha:= (CurPt.x - x1) / (x2 - x1);
   yAlpha:= (CurPt.y - y1) / (y2 - y1);

   {$IFNDEF FillArcUncached}
   // insert new index buffer entry
   AddIndexEntry(VertexZero);
   AddIndexEntry(FVertexCount);
   AddIndexEntry(FVertexCount + 1);
   {$ENDIF}

   // insert the entry into vertex array
   Entry:= NextVertexEntry();
   Entry.Vertex.x:= CurPt.x;
   Entry.Vertex.y:= CurPt.y;
   Entry.Color:= AlphaBlendTC(AlphaBlendTC(cs[0], cs[1], xAlpha),
    AlphaBlendTC(cs[3], cs[2], xAlpha), yAlpha);
   Inc(FVertexCount);
  end;

 // find the latest vertex to finish the arc
 CurPt.x:= x + Cos(EndPhi) * RadiusX;
 CurPt.y:= y - Sin(EndPhi) * RadiusY;

 // find color interpolation values
 xAlpha:= (CurPt.x - x1) / (x2 - x1);
 yAlpha:= (CurPt.y - y1) / (y2 - y1);

 // insert the entry into vertex array
 Entry:= NextVertexEntry();
 Entry.Vertex.x:= CurPt.x;
 Entry.Vertex.y:= CurPt.y;
 Entry.Color   := AlphaBlendTC(AlphaBlendTC(cs[0], cs[1], xAlpha),
  AlphaBlendTC(cs[3], cs[2], xAlpha), yAlpha);
 Inc(FVertexCount);

 Inc(FPrimitives, Steps);

 {$IFDEF FillArcUncached}
 ResetCache();
 {$ENDIF}
end;

//---------------------------------------------------------------------------
procedure TAsphyreCanvas.FillEllipse(x, y, RadiusX, RadiusY: Single;
 Steps: Integer; const Colors: TColor4; DrawFx: Integer);
begin
 FillArc(x, y, RadiusX, RadiusY, 0, Pi * 2.0, Steps, Colors, DrawFx);
end;

//---------------------------------------------------------------------------
procedure TAsphyreCanvas.FillCircle(x, y, Radius: Single;
 Steps: Integer; const Colors: TColor4; DrawFx: Integer);
begin
 FillArc(x, y, Radius, Radius, 0, Pi * 2.0, Steps, Colors, DrawFx);
end;

//---------------------------------------------------------------------------
procedure TAsphyreCanvas.Ellipse(x, y, RadiusX, RadiusY: Single;
 Steps: Integer; Color: Cardinal);
const
 Pi2 = Pi * 2.0;
var
 Vertices: array of TD3DXVector2;
 i: Integer;
 Alpha: Real;
begin
 SetLength(Vertices, Steps + 1);

 for i:= 0 to Steps do
  begin
   Alpha:= i * Pi2 / Steps;

   Vertices[i].x:= x + Cos(Alpha) * RadiusX;
   Vertices[i].y:= y - Sin(Alpha) * RadiusY;

   // 1-pixel gap bug fix
   if (i = Steps) then Vertices[i].y:=  Vertices[i].y - 1;
  end;

 LineDriver.Draw(@Vertices[0], Steps + 1, Color);
end;

//--------------------------------------------------------------------------
procedure TAsphyreCanvas.Circle(x, y, Radius: Single; Steps: Integer;
 Color: Cardinal);
begin
 Ellipse(x, y, Radius, Radius, Steps, Color);
end;

//---------------------------------------------------------------------------
procedure TAsphyreCanvas.FillRibbon(x, y, InRadiusX, InRadiusY, OutRadiusX,
 OutRadiusY, InitPhi, EndPhi: single; Steps: Integer; const Colors: TColor4;
 DrawFx: Integer);
var
 x1, y1, x2, y2: Single;
 cs: TTrueColor4;
 i: Integer;
 Alpha, xAlpha, yAlpha: Single;
 CurPt: TPoint2;
 Entry: PVertexRecord;
 {$IFNDEF FillRibbonUncached}PreVtx: Integer;{$ENDIF}
begin
 if (Steps < 1) then
  begin
   {$IFDEF DebugMode}
   DebugLog('! FillRibbon: Steps must be greater than zero.');
   {$ENDIF}

   Exit;
  end;

 // (1) Convert 32-bit RGBA colors to floating-point color set.
 cs:= TrueColor4to4(Colors);

 // (2) Find (x, y) margins for color interpolation.
 x1:= x - OutRadiusX;
 x2:= x + OutRadiusX;
 y1:= y - OutRadiusY;
 y2:= y + OutRadiusY;

 // (3) Check cache availability first.
 {$IFDEF FillRibbonUncached}
 // request non-indexed triangle strip to reduce bandwidth
 RequestCache(dmTriangleStrip, False, (Steps * 2) + 2, 0, DrawFx, nil);
 {$ELSE}
 // request indexed triangle list to improve cache performance
 RequestCache(dmTriangleList, True, (Steps * 2) + 2, Steps * 6, DrawFx, nil);
 {$ENDIF}

 {$IFNDEF FillRibbonUncached}
 PreVtx:= FVertexCount;
 {$ENDIF}

 // (4) Create first inner vertex
 CurPt.x:= x + Cos(InitPhi) * InRadiusX;
 CurPt.y:= y - Sin(InitPhi) * InRadiusY;
 // -> color interpolation values
 xAlpha:= (CurPt.x - x1) / (x2 - x1);
 yAlpha:= (CurPt.y - y1) / (y2 - y1);
 // -> insert the vertex
 Entry:= NextVertexEntry();
 Entry.Vertex.x:= CurPt.x;
 Entry.Vertex.y:= CurPt.y;
 Entry.Color   := AlphaBlendTC(AlphaBlendTC(cs[0], cs[1], xAlpha),
  AlphaBlendTC(cs[3], cs[2], xAlpha), yAlpha);
 Inc(FVertexCount);

 // (5) Create first outer vertex
 CurPt.x:= x + Cos(InitPhi) * OutRadiusX;
 CurPt.y:= y - Sin(InitPhi) * OutRadiusY;
 // -> color interpolation values
 xAlpha:= (CurPt.x - x1) / (x2 - x1);
 yAlpha:= (CurPt.y - y1) / (y2 - y1);
 // -> insert the vertex
 Entry:= NextVertexEntry();
 Entry.Vertex.x:= CurPt.x;
 Entry.Vertex.y:= CurPt.y;
 Entry.Color   := AlphaBlendTC(AlphaBlendTC(cs[0], cs[1], xAlpha),
  AlphaBlendTC(cs[3], cs[2], xAlpha), yAlpha);
 Inc(FVertexCount);

 // (6) Insert the rest of vertices
 for i:= 1 to Steps do
  begin
   // 6a. Insert inner vertex
   // -> angular position
   Alpha:= (i * (EndPhi - InitPhi) / Steps) + InitPhi;
   // -> vertex position
   CurPt.x:= x + Cos(Alpha) * InRadiusX;
   CurPt.y:= y - Sin(Alpha) * InRadiusY;
   // -> color interpolation values
   xAlpha:= (CurPt.x - x1) / (x2 - x1);
   yAlpha:= (CurPt.y - y1) / (y2 - y1);
   // -> insert the vertex
   Entry:= NextVertexEntry();
   Entry.Vertex.x:= CurPt.x;
   Entry.Vertex.y:= CurPt.y;
   Entry.Color:= AlphaBlendTC(AlphaBlendTC(cs[0], cs[1], xAlpha),
    AlphaBlendTC(cs[3], cs[2], xAlpha), yAlpha);
   Inc(FVertexCount);

   // 6b. Insert outer vertex
   // -> angular position
   Alpha:= (i * (EndPhi - InitPhi) / Steps) + InitPhi;
   // -> vertex position
   CurPt.x:= x + Cos(Alpha) * OutRadiusX;
   CurPt.y:= y - Sin(Alpha) * OutRadiusY;
   // -> color interpolation values
   xAlpha:= (CurPt.x - x1) / (x2 - x1);
   yAlpha:= (CurPt.y - y1) / (y2 - y1);
   // -> insert the vertex
   Entry:= NextVertexEntry();
   Entry.Vertex.x:= CurPt.x;
   Entry.Vertex.y:= CurPt.y;
   Entry.Color:= AlphaBlendTC(AlphaBlendTC(cs[0], cs[1], xAlpha),
    AlphaBlendTC(cs[3], cs[2], xAlpha), yAlpha);
   Inc(FVertexCount);
  end;

 {$IFNDEF FillRibbonUncached}
 // (7) Insert indexes
 for i:= 0 to Steps - 1 do
  begin
   AddIndexEntry(PreVtx);
   AddIndexEntry(PreVtx + 1);
   AddIndexEntry(PreVtx + 2);

   AddIndexEntry(PreVtx + 1);
   AddIndexEntry(PreVtx + 3);
   AddIndexEntry(PreVtx + 2);

   Inc(PreVtx, 2);
  end;
 {$ENDIF}

 Inc(FPrimitives, Steps * 2);

 {$IFDEF FillRibbonUncached}
 ResetCache();
 {$ENDIF}
end;

//---------------------------------------------------------------------------
procedure TAsphyreCanvas.FillRibbon(x, y, InRadiusX, InRadiusY, OutRadiusX,
 OutRadiusY, InitPhi, EndPhi: single; Steps: Integer; Palette: TAsphyrePalette;
 DrawFx: Integer);
var
 i: Integer;
 Alpha: Single;
 CurPt: TPoint2;
 Color: Cardinal;
 Entry: PVertexRecord;
 {$IFNDEF FillRibbonUncached}PreVtx: Integer;{$ENDIF}
begin
 if (Steps < 1) then
  begin
   {$IFDEF DebugMode}
   DebugLog('! FillRibbon: Steps must be greater than zero.');
   {$ENDIF}

   Exit;
  end;

 // (1) Check cache availability.
 {$IFDEF FillRibbonUncached}
 // request non-indexed triangle strip to reduce bandwidth
 RequestCache(dmTriangleStrip, False, (Steps * 2) + 2, 0, DrawFx, nil);
 {$ELSE}
 // request indexed triangle list to improve cache performance
 RequestCache(dmTriangleList, True, (Steps * 2) + 2, Steps * 6, DrawFx, nil);
 {$ENDIF}

 {$IFNDEF FillRibbonUncached}
 PreVtx:= FVertexCount;
 {$ENDIF}

 // (2) Retreive first color from the palette.
 Color:= Palette.Color[0.0];

 // (3) Create first inner vertex
 CurPt.x:= x + Cos(InitPhi) * InRadiusX;
 CurPt.y:= y - Sin(InitPhi) * InRadiusY;
 // -> insert the vertex
 Entry:= NextVertexEntry();
 Entry.Vertex.x:= CurPt.x;
 Entry.Vertex.y:= CurPt.y;
 Entry.Color   := Color;
 Inc(FVertexCount);

 // (4) Create first outer vertex
 CurPt.x:= x + Cos(InitPhi) * OutRadiusX;
 CurPt.y:= y - Sin(InitPhi) * OutRadiusY;
 // -> insert the vertex
 Entry:= NextVertexEntry();
 Entry.Vertex.x:= CurPt.x;
 Entry.Vertex.y:= CurPt.y;
 Entry.Color   := Color;
 Inc(FVertexCount);

 // (5) Insert the rest of vertices
 for i:= 1 to Steps do
  begin
   // 5a. Retreive next color from palette
   Color:= Palette.Color[i / Steps];

   // 5b. Insert inner vertex
   // -> angular position
   Alpha:= (i * (EndPhi - InitPhi) / Steps) + InitPhi;
   // -> vertex position
   CurPt.x:= x + Cos(Alpha) * InRadiusX;
   CurPt.y:= y - Sin(Alpha) * InRadiusY;
   // -> insert the vertex
   Entry:= NextVertexEntry();
   Entry.Vertex.x:= CurPt.x;
   Entry.Vertex.y:= CurPt.y;
   Entry.Color:= Color;
   Inc(FVertexCount);

   // 5c. Insert outer vertex
   // -> angular position
   Alpha:= (i * (EndPhi - InitPhi) / Steps) + InitPhi;
   // -> vertex position
   CurPt.x:= x + Cos(Alpha) * OutRadiusX;
   CurPt.y:= y - Sin(Alpha) * OutRadiusY;
   // -> insert the vertex
   Entry:= NextVertexEntry();
   Entry.Vertex.x:= CurPt.x;
   Entry.Vertex.y:= CurPt.y;
   Entry.Color:= Color;
   Inc(FVertexCount);
  end;

 {$IFNDEF FillRibbonUncached}
 // (6) Insert indexes
 for i:= 0 to Steps - 1 do
  begin
   AddIndexEntry(PreVtx);
   AddIndexEntry(PreVtx + 1);
   AddIndexEntry(PreVtx + 2);

   AddIndexEntry(PreVtx + 1);
   AddIndexEntry(PreVtx + 3);
   AddIndexEntry(PreVtx + 2);

   Inc(PreVtx, 2);
  end;
 {$ENDIF}

 Inc(FPrimitives, Steps * 2);

 {$IFDEF FillRibbonUncached}
 ResetCache();
 {$ENDIF}
end;

//---------------------------------------------------------------------------
procedure TAsphyreCanvas.WuLine(Src, Dest: TPoint2; Color0, Color1: Cardinal;
 DrawFx: Integer);
var
 DeltaX, DeltaY, Grad, xEnd, yEnd, xPos, yPos: Real;
 Alpha, AlphaInc: Real;
 Aux, Point0, Point1: TPoint2;
 Index: Integer;
 MyColor: Cardinal;
begin
 DeltaX:= Dest.x - Src.x;
 DeltaY:= Dest.y - Src.y;

 // straight lines?
 if (DeltaX = 0.0)or(DeltaY = 0.0) then
  begin
   LineHw(Src, Dest, Color0, Color1, DrawFx);
   Exit;
  end;

 if (Abs(DeltaX) > Abs(DeltaY)) then
  begin // horizontal line
   if (DeltaX < 0.0) then
    begin
     Aux := Src;
     Src := Dest;
     Dest:= Aux;
     DeltaX:= -DeltaX;
     DeltaY:= -DeltaY;
     MyColor:= Color0;
     Color0 := Color1;
     Color1 := MyColor;
    end;

   Grad:= DeltaY / DeltaX;

   // 1st point
   xEnd:= Int(Src.x + 0.5);
   yEnd:= Src.y + (xEnd - Src.x) * Grad;
   yPos:= yEnd + Grad;

   Point0:= Point2(Int(xEnd), Int(yEnd));

   // 2nd point
   xEnd:= Int(Dest.x + 0.5);
   yEnd:= Dest.y + (xEnd - Dest.x) * Grad;

   Point1:= Point2(Int(xEnd), Int(yEnd));

   Alpha:= 0.0;
   AlphaInc:= 255.0 / Abs(Int(Point1.x) - Int(Point0.x));
   for Index:= Trunc(Point0.x) to Trunc(Point1.x) do
    begin
     MyColor:= BlendPixels(Color1, Color0, Round(Alpha));
     PutPixel(Index, Int(yPos), ModulateAlpha(MyColor, 1.0 - Frac(yPos)), DrawFx);
     PutPixel(Index, Int(yPos) + 1.0, ModulateAlpha(MyColor, Frac(yPos)), DrawFx);

     yPos:= yPos + Grad;
     Alpha:= Alpha + AlphaInc;
    end;
  end else
  begin // vertical line
   if (DeltaY < 0.0) then
    begin
     Aux := Src;
     Src := Dest;
     Dest:= Aux;
     DeltaX:= -DeltaX;
     DeltaY:= -DeltaY;

     MyColor:= Color0;
     Color0 := Color1;
     Color1 := MyColor;
    end;

   Grad:= DeltaX / DeltaY;

   // 1st point
   yEnd:= Int(Src.y + 0.5);
   xEnd:= Src.x + (yEnd - Src.y) * Grad;
   xPos:= xEnd + Grad;

   Point0:= Point2(Int(xEnd), Int(yEnd));

   // 2nd point
   yEnd:= Int(Dest.y + 0.5);
   xEnd:= Dest.x + (yEnd - Dest.y) * Grad;

   Point1:= Point2(Int(xEnd), Int(yEnd));

   Alpha:= 0.0;
   AlphaInc:= 255.0 / Abs(Int(Point1.y) - Int(Point0.y));
   for Index:= Trunc(Point0.y) to Trunc(Point1.y) do
    begin
     MyColor:= BlendPixels(Color1, Color0, Round(Alpha));
     PutPixel(Int(xPos), Index, ModulateAlpha(MyColor, 1.0 - Frac(xPos)), DrawFx);
     PutPixel(Int(xPos) + 1.0, Index, ModulateAlpha(MyColor, Frac(xPos)), DrawFx);

     xPos := xPos + Grad;
     Alpha:= Alpha + AlphaInc;
    end;
  end;
end;

//---------------------------------------------------------------------------
procedure TAsphyreCanvas.WuLine(x1, y1, x2, y2: Single; Color1,
 Color2: Cardinal; DrawFx: Integer);
begin
 WuLine(Point2(x1, y1), Point2(x2, y2), Color1, Color2, DrawFx);
end;

//---------------------------------------------------------------------------
procedure TAsphyreCanvas.FrameRibbonHw(x, y, InRadiusX, InRadiusY,
 OutRadiusX, OutRadiusY, InitPhi, EndPhi: Single; Steps: Integer;
 Color: Cardinal; DrawFx: Integer);
var
 i: Integer;
 Alpha: Single;
 CurPt: TPoint2;
 Entry: PVertexRecord;
 {$IFNDEF FrameRibbonUncached}PreVtx: Integer;{$ENDIF}
begin
 if (Steps < 1) then
  begin
   {$IFDEF DebugMode}
   DebugLog('! FrameRibbonHw: Steps must be greater than zero.');
   {$ENDIF}

   Exit;
  end;

 // (1) Check cache availability.
 {$IFDEF FrameRibbonUncached}
 // request non-indexed line strip to reduce bandwidth
 RequestCache(dmLineStrip, False, (Steps * 2) + 3, 0, DrawFx, nil);
 {$ELSE}
 // request indexed line list to improve cache performance
 RequestCache(dmLineList, True, (Steps * 2) + 2, (Steps * 2) + 3, DrawFx, nil);
 {$ENDIF}

 {$IFNDEF FrameRibbonUncached}
 PreVtx:= FVertexCount;
 {$ENDIF}

 // (2) Create first inner vertex
 CurPt.x:= x + Cos(InitPhi) * InRadiusX;
 CurPt.y:= y - Sin(InitPhi) * InRadiusY;
 // -> insert the vertex
 Entry:= NextVertexEntry();
 Entry.Vertex.x:= CurPt.x;
 Entry.Vertex.y:= CurPt.y;
 Entry.Color   := Color;
 Inc(FVertexCount);

 // (3) Create first outer vertex
 CurPt.x:= x + Cos(InitPhi) * OutRadiusX;
 CurPt.y:= y - Sin(InitPhi) * OutRadiusY;
 // -> insert the vertex
 Entry:= NextVertexEntry();
 Entry.Vertex.x:= CurPt.x;
 Entry.Vertex.y:= CurPt.y;
 Entry.Color   := Color;
 Inc(FVertexCount);

 // (4) Insert outer vertices.
 for i:= 1 to Steps do
  begin
   // -> angular position
   Alpha:= (i * (EndPhi - InitPhi) / Steps) + InitPhi;
   // -> vertex position
   CurPt.x:= x + Cos(Alpha) * OutRadiusX;
   CurPt.y:= y - Sin(Alpha) * OutRadiusY;
   // -> insert the vertex
   Entry:= NextVertexEntry();
   Entry.Vertex.x:= CurPt.x;
   Entry.Vertex.y:= CurPt.y;
   Entry.Color:= Color;
   Inc(FVertexCount);
  end;

 // (5) Insert inner vertices.
 {$IFDEF FrameRibbonUncached}
 for i:= Steps downto 0 do
 {$ELSE}
 for i:= Steps downto 1 do
 {$ENDIF}
  begin
   // -> angular position
   Alpha:= (i * (EndPhi - InitPhi) / Steps) + InitPhi;
   // -> vertex position
   CurPt.x:= x + Cos(Alpha) * InRadiusX;
   CurPt.y:= y - Sin(Alpha) * InRadiusY;
   // -> insert the vertex
   Entry:= NextVertexEntry();
   Entry.Vertex.x:= CurPt.x;
   Entry.Vertex.y:= CurPt.y;
   Entry.Color:= Color;
   Inc(FVertexCount);
  end;

 {$IFNDEF FrameRibbonUncached}
 AddIndexEntry(PreVtx);
 AddIndexEntry(PreVtx + 1);

 // (6) Insert indexes.
 for i:= 0 to (Steps * 2) - 1 do
  begin
   AddIndexEntry(PreVtx + 1 + i);
   AddIndexEntry(PreVtx + 2 + i);
  end;

 AddIndexEntry(PreVtx + (Steps * 2) + 1);
 AddIndexEntry(PreVtx);
 {$ENDIF}

 Inc(FPrimitives, 2 + Steps * 2);

 {$IFDEF FrameRibbonUncached}
 ResetCache();
 {$ENDIF}
end;

//---------------------------------------------------------------------------
procedure TAsphyreCanvas.FrameRibbonEx(x, y, InRadiusX, InRadiusY,
 OutRadiusX, OutRadiusY, InitPhi, EndPhi: Single; Steps: Integer;
 Color: Cardinal);
var
 Vertices: array of TD3DXVector2;
 vIndex  : Integer;
 i: Integer;
 Alpha: Single;
begin
 if (Steps < 1) then
  begin
   {$IFDEF DebugMode}
   DebugLog('! FrameRibbonEx: Steps must be greater than zero.');
   {$ENDIF}

   Exit;
  end;

 Flush();
 SetLength(Vertices, (Steps * 2) + 3);

 // (1) Create first inner vertex
 Vertices[0].x:= x + Cos(InitPhi) * InRadiusX;
 Vertices[0].y:= y - Sin(InitPhi) * InRadiusY;

 // (2) Create first outer vertex
 Vertices[1].x:= x + Cos(InitPhi) * OutRadiusX;
 Vertices[1].y:= y - Sin(InitPhi) * OutRadiusY;

 // (3) Insert outer vertices.
 vIndex:= 2;
 for i:= 1 to Steps do
  begin
   // -> angular position
   Alpha:= (i * (EndPhi - InitPhi) / Steps) + InitPhi;
   // -> vertex position
   Vertices[vIndex].x:= x + Cos(Alpha) * OutRadiusX;
   Vertices[vIndex].y:= y - Sin(Alpha) * OutRadiusY;
   Inc(vIndex);
  end;

 for i:= Steps downto 0 do
  begin
   // -> angular position
   Alpha:= (i * (EndPhi - InitPhi) / Steps) + InitPhi;
   // -> vertex position
   Vertices[vIndex].x:= x + Cos(Alpha) * InRadiusX;
   Vertices[vIndex].y:= y - Sin(Alpha) * InRadiusY;
   Inc(vIndex);
  end;

 LineDriver.Draw(@Vertices[0], (Steps * 2) + 3, Color);
end;

//---------------------------------------------------------------------------
procedure TAsphyreCanvas.UseImage(Image: TAsphyreCustomImage; Pattern: Integer);
begin
 if (Image <> nil) then
  begin
   if (Image is TAsphyreImage) then
    begin // Mapping using Pattern information
     ActiveTex:= TAsphyreImage(Image).RetreiveTex(Pattern, @QuadMapping);
    end else
    begin // Default mapping
     {$IFDEF DebugMode}
     DebugLog('! UseImage: The specified image is not TAsphyreImage, ' +
      'can''t use Pattern value.');
     {$ENDIF}

     ActiveTex  := Image.Texture[0];
     QuadMapping:= TexFull4;
    end;
  end else
  begin
   {$IFDEF DebugMode}
   DebugLog('! UseImage: The specified image does not exist, ' +
    'can''t use Pattern value.');
   {$ENDIF}

   ActiveTex:= nil;
  end;
end;

//---------------------------------------------------------------------------
procedure TAsphyreCanvas.UseImage(Image: TAsphyreCustomImage; Pattern, SrcX,
 SrcY, SrcWidth, SrcHeight: Integer; Mirror, Flip: Boolean);
begin
 if (Image <> nil) then
  begin
   if (Image is TAsphyreImage) then
    begin // Mapping using Pattern information
     ActiveTex:= TAsphyreImage(Image).RetreiveTex(Pattern, SrcX, SrcY,
      SrcWidth, SrcHeight, Mirror, Flip, @QuadMapping);
    end else
    begin // Default mapping
     {$IFDEF DebugMode}
     DebugLog('! UseImage: The specified image is not TAsphyreImage, ' +
      'can''t use Pattern, Size and Mirror information.');
     {$ENDIF}

     ActiveTex  := Image.Texture[0];
     QuadMapping:= TexFull4;
    end;
  end else
  begin
   {$IFDEF DebugMode}
   DebugLog('! UseImage: The specified image does not exist, ' +
    'can''t use Pattern, Size and Mirror information.');
   {$ENDIF}

   ActiveTex:= nil;
  end;
end;

//---------------------------------------------------------------------------
procedure TAsphyreCanvas.UseImage(Image: TAsphyreCustomImage; TexNum: Integer;
 const Mapping: TPoint4);
begin
 if (Image = nil) then
  begin
   {$IFDEF DebugMode}
   DebugLog('! UseImage: The specified image does not exist, ' +
    'can''t use that texture number.');
   {$ENDIF}

   ActiveTex:= nil;
  end else ActiveTex:= Image.Texture[TexNum];

 QuadMapping:= Mapping;
end;

//---------------------------------------------------------------------------
procedure TAsphyreCanvas.UseImage(Image: TAsphyreCustomImage;
 const Mapping: TPoint4);
begin
 if (Image = nil) then
  begin
   {$IFDEF DebugMode}
   DebugLog('! UseImage: The specified image does not exist.');
   {$ENDIF}

   ActiveTex:= nil;
  end else ActiveTex:= Image.Texture[0];

 QuadMapping:= Mapping;
end;

//---------------------------------------------------------------------------
procedure TAsphyreCanvas.UseImage(Image: TAsphyreCustomImage;
 const Mapping: TPoint4px);
begin
 if (Image = nil) then
  begin
   {$IFDEF DebugMode}
   DebugLog('! UseImage: The specified image does not exist, ' +
    'can''t use the specified mapping.');
   {$ENDIF}

   ActiveTex:= nil;
  end else ActiveTex:= Image.Texture[0];

 if (ActiveTex <> nil) then
  begin
   QuadMapping[0]:= ActiveTex.CoordToLogical(Mapping[0]);
   QuadMapping[1]:= ActiveTex.CoordToLogical(Mapping[1]);
   QuadMapping[2]:= ActiveTex.CoordToLogical(Mapping[2]);
   QuadMapping[3]:= ActiveTex.CoordToLogical(Mapping[3]);
  end else QuadMapping:= TexFull4;
end;

//---------------------------------------------------------------------------
procedure TAsphyreCanvas.UseImageTri(Image: TAsphyreCustomImage; const tx0,
 tx1, tx2: TPoint2);
begin
 if (Image = nil) then
  begin
   {$IFDEF DebugMode}
   DebugLog('! UseImageTri: The specified image does not exist.');
   {$ENDIF}

   ActiveTex:= nil;
  end else ActiveTex:= Image.Texture[0];

 QuadMapping[0]:= tx0;
 QuadMapping[1]:= tx1;
 QuadMapping[2]:= tx2;
end;

//---------------------------------------------------------------------------
procedure TAsphyreCanvas.UseImageTri(Image: TAsphyreCustomImage; const tx0,
 tx1, tx2: TPoint);
begin
 if (Image = nil) then
  begin
   {$IFDEF DebugMode}
   DebugLog('! UseImageTri: The specified image does not exist.');
   {$ENDIF}

   ActiveTex:= nil;
  end else ActiveTex:= Image.Texture[0];

 if (ActiveTex <> nil) then
  begin
   QuadMapping[0]:= ActiveTex.CoordToLogical(tx0);
   QuadMapping[1]:= ActiveTex.CoordToLogical(tx1);
   QuadMapping[2]:= ActiveTex.CoordToLogical(tx2);
  end;
end;

//---------------------------------------------------------------------------
procedure TAsphyreCanvas.TexMap(const Points: TPoint4; const Colors: TColor4;
 DrawFx: Integer);
var
 Entry: PVertexRecord;
begin
 {$IFDEF TexMapUncached}
 // request non-indexed triangle strip to reduce bandwidth
 RequestCache(dmTriangleStrip, False, 4, 0, DrawFx, ActiveTex);
 {$ELSE}
 // request indexed triangle list to improve cache performance
 RequestCache(dmTriangleList, True, 4, 6, DrawFx, ActiveTex);
 {$ENDIF}

 {$IFNDEF TexMapUncached}
 // insert index entries, if using index buffers
 AddIndexEntry(FVertexCount + 2);
 AddIndexEntry(FVertexCount);
 AddIndexEntry(FVertexCount + 1);

 AddIndexEntry(FVertexCount + 3);
 AddIndexEntry(FVertexCount + 2);
 AddIndexEntry(FVertexCount + 1);
 {$ENDIF}

 // insert vertices
 Entry:= NextVertexEntry();
 Entry.Vertex.x:= Points[0].x - 0.5;
 Entry.Vertex.y:= Points[0].y - 0.5;
 Entry.Color   := Colors[0];
 Entry.u:= QuadMapping[0].x;
 Entry.v:= QuadMapping[0].y;
 Inc(FVertexCount);

 Entry:= NextVertexEntry();
 Entry.Vertex.x:= Points[1].x - 0.5;
 Entry.Vertex.y:= Points[1].y - 0.5;
 Entry.Color   := Colors[1];
 Entry.u:= QuadMapping[1].x;
 Entry.v:= QuadMapping[1].y;
 Inc(FVertexCount);

 Entry:= NextVertexEntry();
 Entry.Vertex.x:= Points[3].x - 0.5;
 Entry.Vertex.y:= Points[3].y - 0.5;
 Entry.Color   := Colors[3];
 Entry.u:= QuadMapping[3].x;
 Entry.v:= QuadMapping[3].y;
 Inc(FVertexCount);

 Entry:= NextVertexEntry();
 Entry.Vertex.x:= Points[2].x - 0.5;
 Entry.Vertex.y:= Points[2].y - 0.5;
 Entry.Color   := Colors[2];
 Entry.u:= QuadMapping[2].x;
 Entry.v:= QuadMapping[2].y;
 Inc(FVertexCount);

 Inc(FPrimitives, 2);

 {$IFDEF TexMapUncached}
 ResetCache();
 {$ENDIF}
end;

//---------------------------------------------------------------------------
procedure TAsphyreCanvas.TexTri(const p1, p2, p3: TPoint2; c1, c2,
 c3: Cardinal; DrawFx: Integer);
var
 Entry: PVertexRecord;
begin
 {$IFDEF TexTriUncached}
 // request non-indexed triangle strip to reduce bandwidth
 RequestCache(dmTriangleStrip, False, 3, 0, DrawFx, ActiveTex);
 {$ELSE}
 // request indexed triangle list to improve cache performance
 RequestCache(dmTriangleList, True, 3, 3, DrawFx, ActiveTex);
 {$ENDIF}

 {$IFNDEF TexTriUncached}
 // insert index entries, if using index buffers
 AddIndexEntry(FVertexCount);
 AddIndexEntry(FVertexCount + 1);
 AddIndexEntry(FVertexCount + 2);
 {$ENDIF}

 // insert vertices
 Entry:= NextVertexEntry();
 Entry.Vertex.x:= p1.x - 0.5;
 Entry.Vertex.y:= p1.y - 0.5;
 Entry.Color   := c1;
 Entry.u:= QuadMapping[0].x;
 Entry.v:= QuadMapping[0].y;
 Inc(FVertexCount);

 Entry:= NextVertexEntry();
 Entry.Vertex.x:= p2.x - 0.5;
 Entry.Vertex.y:= p2.y - 0.5;
 Entry.Color   := c2;
 Entry.u:= QuadMapping[1].x;
 Entry.v:= QuadMapping[1].y;
 Inc(FVertexCount);

 Entry:= NextVertexEntry();
 Entry.Vertex.x:= p3.x - 0.5;
 Entry.Vertex.y:= p3.y - 0.5;
 Entry.Color   := c3;
 Entry.u:= QuadMapping[3].x;
 Entry.v:= QuadMapping[3].y;
 Inc(FVertexCount);

 Inc(FPrimitives);

 {$IFDEF TexTriUncached}
 ResetCache();
 {$ENDIF}
end;

//---------------------------------------------------------------------------
end.

