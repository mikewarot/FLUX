(* Simple AI with random movement *)

unit simple_ai;

{$mode objfpc}{$H+}{$R+}

interface

uses
  crt, entities, map, tui, pathfinding, player, SysUtils, globalutils;

(* NPC takes a turn *)
procedure takeTurn(id, spx, spy: smallint);
(* Move in a random direction *)
procedure wander(id, spx, spy: smallint);
(* Chase the player *)
procedure chasePlayer(id, spx, spy: smallint);
(* Combat *)
procedure combat(id: smallint);

implementation


procedure takeTurn(id, spx, spy: smallint);
begin
  // check if NPC is in players FoV
  if (map.canSee(spx, spy) = True) then
    chasePlayer(id, spx, spy)
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

procedure chasePlayer(id, spx, spy: smallint);
var
  newX, newY: smallint;
begin
  newX := pathfinding.getX(spx, spy, player.ThePlayer.posX, player.ThePlayer.posY);
  newY := pathfinding.getY(spx, spy, player.ThePlayer.posX, player.ThePlayer.posY);
  if (map.hasPlayer(newX, newY) = True) then
  begin
    entities.move_npc(id, spx, spy);
    combat(id);
  end
  else
    entities.move_npc(id, newX, newY);
end;

procedure combat(id: smallint);
var
  damageAmount: smallint;
begin
  damageAmount := globalutils.randomRange(1, entities.entityList[id].attack) -
    player.ThePlayer.defense;
  if damageAmount > 0 then
  begin
    player.ThePlayer.currentHP := (player.ThePlayer.currentHP - damageAmount);
    if player.ThePlayer.currentHP < 1 then
    begin
      tui.displayMessage('You are dead!');
      exit;
    end
    else
      tui.displayMessage('The Gribbly attacks you for ' +
        IntToStr(damageAmount) + ' HP');
  end
  else
    tui.displayMessage('The Gribbly attacks but misses.');
end;

end.
