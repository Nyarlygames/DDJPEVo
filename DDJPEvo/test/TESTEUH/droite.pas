unit droite;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, AsphyreDevices, AsphyreImages, AsphyreTypes, AsphyreJoystick, AsphyreMouse,
  AsphyreKeyboard, AsphyreInputs, StdCtrls;

type
  TJoyInfos = record
    Axis: integer;
    Buttons: integer;
    POVs: integer;
  end;

  TDroitfrm = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Déclarations privées }
    SpaceDown: boolean;
    procedure ConfigureDevice(Sender: TAsphyreDevice; Tag: TObject;
      var Config: TScreenConfig);
    procedure TimerEvent(Sender: TObject);
    procedure ProcessEvent(Sender: TObject);
    procedure RenderCallback(Sender: TAsphyreDevice; Tag: TObject);
  public
    { Déclarations publiques }
  end;

const
  MAX_WIDTH = 1024;
  MAX_HEIGTH = 800;
  Sensibilite_Vertical = 20;
  Sensibilite_Horizontal = 20;

var
  Droitfrm: TDroitfrm;
  t : integer;



implementation

uses
  AsphyreEvents, AsphyreTimer, AsphyreSystemFonts, MediaImages, MediaFonts,
  AsphyreEffects, Vectors2, DirectInput, Math;

{$R *.dfm}



procedure TDroitfrm.ConfigureDevice(Sender: TAsphyreDevice; Tag: TObject;
  var Config: TScreenConfig);
begin
  //Paramétrage de l'affichage
  Config.Width   := ClientWidth;
  Config.Height  := ClientHeight;
  Config.Windowed:= True;

  Config.WindowHandle:= Self.Handle;
  Config.HardwareTL  := true;
end;

procedure TDroitfrm.FormCreate(Sender: TObject);
begin
  //Chargement des images
  ImageGroups.ParseLink('Ressources.xml');

  //Initialisation de DirectX
  if (not Devices.Initialize(ConfigureDevice, Self)) then
  begin
    //L'initalisation a échoué
    MessageDlg('Asphyre n''a pas pu s''initialiser!', mtError, [mbOk], 0);
    Close();
    Exit;
  end;

  //Initialisation de AsphyreInput
  AsphyreInput.Initialize;
  AsphyreInput.WindowHandle := Handle;
  //Initialisation des interfaces
  AsphyreInput.Keyboard.Initialize;
  AsphyreInput.Mouse.Initialize;
  SpaceDown := false;
  //Origine du carré




  //Paramétrage et déclenchement du Timer
  Timer.OnTimer  := TimerEvent;
  Timer.OnProcess:= ProcessEvent;
  Timer.MaxFPS   := 200;
  Timer.Enabled  := True;
end;

procedure TDroitfrm.FormDestroy(Sender: TObject);
begin
  AsphyreInput.Finalize;
  //Finalisation de DirectX
  Devices.Finalize;
end;

procedure TDroitfrm.ProcessEvent(Sender: TObject);
begin



  if AsphyreInput.Keyboard.Update then
  with AsphyreInput.Keyboard do
  begin
    //Appui de 1 à 9 sur le pavé numérique pour spécifier le joystick utilisé


    //Appui sur Echap pour fermer l'application
    if Key[DIK_ESCAPE] then
      Close;

  if Key[DIK_SPACE] then
    SpaceDown := not SpaceDown;
  end;

end;

procedure TDroitfrm.RenderCallback(Sender: TAsphyreDevice; Tag: TObject);

  var
droitev,AsImage: TAsphyreCustomImage;
begin

  with Sender.Canvas do
  begin

      //droite
    droitev := Sender.Images.Image['droitev'];

    TexMap(pBounds4(1150, MAX_HEIGTH + 800, droitev.Texture[0].Size.X, droitev.Texture[0].Size.Y),
      cColor4($FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF), fxuMultiBlend);
end;
end;

procedure TDroitfrm.TimerEvent(Sender: TObject);
begin
  //Déclenchement du rendu sur fond bleu
  DefDevice.Render(RenderCallback, self, $FF0000FF);
  //Déclenchement de Process
  Timer.Process;
end;

end.
