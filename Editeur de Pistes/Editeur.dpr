program editeur;

uses
  Forms,
  Builder in 'Builder.pas' {MainFrm},
  MoteurSound in 'MoteurSound.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainFrm, MainFrm);
  Application.Run;
end.
