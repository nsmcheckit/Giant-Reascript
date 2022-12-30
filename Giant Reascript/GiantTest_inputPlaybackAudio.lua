---json 转换工具
---@class JSON @by wx771720@outlook.com 2019-08-07 16:03:34
_G.JSON = {escape = "\\", comma = ",", colon = ":", null = "null"}

---将数据转换成 json 字符串
---@param data any @数据
---@param space number|string @美化输出时缩进空格数量或者字符串，默认 nil 表示不美化
---@param toArray boolean @如果是数组，是否按数组格式输出，默认 true
---@return string @返回 json 格式的字符串
function JSON.toString(data, space, toArray, __tableList, __keyList, __indent)
  if "boolean" ~= type(toArray) then toArray = true end
  if "table" ~= type(__tableList) then __tableList = {} end
  if "table" ~= type(__keyList) then __keyList = {} end
  if "number" == type(space) then space = space > 0 and string.format("%" .. tostring(space) .. "s", " ") or nil end
  if nil ~= space and nil == __indent then __indent = "" end

  local dataType = type(data)
  -- string
  if "string" == dataType then
    data = string.gsub(data, "\\", "\\\\")
    data = string.gsub(data, "\"", "\\\"")
    return "\"" .. data .. "\""
  end
  -- number
  if "number" == dataType then return tostring(data) end
  -- boolean
  if "boolean" == dataType then return data and "true" or "false" end
  -- table
  if "table" == dataType then
    table.insert(__tableList, data)

    local result, value
    if 0 == JSON._tableCount(data) then
      result = "{}"
    elseif toArray and JSON._isArray(data) then
      result = nil == space and "[" or (__indent .. "[")
      local subIndent = __indent and (__indent .. space)
      for i = 1, #data do
        value = data[i]
        if "table" == type(value) and JSON._indexOf(__tableList, value) >= 1 then
          print(string.format("json array loop refs warning : %s[%i]", JSON.toString(__keyList), i))
        else
          local valueString = JSON.toString(data[i], space, toArray, __tableList, table.insert({unpack(__keyList)}, i), subIndent)
          if valueString and subIndent and JSON._isBeginWith(valueString, subIndent) then valueString = string.sub(valueString, #subIndent + 1) end
          if nil == space then
            result = result .. (i > 1 and "," or "") .. (valueString or JSON.null)
          else
            result = result .. (i > 1 and "," or "") .. "\n" .. subIndent .. (valueString or JSON.null)
          end
        end
      end
      result = result .. (nil == space and "]" or ("\n" .. __indent .. "]"))
    else
      result = nil == space and "{" or (__indent .. "{")
      local index = 0
      local subIndent = __indent and (__indent .. space)
      for k, v in pairs(data) do
        if "table" == type(v) and JSON._indexOf(__tableList, v) >= 1 then
          print(string.format("json map loop refs warning : %s[%s]", JSON.toString(__keyList), k))
        else
          local valueString = JSON.toString(v, space, toArray, __tableList, table.insert({unpack(__keyList)}, k), subIndent)
          if valueString then
            if subIndent and JSON._isBeginWith(valueString, subIndent) then valueString = string.sub(valueString, #subIndent + 1) end
            if nil == space then
              result = result .. (index > 0 and "," or "") .. ("\"" .. k .. "\":") .. valueString
            else
              result = result .. (index > 0 and "," or "") .. "\n" .. subIndent .. ("\"" .. k .. "\" : ") .. valueString
            end
            index = index + 1
          end
        end
      end
      result = result .. (nil == space and "}" or ("\n" .. __indent .. "}"))
    end
    return result
  end
end

---去掉字符串首尾空格
---@param target string
---@return string
JSON._trim = function(target) return target and string.gsub(target, "^%s*(.-)%s*$", "%1") end
---判断字符串是否已指定字符串开始
---@param str string @需要判断的字符串
---@param match string @需要匹配的字符串
---@return boolean
JSON._isBeginWith = function(str, match) return nil ~= string.match(str, "^" .. match) end
---计算指定表键值对数量
---@param map table @表
---@return number @返回表数量
JSON._tableCount = function(map)
  local count = 0
  for _, __ in pairs(map) do count = count + 1 end
  return count
end
---判断指定表是否是数组（不包含字符串索引的表）
---@param target any @表
---@return boolean @如果不包含字符串索引则返回 true，否则返回 false
JSON._isArray = function(target)
  if "table" == type(target) then
    for key, _ in pairs(target) do if "string" == type(key) then return false end end
    return true
  end
  return false
end
---获取数组中第一个项索引
JSON._indexOf = function(array, item)
  for i = 1, #array do if item == array[i] then return i end end
  return -1
end

---将字符串转换成 table 对象
---@param text string json @格式的字符串
---@return any|nil @如果解析成功返回对应数据，否则返回 nil
JSON.toJSON = function(text)
  text = JSON._trim(text)
  -- string
  if "\"" == string.sub(text, 1, 1) and "\"" == string.sub(text, -1, -1) then return string.sub(JSON.findMeta(text), 2, -2) end
  if 4 == #text then
    -- boolean
    local lowerText = string.lower(text)
    if "false" == lowerText then
      return false
    elseif "true" == lowerText then
      return true
    end
    -- nil
    if JSON.null == lowerText then return end
  end
  -- number
  local number = tonumber(text)
  if number then return number end
  -- array
  if "[" == string.sub(text, 1, 1) and "]" == string.sub(text, -1, -1) then
    local remain = string.gsub(text, "[\r\n]+", "")
    remain = string.sub(remain, 2, -2)
    local array, index, value = {}, 1
    while #remain > 0 do
      value, remain = JSON.findMeta(remain)
      if value then
        value = JSON.toJSON(value)
        array[index] = value
        index = index + 1
      end
    end
    return array
  end
  -- table
  if "{" == string.sub(text, 1, 1) and "}" == string.sub(text, -1, -1) then
    local remain = string.gsub(text, "[\r\n]+", "")
    remain = string.sub(remain, 2, -2)
    local key, value
    local map = {}
    while #remain > 0 do
      key, remain = JSON.findMeta(remain)
      value, remain = JSON.findMeta(remain)
      if key and #key > 0 and value then
        key = JSON.toJSON(key)
        value = JSON.toJSON(value)
        if key and value then map[key] = value end
      end
    end
    return map
  end
end

---查找字符串中的 json 元数据
---@param text string @json 格式的字符串
---@return string,string @元数据,剩余字符串
JSON.findMeta = function(text)
  local stack = {}
  local index = 1
  local lastChar = nil
  while index <= #text do
    local char = string.sub(text, index, index)
    if "\"" == char then
      if char == lastChar then
        table.remove(stack, #stack)
        lastChar = #stack > 0 and stack[#stack] or nil
      else
        table.insert(stack, char)
        lastChar = char
      end
    elseif "\"" ~= lastChar then
      if "{" == char then
        table.insert(stack, "}")
        lastChar = char
      elseif "[" == char then
        table.insert(stack, "]")
        lastChar = char
      elseif "}" == char or "]" == char then
        assert(char == lastChar, text .. " " .. index .. " not expect " .. char .. "<=>" .. lastChar)
        table.remove(stack, #stack)
        lastChar = #stack > 0 and stack[#stack] or nil
      elseif JSON.comma == char or JSON.colon == char then
        if not lastChar then return string.sub(text, 1, index - 1), string.sub(text, index + 1) end
      end
    elseif JSON.escape == char then
      text = string.sub(text, 1, index - 1) .. string.sub(text, index + 1)
    end

    index = index + 1
  end
  return string.sub(text, 1, index - 1), string.sub(text, index + 1)
end

Utils = {}
----------------------------------------------------------------------------------
-- Lua-Table 与 string 转换
local function value2string(value, isArray)
    if type(value)=='table' then
       return Utils.table2string(value, isArray)
    elseif type(value)=='string' then
        return "\""..value.."\""
    else
       return tostring(value)
    end
end

function Utils.string2table(str)
    if str == nil or type(str) ~= "string" or str == "" then
        return {}
    end
    --若报错bad argument #1 to 'loadstring' ... ，把loadstring改为load即可
    --return loadstring("return " .. str)()
  return load("return " .. str)()
end

function Utils.table2string(t, isArray)
    if t == nil then return "" end
    local sStart = "{"

    local i = 1
    for key,value in pairs(t) do
        local sSplit = ","
        if i==1 then
            sSplit = ""
        end

        if isArray then
            sStart = sStart..sSplit..value2string(value, isArray)
        else
            if type(key)=='number' or type(key) == 'string' then
                sStart = sStart..sSplit..'['..value2string(key).."]="..value2string(value)
            else
                if type(key)=='userdata' then
                    sStart = sStart..sSplit.."*s"..Utils.table2string(getmetatable(key)).."*e".."="..value2string(value)
                else
                    sStart = sStart..sSplit..key.."="..value2string(value)
                end
            end
        end

        i = i+1
    end

  sStart = sStart.."}"
  return sStart
end

----------------------------------------------------------------------------------
-- Lua-Table 与 json 转换
local function json2true(str, from, to)
    return true, from + 3
end

local function json2false(str, from, to)
    return false, from + 4
end

local function json2null(str, from, to)
    return nil, from + 3
end

local function json2nan(str, from, to)
    return nil, from + 2
end

local numberchars = {
    ['-'] = true,
    ['+'] = true,
    ['.'] = true,
    ['0'] = true,
    ['1'] = true,
    ['2'] = true,
    ['3'] = true,
    ['4'] = true,
    ['5'] = true,
    ['6'] = true,
    ['7'] = true,
    ['8'] = true,
    ['9'] = true,
}

local function json2number(str, from, to)
    local i = from + 1
    while (i <= to) do
        local char = string.sub(str, i, i)
        if not numberchars[char] then
            break
        end
        i = i + 1
    end
    local num = tonumber(string.sub(str, from, i - 1))
    if not num then
        return
    end
    return num, i - 1
end

local function json2string(str, from, to)
    local ignor = false
    for i = from + 1, to do
        local char = string.sub(str, i, i)
        if not ignor then
            if char == '\"' then
                return string.sub(str, from + 1, i - 1), i
            elseif char == '\\' then
                ignor = true
            end
        else
            ignor = false
        end
    end
end

local function json2array(str, from, to)
    local result = {}
    from = from or 1
    local pos = from + 1
    local to = to or string.len(str)
    while (pos <= to) do
        local char = string.sub(str, pos, pos)
        if char == '\"' then
            result[#result + 1], pos = json2string(str, pos, to)
        --[[    elseif char == ' ' then
        
        elseif char == ':' then
        
        elseif char == ',' then]]
        elseif char == '[' then
            result[#result + 1], pos = json2array(str, pos, to)
        elseif char == '{' then
            result[#result + 1], pos = Utils.json2table(str, pos, to)
        elseif char == ']' then
            return result, pos
        elseif (char == 'f' or char == 'F') then
            result[#result + 1], pos = json2false(str, pos, to)
        elseif (char == 't' or char == 'T') then
            result[#result + 1], pos = json2true(str, pos, to)
        elseif (char == 'n') then
            result[#result + 1], pos = json2null(str, pos, to)
        elseif (char == 'N') then
            result[#result + 1], pos = json2nan(str, pos, to)
        elseif numberchars[char] then
            result[#result + 1], pos = json2number(str, pos, to)
        end
        pos = pos + 1
    end
end

local function string2json(key, value)
    return string.format("\"%s\":\"%s\",", key, value)
end

local function number2json(key, value)
    return string.format("\"%s\":%s,", key, value)
end

local function boolean2json(key, value)
    value = value == nil and false or value
    return string.format("\"%s\":%s,", key, tostring(value))
end

local function array2json(key, value)
    local str = "["
    for k, v in pairs(value) do
        str = str .. Utils.table2json(v) .. ","
    end
    str = string.sub(str, 1, string.len(str) - 1) .. "]"
    return string.format("\"%s\":%s,", key, str)
end

local function isArrayTable(t)
    if type(t) ~= "table" then
        return false
    end
    
    local n = #t
    for i, v in pairs(t) do
        if type(i) ~= "number" then
            return false
        end
        
        if i > n then
            return false
        end
    end
    return true
end

local function table2json(key, value)
    if isArrayTable(value) then
        return array2json(key, value)
    end
    local tableStr = Utils.table2json(value)
    return string.format("\"%s\":%s,", key, tableStr)
end

function Utils.json2table(str, from, to)
    local result = {}
    from = from or 1
    local pos = from + 1
    local to = to or string.len(str)
    local key
    while (pos <= to) do
        local char = string.sub(str, pos, pos)
        if char == '\"' then
            if not key then
                key, pos = json2string(str, pos, to)
            else
                result[key], pos = json2string(str, pos, to)
                key = nil
            end
        --[[    elseif char == ' ' then
        
        elseif char == ':' then
        
        elseif char == ',' then]]
        elseif char == '[' then
            if not key then
                key, pos = json2array(str, pos, to)
            else
                result[key], pos = json2array(str, pos, to)
                key = nil
            end
        elseif char == '{' then
            if not key then
                key, pos = Utils.json2table(str, pos, to)
            else
                result[key], pos = Utils.json2table(str, pos, to)
                key = nil
            end
        elseif char == '}' then
            return result, pos
        elseif (char == 'f' or char == 'F') then
            result[key], pos = json2false(str, pos, to)
            key = nil
        elseif (char == 't' or char == 'T') then
            result[key], pos = json2true(str, pos, to)
            key = nil
        elseif (char == 'n') then
            result[key], pos = json2null(str, pos, to)
            key = nil
        elseif (char == 'N') then
            result[key], pos = json2nan(str, pos, to)
            key = nil
        elseif numberchars[char] then
            if not key then
                key, pos = json2number(str, pos, to)
            else
                result[key], pos = json2number(str, pos, to)
                key = nil
            end
        end
        pos = pos + 1
    end
end

--json格式中表示字符串不能使用单引号
local jsonfuncs = {
    ['\"'] = json2string,
    ['['] = json2array,
    ['{'] = Utils.json2table,
    ['f'] = json2false,
    ['F'] = json2false,
    ['t'] = json2true,
    ['T'] = json2true,
}

function Utils.json2lua(str)
    local char = string.sub(str, 1, 1)
    local func = jsonfuncs[char]
    if func then
        return func(str, 1, string.len(str))
    end
    if numberchars[char] then
        return json2number(str, 1, string.len(str))
    end
end

function Utils.table2json(tab)
    local str = "{"
    for k, v in pairs(tab) do
        if type(v) == "string" then
            str = str .. string2json(k, v)
        elseif type(v) == "number" then
            str = str .. number2json(k, v)
        elseif type(v) == "boolean" then
            str = str .. boolean2json(k, v)
        elseif type(v) == "table" then
            str = str .. table2json(k, v)
        end
    end
    str = string.sub(str, 1, string.len(str) - 1)
    return str .. "}"
end

-- 检测前三个字节是否是 EF BB BF 也就是BOM标记；如果是就去掉，只保留后面的字节。
function TryRemoveUtf8BOM(ret)
    if string.byte(ret,1)==239 and string.byte(ret,2)==187 and string.byte(ret,3)==191 then
        ret=string.char( string.byte(ret,4,string.len(ret)) )
    end
    return ret;
end


--retval, loc_CSV = reaper.GetUserInputs("Input PlayBackJson", 2, "File Location,Wwise Location ?extrawidth=150", "");
function inputWav()
  itemidx = 0;
  for i = 1, #playbackJson["items"] do
    for j = 1, #playbackJson["items"][i]["names"] do
      reaper.InsertMedia(wwiseFileLoc .. "\\" .. playbackJson["items"][i]["names"][j] .. ".wav", 1);
      item = reaper.GetMediaItem(0, itemidx)
      reaper.SetMediaItemPosition(item, playbackJson["items"][i]["time"]*0.001, true)
      itemidx = itemidx + 1;
    end
  end
end 

-- open and read file
local file = io.open("F:\\2022_12_19_16_57_56_57.json", "r")
wwiseFileLoc = "C:\\Users\\mengqingjie1\\Desktop\\测试";
--local file = io.open("F:\\reaperWebInterface\\sounds\\SoundData\\xlsxtojson\\json\\配音文本（终版）.json", "r")
if nil == file then
    print("open file readtest.txt fail")
end

readall = file:read("*a");
readall = TryRemoveUtf8BOM(readall)
playbackJson = JSON.toJSON(readall);
--reaper.ShowConsoleMsg(tostring(wwiseFileLoc .. "\\" .. playbackJson["items"][1]["names"][1]));
inputWav()
