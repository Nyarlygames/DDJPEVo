unit MoteurSound;

interface

uses
  dialogs,SysUtils, fmod, fmodtypes;


var
  music : PFSOUNDSTREAM ;
  MouseDown: boolean;

implementation

begin
//initialisation de FMOD ( nb Hz / nb canaux dispos / flags? mais osef )
FSOUND_Init(44100, 42, 0);

//on charge la musique ( nom fichier / osef ^^ / debut de la ziq / jusqu'ou )
music := FSOUND_Stream_Open('phoenix.mp3',FSOUND_LOOP_NORMAL,0,0) ;

//activation de la boucle ( musique / positif = nb repet, neg = infini )
FSOUND_Stream_SetLoopCount(music, 1);

//on joue la musique ( FMOD choisi un canal, musique en question )
FSOUND_Stream_play( FSOUND_FREE, music ) ;

//on commence en pause
FSOUND_SetPaused(FSOUND_ALL, true ) ;

//changer le volume ( sur tous les canaux / entre 0 et 256 )
FSOUND_SetVolume(FSOUND_ALL, 255);

end.

