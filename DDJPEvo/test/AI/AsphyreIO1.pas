unit AsphyreIO1;

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

  TMainFrm = class(TForm)
    Memo1: TMemo;
    Button1: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { D�clarations priv�es }
    SpaceDown: boolean;
    procedure ConfigureDevice(Sender: TAsphyreDevice; Tag: TObject;
      var Config: TScreenConfig);
    procedure TimerEvent(Sender: TObject);
    procedure ProcessEvent(Sender: TObject);
    procedure RenderCallback(Sender: TAsphyreDevice; Tag: TObject);
  public
    { D�clarations publiques }
  end;

const
  MAX_WIDTH = 1680;
  MAX_HEIGTH = 1050;
  Sensibilite_Vertical = 20;
  Sensibilite_Horizontal = 20;

var
  MainFrm: TMainFrm;
  t : integer;
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
  AsphyreEffects, Vectors2, DirectInput, Math;

{$R *.dfm}

procedure TMainFrm.Button1Click(Sender: TObject);
begin
    rh:= MAX_HEIGTH + 1000;
    rb:= MAX_HEIGTH + 1200;
    rd:= MAX_HEIGTH + 1400;
    rg:=  MAX_HEIGTH + 800;
    count :=0;

end;

procedure TMainFrm.ConfigureDevice(Sender: TAsphyreDevice; Tag: TObject;
  var Config: TScreenConfig);
begin
  //Param�trage de l'affichage
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
    //L'initalisation a �chou�
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
  //Origine du carr�
    count := 0;
    Memo1.Lines.Clear;
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

  //Param�trage et d�clenchement du Timer
  Timer.OnTimer  := TimerEvent;
  Timer.OnProcess:= ProcessEvent;
  Timer.MaxFPS   := 200;
  Timer.Enabled  := True;
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
    //Appui de 1 � 9 sur le pav� num�rique pour sp�cifier le joystick utilis�


    //Appui sur Echap pour fermer l'application
    if Key[DIK_ESCAPE] then
      Close;

  if Key[DIK_SPACE] then
    SpaceDown := not SpaceDown;
  end;


if yg = -600    //random gauche
then begin lumieregX := MAX_WIDTH+200;
           lumieregY := MAX_HEIGTH+200;
           capteurgX := 0;
           capteurgY := 100;
     end
else  begin
  if (yg = -300) then
  begin
  yg := MAX_HEIGTH + 200;
  lumieregX := MAX_WIDTH+200;
  lumieregY := MAX_HEIGTH+200;
  capteurgX := 0;
  capteurgY := 100;
  yg := -500;
  Memo1.Lines.Clear;
  Memo1.Lines.Add('0');
  end
  else begin if (yg < 170) and (yg > 50)
       then begin yg := -500;
                  lumieregX := 0;
                  lumieregY := 100;
                  capteurgX := MAX_WIDTH+200;
                  capteurgY := MAX_HEIGTH+200;
                  Memo1.Lines.Clear;
                  Memo1.Lines.Add(IntToStr(count+1));
                  count := count+1;
            end
       else yg := yg -10;
  end;
end;


               //droite

if yd = -600
then begin lumieredX := MAX_WIDTH+200;
           lumieredY := MAX_HEIGTH+200;
           capteurdX := 900;
           capteurdY := 100;
     end
else begin
  if (yd = -300)then
  begin
  yd := MAX_HEIGTH + 200;
  lumieredX := MAX_WIDTH+200;
  lumieredY := MAX_HEIGTH+200;
  capteurdX := 900;
  capteurdY := 100;
  yd := -500;
  Memo1.Lines.Clear;
  Memo1.Lines.Add('0');
  end
  else begin if (yd < 170) and (yd > 50)
       then begin yd := -500;
                  lumieredX := 900;
                  lumieredY := 100;
                  capteurdX := MAX_WIDTH+200;
                  capteurdY := MAX_HEIGTH+200;
                  Memo1.Lines.Clear;
                  Memo1.Lines.Add(IntToStr(count+1));
                  count := count+1;
            end
       else yd := yd -10;
  end;
end;


    //haut

if yh = -600
then begin lumierehX := MAX_WIDTH+200;
           lumierehY := MAX_HEIGTH+200;
           capteurhX := 300;
           capteurhY := 100;
     end
else begin
  if (yh = -300)then
  begin
  yh := MAX_HEIGTH + 200;
  lumierehX := MAX_WIDTH+200;
  lumierehY := MAX_HEIGTH+200;
  capteurhX := 300;
  capteurhY := 100;
  yh := -500;
  Memo1.Lines.Clear;
  Memo1.Lines.Add('0');
  end
  else begin if (yh < 170) and (yh > 50)
       then begin yh := -500;
                  lumierehX := 300;
                  lumierehY := 100;
                  capteurhX := MAX_WIDTH+200;
                  capteurhY := MAX_HEIGTH+200;
                  Memo1.Lines.Clear;
                  Memo1.Lines.Add(IntToStr(count+1));
                  count := count+1;
                  end
       else yh := yh -10;
  end;
end;


         //bas

if yb = -600
then begin lumierebX := MAX_WIDTH+200;
           lumierebY := MAX_HEIGTH+200;
           capteurbX := 600;
           capteurbY := 100;
     end
else  begin
  if (yb =-300)then
  begin
  yb := MAX_HEIGTH + 200;
  lumierebX := MAX_WIDTH+200;
  lumierebY := MAX_HEIGTH+200;
  capteurbX := 600;
  capteurbY := 100;
  yb := -500;
  Memo1.Lines.Clear;
  Memo1.Lines.Add('0');
  end
  else begin if (yb < 170) and (yb > 50)
       then begin yb := -500;
                  lumierebX := 600;
                  lumierebY := 100;
                  capteurbX := MAX_WIDTH+200;
                  capteurbY := MAX_HEIGTH+200;
                  Memo1.Lines.Clear;
                  Memo1.Lines.Add(IntToStr(count+1));
                  count := count+1;
                  end
       else yb := yb -10;
  end;
end;


Randomize();

if rb = -600              //rand bas
then begin lumierebX := MAX_WIDTH+200;
           lumierebY := MAX_HEIGTH+200;
           capteurbX := 600;
           capteurbY := 100;
     end
else  begin
  if (rb =-300)then
  begin
  rb := MAX_HEIGTH + 200;
  lumierebX := MAX_WIDTH+200;
  lumierebY := MAX_HEIGTH+200;
  capteurbX := 600;
  capteurbY := 100;
  rb := -500;
  Memo1.Lines.Clear;
  Memo1.Lines.Add('0');
  end
  else begin if (rb < 170) and (rb > 50)
       then begin if Random(100) <=10 then
                  begin
                  Memo1.Lines.Clear;
                  rb := -500;
                  lumierebX := 600;
                  lumierebY := 100;
                  capteurbX := MAX_WIDTH+200;
                  capteurbY := MAX_HEIGTH+200;
                  Memo1.Lines.Add(IntToStr(count+1));
                  count := count+1;
                    end
                  else rb := rb-10;
                  end
       else rb := rb -10;
  end;
end;



if rh = -600   //rand haut
then begin lumierehX := MAX_WIDTH+200;
           lumierehY := MAX_HEIGTH+200;
           capteurhX := 300;
           capteurhY := 100;
     end
else begin
  if (rh = -300)then
  begin
  rh := MAX_HEIGTH + 200;
  lumierehX := MAX_WIDTH+200;
  lumierehY := MAX_HEIGTH+200;
  capteurhX := 300;
  capteurhY := 100;
  rh := -500;
  Memo1.Lines.Clear;
  Memo1.Lines.Add('0');
  end
  else begin if (rh < 170) and (rh > 50)
       then begin if Random(100) <=10 then
                  begin
                  Memo1.Lines.Clear;
                  rh := -500;
                  lumierehX := 300;
                  lumierehY := 100;
                  capteurhX := MAX_WIDTH+200;
                  capteurhY := MAX_HEIGTH+200;
                  Memo1.Lines.Add(IntToStr(count+1));
                  count := count+1;
                    end
                  else rh := rh-10;
                  end
       else rh := rh -10;
  end;
end;



if rd = -600     //random droite
then begin lumieredX := MAX_WIDTH+200;
           lumieredY := MAX_HEIGTH+200;
           capteurdX := 900;
           capteurdY := 100;
     end
else begin
  if (rd = -300)then
  begin
  rd := MAX_HEIGTH + 200;
  lumieredX := MAX_WIDTH+200;
  lumieredY := MAX_HEIGTH+200;
  capteurdX := 900;
  capteurdY := 100;
  rd := -500;
  Memo1.Lines.Clear;
  Memo1.Lines.Add('0');
  end
  else begin if (rd < 170) and (rd > 50)
       then begin if Random(100) <=10 then
                  begin
                  Memo1.Lines.Clear;
                  rd := -500;
                  lumieredX := 900;
                  lumieredY := 100;
                  capteurdX := MAX_WIDTH+200;
                  capteurdY := MAX_HEIGTH+200;
                  Memo1.Lines.Add(IntToStr(count+1));
                  count := count+1;
                    end
                  else rd := rd-10;
            end
       else rd := rd -10;
  end;
end;



if rg = -600    //random gauche
then begin lumieregX := MAX_WIDTH+200;
           lumieregY := MAX_HEIGTH+200;
           capteurgX := 0;
           capteurgY := 100;
     end
else  begin
  if (rg = -300) then
  begin
  rg := MAX_HEIGTH + 200;
  lumieregX := MAX_WIDTH+200;
  lumieregY := MAX_HEIGTH+200;
  capteurgX := 0;
  capteurgY := 100;
  rg := -500;
  Memo1.Lines.Clear;
  Memo1.Lines.Add('0');
  end
  else begin if (rg < 170) and (rg > 50)
       then begin if Random(100) <=10 then
                  begin
                  rg := -500;
                  lumieregX := 0;
                  lumieregY := 100;
                  capteurgX := MAX_WIDTH+200;
                  capteurgY := MAX_HEIGTH+200;
                  Memo1.Lines.Clear;
                  Memo1.Lines.Add(IntToStr(count+1));
                  count := count+1;
                  end
                  else rg := rg-10;
            end
       else rg := rg -10;
  end;
end;


end;






procedure TMainFrm.RenderCallback(Sender: TAsphyreDevice; Tag: TObject);

  var
bas,basv,basb,haut,hautv,hautb,droite,droitev,droiteb,gauche,gauchev,gaucheb,AsImage,ran1,ran2,ran3,ran0: TAsphyreCustomImage;
begin

  with Sender.Canvas do
  begin

    // ****Dessin de l'arri�re plan

    //Chargement de l'image
    AsImage := Sender.Images.Image['Back'];
    //Image � utiliser
    UseImage(AsImage, TexFull4);
    //Dessin de l'image
    //Image � utiliser
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
end;

procedure TMainFrm.TimerEvent(Sender: TObject);
begin
  //D�clenchement du rendu sur fond bleu
  DefDevice.Render(RenderCallback, self, $FF0000FF);
  //D�clenchement de Process
  Timer.Process;
end;

end.
