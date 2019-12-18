
Procedure StartScript ();
var
  Board       : IPCB_Board;
  str         : String;
  Comp        : IPCB_Component;
  X           : Tcoord;
  Y           : Tcoord;
  X1          : Tcoord;
  Y1          : Tcoord;
  Area        : Tcoord;
  d           : real;
  dold        : real;
  CompOld     : IPCB_Component;
  CompItog    : IPCB_Component;
  ComponentIteratorHandle : IPCB_BoardIterator;
  CheckSelect : boolean;
  CurrentLayer: integer;
  LyrMehPairs              : IPCB_MechanicalLayerPairs;
  LayerType                : Tlayer;
  LayerType2               : Tlayer;
  i                        : integer;

  //PCBSystemOptions : IPCB_SystemOptions;
  //Mech1       : IPCB_MechanicalLayer;
  //LayerObj : IPCB_MechanicalLayer;
  //Layer : TLayer;
  //TheLayerStack : IPCB_LayerStack;


Begin
     CurrentLayer := eTopLayer;
     CheckSelect := true;
     Board := PCBServer.GetCurrentPCBBoard;              // Получение Текущей платы
     If Board = nil then Begin ShowError('Open board!'); Exit; End; // Если платы нет то выходим
     Area := Board.SnapGridSize*2.1;
     Board.ChooseLocation(X,Y, 'Choose Component1');

     if (Board.CurrentLayer = eTopOverlay)| (Board.CurrentLayer = eTopPaste )  then
     CurrentLayer := eTopLayer;

     if (Board.CurrentLayer = eBottomOverlay) | (Board.CurrentLayer = eBottomPaste ) then
     CurrentLayer := eBottomLayer;


     i := 0;
     LyrMehPairs := Board.MechanicalPairs;
     for LayerType := 1 to 32 do
        for LayerType2 := LayerType to 32 do
        begin
          if LyrMehPairs.PairDefined(PCBServer.LayerUtils.MechanicalLayer(LayerType),PCBServer.LayerUtils.MechanicalLayer(LayerType2)) then
          begin
           if Board.CurrentLayer = PCBServer.LayerUtils.MechanicalLayer(LayerType) then CurrentLayer := eTopLayer;
           if Board.CurrentLayer = PCBServer.LayerUtils.MechanicalLayer(LayerType2) then CurrentLayer := eBottomLayer;
           inc(i);
          end;
        end;

     //Comp := Board.GetObjectAtCursor(AllObjects,AllLayers,eEditAction_Select);
     //Board.GetObjectAtXYAskUserIfAmbiguous(
     //TheLayerStack := Board.LayerStack;
     // Layer := eMechanical1;
     //LayerObj := TheLayerStack.LayerObject(Layer);
     //LayerObj := TheLayerStack.LayerObject(Layer);
     // TheLayerStack.ShowDielectricTop;
     // LayerObj.DisplayInSingleLayerMode := false;
     ComponentIteratorHandle := Board.BoardIterator_Create;
     ComponentIteratorHandle.AddFilter_ObjectSet(MkSet(eComponentObject));
     ComponentIteratorHandle.AddFilter_LayerSet(MkSet(CurrentLayer));
     ComponentIteratorHandle.AddFilter_Method(eProcessAll);
     Comp := ComponentIteratorHandle.FirstPCBObject; // получаем первый компонент
     CompItog := Comp;
     X1:= Comp.x;
     Y1:= Comp.y;
     dOld := sqrt(sqr(X1-X)+sqr(Y1-Y));

     While (Comp <> Nil) Do
     Begin
          //NameComp := Component.Name.Text;
          //NameComp := StringReplace(NameComp, 'A1', '', rfReplaceAll);
          //Component.Name.Text := NameComp;
          //Component := ComponentIteratorHandle.NextPCBObject;

          X1:= Comp.x;
          Y1:= Comp.y;
          d := sqrt(sqr(X1-X)+sqr(Y1-Y));
          if d <= Area then
          begin
          CompItog := Comp;
            Break;
          end;

          if d<dold then
          begin
          CompItog := Comp;
          dold := d;
          end;

     Comp := ComponentIteratorHandle.NextPCBObject;
     End;
     Board.BoardIterator_Destroy(ComponentIteratorHandle);

     //PCBSystemOptions := PCBServer.SystemOptions;
     //PCBSystemOptions.SingleLayerMode := false;

     //Comp := Board.GetObjectAtXYAskUserIfAmbiguous(x,y,MkSet(eComponentObject),AllLayers, eEditAction_Select);
     //Comp := Board.GetObjectAtXYAskUserIfAmbiguous(X,Y,AllObjects,AllLayers,eEditAction_Select);

     if CompItog <> Nil then
     CompItog.Selected := true;
     Board.ViewManager_FullUpdate;

end;
