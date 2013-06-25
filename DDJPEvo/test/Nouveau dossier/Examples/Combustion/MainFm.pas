//-------------------------------------------------------------------------------
//  port from Combustion of Asphyre310 to Asphyre4 and SpriteEngine
//  huasoft(»ðÈË) (www.huosoft.com)                            24-Jan-2007
//-------------------------------------------------------------------------------
unit MainFm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,Direct3D9,
  Dialogs, AsphyreDevices, AsphyreTimer, ExtCtrls, AsphyreDef, AsphyreImages,
  AsphyrePalettes, AsphyreEffects, StdCtrls, AsphyreSprite, MediaFonts;

type
  TMainForm = class(TForm)
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  Private
    { Private declarations }
    Ticks: Integer;
    Color1: Integer;
    Color2: Integer;
    Opacity: Integer;
    Background: Cardinal;
    procedure DevConfig(Sender: TAsphyreDevice; Tag: TObject; var Config: TScreenConfig);
    procedure TimerEvent(Sender: TObject);
    procedure DevRender(Sender: TAsphyreDevice; Tag: TObject);
    procedure ProcessEvent(Sender: TObject);
    procedure PreloadEvent(Sender: TAsphyreDevice);
    procedure ResetEvent(Sender: TAsphyreDevice; Tag: TObject;
      var Params: TD3DPresentParameters);
  Public
    SpriteEngine: TSpriteEngine;
  end;

var
  MainForm: TMainForm;

implementation
uses
  AsphyreArchives, AsphyreArcASDb, AsphyreArc7z, MediaImages, CommonUtils;
{$R *.dfm}

procedure TMainForm.FormCreate(Sender: TObject);
begin
  Register7z('.7z');
  ImageGroups.ParseLink('/media.xml');
  FontGroups.ParseLink('/media.xml');

  Devices.PreloadEvent:= PreloadEvent;
  Devices.Count := 1; //Devices.DisplayCount;
  if (not Devices.Initialize(DevConfig, Self)) then
  begin
    ShowMessage('Initialization failed.');
    Close();
    Exit;
  end;
  Timer.Enabled := True;
  Timer.OnTimer := TimerEvent;
  Timer.OnProcess := ProcessEvent;
  Timer.MaxFPS := 2000;

  Ticks := 0;
  Color1 := $7F0000;
  Color2 := $7F0000;
  Opacity := 0;
end;


//---------------------------------------------------------------------------
procedure TMainForm.PreloadEvent(Sender: TAsphyreDevice);
begin
  Sender.Images.ResolveImage('/images/fire');
  Sender.Images.ResolveImage('/images/powerdraw');
  Sender.Images.ResolveImage('/images/scanline');

  SpriteEngine := TSpriteEngine.Create(nil);
  SpriteEngine.VisibleWidth := Sender.Params.BackBufferWidth;
  SpriteEngine.VisibleHeight := Sender.Params.BackBufferHeight;
  SpriteEngine.Device := Sender;
  SpriteEngine.Image := Sender.Images;
  SpriteEngine.Canvas := Sender.Canvas;

  with TTileMapSprite.Create(SpriteEngine) do
  begin
    ImageName := '/images/scanline';
    Width := 64;
    Height := 64;
    SetMapSize(SpriteEngine.VisibleWidth div Width, SpriteEngine.VisibleHeight div Height);
    DoTile := true;
    DrawMode := 1;
    Z := 0;
    DrawFx := fxuMultiply;
  end;
end;

//---------------------------------------------------------------------------
procedure TMainForm.ProcessEvent(Sender: TObject);
var
  i: Integer;
  Effect: Cardinal;
begin
  SpriteEngine.Dead;
  SpriteEngine.Move(1);

 // drop some particles randomly at the bottom of the screen
  for i := 0 to 15 do
    if (Random(4) = 0) then
      with TParticleSprite.Create(SpriteEngine) do
      begin
        ImageName := '/images/fire';
        Decay := 1;
        UpdateSpeed := 1;
        LifeTime := 64;
        X := Random(640);
        Y := 480; //self.Height;
        Z := 1;
        AnimStart := 0;
        AnimCount := 32;
        DoAnimate := True;
        AnimSpeed := 0.5;
        AccelX := 0.0;
        AccelY := -(0.005 + (Random(10) / 200));
        VelocityX := (Random(10) - 5) / 20;
        VelocityY := -(Random(20) / 4);
        AnimLooped := false;
        DrawFx := fxuBlend;
        Angle := Random * Pi * 2.0;
        DrawMode := 1;
      end;

  Inc(Ticks);
  Inc(Opacity);
  if (Opacity > 255) then
  begin
    Color1 := Color2;
    Color2 := Random(255) + (Random(255) shl 8) + (Random(255) shl 16);
    Opacity := 0;
  end;
 // prepare background color
 Background := $FF000000 or Cardinal(BlendPixels(Color2, Color1, Opacity));

end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  Devices.Finalize();
end;

procedure TMainForm.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (Key = VK_ESCAPE) then Close();

  // ALT + ENTER: Switch Windowed / Fullscreen
  if (Key = VK_RETURN)and(ssAlt in Shift) then
    Devices[0].Reset(ResetEvent, self);

end;

procedure TMainForm.ResetEvent(Sender: TAsphyreDevice; Tag: TObject;
  var Params: TD3DPresentParameters);
begin
  Params.Windowed := not Params.Windowed;
  if  Params.Windowed then self.BorderStyle:=bsSingle;
  
end;


procedure TMainForm.DevConfig(Sender: TAsphyreDevice; Tag: TObject;
  var config: TScreenConfig);
begin
  Config.Width := 640; //ClientWidth;
  Config.Height := 480; //ClientHeight;
  Config.Windowed := true;
  Config.VSync := true;
  Config.BitDepth := bd24bit;
  Config.WindowHandle := Self.Handle;
  Config.DepthStencil := dsNone;
end;

procedure TMainForm.TimerEvent(Sender: TObject);
begin
  Devices[0].Render(DevRender, Self, Background);
  Timer.Process();
end;

procedure TMainForm.DevRender(Sender: TAsphyreDevice; Tag: TObject);
begin
  with Sender.Canvas do
  begin
    SpriteEngine.Draw;

    useimage(sender.Images.image['/images/powerdraw'], 0);
    sender.Canvas.TexMap(pbounds4(80, 160, 240, 128), clWhite4, fxfAlphaTest);
    useimage(sender.Images.image['/images/powerdraw'], 1);
    sender.Canvas.TexMap(pbounds4(320, 160, 240, 128), clWhite4, fxfAlphaTest);
  end;
  
  Sender.Fonts.Font['s/tahoma'].TextOutW('FPS: ' + IntToStr(Timer.FrameRate)+
      '   Sprites:'+IntToStr(SpriteEngine.Count), 10, 10,$FFFFFFFF);
end;

end.

