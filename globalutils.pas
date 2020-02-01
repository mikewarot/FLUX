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
  randomSeed: integer;

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
  Doc: TXMLDocument;
  RootNode, dataNode, ItemNode, TextNode: TDOMNode;
begin
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
        ItemNode := Doc.CreateElement('character');
        TextNode := Doc.CreateTextNode(map.maparea[r][c].character);
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
      ItemNode := Doc.CreateElement('glyph');
      TextNode := Doc.CreateTextNode(entities.entityList[i].glyph);
      ItemNode.AppendChild(TextNode);
      dataNode.AppendChild(ItemNode);
      ItemNode := Doc.CreateElement('glyphColour');
      TextNode := Doc.CreateTextNode(IntToStr(entities.entityList[i].glyphColour));
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
  hiColour, defColour, PlayerNode, NPCnode, RaceNode, GlyphNode,
  GColourNode, CurrentHPnode, MaxHPnode, AttackNode, DefenseNode,
  ViewNode, DeadNode, PosX, PosY, characterNode: TDOMNode;
  Doc: TXMLDocument;
  r, c, i: integer;
begin
  try
    // Read in xml file from disk
    ReadXMLFile(Doc, saveFile);
    // Retrieve the nodes
    RootNode := Doc.DocumentElement.FindNode('GameData');
    (* Random Seed *)
    //RandSeed := StrToInt(RootNode.FirstChild.TextContent);
    ParentNode := RootNode.FirstChild.NextSibling;
    (* NPC amount *)
    entities.npcAmount := StrToInt(ParentNode.TextContent);
    (* Map tile data *)
    Tile := RootNode.NextSibling;
    for r := 1 to MAXROWS do
    begin
      for c := 1 to MAXCOLUMNS do
      begin
        map.maparea[r][c].id := StrToInt(Tile.Attributes.Item[0].NodeValue);
        Blocks := Tile.FirstChild;
        map.maparea[r][c].blocks := StrToBool(Blocks.TextContent);
        Visible := Blocks.NextSibling;
        map.maparea[r][c].Visible := StrToBool(Visible.TextContent);
        Occupied := Visible.NextSibling;
        map.maparea[r][c].occupied := StrToBool(Occupied.TextContent);
        defColour := Occupied.NextSibling;
        map.maparea[r][c].defColour := StrToInt(defColour.TextContent);
        hiColour := defColour.NextSibling;
        map.maparea[r][c].hiColour := StrToInt(hiColour.TextContent);
        characterNode := hiColour.NextSibling;
        // Convert String to Char
        map.maparea[r][c].character := characterNode.TextContent[1];

        NextNode := Tile.NextSibling;
        Tile := NextNode;
      end;
    end;
    (* Player info *)
    PlayerNode := Doc.DocumentElement.FindNode('Player');
    player.ThePlayer.currentHP := StrToInt(PlayerNode.FirstChild.TextContent);
    player.ThePlayer.maxHP := StrToInt(PlayerNode.FirstChild.NextSibling.TextContent);
    NextNode := PlayerNode.FirstChild.NextSibling;
    player.ThePlayer.attack := StrToInt(NextNode.NextSibling.TextContent);
    ParentNode := NextNode.NextSibling;
    player.ThePlayer.defense := StrToInt(ParentNode.NextSibling.TextContent);
    NextNode := ParentNode.NextSibling;
    player.ThePlayer.posX := StrToInt(NextNode.NextSibling.TextContent);
    ParentNode := NextNode.NextSibling;
    player.ThePlayer.posY := StrToInt(NextNode.NextSibling.TextContent);
    (* NPC stats *)
    SetLength(entities.entityList, 1);
    NPCnode := PlayerNode.NextSibling;
    for i := 1 to entities.npcAmount do
    begin
      entities.listLength := length(entities.entityList);
      SetLength(entities.entityList, entities.listLength + 1);
      entities.entityList[i].npcID :=
        StrToInt(NPCnode.Attributes.Item[0].NodeValue);
      RaceNode := NPCnode.FirstChild;
      entities.entityList[i].race := RaceNode.TextContent;
      GlyphNode := RaceNode.NextSibling;
      entities.entityList[i].glyph := GlyphNode.TextContent[1];
      GColourNode := GlyphNode.NextSibling;
      entities.entityList[i].glyphColour := StrToInt(GColourNode.TextContent);
      CurrentHPnode := GColourNode.NextSibling;
      entities.entityList[i].currentHP := StrToInt(CurrentHPnode.TextContent);
      MaxHPnode := CurrentHPnode.NextSibling;
      entities.entityList[i].maxHP := StrToInt(MaxHPnode.TextContent);
      AttackNode := MaxHPnode.NextSibling;
      entities.entityList[i].attack := StrToInt(AttackNode.TextContent);
      DefenseNode := AttackNode.NextSibling;
      entities.entityList[i].defense := StrToInt(DefenseNode.TextContent);
      ViewNode := DefenseNode.NextSibling;
      entities.entityList[i].inView := StrToBool(ViewNode.TextContent);
      DeadNode := ViewNode.NextSibling;
      entities.entityList[i].isDead := StrToBool(DeadNode.TextContent);
      PosX := DeadNode.NextSibling;
      entities.entityList[i].posX := StrToInt(PosX.TextContent);
      PosY := PosX.NextSibling;
      entities.entityList[i].posY := StrToInt(PosY.TextContent);
      ParentNode := NPCnode.NextSibling;
      NPCnode := ParentNode;
    end;

  finally
    // finally, free the document
    Doc.Free;
  end;
end;

end.
