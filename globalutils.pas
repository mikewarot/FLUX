(* Common functions / utilities *)

unit globalutils;

{$mode objfpc}{$H+}

interface

uses
  SysUtils,
  DOM,
  XMLWrite,
  XMLRead;

const
  (* Save game file *)
  saveFile = 'fluxsave.xml';
  (* Columns of the game map *)
  MAXCOLUMNS = 67;
  (* Rows of the game map *)
  MAXROWS = 19;

var
  dungeonLoadArray: array[1..MAXROWS, 1..MAXCOLUMNS] of char;

(* Select random number from a range *)
function randomRange(fromNumber, toNumber: smallint): smallint;
(* Save game state to XML file *)
procedure saveGame;
(* Load saved game *)
procedure loadGame;

implementation

uses
  entities, player, map;

// Random(Range End - Range Start) + Range Start;
function randomRange(fromNumber, toNumber: smallint): smallint;
var
  p: smallint;
begin
  p := toNumber - fromNumber;
  Result := random(p + 1) + fromNumber;
end;

procedure saveGame;
var
  i, r, c: smallint;
  mapString: string;
  Doc: TXMLDocument;
  RootNode, dataNode, ItemNode, TextNode: TDOMNode;
begin
  mapString := map.saveMap;
  try
    // Create a document
    Doc := TXMLDocument.Create;
    // Create a root node
    RootNode := Doc.CreateElement('root');
    Doc.Appendchild(RootNode);
    RootNode := Doc.DocumentElement;
    // Create nodes

    // Game data
    dataNode := Doc.CreateElement('GameData');
    ItemNode := Doc.CreateElement('RandSeed');
    TextNode := Doc.CreateTextNode(IntToStr(RandSeed));
    ItemNode.AppendChild(TextNode);
    dataNode.AppendChild(ItemNode);
    ItemNode := Doc.CreateElement('npcAmount');
    TextNode := Doc.CreateTextNode(IntToStr(entities.npcAmount));
    ItemNode.AppendChild(TextNode);
    dataNode.AppendChild(ItemNode);

    RootNode.AppendChild(dataNode);

    // Game map
    dataNode := Doc.CreateElement('Map');
    ItemNode := Doc.CreateElement('map_area');
    TextNode := Doc.CreateTextNode(mapString);
    ItemNode.AppendChild(TextNode);
    dataNode.AppendChild(ItemNode);
    RootNode.AppendChild(dataNode);

    // map tiles
    for r := 1 to map.MAXROWS do
    begin
      for c := 1 to map.MAXCOLUMNS do
      begin
        dataNode := Doc.CreateElement('map_tiles');
        TDOMElement(dataNode).SetAttribute('id', IntToStr(maparea[r][c].id));
        ItemNode := Doc.CreateElement('blocks');
        TextNode := Doc.CreateTextNode(BoolToStr(map.maparea[r][c].blocks));
        ItemNode.AppendChild(TextNode);
        dataNode.AppendChild(ItemNode);
        ItemNode := Doc.CreateElement('Visible');
        TextNode := Doc.CreateTextNode(BoolToStr(map.maparea[r][c].Visible));
        ItemNode.AppendChild(TextNode);
        dataNode.AppendChild(ItemNode);
        ItemNode := Doc.CreateElement('occupied');
        TextNode := Doc.CreateTextNode(BoolToStr(map.maparea[r][c].occupied));
        ItemNode.AppendChild(TextNode);
        dataNode.AppendChild(ItemNode);
        ItemNode := Doc.CreateElement('defColour');
        TextNode := Doc.CreateTextNode(IntToStr(map.maparea[r][c].defColour));
        ItemNode.AppendChild(TextNode);
        dataNode.AppendChild(ItemNode);
        ItemNode := Doc.CreateElement('hiColour');
        TextNode := Doc.CreateTextNode(IntToStr(map.maparea[r][c].hiColour));
        ItemNode.AppendChild(TextNode);
        dataNode.AppendChild(ItemNode);
        RootNode.AppendChild(dataNode);
      end;
    end;
    // Player record
    dataNode := Doc.CreateElement('Player');
    ItemNode := Doc.CreateElement('currentHP');
    TextNode := Doc.CreateTextNode(IntToStr(player.ThePlayer.currentHP));
    ItemNode.AppendChild(TextNode);
    dataNode.AppendChild(ItemNode);
    ItemNode := Doc.CreateElement('maxHP');
    TextNode := Doc.CreateTextNode(IntToStr(player.ThePlayer.maxHP));
    ItemNode.AppendChild(TextNode);
    dataNode.AppendChild(ItemNode);
    ItemNode := Doc.CreateElement('attack');
    TextNode := Doc.CreateTextNode(IntToStr(player.ThePlayer.attack));
    ItemNode.AppendChild(TextNode);
    dataNode.AppendChild(ItemNode);
    ItemNode := Doc.CreateElement('defense');
    TextNode := Doc.CreateTextNode(IntToStr(player.ThePlayer.defense));
    ItemNode.AppendChild(TextNode);
    dataNode.AppendChild(ItemNode);
    ItemNode := Doc.CreateElement('posX');
    TextNode := Doc.CreateTextNode(IntToStr(player.ThePlayer.posX));
    ItemNode.AppendChild(TextNode);
    dataNode.AppendChild(ItemNode);
    ItemNode := Doc.CreateElement('posY');
    TextNode := Doc.CreateTextNode(IntToStr(player.ThePlayer.posY));
    ItemNode.AppendChild(TextNode);
    dataNode.AppendChild(ItemNode);
    RootNode.AppendChild(dataNode);
    // NPC records
    for i := 1 to entities.npcAmount do
    begin
      dataNode := Doc.CreateElement('NPC');
      TDOMElement(dataNode).SetAttribute('id', IntToStr(i));
      ItemNode := Doc.CreateElement('race');
      TextNode := Doc.CreateTextNode(entities.entityList[i].race);
      ItemNode.AppendChild(TextNode);
      dataNode.AppendChild(ItemNode);
      ItemNode := Doc.CreateElement('currentHP');
      TextNode := Doc.CreateTextNode(IntToStr(entities.entityList[i].currentHP));
      ItemNode.AppendChild(TextNode);
      dataNode.AppendChild(ItemNode);
      ItemNode := Doc.CreateElement('maxHP');
      TextNode := Doc.CreateTextNode(IntToStr(entities.entityList[i].maxHP));
      ItemNode.AppendChild(TextNode);
      dataNode.AppendChild(ItemNode);
      ItemNode := Doc.CreateElement('attack');
      TextNode := Doc.CreateTextNode(IntToStr(entities.entityList[i].attack));
      ItemNode.AppendChild(TextNode);
      dataNode.AppendChild(ItemNode);
      ItemNode := Doc.CreateElement('defense');
      TextNode := Doc.CreateTextNode(IntToStr(entities.entityList[i].defense));
      ItemNode.AppendChild(TextNode);
      dataNode.AppendChild(ItemNode);
      ItemNode := Doc.CreateElement('inView');
      TextNode := Doc.CreateTextNode(BoolToStr(entities.entityList[i].inView));
      ItemNode.AppendChild(TextNode);
      dataNode.AppendChild(ItemNode);
      ItemNode := Doc.CreateElement('isDead');
      TextNode := Doc.CreateTextNode(BoolToStr(entities.entityList[i].isDead));
      ItemNode.AppendChild(TextNode);
      dataNode.AppendChild(ItemNode);
      ItemNode := Doc.CreateElement('posX');
      TextNode := Doc.CreateTextNode(IntToStr(entities.entityList[i].posX));
      ItemNode.AppendChild(TextNode);
      dataNode.AppendChild(ItemNode);
      ItemNode := Doc.CreateElement('posY');
      TextNode := Doc.CreateTextNode(IntToStr(entities.entityList[i].posX));
      ItemNode.AppendChild(TextNode);
      dataNode.AppendChild(ItemNode);
      RootNode.AppendChild(dataNode);
    end;
    // Save XML
    WriteXMLFile(Doc, saveFile);
  finally
    Doc.Free;  // free memory
  end;
end;

procedure loadGame;
var
  RootNode, ParentNode, Tile, NextNode, Blocks, Visible, Occupied,
  hiColour, defColour, PlayerNode, NPCnode, RaceNode, CurrentHPnode,
  MaxHPnode, AttackNode, DefenseNode, ViewNode, DeadNode, PosX, PosY: TDOMNode;
  Doc: TXMLDocument;
  r, c, i, npcAmount, totalTiles: integer;
  mapData: string;
begin
  // Number of tiles in game map
  totalTiles := 1273;
  try
    // Read in xml file from disk
    ReadXMLFile(Doc, saveFile);
    // Retrieve the nodes
    RootNode := Doc.DocumentElement.FindNode('GameData');
    (* Random Seed *)
    RandSeed := StrToInt(RootNode.FirstChild.TextContent);
    ParentNode := RootNode.FirstChild.NextSibling;
    (* NPC amount *)
    entities.npcAmount := StrToInt(ParentNode.TextContent);
    (* Game Map *)
    ParentNode := Rootnode.NextSibling;
    mapData := ParentNode.FirstChild.TextContent;
    i := 1;
    for r := 1 to MAXROWS do
    begin
      for c := 1 to MAXCOLUMNS do
      begin
        dungeonLoadArray[r][c] := mapData[i];
        Inc(i);
      end;

    end;


  finally
    // finally, free the document
    Doc.Free;
  end;
end;

end.
