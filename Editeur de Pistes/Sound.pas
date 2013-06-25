unit Sound;

interface

uses
   fmod, fmodtypes;

var
  phoenix :PFSOUNDSTREAM ;

procedure InitSound () ;

implementation

procedure InitSound () ;
  begin
    FSOUND_Init(44100, 32, 0) ;
    phoenix := FSOUND_Stream_Open('Phoenix - If I Ever Feel Better.mp3', 0, 0, 0);
    FSOUND_Stream_play( FSOUND_FREE, phoenix ) ;
    FSOUND_SetPaused(FSOUND_ALL, true ) ;
  end;

end.
