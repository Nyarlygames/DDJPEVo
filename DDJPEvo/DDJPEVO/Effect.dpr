Program Effect;

  Uses
    Forms,
    Windows,
    DirectDraw;

  Var
    IsTerminated : Boolean ;
    MyForm : TForm ;
    lpDD : IDirectdraw ;
    Surface, Buffer : IDirectDrawSurface ;
    ddSD : TDDSURFACEDESC ;
    Palette : array[0..255] of PaletteEntry ;
    ddPalette : IDirectDrawPalette ;
    I : Integer ;
    X, Y, Dx, Dy : Integer ;

  Procedure Key( Sender : TObject; Var Key: Char);
    Begin
      IsTerminated:=True;
    End;

  Procedure DrawPixel(X,Y:Integer;C:Byte;Desc:TDDSurfaceDesc);
    Type
      TScreen = Array Of Byte;
      Begin
        If (X>=0) And (X<=639) And (Y>=0) And (Y<=479) Then
          Begin
            TScreen(Desc.LPSurface)[X+Y*Desc.LPitch]:=C;
          End;
      End;

  Procedure DrawRectangle(X,Y,W,H:Integer;C:Byte;Desc:TDDSurfaceDesc);
    Var
      I, J : Integer;
      Begin
        For J:=Y To Y+H-1 Do
          Begin
            For I:=X To X+W-1 Do
              Begin
                DrawPixel(I,J,C,Desc);
              End;
          End;
      End;

  Procedure Show;
    Var
      SurfaceDesc : TDDSurfaceDesc ;
      Begin
        SurfaceDesc.dwSize:=SizeOf(SurfaceDesc);
        If Buffer.Lock(Nil,SurfaceDesc,0,0)<>DD_OK Then
          Begin
            IsTerminated:=True;
            Exit;
          End;
        Inc(X,Dx);Inc(Y,Dy);
        If (X<0) Or (X>639-50) Then
          Begin
            Dx := -Dx ;
            Inc(X,Dx) ;
          End;
        If (Y<0) Or (Y>479-50) Then
          Begin
            Dy:=-Dy;
            Inc(Y,Dy);
          End;
        FillChar(SurfaceDesc.LPSurface^,480*SurfaceDesc.LPitch,0);
        DrawRectangle(X,Y,50,50,255,SurfaceDesc);
        Buffer.UnLock(SurfaceDesc.LPSurface);
        lpDD.WaitForVerticalBlank(DDWAITVB_BLOCKBEGIN,0);
        Surface.Flip(Nil,0);
      End;

  Begin
    IsTerminated := False;
    MyForm:=TForm.Create(Nil);
    MyForm.BorderStyle := bsNone;
    @MyForm.OnKeyPress := @Key;
    MyForm.Show;

  If DirectDrawCreate(Nil,lpDD,Nil)<>DD_OK Then
    Exit;
  If lpDD.SetCooperativeLevel(MyForm.Handle,DDSCL_EXCLUSIVE OR DDSCL_FULLSCREEN OR DDSCL_ALLOWMODEX OR DDSCL_ALLOWREBOOT)<>DD_OK Then
    Exit;
  If lpDD.SetDisplayMode(640,480,8)<>DD_OK Then
    Exit;
    Fillchar(ddSD,SizeOf(ddSD),0);
    ddSD.dwSize := SizeOf(ddSD);
    ddSD.dwflags := ddSD_caps or ddSD_backbuffercount;
    ddSD.ddscaps.dwcaps := ddscaps_primarysurface or ddscaps_systemmemory or ddscaps_complex or ddscaps_flip;
    ddSD.dwbackbuffercount := 1;
    If lpDD.CreateSurface(ddSD,Surface,Nil)<>DD_OK Then
      Exit;
      ddSD.ddscaps.dwCaps := DDSCAPS_BACKBUFFER;
    If Surface.GetAttachedSurface(ddSD.ddscaps,Buffer)<>DD_OK Then
      Exit;
  For I:=0 To 255 Do
    Begin
      Palette[I].peRed:=I;
      Palette[I].peGreen:=I;
      Palette[I].peBlue:=I;
    End;
  If lpDD.CreatePalette(DDPCAPS_8BIT,@Palette,ddPalette,Nil)<>DD_OK Then
    Exit;
    Surface.SetPalette(ddPalette);
    ShowCursor(False);
    MyForm.WindowState:=wsMaximized;

X:=0;
Y:=0;
Dx:=1;
Dy:=1;

  Repeat
    Show;
    Application.ProcessMessages;
  Until IsTerminated;
    MyForm.Hide;
    lpDD.RestoreDisplayMode;
    ShowCursor(True);
    ddPalette:=nil;
    Buffer:=nil;
    Surface:=nil;
    lpDD:=nil;
    MyForm.Release;
End.
