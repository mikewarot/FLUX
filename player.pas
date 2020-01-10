(* NPC stats and setup *)

unit player;

{$mode objfpc}{$H+}

interface

uses
  crt, map;

type
  Creature = record            // Store information about player
    currentHP, maxHP, posX, posY: smallint;
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
begin
  tui.displayMessage('You hit the ' + entities.entityList[npcID].race);
  entities.entityList[npcID].isAttacked := True;
end;

end.
