unit MainFm;

//---------------------------------------------------------------------------
interface

//---------------------------------------------------------------------------
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, AsphyreDevices, AsphyreTimer, AsphyrePalettes,
  AsphyreFonts;

//---------------------------------------------------------------------------
type
  TMainForm = class(TForm)
    PrimaryPanel: TPanel;
    Label1: TLabel;
    AuxiliaryPanel: TPanel;
    Label2: TLabel;
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    Ticks: Integer;
    Chain: array[0..3] of Integer;

    DrawIndex: Integer;
    MixIndex : Integer;
    Palette  : TAsphyrePalette;

    DrawTicks: Integer;

    procedure SetupDevice(Sender: TAsphyreDevice; Tag: TObject;
     var Config: TScreenConfig);
    procedure TimerEvent(Sender: TObject);
    procedure ProcessEvent(Sender: TObject);
    procedure RenderPrimary(Sender: TAsphyreDevice; Tag: TObject);
    procedure RenderSecondary(Sender: TAsphyreDevice; Tag: TObject);
    procedure DrawMotion(Sender: TAsphyreDevice; Tag: TObject);
    procedure MixDrawings(Sender: TAsphyreDevice; Tag: TObject);
    procedure PreloadEvent(Sender: TAsphyreDevice);
    procedure ResolveFailed(Sender: TObject; const Symbol: string);
  public
    { Public declarations }
  end;

//---------------------------------------------------------------------------
var
  MainForm: TMainForm;

//---------------------------------------------------------------------------
implementation
uses
 AsphyreDef, AsphyreEffects, MediaImages, MediaFonts, Vectors2;
{$R *.dfm}

//---------------------------------------------------------------------------
const
 OrigPx0: TPoint2 = (x:   0 + 4; y: 0 + 4);
 OrigPx1: TPoint2 = (x: 256 - 1; y: 0 + 3);
 OrigPx2: TPoint2 = (x: 256 - 3; y: 256 - 1);
 OrigPx3: TPoint2 = (x:   0 + 1; y: 256 - 4);

//---------------------------------------------------------------------------
procedure TMainForm.FormCreate(Sender: TObject);
begin
 Palette:= TAsphyrePalette.Create();
 Palette.Add($FF9100FF, 0.0);
 Palette.Add($FF617BFF, 0.25);
 Palette.Add($FFFF6F00, 0.5);
 Palette.Add($FFFFB700, 0.75);
 Palette.Add($FFFFFFFF, 1.0);

 // retreive image and font descriptions
 ImageGroups.ParseLink('/media.xml');
 FontGroups.ParseLink('/media.xml');

 // configure Asphyre device(s)
 Devices.Count:= 1;
 Devices.PreloadEvent:= PreloadEvent;
 if (not Devices.Initialize(SetupDevice, Self)) then
  begin
   MessageDlg('Failed to initialize Asphyre device', mtError, [mbOk], 0);
   Close();
   Exit;
  end;

 // configure Asphyre timer
 Timer.Enabled  := True;
 Timer.OnTimer  := TimerEvent;
 Timer.OnProcess:= ProcessEvent;
 Timer.MaxFPS   := 4000;

 DrawIndex:= 0;
 MixIndex := 0;
end;

//---------------------------------------------------------------------------
procedure TMainForm.FormDestroy(Sender: TObject);
begin
 Devices.Finalize();
 Palette.Free();
end;

//---------------------------------------------------------------------------
procedure TMainForm.SetupDevice(Sender: TAsphyreDevice; Tag: TObject;
 var Config: TScreenConfig);
begin
 // configure Asphyre device
 Config.Width   := 256;
 Config.Height  := 256;
 Config.Windowed:= True;

 Config.WindowHandle:= Self.Handle;
 Config.HardwareTL  := False;

 
 // configure resolution events
 Sender.Images.OnResolveFailed:= ResolveFailed;
 Sender.Fonts.OnResolveFailed := ResolveFailed;
end;

//---------------------------------------------------------------------------
procedure TMainForm.PreloadEvent(Sender: TAsphyreDevice);
const
 ChainNames: array[0..3] of string = ('draw-1',
  'draw-2', 'mix-1', 'mix-2');
var
 i: Integer;
begin
 with Sender do
  begin
   for i:= 0 to High(ChainNames) do
    Chain[i]:=  Images.ResolveImage(ChainNames[i]);
  end;
end;

//---------------------------------------------------------------------------
procedure TMainForm.ResolveFailed(Sender: TObject; const Symbol: string);
begin
 MessageDlg('Failed to resolve symbol ' + Symbol , mtError, [mbOk], 0);

 // make sure the application is terminated
 Devices.Finalize();
 Timer.Enabled:= False;
 Application.Terminate();
end;

//---------------------------------------------------------------------------
procedure TMainForm.TimerEvent(Sender: TObject);
begin
 Devices[0].DrawOnSurf(Chain[DrawIndex xor 1], DrawMotion, Self, $000000);
 Devices[0].DrawOnSurf(Chain[2 + (MixIndex xor 1)], MixDrawings, Self);

 if (DrawTicks and $03 = 0) then
  Devices[0].Render(PrimaryPanel.Handle, RenderPrimary, Self, $000080);

 Devices[0].Render(AuxiliaryPanel.Handle, RenderSecondary, Self, $000000);

 DrawIndex:= DrawIndex xor 1;
 MixIndex := MixIndex xor 1;

 Timer.Process();

 Inc(DrawTicks);

 Caption:= 'Targets''n''Panels, FPS: ' + IntToStr(Timer.FrameRate);
end;

//---------------------------------------------------------------------------
procedure TMainForm.ProcessEvent(Sender: TObject);
begin
 Inc(Ticks);
end;

//---------------------------------------------------------------------------
procedure TMainForm.RenderPrimary(Sender: TAsphyreDevice; Tag: TObject);
begin
 with Sender.Canvas do
  begin
   // Draw some random primitives.
   FillQuad(pBounds4(2, 2, 50, 50), cColor4($FF00FF00, $FFFF0000, $FF0000FF,
    $FFFFFFFF), fxuNoBlend);

   FillQuad(pBounds4(54, 2, 50, 50), cColor4($FF000000, $FFFF00FF, $FFFFFF00,
    $FF00FFFF), fxuNoBlend);

   FillQuadEx(pBounds4(2, 54, 50, 50), cColor4($FF00FF00, $FFFF0000, $FF0000FF,
    $FFFFFFFF), fxuNoBlend);

   FillQuadEx(pBounds4(54, 54, 50, 50), cColor4($FF000000, $FFFF00FF,
    $FFFFFF00, $FF00FFFF), fxuNoBlend);

   FillArc(150, 150, 80, 70, Pi / 8, (Pi / 4) + Pi, 24, cColor4($FF00FF00,
    $FFFF0000, $FF0000FF, $FFFFFFFF), fxuNoBlend);

   // Draw the "motion" scene with alpha-channel on top of everything.
   UseImage(Sender.Images[Chain[DrawIndex]], pFlip4(pBounds4(0.0, 0.0, 1.0,
    1.0)));
   TexMap(pBounds4(0, 0, 256, 256), clWhite4, fxuBlend);
  end;

 Sender.Fonts.Font['s/tahoma'].TextOut('System Font!', 4, 230, $FFFFFFFF);
 Sender.Fonts.Font['s/tahoma'].TextOutW('Unicode string :-)', 4, 210,
  $FF9745FF);
end;

//---------------------------------------------------------------------------
procedure TMainForm.RenderSecondary(Sender: TAsphyreDevice; Tag: TObject);
begin
 with Sender.Canvas do
  begin
   // Just render the "mixed" scene on the second panel.
   UseImage(Sender.Images[Chain[2 + MixIndex]], TexFull4);
   TexMap(pBounds4(0, 0, 256, 256), clWhite4, fxuBlend);

   with Sender.Fonts.Font['x/warmachine'] as TAsphyreBitmapFont do
    begin
     Kerning:= -4;
     TextOut('Future is here!', -2, 230, $FFFFFFFF);
    end;
  end;

 with Sender.Fonts.Font['x/acidreamer'] as TAsphyreBitmapFont do
  begin
   Kerning:= -6;
   TextOutFx('Some weird fonts can also be displayed', 0, 100, $FF7E00FF,
    $FFFFFFFF, fxuBlend or fxfDiffuse);
  end;

 with Sender.Fonts.Font['x/smallpaulo'] as TAsphyreBitmapFont do
  begin
   Kerning:= 1;
   TextOut('This damn tiny font has no antialiasing!', 4, 30, $FFFFFFFF);
  end;
end;

//---------------------------------------------------------------------------
procedure TMainForm.DrawMotion(Sender: TAsphyreDevice; Tag: TObject);
var
 Theta, RibbonLength: Real;
begin
 // Draw some motion - moving ribbons and two soldiers moving from separate
 // directions.
 with Sender.Canvas do
  begin
   Theta:= (Ticks mod 200) * Pi / 100;
   RibbonLength:= (1.0 + Sin(Ticks / 50.0)) * Pi * 2 / 3 + (Pi / 3);

   FillRibbon(128, 128 - 32, 16.0, 24.0, 48.0, 32.0, Theta, Theta +
    RibbonLength, 24, Palette, fxuBlend or fxfDiffuse);

   Theta:= (-Ticks mod 100) * Pi / 50;
   RibbonLength:= (1.0 + Cos(Ticks / 37.0)) * Pi * 2 / 3 + (Pi / 3);

   FillRibbon(128, 128 + 32, 24.0, 16.0, 32.0, 48.0, Theta, Theta +
    RibbonLength, 24, Palette, fxuAdd or fxfDiffuse);

   Sender.Fonts.Font['s/tahoma'].TextOut('Welcome!', -32 + (Ticks mod 288),
    180, $FFFFFFFF);
  end;
end;

//---------------------------------------------------------------------------
procedure TMainForm.MixDrawings(Sender: TAsphyreDevice; Tag: TObject);
begin
 with Sender.Canvas do
  begin
   // Copy previous scene, englarged and slightly rotated.
   UseImage(Sender.Images[Chain[2 + MixIndex]], Point4(OrigPx0 / 256.0,
    OrigPx1 / 256.0, OrigPx2 / 256.0, OrigPx3 / 256.0));
   TexMap(pBounds4(0, 0, 256, 256), clWhite4, fxuNoBlend);

   // Darken the area slightly, to avoid color mess :)
   // Replace color parameter to $FFF0F0F0 to reduce the effect.
   FillRect(0, 0, 256, 256, $FFF8F8F8, fxuMultiply);

   // Add the "motion scene" on our working surface. 
   UseImage(Sender.Images[Chain[DrawIndex]], TexFull4);
   TexMap(pBounds4(0, 0, 256, 256), cAlpha4(32), fxuAdd or fxfDiffuse);
  end;
end;

//---------------------------------------------------------------------------
end.
