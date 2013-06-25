unit AsphyreIO1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, AsphyreDevices, AsphyreImages, AsphyreTypes, AsphyreJoystick, AsphyreMouse,
  AsphyreKeyboard, AsphyreInputs, fmod, fmodtypes, MoteurSon;

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
    OriginRectPos: TPoint;
    DispRectPos: TPoint;
  //  CurrentJoystick: integer;
  //  JoyPos: TPoint;
  //  Joys: array of TJoyInfos;
    JoyDown: boolean;
    MouseDown: boolean;
    SpaceDown: boolean;
    procedure ConfigureDevice(Sender: TAsphyreDevice; Tag: TObject;
      var Config: TScreenConfig);
    procedure TimerEvent(Sender: TObject);
    procedure ProcessEvent(Sender: TObject);
    procedure RenderCallback(Sender: TAsphyreDevice; Tag: TObject);
{    procedure DrawJoyInfos(Sender: TAsphyreDevice);  }
   { function GetJoyInfos(const JoyIndex: integer): TJoyInfos;    }
  public
    { Déclarations publiques }
  end;

const
  MAX_WIDTH = 1280;
  MAX_HEIGTH = 1024;
  Sensibilite_Vertical = 20;
  Sensibilite_Horizontal = 20;

var
  MainFrm: TMainFrm;
  t : integer;
  Couleur_next : integer;

FUNCTION DesktopColor(CONST X, Y: Integer): TColor;

implementation

uses
  AsphyreEvents, AsphyreTimer, AsphyreSystemFonts, MediaImages, MediaFonts,
  AsphyreEffects, Vectors2, DirectInput, Math;

{$R *.dfm}

FUNCTION DesktopColor(CONST X, Y: Integer): TColor;
VAR
  c  : TCanvas;
BEGIN
  c := TCanvas.Create;
  TRY
    c.Handle := GetWindowDC(GetDesktopWindow);
    Result := GetPixel(c.Handle, X, Y);
  FINALLY c.Free; END;
END;    




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

{procedure TMainFrm.DrawJoyInfos(Sender: TAsphyreDevice);
var
  i: integer;
  Color: Cardinal;
begin
  //Y a-t-il des joysticks?
  if AsphyreInput.Joysticks.Count > 0 then
  begin
    //Affichage du nombre de joystick(s) et des amplitudes de déplacement
    Sender.SysFonts.Font['s/arial'].TextOut(
      Format('Joysticks : %u (X=%d, Y=%d)',
        [AsphyreInput.Joysticks.Count, JoyPos.X, JoyPos.Y]),
      10, 25, $FF777777);
    //Affichage des données de chaque joystick
    with Sender.Canvas do
    for i := 0 to AsphyreInput.Joysticks.Count - 1 do
    begin
      //Si le joystick est le joystick courant
      if i = CurrentJoystick then
      begin
        //Aficher un cercle rouge en face du texte
        FillCircle(10, 51 + i * 20, 5, 10, clRed4, fxuBlend);
        //Couleur du texte en blanc
        Color := $FFFFFFFF;
      end else
        //Couleur du texte en gris
        Color := $FF777777;

      //Affichage du texte
      Sender.SysFonts.Font['s/arial'].TextOut(
        Format('%d :  %d axe(s),  %d bouton(s),  %d POV(s)',
          [i + 1, Joys[i].Axis, Joys[i].Buttons, Joys[i].POVs]),
        20, 45 + i * 20, Color);
    end;
  end else
    //S'il n'y a pas de joystick
    Sender.SysFonts.Font['s/arial'].TextOut('Aucun joystick détecté.',
  550, 80, $FF777777);
end;         }

procedure TMainFrm.FormCreate(Sender: TObject);
var
  I: Integer;
begin
  //Chargement des images
  ImageGroups.ParseLink('Ressources.xml');
  //Chargements des polices
  FontGroups.ParseLink('Ressources.xml');

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
 { AsphyreInput.Joysticks.Initialize; }
  AsphyreInput.Keyboard.Initialize;
  AsphyreInput.Mouse.Initialize;
  //Initialise le joystick courant
 { CurrentJoystick := 0;
  //Spécifie la longueur du tableau
  SetLength(Joys, AsphyreInput.Joysticks.Count);
  //Initialise chaque information de joystick
  for I := 0 to AsphyreInput.Joysticks.Count - 1 do
    Joys[I] := GetJoyInfos(i);
  //Initialisation de l'état appuyé à faux
  JoyDown := false;         }
  MouseDown := false;
  SpaceDown := false;
  //Origine du carré
  OriginRectPos := Point(250,150);
  
  //Création d'une police système
  DefDevice.SysFonts.CreateFont('s/arial', 'arial', 9, False, fwtBold,
      fqtClearType, fctAnsi);

  //Paramétrage et déclenchement du Timer
  Timer.OnTimer  := TimerEvent;
  Timer.OnProcess:= ProcessEvent;
  Timer.MaxFPS   := 200;
  Timer.Enabled  := True;
end;

procedure TMainFrm.FormDestroy(Sender: TObject);
begin
  //Finalisation de AsphyreInput
 // SetLength(Joys, 0);
  AsphyreInput.Finalize;
  //Finalisation de DirectX
  Devices.Finalize;
end;

{function TMainFrm.GetJoyInfos(const JoyIndex: integer): TJoyInfos;
begin
  with AsphyreInput.Joysticks[JoyIndex].DeviceCaps do
  begin
    //Nombre d'axes
    Result.Axis := dwAxes;
    //Nombre de boutons
    Result.Buttons := dwButtons;
    //Nombre de POVs
    Result.POVs := dwPOVs;
  end;
end;      }

procedure TMainFrm.ProcessEvent(Sender: TObject);
const
  RectSize = 40;
  DecValue = 10;
  JoyDeadZone = 3000;
var
  Decalage: TPoint;
begin
  t := 1;
  //Mise à zéro du décalage
  Decalage := Point(0, 0);


  //Mise à jour des données de la souris
  if AsphyreInput.Mouse.Update then
  with AsphyreInput.Mouse do
  begin
    //Assignation des valeurs des mouvements
    //Decalage.X := DeltaX * 2;
    //Decalage.Y := DeltaY * 2;

    //Si le bouton gauche est enfoncé
    if Pressed[0] then
      MouseDown := not MouseDown;
    //S'il est relaché
  //if Released[0] then
  //   MouseDown := false;
  end;

  {//Vérification de la présence d'un joystick
  if AsphyreInput.Joysticks.Count > 0 then
  begin
    //Mise à jour des données des joysticks
    if AsphyreInput.Joysticks.Update then
    with AsphyreInput.Joysticks[CurrentJoystick].JoyState do
    begin
      //Si l'amplitude est supérieure à la deadzone alors effectuer le déplacement

      //en X
      if Abs(lX) > JoyDeadZone then
        Decalage.X := lX div 200;

      //en Y
      if Abs(lY) > JoyDeadZone then
        Decalage.Y := lY div 200;

      //Etat baissé si le bouton 0 est pressé
      JoyDown := rgbButtons[0] > 0;

      //Pour l'affichage des données
      JoyPos := Point(lX, lY);
    end;
  end;   }

  if AsphyreInput.Keyboard.Update then
  with AsphyreInput.Keyboard do
  begin
    //Appui de 1 à 9 sur le pavé numérique pour spécifier le joystick utilisé
   { if Key[DIK_NUMPAD1] then CurrentJoystick :=
      Min(0, AsphyreInput.Joysticks.Count - 1) else
    if Key[DIK_NUMPAD2] then CurrentJoystick :=
      Min(1, AsphyreInput.Joysticks.Count - 1) else
    if Key[DIK_NUMPAD3] then CurrentJoystick :=
      Min(2, AsphyreInput.Joysticks.Count - 1) else
    if Key[DIK_NUMPAD4] then CurrentJoystick :=
      Min(3, AsphyreInput.Joysticks.Count - 1) else
    if Key[DIK_NUMPAD5] then CurrentJoystick :=
      Min(4, AsphyreInput.Joysticks.Count - 1) else
    if Key[DIK_NUMPAD6] then CurrentJoystick :=
      Min(5, AsphyreInput.Joysticks.Count - 1) else
    if Key[DIK_NUMPAD7] then CurrentJoystick :=
      Min(6, AsphyreInput.Joysticks.Count - 1) else
    if Key[DIK_NUMPAD8] then CurrentJoystick :=
      Min(7, AsphyreInput.Joysticks.Count - 1) else
    if Key[DIK_NUMPAD9] then CurrentJoystick :=
      Min(8, AsphyreInput.Joysticks.Count - 1);     }

if (DispRectPos.Y <= 130) and (DispRectPos.X <= 170) then
begin
    //Fake limite batiment X
    if (DispRectPos.X < 170) or (DispRectPos.Y >129) then
    begin
        if Key[DIK_RIGHT] then
          Decalage.X := DecValue else
        if Key[DIK_LEFT] then
        begin


          Decalage.X := 0;
        end;
    end
    else
    begin
      if Key[DIK_RIGHT] then
        Decalage.X := DecValue else
      if Key[DIK_LEFT] then
        Decalage.X := -DecValue;
    end;

    //Fake limite batiment Y
    if (DispRectPos.Y < 130) or (DispRectPos.X > 169) then
      begin
        if Key[DIK_DOWN] then
          Decalage.Y := DecValue else
        if Key[DIK_UP] then
        begin
          //on charge la musique ( nom fichier / osef ^^ / debut de la ziq / jusqu'ou )
          music := FSOUND_Stream_Open('gong.wav',0,0,0) ;

          //on joue la musique ( FMOD choisi un canal, musique en question )
          FSOUND_Stream_play( FSOUND_FREE, music ) ;

          Decalage.Y := 0;
        end;
      end
    else
      begin
      if Key[DIK_DOWN] then
        Decalage.Y := DecValue else
      if Key[DIK_UP] then
        Decalage.Y := -DecValue;
      end;

end
else
begin

    //Appui sur droite ou gauche
    if (DispRectPos.X > MAX_WIDTH - Sensibilite_Horizontal -50) or (DispRectPos.X < 10 + Sensibilite_Horizontal ) then
    begin
      if (DispRectPos.X > MAX_WIDTH - Sensibilite_Horizontal -50) then
      begin  //limite à droite
        if Key[DIK_RIGHT] then
          Decalage.X := 0 else
        if Key[DIK_LEFT] then
          Decalage.X := -DecValue;
      end
      else  // limite à gauche
      begin
        if Key[DIK_RIGHT] then
          Decalage.X := DecValue else
        if Key[DIK_LEFT] then
        begin

          Decalage.X := 0;
        end;
      end;
    end
    else
    begin
      if Key[DIK_RIGHT] then
        Decalage.X := DecValue else
      if Key[DIK_LEFT] then
        Decalage.X := -DecValue;
    end;


    //Appui sur bas ou haut
    if (DispRectPos.Y > MAX_HEIGTH-50-224) or (DispRectPos.Y < 10) then
    begin
      if (DispRectPos.Y > MAX_HEIGTH-50-224) then
      begin  //limite en bas
        if Key[DIK_DOWN] then
        begin
          Decalage.Y := 0
        end
        else
        if Key[DIK_UP] then
          Decalage.Y := -DecValue;
      end
      else  // limite en haut
      begin
        if Key[DIK_DOWN] then
          Decalage.Y := DecValue else
        if Key[DIK_UP] then
          Decalage.Y := 0;
      end;
    end
    else
    begin
      if Key[DIK_DOWN] then
        Decalage.Y := DecValue else
      if Key[DIK_UP] then
        Decalage.Y := -DecValue;
    end;

end;





    //mettre la chanson en pause =====> ne marche pas encore ^^
      if AsphyreInput.Mouse.Update then
      with AsphyreInput.Mouse do
        if MouseDown then
        begin
         { if Fmusic_GetPaused(music) = true then     // Si la chanson est en pause
              Fmusic_SetPaused(music, false) // On enlève la pause
          else                              // Sinon, elle est en cours de lecture
            Fmusic_SetPaused(music, true);// On met en pause   }
        end;


    //Appui sur Echap pour fermer l'application
    if Key[DIK_ESCAPE] then
      Close;

    //Collision sur un mur rouge
   { Couleur_next := DesktopColor(OriginRectPos.X , OriginRectPos.Y);


    if GetRValue(Couleur_next) < 255 then
    begin
      DispRectPos.X := OriginRectPos.X - Decalage.X*t;
      DispRectPos.Y := OriginRectPos.Y - Decalage.Y*t;
    end;                                               }


  //Assignation de la position du carré
  DispRectPos.X := OriginRectPos.X + Decalage.X*t;
  DispRectPos.Y := OriginRectPos.Y + Decalage.Y*t;
  //Update de l'origine du carré
  OriginRectPos := Point(DispRectPos.X,DispRectPos.Y);

  if Key[DIK_SPACE] then
    SpaceDown := not SpaceDown;
  end;
end;

procedure TMainFrm.RenderCallback(Sender: TAsphyreDevice; Tag: TObject);
const
  RectSize = 40;

var
  i, j : integer ;
  play,pause: TPoint4;
  tab_carre_colonne : array[0..(MAX_HEIGTH div Sensibilite_Vertical)-1] of Tpoint4;
  cl: TColor4;
  cl2 : TColor4;
  AsImage: TAsphyreCustomImage;

begin

  //Affichage du nombre de FPS
  Sender.SysFonts.Font['s/arial'].TextOut('FPS : ' + IntToStr(Timer.FrameRate),
  550, 60, $99009900);

  //Affichage des données des joysticks
  //DrawJoyInfos(Sender);







  begin
  with Sender.Canvas do
  begin
    {Couleur_next := GetRValue(ColorToRGB(DesktopColor(OriginRectPos.X ,
                                                            OriginRectPos.Y)));       }


    //Qualité de l'antialiasing
    Antialias := atBest;
{
    // ****Dessin de l'arrière plan

    //Chargement de l'image
    AsImage := Sender.Images.Image['Background'];
    //Image à utiliser
    UseImage(AsImage, TexFull4);
    //Dessin de l'image
    TexMap(pRect4(Rect(0, 0, ClientWidth, ClientHeight)), clWhite4, fxuBlend);
}
    // ****Affichage du titre
    Sender.Fonts.Font['CustomPolice'].TextOut('DANCE DANCE JP EVOLUTION',
      400, 20, cColor2($FFE4000F));

    // ****Dessin de la ligne de soulignement du titre
    //Largeur des lignes à 2
    LineWidth := 2;
    //Dessin de la ligne avec LineEx pour avoir une épaisseur
    LineEx(400, 50, 900, 50, $FFFE2415);




  with Sender.Canvas do
  begin
    //Spécification des coordonnées du carré
    play := Point4(DispRectPos.X, DispRectPos.Y,
                DispRectPos.X + RectSize, DispRectPos.Y + RectSize div 2,
                DispRectPos.X, DispRectPos.Y + RectSize,
                DispRectPos.X, DispRectPos.Y);

    pause := Point4(DispRectPos.X, DispRectPos.Y,
                DispRectPos.X + RectSize, DispRectPos.Y,
                DispRectPos.X + RectSize, DispRectPos.Y + RectSize,
                DispRectPos.X, DispRectPos.Y + RectSize);

    //Map flashy
    {j := 0 ;
    while j <= MAX_WIDTH do
    begin
      for i:= 0 to (MAX_HEIGTH div Sensibilite_Vertical)-1  do
        begin
          //Spécification des coordonnées du carré
          tab_carre_colonne[i] := Point4( j, i * Sensibilite_Vertical ,
                                          Sensibilite_Horizontal, i * Sensibilite_Vertical ,
                                          Sensibilite_Horizontal,( i + 1 ) * Sensibilite_Vertical ,
                                          j, (i+1) * Sensibilite_Vertical ) ;
          {SpaceDown := not SpaceDown;
            if SpaceDown then
              cl2 := flashy_color_tab[random(5)]
            else
              cl2 := flashy_color_tab[random(5)] ;}
      //Affichage du carré
     { FillQuad(tab_carre_colonne[i], flashy_color_tab[random(5)] ,fxuBlend ) ;
        end;
       j := j + Sensibilite_Horizontal ;
    end; }



//Frontière rouge à gauche
for i:= 0 to (MAX_HEIGTH div Sensibilite_Vertical)-1  do
        begin
          //Spécification des coordonnées du carré
          tab_carre_colonne[i] := Point4( 0, i * Sensibilite_Vertical ,
                                          Sensibilite_Horizontal, i * Sensibilite_Vertical ,
                                          Sensibilite_Horizontal,( i + 1 ) * Sensibilite_Vertical ,
                                          0, (i+1) * Sensibilite_Vertical ) ;
          {SpaceDown := not SpaceDown;
            if SpaceDown then
              cl2 := flashy_color_tab[random(5)]
            else
              cl2 := flashy_color_tab[random(5)] ;}
      //Affichage du carré
      FillQuad(tab_carre_colonne[i], {flashy_color_tab[random(5)]} clRed4 ,fxuBlend ) ;
        end;
//Batiment Opera Sydney
j := 1;
while j <= 7 do
begin
  for i:= 0 to ((MAX_HEIGTH div 8) div Sensibilite_Vertical)-1  do
        begin
          //Spécification des coordonnées du carré
          tab_carre_colonne[i] := Point4( Sensibilite_Horizontal*j, i * Sensibilite_Vertical ,
                                          Sensibilite_Horizontal*(j+1), i * Sensibilite_Vertical ,
                                          Sensibilite_Horizontal*(j+1),( i + 1 ) * Sensibilite_Vertical ,
                                          Sensibilite_Horizontal*j, (i+1) * Sensibilite_Vertical ) ;
          {SpaceDown := not SpaceDown;
            if SpaceDown then
              cl2 := flashy_color_tab[random(5)]
            else
              cl2 := flashy_color_tab[random(5)] ;}
          //Affichage du carré
          FillQuad(tab_carre_colonne[i], {flashy_color_tab[random(5)]} clRed4 ,fxuBlend ) ;
        end;
  j := j+1;
end;


//Frontière à droite
for i:= 0 to (MAX_HEIGTH div Sensibilite_Vertical)-1  do
        begin
          //Spécification des coordonnées du carré
          tab_carre_colonne[i] := Point4( MAX_WIDTH - Sensibilite_Horizontal, (i-1)*Sensibilite_Vertical ,
                                          MAX_WIDTH, (i-1) * Sensibilite_Vertical ,
                                          MAX_WIDTH,( i) * Sensibilite_Vertical ,
                                          MAX_WIDTH - Sensibilite_Horizontal, (i) * Sensibilite_Vertical)  ;
          {SpaceDown := not SpaceDown;
            if SpaceDown then
              cl2 := flashy_color_tab[random(5)]
            else
              cl2 := flashy_color_tab[random(5)] ;}
      //Affichage du carré
      FillQuad(tab_carre_colonne[i], {flashy_color_tab[random(5)]} clRed4 ,fxuBlend ) ;
        end;





    //Spécification de la couleur suivant que l'état appuyé soit vrai ou faux
    if JoyDown or MouseDown then
      cl := clRed4
    else
      cl := clWhite4;

    // ****Dessin du logo DVP

    //Chargement de l'image
    AsImage := Sender.Images.Image['ImageDVP'];
    //Image à utiliser
    UseImage(AsImage, TexFull4);
    //Dessin de l'image avec un dégradé
    TexMap(pBounds4(0, 0, AsImage.Texture[0].Size.X, AsImage.Texture[0].Size.Y),
      cColor4($FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF), fxuMultiBlend);

    //Affichage de l'icone
    if not MouseDown then
    FillQuad(play, clGreen4, fxuBlend)
    else
    FillQuad(pause, clBlack4, fxuBlend);

  end;
end;
end;
end;

procedure TMainFrm.TimerEvent(Sender: TObject);
begin
  //Déclenchement du rendu sur fond jaune
  DefDevice.Render(RenderCallback, self, $FFFFDF00);
  //Déclenchement de Process
  Timer.Process;
end;

end.
