program editeur;

uses
  Forms,
  builder in 'builder.pas' {Build};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TBuild, Build);
  Application.Run;
end.
