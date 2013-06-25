unit capteur;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,AsphyreDevices, AsphyreImages, StdCtrls;

type
  TMainFrm = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Déclarations privées }
    procedure ConfigureDevice(Sender: TAsphyreDevice; Tag: TObject;
      var Config: TScreenConfig);
    procedure TimerEvent(Sender: TObject);
    procedure ProcessEvent(Sender: TObject);
    procedure RenderCallback(Sender: TAsphyreDevice; Tag: TObject);


  public
    { Déclarations publiques }
  end;

var
  MainFrm: TMainFrm;


implementation

{$R *.dfm}
uses
  AsphyreEvents, AsphyreTimer, AsphyreTypes,MediaImages, AsphyreEffects;



procedure TMainFrm.ConfigureDevice(Sender: TAsphyreDevice; Tag: TObject;
  var Config: TScreenConfig);
begin
  Config.Width   := ClientWidth;
  Config.Height  := ClientHeight;
  Config.Windowed:= True;

  Config.WindowHandle:= Self.Handle;
  Config.HardwareTL  := true;

end;


procedure TMainFrm.FormCreate(Sender: TObject);
begin
  ImageGroups.ParseLink('.\Ressources.xml'); //Chargement des images

  if (not Devices.Initialize(ConfigureDevice, Self)) then //Initialisation
  begin
    MessageDlg('Asphyre n''a pas pu s''initialiser!', mtError, [mbOk], 0);
    Close();
    Exit;
  end;

  //Démarrage et paramétrage du Timer
  Timer.Enabled  := True;
  Timer.OnTimer  := TimerEvent;
  Timer.OnProcess:= ProcessEvent;
  Timer.MaxFPS   := 100;


end;

procedure TMainFrm.FormDestroy(Sender: TObject);
begin
  Devices.Finalize;
end;

procedure TMainFrm.ProcessEvent(Sender: TObject);
begin
  //Rien
end;

procedure TMainFrm.RenderCallback(Sender: TAsphyreDevice; Tag: TObject);

var
basv: TAsphyreCustomImage;
bas: TAsphyreCustomImage;

begin

  with Sender.Canvas do
  begin
    //Pour vérfier que l'image est correcte, on peut désactiver l'anticrénelage
    Antialias := atBest;

// affiche les images
    basv := Sender.Images.Image['basv'];
    bas := Sender.Images.Image['bas'];
    UseImage(basv, TexFull4);
    TexMap(pBounds4(50, 50, basv.Texture[0].Size.X, basv.Texture[0].Size.Y),
      cColor4($FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF), fxuMultiBlend);
    UseImage(bas, TexFull4);
    TexMap(pBounds4(50, 300, bas.Texture[0].Size.X, bas.Texture[0].Size.Y),
    cColor4($FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF), fxuMultiBlend);

  end;
end;


procedure TMainFrm.TimerEvent(Sender: TObject);
begin
  DefDevice.Render(RenderCallback, self, $000000);
  Timer.Process;
end;





end.
