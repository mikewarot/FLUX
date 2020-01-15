(* Small console roguelike for Linux and Windows.
   @author (Chris Hawkins)
*)

program flux;

{$mode objfpc}{$H+}

uses {$IFDEF LINUX}
  unix,
 {$IFDEF UseCThreads}cthreads,
 {$ENDIF} {$ENDIF} {$IFDEF WINDOWS}Windows, {$ENDIF}
  crt,
  Math,
  map,
  main,
  simple_ai,
  player,
  pathfinding,
  dungeon,
  globalutils;

begin
  (* Set random seed *)
  Randomize;
  {$IFDEF Linux}
  RandSeed := RandSeed shl 8;
  {$ENDIF}
  {$IFDEF Windows}
  RandSeed := ((RandSeed shl 8) or GetCurrentProcessID) xor GetTickCount64;
  {$ENDIF}
  {$IFDEF WINDOWS}
  SetConsoleTitle('FLUX - Roguelike');
  cursoroff; // Hides the cursor on Windows
  {$ENDIF}
  TextBackground(0);
  clrscr;
  {$IFDEF Linux}
  fpSystem('tput civis'); // Hides the cursor on Linux
  {$ENDIF}
  (* Setup new game *)
  main.gameStart();
  (* Game Loop *)
  main.wait_for_input();
  (* exit game *)
  {$IFDEF WINDOWS}
  cursoron; // Unhides the cursor on Windows
  {$ENDIF}
  {$IFDEF Linux}
  fpSystem('tput cnorm'); // Unhides the cursor on Linux
  {$ENDIF}
  TextBackground(0);
  TextColor(7);
  clrscr;
  writeln('FLUX -  Free pascaL rogUelike eXample...');
end.
