(* NPC stats and setup *)

unit entities;

{$mode objfpc}{$H+}{$R+}

interface

uses
  crt, SysUtils, map, dungeon, globalutils;

type
  (* Store information about NPC's *)
  Creature = record
    (* Unique ID *)
    npcID: smallint;
    (* Create type *)
    race: shortstring;
    (* health and position on game map *)
    currentHP, maxHP, attack, defense, posX, posY: smallint;
    (* Character used to represent NPC on game map *)
    glyph: char;
    (* Colour of character on screen *)
    glyphColour: byte;
    (* Is the NPC in the players FoV *)
    inView: boolean;
    (* Has the NPC been killed, to be removed at end of game loop *)
    isDead: boolean;
  end;

var
  entityList: array of Creature;
  npcAmount, listLength: smallint;

(* Generate list of creatures on the map *)
procedure spawnNPC();
(* Create a Gribbly *)
procedure createGribbly(uniqueid, npcx, npcy: smallint);
(* Create a Booger *)
procedure createBooger(uniqueid, npcx, npcy: smallint);
(* Move NPC's *)
procedure moveNPC(id, newX, newY: smallint);

implementation

procedure spawnNPC();
var
  i, p, r: smallint;
begin
  // get number of NPCs
  npcAmount := (dungeon.totalRooms - 2) div 2;
  // initialise array, 1 based
  SetLength(entityList, 1);
  p := 2; // used to space out NPC location
  // place the NPCs
  for i := 1 to npcAmount do
  begin
    // randomly select a monster type
    r := globalutils.randomRange(0, 1);
    if r = 1 then
      createBooger(i, dungeon.centreList[p + 2].x, dungeon.centreList[p + 2].y);
    if r = 0 then
      createGribbly(i, dungeon.centreList[p + 2].x, dungeon.centreList[p + 2].y);
    Inc(p);
  end;
end;

procedure createGribbly(uniqueid, npcx, npcy: smallint);
begin
  // Add a new entry to list of creatures
  listLength := length(entityList);
  SetLength(entityList, listLength + 1);
  with entityList[listLength] do
  begin
    npcID := uniqueid;
    race := 'Gribbly';
    glyph := 'g';
    glyphColour := 2;
    currentHP := 2;
    maxHP := 10;
    attack := 3;
    defense := 2;
    inView := False;
    isDead := False;
    posX := npcx;
    posY := npcy;
  end;
end;

procedure createBooger(uniqueid, npcx, npcy: smallint);
begin
  // Add a new entry to list of creatures
  listLength := length(entityList);
  SetLength(entityList, listLength + 1);
  with entityList[listLength] do
  begin
    npcID := uniqueid;
    race := 'Booger';
    glyph := 'b';
    glyphColour := 11;
    currentHP := 5;
    maxHP := 10;
    attack := 2;
    defense := 2;
    inView := False;
    isDead := False;
    posX := npcx;
    posY := npcy;
  end;
end;

procedure moveNPC(id, newX, newY: smallint);
begin
  (* delete old position *)
  if entityList[id].inView = True then
  begin
    GotoXY(entityList[id].posX, entityList[id].posY);
    TextBackground(map.DefaultBKGcol);
    TextColor(map.DefaultTXTcol);
    Write(map.getTileGlyph(entityList[id].posX, entityList[id].posY));
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
    entityList[id].inView := False;
end;

end.
