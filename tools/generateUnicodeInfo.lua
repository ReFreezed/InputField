--
-- Unicode info generator
--
-- How to generate:
-- > Put UnicodeData.txt in "local/UnicodeData.txt". (https://unicode.org/Public/UNIDATA/UnicodeData.txt)
-- > Run: lua tools/generateUnicodeInfo.lua
-- > Copy printed info
--

local cpSetByCategory = {}
local maxCp           = 128

for line in io.lines"local/UnicodeData.txt" do
	--[[
		Fields:
		 1.  Codepoint
		 2.  Name
		 3.  General_Category
		 4.  Canonical_Combining_Class
		 5.  Bidi_Class
		 6.  Decomposition_Type
		 7.  Decomposition_Mapping
		 8.  Numeric_Type
		 9.  Numeric_Value
		 10. Bidi_Mirrored
		 11. Unicode_1_Name (Obsolete as of 6.2.0)
		 12. ISO_Comment (Obsolete as of 5.2.0; Deprecated and Stabilized as of 6.0.0)
		 13. Simple_Uppercase_Mapping
		 14. Simple_Lowercase_Mapping
		 15. Simple_Titlecase_Mapping
	]]
	local cp, category = line:match"^(%x+);[^;]*;([^;]*)"

	cp       = tonumber(cp, 16)
	category = category:sub(1, 1) -- Generalize categories more (e.g. make 'Zs' into 'Z').

	cpSetByCategory[category]     = cpSetByCategory[category] or {}
	cpSetByCategory[category][cp] = true

	maxCp = math.max(maxCp, cp)
end

local INDENTATION = string.rep("\t", 1)

local function generateInfoForCharacterType(name, categories)
	local cpSetJoined = {}
	local count       = 0

	for _, category in ipairs(categories) do
		local cpSet = cpSetByCategory[category]
		local lastStartCp

		for cp = 128, maxCp do
			if cpSet[cp] then
				cpSetJoined[cp] = true
				count           = count + 1
			end
		end
	end

	local singles = {}
	local ranges  = {}
	local lastStartCp

	for cp = 128, maxCp do
		if cpSetJoined[cp] then
			if not cpSetJoined[cp-1] then
				lastStartCp = cp
			end
			if not cpSetJoined[cp+1] then
				if cp == lastStartCp then  table.insert(singles, cp)
				else                       table.insert(ranges, {from=lastStartCp, to=cp})  end
			end
		end
	end

	table.sort(singles)
	table.sort(ranges, function(a, b)  return a.from < b.from  end)

	io.write(INDENTATION, "-- ", name, " (", count, ", ", #singles, "+", #ranges, ")\n")

	io.write(INDENTATION, "local UNICODE_", name, " = newSet{")
	for i, cp in ipairs(singles) do
		if i > 1       then  io.write(",")                  end
		if i % 30 == 0 then  io.write("\n\t", INDENTATION)  end
		io.write(cp)
	end
	io.write("}\n")

	io.write(INDENTATION, "local ranges = {")
	for i, range in ipairs(ranges) do
		if i > 1      then  io.write(",")                  end
		if i %12 == 0 then  io.write("\n\t", INDENTATION)  end
		io.write(range.from, ",", range.to)
	end
	io.write("}\n")
	io.write(INDENTATION, "for i = 1, #ranges, 2 do  for cp = ranges[i], ranges[i+1] do UNICODE_", name, "[cp] = true end  end\n")

	io.write("\n")
end

generateInfoForCharacterType("PUNCTUATION", {"P"--[[punctuation]],"S"--[[symbol]]})
generateInfoForCharacterType("WHITESPACE",  {"Z"--[[separator]]})
