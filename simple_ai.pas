(* Simple AI with random movement *)

unit simple_ai;

{$mode objfpc}{$H+}{$R+}

interface

uses
  crt, entities, map, tui, pathfinding, player, SysUtils;

(* NPC takes a turn *)
procedure takeTurn(id, spx, spy: smallint);
(* Move in a random direction *)
procedure wander(id, spx, spy: smallint);
(* Combat *)
procedure combat(id, spx, spy: smallint);

implementation


procedure takeTurn(id, spx, spy: smallint);
begin
  if (entities.entityList[id].isAttacked = True) then
    combat(id, spx, spy)
  else
    wander(id, spx, spy);
end;


procedure wander(id, spx, spy: smallint);
var
  direction, attempts, testx, testy: smallint;
begin
  attempts := 0;
  repeat
    // Reset values after each failed loop so they don't keep dec/incrementing
    testx := spx;
    testy := spy;
    direction := random(6);
    // limit the number of attempts to move so the game doesn't hang if NPC is stuck
    Inc(attempts);
    if attempts > 10 then
    begin
      entities.move_npc(id, spx, spy);
      exit;
    end;
    case direction of
      0: Dec(testy);
      1: Inc(testy);
      2: Dec(testx);
      3: Inc(testx);
      4: testx := spx;
      5: testy := spy;
    end
  until (map.can_move(testx, testy) = True) and (map.isOccupied(testx, testy) = False);
  entities.move_npc(id, testx, testy);
end;

procedure combat(id, spx, spy: smallint);
var
  newX, newY: smallint;
begin
  newX := getX(spx, spy, player.ThePlayer.posX, player.ThePlayer.posY);
  newY := getY(spx, spy, player.ThePlayer.posX, player.ThePlayer.posY);
  if (map.hasPlayer(newX, newY) = True) then
  begin
    tui.displayMessage('Gribbly ' + IntToStr(id) + ' hits back!');
    entities.move_npc(id, spx, spy);
    exit;
  end;
  if (map.can_move(newX, newY) = True) and (map.isOccupied(newX, newY) = False) then
  begin
    entities.move_npc(id, newX, newY);
    exit;
  end
  else
  begin
    entities.move_npc(id, spx, spy);
    exit;
  end;
end;

end.
