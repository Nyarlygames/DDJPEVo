unit AsphyreMeshes;
//---------------------------------------------------------------------------
// AsphyreMeshes.pas                                    Modified: 29-Jan-2007
// High-level structure for 3D meshes                             Version 1.0
//---------------------------------------------------------------------------
// Important Notice:
//
// If you modify/use this code or one of its parts either in original or
// modified form, you must comply with Mozilla Public License v1.1,
// specifically section 3, "Distribution Obligations". Failure to do so will
// result in the license breach, which will be resolved in the court.
// Remember that violating author's rights is considered a serious crime in
// many countries. Thank you!
//
// !! Please *read* Mozilla Public License 1.1 document located at:
//  http://www.mozilla.org/MPL/
//
// If you require any clarifications about the license, feel free to contact
// us or post your question on our forums at: http://www.afterwarp.net
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
//
// The Original Code is AsphyreMeshes.pas.
//
// The Initial Developer of the Original Code is M. Sc. Yuriy Kotsarenko.
// Portions created by M. Sc. Yuriy Kotsarenko are Copyright (C) 2007,
// Afterwarp Interactive. All Rights Reserved.
//---------------------------------------------------------------------------
interface

//--------------------------------------------------------------------------
uses
 AsphyreAsserts;

//--------------------------------------------------------------------------
type
 TAsphyreMeshes = class;
 
//--------------------------------------------------------------------------
 TAsphyreCustomMesh = class
 private
  FOwner: TAsphyreMeshes;
  FMeshIndex: Integer;

  // NoExclude indicates that the component should not exclude itself
  // from the owner.
  NoExclude: Boolean;
 protected
  FName: string;
  FInitialized: Boolean;

  FVolatile: Boolean;
 public
  // The reference to the mesh container.
  property Owner: TAsphyreMeshes read FOwner;

  // The unique mesh identifier.
  property Name: string read FName;

  // Determines whether the mesh should be destroyed when the device
  // is lost.
  property Volatile: Boolean read FVolatile;

  // The index assigned by the owner.
  property MeshIndex: Integer read FMeshIndex;

  // Determines whether the mesh has been initialized successfully.
  property Initialized: Boolean read FInitialized;

  procedure Finalize(); virtual; abstract;
  procedure Draw(); virtual; abstract;

  constructor Create(AOwner: TAsphyreMeshes); virtual;
  destructor Destroy(); override;
 end;

//--------------------------------------------------------------------------
 TAsphyreMeshes = class
 private
  FScene: TObject;
  Meshes: array of TAsphyreCustomMesh;

  SearchObjects: array of Integer;
  SearchDirty  : Boolean;

  function GetCount(): Integer;
  function GetMesh(Num: Integer): TAsphyreCustomMesh;
  function CountSearchObjects(): Integer;
  procedure FillSearchObjects(Amount: Integer);
  procedure SortSearchObjects(Left, Right: Integer);
  procedure PrepareSearchObjects();
 protected
  function FindEmptySlot(): Integer;
  function Insert(Mesh: TAsphyreCustomMesh): Integer;
  procedure Exclude(Mesh: TAsphyreCustomMesh);
  function Include(Mesh: TAsphyreCustomMesh): Integer;
 public
  property Scene: TObject read FScene;

  property Count: Integer read GetCount;
  property Mesh[Num: Integer]: TAsphyreCustomMesh read GetMesh; default;

  function IndexOf(Mesh: TAsphyreCustomMesh): Integer; overload;
  function IndexOf(const uid: string): Integer; overload;
  procedure RemoveAll();
  procedure Remove(Num: Integer);

  constructor Create(AScene: TObject);
  destructor Destroy(); override;
 end;

//--------------------------------------------------------------------------
implementation

//--------------------------------------------------------------------------
uses
 AsphyreScene;

//--------------------------------------------------------------------------
constructor TAsphyreCustomMesh.Create(AOwner: TAsphyreMeshes);
begin
 inherited Create();

 FMeshIndex:= -1;
 Assert(AOwner <> nil, msgInvalidOwner);

 FOwner:= AOwner;
 FInitialized:= False;
 NoExclude:= False;

 FOwner.Insert(Self);
end;

//--------------------------------------------------------------------------
destructor TAsphyreCustomMesh.Destroy();
begin
 if (FInitialized) then Finalize();
 if (not NoExclude) then FOwner.Exclude(Self);

 inherited;
end;

//--------------------------------------------------------------------------
constructor TAsphyreMeshes.Create(AScene: TObject);
begin
 inherited Create();

 FScene:= AScene;
 Assert((FScene <> nil)and(FScene is TAsphyreScene), msgInvalidOwner);

 SearchDirty:= False;
end;

//--------------------------------------------------------------------------
destructor TAsphyreMeshes.Destroy();
begin
 RemoveAll();

 inherited;
end;

//--------------------------------------------------------------------------
function TAsphyreMeshes.GetCount(): Integer;
begin
 Result:= Length(Meshes);
end;

//--------------------------------------------------------------------------
function TAsphyreMeshes.GetMesh(Num: Integer): TAsphyreCustomMesh;
begin
 Assert((Num >= 0)and(Num < Length(Meshes)), msgIndexOutOfBounds);
 Result:= Meshes[Num];
end;

//--------------------------------------------------------------------------
function TAsphyreMeshes.FindEmptySlot(): Integer;
var
 i: Integer;
begin
 Result:= -1;

 for i:= 0 to Length(Meshes) - 1 do
  if (Meshes[i] = nil) then
   begin
    Result:= i;
    Break;
   end;
end;

//--------------------------------------------------------------------------
function TAsphyreMeshes.Insert(Mesh: TAsphyreCustomMesh): Integer;
var
 Slot: Integer;
begin
 Slot:= FindEmptySlot();
 if (Slot = -1) then
  begin
   Slot:= Length(Meshes);
   SetLength(Meshes, Slot + 1);
  end;

 Meshes[Slot]:= Mesh;
 Mesh.FMeshIndex:= Slot;

 SearchDirty:= True;
 Result:= Slot;
end;

//---------------------------------------------------------------------------
function TAsphyreMeshes.IndexOf(Mesh: TAsphyreCustomMesh): Integer;
var
 i: Integer;
begin
 Result:= -1;
 for i:= 0 to Length(Meshes) - 1 do
  if (Meshes[i] = Mesh) then
   begin
    Result:= i;
    Break;
   end;
end;

//---------------------------------------------------------------------------
function TAsphyreMeshes.Include(Mesh: TAsphyreCustomMesh): Integer;
begin
 Result:= IndexOf(Mesh);
 if (Result = -1) then Result:= Insert(Mesh);
end;

//---------------------------------------------------------------------------
procedure TAsphyreMeshes.Exclude(Mesh: TAsphyreCustomMesh);
var
 Index: Integer;
begin
 Index:= IndexOf(Mesh);
 if (Index <> -1) then
  begin
   Meshes[Index]:= nil;
   SearchDirty:= True;
  end;
end;

//---------------------------------------------------------------------------
procedure TAsphyreMeshes.Remove(Num: Integer);
begin
 Assert((Num >= 0)and(Num < Length(Meshes)), msgIndexOutOfBounds);

 Meshes[Num].NoExclude:= True;
 Meshes[Num].Free();
 Meshes[Num]:= nil;

 SearchDirty:= True;
end;

//---------------------------------------------------------------------------
procedure TAsphyreMeshes.RemoveAll();
var
 i: Integer;
begin
 for i:= 0 to Length(Meshes) - 1 do
  if (Meshes[i] <> nil) then
   begin
    Meshes[i].NoExclude:= True;
    Meshes[i].Free();
    Meshes[i]:= nil;
   end;

 SetLength(Meshes, 0);
 SetLength(SearchObjects, 0);
 SearchDirty:= False;
end;

//---------------------------------------------------------------------------
function TAsphyreMeshes.CountSearchObjects(): Integer;
var
 i: Integer;
begin
 Result:= 0;

 for i:= 0 to Length(Meshes) - 1 do
  if (Meshes[i] <> nil) then Inc(Result);
end;

//---------------------------------------------------------------------------
procedure TAsphyreMeshes.FillSearchObjects(Amount: Integer);
var
 i, DestIndex: Integer;
begin
 SetLength(SearchObjects, Amount);

 DestIndex:= 0;
 for i:= 0 to Length(Meshes) - 1 do
  if (Meshes[i] <> nil) then
   begin
    SearchObjects[DestIndex]:= i;
    Inc(DestIndex);
   end;
end;

//---------------------------------------------------------------------------
procedure TAsphyreMeshes.SortSearchObjects(Left, Right: Integer);
var
 Lo, Hi: Integer;
 TempIndex: Integer;
 MidValue: string;
begin
 Lo:= Left;
 Hi:= Right;
 MidValue:= Meshes[SearchObjects[(Left + Right) shr 1]].Name;

 repeat
  while (Meshes[SearchObjects[Lo]].Name < MidValue) do Inc(Lo);
  while (MidValue < Meshes[SearchObjects[Hi]].Name) do Dec(Hi);

  if (Lo <= Hi) then
   begin
    TempIndex:= SearchObjects[Lo];
    SearchObjects[Lo]:= SearchObjects[Hi];
    SearchObjects[Hi]:= TempIndex;

    Inc(Lo);
    Dec(Hi);
   end;
 until (Lo > Hi);

 if (Left < Hi) then SortSearchObjects(Left, Hi);
 if (Lo < Right) then SortSearchObjects(Lo, Right);
end;

//---------------------------------------------------------------------------
procedure TAsphyreMeshes.PrepareSearchObjects();
var
 Amount: Integer;
begin
 Amount:= CountSearchObjects();

 FillSearchObjects(Amount);

 if (Amount > 0) then
  SortSearchObjects(0, Amount - 1);

 SearchDirty:= False;
end;

//---------------------------------------------------------------------------
function TAsphyreMeshes.IndexOf(const uid: string): Integer;
var
 Lo, Hi, Mid: Integer;
begin
 if (SearchDirty) then PrepareSearchObjects();

 Result:= -1;

 Lo:= 0;
 Hi:= Length(SearchObjects) - 1;

 while (Lo <= Hi) do
  begin
   Mid:= (Lo + Hi) div 2;

   if (Meshes[SearchObjects[Mid]].Name = uid) then
    begin
     Result:= SearchObjects[Mid];
     Break;
    end;

   if (Meshes[SearchObjects[Mid]].Name > uid) then Hi:= Mid - 1
    else Lo:= Mid + 1;
 end;
end;

//--------------------------------------------------------------------------
end.
