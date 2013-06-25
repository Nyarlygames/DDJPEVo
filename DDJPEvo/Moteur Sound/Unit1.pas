unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, fmod, fmodtypes, ComCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Edit1: TEdit;
    Button3: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  Form1: TForm1;
  starcraft : PFSOUNDSTREAM ;

implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
begin
  if FSOUND_GetPaused(1) then
    FSOUND_SetPaused(FSOUND_ALL,false )
  else
    FSOUND_SetPaused(FSOUND_ALL, true ) ;
end;


procedure TForm1.Button2Click(Sender: TObject);
begin
  FSOUND_Close();
  Close ;
end;


procedure TForm1.Button3Click(Sender: TObject);
begin
FSOUND_SetVolume(FSOUND_ALL, StrToInt(Edit1.Text));
end;

end.
