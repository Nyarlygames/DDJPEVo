unit MainFm;
//---------------------------------------------------------------------------
// Asphyre example application                          Modified: 23-Jan-2007
// Copyright (c) 2000 - 2007  Afterwarp Interactive
//---------------------------------------------------------------------------
// This demo illustrates how to render isometric terrain with variable
// height using Asphyre.
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

//---------------------------------------------------------------------------
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, AsphyreDevices, IsoLandscape;

//---------------------------------------------------------------------------
type
  TMainForm = class(TForm)
    StatusBar1: TStatusBar;
    procedure FormResize(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    WaterIndex: Integer;

    procedure SetupDevice(Sender: TAsphyreDevice; Tag: TObject;
     var Config: TScreenConfig);
    procedure TimerEvent(Sender: TObject);
    procedure ProcessEvent(Sender: TObject);
    procedure PreloadEvent(Sender: TAsphyreDevice);
    procedure RenderPrimary(Sender: TAsphyreDevice; Tag: TObject);
    procedure ResolveFailed(Sender: TObject; const Symbol: string);
  public
    { Public declarations }
    Land: TLand;
    MouseX, MouseY: Integer;
  end;

//---------------------------------------------------------------------------
var
  MainForm: TMainForm;

//---------------------------------------------------------------------------
implementation
uses
 MediaImages, MediaFonts, AsphyreTimer, AsphyreImages, AsphyreFonts,
 AsphyreEffects;
{$R *.dfm}

//---------------------------------------------------------------------------
procedure TMainForm.FormCreate(Sender: TObject);
begin
 // retreive image and font descriptions
 ImageGroups.ParseLink('/landscape.xml');
 FontGroups.ParseLink('/landscape.xml');

 Devices.PreloadEvent:= PreloadEvent;
 if (not Devices.Initialize(SetupDevice, Self)) then
  begin
   MessageDlg('Failed to initialize Asphyre device.', mtError, [mbOk], 0);
   Close();
   Exit;
  end;

 // create instance of our isometric landscape
 Land:= TLand.Create();

 // configure Asphyre timer
 Timer.Enabled  := True;
 Timer.OnTimer  := TimerEvent;
 Timer.OnProcess:= ProcessEvent;
 Timer.MaxFPS   := 4000;

 MouseX:= ClientWidth div 2;
 MouseY:= ClientHeight div 2;
end;

//---------------------------------------------------------------------------
procedure TMainForm.FormDestroy(Sender: TObject);
begin
 // finalize Asphyre device and remove all loaded images & fonts
 Devices.Finalize();

 // release landscape class
 Land.Free();
end;

//---------------------------------------------------------------------------
procedure TMainForm.SetupDevice(Sender: TAsphyreDevice; Tag: TObject;
  var Config: TScreenConfig);
begin
 Config.Width   := ClientWidth;
 Config.Height  := ClientHeight;
 Config.Windowed:= True;

 Config.WindowHandle:= Self.Handle;
 Config.HardwareTL  := False;

 // configure resolution events
 Sender.Images.OnResolveFailed:= ResolveFailed;
 Sender.Fonts.OnResolveFailed := ResolveFailed;
end;

//---------------------------------------------------------------------------
procedure TMainForm.FormResize(Sender: TObject);
begin
 Devices[0].ChangeParams(ClientWidth, ClientHeight, True);
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
procedure TMainForm.PreloadEvent(Sender: TAsphyreDevice);
begin
 // Try to "resolve" the index for symbol "water". It is described
 // in "images.xml" file and the actual location of graphics file
 // is defined there.
 WaterIndex:= Sender.Images.ResolveImage('water');
end;

//---------------------------------------------------------------------------
procedure TMainForm.TimerEvent(Sender: TObject);
begin
 Devices[0].Render(RenderPrimary, Self, $FF000050);
 Timer.Process();
end;

//---------------------------------------------------------------------------
procedure TMainForm.RenderPrimary(Sender: TAsphyreDevice; Tag: TObject);
begin
 Land.Render();

 with Sender.Fonts.Font['x/squired'] as TAsphyreBitmapFont do
  begin
   Kerning:= -5;
   TextOutFx('Frame Rate: ' + IntToStr(Timer.FrameRate), 4, 4, $FFFFD000,
    $FFFFFFD0);

   TextOutFx('Press ''G'' to switch wireframe grid.', 4, 28, $FFFFFFFF,
    $FF00FF00);

   TextOutFx('To scroll, move your mouse to edges.', 4, 52, $FFFF0000,
    $FFFFE000);
  end;
end;

//---------------------------------------------------------------------------
procedure TMainForm.ProcessEvent(Sender: TObject);
begin
 if (MouseX < 64) then Land.XViewVel:= Land.XViewVel - 1;
 if (MouseX > ClientWidth - 64) then Land.XViewVel:= Land.XViewVel + 1;
 if (MouseY < 64) then Land.YViewVel:= Land.YViewVel - 1;
 if (MouseY > ClientHeight - 64) then Land.YViewVel:= Land.YViewVel + 1;

 Land.Process();
end;

//---------------------------------------------------------------------------
procedure TMainForm.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
 MouseX:= X;
 MouseY:= Y;
end;

//---------------------------------------------------------------------------
procedure TMainForm.FormKeyPress(Sender: TObject; var Key: Char);
begin
 if (UpCase(Key) = 'G') then Land.Grid:= not Land.Grid;
end;

//---------------------------------------------------------------------------
end.
