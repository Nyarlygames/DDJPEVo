unit Serveur;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ScktComp,ComCtrls, Spin, ExtCtrls;

type
  TForm1 = class(TForm)
    Connect: TButton;
    Deconnect: TButton;
    Port: TEdit;
    Serveur: TServerSocket;
    Host: TLabel;
    Envoie: TButton;
    Affichage: TRichEdit;
    Ecriture: TEdit;
    procedure ConnectClick(Sender: TObject);
    procedure EnvoieClick(Sender: TObject);
    procedure DeconnectClick(Sender: TObject);
    procedure ServeurClientRead(Sender: TObject; Socket: TCustomWinSocket);
    procedure ServeurClientConnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure ServeurClientDisconnect(Sender: TObject;
      Socket: TCustomWinSocket);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.ConnectClick(Sender: TObject);
begin
Serveur.Port:=StrtoInt(Port.Text);
Serveur.Open;
Host.Caption := 'Serveur : '+Serveur.Socket.LocalHost;
Affichage.Lines.Clear;
Affichage.Lines.Add('Serveur connecté.');
end; 

procedure TForm1.DeconnectClick(Sender: TObject);
begin
Serveur.Close;
Affichage.Lines.Add('Serveur déconnecté.');
Host.Caption := 'Host';
end;

procedure TForm1.EnvoieClick(Sender: TObject);
var i:integer;
begin
  for i:=0 to Serveur.Socket.ActiveConnections-1 do
begin
    Serveur.Socket.Connections[i].SendText(Ecriture.Text);
    Affichage.Lines.Add(Serveur.Socket.Localhost+'>'+Ecriture.Text);
end;
end;

procedure TForm1.ServeurClientConnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
  Affichage.Lines.Add('Un client vient de se connecter au serveur.');
end;

procedure TForm1.ServeurClientDisconnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
  Affichage.Lines.Add('Le client vient de partir.');
end;

procedure TForm1.ServeurClientRead(Sender: TObject; Socket: TCustomWinSocket);
begin
  Affichage.Lines.Add(Socket.RemoteHost+'> '+Socket.ReceiveText);
end;

end.
