unit MediaUtils;
//---------------------------------------------------------------------------
// MediaUtils.pas                                       Modified: 22-Jan-2007
// Utility routines for handling media files                      Version 1.0
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
// The Original Code is MediaUtils.pas.
//
// The Initial Developer of the Original Code is M. Sc. Yuriy Kotsarenko.
// Portions created by M. Sc. Yuriy Kotsarenko are Copyright (C) 2007,
// Afterwarp Interactive. All Rights Reserved.
//---------------------------------------------------------------------------
interface

//---------------------------------------------------------------------------
uses
 Windows, Direct3D9, Classes, SysUtils, AsphyreDb, AsphyreXML, AsphyreDef;

//---------------------------------------------------------------------------
{$WARN SYMBOL_PLATFORM OFF}

//---------------------------------------------------------------------------
type
 TMediaSymbolEvent = procedure(Sender: TObject; const Symbol: string) of object;

//---------------------------------------------------------------------------
// IsArchiveLink()
//
// Validates if the specified link points to Archive.
// Example:
//   /data/media/map.zip | test.image
//---------------------------------------------------------------------------
function IsArchiveLink(const Text: string): Boolean;

//---------------------------------------------------------------------------
// ExtractArchiveName()
//
// Generates a valid archive file name with full path from the archive link.
//---------------------------------------------------------------------------
function ExtractArchiveName(const Text: string): string;

//---------------------------------------------------------------------------
// ExtractArchiveKey()
//
// Generates a valid key from the archive link.
//---------------------------------------------------------------------------
function ExtractArchiveKey(const Text: string): string;

//---------------------------------------------------------------------------
// LoadLinkXML()
//
// Attempts to load a link pointing to XML file
//---------------------------------------------------------------------------
function LoadLinkXML(const Link: string): TXMLNode;

//---------------------------------------------------------------------------
// GetWindowsDir()
//
// Retreives Windows System path.
//---------------------------------------------------------------------------
function GetWindowsPath(): TFileName;

//---------------------------------------------------------------------------
// GetTempDir()
//
// Retreives Temporary path.
//---------------------------------------------------------------------------
function GetTempPath(): TFileName;

//---------------------------------------------------------------------------
// MakeValidPath()
//
// Assures that the specified path ends with "\", so a file name can be
// added to it.
//---------------------------------------------------------------------------
function MakeValidPath(const Path: string): string;

//---------------------------------------------------------------------------
// MakeValidFileName()
//
// Assures that the specified file name does not begin with "\", so a path
// can be added to it.
//---------------------------------------------------------------------------
function MakeValidFileName(const FileName: string): string;

//---------------------------------------------------------------------------
// ParseInt()
//
// Parses a signed integer value read from XML. If no AutoValue is provided,
// in case of empty or non-parseable text, -1 will be returned.
//---------------------------------------------------------------------------
function ParseInt(const Text: string): Integer; overload;
function ParseInt(const Text: string; AutoValue: Integer): Integer; overload;

//---------------------------------------------------------------------------
// ParseCardinal()
//
// Parses an unsigned integer value read from XML. If no AutoValue is provided,
// in case of empty or non-parseable text, High(Cardinal) will be returned.
//---------------------------------------------------------------------------
function ParseCardinal(const Text: string): Cardinal; overload;
function ParseCardinal(const Text: string;
 AutoValue: Cardinal): Cardinal; overload;

//---------------------------------------------------------------------------
// ParseFloat()
//
// Parses a floating-point  unsigned integer value read from XML. If no AutoValue is provided,
// in case of empty or non-parseable text, High(Cardinal) will be returned.
//---------------------------------------------------------------------------
function ParseFloat(const Text: string): Real; overload;
function ParseFloat(const Text: string; AutoValue: Real): Real; overload;

//---------------------------------------------------------------------------
// ParseBoolean()
//
// Parses Boolean text representation (true, false, yes, no).
//---------------------------------------------------------------------------
function ParseBoolean(const Text: string): Boolean;

//---------------------------------------------------------------------------
// ParseColor()
//
// Parses an HTML or hexadecimal color.
//  -> For HTML colors (#RRGGBB), alpha is always 255.
//  -> If no AutoValue is specified, unparseable text gives opaque white.
//---------------------------------------------------------------------------
function ParseColor(const Text: string): Cardinal; overload;
function ParseColor(const Text: string;
 AutoColor: Cardinal): Cardinal; overload;

//---------------------------------------------------------------------------
// ParseFormat()
//
// Parses a text representation of TD3DFormat without "D3DFMT_" prefix.
//  Example: "a8r8g8b8" will return D3DFMT_A8R8G8B8 value.
//    -> The string must be in low case!
//---------------------------------------------------------------------------
function ParseFormat(const Text: string): TD3DFormat;

//---------------------------------------------------------------------------
// ParseImageType()
//
// Parses a text representation of TImageDescType.
//---------------------------------------------------------------------------
function ParseImageType(const Text: string): TImageDescType;

//---------------------------------------------------------------------------
// ParseFontType()
//
// Parses a text representation of TFontDescType.
//---------------------------------------------------------------------------
function ParseFontType(const Text: string): TFontDescType;

//---------------------------------------------------------------------------
// ParseFontWeight()
//
// Parses the font weight as defined in Win32 API. Text values should not
// contain "FW_" part. That is, "FW_BOLD" should be specified as "bold".
//---------------------------------------------------------------------------
function ParseFontWeight(const Text: string): Cardinal;

//---------------------------------------------------------------------------
// ParseFontCharset()
//
// Parses the font charset as defined in Win32 API. Text values should not
// contain "_CHARSET" part, so "OEM_CHARSET" should be specified as "oem".
//---------------------------------------------------------------------------
function ParseFontCharset(const Text: string): Cardinal;

//---------------------------------------------------------------------------
// ParseFontQuality()
//
// Parses the font quality as defined in Win32 API. Text values should not
// contain the "_QUALITY" part. That is, for "CLEARTYPE_QUALITY" it is enough
// to to set strin as "cleartype".
//---------------------------------------------------------------------------
function ParseFontQuality(const Text: string): Cardinal;

//---------------------------------------------------------------------------
implementation

//---------------------------------------------------------------------------
uses
 AsphyreArchives;

//---------------------------------------------------------------------------
const
 CLEARTYPE_QUALITY = 5;
 HANGUL_CHARSET    = HANGEUL_CHARSET;

//---------------------------------------------------------------------------
function IsArchiveLink(const Text: string): Boolean;
var
 xPos: Integer;
begin
 xPos:= Pos('|', Text);
 Result:= (Length(Text) >= 3)and(xPos > 1)and(xPos < Length(Text));
end;

//---------------------------------------------------------------------------
function ExtractArchiveName(const Text: string): string;
var
 xPos, i: Integer;
begin
 Result:= Text;

 // Step 1. Remove "key" part from the link.
 xPos:= Pos('|', Text);
 if (xPos <> 0) then
  Delete(Result, xPos, Length(Result) + 1 - xPos);

 // Step 2. Replace "/" with "\".
 for i:= 1 to Length(Result) do
  if (Result[i] = '/') then Result[i]:= '\';

 // Step 3. Trim all leading and trailing spaces.
 Result:= Trim(Result);

 // Step 4. Remove leading "\", if such exists.
 if (Length(Result) > 0)and(Result[1] = '\') then Delete(Result, 1, 1);

 // Step 5. Include program path
 Result:= ExtractFilePath(ParamStr(0)) + Result;
end;

//---------------------------------------------------------------------------
function ExtractArchiveKey(const Text: string): string;
var
 xPos: Integer;
begin
 Result:= Text;

 // Step 1. Remove "archive" part from the link.
 xPos:= Pos('|', Text);
 if (xPos <> 0) then
  Delete(Result, 1, xPos);

 // Step 2. Trim all leading and trailing spaces.
 Result:= Trim(Result);
end;

//---------------------------------------------------------------------------
function LoadLinkXML(const Link: string): TXMLNode;
var
 Stream: TMemoryStream;
begin
 if (IsArchiveLink(Link)) then
  begin
   Stream:= TMemoryStream.Create();

   if (not ArchiveManager.ExtractToStream(Link, Stream)) then
    begin
     Result:= nil;
     Stream.Free();
     Exit;
    end;

   Stream.Seek(0, soFromBeginning);

   try
    Result:= LoadXMLFromStream(Stream);
   finally
    Stream.Free();
   end;
  end else Result:= LoadXMLFromFile(ExtractArchiveName(Link));
end;

//---------------------------------------------------------------------------
function GetWindowsPath(): TFileName;
var
 WinDir: array [0..MAX_PATH - 1] of Char;
begin
 SetString(Result, WinDir, GetWindowsDirectory(WinDir, MAX_PATH));

 if (Result = '') then Result:= ExtractFilePath(ParamStr(0));
end;

//---------------------------------------------------------------------------
function GetTempPath(): TFileName;
var
 TempDir: array[0..MAX_PATH - 1] of Char;
begin
 try
  SetString(Result, TempDir, Windows.GetTempPath(MAX_PATH, TempDir));

  if (not DirectoryExists(Result)) then
   if (not CreateDirectory(PChar(Result), nil)) then
    begin
     Result:= IncludeTrailingBackslash(GetWindowsPath()) + 'TEMP';
     if (not DirectoryExists(Result)) then
      if (not CreateDirectory(Pointer(Result), nil)) then
       begin
        Result:= ExtractFileDrive(Result) + '\TEMP';
        if (not DirectoryExists(Result)) then
         if (not CreateDirectory(Pointer(Result), nil)) then
          begin
           Result:= ExtractFileDrive(Result) + '\TMP';
           if (not DirectoryExists(Result)) then
            if (not CreateDirectory(Pointer(Result), nil)) then
             Result:= ExtractFilePath(ParamStr(0));
          end;
       end;
    end;
  except
   Result:= ExtractFilePath(ParamStr(0));
 end;
end;

//---------------------------------------------------------------------------
function MakeValidPath(const Path: string): string;
begin
 Result:= Trim(Path);

 if (Length(Result) > 0)and(Result[Length(Result)] <> '\') then
  Result:= Result + '\';
end;

//---------------------------------------------------------------------------
function MakeValidFileName(const FileName: string): string;
begin
 Result:= Trim(FileName);
 while (Length(Result) > 0)and(Result[1] = '\') do Delete(Result, 1, 1);
end;

//---------------------------------------------------------------------------
function ParseInt(const Text: string): Integer;
begin
 Result:= StrToIntDef(Text, -1);
end;

//---------------------------------------------------------------------------
function ParseInt(const Text: string; AutoValue: Integer): Integer;
begin
 Result:= StrToIntDef(Text, AutoValue);
end;

//---------------------------------------------------------------------------
function ParseCardinal(const Text: string): Cardinal;
begin
 Result:= Cardinal(StrToIntDef(Text, Integer(High(Cardinal))));
end;

//---------------------------------------------------------------------------
function ParseCardinal(const Text: string; AutoValue: Cardinal): Cardinal;
begin
 Result:= Cardinal(StrToIntDef(Text, Integer(AutoValue)));
end;

//---------------------------------------------------------------------------
function ParseBoolean(const Text: string): Boolean;
begin
 Result:= False;

 if (Text = 'yes')or(Text = 'true') then Result:= True;
end;

//---------------------------------------------------------------------------
function ParseFloat(const Text: string): Real;
begin
 Result:= ParseFloat(Text, 0.0);
end;

//---------------------------------------------------------------------------
function ParseFloat(const Text: string; AutoValue: Real): Real;
begin
 Result:= StrToFloatDef(Text, AutoValue);
end;

//---------------------------------------------------------------------------
function ParseColor(const Text: string; AutoColor: Cardinal): Cardinal;
begin
 if (Text = 'source')or(Text = 'auto')or(Text = 'none') then
  begin
   Result:= AutoColor;
   Exit;
  end;

 Result:= $FFFFFFFF;
 if (Length(Text) < 2)or((Text[1] <> '#')and(Text[1] <> '$')) then Exit;

 if (Text[1] = '#') then
  begin
   Result:= Cardinal(StrToIntDef('$' + Copy(Text, 2, Length(Text) - 1),
    Integer(AutoColor))) or $FF000000;
  end else Result:= Cardinal(StrToIntDef(Text, Integer(AutoColor)));
end;

//---------------------------------------------------------------------------
function ParseColor(const Text: string): Cardinal;
begin
 Result:= ParseColor(Text, $FFFFFFFF);
end;

//---------------------------------------------------------------------------
function ParseFormat(const Text: string): TD3DFormat;
begin
 Result:= D3DFMT_UNKNOWN;

 if (Text = 'a2r10g10b10') then Result:= D3DFMT_A2R10G10B10;

 if (Text = 'r8g8b8') then Result:= D3DFMT_R8G8B8;
 if (Text = 'a8r8g8b8') then Result:= D3DFMT_A8R8G8B8;
 if (Text = 'x8r8g8b8') then Result:= D3DFMT_X8R8G8B8;
 if (Text = 'r5g6b5') then Result:= D3DFMT_R5G6B5;
 if (Text = 'x1r5g5b5') then Result:= D3DFMT_X1R5G5B5;
 if (Text = 'a1r5g5b5') then Result:= D3DFMT_A1R5G5B5;

 if (Text = 'a4r4g4b4') then Result:= D3DFMT_A4R4G4B4;

 if (Text = 'a4r4g4b4') then Result:= D3DFMT_A4R4G4B4;
 if (Text = 'r3g3b2') then Result:= D3DFMT_R3G3B2;
 if (Text = 'a8') then Result:= D3DFMT_A8;
 if (Text = 'a8r3g3b2') then Result:= D3DFMT_A8R3G3B2;
 if (Text = 'x4r4g4b4') then Result:= D3DFMT_X4R4G4B4;
 if (Text = 'a2b10g10r10') then Result:= D3DFMT_A2B10G10R10;

 if (Text = 'a8b8g8r8') then Result:= D3DFMT_A8B8G8R8;
 if (Text = 'x8b8g8r8') then Result:= D3DFMT_X8B8G8R8;
 if (Text = 'g16r16') then Result:= D3DFMT_G16R16;
 if (Text = 'a4r4g4b4') then Result:= D3DFMT_A4R4G4B4;
 if (Text = 'a2r10g10b10') then Result:= D3DFMT_A2R10G10B10;
 if (Text = 'a16b16g16r16') then Result:= D3DFMT_A16B16G16R16;

 if (Text = 'a8p8') then Result:= D3DFMT_A8P8;
 if (Text = 'p8') then Result:= D3DFMT_P8;
 if (Text = 'l8') then Result:= D3DFMT_L8;
 if (Text = 'a8l8') then Result:= D3DFMT_A8L8;
 if (Text = 'a4l4') then Result:= D3DFMT_A4L4;

 if (Text = 'v8u8') then Result:= D3DFMT_V8U8;
 if (Text = 'l6v5u5') then Result:= D3DFMT_L6V5U5;
 if (Text = 'x8l8v8u8') then Result:= D3DFMT_X8L8V8U8;
 if (Text = 'q8w8v8u8') then Result:= D3DFMT_Q8W8V8U8;
 if (Text = 'v16u16') then Result:= D3DFMT_V16U16;
 if (Text = 'a2w10v10u10') then Result:= D3DFMT_A2W10V10U10;
 if (Text = 'a8x8v8u8') then Result:= D3DFMT_A8X8V8U8;
 if (Text = 'l8x8v8u8') then Result:= D3DFMT_L8X8V8U8;

 if (Text = 'uyvy') then Result:= D3DFMT_UYVY;
 if (Text = 'rgbg') then Result:= D3DFMT_RGBG;
 if (Text = 'yuy2') then Result:= D3DFMT_YUY2;
 if (Text = 'grgb') then Result:= D3DFMT_GRGB;
 if (Text = 'dxt1') then Result:= D3DFMT_DXT1;
 if (Text = 'dxt2') then Result:= D3DFMT_DXT2;
 if (Text = 'dxt3') then Result:= D3DFMT_DXT3;
 if (Text = 'dxt4') then Result:= D3DFMT_DXT4;
 if (Text = 'dxt5') then Result:= D3DFMT_DXT5;

 if (Text = 'q16w16v16u16') then Result:= D3DFMT_Q16W16V16U16;
 if (Text = 'multi2_argb8') then Result:= D3DFMT_MULTI2_ARGB8;
 if (Text = 'r16f') then Result:= D3DFMT_R16F;
 if (Text = 'g16r16f') then Result:= D3DFMT_G16R16F;
 if (Text = 'a16b16g16r16f') then Result:= D3DFMT_A16B16G16R16F;
 if (Text = 'r32f') then Result:= D3DFMT_R32F;
 if (Text = 'g32r32f') then Result:= D3DFMT_G32R32F;
 if (Text = 'a32b32g32r32f') then Result:= D3DFMT_A32B32G32R32F;
 if (Text = 'cxv8u8') then Result:= D3DFMT_CxV8U8;
end;

//---------------------------------------------------------------------------
function ParseImageType(const Text: string): TImageDescType;
begin
 Result:= idtImage;
 if (Text = 'surface') then Result:= idtSurface;
 if (Text = 'draft') then Result:= idtDraft;
end;

//---------------------------------------------------------------------------
function ParseFontType(const Text: string): TFontDescType;
begin
 Result:= fdtSystem;
 if (Text = 'bitmap') then Result:= fdtBitmap;
end;

//---------------------------------------------------------------------------
function ParseFontWeight(const Text: string): Cardinal;
begin
 Result:= FW_DONTCARE;

 if (Text = 'thin') then Result:= FW_THIN;
 if (Text = 'extralight') then Result:= FW_EXTRALIGHT;
 if (Text = 'ultralight') then Result:= FW_ULTRALIGHT;
 if (Text = 'light') then Result:= FW_LIGHT;
 if (Text = 'normal') then Result:= FW_NORMAL;
 if (Text = 'regular') then Result:= FW_REGULAR;
 if (Text = 'medium') then Result:= FW_MEDIUM;
 if (Text = 'semibold') then Result:= FW_SEMIBOLD;
 if (Text = 'demibold') then Result:= FW_DEMIBOLD;
 if (Text = 'bold') then Result:= FW_BOLD;
 if (Text = 'extrabold') then Result:= FW_EXTRABOLD;
 if (Text = 'ultrabold') then Result:= FW_ULTRABOLD;
 if (Text = 'heavy') then Result:= FW_HEAVY;
 if (Text = 'black') then Result:= FW_BLACK;
end;

//---------------------------------------------------------------------------
function ParseFontCharset(const Text: string): Cardinal;
begin
 Result:= DEFAULT_CHARSET;

 if (Text = 'ansi') then Result:= ANSI_CHARSET;
 if (Text = 'arabic') then Result:= ARABIC_CHARSET;
 if (Text = 'baltic') then Result:= BALTIC_CHARSET;
 if (Text = 'chinesebig5') then Result:= CHINESEBIG5_CHARSET;
 if (Text = 'easteurope') then Result:= EASTEUROPE_CHARSET;
 if (Text = 'gb2312') then Result:= GB2312_CHARSET;
 if (Text = 'greek') then Result:= GREEK_CHARSET;
 if (Text = 'hangul') then Result:= HANGUL_CHARSET;
 if (Text = 'hangeul') then Result:= HANGEUL_CHARSET;
 if (Text = 'hebrew') then Result:= HEBREW_CHARSET;
 if (Text = 'johab') then Result:= JOHAB_CHARSET;
 if (Text = 'mac') then Result:= MAC_CHARSET;
 if (Text = 'oem') then Result:= OEM_CHARSET;
 if (Text = 'russian') then Result:= RUSSIAN_CHARSET;
 if (Text = 'shiftjis') then Result:= SHIFTJIS_CHARSET;
 if (Text = 'symbol') then Result:= SYMBOL_CHARSET;
 if (Text = 'turkish') then Result:= TURKISH_CHARSET;
 if (Text = 'vietnamese') then Result:= VIETNAMESE_CHARSET;
end;

//---------------------------------------------------------------------------
function ParseFontQuality(const Text: string): Cardinal;
begin
 Result:= DEFAULT_QUALITY;

 if (Text = 'antialiased') then Result:= ANTIALIASED_QUALITY;
 if (Text = 'cleartype') then Result:= CLEARTYPE_QUALITY;
 if (Text = 'draft') then Result:= DRAFT_QUALITY;
 if (Text = 'nonantialiased') then Result:= NONANTIALIASED_QUALITY;
 if (Text = 'proof') then Result:= PROOF_QUALITY;
end;

//---------------------------------------------------------------------------
end.
