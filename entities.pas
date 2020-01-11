(* NPC stats and setup *)

unit entities;

{$mode objfpc}{$H+}

interface

uses
  crt, SysUtils, map, dungeon;

const
  NPC_AMOUNT = 2;

type
  (* Store information about NPC's *)
  Creature = record
    (* Unique ID *)
    npcID: smallint;
    (* Create type *)
    race: shortstring;
    (* health and position on game map *)
    currentHP, maxHP, posX, posY: smallint;
    (* Character used to represent NPC on game map *)
    glyph: char;
    (* Colour of character on screen *)
    glyphColour: byte;
    (* Is the NPC in the players FoV *)
    inView: boolean;
    (* Is the NPC being attacked *)
    isAttacked: boolean;
    (* Whether the NPC is hostile / neutral or friendly to the player *)
    attitudeToPlayer: string;
    (* Whether the NPC is healthy / injured / badly injured *)
    healthDescription: string;
  end;

var
  Grib: Creature;
  entityList: array[1..NPC_AMOUNT] of Creature;

(* Generate list of creatures on the map *)
procedure spawnNPC();
(* Move NPC's *)
procedure move_npc(id, newX, newY: smallint);

implementation

procedure spawnNPC();
var
  i: smallint;
begin
  for i := 1 to NPC_AMOUNT do
  begin
    entityList[i].npcID := 1;
    entityList[i].race := 'Gribbly';
    entityList[i].glyph := 'g';
    entityList[i].glyphColour := 2;
    entityList[i].currentHP := 10;
    entityList[i].maxHP := 10;
    entityList[i].inView := False;
    entityList[i].isAttacked := False;
    entityList[i].attitudeToPlayer := 'neutral';
    entityList[i].healthDescription := 'healthy';
    // temporarily place 2 creatures in last room
    entityList[i].posX := dungeon.centreList[i+1].x;
    entityList[i].posY := dungeon.centreList[i+1].y;
   // GotoXY(entityList[i].posX, entityList[i].posY);
   // TextColor(entityList[i].glyphColour);
   // Write(entityList[i].glyph);
  end;
end;

procedure move_npc(id, newX, newY: smallint);
begin
  (* delete old position *)
  if entityList[id].inView = True then
  begin
    GotoXY(entityList[id].posX, entityList[id].posY);
    TextBackground(map.DefaultBKGcol);
    TextColor(map.DefaultTXTcol);
    Write(map.get_tile_glyph(entityList[id].posX, entityList[id].posY));
  end;
  (* mark tile as unoccupied *)
  map.unoccupy(entityList[id].posX, entityList[id].posY);
  (* update new position *)
  entityList[id].posX := newX;
  entityList[id].posY := newY;
  (* mark tile as occupied *)
  map.occupy(newX, newY);
  (* Check if NPC in players FoV *)
  if (map.canSee(newX, newY) = True) then
  begin
    (* redraw NPC *)
    entityList[id].inView := True;
    GotoXY(entityList[id].posX, entityList[id].posY);
    TextColor(entityList[id].glyphColour);
    Write(entityList[id].glyph);
  end
  else
    Grib.inView := False;
end;

end.
