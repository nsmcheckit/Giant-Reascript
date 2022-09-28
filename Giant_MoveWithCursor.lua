function show_msg(m)
  --reaper.ClearConsole()
  reaper.ShowConsoleMsg(tostring(m) .. "\n")
end

function main()
--count region
local retval;
num_markers = -1;
num_regions = -1;
retval, num_markers, num_regions = reaper.CountProjectMarkers();

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
--show_msg("Rec" .. cursorStart);
--show_msg("Stop" .. cursorEnd);
for i = 0, num_regions - 1, 1 do
  if ( cursorStart >= rgnStartArray[i] and cursorStart <= rgnEndArray[i] and reaper.GetPlayState() ~= 5)
    then
      inRegionNum = i; 
      --break
  end
end 

if (reaper.GetPlayState() == 5 and inRegionNum ~= -1)
  then 
    --cursorRegionGap = cursorStart - rgnEndArray[inRegionNum]; 
  if cursorEnd > rgnEndArray[inRegionNum] 
    then
    reaper.SetProjectMarkerByIndex2(1, inRegionNum, true, rgnStartArray[inRegionNum], cursorEnd, inRegionNum, rgnNameArray[inRegionNum], 1, 0);
    rgnEndArray[inRegionNum] = cursorEnd;
    if (rgnStartArray[inRegionNum + 1] ~= nil and rgnStartArray[inRegionNum + 1] - cursorEnd < 20) 
      then 
        for j = inRegionNum + 1, num_regions - 1, 1 do
          rgnStartArray[j] = rgnStartArray[j] + 0.033;
          rgnEndArray[j] = rgnEndArray[j] + 0.033;
          reaper.SetProjectMarkerByIndex2(1, j, true, rgnStartArray[j], rgnEndArray[j], j, rgnNameArray[j], 1, 0);
        end
    end
  end
end
reaper.defer(main)
end
--show_msg(reaper.GetCursorPosition());
--show_msg(reaper.FindTempoTimeSigMarker(reaper.GetCursorPosition()));


--reaper.SetProjectMarkerByIndex2(1, makerIndex, ifRegion, start, end, makerID, name, color, flags);
--reaper.SetProjectMarker(integer markrgnindexnumber, boolean isrgn, number pos, number rgnend, string name)
--flags&1 to clear name


main();
--if (reaper.CSurf_OnRecord())
  --then show_msg("record")
--end
--reaper.SetProjectMarkerByIndex2(1, 2, 1, 9, 18, 09009, 0 , 1, 0);

