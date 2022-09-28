local item=reaper.GetSelectedMediaItem(0,0)
marker_start, marker_end = reaper.GetSet_LoopTimeRange(false,false,0,0,0)
if item then
  local itemStart = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
  reaper.SetMediaItemPosition(item, marker_start + 0.0001, true);
end
