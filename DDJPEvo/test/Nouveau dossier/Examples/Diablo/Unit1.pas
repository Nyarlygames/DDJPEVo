unit Unit1;
//-------------------------------------------------------------------------------
//  port from DIABLO2 of Asphyre310 to Asphyre4 and SpriteEngine
//  huasoft(»ðÈË) (www.huosoft.com)                            28-Jan-2007
//-------------------------------------------------------------------------------
//---------------------------------------------------------------------------
// simple DIABLO-like game  Example                      Modified: 12-Feb-2006
// Copyright (c) 2000 - 2006  Afterwarp Interactive
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
//---------------------------------------------------------------------------
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  AsphyreSpriteUtils, Dialogs, AsphyreCanvas, AsphyreDevices, Math, Vectors2,
  AsphyreSpriteEffects, AsphyreEffects, MediaFonts, MediaImages, AsphyreTimer,
  AsphyreDb, AsphyreImages, AsphyreDef, AsphyreSprite;

type
  TMainForm = class(TForm)
    procedure DeviceInitialize(Sender: TAsphyreDevice);
    procedure TimerTimer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure DeviceRender(Sender: TAsphyreDevice; Tag: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  Public
          { Public declarations }
    procedure CreateTiles(ArrayA, ArrayB, OffsetX, OffsetY: Integer);
    procedure DrawTiles;
    procedure CreateMonsters(ArrayA, ArrayB: Integer);
    procedure DrawMonsters;
    procedure CreateHero;
    procedure DrawHero;
    procedure DevConfig(Sender: TAsphyreDevice; Tag: TObject; var config: TScreenConfig);
    procedure DevicePreload(Sender: TAsphyreDevice);
  end;

  TShadowSprite = class;

  TTile = class(TAnimatedSprite);

  TLight = class(TAnimatedSprite);

  TFinger = class(TAnimatedSprite)
  Public
    procedure DoMove(const MoveCount: Single); Override;
    procedure DoCollision(const Sprite: TSprite); Override;
  end;

  TCharacter = class(TAnimatedSprite)
  Private
    FWalkSpeed: Single;
    FDirection: Integer;
    FFramePerDir: Integer;
    FShadow: TShadowSprite;
  Protected
    procedure SetDirectionAnim; Virtual;
    procedure GoDirection8; Virtual;
  Public
    constructor Create(const AParent: TSprite); Override;
    property Shadow: TShadowSprite Read FShadow Write FShadow;
    property Direction: Integer Read FDirection Write FDirection;
    property WalkSpeed: Single Read FWalkSpeed Write FWalkSpeed;
    property FramePerDir: Integer Read FFramePerDir Write FFramePerDir;
  end;

  TShadowSprite = class(TCharacter)
  Public
    procedure GoDirection8; Override;
    procedure DoMove(const MoveCount: Single); Override;
  end;

  THero = class(TCharacter)
  Public
    procedure DoMove(const MoveCount: Single); Override;
  end;


  TMonster = class(TCharacter)
  Private
    FLight: TLight;
  Public
    procedure DoMove(const MoveCount: Single); Override;
    property Light: TLight Read FLight Write FLight;
  end;

var
  MainForm: TMainForm;
  Names: array[0..7] of string = ('Dark Lord', 'Desert Wing', 'Enraged Fallen',
    'Enraged Shaman', 'Hell Buzzard', 'Mega Demon',
    'Night Clan', 'Player');

  SpriteEngine: TSpriteEngine;
  Tiles: array of array of TTile;
  Monster: array of array of TMonster;
  Hero: THero;
  Finger: TFinger;
  MX, MY: Integer;
  Velocity1: Single;
  Velocity2: Single;

implementation

{$R *.dfm}

procedure TFinger.DoMove(const MoveCount: Single);
begin
  inherited;
  X := MX+ Engine.WorldX;//Mouse.CursorPos.X + Engine.WorldX;
  Y := MY+ Engine.WorldY;//Mouse.CursorPos.Y + Engine.WorldY;
  CollidePos := Point2(X + 16, Y + 16);
end;

procedure TCharacter.SetDirectionAnim;
begin
  case Direction of
    0:
      begin
        AnimStart := 0 * FramePerDir; MirrorX := False;
      end;
    1:
      begin
        AnimStart := 1 * FramePerDir; MirrorX := False;
      end;
    2:
      begin
        AnimStart := 2 * FramePerDir; MirrorX := False;
      end;
    3:
      begin
        AnimStart := 3 * FramePerDir; MirrorX := False;
      end;
    4:
      begin
        AnimStart := 4 * FramePerDir; MirrorX := False;
      end;
          //5,6,7 use image mirror
    5:
      begin
        AnimStart := 3 * FramePerDir; MirrorX := True;
      end;
    6:
      begin
        AnimStart := (3 - 1) * FramePerDir; MirrorX := True;
      end;
    7:
      begin
        AnimStart := (3 - 2) * FramePerDir; MirrorX := True;
      end;
  end;
end;

procedure TCharacter.GoDirection8;
begin
  if Direction = 0 then Y := Y - FWalkSpeed;
  if Direction = 1 then
  begin
    X := X + FWalkSpeed; Y := Y - FWalkSpeed;
  end;
  if Direction = 2 then X := X + FWalkSpeed;
  if Direction = 3 then
  begin
    X := X + FWalkSpeed; Y := Y + FWalkSpeed;
  end;
  if Direction = 4 then Y := Y + FWalkSpeed;
  if Direction = 5 then
  begin
    X := X - FWalkSpeed; Y := Y + FWalkSpeed;
  end;
  if Direction = 6 then X := X - FWalkSpeed;
  if Direction = 7 then
  begin
    X := X - FWalkSpeed; Y := Y - FWalkSpeed;
  end;
end;

procedure TFinger.DoCollision(const Sprite: TSprite);
begin

  if (Sprite is TMonster) then
  begin
    with TMonster(Sprite) do
    begin
      DrawFx := FxuBright;
      Engine.Device.Fonts.Font['s/tahoma'].TextOutW(ImageName, Round(X - Engine.WorldX)+10 ,
               Round(Y - Engine.WorldY) - 15, $EEFFFFFF);
    end;
  end;

  if (Sprite is THero) then
  begin
    with THero(Sprite) do
    begin
      DrawFx := FxuBright;
      Engine.Device.Fonts.Font['s/tahoma'].TextOutW('Huasoft', Round(X - Engine.WorldX) + 20,
               Round(Y - Engine.WorldY-10),  $FF00FFFF);
    end;
  end;
end;

constructor TCharacter.Create(const AParent: TSprite);
begin
  inherited;
  FWalkSpeed := 1.25;
end;

procedure TShadowSprite.DoMove;
begin
  inherited;
  x:=Parent.x;
  y:=Parent.y;
//  X1 := -(Parent.PatternWidth div 2) + Parent.X - 6;
//  Y1 := (Parent.PatternHeight div 2) + Parent.Y;
//  X2 := (Parent.PatternWidth div 2) + Parent.X + 6;
//  Y2 := (Parent.PatternHeight div 2) + Parent.Y;
//  X3 := Parent.PatternWidth + Parent.X + 6;
//  Y3 := Parent.PatternHeight + Parent.Y;
//  X4 := Parent.X + 6;
//  Y4 := Parent.PatternHeight + Parent.Y;
  Direction:= TCharacter(Parent).Direction;
  GoDirection8;
  SetDirectionAnim;
end;

procedure TShadowSprite.GoDirection8;
begin
  if Direction = 0 then
  begin
    Y1 := Y1 - FWalkSpeed; Y2 := Y2 - FWalkSpeed; Y3 := Y3 - FWalkSpeed; Y4 := Y4 - FWalkSpeed;
  end;
  if Direction = 1 then
  begin
    X1 := X1 + FWalkSpeed; X2 := X2 + FWalkSpeed; X3 := X3 + FWalkSpeed; X4 := X4 + FWalkSpeed; Y1
      := Y1 - FWalkSpeed; Y2 := Y2 - FWalkSpeed; Y3 := Y3 - FWalkSpeed; Y4 := Y4 - FWalkSpeed;
  end;
  if Direction = 2 then
  begin
    X1 := X1 + FWalkSpeed; X2 := X2 + FWalkSpeed; X3 := X3 + FWalkSpeed; X4 := X4 + FWalkSpeed;
  end;
  if Direction = 3 then
  begin
    X1 := X1 + FWalkSpeed; X2 := X2 + FWalkSpeed; X3 := X3 + FWalkSpeed; X4 := X4 + FWalkSpeed; Y1
      := Y1 + FWalkSpeed; Y2 := Y2 + FWalkSpeed; Y3 := Y3 + FWalkSpeed; Y4 := Y4 + FWalkSpeed;
  end;
  if Direction = 4 then
  begin
    Y1 := Y1 + FWalkSpeed; Y2 := Y2 + FWalkSpeed; Y3 := Y3 + FWalkSpeed; Y4 := Y4 + FWalkSpeed;
  end;
  if Direction = 5 then
  begin
    X1 := X1 - FWalkSpeed; X2 := X2 - FWalkSpeed; X3 := X3 - FWalkSpeed; X4 := X4 - FWalkSpeed; Y1
      := Y1 + FWalkSpeed; Y2 := Y2 + FWalkSpeed; Y3 := Y3 + FWalkSpeed; Y4 := Y4 + FWalkSpeed;
  end;
  if Direction = 6 then
  begin
    X1 := X1 - FWalkSpeed; X2 := X2 - FWalkSpeed; X3 := X3 - FWalkSpeed; X4 := X4 - FWalkSpeed;
  end;
  if Direction = 7 then
  begin
    X1 := X1 - FWalkSpeed; X2 := X2 - FWalkSpeed; X3 := X3 - FWalkSpeed; X4 := X4 - FWalkSpeed; Y1
      := Y1 - FWalkSpeed; Y2 := Y2 - FWalkSpeed; Y3 := Y3 - FWalkSpeed; Y4 := Y4 - FWalkSpeed;
  end;
end;

procedure TMonster.DoMove(const MoveCount: Single);
begin
  inherited;
  DrawFx := FxuBlend;
  Finger.Collision(self);

  case Random(100) of
    50: Direction := Random(8);
  end;
  GoDirection8;
  SetDirectionAnim;
  CollidePos := Point2(X + 60, Y + 50);
  Light.X := X - 80;
  Light.Y := Y - 30;
  if ImageName = 'Mega Demon' then CollidePos := Point2(X + 100, Y + 80);
end;

procedure TMainForm.CreateTiles(ArrayA, ArrayB, OffsetX, OffsetY: Integer);
var
  a, b: Integer;
begin
  SetLength(Tiles, ArrayA, ArrayB);
  for a := 0 to ArrayA - 1 do
  begin
    for b := 0 to ArrayB - 1 do
    begin
      Tiles[a, b] := TTile.Create(SpriteEngine);
      Tiles[a, b].ImageName := 'Tile';
      Tiles[a, b].X := 79 * b + OffsetX;
      Tiles[a, b].Z := -100;
      Tiles[a, b].Width := 160;
      Tiles[a, b].Height := 80;
      if (b mod 2) = 0 then
        Tiles[a, b].Y := 79 * a + OffsetY;
      if (b mod 2) = 1 then
        Tiles[a, b].Y := 40 + 79 * a + OffsetY;
      Tiles[a, b].PatternIndex := Random(30);
    end;
  end;
end;

procedure TMainForm.DrawTiles;
var
  a, b: Integer;
begin
  for a := 0 to High(Tiles) - 1 do
  begin
    for b := 0 to High(Tiles[0]) - 1 do
      if (Tiles[a, b].X > SpriteEngine.WorldX - 200) and
        (Tiles[a, b].X < SpriteEngine.WorldX + 800) and
        (Tiles[a, b].Y > SpriteEngine.WorldY - 200) and
        (Tiles[a, b].Y < SpriteEngine.WorldY + 600) then
      begin
        Tiles[a, b].DoDraw;
      end;
  end;
end;

procedure TMainForm.CreateMonsters(ArrayA, ArrayB: Integer);
var
  a, b: Integer;
begin
  SetLength(Monster, ArrayA, ArrayB);
  for a := 0 to ArrayA - 1 do
  begin
    for b := 0 to ArrayB - 1 do
    begin
      Monster[a, b] := TMonster.Create(SpriteEngine);
      Monster[a, b].ImageName := Names[Random(7)];
      Monster[a, b].FramePerDir := Monster[a, b].PatternCount div 5;
      Monster[a, b].X := Random(7000) - 3000;
      Monster[a, b].Y := Random(7000) - 3000;
      Monster[a, b].Direction := Random(8);
      Monster[a, b].AnimCount := Monster[a, b].FramePerDir;
      Monster[a, b].AnimSpeed := 0.35;
      Monster[a, b].DoAnimate := True;
      Monster[a, b].AnimLooped := True;
      Monster[a, b].DrawFx := fxuBlend;
      Monster[a, b].CollideRadius := 25;
      Monster[a, b].Light := TLight.Create(SpriteEngine);
      Monster[a, b].Light.ImageName := 'light';
      Monster[a, b].Light.DrawFx := fxuLight;
      Monster[a, b].Light.ScaleX := 0.5;
      Monster[a, b].Light.ScaleY := 0.3;

      if Monster[a, b].ImageName = 'Mega Demon' then Monster[a, b].CollideRadius := 40;
      Monster[a, b].Collisioned := True;
      //Create Sprite's shadow
      Monster[a, b].Shadow := TShadowSprite.Create(Monster[a, b]);
      Monster[a, b].Shadow.DrawMode := 3;
      Monster[a, b].Shadow.DrawFx := fxuShadow or fxfDiffuse;
      Monster[a, b].Shadow.Alpha := 128;
      Monster[a, b].Shadow.ImageName := Monster[a, b].ImageName;
      Monster[a, b].Shadow.AnimCount := Monster[a, b].FramePerDir;
      Monster[a, b].Shadow.AnimSpeed := 0.35;
      Monster[a, b].Shadow.AnimLooped := True;
      Monster[a, b].Shadow.DoAnimate := True;
      Monster[a, b].Shadow.Direction := Monster[a, b].Direction;
      Monster[a, b].Shadow.X1 := -(Monster[a, b].PatternWidth div 2) + Monster[a, b].X + 6;
      Monster[a, b].Shadow.Y1 := (Monster[a, b].PatternHeight div 2) + Monster[a, b].Y;
      Monster[a, b].Shadow.X2 := (Monster[a, b].PatternWidth div 2) + Monster[a, b].X + 6;
      Monster[a, b].Shadow.Y2 := (Monster[a, b].PatternHeight div 2) + Monster[a, b].Y;
      Monster[a, b].Shadow.X3 := Monster[a, b].PatternWidth + Monster[a, b].X + 6;
      Monster[a, b].Shadow.Y3 := Monster[a, b].PatternHeight + Monster[a, b].Y;
      Monster[a, b].Shadow.X4 := Monster[a, b].X + 6;
      Monster[a, b].Shadow.Y4 := Monster[a, b].PatternHeight + Monster[a, b].Y;
    end;
  end;
end;

procedure TMainForm.DrawMonsters;
var
  a, b: Integer;
begin
  for a := 0 to High(Monster) - 1 do
  begin
    for b := 0 to High(Monster[0]) - 1 do
      if (Monster[a, b].X > SpriteEngine.WorldX - 100) and
        (Monster[a, b].X < SpriteEngine.WorldX + 800) and
        (Monster[a, b].Y > SpriteEngine.WorldY - 100) and
        (Monster[a, b].Y < SpriteEngine.WorldY + 600) then
      begin
        Monster[a, b].Shadow.DoMove(1);
        Monster[a, b].Shadow.DoDraw;
        Monster[a, b].DoMove(1);
        Monster[a, b].DoDraw;
        Monster[a, b].Shadow.Direction := Monster[a, b].Direction;
        Monster[a, b].Light.DoDraw;

      end;
  end;
end;

procedure TMainForm.CreateHero;
begin
  Hero := THero.Create(SpriteEngine);
  Hero.ImageName := 'Player';
  Hero.X := 320;
  Hero.Y := 200;
  Hero.FramePerDir := 8;
  Hero.AnimSpeed := 0.30;
  Hero.DoAnimate := False;
  Hero.AnimLooped := True;
  Hero.AnimCount := 8;
  Hero.Collisioned := True;
  Hero.CollideRadius := 20;
  //create hero's shadow
  Hero.Shadow := TShadowSprite.Create(Hero);
  Hero.Shadow.Assign(Hero);
  Hero.Shadow.X := 320 ;
  Hero.Shadow.Y := 200;
  Hero.Shadow.ImageName := 'Player';
  Hero.Shadow.DrawMode := 3;
  Hero.Shadow.DrawFx := fxuShadow or fxfDiffuse;
  Hero.Shadow.Alpha := 128;
  Hero.Shadow.FramePerDir := 8;
end;

procedure TMainForm.DrawHero;
begin
  Hero.Shadow.DoDraw;
  Hero.Shadow.DoMove(1);
  Hero.DoDraw;
  Hero.DoMove(1);
  Hero.Shadow.X1 := -(Hero.PatternWidth div 2) + Hero.X - 6;
  Hero.Shadow.Y1 := (Hero.PatternHeight div 2) + Hero.Y;
  Hero.Shadow.X2 := (Hero.PatternWidth div 2) + Hero.X + 6;
  Hero.Shadow.Y2 := (Hero.PatternHeight div 2) + Hero.Y;
  Hero.Shadow.X3 := Hero.PatternWidth + Hero.X + 6;
  Hero.Shadow.Y3 := Hero.PatternHeight + Hero.Y;
  Hero.Shadow.X4 := Hero.X + 6;
  Hero.Shadow.Y4 := Hero.PatternHeight + Hero.Y;
  Hero.Shadow.Direction := Hero.Direction;
end;

function Angles(X, Y: Integer): Real;
begin
  Result := Abs(((Arctan2(X, Y) * 40.5)) - 128);
end;

procedure THero.DoMove(const MoveCount: Single);
var
  Directions: Integer;
begin
  inherited;
  DrawFx := FxuBlend;
  Finger.Collision(self);

  CollidePos := Point2(320 + Engine.WorldX + 70, 200 + Engine.WorldY + 70);
  X := Engine.WorldX + 320;
  Y := Engine.WorldY + 200;
  Directions := Round(Angles(MX - 320, MY - 200));

  case Directions of
    240..255,
      0..15:
      begin
        Direction := 0;
        Engine.WorldY := Engine.WorldY - Velocity1;
      end;
    16..47:
      begin
        Direction := 1;
        Engine.WorldX := Engine.WorldX + Velocity2;
        Engine.WorldY := Engine.WorldY - Velocity2;
      end;
    48..79:
      begin
        Direction := 2;
        Engine.WorldX := Engine.WorldX + Velocity1;
      end;
    80..111:
      begin
        Direction := 3;
        Engine.WorldX := Engine.WorldX + Velocity2;
        Engine.WorldY := Engine.WorldY + Velocity2;
      end;
    112..143:
      begin
        Direction := 4;
        Engine.WorldY := Engine.WorldY + Velocity1;
      end;
    144..175:
      begin
        Direction := 5;
        Engine.WorldX := Engine.WorldX - Velocity2;
        Engine.WorldY := Engine.WorldY + Velocity2;
      end;
    176..207:
      begin
        Direction := 6;
        Engine.WorldX := Engine.WorldX - Velocity1;
      end;
    208..239:
      begin
        Direction := 7;
        Engine.WorldX := Engine.WorldX - Velocity2;
        Engine.WorldY := Engine.WorldY - Velocity2;
      end;
  end;
  SetDirectionAnim;

end;


procedure TMainForm.DeviceInitialize(Sender: TAsphyreDevice);
begin
  Sender.Canvas.Antialias := true;
  Randomize;
  SpriteEngine := TSpriteEngine.Create(nil);
  SpriteEngine.Canvas := Sender.Canvas;
  SpriteEngine.Image := Sender.Images;
  SpriteEngine.Device:=Sender;
  SpriteEngine.VisibleWidth := Sender.Params.BackBufferWidth;
  SpriteEngine.VisibleHeight := Sender.Params.BackBufferHeight;

  CreateTiles(100, 100, -2000, -2000);
  CreateMonsters(30, 30);
  CreateHero;
  Finger := TFinger.Create(SpriteEngine);
  Finger.ImageName := 'finger';
  Finger.Collisioned := True;
  Finger.CollideRadius := 16;
  Finger.Z := 1000;
  Screen.Cursor := crNone;

end;

procedure TMainForm.TimerTimer(Sender: TObject);
begin
  Devices[0].Render(DeviceRender, Self, $FFFF0000);
  Timer.Process();
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  ImageGroups.ParseLink('/media.xml');
  FontGroups.ParseLink('/media.xml');

  Devices.InitEvent := DeviceInitialize;
  Devices.PreloadEvent:=DevicePreload;
  Devices.Count := 1; //Devices.DisplayCount;
  if (not Devices.Initialize(DevConfig, Self)) then
  begin
    ShowMessage('Initialization failed.');
    Close();
    Exit;
  end;
  Timer.Enabled := True;
  Timer.OnTimer := TimerTimer;
  Timer.MaxFPS := 4000;
end;

procedure TMainForm.DevConfig(Sender: TAsphyreDevice; Tag: TObject;
  var config: TScreenConfig);
begin
  Config.Width := ClientWidth;
  Config.Height := ClientHeight;
  Config.Windowed := true ;
  Config.VSync := true;
  Config.BitDepth := bd24bit;
  Config.WindowHandle := Self.Handle;
  Config.HardwareTL := False;
  Config.DepthStencil := dsNone;
end;

procedure TMainForm.DevicePreload(Sender: TAsphyreDevice);
var
i:integer;
begin
  for i := 0 to 7 do
    Sender.Images.ResolveImage(Names[i]);
end;

procedure TMainForm.DeviceRender(Sender: TAsphyreDevice; Tag: TObject);
begin
//  SpriteEngine.Move(1);
//  SpriteEngine.Draw;
  DrawTiles;
  DrawMonsters;
  DrawHero;

  with Sender.Canvas do
  begin
    DrawEx(Sender.canvas, Sender.Images.Image['light'], 0, 125, 25, 0.5, 0.3,
      True, False, False, clWhite4, fxuLight);

    useimage(sender.Images.Image['panel1'], 0);
    TexMap(pBounds4(120, 555, 572, 48), clWhite4, fxuBlend);
    useimage(sender.Images.Image['panel3'], 0);
    TexMap(pBounds4(5, 510, 117, 104), clWhite4, fxuBlend);
    useimage(sender.Images.Image['panel2'], 0);
    TexMap(pBounds4(690, 500, 117, 104), clWhite4, fxuBlend);
  end;

  Finger.DoMove(1);
  Finger.DoDraw;

  Sender.Fonts.Font['s/tahoma'].TextOutW('FPS: ' + IntToStr(Timer.FrameRate),
    680, 8, $FFFFFFFF);

end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
     // finalize Asphyre device
  Devices.Finalize();
end;


procedure TMainForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
     // leave the program on ESC button
  if (Key = VK_ESCAPE) then Close();

     // switch between full-screen and windowed mode on Alt + Enter
//  if (Key = VK_RETURN) and (ssAlt in Shift) then
//  begin
//          // switch windowed mode
////          Device.Windowed := not Device.Windowed;
//  end;
end;

procedure TMainForm.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  MX := X;
  MY := Y;
  Velocity1 := 4;
  Velocity2 := 3;
  Hero.DoAnimate := True;
  Hero.Shadow.DoAnimate := True;
end;

procedure TMainForm.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  MX := X;
  MY := Y;
  if ssLeft in Shift then
  begin
    Velocity1 := 4;
    Velocity2 := 3;
    Hero.DoAnimate := True;
    Hero.Shadow.DoAnimate := True;
  end;
end;

procedure TMainForm.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  Velocity1 := 0;
  Velocity2 := 0;
  Hero.DoAnimate := False;
  Hero.Shadow.DoAnimate := False;
end;

end.

