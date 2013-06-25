unit AsphyreStates;
//---------------------------------------------------------------------------
// AsphyreStates.pas                                    Modified: 29-Jan-2007
// A wrapper for some relevant Direct3D states                    Version 1.0
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
// The Original Code is AsphyreStates.pas.
//
// The Initial Developer of the Original Code is M. Sc. Yuriy Kotsarenko.
// Portions created by M. Sc. Yuriy Kotsarenko are Copyright (C) 2007,
// Afterwarp Interactive. All Rights Reserved.
//---------------------------------------------------------------------------
interface

//---------------------------------------------------------------------------
uses
 Direct3D9, AsphyreAsserts;

//---------------------------------------------------------------------------
type
 TAsphyreCullMode = (acmNone, acmClockwise, acmAnticlockwise);

//---------------------------------------------------------------------------
 TAsphyreAntialiasType = (aatNone, aatLinear, aatMipmaps);

//---------------------------------------------------------------------------
 TAsphyreStates = class
 private
  FScene: TObject;

  function GetBoolValue(const Index: Integer): Boolean;
  procedure SetBoolValue(const Index: Integer; const Value: Boolean);
  function GetCullMode(): TAsphyreCullMode;
  procedure SetCullMode(const Value: TAsphyreCullMode);
  procedure SetAntialias(const Value: TAsphyreAntialiasType);
 public
  property Scene: TObject read FScene;

  // Determines the usage of depth buffer
  property DepthBuffer: Boolean index 0 read GetBoolValue write SetBoolValue;

  // Determines the usage of 3D lights and illumination
  property Lighting: Boolean index 1 read GetBoolValue write SetBoolValue;

  // Determines whether the normals should be normalized in 3D meshes
  property NormalNormalize: Boolean index 2 read GetBoolValue write SetBoolValue;

  // Whether to use specular illumination
  property SpecularLights: Boolean index 3 read GetBoolValue write SetBoolValue;

  // Determines the type of antialiasing used. This property cannot be read.
  property Antialias: TAsphyreAntialiasType write SetAntialias;

  // The type of culling used for rendering 3D triangles
  property CullMode: TAsphyreCullMode read GetCullMode write SetCullMode;

  constructor Create(AScene: TObject);
 end;

//---------------------------------------------------------------------------
implementation

//--------------------------------------------------------------------------
uses
 AsphyreScene;

//--------------------------------------------------------------------------
constructor TAsphyreStates.Create(AScene: TObject);
begin
 inherited Create();

 FScene:= AScene;
 Assert((FScene <> nil)and(FScene is TAsphyreScene), msgInvalidOwner);
end;

//---------------------------------------------------------------------------
function TAsphyreStates.GetBoolValue(const Index: Integer): Boolean;
var
 vCard: Cardinal;
begin
 with TAsphyreScene(FScene).Device.Dev9 do
  begin
   case Index of
    0: begin // DepthBuffer
        GetRenderState(D3DRS_ZENABLE, vCard);
        Result:= (vCard = D3DZB_TRUE);
       end;
    1: begin // Lighting
        GetRenderState(D3DRS_LIGHTING, vCard);
        Result:= (vCard = iTrue);
       end;
    2: begin // NormalNormalize
        GetRenderState(D3DRS_NORMALIZENORMALS, vCard);
        Result:= (vCard = iTrue);
       end;
    3: begin // SpecularLights
        GetRenderState(D3DRS_SPECULARENABLE, vCard);
        Result:= (vCard = iTrue);
       end;
    4: begin // Mipmapping
        GetRenderState(D3DRS_SPECULARENABLE, vCard);
        Result:= (vCard = iTrue);
       end;
     else Result:= False;
   end; // case
  end; // with
end;

//---------------------------------------------------------------------------
procedure TAsphyreStates.SetBoolValue(const Index: Integer;
 const Value: Boolean);
begin
 with TAsphyreScene(FScene).Device.Dev9 do
  begin
   case Index of
    0: if (Value) then SetRenderState(D3DRS_ZENABLE, D3DZB_TRUE)
        else SetRenderState(D3DRS_ZENABLE, D3DZB_FALSE);
    1: if (Value) then SetRenderState(D3DRS_LIGHTING, iTrue)
        else SetRenderState(D3DRS_LIGHTING, iFalse);
    2: if (Value) then SetRenderState(D3DRS_NORMALIZENORMALS, iTrue)
        else SetRenderState(D3DRS_NORMALIZENORMALS, iFalse);
    3: if (Value) then SetRenderState(D3DRS_SPECULARENABLE, iTrue)
        else SetRenderState(D3DRS_SPECULARENABLE, iFalse);
   end; // case
  end; // with
end;

//---------------------------------------------------------------------------
function TAsphyreStates.GetCullMode(): TAsphyreCullMode;
var
 vCard: Cardinal;
begin
 with TAsphyreScene(FScene).Device.Dev9 do
  begin
   GetRenderState(D3DRS_CULLMODE, vCard);

   case vCard of
    D3DCULL_CW : Result:= acmClockwise;
    D3DCULL_CCW: Result:= acmAnticlockwise;
    else Result:= acmNone;
   end;
  end;
end;

//---------------------------------------------------------------------------
procedure TAsphyreStates.SetCullMode(const Value: TAsphyreCullMode);
begin
 with TAsphyreScene(FScene).Device.Dev9 do
  case Value of
   acmNone:
    SetRenderState(D3DRS_CULLMODE, D3DCULL_NONE);
    
   acmClockwise:
    SetRenderState(D3DRS_CULLMODE, D3DCULL_CW);

   acmAnticlockwise:
    SetRenderState(D3DRS_CULLMODE, D3DCULL_CCW);
  end;
end;

//---------------------------------------------------------------------------
procedure TAsphyreStates.SetAntialias(const Value: TAsphyreAntialiasType);
var
 i: Integer;
begin
 with TAsphyreScene(FScene).Device.Dev9 do
  for i:= 0 to 7 do
   case Value of
    aatNone:
     begin
      SetSamplerState(i, D3DSAMP_MAGFILTER, D3DTEXF_POINT);
      SetSamplerState(i, D3DSAMP_MINFILTER, D3DTEXF_POINT);
      SetSamplerState(i, D3DSAMP_MIPFILTER, D3DTEXF_NONE);
     end;
    aatLinear:
     begin
      SetSamplerState(i, D3DSAMP_MAGFILTER, D3DTEXF_LINEAR);
      SetSamplerState(i, D3DSAMP_MINFILTER, D3DTEXF_LINEAR);
      SetSamplerState(i, D3DSAMP_MIPFILTER, D3DTEXF_POINT);
     end;
    aatMipmaps:
     begin
      SetSamplerState(i, D3DSAMP_MAGFILTER, D3DTEXF_LINEAR);
      SetSamplerState(i, D3DSAMP_MINFILTER, D3DTEXF_LINEAR);
      SetSamplerState(i, D3DSAMP_MIPFILTER, D3DTEXF_LINEAR);
     end;
   end;
end;

//---------------------------------------------------------------------------
end.
