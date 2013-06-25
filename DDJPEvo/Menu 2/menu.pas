unit menu;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,AsphyreDevices, AsphyreImages, StdCtrls,ShellAPI, AsphyreKeyboard,
  AsphyreInputs, DirectInput;

type
  TMainFrm = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button5: TButton;
    Button6: TButton;
    Button4: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
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
  AsphyreEvents, AsphyreTimer, AsphyreTypes, MediaFonts,MediaImages, AsphyreEffects;


procedure TMainFrm.Button1Click(Sender: TObject);
begin
ShellExecute(0, Nil, 'AsphyreIO.exe', nil, '..\Moteur Jeu', SW_NORMAL);
end;

procedure TMainFrm.Button2Click(Sender: TObject);
begin
ShellExecute(0, Nil, 'ClientChat.exe', nil, '..\delphichat', SW_NORMAL);
ShellExecute(0, Nil, 'server.exe', nil, '..\delphichat', SW_NORMAL);
end;

procedure TMainFrm.Button3Click(Sender: TObject);
begin
ShellExecute(0, Nil, 'AsphyreIO.exe', nil, '..\test\Moteur Jeu', SW_NORMAL);
end;

procedure TMainFrm.Button4Click(Sender: TObject);
begin
ShellExecute(0, Nil, 'AsphyreIO.exe', nil, '..\test\AI', SW_NORMAL);
end;

procedure TMainFrm.Button5Click(Sender: TObject);
begin
ShellExecute(0, Nil, 'index.html', nil, '..\', SW_NORMAL);
end;

procedure TMainFrm.Button6Click(Sender: TObject);
begin
ShellExecute(0, Nil, 'Project1.exe', nil, '..\Moteur Sound\', SW_NORMAL);
end;

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
  ImageGroups.ParseLink('/Ressources.xml'); //Chargement des images
  FontGroups.ParseLink('/Ressources.xml'); //Chargement des polices

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

  if AsphyreInput.Keyboard.Update then
  with AsphyreInput.Keyboard do
  begin
      //Appui sur Echap pour fermer l'application
      if Key[DIK_ESCAPE] then
      Close;
  end;
end;

procedure TMainFrm.RenderCallback(Sender: TAsphyreDevice; Tag: TObject);

var
AsImage: TAsphyreCustomImage;

begin


  with Sender.Canvas do
  begin
    //Pour vérfier que l'image est correcte, on peut désactiver l'anticrénelage
    Antialias := atBest;




    // ****Dessin de l'arrière plan

    //Chargement de l'image
    AsImage := Sender.Images.Image['Background'];
    //Image à utiliser
    UseImage(AsImage, TexFull4);
    //Dessin de l'image
    TexMap(pRect4(Rect(0, 0, ClientWidth, ClientHeight)), clWhite4, fxuBlend);


    //Titre - Header
    Sender.Fonts.Font['police'].TextOut('DANCE DANCE JP EVOLUTION Soutenance 3',
    250, 10, $FFFF0000);

    //Titre - Menu
    Sender.Fonts.Font['police'].TextOut('MENU',
    175, 500, $FFFF0000);
    // ****Dessin de la ligne de soulignement du titre
    LineWidth := 2;
    //Dessin de la ligne avec LineEx pour avoir une épaisseur
    LineEx(25, 540, 350, 540, $FFFE2415);

    // affiche les images
    AsImage := Sender.Images.Image['bg'];
    UseImage(AsImage, TexFull4);
    {TexMap(pBounds4(50, 50, AsImage.Texture[0].Size.X, AsImage.Texture[0].Size.Y),
      cColor4($FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF), fxuMultiBlend);
    TexMap(pBounds4(50, 180, AsImage.Texture[0].Size.X, AsImage.Texture[0].Size.Y),
      cColor4($FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF), fxuMultiBlend);
    TexMap(pBounds4(50, 310, AsImage.Texture[0].Size.X, AsImage.Texture[0].Size.Y),
      cColor4($FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF), fxuMultiBlend);
    TexMap(pBounds4(50, 440, AsImage.Texture[0].Size.X, AsImage.Texture[0].Size.Y),
      cColor4($FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF), fxuMultiBlend);}
    TexMap(pBounds4(25, 475, AsImage.Texture[0].Size.X, AsImage.Texture[0].Size.Y),
      cColor4($FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF), fxuMultiBlend);
  end;
end;


procedure TMainFrm.TimerEvent(Sender: TObject);
begin
  DefDevice.Render(RenderCallback, self, $000000);
  Timer.Process;
end;





end.
