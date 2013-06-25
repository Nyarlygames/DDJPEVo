unit menu;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,AsphyreDevices, AsphyreImages, StdCtrls,AsphyreKeyboard, AsphyreInputs,
  ComCtrls;
type
  TMainFrm = class(TForm)
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

var
  MainFrm: TMainFrm;
  yib,count : integer;
  lumiereX, lumiereY : integer;
  capteurX, capteurY : integer;
implementation

{$R *.dfm}
uses
  AsphyreEvents, AsphyreTimer, AsphyreTypes, MediaFonts,MediaImages, AsphyreEffects, DirectInput;



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

  if (not Devices.Initialize(ConfigureDevice, Self)) then //Initialisation
  begin
    MessageDlg('Asphyre n''a pas pu s''initialiser!', mtError, [mbOk], 0);
    Close();
    Exit;
  end;
  yib := 400;
  lumiereX := 4000;
  lumiereY := 4000;
  capteurX := 0;
  capteurY := 0;
  AsphyreInput.Keyboard.Initialize;
  SpaceDown := false;
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
  if (yib <= 0)then
  begin
  yib := 400;
  end
  else if (yib < 100) and (yib > 0)
       then begin if AsphyreInput.Keyboard.Update
                  then begin with AsphyreInput.Keyboard
                                 do begin if Key[DIK_DOWN]
                                          then
                                          begin yib := 10;
                                            lumiereX := 0;
                                            lumiereY := 0;
                                            capteurX := 4000;
                                            capteurY := 4000;
                                          end
                                          else yib := yib -1;
                                    end
                       end
                  else yib := -1
            end
       else yib := yib -2;
end;

procedure TMainFrm.RenderCallback(Sender: TAsphyreDevice; Tag: TObject);

var
bas,vide,black: TAsphyreCustomImage;

begin
  with Sender.Canvas do
  begin
    //Pour vérfier que l'image est correcte, on peut désactiver l'anticrénelage
    Antialias := atBest;


// affiche les images
    bas := Sender.Images.Image['vide'];
    vide := Sender.Images.Image['bas'];
    black := Sender.Images.Image['black'];
    UseImage(bas, TexFull4);
    TexMap(pBounds4(0, yib, bas.Texture[0].Size.X, bas.Texture[0].Size.Y),
      cColor4($FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF), fxuMultiBlend);
    UseImage(vide, TexFull4);
    TexMap(pBounds4(lumiereX, lumiereY, vide.Texture[0].Size.X, vide.Texture[0].Size.Y),
      cColor4($FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF), fxuMultiBlend);
    UseImage(black, TexFull4);
    TexMap(pBounds4(capteurX, capteurY, vide.Texture[0].Size.X, vide.Texture[0].Size.Y),
      cColor4($FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF), fxuMultiBlend);
  end;
end;


procedure TMainFrm.TimerEvent(Sender: TObject);
begin
  DefDevice.Render(RenderCallback, self, $000000);
  Timer.Process;
end;





end.
