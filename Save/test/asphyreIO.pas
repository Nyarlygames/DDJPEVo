unit asphyreIO;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, AsphyreDevices, AsphyreImages, AsphyreTypes, AsphyreJoystick, AsphyreMouse,
  AsphyreKeyboard, AsphyreInputs, StdCtrls,droite,gauche,haut,bas,test,ExtCtrls, ExtDlgs,
  Menus,fmod,fmodtypes;



const
  MAX_WIDTH = 1280;
  MAX_HEIGTH = 800;
  Sensibilite_Vertical = 20;
  Sensibilite_Horizontal = 20;


  type

  TMainFrm = class(TForm)
    Memo1: TMemo;
    Timer1: TTimer;
    Edit1: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure OnTimer(Sender: TObject);
    procedure Edit1Change(Sender: TObject; flec : t_fleche);

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
  down : integer;
  music : PFSOUNDSTREAM;
  Droit : TDroitfrm;
  Gauche : TGaucheFrm;
  Haut : THautFrm;
  Bas : TBasFrm;
  nbr : integer;
  vecteur : t_vec;
  temp : integer;
  lumierehX, lumieregX,lumieredX,lumierebX : integer;
  lumiereY : integer;
  capteurhX,capteurbX,capteurgX,capteurdX : integer;
  capteurY : integer;
  recountg,recountd,recounth,recountb : integer;

implementation

uses
  AsphyreEvents, AsphyreTimer, AsphyreSystemFonts, MediaImages, MediaFonts,
  AsphyreEffects, Vectors2, DirectInput, Math;

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

procedure TMainFrm.Edit1Change(Sender: TObject; flec : t_fleche);

begin
 if Abs(round((lumierey + 30 - flec.ord))) <= 30  then
  Edit1.Text := 'Marvelous'
 else
   if Abs(round((lumierey + 30 - flec.ord))) <= 50  then
    Edit1.Text := 'Perfect'
   else
    if Abs(round((lumierey + 30 - flec.ord))) <= 80  then
     Edit1.Text := 'Great'
    else
      if Abs(round((lumierey +30 - flec.ord))) > 80  then
       Edit1.Text := 'Bad'
           
end;

procedure TMainFrm.FormCreate(Sender: TObject);
var
i : integer;
F : TextFile;
Line : String;
begin
FSOUND_SetPaused(FSOUND_ALL, true ) ;
Timer1.Enabled := true;
Timer1.OnTimer := OnTimer;
down := 2;
recountg := -10;
recountd := -10;
recounth := -10;
recountb := -10;
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

  //Origine du carré
    Memo1.Lines.Clear;

  lumieregX := MAX_WIDTH + 300;
  lumierehX := MAX_WIDTH + 300;
  lumierebX := MAX_WIDTH + 300;
  lumieredX := MAX_WIDTH + 300;
  capteurY := 30;
  capteurhX := 350;
  capteurbX := 650;
  capteurdX := 950;
  capteurgX := 50;

  //Paramétrage et déclenchement du Timer
  Timer.OnTimer  := TimerEvent;
  Timer.OnProcess:= ProcessEvent;
  Timer.MaxFPS   := 200;
  Timer.Enabled  := True;


for i := 0 to MAX_FLECHES do
 begin vecteur[i].dir := 0;
       vecteur[i].time := 0;
       vecteur[i].nombre := i;
       vecteur[i].sender := DefDevice;
       vecteur[i].tag := MainFrm;
       vecteur[i].ord := (MAX_HEIGTH + 300);
 end;
i := 0;
AssignFile(F,'test.jp');
Reset(F);
Readln(F,Line);
music := FSOUND_Stream_Open(PAnsiChar(Line),FSOUND_LOOP_NORMAL,0,0) ;
Readln(F,Line);
while (not(eof(F))) and (i<=MAX_FLECHES) do
  begin Readln(F,Line);
        if Line <> '' then
         begin if Line = 'Gauche' then
                  begin vecteur[i].img := DefDevice.Images.Image['gauchev'];
                        vecteur[i].dir := 203;
                  end
                else if Line = 'Droite' then
                      begin vecteur[i].img := DefDevice.Images.Image['droitev'];
                            vecteur[i].dir := 205;
                      end
                     else if Line = 'Haut' then
                           begin vecteur[i].img := DefDevice.Images.Image['hautv'];
                                 vecteur[i].dir := 200;
                           end
                          else if Line = 'Bas' then
                                begin vecteur[i].img :=  DefDevice.Images.Image['basv'];
                                      vecteur[i].dir := 208;
                                end;
               Readln(F,Line);
               vecteur[i].time := StrToInt(Line);
               vecteur[i].nombre := i;
               i:=i+1;
         end;
  end;
nbr := i-1;
CloseFile(F);

temp := 0;

end;

procedure TMainFrm.FormDestroy(Sender: TObject);
begin
  AsphyreInput.Finalize;
  //Finalisation de DirectX
  Devices.Finalize;
end;



procedure TMainFrm.ProcessEvent(Sender: TObject);
var
v,w : integer;
dirkey : string;
begin
  if AsphyreInput.Keyboard.Update then
  with AsphyreInput.Keyboard do
  begin
    //Appui sur Echap pour fermer l'application
    if Key[DIK_ESCAPE] then
      Close;

  end;

for v:=0 to nbr do
begin if temp-1 >= vecteur[v].time then
       vecteur[v].ord := vecteur[v].ord -down;
end;

if AsphyreInput.Keyboard.Update
      then begin with AsphyreInput.Keyboard do
                           begin if Key[DIK_LEFT] then
                                 begin recountg:= temp;
                                       lumieregX:= 50;
                                       capteurgX := MAX_WIDTH+300;
                                       dirkey := 'Gauche'
                                 end;
                                 if Key[DIK_DOWN] then
                                 begin recountb:= temp;
                                       lumierebX:= 650;
                                       capteurbX := MAX_WIDTH+300;
                                       dirkey := 'Bas'
                                 end;
                                 if Key[DIK_UP] then
                                 begin recounth:= temp;
                                       lumierehX:= 350;
                                       capteurhX := MAX_WIDTH+300;
                                       dirkey := 'Haut'
                                 end;
                                 if Key[DIK_RIGHT] then
                                 begin recountd:= temp;
                                       lumieredX:= 950;
                                       capteurdX := MAX_WIDTH+300;
                                       dirkey := 'Droite'
                                 end;
                            end;
           end;
if temp >= recountg+1 then
begin capteurgX := 50;
      lumieregX := MAX_WIDTH +300;
end;
if temp >= recountd+1 then
begin capteurdX := 950;
      lumieredX := MAX_WIDTH +300;
end;
if temp >= recounth+1 then
begin capteurhX := 350;
      lumierehX := MAX_WIDTH +300;
end;
if temp >= recountb+1 then
begin capteurbX := 650;
      lumierebX := MAX_WIDTH +300;
end;
if temp >30 then
Memo1.Lines.add(IntToStr((temp div 10)-3));

if temp >30 then
begin
FSOUND_Stream_SetLoopCount(music, 1) ;
FSOUND_Stream_play( FSOUND_FREE, music ) ;
FSOUND_SetPaused(FSOUND_ALL, false ) ;
end;


for w := 0 to nbr do
 if vecteur[w].ord = (-280)  then
  Edit1.Text := 'Miss'
  else
if abs(round(vecteur[w].ord - (capteury + 30))) < 100 then
 if ((dirkey = 'Gauche') and ( vecteur[w].dir = 203))  then
  begin
    Edit1.Text := '';
    Edit1Change(Edit1,vecteur[w]);
    vecteur[w].ord := -400;
  end
 else
  if(( dirkey = 'Droite') and (vecteur[w].dir = 205))  then
   begin
     Edit1.Text := '';
     Edit1Change(Edit1,vecteur[w]);
     vecteur[w].ord := -400;
   end
  else
   if ((dirkey = 'Haut') and (vecteur[w].dir = 200))  then
    begin
      Edit1.Text := '';
      Edit1Change(Edit1,vecteur[w]);
      vecteur[w].ord := -400;
    end
   else
    if ((dirkey = 'Bas') and (vecteur[w].dir = 208))  then
     begin
      Edit1.Text := '';
      Edit1Change(Edit1,vecteur[w]);
      vecteur[w].ord := -400;
     end;

end;


procedure TMainFrm.RenderCallback(Sender: TAsphyreDevice; Tag: TObject);
var
v : integer;
basv,basb,hautv,hautb,droitev,droiteb,gauchev,gaucheb: TAsphyreCustomImage;

begin
for v:=0 to nbr do
begin if vecteur[v].ord > -300 then
if temp-31 >= vecteur[v].time then
      begin if vecteur[v].dir = 203 then
             Gauche.RenderCallback(vecteur[v])
            else if vecteur[v].dir = 205 then
                  Droit.RenderCallback(vecteur[v])
                 else if vecteur[v].dir = 200 then
                       Haut.RenderCallback(vecteur[v])
                      else if vecteur[v].dir = 208 then
                            Bas.RenderCallback(vecteur[v]);
                   end;
end;

  with Sender.Canvas do
  begin



    //bas
    basv := Sender.Images.Image['bas'];
    basb := Sender.Images.Image['basb'];
    UseImage(basv, TexFull4);
    TexMap(pBounds4(lumierebX, capteurY, basv.Texture[0].Size.X, basv.Texture[0].Size.Y),
      cColor4($FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF), fxuMultiBlend);
    UseImage(basb, TexFull4);
    TexMap(pBounds4(capteurbX, capteurY, basb.Texture[0].Size.X, basb.Texture[0].Size.Y),
      cColor4($FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF), fxuMultiBlend);



      //haut

    hautv := Sender.Images.Image['haut'];
    hautb := Sender.Images.Image['hautb'];
    UseImage(hautv, TexFull4);
    TexMap(pBounds4(lumierehX, capteurY, hautv.Texture[0].Size.X, hautv.Texture[0].Size.Y),
      cColor4($FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF), fxuMultiBlend);
    UseImage(hautb, TexFull4);
    TexMap(pBounds4(capteurhX, capteurY, hautb.Texture[0].Size.X, hautb.Texture[0].Size.Y),
      cColor4($FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF), fxuMultiBlend);

     // droite

    droitev := Sender.Images.Image['droite'];
    droiteb := Sender.Images.Image['droiteb'];
    UseImage(droitev, TexFull4);
    TexMap(pBounds4(lumieredX, capteurY, droitev.Texture[0].Size.X, droitev.Texture[0].Size.Y),
      cColor4($FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF), fxuMultiBlend);
    UseImage(droiteb, TexFull4);
    TexMap(pBounds4(capteurdX, capteurY, droiteb.Texture[0].Size.X, droiteb.Texture[0].Size.Y),
      cColor4($FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF), fxuMultiBlend);

     // gauche
    gauchev := Sender.Images.Image['gauche'];
    gaucheb := Sender.Images.Image['gaucheb'];
    UseImage(gauchev, TexFull4);
    TexMap(pBounds4(lumieregX, capteurY, gauchev.Texture[0].Size.X, gauchev.Texture[0].Size.Y),
      cColor4($FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF), fxuMultiBlend);

    UseImage(gaucheb, TexFull4);
    TexMap(pBounds4(capteurgX, capteurY, gaucheb.Texture[0].Size.X, gaucheb.Texture[0].Size.Y),
      cColor4($FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF), fxuMultiBlend);
  end;
if temp <=10 then
  begin Memo1.Lines.add('1')
  end
else if (temp >10) and (temp <=20) then
  begin Memo1.Lines.add('2');
  end
else if (temp >20) and (temp <=30) then
  begin Memo1.Lines.add('3');
  end;

end;

procedure TMainFrm.OnTimer(Sender: TObject);
begin
temp := temp+1;
end;

procedure TMainFrm.TimerEvent(Sender: TObject);
begin
  //Déclenchement du rendu sur fond bleu
  DefDevice.Render(RenderCallback, self, $FF0000FF);
  //Déclenchement de Process
  Timer.Process;
end;



end.
