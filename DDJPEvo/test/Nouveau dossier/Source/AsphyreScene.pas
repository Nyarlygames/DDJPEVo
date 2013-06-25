unit AsphyreScene;
//---------------------------------------------------------------------------
// AsphyreScene.pas                                     Modified: 29-Jan-2007
// High-level structure for making 3D scenes in Asphyre           Version 1.0
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
// The Original Code is AsphyreScene.pas.
//
// The Initial Developer of the Original Code is M. Sc. Yuriy Kotsarenko.
// Portions created by M. Sc. Yuriy Kotsarenko are Copyright (C) 2007,
// Afterwarp Interactive. All Rights Reserved.
//---------------------------------------------------------------------------
interface

//--------------------------------------------------------------------------
uses
 Windows, Direct3D9, AsphyreAsserts, AsphyreDevices, AsphyreLights,
 AsphyreMeshes, AsphyreMatrices, AsphyreStates;

//--------------------------------------------------------------------------
type
 TAsphyreTransformType = (attWorld, attView, attProjection);

//--------------------------------------------------------------------------
 TAsphyreTransformTypes = set of TAsphyreTransformType;

//--------------------------------------------------------------------------
 TAsphyreScene = class
 private
  FDevice: TAsphyreDevice;
  FLights: TAsphyreLights;
  FMeshes: TAsphyreMeshes;
  FStates: TAsphyreStates;

  FWorldMtx: TAsphyreMatrix;
  FViewMtx : TAsphyreMatrix;
  FProjMtx : TAsphyreMatrix;
 public
  property Device: TAsphyreDevice read FDevice;

  property Lights: TAsphyreLights read FLights;
  property Meshes: TAsphyreMeshes read FMeshes;
  property States: TAsphyreStates read FStates;

  property WorldMtx: TAsphyreMatrix read FWorldMtx;
  property ViewMtx : TAsphyreMatrix read FViewMtx;
  property ProjMtx : TAsphyreMatrix read FProjMtx;

  function UpdateTransform(Types: TAsphyreTransformTypes): Boolean;

  constructor Create(ADevice: TAsphyreDevice);
  destructor Destroy(); override;
 end;

//--------------------------------------------------------------------------
implementation

//--------------------------------------------------------------------------
constructor TAsphyreScene.Create(ADevice: TAsphyreDevice);
begin
 inherited Create();

 FDevice:= ADevice;
 Assert(FDevice <> nil);

 FWorldMtx:= TAsphyreMatrix.Create();
 FViewMtx := TAsphyreMatrix.Create();
 FProjMtx := TAsphyreMatrix.Create();

 FLights:= TAsphyreLights.Create(Self);
 FMeshes:= TAsphyreMeshes.Create(Self);
 FStates:= TAsphyreStates.Create(Self);
end;

//--------------------------------------------------------------------------
destructor TAsphyreScene.Destroy();
begin
 FStates.Free();
 FMeshes.Free();
 FLights.Free();

 FProjMtx.Free();
 FViewMtx.Free();
 FWorldMtx.Free();

 inherited;
end;

//--------------------------------------------------------------------------
function TAsphyreScene.UpdateTransform(Types: TAsphyreTransformTypes): Boolean;
begin
 Assert(FDevice.Initialized, msgNotInitialized);

 Result:= True;

 if (attWorld in Types) then
  Result:= Succeeded(FDevice.Dev9.SetTransform(D3DTS_WORLD,
   TD3DMatrix(FWorldMtx.RawMtx^)));

 if (attView in Types)and(Result) then
  Result:= Succeeded(FDevice.Dev9.SetTransform(D3DTS_VIEW,
   TD3DMatrix(FViewMtx.RawMtx^)));

 if (attProjection in Types)and(Result) then
  Result:= Succeeded(FDevice.Dev9.SetTransform(D3DTS_PROJECTION,
   TD3DMatrix(FProjMtx.RawMtx^)));
end;

//--------------------------------------------------------------------------
end.
