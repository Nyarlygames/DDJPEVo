unit MainFm;

//---------------------------------------------------------------------------
interface

//---------------------------------------------------------------------------
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, AsphyreDevices, AsphyreScene, Direct3D9, D3DX9;

//---------------------------------------------------------------------------
type
  TMainForm = class(TForm)
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    Scene: TAsphyreScene;
    Ticks: Integer;

    procedure SetupLights();
    procedure CreateMeshes();

    procedure DeviceConfig(Sender: TAsphyreDevice; Tag: TObject;
     var Config: TScreenConfig);
    procedure TimerEvent(Sender: TObject);
    procedure ProcessEvent(Sender: TObject);
    procedure RenderPrimary(Sender: TAsphyreDevice; Tag: TObject);
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
 AsphyreTimer, AsphyreEffects, MediaFonts, MediaImages, AsphyreLights,
 Vectors3, AsphyreMeshX, AsphyreStates, AsphyreDef, Vectors2;
{$R *.dfm}

//---------------------------------------------------------------------------
procedure TMainForm.FormCreate(Sender: TObject);
begin
 ImageGroups.ParseLink('/images.xml');
 FontGroups.ParseLink('/fonts.xml');

 if (not Devices.Initialize(DeviceConfig, Self)) then
  begin
   MessageDlg('Failed to initialize Asphyre device.', mtError, [mbOk], 0);
   Close();
   Exit;
  end;

 Scene:= TAsphyreScene.Create(DefDevice);

 // configure scene lights
 SetupLights();
 Scene.Lights.UpdateStates();

 // load scene meshes
 CreateMeshes();

 // configure view camera and projection
 Scene.ViewMtx.LookAt(Vector3(150.0, 150.0, 150.0), ZeroVec3, AxisYVec3);
 Scene.ProjMtx.PerspectiveFOVY(Pi / 3, ClientHeight / ClientWidth, 0.5, 2000.0);
 Scene.UpdateTransform([attView, attProjection]);

 // configure the application timer
 Timer.Enabled  := True;
 Timer.OnTimer  := TimerEvent;
 Timer.OnProcess:= ProcessEvent;
 Timer.MaxFPS   := 4000;
end;

//---------------------------------------------------------------------------
procedure TMainForm.FormDestroy(Sender: TObject);
begin
 Scene.Free();
 Devices.Finalize();
end;

//---------------------------------------------------------------------------
procedure TMainForm.DeviceConfig(Sender: TAsphyreDevice; Tag: TObject;
 var Config: TScreenConfig);
begin
 Config.WindowHandle:= Self.Handle;
 Config.HardwareTL  := False;
 Config.DepthStencil:= dsDepthStencil;

 Config.Width   := ClientWidth;
 Config.Height  := ClientHeight;
 Config.Windowed:= True;
 Config.VSync   := False;
 Config.BitDepth:= bd24bit;

 // configure resolution events
 Sender.Images.OnResolveFailed:= ResolveFailed;
 Sender.Fonts.OnResolveFailed := ResolveFailed;
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
 DefDevice.Render(RenderPrimary, Self, $000040, 1.0, 0);
 Timer.Process();
end;

//---------------------------------------------------------------------------
procedure TMainForm.ProcessEvent(Sender: TObject);
begin
 Inc(Ticks);
end;

//---------------------------------------------------------------------------
procedure TMainForm.RenderPrimary(Sender: TAsphyreDevice; Tag: TObject);
var
 Phi: Real;
begin
 Phi:= Ticks * Pi / 100.0; // this is an angle to rotate our cube with

 // Configure Cube's position and orientation
 Scene.WorldMtx.LoadIdentity();

 // Rescale the cube to make it look bigger.
 Scene.WorldMtx.Scale(2.0, 2.0, 2.0);

 // -> rotate the cube around X axis
 Scene.WorldMtx.RotateX(Cos(Phi));
 // -> move the cube around
 // note: it is moved diagonally to provide depth-view effect, since we
 // look at our cube from position (150.0, 150.0, 150.0)
 Scene.WorldMtx.Translate(Sin(Phi / 4.0) * 50.0, Sin(Phi / 4.0) * 50.0,
  Sin(Phi / 4.0) * 50.0);

 // Specify the cube transformation.
 Scene.UpdateTransform([attWorld]);

 // Modify relevant states for correct rendering of 3D mesh
 Scene.States.DepthBuffer    := True;
 Scene.States.CullMode       := acmAnticlockwise;
 Scene.States.Lighting       := True;
 Scene.States.SpecularLights := True;
 Scene.States.NormalNormalize:= True;
 Scene.States.Antialias      := aatMipmaps;

 // draw the mesh
 Scene.Meshes[0].Draw();

 // output some text
 with Sender.Fonts.Font['s/arial'] do
  begin
   DropShadow:= True;
   TextOut('FPS: ' + IntToStr(Timer.FrameRate), 4, 4, $FFFFFFFF);
  end;
end;

//---------------------------------------------------------------------------
procedure TMainForm.SetupLights();
begin
 with Scene.Lights[0]^ do
  begin
   Active   := True;
   LightType:= altOmni;
   Diffuse  := $FFFFFF;
   Specular := $FFFFFF;
   Ambient  := $202020;
   Position := Vector3(0.0, 200.0, 150.0);
  end;
end;

//---------------------------------------------------------------------------
procedure TMainForm.CreateMeshes();
var
 Mesh: TAsphyreMeshX;
begin
 Mesh:= TAsphyreMeshX.Create(Scene.Meshes);

 if (not Mesh.LoadFromFile('box.x')) then
  begin
   MessageDlg('Failed loading 3D cube mesh!', mtError, [mbOk], 0);
   Close();
   Exit;
  end;
end;

//---------------------------------------------------------------------------
end.
