unit TimerFrm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,ActnList, ExtCtrls,UTimer;

type
  TFrmTimer = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Edit1: TEdit;
    EditInterval: TEdit;
    Label1: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Déclarations privées }
    procedure OnTimer(Sender:TObject);
  public
    { Déclarations publiques }
    FTimer:TWaitableTime;
    constructor create(AOwner:TComponent);override;
    destructor Destroy;override;

  end;

var
  FrmTimer: TFrmTimer;

implementation

{$R *.dfm}

procedure TFrmTimer.Button1Click(Sender: TObject);
begin
  FTimer.Intervalle:=strToInt(EditInterval.Text);
  //qd on met false il se déclenche après l'intervalle. Pour tester, mettr un très gd intervalle
  FTimer.Start(False);
end;

procedure TFrmTimer.Button3Click(Sender: TObject);
begin
  FTimer.Intervalle:=strToInt(EditInterval.Text);
  FTimer.Start(True);
end;

procedure TFrmTimer.Button2Click(Sender: TObject);
begin
   FTimer.Stop;
end;

constructor TFrmTimer.create(AOwner: TComponent);
begin
  inherited;
  FTimer:=TWaitableTime.Create;
  FTimer.OnTimer:=OnTimer;
end;

destructor TFrmTimer.Destroy;
begin
  FTimer.Kill;
  FTimer.WaitFor;
  FTimer.Free;
  inherited;
end;

procedure TFrmTimer.OnTimer(Sender: TObject);
begin
  Edit1.Text:=IntTostr(FTimer.TickCount);
end;

end.


