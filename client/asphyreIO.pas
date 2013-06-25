unit asphyreIO;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, AsphyreDevices, AsphyreImages, AsphyreTypes, AsphyreJoystick, AsphyreMouse,
  AsphyreKeyboard, AsphyreInputs, StdCtrls,droite,gauche,haut,bas,test,ExtCtrls, ExtDlgs,
  Menus,fmod,fmodtypes,ScktComp;



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
    Client: TClientSocket;
    Button1: TButton;
    Button2: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure OnTimer(Sender: TObject);
    procedure Edit1Change(Sender: TObject; flec : t_fleche);
    procedure ClientRead(Sender: TObject; Socket: TCustomWinSocket);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);

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
  recu : string;
  Creat : TextFile;
  F : TextFile;
  debut : boolean;
  initi : integer;
  dirkey : string;
  know : string;
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



procedure TMainFrm.Button1Click(Sender: TObject);
begin
  Client.Host := Edit1.Text;
  Client.Open;
  Edit1.Text := 'Connecté';
end;

procedure TMainFrm.Button2Click(Sender: TObject);
begin
    Client.Close;
    Edit1.Text := 'Déconnecté';
end;

procedure TMainFrm.ClientRead(Sender: TObject; Socket: TCustomWinSocket);
begin
if recu = 'init' then
begin
recu := Client.Socket.ReceiveText;
debut := true;
end
{if initi = 0 then
begin if (not(FileExists(recu))) then
 begin AssignFile(Creat,recu);
       Rewrite(Creat);
       initi :=1;
       Client.Socket.SendText('suite');
       CloseFile(Creat);
 end;
end
else begin if (initi<>0) and (Client.Socket.ReceiveText <> 'eof') then
            begin Memo1.Lines.Add(Client.Socket.ReceiveText);
                  AssignFile(Creat,'test.jp');
                  Append(Creat);
                  Writeln(Creat,Client.Socket.ReceiveText);
                  Client.Socket.SendText('suite');
                  CloseFile(Creat);
            end;
     end;}
else
begin
know := Client.Socket.ReceiveText;
if know[1]= 'g' then
begin recountg:= temp;
 lumieregX:= 50;
 capteurgX := MAX_WIDTH+300;
 dirkey := 'Gauche';
end;
if know[1] = 'b' then
begin recountb:= temp;
 lumierebX:= 650;
 capteurbX := MAX_WIDTH+300;
 dirkey := 'Bas';
end;
if know[1]= 'h' then
 begin recounth:= temp;
 lumierehX:= 350;
 capteurhX := MAX_WIDTH+300;
 dirkey := 'Haut';
end;
if know[1] = 'd' then
 begin recountd:= temp;
 lumieredX:= 950;
 capteurdX := MAX_WIDTH+300;
 dirkey := 'Droite';
 end;
end;

end;

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
begin
recu := 'init';
initi := 0;
debut := false;
Client.Port:=666;
FSOUND_Init ( 44100, 42, 0 ) ;
Timer1.Enabled := true;
Timer1.OnTimer := OnTimer;
down := 10;
recountg := -10;
recountd := -10;
recounth := -10;
recountb := -10;
dirkey := '';
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
v,w,i : integer;
Line : string;
begin
  if AsphyreInput.Keyboard.Update then
  with AsphyreInput.Keyboard do
  begin
    //Appui sur Echap pour fermer l'application
    if Key[DIK_ESCAPE] then
      Close;

  end;
if not(debut) then
temp := 0
else
begin
if initi = 0 then
begin
i := 0;
AssignFile(F,recu);
Reset(F);
Readln(F,Line);
Line := GetCurrentDir+Line ;
music := FSOUND_Stream_Open(PAnsiChar(Line),FSOUND_LOOP_NORMAL,0,0) ;
FSOUND_Stream_SetLoopCount(music, 1) ;
FSOUND_Stream_play( FSOUND_FREE, music ) ;
FSOUND_SetPaused(FSOUND_ALL, true ) ;
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
initi := 1 ;
temp := 1;
end;
end;

for v:=0 to nbr do
begin if temp-31 >= vecteur[v].time then
       vecteur[v].ord := vecteur[v].ord -down;
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
begin
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
    dirkey :='';
  end
 else       
  if(( dirkey = 'Droite') and (vecteur[w].dir = 205))  then
   begin
     Edit1.Text := '';
     Edit1Change(Edit1,vecteur[w]);
     vecteur[w].ord := -400;
     dirkey :='';
   end
  else
   if ((dirkey = 'Haut') and (vecteur[w].dir = 200))  then
    begin
      Edit1.Text := '';
      Edit1Change(Edit1,vecteur[w]);
      vecteur[w].ord := -400;
      dirkey :='';
    end
   else
    if ((dirkey = 'Bas') and (vecteur[w].dir = 208))  then
     begin
      Edit1.Text := '';
      Edit1Change(Edit1,vecteur[w]);
      vecteur[w].ord := -400;
      dirkey :='';
     end;


Memo1.Lines.add (inttostr(temp div 10));

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
