(*
  Unité       : UTimer.pas
  Date        : 28/10/2002
  Auteur      : Sébastien TIMONER (sebastien@timoner.com)
  Description : Timer utilisant l'api SetWaitableTimer, permettant d'avoir
                un timer beaucoup plus fiable que le TTimer de delphi

*)
unit UTimer;

interface

uses
  SysUtils,
  Windows,
  Classes,
  SyncObjs;

type
  TWaitableTime = class(TForm)
  private
    FStartEvent: TEvent;
    FStopEvent: TEvent;
    FKillEvent: TEvent;
    FIntervalle: integer;
    FTimer:THandle;
    FOnTimer: TNotifyEvent;
    FTickCount: integer;
    FTickLock: TCriticalSection;
    FStartTick:Cardinal;
    FCounterTick:integer;
    FNow:boolean;
    procedure SetIntervalle(const Value: integer); // millisecondes
    procedure DoOnTimer;
    function GetTickCount: integer;
    procedure SetTickCount(const Value: integer);
    procedure IncTickCount;
  protected
    procedure Execute; override;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Start(const ANow:boolean=True);
    procedure Stop;
    procedure Kill;
    property Intervalle: integer read FIntervalle write SetIntervalle;
    property OnTimer: TNotifyEvent read FOnTimer write FOnTimer;
    property TickCount: integer read GetTickCount write SetTickCount;
  end;

implementation

{ TWaitableTime }

constructor TWaitableTime.Create;
begin
  inherited create(True);
  FStartEvent:=TEvent.Create(nil,false,false,'');
  FStopEvent:=TEvent.Create(nil,false,false,'');
  FKillEvent:=TEvent.Create(nil,false,false,'');
  FTimer:=CreateWaitableTimer(nil,false,nil);
  FTickLock:=TCriticalSection.Create;
  Resume;
end;

destructor TWaitableTime.Destroy;
begin
  FTickLock.Free;
  FStartEvent.Free;
  FStopEvent.Free;
  FKillEvent.Free;
  CloseHandle(FTimer);
  inherited;
end;

procedure TWaitableTime.DoOnTimer;
begin
  if assigned(FOnTimer) then FOnTimer(self);
end;

procedure TWaitableTime.Execute;
var
  _Event:Array [0..3] of THandle;
  _starttime:int64;
begin
  _Event[0]:=FStartEvent.Handle;
  _Event[1]:=FStopEvent.Handle;
  _Event[2]:=FTimer;
  _Event[3]:=FKillEvent.Handle;
  while not Terminated do
    begin
      case WaitForMultipleObjects(4,@_Event,False,INFINITE) of
        WAIT_OBJECT_0:
          begin
            TickCount:=0;
            FStartTick:=windows.GetTickCount;
            FCounterTick:=0;
            if FNow then _StartTime:=-10000
            else _starttime:=-(FIntervalle * 10000);
            SetWaitableTimer(FTimer,_starttime,FIntervalle,nil,nil,True);
          end;
        WAIT_OBJECT_0+1:
          begin
            CancelWaitableTimer(FTimer);
          end;
        WAIT_OBJECT_0+2:
          begin
            IncTickCount;
            DoOnTimer;
          end;
        WAIT_OBJECT_0+3:
          begin
            CancelWaitableTimer(FTimer);
            Terminate;
          end;
      end;
    end;
end;

function TWaitableTime.GetTickCount: integer;
begin
  FTickLock.Acquire;
  try
    Result := FTickCount;
  finally
    FTickLock.Release;
  end;
end;

procedure TWaitableTime.IncTickCount;
var
  _cardinal:Cardinal;
begin
  FTickLock.Acquire;
  try
    inc(FTickCount);
    inc(FCounterTick);
    if ((FCounterTick mod 5)=0) then
      begin
        _cardinal:=Windows.GetTickCount;
        if _cardinal>FStartTick then
          _cardinal:=(abs(_cardinal-FStartTick)) div Intervalle
        else
          _cardinal:=abs((high(cardinal)-FStartTick+_cardinal)) div Intervalle;
        if _cardinal<=2147483647 then
          FTickCount:=integer(_cardinal)
        else
          FTickCount:=high(integer);
      end;
  finally
    FTickLock.Release;
  end;
end;

procedure TWaitableTime.Kill;
begin
  FKillEvent.SetEvent;
end;

procedure TWaitableTime.SetIntervalle(const Value: integer);
begin
  FIntervalle:=Value;
end;

procedure TWaitableTime.SetTickCount(const Value: integer);
begin
  FTickLock.Acquire;
  try
    FTickCount := Value;
  finally
    FTickLock.Release;
  end;
end;

procedure TWaitableTime.Start(const ANow:boolean);
begin
  FNow:=ANow;
  FStartEvent.SetEvent;
end;

procedure TWaitableTime.Stop;
begin
  FStopEvent.SetEvent;
end;

end.


