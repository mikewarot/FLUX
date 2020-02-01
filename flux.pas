(* Small console roguelike for Linux and Windows.
   @author (Chris Hawkins)
*)

program flux;

{$mode objfpc}{$H+}

uses {$IFDEF LINUX}
  unix,
 {$IFDEF UseCThreads}cthreads,
 {$ENDIF} {$ENDIF} {$IFDEF WINDOWS}Windows, {$ENDIF}
  SysUtils,
  crt,
  Math,
  tui,
  map,
  main,
  simple_ai,
  player,
  pathfinding,
  dungeon,
  globalutils;

var
  menuOption: char;

begin
  Randomize;
  {$IFDEF WINDOWS}
  SetConsoleTitle('FLUX - Roguelike');
  cursoroff; // Hides the cursor on Windows
  {$ENDIF}
  TextBackground(0);
  clrscr;
  {$IFDEF Linux}
  fpSystem('tput civis'); // Hides the cursor on Linux
  {$ENDIF}
  (* Title screen *)
  GoToXY(38, 12);
  TextColor(LightGray);
  Write('FLUX');
  GoToXY(25, 14);
  Write('Free pascaL rogUelike eXample');
  TextBackground(LightGray);
  TextColor(Black);
  GoToXY(25, 14);
  Write('F');
  GoToXY(35, 14);
  Write('L');
  GoToXY(40, 14);
  Write('U');
  GoToXY(48, 14);
  Write('X');
  TextColor(7);
  TextBackground(0);
  (* Check for previous save file *)
  if FileExists(globalutils.saveFile) then
  begin
    repeat
      GotoXY(15, 23);
      Write('''C'' - Continue last saved game | ''N'' - New game');
      menuOption := readkey;
      while KeyPressed do
        ReadKey;
    until (UpperCase(menuOption) = 'N') or (UpperCase(menuOption) = 'C');
    if (UpperCase(menuOption) = 'N') then
      main.newGame;
    if (UpperCase(menuOption) = 'C') then
      main.continueGame;
  end
  else
  begin
    (* Setup new game *)
    repeat
      GotoXY(15, 23);
      Write('''N'' - Start a New game');
      menuOption := readkey;
      while KeyPressed do
        ReadKey;
    until (UpperCase(menuOption) = 'N');
    main.newGame;
  end;
  (* Game Loop *)
  main.waitForInput();
  (* exit game *)
  globalUtils.saveGame;
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
