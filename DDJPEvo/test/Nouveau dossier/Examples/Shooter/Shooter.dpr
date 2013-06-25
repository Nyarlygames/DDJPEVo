//-------------------------------------------------------------------------------
//    huaosft(http://www.huosoft.com)               Modified:27-Jan-2007
//------------------------------------------------------------------------------
program Shooter;

uses
  Forms,
  MainFm in 'MainFm.pas' {MainForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
