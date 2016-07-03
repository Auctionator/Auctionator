
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