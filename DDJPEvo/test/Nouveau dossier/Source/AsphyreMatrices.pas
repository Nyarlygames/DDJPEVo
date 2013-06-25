unit AsphyreMatrices;
//---------------------------------------------------------------------------
// AsphyreMatrices.pas                                  Modified: 28-Jan-2007
// High-level implementation of 4x4 matrix w/32-byte alignment    Version 1.0
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
// The Original Code is AsphyreMatrices.pas.
//
// The Initial Developer of the Original Code is M. Sc. Yuriy Kotsarenko.
// Portions created by M. Sc. Yuriy Kotsarenko are Copyright (C) 2007,
// Afterwarp Interactive. All Rights Reserved.
//---------------------------------------------------------------------------
interface

//---------------------------------------------------------------------------
uses
 Vectors3, Matrices4;

//---------------------------------------------------------------------------
type
 TAsphyreMatrix = class
 private
  MemAddr: Pointer;
  FRawMtx: PMatrix4;

 public
  property RawMtx: PMatrix4 read FRawMtx;

  procedure LoadIdentity();
  procedure LoadZero();

  procedure Translate(dx, dy, dz: Real); overload;
  procedure Translate(const v: TVector3); overload;

  procedure Scale(const v: TVector3); overload;
  procedure Scale(dx, dy, dz: Real); overload;
  procedure RotateX(Phi: Real);
  procedure RotateY(Phi: Real);
  procedure RotateZ(Phi: Real);

  procedure RotateXLocal(Phi: Real);
  procedure RotateYLocal(Phi: Real);
  procedure RotateZLocal(Phi: Real);

  procedure Multiply(const SrcMtx: TMatrix4); overload;
  procedure Multiply(Source: TAsphyreMatrix); overload;

  procedure LoadRotation(SrcMtx: PMatrix4);

  procedure LookAt(const Origin, Target, Roof: TVector3);

  procedure PerspectiveFOVY(FieldOfView, AspectRatio, MinRange, MaxRange: Real);
  procedure PerspectiveFOVX(FieldOfView, AspectRatio, MinRange, MaxRange: Real);
  procedure PerspectiveVOL(Width, Height, MinRange, MaxRange: Real);
  procedure PerspectiveBDS(Left, Right, Top, Bottom, MinRange, MaxRange: Real);
  procedure OrthogonalVOL(Width, Height, MinRange, MaxRange: Real);
  procedure OrthogonalBDS(Left, Right, Top, Bottom, MinRange, MaxRange: Real);

  constructor Create();
  destructor Destroy(); override;
 end;

//---------------------------------------------------------------------------
implementation

//---------------------------------------------------------------------------
const
 Grad2Rad = Pi / 180.0;

//---------------------------------------------------------------------------
constructor TAsphyreMatrix.Create();
begin
 inherited;

 MemAddr:= AllocMem(SizeOf(TMatrix4) + 16);
 FRawMtx:= Pointer(Integer(MemAddr) + ($10 - (Integer(MemAddr) and $0F)));

 LoadIdentity();
end;

//---------------------------------------------------------------------------
destructor TAsphyreMatrix.Destroy();
begin
 FreeMem(MemAddr);

 inherited;
end;

//---------------------------------------------------------------------------
procedure TAsphyreMatrix.LoadIdentity();
begin
 Move(IdentityMtx4, FRawMtx^, SizeOf(TMatrix4));
end;

//---------------------------------------------------------------------------
procedure TAsphyreMatrix.LoadZero();
begin
 FillChar(FRawMtx^, SizeOf(TMatrix4), 0);
end;

//---------------------------------------------------------------------------
procedure TAsphyreMatrix.Translate(dx, dy, dz: Real);
begin
 FRawMtx^:= FRawMtx^ * TranslateMtx4(Vector3(dx, dy, dz));
end;

//---------------------------------------------------------------------------
procedure TAsphyreMatrix.Translate(const v: TVector3);
begin
 FRawMtx^:= FRawMtx^ * TranslateMtx4(v);
end;

//---------------------------------------------------------------------------
procedure TAsphyreMatrix.RotateX(Phi: Real);
begin
 FRawMtx^:= FRawMtx^ * RotateXMtx4(Phi);
end;

//---------------------------------------------------------------------------
procedure TAsphyreMatrix.RotateY(Phi: Real);
begin
 FRawMtx^:= FRawMtx^ * RotateYMtx4(Phi);
end;

//---------------------------------------------------------------------------
procedure TAsphyreMatrix.RotateZ(Phi: Real);
begin
 FRawMtx^:= FRawMtx^ * RotateZMtx4(Phi);
end;

//---------------------------------------------------------------------------
procedure TAsphyreMatrix.Scale(const v: TVector3);
begin
 FRawMtx^:= FRawMtx^ * ScaleMtx4(v);
end;

//---------------------------------------------------------------------------
procedure TAsphyreMatrix.Scale(dx, dy, dz: Real);
begin
 FRawMtx^:= FRawMtx^ * ScaleMtx4(Vector3(dx, dy, dz));
end;

//---------------------------------------------------------------------------
procedure TAsphyreMatrix.RotateXLocal(Phi: Real);
var
 Axis: TVector3;
begin
 Axis.x:= FRawMtx.Data[0, 0];
 Axis.y:= FRawMtx.Data[0, 1];
 Axis.z:= FRawMtx.Data[0, 2];

 FRawMtx^:= FRawMtx^ * RotateMtx4(Axis, Phi);
end;

//---------------------------------------------------------------------------
procedure TAsphyreMatrix.RotateYLocal(Phi: Real);
var
 Axis: TVector3;
begin
 Axis.x:= FRawMtx.Data[1, 0];
 Axis.y:= FRawMtx.Data[1, 1];
 Axis.z:= FRawMtx.Data[1, 2];

 FRawMtx^:= FRawMtx^ * RotateMtx4(Axis, Phi);
end;

//---------------------------------------------------------------------------
procedure TAsphyreMatrix.RotateZLocal(Phi: Real);
var
 Axis: TVector3;
begin
 Axis.x:= FRawMtx.Data[2, 0];
 Axis.y:= FRawMtx.Data[2, 1];
 Axis.z:= FRawMtx.Data[2, 2];

 FRawMtx^:= FRawMtx^ * RotateMtx4(Axis, Phi);
end;

//---------------------------------------------------------------------------
procedure TAsphyreMatrix.Multiply(const SrcMtx: TMatrix4);
begin
 FRawMtx^:= FRawMtx^ * SrcMtx;
end;

//---------------------------------------------------------------------------
procedure TAsphyreMatrix.Multiply(Source: TAsphyreMatrix);
begin
 Multiply(Source.RawMtx^);
end;

//--------------------------------------------------------------------------
procedure TAsphyreMatrix.LookAt(const Origin, Target, Roof: TVector3);
begin
 FRawMtx^:= LookAtMtx4(Origin, Target, Roof);
end;

//--------------------------------------------------------------------------
procedure TAsphyreMatrix.PerspectiveFOVY(FieldOfView, AspectRatio, MinRange,
 MaxRange: Real);
begin
 FRawMtx^:= PerspectiveFOVYMtx4(FieldOfView, AspectRatio, MinRange,
  MaxRange);
end;

//--------------------------------------------------------------------------
procedure TAsphyreMatrix.PerspectiveFOVX(FieldOfView, AspectRatio, MinRange,
 MaxRange: Real);
begin
 FRawMtx^:= PerspectiveFOVXMtx4(FieldOfView, AspectRatio, MinRange,
  MaxRange);
end;

//--------------------------------------------------------------------------
procedure TAsphyreMatrix.PerspectiveVOL(Width, Height, MinRange,
 MaxRange: Real);
begin
 FRawMtx^:= PerspectiveVOLMtx4(Width, Height, MinRange, MaxRange);
end;

//--------------------------------------------------------------------------
procedure TAsphyreMatrix.PerspectiveBDS(Left, Right, Top, Bottom, MinRange,
 MaxRange: Real);
begin
 FRawMtx^:= PerspectiveBDSMtx4(Left, Right, Top, Bottom, MinRange, MaxRange);
end;

//--------------------------------------------------------------------------
procedure TAsphyreMatrix.OrthogonalVOL(Width, Height, MinRange, MaxRange: Real);
begin
 FRawMtx^:= OrthogonalVOLMtx4(Width, Height, MinRange, MaxRange);
end;

//--------------------------------------------------------------------------
procedure TAsphyreMatrix.OrthogonalBDS(Left, Right, Top, Bottom, MinRange,
 MaxRange: Real);
begin
 FRawMtx^:= OrthogonalBDSMtx4(Left, Right, Top, Bottom, MinRange, MaxRange);
end;

//---------------------------------------------------------------------------
procedure TAsphyreMatrix.LoadRotation(SrcMtx: PMatrix4);
var
 i: Integer;
begin
 Move(SrcMtx^, FRawMtx^, SizeOf(TMatrix4));

 for i:= 0 to 3 do
  begin
   FRawMtx.Data[3, i]:= 0.0;
   FRawMtx.Data[i, 3]:= 0.0;
  end;
  
 FRawMtx.Data[3, 3]:= 1.0; 
end;

//---------------------------------------------------------------------------
end.
