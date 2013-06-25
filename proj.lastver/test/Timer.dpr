program Timer;

uses
  Forms,
  TimerFrm in 'TimerFrm.pas' {FrmTimer},
  UTimer in 'UTimer.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFrmTimer, FrmTimer);
  Application.Run;
end.
