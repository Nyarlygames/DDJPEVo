unit builder;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,ExtCtrls;

type
  TBuild = class(TForm)
    Elements: TListBox;
    Supprimer: TButton;
    Ajouter: TButton;
    Temps: TEdit;
    Fleches: TComboBox;
    Nom: TEdit;
    Save: TButton;
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure AjouterClick(Sender: TObject);
    procedure SupprimerClick(Sender: TObject);
    procedure SaveClick(Sender: TObject);
    procedure ElementsClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  Build: TBuild;
  F : TextFile;
  i : integer;

implementation

{$R *.dfm}

procedure TBuild.ElementsClick(Sender: TObject);
begin
i := Elements.ItemIndex;
end;

procedure TBuild.FormCreate(Sender: TObject);
begin
  Timer1.Create(Build);
  AssignFile(F,Nom.Text+'.jp');
  Rewrite(F);
  Fleches.Items.Add('Gauche');
  Fleches.Items.Add('Haut');
  Fleches.Items.Add('Bas');
  Fleches.Items.Add('Droite');
  CloseFile(F);
end;

procedure TBuild.SaveClick(Sender: TObject);
begin
Rename(F,Nom.Text+'.jp');
end;

procedure TBuild.SupprimerClick(Sender: TObject);
var
Line : String;
begin
Reset(F);
Readln(F,Line);
while (Line <> Elements.Items.Strings[i]) and (not (Eof(F))) do
 begin Readln(F,Line);
 end;
Line := '';
Writeln(F,Line);
Elements.DeleteSelected;
CloseFile(F);
end;

procedure TBuild.Timer1Timer(Sender: TObject);
begin
Temps.Text:=IntToStr(Timer1.InstanceSize);
end;

procedure TBuild.AjouterClick(Sender: TObject);
var
Line : string;
begin
Line := ('Flèche ' + Fleches.Text + ' à ' + Temps.Text + ' ms');
Elements.Items.Add(Line);
Append(F);
Writeln(F,Line);
Writeln(F,Fleches.Text);
Writeln(F,Temps.Text);
Writeln(F,'');
CloseFile(F);
end;

end.
