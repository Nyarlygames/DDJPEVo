program AsphyreIO;

uses
  Forms,
  AsphyreIO1 in 'AsphyreIO1.pas' {MainFrm},
  MoteurSon in 'MoteurSon.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainFrm, MainFrm);
  Application.Run;
end.
