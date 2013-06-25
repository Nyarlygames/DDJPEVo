unit DrawingUtils;

//---------------------------------------------------------------------------
interface

//---------------------------------------------------------------------------
uses
 Windows, Types, AsphyreDef, AsphyreCanvas, AsphyreImages;

//---------------------------------------------------------------------------
procedure DrawScaled(Dest: TAsphyreCanvas; Source: TAsphyreCustomImage;
 x, y, Pattern: Integer; const Colors: TColor4; Scale, DrawFx: Integer);

//---------------------------------------------------------------------------
implementation

//---------------------------------------------------------------------------
procedure DrawScaled(Dest: TAsphyreCanvas; Source: TAsphyreCustomImage;
 x, y, Pattern: Integer; const Colors: TColor4; Scale, DrawFx: Integer);
var
 Size: TPoint;
begin
 Assert(Source is TAsphyreImage);

 Size:= TAsphyreImage(Source).PatternSize;

 Size.X:= MulDiv(Size.X - TAsphyreImage(Source).Padding.X, Scale, 1024);
 Size.Y:= MulDiv(Size.Y - TAsphyreImage(Source).Padding.Y, Scale, 1024);

 Dest.UseImage(Source, Pattern);
 Dest.TexMap(pBounds4(x, y, Size.X, Size.Y), Colors, DrawFx);
end;

//---------------------------------------------------------------------------
end.
