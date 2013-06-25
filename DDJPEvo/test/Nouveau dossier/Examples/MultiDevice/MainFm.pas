unit MainFm;

//---------------------------------------------------------------------------
interface

//---------------------------------------------------------------------------
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, AsphyreDevices, AsphyreTimer, ExtCtrls, AsphyreDef, AsphyreImages,
  Vectors2, AsphyrePalettes, AsphyreEffects, StdCtrls, AsphyreSprite,
  AsphyreSpriteUtils, Direct3D9;

//---------------------------------------------------------------------------
type
  TMapPoint = record
    R, G, B: Byte;
    RPl, GPl, BPl: Integer;
  end;

  TMapInfo = record
    Width,
      Height: Integer;
    MapPoints: array of array of TMapPoint;
  end;

  TMainForm = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Label1: TLabel;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  Private
    { Private declarations }
    Ticks: Integer;
    Palette: TAsphyrePalette;
    ImageIndex: array[0..1] of Integer;

  Public
    SpriteEngine: array[0..1] of TSpriteEngine;
    procedure DevConfig(Sender: TAsphyreDevice; Tag: TObject;
      var Config: TScreenConfig);
    procedure ResetEvent(Sender: TAsphyreDevice; Tag: TObject;
      var Params: TD3DPresentParameters);
    procedure ConvertEvent(Sender: TAsphyreDevice; Tag: TObject;
      var Params: TD3DPresentParameters);
    procedure ProcessPoints;
    procedure TimerEvent(Sender: TObject);
    procedure ProcessEvent(Sender: TObject);
    procedure CreateParticleSprite();
    procedure CreateMapSprites(Sender: TAsphyreDevice);
    procedure DevRender(Sender: TAsphyreDevice; Tag: TObject);
    procedure InitDevice(Sender: TAsphyreDevice);
    procedure SetTileSpriteColor4;
  end;

  P = class(TParticleSprite)
  Public
    procedure DoMove(const MoveCount: Single); Override;
  end;


//---------------------------------------------------------------------------
var
  MainForm: TMainForm;
  MapInfo: TMapInfo;
  ColorTile: array of array of TAnimatedSprite;
//---------------------------------------------------------------------------
implementation
uses
  AsphyreArchives, AsphyreArcASDb, AsphyreArc7z, MediaImages,MediaFonts;
{$R *.dfm}

procedure TMainForm.ProcessPoints;
var
  i, j: Integer;
begin
  for i := 0 to MapInfo.Width do
    for j := 0 to MapInfo.Height do
      with MapInfo.MapPoints[i, j] do
      begin
        if R + RPl > 255 then
        begin
          R := 255;
          RPl := -RPl;
        end
        else
        begin
          if R + RPl < 0 then
          begin
            R := 0;
            RPl := -RPl;
          end
          else
            R := R + RPl;
        end;
        if G + GPl > 255 then
        begin
          G := 255;
          GPl := -GPl;
        end
        else
        begin
          if G + GPl < 0 then
          begin
            G := 0;
            GPl := -GPl;
          end
          else
            G := G + GPl;
        end;
        if B + BPl > 255 then
        begin
          B := 255;
          BPl := -BPl;
        end
        else
        begin
          if B + BPl < 0 then
          begin
            B := 0;
            BPl := -BPl;
          end
          else
            B := B + BPl;
        end;
      end;
end;

procedure P.DoMove(const MoveCount: Single);
begin
  inherited;
//  Alpha := Alpha - 1;
//  Red := Red - 1;
//  Blue := Blue - 1;
//  ScaleX := ScaleX - 0.005;
//  ScaleY := ScaleY - 0.005;
end;

//---------------------------------------------------------------------------
procedure TMainForm.SetTileSpriteColor4;
var
  i, j: Integer;
begin
  ProcessPoints;

  for i := 0 to MapInfo.Width - 1 do
  begin
    for j := 0 to MapInfo.Height - 1 do
    begin
      ColorTile[i, j].Color1 := cRGB1(MapInfo.MapPoints[i, j].R, MapInfo.MapPoints[i, j].G,
        MapInfo.MapPoints[i, j].B, 255);
      ColorTile[i, j].Color2 := cRGB1(MapInfo.MapPoints[i + 1, j].R, MapInfo.MapPoints[i + 1, j].G,
        MapInfo.MapPoints[i + 1, j].B, 255);
      ColorTile[i, j].Color3 := cRGB1(MapInfo.MapPoints[i + 1, j + 1].R, MapInfo.MapPoints[i + 1, j
        + 1].G, MapInfo.MapPoints[i + 1, j + 1].B, 255);
      ColorTile[i, j].Color4 := cRGB1(MapInfo.MapPoints[i, j + 1].R, MapInfo.MapPoints[i, j + 1].G,
        MapInfo.MapPoints[i, j + 1].B, 255);
    end;
  end;
end;

procedure TMainForm.Button1Click(Sender: TObject);
begin
  if Devices[0].Params.hDeviceWindow=panel1.Handle then
    Devices[0].Reset(ResetEvent, self)
   else
    Devices[1].Reset(ResetEvent, self);
end;

procedure TMainForm.Button1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
     if (Key = VK_ESCAPE) then Close();
end;

procedure TMainForm.Button2Click(Sender: TObject);
begin
  if Devices[0].Params.hDeviceWindow=panel2.Handle then
    Devices[0].Reset(ResetEvent, self)
  else
    Devices[1].Reset(ResetEvent, self);
end;

procedure TMainForm.Button3Click(Sender: TObject);
begin
  Devices[0].Reset(ConvertEvent, self);
  Devices[1].Reset(ConvertEvent, self);
end;

procedure TMainForm.ConvertEvent(Sender: TAsphyreDevice; Tag: TObject;
  var Params: TD3DPresentParameters);
begin
  if Params.hDeviceWindow = panel1.Handle then
  begin
    Params.hDeviceWindow := panel2.Handle;
    exit;
  end;
  
  if Params.hDeviceWindow = panel2.Handle then
  begin
    Params.hDeviceWindow := panel1.Handle;
    exit;
  end;

end;

procedure TMainForm.CreateMapSprites(Sender: TAsphyreDevice);
var
  j: Integer;
  i: Integer;
begin
  MapInfo.Width := Trunc(1024 / (128 * 2)) + 1;
  MapInfo.Height := Trunc(768 / (128 * 2)) + 1;
  SetLength(MapInfo.MapPoints, MapInfo.Width + 1, MapInfo.Height + 1);
  SetLength(ColorTile, MapInfo.Width + 1, MapInfo.Height + 1);
  for i := 0 to MapInfo.Width - 1 do
  begin
    for j := 0 to MapInfo.Height - 1 do
      with MapInfo do
      begin
        MapPoints[i, j].R := Random(256);
        MapPoints[i, j].G := Random(256);
        MapPoints[i, j].B := Random(256);
        MapPoints[i, j].RPl := Random(7) - 3;
        MapPoints[i, j].GPl := Random(7) - 3;
        MapPoints[i, j].BPl := Random(7) - 3;

        ColorTile[i, j] := TAnimatedSprite.Create(SpriteEngine[Sender.Index]);
        ColorTile[i, j].ImageName := '/images/tile';
        ColorTile[i, j].DrawMode := 4;
        ColorTile[i, j].AnimStart := 0;
        ColorTile[i, j].AnimSpeed := 0.06;
        ColorTile[i, j].AnimCount := 30;
        ColorTile[i, j].DrawFx := fxuBlend or fxfDiffuse;
        ColorTile[i, j].DoAnimate := True;
        ColorTile[i, j].AnimLooped := True;
        ColorTile[i, j].X1 := i * (128 * 2);
        ColorTile[i, j].Y1 := j * (128 * 2);
        ColorTile[i, j].X2 := i * (128 * 2) + (128 * 2);
        ColorTile[i, j].Y2 := j * (128 * 2);
        ColorTile[i, j].X3 := i * (128 * 2) + (128 * 2);
        ColorTile[i, j].Y3 := j * (128 * 2) + (128 * 2);
        ColorTile[i, j].X4 := i * (128 * 2);
        ColorTile[i, j].Y4 := j * (128 * 2) + (128 * 2);
      end;
  end;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin

  ImageGroups.ParseLink('/media.xml');
  FontGroups.ParseLink('/media.xml');

  Devices.InitEvent := InitDevice;

  Devices.Count := 2; //Devices.DisplayCount;
  if (not Devices.Initialize(DevConfig, Self)) then
  begin
    ShowMessage('Initialization failed.');
    Close();
    Exit;
  end;

  Timer.Enabled := True;
  Timer.OnTimer := TimerEvent;
  Timer.OnProcess := ProcessEvent;
  Timer.MaxFPS := 4000;
end;

//---------------------------------------------------------------------------
procedure TMainForm.FormDestroy(Sender: TObject);
begin
  Devices.Finalize();
  Palette.Free();
end;

//---------------------------------------------------------------------------
procedure TMainForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_ESCAPE) then Close();
end;

//---------------------------------------------------------------------------
procedure TMainForm.DevConfig(Sender: TAsphyreDevice; Tag: TObject;
  var Config: TScreenConfig);
begin
  Config.Width := 1024; //Panel1.Width;
  Config.Height := 768; // Panel1.Height;
  Config.Windowed := true;
  Config.VSync := true;
  Config.BitDepth := bd24bit;


  case Sender.Index of
  0:Config.WindowHandle := Panel1.Handle;
  1:Config.WindowHandle := Panel2.Handle;
  end;

  Config.HardwareTL := false;
  Config.DepthStencil := dsNone;

end;

//---------------------------------------------------------------------------
procedure TMainForm.InitDevice(Sender: TAsphyreDevice);
begin

  case Sender.Index of
  0:
    begin
      ImageIndex[Sender.Index] := Sender.Images.ResolveImage('/images/tile');
      if (ImageIndex[Sender.Index] = -1) then ShowMessage('Failed loading images!');
      
      SpriteEngine[Sender.Index] := TSpriteEngine.Create(nil);
      SpriteEngine[Sender.Index].Device := Sender;
      SpriteEngine[Sender.Index].Image := Sender.Images;
      SpriteEngine[Sender.Index].Canvas := Sender.Canvas;
      SpriteEngine[Sender.Index].VisibleWidth:= Sender.Params.BackBufferWidth;
      SpriteEngine[Sender.Index].VisibleHeight:= Sender.Params.BackBufferHeight;

      CreateMapSprites(Sender);
    end;
    1:
    begin
      ImageIndex[Sender.Index] := Sender.Images.ResolveImage('/images/fire');
      if (ImageIndex[Sender.Index] = -1) then ShowMessage('Failed loading images!');

      SpriteEngine[Sender.Index] := TSpriteEngine.Create(nil);
      SpriteEngine[Sender.Index].Device := Sender;
      SpriteEngine[Sender.Index].Image := Sender.Images;
      SpriteEngine[Sender.Index].Canvas := Sender.Canvas;
      SpriteEngine[Sender.Index].VisibleWidth:= Sender.Params.BackBufferWidth;
      SpriteEngine[Sender.Index].VisibleHeight:= Sender.Params.BackBufferHeight;
    end;
  end;

end;

//---------------------------------------------------------------------------
//---------------------------------------------------------------------------
procedure TMainForm.TimerEvent(Sender: TObject);
const
  Colors: array[0..3] of Cardinal = ($404040, $000080, $003000, $400000);
var
  i: Integer;
begin
  for i := 0 to Devices.Count - 1 do
    Devices[i].Render(DevRender, Self, Colors[i mod 4 ]);

  Timer.Process();
end;

//---------------------------------------------------------------------------
procedure TMainForm.ProcessEvent(Sender: TObject);
begin
  Inc(Ticks);
  SetTileSpriteColor4();
  SpriteEngine[0].Move(1);

  CreateParticleSprite();
  SpriteEngine[1].Move(1);
  SpriteEngine[1].Dead;
end;

procedure TMainForm.CreateParticleSprite;
var
  Pos: TPoint2;
begin
  if ticks mod 4<>0 then exit;

  Pos.x := 400.0 + (Cos(ticks / 130.0) * 150) - (Sin(ticks / 20.0) * 150);
  Pos.y := 356.0 + (Sin(ticks / 30.0) * 150) + (Cos(ticks / 20.0) * 150);
  Inc(ticks);Inc(ticks);
  with P.Create(SpriteEngine[1]) do
  begin
    ImageName := '/images/fire';
    Decay := 0.8;
    LifeTime := 128;
    X := Pos.x;
    Y := Pos.y;
    AnimStart := 0;
    AnimCount := 32;
    DoAnimate := True;
    AnimSpeed := 0.4;
    AnimLooped := false;
    Angle:= Random * Pi * 2.0;
    DrawMode:=1;
  end;

  Pos.x := 500.0 + (Cos(ticks / 130.0) * 150) + (Sin(ticks / 20.0) * 150);
  Pos.y := 356.0 - (Sin(ticks / 30.0) * 150) + (Cos(ticks / 20.0) * 150);
  with P.Create(SpriteEngine[1]) do
  begin
    ImageName := '/images/fire';
    Decay := 0.8;
    LifeTime := 128;
    X := Pos.x;
    Y := Pos.y;
    AnimStart := 0;
    AnimCount := 32;
    DoAnimate := True;
    AnimSpeed := 0.5;
    AnimLooped := false;
    Angle:= Random * Pi * 2.0;
  end;
end;

procedure TMainForm.ResetEvent(Sender: TAsphyreDevice; Tag: TObject;
  var Params: TD3DPresentParameters);
begin
  panel2.Visible := false;
  panel1.Visible := false;
  Button1.Visible := false;
  Button2.Visible := false;
  Button3.Visible := false;
  Label1.Visible := false;
  
//  Params.BackBufferWidth:=800;
//  Params.BackBufferHeight:=600;
  Params.hDeviceWindow := Handle;
  Params.Windowed := false;
end;

//---------------------------------------------------------------------------
procedure TMainForm.DevRender(Sender: TAsphyreDevice; Tag: TObject);
var
  Theta, RibbonLength: Real;
begin
  with Sender.Canvas do
  begin
    SpriteEngine[Sender.Index].Draw;
  end;
  Sender.Fonts.Font['s/tahoma'].TextOutW('FPS: ' + IntToStr(Timer.FrameRate)
      , 900, 10,$FFFFFFFF);
  case Sender.Index of
  0:Sender.Fonts.Font['s/tahoma'].TextOutW('ColorEffect Demo' , 10, 10,$FFFFFFFF);
  1:Sender.Fonts.Font['s/tahoma'].TextOutW('ParticleSprite Demo' , 10, 10,$FFFFFF00);
  end;
end;

end.

