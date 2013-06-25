unit test;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, AsphyreDevices, AsphyreImages, AsphyreTypes, AsphyreJoystick, AsphyreMouse,
  AsphyreKeyboard, AsphyreInputs, StdCtrls,droite;

type
  TJoyInfos = record
    Axis: integer;
    Buttons: integer;
    POVs: integer;
  end;

  TMainFrm = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);

  private
    { Déclarations privées }
  public
    { Déclarations publiques }
            procedure ConfigureDevice(Sender: TAsphyreDevice; Tag: TObject;
      var Config: TScreenConfig);
    procedure TimerEvent(Sender: TObject);
    procedure ProcessEvent(Sender: TObject);
    procedure RenderCallback(Sender: TAsphyreDevice; Tag: TObject);
  end;

const
  MAX_WIDTH = 1680;
  MAX_HEIGTH = 1050;
  Sensibilite_Vertical = 20;
  Sensibilite_Horizontal = 20;

var
  MainFrm: TMainFrm;
  t : integer;
  Droit : TDroitFrm;
    yb,yh,yg,yd,rg,rh,rb,rd : integer;
  count : integer;
  lumierehX, lumierehY : integer;
  lumierebX, lumierebY : integer;
  lumieredX, lumieredY : integer;
  lumieregX, lumieregY : integer;
  capteurhX, capteurhY : integer;
  capteurbX, capteurbY : integer;
  capteurdX, capteurdY : integer;
  capteurgX, capteurgY : integer;

implementation

uses
  AsphyreEvents, AsphyreTimer, AsphyreSystemFonts, MediaImages, MediaFonts,
  AsphyreEffects, Vectors2, DirectInput;

{$R *.dfm}



procedure TMainFrm.ConfigureDevice(Sender: TAsphyreDevice; Tag: TObject;
  var Config: TScreenConfig);
begin

  //Paramétrage de l'affichage
  Config.Width   := ClientWidth;
  Config.Height  := ClientHeight;
  Config.Windowed:= True;

  Config.WindowHandle:= Self.Handle;
  Config.HardwareTL  := true;
end;

procedure TMainFrm.FormCreate(Sender: TObject);
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
  AsphyreInput.WindowHandle := Self.Handle;
  //Initialisation des interfaces
  AsphyreInput.Keyboard.Initialize;
  AsphyreInput.Mouse.Initialize;

  //Origine du carré

    yg := MAX_HEIGTH + 200;
    yd := MAX_HEIGTH + 800;
    yh := MAX_HEIGTH + 400;
    yb := MAX_HEIGTH + 600;
    rh:= MAX_HEIGTH + 1200;
    rb:= MAX_HEIGTH + 1400;
    rd:= MAX_HEIGTH + 1600;
    rg:=  MAX_HEIGTH + 1000;


  lumierehX := 4000;
  lumierehY := 4000;
  lumierebX := 4000;
  lumierebY := 4000;
  lumieredX := 4000;
  lumieredY := 4000;
  lumieregX := 4000;
  lumieregY := 4000;
  capteurhX := 300;
  capteurhY := 100;
  capteurbX := 600;
  capteurbY := 100;
  capteurdX := 900;
  capteurdY := 100;
  capteurgX := 0;
  capteurgY := 100;

  //Paramétrage et déclenchement du Timer
  Timer.OnTimer  := TimerEvent;
  Timer.OnProcess:= ProcessEvent;
  Timer.MaxFPS   := 200;
  Timer.Enabled  := True;


 Droit := TDroitFrm.Create;
 Droit.FormCreate(MainFrm);


end;

procedure TMainFrm.FormDestroy(Sender: TObject);
begin
  AsphyreInput.Finalize;
  //Finalisation de DirectX
  Devices.Finalize;
end;

procedure TMainFrm.ProcessEvent(Sender: TObject);
begin



  if AsphyreInput.Keyboard.Update then
  with AsphyreInput.Keyboard do
  begin
    //Appui de 1 à 9 sur le pavé numérique pour spécifier le joystick utilisé


    //Appui sur Echap pour fermer l'application
    if Key[DIK_ESCAPE] then
      Close;




end;
       ShowMessage('process marche');

end;





procedure TMainFrm.RenderCallback(Sender: TAsphyreDevice; Tag: TObject);

  var
bas,basv,basb,haut,hautv,hautb,droite,droitev,droiteb,gauche,gauchev,gaucheb,AsImage,ran1,ran2,ran3,ran0: TAsphyreCustomImage;
begin

  with Sender.Canvas do
  begin

    // ****Dessin de l'arrière plan

    //Chargement de l'image
    AsImage := Sender.Images.Image['Back'];
    //Image à utiliser
    UseImage(AsImage, TexFull4);
    //Dessin de l'image
    //Image à utiliser
    UseImage(AsImage, TexFull4);
    //Dessin de l'image
    TexMap(pRect4(Rect(0, 0, ClientWidth, ClientHeight)), clWhite4, fxuBlend);

      //bas
    bas := Sender.Images.Image['basv'];
    basv := Sender.Images.Image['bas'];
    basb := Sender.Images.Image['basb'];
    ran0 := Sender.Images.Image['basv'];
    UseImage(bas, TexFull4);
    TexMap(pBounds4(600, yb, bas.Texture[0].Size.X, bas.Texture[0].Size.Y),
      cColor4($FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF), fxuMultiBlend);
    UseImage(basv, TexFull4);
    TexMap(pBounds4(lumierebX, lumierebY, basv.Texture[0].Size.X, basv.Texture[0].Size.Y),
      cColor4($FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF), fxuMultiBlend);
    UseImage(basb, TexFull4);
    TexMap(pBounds4(capteurbX, capteurbY, basb.Texture[0].Size.X, basb.Texture[0].Size.Y),
      cColor4($FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF), fxuMultiBlend);
    UseImage(ran0, TexFull4);
    TexMap(pBounds4(600,rb , ran0.Texture[0].Size.X, ran0.Texture[0].Size.Y),
      cColor4($FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF), fxuMultiBlend);


      //haut
    haut := Sender.Images.Image['hautv'];
    hautv := Sender.Images.Image['haut'];
    hautb := Sender.Images.Image['hautb'];
    ran1 := Sender.Images.Image['hautv'];
    UseImage(haut, TexFull4);
    TexMap(pBounds4(300, yh, haut.Texture[0].Size.X, haut.Texture[0].Size.Y),
      cColor4($FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF), fxuMultiBlend);
    UseImage(hautv, TexFull4);
    TexMap(pBounds4(lumierehX, lumierehY, hautv.Texture[0].Size.X, hautv.Texture[0].Size.Y),
      cColor4($FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF), fxuMultiBlend);
    UseImage(hautb, TexFull4);
    TexMap(pBounds4(capteurhX, capteurhY, hautb.Texture[0].Size.X, hautb.Texture[0].Size.Y),
      cColor4($FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF), fxuMultiBlend);
    UseImage(ran1, TexFull4);
    TexMap(pBounds4(300,rh , ran1.Texture[0].Size.X, ran1.Texture[0].Size.Y),
      cColor4($FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF), fxuMultiBlend);


     // droite
    droite := Sender.Images.Image['droitev'];
    droitev := Sender.Images.Image['droite'];
    droiteb := Sender.Images.Image['droiteb'];
    ran2 := Sender.Images.Image['droitev'];
    UseImage(droite, TexFull4);
    TexMap(pBounds4(900, yd, droite.Texture[0].Size.X, droite.Texture[0].Size.Y),
      cColor4($FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF), fxuMultiBlend);
    UseImage(droitev, TexFull4);
    TexMap(pBounds4(lumieredX, lumieredY, droitev.Texture[0].Size.X, droitev.Texture[0].Size.Y),
      cColor4($FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF), fxuMultiBlend);
    UseImage(droiteb, TexFull4);
    TexMap(pBounds4(capteurdX, capteurdY, droiteb.Texture[0].Size.X, droiteb.Texture[0].Size.Y),
      cColor4($FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF), fxuMultiBlend);
    UseImage(ran2, TexFull4);
    TexMap(pBounds4(900,rd , ran2.Texture[0].Size.X, ran2.Texture[0].Size.Y),
      cColor4($FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF), fxuMultiBlend);

     // gauche
    gauche := Sender.Images.Image['gauchev'];
    gauchev := Sender.Images.Image['gauche'];
    gaucheb := Sender.Images.Image['gaucheb'];
    ran3 := Sender.Images.Image['gauchev'];
    UseImage(gauche, TexFull4);
    TexMap(pBounds4(0, yg, gauche.Texture[0].Size.X, gauche.Texture[0].Size.Y),
      cColor4($FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF), fxuMultiBlend);
    UseImage(gauchev, TexFull4);
    TexMap(pBounds4(lumieregX, lumieregY, gauchev.Texture[0].Size.X, gauchev.Texture[0].Size.Y),
      cColor4($FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF), fxuMultiBlend);
    UseImage(gaucheb, TexFull4);
    TexMap(pBounds4(capteurgX, capteurgY, gaucheb.Texture[0].Size.X, gaucheb.Texture[0].Size.Y),
      cColor4($FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF), fxuMultiBlend);
    UseImage(ran3, TexFull4);
    TexMap(pBounds4(0,rg , ran3.Texture[0].Size.X, ran3.Texture[0].Size.Y),
      cColor4($FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF), fxuMultiBlend);



  end;
  ShowMessage('render marche');
end;

procedure TMainFrm.TimerEvent(Sender: TObject);
begin
  //Déclenchement du rendu sur fond bleu
  DefDevice.Render(RenderCallback, self, $FF0000FF);
  //Déclenchement de Process
  Timer.Process;
  ShowMessage('timer up');
end;

end.
