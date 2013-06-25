unit AsphyreMeshX;
//---------------------------------------------------------------------------
// AsphyreMeshX.pas                                     Modified: 29-Jan-2007
// Wrapper for DirectX .X meshes                                  Version 1.0
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
// The Original Code is AsphyreMeshX.pas.
//
// The Initial Developer of the Original Code is M. Sc. Yuriy Kotsarenko.
// Portions created by M. Sc. Yuriy Kotsarenko are Copyright (C) 2007,
// Afterwarp Interactive. All Rights Reserved.
//---------------------------------------------------------------------------
interface

//--------------------------------------------------------------------------
uses
 Windows, Direct3D9, D3DX9, AsphyreAsserts, AsphyreMeshes, AsphyreImages;

//--------------------------------------------------------------------------
type
 TAsphyreMeshX = class(TAsphyreCustomMesh)
 private
  FMesh: ID3DXMesh;

  Materials: array of TD3DMaterial9;

  FImages : TAsphyreImages;
  Textures: array of Integer;

  function GetMaterial(Num: Integer): PD3DMaterial9;
  function GetTexture(Num: Integer): Integer;
  procedure SetTexture(Num: Integer; const Value: Integer);
  function GetMaterialCount(): Integer;
 public
  property Mesh: ID3DXMesh read FMesh;
  property Images: TAsphyreImages read FImages;

  property MaterialCount: Integer read GetMaterialCount;
  property Material[Num: Integer]: PD3DMaterial9 read GetMaterial;
  property Texture[Num: Integer]: Integer read GetTexture write SetTexture;

  function InitSphere(Radius: Single; Slices, Stacks: Integer): Boolean;
  function LoadFromFile(const FileName: string): Boolean;

  procedure Draw(); override;
  procedure Finalize(); override;

  constructor Create(AOwner: TAsphyreMeshes); override;
 end;

//--------------------------------------------------------------------------
implementation

//--------------------------------------------------------------------------
uses
 AsphyreDXUtils, AsphyreScene;

//--------------------------------------------------------------------------
constructor TAsphyreMeshX.Create(AOwner: TAsphyreMeshes);
begin
 inherited;

 FImages:= TAsphyreScene(Owner.Scene).Device.Images;
end;

//--------------------------------------------------------------------------
procedure TAsphyreMeshX.Finalize();
begin
 if (FMesh <> nil) then FMesh:= nil;

 SetLength(Materials, 0);
 SetLength(Textures, 0);

 FInitialized:= False;
end;

//--------------------------------------------------------------------------
function TAsphyreMeshX.GetMaterialCount(): Integer;
begin
 Result:= Length(Materials);
end;

//--------------------------------------------------------------------------
function TAsphyreMeshX.GetMaterial(Num: Integer): PD3DMaterial9;
begin
 Assert((Num >= 0)and(Num < Length(Materials)), msgIndexOutOfBounds);
 Result:= @Materials[Num];
end;

//--------------------------------------------------------------------------
function TAsphyreMeshX.GetTexture(Num: Integer): Integer;
begin
 Assert((Num >= 0)and(Num < Length(Textures)), msgIndexOutOfBounds);
 Result:= Textures[Num];
end;

//--------------------------------------------------------------------------
procedure TAsphyreMeshX.SetTexture(Num: Integer; const Value: Integer);
begin
 Assert((Num >= 0)and(Num < Length(Textures)), msgIndexOutOfBounds);
 Textures[Num]:= Value;
end;

//--------------------------------------------------------------------------
function TAsphyreMeshX.InitSphere(Radius: Single; Slices,
 Stacks: Integer): Boolean;
begin
 Assert(not FInitialized, msgAlreadyInitialized);

 Result:= Succeeded(D3DXCreateSphere(TAsphyreScene(Owner.Scene).Device.Dev9,
  Radius, Slices, Stacks, FMesh, nil));

 SetLength(Materials, 1);
 SetLength(Textures, 1);

 with Materials[0] do
  begin
   Diffuse := ToD3DColorValue($FFFFFFFF);
   Specular:= ToD3DColorValue($FFFFFF);
   Ambient := ToD3DColorValue($FFFFFF);
   Emissive:= ToD3DColorValue($000000);
   Power   := 20.0;
  end;

 Textures[0]:= -1;

 FInitialized:= Result;
end;

//--------------------------------------------------------------------------
function TAsphyreMeshX.LoadFromFile(const FileName: string): Boolean;
var
 Adjacency   : ID3DXBuffer;
 BufMaterials: ID3DXBuffer;
 NumMaterials: Cardinal;
 SrcMaterial : PD3DXMaterial;
 i: Integer;
begin
 Assert(not FInitialized, msgAlreadyInitialized);

 Result:= Succeeded(D3DXLoadMeshFromX(PChar(FileName), D3DXMESH_MANAGED,
  TAsphyreScene(Owner.Scene).Device.Dev9, @Adjacency, @BufMaterials, nil,
  @NumMaterials, FMesh));
 if (not Result) then Exit;

 SetLength(Materials, NumMaterials);
 SetLength(Textures, NumMaterials);

 SrcMaterial:= BufMaterials.GetBufferPointer();

 for i:= 0 to NumMaterials - 1 do
  begin
   // retreive material information
   Materials[i]:= SrcMaterial.MatD3D;
   Materials[i].Ambient:= Materials[i].Diffuse;

   // retreive the used texture
   Textures[i]:= FImages.ResolveImage(SrcMaterial.pTextureFilename);

   Inc(SrcMaterial);
  end;

 FMesh.OptimizeInplace(D3DXMESHOPT_COMPACT or D3DXMESHOPT_ATTRSORT or
  D3DXMESHOPT_VERTEXCACHE, Adjacency.GetBufferPointer(), nil, nil, nil);

 FInitialized:= True;
 BufMaterials:= nil;
 Adjacency   := nil;
end;

//--------------------------------------------------------------------------
procedure TAsphyreMeshX.Draw();
var
 i: Integer;
 Image: TAsphyreCustomImage;
begin
 Assert(FInitialized, msgNotInitialized);

 for i:= 0 to Length(Materials) - 1 do
  begin
   with TAsphyreScene(Owner.Scene).Device.Dev9 do
    begin
     // specify Direct3D material
     SetMaterial(Materials[i]);

     // specify Direct3D texture
     if (Textures[i] <> -1) then
      begin
       Image:= FImages[Textures[i]];

       if (Image <> nil)and(Image.TextureCount > 0) then
        Image.Texture[0].Activate(0);
      end else SetTexture(0, nil);
    end;
   if (Failed(FMesh.DrawSubset(i))) then Assert(False);
  end;
end;

//--------------------------------------------------------------------------
end.
