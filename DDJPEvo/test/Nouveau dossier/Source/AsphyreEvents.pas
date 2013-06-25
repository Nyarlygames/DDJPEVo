unit AsphyreEvents;
//---------------------------------------------------------------------------
// AsphyreEvents.pas                                    Modified: 12-Jul-2006
// Event casting system for Asphyre components                    Version 1.0
//---------------------------------------------------------------------------
// The contents of this file are subject to the Mozilla Public License
// Version 1.1 (the "License"); you may not use this file except in
// compliance with the License. You may obtain a copy of the License at
// http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS"
// basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
// License for the specific language governing rights and limitations
// under the License.
//---------------------------------------------------------------------------
interface

//---------------------------------------------------------------------------
type
 TEventCallback = procedure(Sender: TObject; EventNo,
  EventRef: Integer; var Success: Boolean) of object;

//---------------------------------------------------------------------------
const
 aevInitialize     = $01; // device initialization
 aevFinalize       = $02; // device finalization
 aevRender         = $03; // rendering phase

 aevDeviceLost     = $04; // device has been lost
 aevDeviceRecover  = $05; // device has been recovered

 aevBeginScene     = $06; // scene rendering has started
 aevEndScene       = $07; // scene rendering has finished

 aevMonoCanvasIni  = $08; // initialization of asphyre canvas
 aevMultiCanvasIni = $09; // initialization of asphyre multi canvas
 aevDrawFlush      = $0A; // flush request

//---------------------------------------------------------------------------
type
 TEventCallbacks = class
 private
  Data: array of TEventCallback;

  function GetCount(): Integer;
  function GetCallback(Num: Integer): TEventCallback;
  procedure RemoveNum(Num: Integer);
 public
  property Count: Integer read GetCount;
  property Callback[Num: Integer]: TEventCallback read GetCallback; default;

  function FindByRef(Callback: TEventCallback): Integer;
  function Include(Callback: TEventCallback): Integer;
  procedure Exclude(Callback: TEventCallback);
  function Notify(Sender: TObject; EventNo, EventRef: Integer): Boolean;
 end;

//---------------------------------------------------------------------------
var
 Events: TEventCallbacks = nil;

//---------------------------------------------------------------------------
implementation

//---------------------------------------------------------------------------
function TEventCallbacks.GetCount(): Integer;
begin
 Result:= Length(Data);
end;

//---------------------------------------------------------------------------
function TEventCallbacks.GetCallback(Num: Integer): TEventCallback;
begin
 if (Num >= 0)and(Num < Length(Data)) then Result:= Data[Num]
  else Result:= nil;
end;

//---------------------------------------------------------------------------
function TEventCallbacks.FindByRef(Callback: TEventCallback): Integer;
var
 i: Integer;
begin
 Result:= -1;
 for i:= 0 to Length(Data) - 1 do
  if (@Data[i] = @Callback) then
   begin
    Result:= i;
    Break;
   end;
end;

//---------------------------------------------------------------------------
function TEventCallbacks.Include(Callback: TEventCallback): Integer;
var
 Index: Integer;
begin
 Index:= FindByRef(Callback);
 if (Index <> -1) then
  begin
   Result:= Index;
   Exit;
  end;

 Index:= Length(Data);
 SetLength(Data, Length(Data) + 1);

 Data[Index]:= Callback;
 Result:= Index;
end;

//---------------------------------------------------------------------------
procedure TEventCallbacks.RemoveNum(Num: Integer);
var
 i: Integer;
begin
 if (Num < 0)or(Num >= Length(Data)) then Exit;

 for i:= Num to Length(Data) - 2 do
  Data[i]:= Data[i + 1];

 SetLength(Data, Length(Data) - 1);
end;

//---------------------------------------------------------------------------
procedure TEventCallbacks.Exclude(Callback: TEventCallback);
begin
 RemoveNum(FindByRef(Callback));
end;

//---------------------------------------------------------------------------
function TEventCallbacks.Notify(Sender: TObject; EventNo,
 EventRef: Integer): Boolean;
var
 i: Integer;
begin
 Result:= True;

 for i:= 0 to Length(Data) - 1 do
  begin
   Data[i](Sender, EventNo, EventRef, Result);
   if (not Result) then Break;
  end;
end;

//---------------------------------------------------------------------------
initialization
 Events:= TEventCallbacks.Create();

//---------------------------------------------------------------------------
finalization
 Events.Free();
 Events:= nil;

//---------------------------------------------------------------------------
end.
