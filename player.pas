(* NPC stats and setup *)

unit player;

{$mode objfpc}{$H+}{$R+}

interface

uses
  crt, SysUtils, map, globalutils;

type
  Creature = record            // Store information about player
    currentHP, maxHP, attack, defense, posX, posY: smallint;
    glyph: char;
    glyphColour: byte;
  end;

var
  ThePlayer: Creature;

(* Place player on game map *)
procedure spawn_player(spx, spy: smallint);
(* Move the player *)
procedure move_player(newX, newY: smallint);
(* Attack NPC *)
procedure combat(npcID: smallint);

implementation

uses
  main, tui, entities;

procedure spawn_player(spx, spy: smallint);
begin
  ThePlayer.glyph := '@';
  ThePlayer.glyphColour := 14;
  ThePlayer.currentHP := 20;
  ThePlayer.maxHP := 20;
  ThePlayer.attack := 5;
  ThePlayer.defense := 2;
  ThePlayer.posX := spx;
  ThePlayer.posY := spy;
  main.playerX := spx;
  main.PlayerY := spy;
  GotoXY(ThePlayer.posX, ThePlayer.posY);
  TextColor(ThePlayer.glyphColour);
  Write(ThePlayer.glyph);
  //clear_vision();
  map.FOV(spx, spy);
end;

procedure move_player(newX, newY: smallint);
begin
  (* repaint any tiles not in FOV *)
  map.removeFOV();
  map.clear_vision();
  (* delete old position *)
  GotoXY(ThePlayer.posX, ThePlayer.posY);
  TextBackground(map.DefaultBKGcol);
  TextColor(map.DefaultTXTcol);
  Write(map.get_tile_glyph(ThePlayer.posX, ThePlayer.posY));
  (* mark tile as unoccupied *)
  map.unoccupy(ThePlayer.posX, ThePlayer.posY);
  (* update new position *)
  ThePlayer.posX := newX;
  ThePlayer.posY := newY;
  (* mark tile as occupied *)
  map.occupy(newX, newY);
  (* redraw player *)
  GotoXY(ThePlayer.posX, ThePlayer.posY);
  TextColor(ThePlayer.glyphColour);
  Write(ThePlayer.glyph);
  (* Field of View *)
  map.FOV(ThePlayer.posX, ThePlayer.posY);
end;

procedure combat(npcID: smallint);
var
  damageAmount: integer;
begin
  damageAmount := globalutils.randomRange(1, ThePlayer.attack) - entities.entityList[npcID].defense;
  if damageAmount > 0 then
  begin
    entities.entityList[npcID].currentHP := (entities.entityList[npcID].currentHP - damageAmount);
    if entities.entityList[npcID].currentHP < 1 then
    begin
      tui.displayMessage('You kill the ' + entities.entityList[npcID].race);
      // NPC will be deleted from array at the end of the game loop
      entities.entityList[npcID].isDead:= True;
      entities.entityList[npcID].glyph:= '%';
      map.unoccupy(entities.entityList[npcID].posX, entities.entityList[npcID].posY);
      exit;
    end
    else
      tui.displayMessage('You hit the ' + entities.entityList[npcID].race +
        ' for ' + IntToStr(damageAmount) + ' HP.');
  end
  else
  tui.displayMessage('You miss');
end;

end.
