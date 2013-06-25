unit builder;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, fmod, fmodtypes, StdCtrls,ExtCtrls, ComCtrls,test, Menus,
  ToolWin;

type

  t_flec = record
        fleche : string;
        temps : string;
  end;

  t_add = array [0..MAX_FLECHES] of t_flec;


  TMainFrm = class(TForm)
    Elements: TListBox;
    Supprimer: TButton;
    Ajouter: TButton;
    Temps: TEdit;
    Fleches: TComboBox;
    Play: TButton;
    OpenDialog: TOpenDialog;
    Progress: TTrackBar;
    Timer: TTimer;
    Label1: TLabel;
    MainMenu1: TMainMenu;
    Fichierjp1: TMenuItem;
    Ouvrir1: TMenuItem;
    Sauvegarder1: TMenuItem;
    SaveDialog1: TSaveDialog;
    OpenDialog1: TOpenDialog;
    Nouveau: TMenuItem;
    Enregistrer1: TMenuItem;
    Son: TTrackBar;
    Au1: TMenuItem;
    FermerMusique1: TMenuItem;
    ChercherMusique1: TMenuItem;
    Time: TEdit;
    Track: TEdit;
    GetTo: TButton;
    procedure FormCreate(Sender: TObject);
    procedure AjouterClick(Sender: TObject);
    procedure SupprimerClick(Sender: TObject);
    procedure ElementsClick(Sender: TObject);
    procedure PlayClick(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure Ouvrir1Click(Sender: TObject);
    procedure Sauvegarder1Click(Sender: TObject);
    procedure NouveauClick(Sender: TObject);
    procedure Enregistrer1Click(Sender: TObject);
    procedure SonChange(Sender: TObject);
    procedure ChercherMusique1Click(Sender: TObject);
    procedure GetToClick(Sender: TObject);

  private
    { Déclarations privées }
  public

  end;

var
  liste : t_add;
  num : integer;
  MainFrm: TMainFrm;
  mus : string;
  F,Temp : TextFile;
  i, len, j, strlen : integer;
  Open : TextFile;
  OpenDialog : TOpenDialog ;
  music : PFSOUNDSTREAM ;
  compteur : integer ;
  str,min,sec,ms : string ;

//-------------------------------------------------------------------------------
implementation
//-------------------------------------------------------------------------------

{$R *.dfm}

//---------------------------------Form Create-----------------------------------

procedure TMainFrm.FormCreate( Sender : TObject ) ;
  begin
    num := -1;
    mus := '\maps\Default.mp3';
    SaveDialog1.FileName := 'SansTitre.jp';
    Progress.Min := 0 ;
    Son.Min := 0 ;
    Son.Max := 255 ;
    Son.Position := 255 ;
    Timer.Enabled := false ;
    Fleches.Items.Add('Gauche');
    Fleches.Items.Add('Haut');
    Fleches.Items.Add('Bas');
    Fleches.Items.Add('Droite');
  end;

procedure TMainFrm.NouveauClick(Sender: TObject);
begin
num :=-1;
Elements.Clear;
SaveDialog1.FileName := 'SansTitre.jp';
ChercherMusique1Click(MainFrm);
end;

procedure TMainFrm.Ouvrir1Click(Sender: TObject);
var
i,nombre : integer;
Line,NewTemp : string;
begin
OpenDialog1.InitialDir := GetCurrentDir + '\maps\';
OpenDialog1.Title := 'Ouvrir une piste';
OpenDialog1.Filter:='.jp files only|*.jp';
OpenDialog1.DefaultExt := 'txt';
if OpenDialog1.Execute then
begin
num := -1;
Elements.clear;
AssignFile(Open,OpenDialog1.FileName);
Reset(Open); 
Readln(Open,Line);
OpenDialog.FileName := Line;
music := FSOUND_Stream_Open(PAnsiChar(Opendialog.Filename),FSOUND_LOOP_NORMAL,0,0) ;
Progress.max := FSOUND_Stream_GetLengthMs ( music ) ;
FSOUND_Stream_SetLoopCount(music, 1) ;
FSOUND_Stream_play( FSOUND_FREE, music ) ;
FSOUND_SetPaused(FSOUND_ALL, true ) ;
Time.Text := (inttostr( ( FSOUND_STREAM_GetTime (music ) )div 60000 ) +
     ':' + (inttostr((( FSOUND_STREAM_GetTime (music )) mod 60000)div 1000)) +
     ':' + inttostr(( (FSOUND_STREAM_GetTime (music ))div 100)mod 10 ))+'/'+(inttostr( (FSOUND_Stream_GetLengthMs(music) )div 60000 ) +
     ':' + (inttostr(((FSOUND_Stream_GetLengthMs(music)) mod 60000)div 10)) +
     ':' + inttostr((( FSOUND_Stream_GetLengthMs(music))div 100)mod 10 ));
Readln(Open,Line);
while not (Eof(Open)) do
 begin if (Line <> '') and (num+1 <=MAX_FLECHES) then
        begin liste[num+1].fleche := Line;
              Readln(Open,Line);
              liste[num+1].temps := Line;
              Readln(Open,Line);
              num := num+1;
        end
       else Readln(Open,Line);
 end;
nombre := num;
for i := 0  to nombre do
begin if liste[i].temps = '0' then
      liste[i].temps := '00';
      NewTemp := liste[i].temps;
      NewTemp := NewTemp + NewTemp[Length(NewTemp)];
      NewTemp[Length(NewTemp)-1] := ',';
      Elements.Items.Add('Flèche '+liste[num].fleche+' à '+NewTemp+' sc');
end;
SaveDialog1.FileName := OpenDialog1.FileName;
CloseFile(Open);
end;
end;

//-------------------------------Elements----------------------------------------

procedure TMainFrm.ElementsClick(Sender: TObject);
begin
i := Elements.ItemIndex;
end;

//---------------------------------Enregistrer-----------------------------------

procedure TMainFrm.Enregistrer1Click(Sender: TObject);
var
nombr,i,t : integer;
buttonSelected : integer;
begin
nombr := num;
if (SaveDialog1.Filename = 'SansTitre.jp') then
 begin t := 1;
       while FileExists(GetCurrentDir+'\maps\'+'Piste'+inttostr(t)+'.mp3') = true do
       t:=t+1;
       CopyFile(pchar(OpenDialog.Filename),pchar(GetCurrentDir+'\maps\'+'Piste'+inttostr(t)+'.mp3'),False);
       mus := '\maps\Piste'+inttostr(t)+'.mp3';
       buttonSelected := MessageDlg('Enregistrer dans SansTitre.jp ?',mtConfirmation, mbOKCancel, 0);
       if buttonSelected = mrOK then
        begin AssignFile(F,SaveDialog1.FileName);
              Rewrite(F);
              Append(F);
              Writeln(F,mus);
              Writeln(F,'');
              for i := 0 to nombr do
               begin Writeln(F,liste[i].fleche);
                     Writeln(F,liste[i].temps);
                     Writeln(F,'');
               end;
              CloseFile(F);
        end;
       if buttonSelected = mrCancel then
        begin Sauvegarder1.Click;
        end;
 end
else begin AssignFile(F,SaveDialog1.FileName);
           Rewrite(F);
           Append(F);
           Writeln(F,mus);
           Writeln(F,'');
           for i := 0 to nombr do
            begin Writeln(F,liste[i].fleche);
                  Writeln(F,liste[i].temps);
                  Writeln(F,'');
            end;
           CloseFile(F);
     end;
end;

//-------------------------------Play / Pause------------------------------------

procedure TMainFrm.PlayClick(Sender: TObject);
  begin
    if FSOUND_GetPaused(1) then
      begin
        FSOUND_SetPaused(FSOUND_ALL,false ) ;
        Timer.Enabled := True ;
      end
    else
      begin
        FSOUND_SetPaused(FSOUND_ALL, true ) ;
        Timer.Enabled := False
      end;
  end;


//-------------------------Ouverture OpenDialog----------------------------------

procedure TMainFrm.Sauvegarder1Click(Sender: TObject);
var
i : integer;
t : integer;
nombr : integer;
buttonSelected : integer;
  begin
  SaveDialog1.InitialDir := GetCurrentDir + '\maps\';
  SaveDialog1.Title := 'Sauveguardez une piste';
  SaveDialog1.Filter:='.jp files only|*.jp';
  SaveDialog1.DefaultExt := 'jp';
  if SaveDialog1.Execute then
  begin t:=1;
        while FileExists(GetCurrentDir+'\maps\'+'Piste'+inttostr(t)+'.mp3') = true do
        t:=t+1;
        CopyFile(pchar(OpenDialog.Filename),pchar(GetCurrentDir+'\maps\'+'Piste'+inttostr(t)+'.mp3'),False);
        mus := '\maps\Piste'+inttostr(t)+'.mp3';
        if (FileExists(SaveDialog1.FileName)) then
          begin  buttonSelected := MessageDlg('Le fichier existe déja, voulez-vous continuer ?',mtConfirmation, mbOKCancel, 0);
                 if buttonSelected = mrOK then
                  begin nombr := num;
                        AssignFile(F,SaveDialog1.FileName);
                        Rewrite(F);
                        Append(F);
                        Writeln(F,mus);
                        Writeln(F,'');
                        for i := 0 to nombr do
                         begin Writeln(F,liste[i].fleche);
                               Writeln(F,liste[i].temps);
                               Writeln(F,'');
                         end;
                        CloseFile(F);
                  end;
          end
         else begin AssignFile(F,SaveDialog1.FileName);
                    Rewrite(F);
                    Writeln(F,mus);
                    Writeln(F,'');
                    nombr := num;
                    for i := 0 to nombr do
                     begin Writeln(F,liste[i].fleche);
                           Writeln(F,liste[i].temps);
                           Writeln(F,'');
                     end;
                    CloseFile(F);
              end;
  end;
end;

//-------------------------------Ouvrir Musique----------------------------------

procedure TMainFrm.ChercherMusique1Click(Sender: TObject);
  begin
    OpenDialog.Execute ;
    music := FSOUND_Stream_Open(PAnsiChar(Opendialog.Filename),FSOUND_LOOP_NORMAL,0,0) ;
    Progress.max := FSOUND_Stream_GetLengthMs ( music ) ;
    FSOUND_Stream_SetLoopCount(music, 1) ;
    FSOUND_Stream_play( FSOUND_FREE, music ) ;
    FSOUND_SetPaused(FSOUND_ALL, true ) ;
end;


//------------------------------Gestion TrackBar---------------------------------

procedure TMainFrm.TimerTimer(Sender: TObject);
  begin
    Progress.Position := FSOUND_Stream_GetTime( music ) ;
    Time.Text := (inttostr( ( FSOUND_STREAM_GetTime (music ) )div 60000 ) +
     ':' + (inttostr((( FSOUND_STREAM_GetTime (music )) mod 60000)div 1000)) +
     ':' + inttostr(( (FSOUND_STREAM_GetTime (music ))div 100)mod 10 ))+'/'+(inttostr( (FSOUND_Stream_GetLengthMs(music) )div 60000 ) +
     ':' + inttostr(((FSOUND_Stream_GetLengthMs(music)) mod 60000)div 10) +
     ':' + inttostr((( FSOUND_Stream_GetLengthMs(music))div 100)mod 10 ));
  end;

//------------------------------Track ------------------------------------

procedure TMainFrm.GetToClick(Sender: TObject);
  begin
    str := Track.Text ;
    StrLen := Length(Str) ;
    min := str[1] + str[2] ;
    sec := str[4] + str[5] ;
    ms := str[7] ;
    len := strtoint(min) * 60000 + strtoint(sec) * 1000 + strtoint(ms) * 100 ;
    FSOUND_Stream_SetTime ( music , len ) ;
  end;

//-------------------------------Changer Son-------------------------------------

procedure TMainFrm.SonChange(Sender: TObject);
  begin
     FSOUND_SetVolume(FSOUND_ALL, Son.Position);
  end;

//------------------------------Ajouter Fleche-----------------------------------

procedure TMainFrm.AjouterClick(Sender: TObject);
var
Newtemp : string;
long : integer;
  begin
  if num <= MAX_FLECHES then
  begin
  Newtemp := '';
  for long :=1 to Length(Temps.Text) do
  if (Temps.Text[long]<>',') and (long <= Length(Temps.Text)) then
   Newtemp := Newtemp + Temps.Text[long];
  if Length(Newtemp) <> (Length(Temps.text)-1) then
   begin Newtemp := Newtemp + '0';
   end;
  num := num+1;
  i:=num;
  liste[i].fleche := Fleches.Text;
  liste[i].temps := IntToStr(StrToInt(Newtemp));
  if Length(Newtemp) = (Length(Temps.text)) then
   begin Newtemp := Newtemp + '0';
         Newtemp[Length(Newtemp)-1] := ',';
   end
  else begin Newtemp := Newtemp + Newtemp[Length(Newtemp)];
             Newtemp[Length(Newtemp)-1]:=',';
       end;
  Elements.Items.Add('Flèche '+Fleches.Text+' à '+NewTemp+' sc');
  Temps.Text := Newtemp;
  end
  else ShowMessage('Nombre maximum de flèche atteint');
  end;

//--------------------------Supprimer Fleche-------------------------------------

procedure TMainFrm.SupprimerClick(Sender: TObject);
  var
    i : integer;
  begin
  for i := Elements.ItemIndex to num-1 do
  liste[Elements.ItemIndex] := liste[Elements.ItemIndex +1];
  num := num-1;
  Elements.DeleteSelected;
  end;


end.
