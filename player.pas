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
procedure spawnPlayer(spx, spy: smallint);
(* Move the player *)
procedure movePlayer(newX, newY: smallint);
(* Attack NPC *)
procedure combat(npcID: smallint);

implementation

uses
  main, tui, entities;

procedure spawnPlayer(spx, spy: smallint);
begin
  with ThePlayer do
  begin
    glyph := '@';
    glyphColour := 14;
    currentHP := 20;
    maxHP := 20;
    attack := 5;
    defense := 2;
    posX := spx;
    posY := spy;
  end;
  main.playerX := spx;
  main.PlayerY := spy;
  GotoXY(ThePlayer.posX, ThePlayer.posY);
  TextColor(ThePlayer.glyphColour);
  Write(ThePlayer.glyph);
  //clear_vision();
  map.FOV(spx, spy);
end;

procedure movePlayer(newX, newY: smallint);
begin
  (* repaint any tiles not in FOV *)
  map.removeFOV();
  map.clearVision();
  (* delete old position *)
  GotoXY(ThePlayer.posX, ThePlayer.posY);
  TextBackground(map.DefaultBKGcol);
  TextColor(map.DefaultTXTcol);
  Write(map.getTileGlyph(ThePlayer.posX, ThePlayer.posY));
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
  damageAmount: smallint;
begin
  damageAmount := globalutils.randomRange(1, ThePlayer.attack) -
    entities.entityList[npcID].defense;
  if damageAmount > 0 then
  begin
    entities.entityList[npcID].currentHP :=
      (entities.entityList[npcID].currentHP - damageAmount);
    if entities.entityList[npcID].currentHP < 1 then
    begin
      tui.displayMessage('You kill the ' + entities.entityList[npcID].race);
      entities.entityList[npcID].isDead := True;
      entities.entityList[npcID].glyph := '%';
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
