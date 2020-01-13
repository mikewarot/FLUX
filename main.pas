(* Contains the main game loop *)

unit main;

{$mode objfpc}{$H+}

interface

uses
  crt;

type
  TDirection = (moveUP, moveLEFT, moveRIGHT, moveDOWN);

var
  moveCH: char;
  Dir: TDirection;
  playerX, playerY: smallint;

(* New game setup *)
procedure gameStart();
(* Waits for player input *)
procedure wait_for_input();
(* Handles NPC movement after player moves *)
procedure gameLoop();
(* Check if tile is occupied by an NPC *)
function combatCheck(x, y: smallint): boolean;

implementation

uses
  tui,
  player,
  entities,
  simple_ai,
  map,
  dungeon;

(* Each movement is triggered by an individual keypress as the game is turn based *)
procedure wait_for_input();
var
  oldX, oldY: smallint;
begin
  Dir := moveDown;
  repeat
    moveCH := ReadKey;
    if moveCH = #0 then
      moveCH := ReadKey;
    case moveCH of
      #72: Dir := moveUP;
      #75: Dir := moveLEFT;
      #77: Dir := moveRIGHT;
      #80: Dir := moveDOWN;
    end;
    (* Set original values in case player cannot move *)
    oldX := playerX;
    oldY := playerY;
    case Dir of
      moveUP: Dec(playerY);
      moveDOWN: Inc(playerY);
      moveLEFT: Dec(playerX);
      moveRIGHT: Inc(playerX);
    end;
    (* check if tile is occupied *)
    if (map.isOccupied(playerX, playerY) = True) then
      if (combatCheck(playerX, playerY) = True) then
      begin
        playerX := oldX;
        playerY := oldY;
        map.FOV(oldX, oldY);
        tui.UpdateHP;
        gameLoop();
      end;
    (* check if tile is a floor tile *)
    if (map.can_move(playerX, playerY) = True) then
    begin
      player.move_player(playerX, playerY);
      tui.UpdateHP;
      gameLoop();
    end
    else
    begin
      playerX := oldX;
      playerY := oldY;
      map.FOV(oldX, oldY);
      tui.UpdateHP;
      tui.displayMessage('<bump>');
      gameLoop();
    end
  until UpCase(moveCH) = 'Q';
end;

procedure gameStart();
begin
  (* Draw the title screen *)
  tui.title_screen;
  (* Set up the map *)
  map.setup_map;
  (* wait for a keypress *)
  readkey;
  clrscr;
  (* Draw the UI *)
  tui.draw_sidepanel;
  (* Create NPC's *)
  entities.spawnNPC();
  (* Add the player *)
  playerX := dungeon.startX;
  playerY := dungeon.startY;
  player.spawn_player(playerX, playerY);
  tui.UpdateHP;
end;

procedure gameLoop();
var
  i: smallint;
begin
  for i := 1 to entities.npcAmount do
    simple_ai.takeTurn(i, entities.entityList[i].posX, entities.entityList[i].posY);
end;

function combatCheck(x, y: smallint): boolean;
var
  i: smallint;
begin
  Result := False;
  for i := 1 to entities.npcAmount do
  begin
    if (x = entities.entityList[i].posX) then
    begin
      if (y = entities.entityList[i].posY) then
      begin
        player.combat(i);
        Result := True;
      end;
    end;
  end;
end;

end.

