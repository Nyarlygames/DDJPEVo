program testtypes;

uses
  Forms,
  test in 'test.pas' {TYpes};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TTYpes, TYpes);
  Application.Run;
end.
