
-- https://coronalabs.com/blog/2014/09/02/tutorial-printing-table-contents/
function Auctionator.Util.Print( t, name )
  if not Auctionator.Debug.IsOn() then
    return
  end

  name = name or 'Unknown'

  print( '*************** TABLE ' .. name .. ' *****************' )
  -- print( 'Util.Print', debugstack( 2, 1, 0 ) )
  local print_r_cache={}

  local function sub_print_r(t,indent)
    if (print_r_cache[tostring(t)]) then
      print(indent.."*"..tostring(t))
    else
      print_r_cache[tostring(t)]=true
      if (type(t)=="table") then
        for pos,val in pairs(t) do
          if (type(val)=="table") then
            print(indent.."["..pos.."] => "..tostring(t).." {")
            sub_print_r(val,indent..string.rep(" ",string.len(pos)+2))
            print(indent..string.rep(" ",string.len(pos)).."}")
          elseif (type(val)=="string") then
            print(indent.."["..pos..'] => "'..val..'"')
          else
            print(indent.."["..pos.."] => "..tostring(val))
          end
        end
      else
        print(indent..tostring(t))
      end
    end
  end

  if (type(t)=="table") then
    print(tostring(t).." {")
    sub_print_r(t,"  ")
    print("}")
  else
    sub_print_r(t,"  ")
  end

  print()
end

function Auctionator.Util.FlatPrint( t )
  local buffer = {}

  for position, value in pairs( t ) do
    table.insert( buffer, value )
  end

  print( [[{]] .. table.concat( buffer, ',' ) .. [[}]] )
end

function Auctionator.Util.UTF8_Truncate( string, options )
  options = options or {}
  local newLength = options.newLength or 127

  if string:len() <= newLength then
    return string
  end

  local position, char;

  for position = newLength, 1, -1 do
    char = string:byte( position + 1 )

    if bit.band( char, 0xC0 ) == 0x80 then
      return string:sub( 1, position - 1 )
    end
  end
end