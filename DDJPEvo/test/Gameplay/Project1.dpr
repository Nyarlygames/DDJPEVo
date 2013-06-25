program Project1;

uses
  Forms,
  TForme in 'TForme.pas' {Form1},
  TFleches in 'TFleches.pas',
  TArrowUp in 'TArrowUp.pas',
  TArrowDown in 'TArrowDown.pas',
  TArrowLeft in 'TArrowLeft.pas',
  TArrowRight in 'TArrowRight.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
