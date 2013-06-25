//-------------------------------------------------------------------------------
//    Origianl work: DraculaLin
//-------------------------------------------------------------------------------
//    Modified:      huaosft(http://www.huosoft.com)               27-Jan-2007
//------------------------------------------------------------------------------
unit MainFm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Vectors2,
  Dialogs, AsphyreDevices, AsphyreTimer, ExtCtrls, AsphyreDef, AsphyreImages, MediaFonts,
  AsphyrePalettes, AsphyreEffects, StdCtrls, AsphyreSprite, AsphyreSpriteUtils;

type
  TKeyDef = (kdKeyUp, kdKeyDown, kdKeyLeft, kdKeyRight, kdKeyCtrl);

  TBullet = class(TParticleSprite)
  Private
    FMoveSpeed: Single;
  Public
    procedure DoMove(const MoveCount: Single); Override;
    procedure DoCollision(const Sprite: TSprite); Override;
    property MoveSpeed: Single Read FMoveSpeed Write FMoveSpeed;
  end;

  TCustomShip = class(TAnimatedSprite)
  Private
    FMoveSpeed: Single;
  Public
    procedure SetAnim(DoMirror: Boolean; APlayMode: TAnimPlayMode);
    property MoveSpeed: Single Read FMoveSpeed Write FMoveSpeed;
  end;

  TTail = class(TAnimatedSprite)
  Private
    FMoveSpeed: Single;
  Public
    procedure DoMove(const MoveCount: Single); Override;
    property MoveSpeed: Single Read FMoveSpeed Write FMoveSpeed;
  end;

  TShip = class(TCustomShip)
  Private
    FShadow: TCustomShip;
    FTail: TTail;
  Public
    constructor Create(const AParent: TSprite); Override;
    procedure DoMove(const MoveCount: Single); Override;
    property Shadow: TCustomShip Read FShadow Write FShadow;
    property Tail: TTail Read FTail Write FTail;
  end;

  TEnemy = class(TAnimatedSprite)
  Private
    FAI: Integer;
    FVelocity1: Single;
    FVelocity2: Single;
    Curve: Integer;
    OriginalX: Single;
    FShadow: TEnemy;
  Public
    procedure DoMove(const MoveCount: Single); Override;
    property AI: Integer Read FAI Write FAI;
    property Velocity1: Single Read FVelocity1 Write FVelocity1;
    property Velocity2: Single Read FVelocity2 Write FVelocity2;
    property Shadow: TEnemy Read FShadow Write FShadow;
  end;

  TCloud = class(TAnimatedSprite)
  Private
    FSize: Single;
    FAdd: Single;
  Public
    procedure DoMove(const MoveCount: Single); Override;
    property Size: Single Read FSize Write FSize;
    property Add: Single Read FAdd Write FAdd;
  end;

  TMainForm = class(TForm)
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
  Public

    ShipEngine: TSpriteEngine;
    Y1, Y2, ticks, DestroyCount: Integer;
    Ship: TShip;
    BackX: Single;
    SpriteEngine: TSpriteEngine;
    Mouse_X, Mouse_Y: Integer;
    DestMsg: string;
    procedure DrawMiniMap(Sender: TAsphyreDevice; Tag: TObject);
    procedure CreateEnemy;
    procedure CreateCloud;
    procedure ProcessEvent(Sender: TObject);
    procedure DevConfig(Sender: TAsphyreDevice; Tag: TObject; var Config: TScreenConfig);
    procedure TimerEvent(Sender: TObject);
    procedure DevRender(Sender: TAsphyreDevice; Tag: TObject);
    procedure InitDevice(Sender: TAsphyreDevice);
    procedure PreloadEvent(Sender: TAsphyreDevice);
  end;

var
  MainForm: TMainForm;
  KeyState: array[0..4] of Boolean;
  KeyReleaseState: array[0..4] of Boolean;

implementation
uses
  AsphyreArchives, AsphyreArcASDb, AsphyreArc7z, MediaImages, CommonUtils;
{$R *.dfm}

procedure TMainForm.FormCreate(Sender: TObject);
begin
  ImageGroups.ParseLink('/media.xml');
  FontGroups.ParseLink('/media.xml');

  Devices.InitEvent:= InitDevice;
  Devices.PreloadEvent:= PreloadEvent;

  if (not Devices.Initialize(DevConfig, Self)) then
  begin
    ShowMessage('Initialization failed.');
    Close();
    Exit;
  end;
  Timer.Enabled := True;
  Timer.OnTimer := TimerEvent;
  Timer.OnProcess := ProcessEvent;
  Timer.Speed := 60;
  Timer.MaxFPS := 4000;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  Devices.Finalize();
end;

procedure TMainForm.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (Key = VK_ESCAPE) then Close();
  if Key = VK_UP then
  begin
    KeyState[Integer(kdKeyUp)] := true;
    KeyReleaseState[Integer(kdKeyUp)] := false;
  end;
  if Key = VK_Down then
  begin
    KeyState[Integer(kdKeyDown)] := true;
    KeyReleaseState[Integer(kdKeyDown)] := false;
  end;
  if Key = VK_Left then
  begin
    KeyState[Integer(kdKeyLeft)] := true;
    KeyReleaseState[Integer(kdKeyLeft)] := false;
  end;
  if Key = VK_Right then
  begin
    KeyState[Integer(kdKeyRight)] := true;
    KeyReleaseState[Integer(kdKeyRight)] := false;
  end;
  if Key = VK_CONTROL then
  begin
    KeyState[Integer(kdKeyCtrl)] := true;
    KeyReleaseState[Integer(kdKeyCtrl)] := false;
  end;


 if (Key = VK_Return)and(ssAlt in Shift) then
  Devices[0].ChangeParams(Devices[0].Params.BackBufferWidth,
   Devices[0].Params.BackBufferHeight, not Devices[0].Params.Windowed);
end;

procedure TMainForm.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
//  TKeyDef=(kdKeyUp,kdKeyDown,kdKeyLeft,kdKeyRight,kdKeyCtrl);
  if Key = VK_UP then
  begin
    KeyState[Integer(kdKeyUp)] := false;
    KeyReleaseState[Integer(kdKeyUp)] := true;
  end;
  if Key = VK_Down then
  begin
    KeyState[Integer(kdKeyDown)] := false;
    KeyReleaseState[Integer(kdKeyDown)] := true;
  end;
  if Key = VK_Left then
  begin
    KeyState[Integer(kdKeyLeft)] := false;
    KeyReleaseState[Integer(kdKeyLeft)] := true;
  end;
  if Key = VK_Right then
  begin
    KeyState[Integer(kdKeyRight)] := false;
    KeyReleaseState[Integer(kdKeyRight)] := true;
  end;
  if Key = VK_CONTROL then
  begin
    KeyState[Integer(kdKeyCtrl)] := false;
    KeyReleaseState[Integer(kdKeyCtrl)] := true;
  end;

end;

procedure TMainForm.CreateCloud;
var
  Cloud: TCloud;
begin
  if Random(100) = 20 then
  begin
    Cloud := TCloud.Create(ShipEngine);
    with Cloud do
    begin
      X := Random(800);
      Y := -Random(600) - 200;
      ImageName := 'cloud' + IntToStr(Random(2));
      ScaleY := 0.7;
      Width := 200;
      Height := 200;
      Size := 1;
      Add := 0.003;
      DoCenter := false;
      DrawFx := fxuAdd;
    end;
  end;
end;

procedure TMainForm.CreateEnemy;
var
  RandEnemy: Integer;
  Enemy: TEnemy;
begin
  for RandEnemy := 0 to 3 do
  begin
    if Random(150) = 25 then
    begin
      Enemy := TEnemy.Create(ShipEngine);
      Enemy.Shadow := TEnemy.Create(ShipEngine);
      with Enemy do
      begin
        X := Random(700);
        Y := -Random(200);
        ImageName := 'Enemy' + IntToStr(Random(5));
        AnimSpeed := 0.35;
        AnimStart := 0;
        AnimCount := 8;
        AnimLooped := True;
        DoAnimate := True;
        CollideMode := cmCircle;
        DoCenter := False;
        Collisioned := True;
        CollideRadius := 16;
        AI := Random(3);
        OriginalX := X;
        Velocity1 := 1;
        Velocity2 := 2;
        width := 64;
        height := 64;
                    //enemy's shadow
        Shadow.X := X + 30;
        Shadow.Y := Y + 30;
        Shadow.ImageName := Imagename;
        Shadow.AnimSpeed := 0.35;
        Shadow.AnimStart := 0;
        Shadow.AnimCount := 8;
        Shadow.AnimLooped := True;
        Shadow.DoAnimate := True;
        Shadow.DoCenter := False;
        Shadow.AI := AI;
        Shadow.OriginalX := X + 40;
        Shadow.Velocity1 := 1;
        Shadow.Velocity2 := 2;
        Shadow.width := 40;
        Shadow.height := 40;
        Shadow.Alpha := 128;
        Shadow.DrawFx := fxuShadow or fxfDiffuse; //fxuShadow or fxfAlphaTest;
        Shadow.ScaleX := 0.7;
        Shadow.ScaleY := 0.7;
      end;
    end;
  end;

end;

procedure TMainForm.DevConfig(Sender: TAsphyreDevice; Tag: TObject;
  var config: TScreenConfig);
begin
  Config.Width := ClientWidth;
  Config.Height := ClientHeight;
  Config.Windowed := true;
  Config.VSync := true;
  Config.BitDepth := bd24bit;
  Config.WindowHandle := Self.Handle;
  Config.HardwareTL := False;
  Config.DepthStencil := dsNone;
end;

procedure TMainForm.InitDevice(Sender: TAsphyreDevice);
begin
  Screen.Cursor := crNone;
  ShipEngine := TSpriteEngine.Create(nil);
  ShipEngine.VisibleWidth := Sender.Params.BackBufferWidth;
  ShipEngine.VisibleHeight := Sender.Params.BackBufferHeight;
  ShipEngine.Device := Sender;
  ShipEngine.Canvas := Sender.Canvas;
  ShipEngine.Image := Sender.Images; ;
  Ship := TShip.Create(ShipEngine);
  Ship.Z := -5;
  BackX := -100;
end;

procedure TMainForm.PreloadEvent(Sender: TAsphyreDevice);
begin
 Sender.Images.ResolveImage('miniMap');
end;

procedure TMainForm.DrawMiniMap(Sender: TAsphyreDevice; Tag: TObject);
var
  sx, sy: integer;
  i: integer;
begin
  with Sender.Canvas do
  begin
    FillRect(Rect(1, 1, 126, 126), $88FF00FF, 0);
    FrameRect(Rect(0, 0, 128, 128), $FFFFFFFF, 0);

    sx := trunc(ship.X / 640 * 128);
    sy := trunc(ship.Y / 640 * 128) + 20;
    FillTri(sX, sY, sx - 5, sY + 10, sX + 5, sy + 10, $FFFFFF00, $FFFFFF00, $FFFFFF00, 0);

    for i := 0 to shipengine.Count - 1 do
      if (shipengine[i] is TEnemy) and (shipengine[i].Width > 40)
        and (shipengine[i].ImageName <> 'explode') then
      begin
        sx := trunc(shipengine[i].X / 640 * 128);
        sy := trunc(shipengine[i].Y / 640 * 128) + 20;
        PutPixel(sx + 2, sy + 2, $FFFF0000, 0);
        FrameRect(Rect(sx, sy, sx + 5, sy + 5), $FFFFFFFF, 0);
//      FillCircle(sx, sy, 1.5 ,80 ,clWhite4,0);
//       Circle(sx, sy, 3 ,80 ,$FFFF0000);
      end;

  end;


end;

procedure TMainForm.TimerEvent(Sender: TObject);
begin
  Devices[0].DrawOnSurf(0, DrawMiniMap, Self, $000000);
  Devices[0].Render(DevRender, Self, $FF88BB88);
  Timer.Process();
end;

procedure TMainForm.ProcessEvent(Sender: TObject);
var
  i: Integer;
  Bullet: TBullet;
begin
  ShipEngine.Dead;
  ShipEngine.Move(1);

  if KeyState[Integer(kdKeyLeft)] then
    BackX := BackX + 0.25;
  if KeyState[Integer(kdKeyRight)] then
    BackX := BackX - 0.25;
  if BackX < -130 then BackX := -130;
  if BackX > 0 then BackX := 0;

  Y1 := Y1 - 1;
  Y2 := Y2 + 1;
  CreateEnemy;
  CreateCloud;

  INC(ticks);
  if KeyState[Integer(kdKeyCtrl)] and (ticks mod 10 = 0) then
  begin
    for i := 0 to 2 do
    begin
      Bullet := TBullet.Create(ShipEngine);
      Bullet.Collisioned := true;
      Bullet.CollideMode := cmCircle;
      Bullet.CollideRadius := 5;
      Bullet.MoveSpeed := 7;
      Bullet.VelocityX:= 1-i  ;
      Bullet.UpdateSpeed:=1;
      Bullet.DoCenter := False;
      Bullet.X := ship.X - i * 20 + 10;
      Bullet.Y := ship.Y - 10;
      Bullet.ImageName := 'Bulletr';
      Bullet.DrawFx := fxuAdd;
      Bullet.ScaleX := 0.1;
      Bullet.ScaleY := 0.15;
      Bullet.MirrorY := True;
      Bullet.DrawMode := 1;
    end;
  end;


end;

procedure TMainForm.DevRender(Sender: TAsphyreDevice; Tag: TObject);
begin
 DrawPortion(Sender.Canvas, Sender.Images.Image['jungle'], 0, BackX, 0, 0, Y1,
    800, 1024 + Y2, clWhite4, fxuNoBlend);

  ShipEngine.Draw;

  with Sender.Canvas do
  begin
    UseImage(Sender.Images[0], TexFull4);
//    TexMap(pBounds4(511, 1, 128, 128), clWhite4, fxuBlend);
    TexMap(pBounds4(511, 358, 128, 128), clWhite4, fxuBlend);
  end;

  Sender.Fonts.Font['s/tahoma'].TextOutW('FPS: ' + IntToStr(Timer.FrameRate),
    580, 8, $FFFFFFFF);
  Sender.Fonts.Font['s/tahoma'].TextOutW('SpriteCount: ' + IntToStr(ShipEngine.Count),
    10, 8, $FFFFFFFF);
  Sender.Fonts.Font['s/tahoma'].TextOutW('Destroyed  : ' + IntToStr(DestroyCount),
    10, 28, $FFFFFFFF);
  Sender.Fonts.Font['s/tahoma'].TextOutW('Shooter demo For SpriteEngine4 (Powered by Asphyre4)',
    10, 460, $FFFFFFFF);
end;

{ TBullet }

procedure TBullet.DoMove(const MoveCount: Single);
begin
  inherited;
  Y := Y - FMoveSpeed;
  if Y < 0 then
  begin
    Dead;
    Visible := False;
  end;
  CollidePos := Point2(X + 13, Y + 8);

  Collision;
end;


procedure TBullet.DoCollision(const Sprite: TSprite);
begin
  if (Sprite is TEnemy) then
  begin
    Collisioned := False;
    Visible := False;
    Dead;
    with TEnemy(Sprite) do
    begin
      DrawFx := fxuAdd;
      ImageName := 'explode';
      AnimCount := 32;
      AnimSpeed := 0.35;
      AnimLooped := False;
      Shadow.Dead;
      Inc(Mainform.DestroyCount);
    end;
  end;

end;

{ TEnemy }

procedure TEnemy.DoMove(const MoveCount: Single);
begin
  inherited;

  CollidePos := Point2(X + 32, Y + 32);
  if ImageName = 'explode' then
  begin
    Collisioned := False;
    Velocity1 := 0;
    Velocity2 := 0;
    if Trunc(AnimPos) = 31 then
      Dead;
  end;
    // AI = 0 just move the enemy downwards
    // AI = 1 move the enemy down in a nice sinus curve
    // AI = 2 make the enemy hunt the player
  case FAI of
    0:
      begin
        Y := Y + Velocity2;
      end;
    1:
      begin
        Y := Y + Velocity1;
        Curve := Curve + Round(Velocity1);
        X := OriginalX + Round(100 * sin(2 * PI * Curve / 360));
      end;
    2:
      begin
        Y := Y + Velocity2;
        if MainForm.Ship.X > X then X := X + Velocity1;
        if MainForm.Ship.X < X then X := X - Velocity1;
      end;
  end;
     // if the enemy goes out of screen clear it out of memory
  if (Y > 600) then
  begin
    Dead;
    Visible := False;
    Collisioned := False;
  end;

end;

{ TShip }

constructor TShip.Create(const AParent: TSprite);
begin
  inherited;
  X := 300;
  Y := 300;
  ScaleX := 0.5;
  ScaleY := 0.5;
  MoveSpeed := 3;
  ImageName := 'ship4';
  AnimLooped := false;
  DrawMode := 1;

  // self shadow
  Shadow := TCustomShip.Create(MainForm.ShipEngine);
  Shadow.X := 290;
  Shadow.Y := 260;
  Shadow.AnimLooped := false;
  Shadow.ScaleX := 0.4;
  Shadow.ScaleY := 0.4;
  Shadow.MoveSpeed := 2;
  Shadow.Red := 0;
  Shadow.Green := 0;
  Shadow.Blue := 0;
  Shadow.Alpha := 128;
  Shadow.DrawFx := fxuShadow or fxfDiffuse;
  Shadow.ImageName := 'ship4';
  Shadow.DrawMode := 1;
  //
  Tail := TTail.Create(MainForm.ShipEngine);
  Tail.X := 300;
  Tail.Y := 333;
  Tail.ScaleX := 0.5;
  Tail.ScaleY := 0.65;
  Tail.MoveSpeed := 2;
  Tail.ImageName := 'tail';
  Tail.AnimSpeed := 0.2;
  Tail.AnimStart := 0;
  Tail.AnimCount := 3;
  Tail.AnimLooped := True;
  Tail.DoAnimate := True;
  Tail.DrawFx := fxuAdd;
  Tail.DrawMode := 1;
end;

{ TCloud }

procedure TCloud.DoMove(const MoveCount: Single);
begin
  inherited;
  Y := Y + 0.8;
  FSize := FSize + FAdd;
  if (FSize > 1) or (FSize < 0.9) then FAdd := -FAdd;
  ScaleX := FSize;
//     if MainForm.Keyboard.Key[205] then
//          X := X - 0.35;
//
//     if MainForm.Keyboard.Key[203] then
//          X := X +0.35;
  if Y > 600 then
  begin
    Dead;
    Visible := False;
  end;

end;

{ TCustomShip }

procedure TShip.DoMove(const MoveCount: Single);
begin
  inherited;
    //move Right
  if KeyState[Integer(kdKeyRight)] then
  begin
    X := X + FMoveSpeed;
    if X > 600 then X := 600;
    Shadow.X := Shadow.X + Shadow.FMoveSpeed;
    if Shadow.X > 600 then Shadow.X := 600;
    if Round(AnimPos) = 0 then
    begin
      SetAnim(False, pmForward);
      Shadow.SetAnim(False, pmForward);
    end;
  end;

  if KeyReleaseState[Integer(kdKeyRight)] then
  begin
    SetAnim(False, pmBackward);
    Shadow.SetAnim(False, pmBackward);
    KeyReleaseState[Integer(kdKeyRight)] := false;
  end;

     //move left
  if KeyState[Integer(kdKeyLeft)] then
  begin
    X := X - FMoveSpeed;
    if X < 10 then X := 10;
    Shadow.X := Shadow.X - Shadow.FMoveSpeed;
    if Shadow.X < 10 then Shadow.X := 10;
    if Round(AnimPos) = 0 then
    begin
      SetAnim(True, pmForward);
      Shadow.SetAnim(True, pmForward);
    end;
  end;

  if KeyReleaseState[Integer(kdKeyLeft)] then
  begin
    SetAnim(true, pmBackward);
    Shadow.SetAnim(true, pmBackward);
    KeyReleaseState[Integer(kdKeyLeft)] := false;
  end;

  if KeyState[Integer(kdKeyUp)] then
  begin
    Y := Y - FMoveSpeed;
    if Y < 40 then Y := 40;
    Shadow.Y := Shadow.Y - Shadow.FMoveSpeed;
    if Shadow.Y < 40 then Shadow.Y := 40;
  end;

  if KeyState[Integer(kdKeyDown)] then
  begin
    Y := Y + FMoveSpeed;
    if Y > 420 then Y := 420;
    Shadow.Y := Shadow.Y + Shadow.FMoveSpeed;
    if Shadow.Y > 420 then Shadow.Y := 420;
  end;
end;

procedure TCustomShip.SetAnim(DoMirror: Boolean; APlayMode: TAnimPlayMode);
begin
  MirrorX := DoMirror;
//  AnimStart := 0;
  AnimPlayMode := APlayMode;
  AnimCount := 4;
  AnimSpeed := 0.15;
  DoAnimate := True;
end;

{ TTail }

procedure TTail.DoMove(const MoveCount: Single);
begin
  inherited;
  X := MainForm.Ship.x;
  Y := MainForm.Ship.Y + 32;
end;

end.

