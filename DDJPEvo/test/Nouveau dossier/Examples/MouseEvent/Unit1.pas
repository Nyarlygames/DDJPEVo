unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,AsphyreDevices, AsphyreTimer, ExtCtrls, AsphyreDef, AsphyreImages,
  AsphyrePalettes, AsphyreEffects, StdCtrls, AsphyreSprite, AsphyreSpriteEffects,
  AsphyreSpriteUtils;

type
  TMoveDirection=(mdLeft,mdRight);

  TSheep=class(TAnimatedSprite)
  private
     FMoveSpeed: Single;
     FMoveDirection: TMoveDirection;
  public
     procedure DoMove(const MoveCount: Single); override;
     procedure OnMouseClick; override;
     procedure OnMouseDbClick; override;
     procedure OnMouseLeave; override;
     procedure OnMouseEnter; override;
     procedure OnMouseDrag; override;
     procedure OnMouseRClick; override;
     procedure OnMouseWheel; override;
     procedure OnAnimEnd; override;
     property MoveSpeed: Single read  FMoveSpeed write  FMoveSpeed;
     property MoveDirection: TMoveDirection read FMoveDirection write FMoveDirection;
  end;

  TMainForm = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    procedure DevConfig(Sender: TAsphyreDevice; Tag: TObject;   var Config: TScreenConfig);
    procedure TimerEvent(Sender: TObject);
    procedure DevRender(Sender: TAsphyreDevice; Tag: TObject);
    procedure InitDevice(Sender: TAsphyreDevice);
    procedure DoneDevice(Sender: TAsphyreDevice);
    { Private declarations }
  public
     SpriteEngine: TSpriteEngine;
    { Public declarations }
  end;

var
  MainForm: TMainForm;
  OffsetW,OffsetH: Integer;

implementation
    uses
AsphyreArchives,  MediaImages, CommonUtils, MediaFonts;
{$R *.dfm}

procedure TSheep.OnMouseEnter;
begin
     SetColor(255,150,255);

end;

procedure TSheep.OnMouseLeave;
begin
     Setcolor(255,255,255);
end;

procedure TSheep.OnMouseClick;
begin
     OffsetW:= Round(X-Mouse.CursorPos.X);
     OffsetH:= Round(Y-Mouse.CursorPos.Y);
     FMoveSpeed:= 0.5;
end;

procedure TSheep.OnMouseDbClick;
begin
     SetAnim('Run', 0, 2, 0.1, True);
     FmoveSpeed:=1;
end;

procedure TSheep.OnMouseDrag;
begin
     X:= Mouse.CursorPos.X+OffsetW;
     Y:= Mouse.CursorPos.Y+OffsetH;
     SetAnim('Scare', 0, 6, 0.1, True);
end;

procedure TSheep.OnMouseRClick;
begin
     SetAnim('HandStand', 0, 2, 0.1, True);
     FMoveSpeed:=0.5;
end;

procedure TSheep.OnMouseWheel;
begin
     SetAnim('Rolling', 0, 8, 0.15, True);
     FMoveSpeed:=1;
end;

procedure TSheep.DoMove(const movecount: Single);
begin
     inherited;
     ActiveRect:=Rect(Round(X), Round(Y), Round(X+40), Round(Y+40));
     case FMoveDirection of
         mdLeft:
         begin
              X:=X- FMoveSpeed;
              MirrorX:= True;
         end;
         mdRight:
         begin
              X:=X+ FMoveSpeed;
              MirrorX:= False;
         end;
     end;
     if (X>750) then FMovedirection:= mdLeft;
     if (X<10)  then FMovedirection:= mdRight;
     DoMouseDrag;
end;

procedure TSheep.OnAnimEnd;
begin
     if ImageName= 'Scare' then
        SetAnim('Walk', 0, 2, 0.1, True);
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
     Randomize;
     ImageGroups.ParseLink('/media.xml');
     FontGroups.ParseLink('/media.xml');
     Devices.InitEvent:= InitDevice;
     Devices.DoneEvent:= DoneDevice;
     Devices.Count:= 1;//Devices.DisplayCount;
     if (not Devices.Initialize(DevConfig, Self)) then
     begin
         ShowMessage('Initialization failed.');
         Close();
         Exit;
     end;
     Timer.Enabled:= True;
     Timer.OnTimer:= TimerEvent;
     Timer.MaxFPS:= 4000;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
     Devices.Finalize();
end;

procedure TMainForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
     if (Key = VK_ESCAPE) then Close();
end;

procedure TMainForm.DevConfig(Sender: TAsphyreDevice; Tag: TObject;
  var config: TScreenConfig);
begin
     Config.Width   := 800;
     Config.Height  := 600;
     Config.Windowed:= False;
     Config.VSync   := True;
     Config.BitDepth:= bd24Bit;
     Config.WindowHandle:= Self.Handle;
     Config.HardwareTL  := False;
     Config.DepthStencil:= dsNone;
end;

procedure TMainForm.InitDevice(Sender: TAsphyreDevice);
var
   i: Integer;
begin
     Sender.Images.ResolveImage('walk');
     // Sender.Canvas.Antialias:= False;
     SpriteEngine := TSpriteEngine.Create(nil);
     SpriteEngine.Device:=Sender;
     SpriteEngine.Image := Sender.Images;
     SpriteEngine.Canvas := Sender.Canvas;
     Spriteengine.DoMouseEvent := True;
     for i := 0 to 20 do
     begin
          with TSheep.Create(SpriteEngine) do
          begin
               SetAnim('Walk',0,2,0.1,True);
               DoAnimate:=True;
               DrawFx:= fxfDiffuse or fxublend;
               Width:=40;
               Height:=40;
               X := Random(750);
               Y := Random(550);
               FMoveSpeed:=0.5;
               FMoveDirection:=TMoveDirection(Random(2));
               Tag:= i;
          end;
     end;
end;

procedure TMainForm.DoneDevice(Sender: TAsphyreDevice);
begin

end;

procedure TMainForm.TimerEvent(Sender: TObject);
begin
     Devices[0].Render(0, DevRender, Self, cRGB1(255,255,0));
     Timer.Process();
end;

procedure TMainForm.DevRender(Sender: TAsphyreDevice; Tag: TObject);
begin
     DrawEx(Sender.Canvas,Sender.Images.Image['Background'], 0, 0, 0, clWhite4, fxuBlend);
     SpriteEngine.Draw;
     SpriteEngine.Move(1);
     Sender.Fonts.Font['s/tahoma'].TextOut('"Mouse Click" to make The sheet scare', 200, 480,cRGB1(250,200,0));
     Sender.Fonts.Font['s/tahoma'].TextOut('"Mouse Double Click" to make the sheet run', 200, 500,cRGB1(250,200,0));
     Sender.Fonts.Font['s/tahoma'].TextOut('"Mouse Drag" to move the sheet', 200, 520,cRGB1(250,200,0));
     Sender.Fonts.Font['s/tahoma'].TextOut('"Mouse Wheel" to make the sheet rolling', 200, 540,cRGB1(250,200,0));
     Sender.Fonts.Font['s/tahoma'].TextOut('"Mouse Right Click" to make the sheet handstand', 200, 560,cRGB1(250,200,0));
end;

end.
