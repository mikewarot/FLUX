(* Contains the main game loop *)

unit main;

{$mode objfpc}{$H+}{$R+}

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
procedure newGame;
(* Continue a saved game *)
procedure continueGame;
(* Waits for player input *)
procedure waitForInput;
(* Handles NPC movement after player moves *)
procedure gameLoop;
(* Check if tile is occupied by an NPC *)
function combatCheck(x, y: smallint): boolean;

implementation

uses
  tui,
  player,
  entities,
  simple_ai,
  map,
  dungeon,
  globalutils;

procedure continueGame;
begin
  (* Set random seed *)
  {$IFDEF Linux}
  RandSeed := RandSeed shl 8;
  {$ENDIF}
  {$IFDEF Windows}
  RandSeed := ((RandSeed shl 8) or GetCurrentProcessID) xor GetTickCount64;
  {$ENDIF}
  globalutils.loadGame;
  clrscr;
  map.loadMap;
  (* Draw the UI *)
  tui.drawSidepanel;
  (* Set up player *)
  //player.ThePlayer.glyph:='@';
  //player.ThePlayer.glyphColour := 14;
  //playerX := player.ThePlayer.posX;
  //playerY := player.ThePlayer.posY;
  //GotoXY(playerX, playerY);
  //TextColor(player.ThePlayer.glyphColour);
  //Write(player.ThePlayer.glyph);
  player.spawnPlayer(player.ThePlayer.posX, player.ThePlayer.posY);

  //map.FOV(playerX, playerY);

  entities.redrawNPC;

  tui.UpdateHP;
end;

(* Each movement is triggered by an individual keypress as the game is turn based *)
procedure waitForInput;
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
    if (map.canMove(playerX, playerY) = True) then
    begin
      player.movePlayer(playerX, playerY);
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

procedure newGame;
begin
  (* Set random seed *)
  {$IFDEF Linux}
  RandSeed := RandSeed shl 8;
  {$ENDIF}
  {$IFDEF Windows}
  RandSeed := ((RandSeed shl 8) or GetCurrentProcessID) xor GetTickCount64;
  {$ENDIF}
  (* Set up the map *)
  map.setupMap;
  clrscr;
  (* Draw the UI *)
  tui.drawSidepanel;
  (* Create NPC's *)
  entities.spawnNPC();
  (* Add the player *)
  playerX := dungeon.startX;
  playerY := dungeon.startY;
  player.spawnPlayer(playerX, playerY);
  tui.UpdateHP;
end;

procedure gameLoop;
var
  i: smallint;
begin
  for i := 1 to entities.npcAmount do
    if entities.entityList[i].isDead = False then
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
        player.combat(i);
      Result := True;
    end;
  end;
end;

end.

