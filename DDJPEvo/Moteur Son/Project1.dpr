program Project1;

uses
  Forms,
  Unit1 in 'Unit1.pas' {Form1},
  fmod in 'fmod.pas',
  fmodtypes in 'fmodtypes.pas',
  MoteurSon in 'MoteurSon.pas',
  fmoddyn in 'fmoddyn.pas',
  fmodpresets in 'fmodpresets.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
