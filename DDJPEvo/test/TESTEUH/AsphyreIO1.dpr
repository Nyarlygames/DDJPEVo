program AsphyreIO;

uses
  Forms,
  AsphyreIO1 in 'AsphyreIO1.pas' {MainFrm};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainFrm, MainFrm);
  Application.Run;
end.
