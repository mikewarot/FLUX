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

  procedure AddElement(Node : TDOMNode; Name,Value : String);
  var
    NameNode,ValueNode : TDomNode;
  begin
    NameNode  := Doc.CreateElement(Name);    // creates future Node/Name
    ValueNode := Doc.CreateTextNode(Value);  // creates future Node/Name/Value
    NameNode.Appendchild(ValueNode);         // place value in place
    Node.Appendchild(NameNode);              // place Name in place
  end;

  function AddChild(Node : TDOMNode; ChildName : String): TDomNode;
  Var
    ChildNode : TDomNode;
  begin
    ChildNode := Doc.CreateElement(ChildName);
    Node.AppendChild(ChildNode);
    AddChild := ChildNode;
  end;

begin
  try
    // Create a document
    Doc := TXMLDocument.Create;
    // Create a root node
    RootNode := Doc.CreateElement('root');
    Doc.Appendchild(RootNode);
    RootNode := Doc.DocumentElement;

    // Game data
    DataNode := AddChild(RootNode,'GameData');
    AddElement(datanode, 'RandSeed',IntToStr(RandSeed));
    AddElement(datanode, 'npcAmount',IntToStr(entities.npcAmount));

    // map tiles
    for r := 1 to map.MAXROWS do
    begin
      for c := 1 to map.MAXCOLUMNS do
      begin
        DataNode := AddChild(RootNode,'map_tiles');
        TDOMElement(dataNode).SetAttribute('id', IntToStr(maparea[r][c].id));
        AddElement(datanode,'blocks',BoolToStr(map.maparea[r][c].blocks));
        AddElement(datanode,'Visible',BoolToStr(map.maparea[r][c].Visible));
        AddElement(datanode,'occupied',BoolToStr(map.maparea[r][c].occupied));
        AddElement(datanode,'defColour',IntToStr(map.maparea[r][c].defColour));
        AddElement(datanode,'hiColour',IntToStr(map.maparea[r][c].hiColour));
        AddElement(datanode,'character',map.maparea[r][c].character);
      end;
    end;
    // Player record

    DataNode := AddChild(RootNode,'Player');
    AddElement(DataNode,'currentHP',IntToStr(player.ThePlayer.currentHP));
    AddElement(DataNode,'maxHP',IntToStr(player.ThePlayer.maxHP));
    AddElement(DataNode,'attack',IntToStr(player.ThePlayer.attack));
    AddElement(DataNode,'defense',IntToStr(player.ThePlayer.defense));
    AddElement(DataNode,'posX',IntToStr(player.ThePlayer.posX));
    AddElement(DataNode,'posY',IntToStr(player.ThePlayer.posY));

    // NPC records
    for i := 1 to entities.npcAmount do
    begin
      DataNode := AddChild(RootNode,'NPC');
      TDOMElement(dataNode).SetAttribute('id', IntToStr(i));
      AddElement(DataNode,'race',entities.entityList[i].race);
      AddElement(DataNode,'glyph',entities.entityList[i].glyph);
      AddElement(DataNode,'glyphColour',IntToStr(entities.entityList[i].glyphColour));
      AddElement(DataNode,'currentHP',IntToStr(entities.entityList[i].currentHP));
      AddElement(DataNode,'maxHP',IntToStr(entities.entityList[i].maxHP));
      AddElement(DataNode,'attack',IntToStr(entities.entityList[i].attack));
      AddElement(DataNode,'defense',IntToStr(entities.entityList[i].defense));
      AddElement(DataNode,'inView',BoolToStr(entities.entityList[i].inView));
      AddElement(DataNode,'isDead',BoolToStr(entities.entityList[i].isDead));
      AddElement(DataNode,'posX',IntToStr(entities.entityList[i].posX));
      AddElement(DataNode,'posY',IntToStr(entities.entityList[i].posY));
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
    player.ThePlayer.currentHP   := StrToInt(PlayerNode.FindNode('currentHP').TextContent);
    player.ThePlayer.posX        := StrToInt(PlayerNode.FindNode('posX').TextContent);
    player.ThePlayer.posY        := StrToInt(PlayerNode.FindNode('posY').TextContent);
    player.ThePlayer.maxHP       := StrToInt(PlayerNode.FindNode('maxHP').TextContent);
    player.ThePlayer.attack      := StrToInt(PlayerNode.FindNode('attack').TextContent);
    player.ThePlayer.defense     := StrToInt(PlayerNode.FindNode('defense').TextContent);

    (* NPC stats *)
    SetLength(entities.entityList, 1);
    NPCnode := Doc.DocumentElement.FindNode('NPC');
    for i := 1 to entities.npcAmount do
    begin
      entities.listLength := length(entities.entityList);
      SetLength(entities.entityList, entities.listLength + 1);
      entities.entityList[i].npcID :=
        StrToInt(NPCnode.Attributes.Item[0].NodeValue);
      entities.entityList[i].race        := NPCnode.FindNode('race').TextContent;
      entities.entityList[i].glyph       := Char(WideChar(NPCnode.FindNode('glyph').TextContent[1]));
      entities.entityList[i].glyphColour := StrToInt(NPCnode.FindNode('glyphColour').TextContent);
      entities.entityList[i].currentHP   := StrToInt(NPCnode.FindNode('currentHP').TextContent);
      entities.entityList[i].attack      := StrToInt(NPCnode.FindNode('attack').TextContent);
      entities.entityList[i].defense     := StrToInt(NPCnode.FindNode('defense').TextContent);
      entities.entityList[i].inView      := StrToBool(NPCnode.FindNode('inView').TextContent);
      entities.entityList[i].isDead      := StrToBool(NPCnode.FindNode('isDead').TextContent);
      entities.entityList[i].posX        := StrToInt(NPCnode.FindNode('posX').TextContent);
      entities.entityList[i].posY        := StrToInt(NPCnode.FindNode('posY').TextContent);
      ParentNode := NPCnode.NextSibling;
      NPCnode := ParentNode;
    end;

  finally
    // finally, free the document
    Doc.Free;
  end;
end;

end.
