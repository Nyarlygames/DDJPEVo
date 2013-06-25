unit Client;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ScktComp, ComCtrls, ExtCtrls;

type
  TForm1 = class(TForm)
    Connect: TButton;
    Deconnect: TButton;
    Port: TEdit;
    Envoie: TButton;
    Host: TEdit;
    ClientChat: TClientSocket;
    Ecriture: TEdit;
    Affichage: TRichEdit;
    procedure ConnectClick(Sender: TObject);
    procedure EnvoieClick(Sender: TObject);
    procedure DeconnectClick(Sender: TObject);
    procedure ClientChatRead(Sender: TObject; Socket: TCustomWinSocket);
    procedure ClientChatConnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure ClientChatDisconnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure ClientChatError(Sender: TObject; Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: Integer);
    procedure ClientChatConnecting(Sender: TObject; Socket: TCustomWinSocket);
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
ClientChat.Port:=StrtoInt(Port.Text);
ClientChat.Host:=Host.Text;
ClientChat.Open;
Affichage.Lines.Clear;
end;

procedure TForm1.DeconnectClick(Sender: TObject);
begin
ClientChat.Close;
end;

procedure TForm1.EnvoieClick(Sender: TObject);
begin
  ClientChat.Socket.SendText(Ecriture.Text);
  Affichage.Lines.Add(ClientChat.Socket.LocalHost+'> '+Ecriture.Text);
end;

procedure TForm1.ClientChatRead(Sender: TObject; Socket: TCustomWinSocket);
begin
  Affichage.Lines.Add(Socket.Remotehost+'> '+Socket.ReceiveText);
end;

procedure TForm1.ClientChatConnecting(Sender: TObject;
  Socket: TCustomWinSocket);
begin
Affichage.Lines.Add('Connection a ' + Host.Text+'.');
end;

procedure TForm1.ClientChatDisconnect(Sender: TObject; Socket: TCustomWinSocket);
begin
   Affichage.Lines.Add('Déconnecté.');
end;

procedure TForm1.ClientChatConnect(Sender: TObject; Socket: TCustomWinSocket);
begin
  Affichage.Lines.Add('Connecté à : '+Socket.Remotehost+'.');
end;

procedure TForm1.ClientChatError(Sender: TObject; Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: Integer);
begin
  if ErrorEvent=eeConnect
  then begin ShowMessage('Impossible de se connecter à  '+Host.Text+'.');
             ErrorCode:=0;
       end;
end;

end.
