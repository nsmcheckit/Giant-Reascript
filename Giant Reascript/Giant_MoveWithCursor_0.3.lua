--this lua reascript is for Giant SoundTeam Tool


num_selectItems = reaper.CountSelectedMediaItems();
selectItem = {};
selectItemGUID = {};

function init()
--init item
itemNum = reaper.CountMediaItems(1);
itemIdArray = {};
itemPosArray = {};
for i = 0, itemNum - 1, 1 do
  itemIdArray[i] = reaper.GetMediaItem(0, i);
  itemPosArray[i] = reaper.GetMediaItemInfo_Value(itemIdArray[i],"D_POSITION");
end
--count region
local retval;
num_markers = -1;
num_regions = -1;
retval, num_markers, num_regions = reaper.CountProjectMarkers();
num_regions = num_markers + num_regions;

--init region array
rgnStartArray = {};
rgnEndArray = {};
rgnNameArray = {};
for i = 0,num_regions - 1 do
  local hexnumber = string.format('%08d-%04d-%04d-%04d-%012d',0,0,0,0,i);
  local retval, isrgn, rgnStart, rgnEnd, name, markrgnindexnumber = reaper.EnumProjectMarkers(i);
  rgnStartArray[i] = rgnStart;
  rgnEndArray[i] = rgnEnd;
  rgnNameArray[i] = name;
end

--init cursor position
cursorStart = -1;
cursorEnd = -1; 
wantRegionEndPosition = -1;
cursorRegionGap = -1;

cursorStart = reaper.GetCursorPosition();
cursorEnd = reaper.GetPlayPosition();
for i = 0, num_regions - 1, 1 do
  if ( cursorStart >= rgnStartArray[i] and cursorStart <= rgnEndArray[i] and reaper.GetPlayState() ~= 5)
    then
      inRegionNum = i; 
      --break
  end
end 

--alert
if(inRegionNum == nil)
then reaper.ShowConsoleMsg("Please Set Cursor In Right Region");
  return nil
end

--mark all selected items
for i = 0, num_selectItems - 1, 1 do
  selectItem[i] = reaper.GetSelectedMediaItem(0, i);
end
  
--move all selected items 
for i = 0, num_selectItems - 1, 1 do
  item = selectItem[i];
  reaper.SetMediaItemPosition(item,rgnStartArray[inRegionNum], true);
  selectItemGUID[i] = reaper.BR_GetMediaItemGUID(item);
end
end

--unfold all selected items 
function unfold()
  thisPosition = rgnStartArray[inRegionNum];
  for i = 0, num_selectItems - 1, 1 do
    item = selectItem[i];
    reaper.SetMediaItemPosition(item, thisPosition, true);
    thisPosition = thisPosition + reaper.GetMediaItemInfo_Value(item,"D_LENGTH") + 0.5;
  end
  --reaper.SetProjectMarkerByIndex2(1, inRegionNum, true, rgnStartArray[inRegionNum], thisPosition - 0.5, inRegionNum, rgnNameArray[inRegionNum], 1, 0);
  moveLength = thisPosition - 0.5 - rgnEndArray[inRegionNum];
  movePos = thisPosition - 0.5;
end 

--count how many items in each region
inRegionItemsLength = {};
function regionifMove()
  for i = 0, num_regions - 1, 1 do
    for j = 0, itemNum - 1, 1 do 
      if (itemPosArray[j] >= rgnStartArray[i] and itemPosArray[j] <= rgnEndArray[i])
      then
        inRegionItemsLength[i] = 0;
        inRegionItemsLength[i] = inRegionItemsLength[i] + reaper.GetMediaItemInfo_Value(itemIdArray[j],"D_LENGTH");
      end
    end
    if (inRegionItemsLength[i] == nil)
    then inRegionItemsLength[i] = 0;
    end
  end
end
    
--move region, marker and other items 
function move()
--move item
if (rgnEndArray[inRegionNum] < movePos)
then
  for k = 0, itemNum - 1, 1 do
      ifMoved = false;
      for i = 0, num_selectItems - 1, 1 do
        if (selectItemGUID[i] == reaper.BR_GetMediaItemGUID(itemIdArray[k]))
          then ifMoved = true;
        end
      end  
      if (itemPosArray[k] > rgnEndArray[inRegionNum] and (not ifMoved))
      then
        reaper.SetMediaItemInfo_Value(itemIdArray[k], "D_POSITION", itemPosArray[k] + moveLength )
      end          
  end
--init move in region
rgnEndArray[inRegionNum] = thisPosition - 0.5;
--move region marker
if moveLength > 0
then
  for j = num_regions - 1,inRegionNum + 1, -1 do
    rgnStartArray[j] = rgnStartArray[j] + moveLength;
    if (rgnEndArray[j] ~= 0)
    then
      rgnEndArray[j] = rgnEndArray[j] + moveLength;
      reaper.SetProjectMarkerByIndex2(1, j, true, rgnStartArray[j], rgnEndArray[j], j, rgnNameArray[j], 1, 0);
      --reaper.ShowConsoleMsg("i am region"..j.."\n")
    else 
      reaper.SetProjectMarkerByIndex2(1, j, false, rgnStartArray[j], rgnEndArray[j], j, rgnNameArray[j], 1, 0);
     -- reaper.ShowConsoleMsg("i am marker"..j.."\n")
    end
  reaper.SetProjectMarkerByIndex2(1, inRegionNum, true, rgnStartArray[inRegionNum], rgnEndArray[inRegionNum], inRegionNum, rgnNameArray[inRegionNum], 1, 0);
  end
else 
  for j = inRegionNum + 1,num_regions - 1, 1 do
      rgnStartArray[j] = rgnStartArray[j] + moveLength;
      if (rgnEndArray[j] ~= 0)
      then
        rgnEndArray[j] = rgnEndArray[j] + moveLength;
        reaper.SetProjectMarkerByIndex2(1, j, true, rgnStartArray[j], rgnEndArray[j], j, rgnNameArray[j], 1, 0);
        --reaper.ShowConsoleMsg("i am region"..j.."\n")
      else 
        reaper.SetProjectMarkerByIndex2(1, j, false, rgnStartArray[j], rgnEndArray[j], j, rgnNameArray[j], 1, 0);
        --reaper.ShowConsoleMsg("i am marker"..j.."\n")
      end
  end
end
end
end

function main()
  init();
  --alert
  if(inRegionNum == nil)
  then return nil
  end
  unfold();
  regionifMove()
  move();
end

main()
