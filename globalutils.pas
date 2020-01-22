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
  saveFile = 'savegame.xml';

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
  RootNode, ElementNode, ParentNode, TextNode, ItemNode: TDOMNode;
begin
  mapString := map.saveMap;
  try
    // Create a document
    Doc := TXMLDocument.Create;
    // Create a root node
    RootNode := Doc.CreateElement('FLUX');
    // Save root node
    Doc.Appendchild(RootNode);
    // Create a parent node
    RootNode := Doc.DocumentElement;
    // Create nodes

    //// Game data
    RootNode := Doc.DocumentElement;
    ElementNode := Doc.CreateElement('RandSeed');
    TextNode := Doc.CreateTextNode(IntToStr(RandSeed));
    ElementNode.AppendChild(TextNode);
    RootNode.AppendChild(ElementNode);

    RootNode := Doc.DocumentElement;
    ElementNode := Doc.CreateElement('npcAmount');
    TextNode := Doc.CreateTextNode(IntToStr(entities.npcAmount));
    ElementNode.AppendChild(TextNode);
    RootNode.AppendChild(ElementNode);

    //// Game map
    RootNode := Doc.DocumentElement;
    ElementNode := Doc.CreateElement('map_area');
    TextNode := Doc.CreateTextNode(mapString);
    ElementNode.AppendChild(TextNode);
    RootNode.AppendChild(ElementNode);

    // map tiles
    for r := 1 to map.MAXROWS do
    begin
      for c := 1 to map.MAXCOLUMNS do
      begin
        ElementNode := Doc.CreateElement('map_tiles');
        TDOMElement(ElementNode).SetAttribute('id', IntToStr(maparea[r][c].id));

        ItemNode := Doc.CreateElement('blocks');
        TextNode := Doc.CreateTextNode(BoolToStr(map.maparea[r][c].blocks));
        ItemNode.AppendChild(TextNode);
        ElementNode.AppendChild(ItemNode);

        ItemNode := Doc.CreateElement('Visible');
        TextNode := Doc.CreateTextNode(BoolToStr(map.maparea[r][c].Visible));
        ItemNode.AppendChild(TextNode);
        ElementNode.AppendChild(ItemNode);

        ItemNode := Doc.CreateElement('occupied');
        TextNode := Doc.CreateTextNode(BoolToStr(map.maparea[r][c].occupied));
        ItemNode.AppendChild(TextNode);
        ElementNode.AppendChild(ItemNode);

        ItemNode := Doc.CreateElement('defColour');
        TextNode := Doc.CreateTextNode(IntToStr(map.maparea[r][c].defColour));
        ItemNode.AppendChild(TextNode);
        ElementNode.AppendChild(ItemNode);

        ItemNode := Doc.CreateElement('hiColour');
        TextNode := Doc.CreateTextNode(IntToStr(map.maparea[r][c].hiColour));
        ItemNode.AppendChild(TextNode);
        ElementNode.AppendChild(ItemNode);
        RootNode.AppendChild(ElementNode);
      end;
    end;
    // Player record
    ParentNode := Doc.CreateElement('Player');

    ItemNode := Doc.CreateElement('currentHP');
    TextNode := Doc.CreateTextNode(IntToStr(player.ThePlayer.currentHP));
    ItemNode.AppendChild(TextNode);
    ParentNode.AppendChild(ItemNode);

    ItemNode := Doc.CreateElement('maxHP');
    TextNode := Doc.CreateTextNode(IntToStr(player.ThePlayer.maxHP));
    ItemNode.AppendChild(TextNode);
    ParentNode.AppendChild(ItemNode);

    ItemNode := Doc.CreateElement('attack');
    TextNode := Doc.CreateTextNode(IntToStr(player.ThePlayer.attack));
    ItemNode.AppendChild(TextNode);
    ParentNode.AppendChild(ItemNode);

    ItemNode := Doc.CreateElement('defense');
    TextNode := Doc.CreateTextNode(IntToStr(player.ThePlayer.defense));
    ItemNode.AppendChild(TextNode);
    ParentNode.AppendChild(ItemNode);

    ItemNode := Doc.CreateElement('posX');
    TextNode := Doc.CreateTextNode(IntToStr(player.ThePlayer.posX));
    ItemNode.AppendChild(TextNode);
    ParentNode.AppendChild(ItemNode);

    ItemNode := Doc.CreateElement('posY');
    TextNode := Doc.CreateTextNode(IntToStr(player.ThePlayer.posY));
    ItemNode.AppendChild(TextNode);
    ParentNode.AppendChild(ItemNode);

    RootNode.AppendChild(ParentNode);
    // NPC records
    for i := 1 to entities.npcAmount do
    begin
      ElementNode := Doc.CreateElement('NPC');
      TDOMElement(ElementNode).SetAttribute('id', IntToStr(i));

      ItemNode := Doc.CreateElement('race');
      TextNode := Doc.CreateTextNode(entities.entityList[i].race);
      ItemNode.AppendChild(TextNode);
      ElementNode.AppendChild(ItemNode);

      ItemNode := Doc.CreateElement('currentHP');
      TextNode := Doc.CreateTextNode(IntToStr(entities.entityList[i].currentHP));
      ItemNode.AppendChild(TextNode);
      ElementNode.AppendChild(ItemNode);

      ItemNode := Doc.CreateElement('maxHP');
      TextNode := Doc.CreateTextNode(IntToStr(entities.entityList[i].maxHP));
      ItemNode.AppendChild(TextNode);
      ElementNode.AppendChild(ItemNode);

      ItemNode := Doc.CreateElement('attack');
      TextNode := Doc.CreateTextNode(IntToStr(entities.entityList[i].attack));
      ItemNode.AppendChild(TextNode);
      ElementNode.AppendChild(ItemNode);

      ItemNode := Doc.CreateElement('defense');
      TextNode := Doc.CreateTextNode(IntToStr(entities.entityList[i].defense));
      ItemNode.AppendChild(TextNode);
      ElementNode.AppendChild(ItemNode);

      ItemNode := Doc.CreateElement('inView');
      TextNode := Doc.CreateTextNode(BoolToStr(entities.entityList[i].inView));
      ItemNode.AppendChild(TextNode);
      ElementNode.AppendChild(ItemNode);

      ItemNode := Doc.CreateElement('isDead');
      TextNode := Doc.CreateTextNode(BoolToStr(entities.entityList[i].isDead));
      ItemNode.AppendChild(TextNode);
      ElementNode.AppendChild(ItemNode);

      ItemNode := Doc.CreateElement('posX');
      TextNode := Doc.CreateTextNode(IntToStr(entities.entityList[i].posX));
      ItemNode.AppendChild(TextNode);
      ElementNode.AppendChild(ItemNode);

      ItemNode := Doc.CreateElement('posY');
      TextNode := Doc.CreateTextNode(IntToStr(entities.entityList[i].posX));
      ItemNode.AppendChild(TextNode);
      ElementNode.AppendChild(ItemNode);

      RootNode.AppendChild(ElementNode);
    end;
    // Save XML
    WriteXMLFile(Doc, saveFile);
  finally
    Doc.Free;  // free memory
  end;
end;

procedure loadGame;
var
  Doc: TXMLDocument;
  RootNode, dataNode, ParentNode, TextNode: TDOMNode;
begin
  try
    ReadXMLFile(Doc, saveFile);
    ParentNode := Doc.DocumentElement.FindNode('RandSeed');
    WriteLn(ParentNode.FirstChild.NodeValue);
  finally
    Doc.Free; // free memory
  end;
end;

end.
