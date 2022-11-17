--init item
itemNum = reaper.CountSelectedMediaItems();
itemIdArray = {};
itemPosArray = {};
itemRegionName = {};
for i = 0, itemNum - 1, 1 do
  itemIdArray[i] = reaper.GetSelectedMediaItem(0, i);
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
--split func
string.split = function(s, p)
  local rt= {}
  string.gsub(s, '[^'..p..']+', function(w) table.insert(rt, w) end )
  return rt
end
--item in region
function handleItemRegionName()
  for i = 0, itemNum - 1 do
    for j = 0, num_regions - 1 do
      if ( itemPosArray[i] >= rgnStartArray[j] and (itemPosArray[i] + reaper.GetMediaItemInfo_Value(itemIdArray[i],"D_LENGTH")) <= rgnEndArray[j])
      then 
        itemRegionName[i] = rgnNameArray[j];
        break;
      end
    itemRegionName[i] = 'Error';
    end
  end
end

-- Export Json
function expoert_Json()
    local print_s = "["
    for i=0, itemNum-1 do
      print_s = print_s 
      .. "{"
      .. "\"Audio File Name\":" .. "\"" .. itemRegionName[i] .. "\"" .. ","
      .. "\"Dialogue(CN)(台词)\":" .. "\"" .. reaper.ULT_GetMediaItemNote(itemIdArray[i]) .. "\""
      .. "}"
      if i < itemNum-1 then
        print_s = print_s .. ","
      end
    end
    print_s = print_s .. "]"
    --reaper.ShowConsoleMsg(print_s)
    -- Write Json 
    local path = fileLoc
    if (path ~= "" and string.split(path, '.')[#string.split(path, '.')] == "json")
    then
      local file = io.open(path, "w+")
      file:write(print_s)
      io.close(file)
    else 
      reaper.ShowMessageBox("Wrong File Path!", "Message", 0)
    end
end

--open GUI
retval, fileLoc= reaper.GetUserInputs("Out Put newjson", 1, "File Location ?extrawidth=150", "")
handleItemRegionName()
expoert_Json()
