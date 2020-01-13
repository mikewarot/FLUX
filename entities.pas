(* NPC stats and setup *)

unit entities;

{$mode objfpc}{$H+}

interface

uses
  crt, SysUtils, map, dungeon;

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
  entityList: array of Creature;
  npcAmount, listLength: smallint;

(* Generate list of creatures on the map *)
procedure spawnNPC();
(* Create a Gribbly *)
procedure createGribbly(uniqueid, npcx, npcy: integer);
(* Move NPC's *)
procedure move_npc(id, newX, newY: smallint);

implementation

procedure spawnNPC();
var
  i, p: integer;
begin
  // get number of NPCs
  npcAmount := (dungeon.totalRooms - 2) div 2;
  // initialise array, 1 based
  SetLength(entityList, 1);
  p := 2; // used to space out NPC location
  // place the NPCs
  for i := 1 to npcAmount do
  begin
    createGribbly(i, dungeon.centreList[p + 2].x, dungeon.centreList[p + 2].y);
    Inc(p);
  end;
end;

procedure createGribbly(uniqueid, npcx, npcy: integer);
begin
  // Add a new entry to list of creatures
  listLength := length(entityList);
  SetLength(entityList, listLength + 1);
  entityList[listLength].npcID := uniqueid;
  entityList[listLength].race := 'Gribbly';
  entityList[listLength].glyph := 'g';
  entityList[listLength].glyphColour := 2;
  entityList[listLength].currentHP := 10;
  entityList[listLength].maxHP := 10;
  entityList[listLength].inView := False;
  entityList[listLength].isAttacked := False;
  entityList[listLength].attitudeToPlayer := 'neutral';
  entityList[listLength].healthDescription := 'healthy';
  entityList[listLength].posX := npcx;
  entityList[listLength].posY := npcy;
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
