                                                                                                                                                                                                                --[[

    Command-Line Arguments by:
        Noire　・　BHNoire ・ BHNowaaru ・ Fifkee

        Stinky command-line argument implementation that desperately needs major cleanup.
        I wont be the one cleaning it up, however. It do be how it do be sometimes.
        If you wish to use this work, please credit me somewhere. I pulleed many
        a hairs for this.

        Made with reference to the Godawful Language Golang (G.L.G - pronounced Gluck) Monarchy.
        It's pronounced "Gluck" because G'luck trying to use Golang! :troll:
        Comes with a simple, custom type system. You can export it as well if you wish.

        Also features autocompletion via setupAutoComplete - should be ran after all flags are ran.
        Thank you for using this!

        Made many comments and explained much of my code to improve readability and to help learners
        understand what each part does.
                                                                                                                                                                                            --]]



-- Two types of command line arguments:
--[[

    -c=foobar
    --c foobar

]]--

--test
local cla = {};
local arguments = {};
local prettyprint = function(colour, ...)
    -- Checks if a value exists within a table
    colour = colour or "white";
    local function hasIndex(t, l)
        for k, value in pairs(t) do
            if (tostring(k):lower() == tostring(l):lower()) then
                return true, value end;
        end
        
        return false
    end;

    local lastTextColour = term.getTextColour()
    assert(hasIndex(colours, colour) or table.find(colours, colour), ("invalid color '%s'"):format(colour)) 

    term.setTextColour(term.isColour and (select(2, hasIndex(colours, colour)) or colour) or colours.white); --sloppy, but not as if I could do anythin better
    print(table.concat({...}, " "));
    term.setTextColour(lastTextColour);
    return;
end

local _type = type;
local function type(default)
    return tonumber(default) and (tostring(default):match("%d%.%d+") and "float" or "int") or _type(default) end;

-- too lazy to make an arguments[name] function check or whatever so i'll do it the copy and paste way
function cla.String(name, default, description)
    if (type(default) ~= "string") then
        error(("type mismatch: expected %s, got %s for function String"):format("string", type(default)), 2) end;
    
    if (arguments[name]) then
        return error(("argument %s is already defined as a command-line argument"):format(name), 2) end;
    
    arguments[name] = {name = name, value = default, type = "string", description = description};
end

function cla.Boolean(name, default, description)
    if (type(default) ~= "boolean") then
        error(("type mismatch: expected %s, got %s for function Boolean"):format("boolean", type(default)), 2) end;
    
    if (arguments[name]) then
        return error(("argument %s is already defined as a command-line argument"):format(name), 2) end;
    
    arguments[name] = {name = name, value = default, type = "boolean", description = description};
end

function cla.Float(name, default, description)
    if (type(default) ~= "float" and type(default) ~= "int") then 
        --ints can be floats but floats cant be int, sad wiggleroom i cant excuse
        -- since i cant take "4.0" literally without it being automatically coerced.. sadge.
        error(("type mismatch: expected %s, got %s for function Float"):format("float", type(default)), 2) end;
    
    if (arguments[name]) then
        return error(("argument %s is already defined as a command-line argument"):format(name), 2) end;
    
    arguments[name] = {name = name, value = default, type = "float", description = description};
end

function cla.Integer(name, default, description)
    if (type(default) ~= "int") then
        error(("type mismatch: expected %s, got %s for function Integer"):format("integer", type(default)), 2) end;
    
    if (arguments[name]) then
        return error(("argument %s is already defined as a command-line argument"):format(name), 2) end;
    
    arguments[name] = {name = name, value = default, type = "integer", description = description};
end

-- Valueless  arguments such as:
-- ./importer.lua --foo 
-- It's essentially an interfaced cla.Boolean value except that by its presence
-- it immediately sets its own value to true rather than it being explicitly defined
-- by the user.
-- Therefore:
-- ./importer.lua --foo, ./importer.lua --foo true, and ./importer.lua -foo=true are synonyumous.
function cla.Valueless(name, description)
    arguments[name] = {name = name, value = false, type = "valueless", description = description};
end

--shell.tokenize eats quotation marks, so we'll have to make do with 'true' and 'false' unfortunately.
local function determineTrueType(argument)
    return (tostring(argument):match("%b''") and "string") or (tonumber(argument) and (tostring(argument):match("^%d%.%d+") and "float" or "integer")) 
            or ((argument:lower() == "true" or argument:lower() == "false") and "boolean")
            or "string";
end

--The reason we need an iterator here is becasue this (fortunately and unfortunately)
--isn't Lua 5.0 where we can modify the iterator of a numerical for loop.
--man. Lua should have pointers. :troll:
local function args(callingArguments)
    local currentIndex = 1;

    local function _itr() --iterator functions should really be outside the iterator factory but it looks ugly (and its stateful) soooo ...
        local stringifiedIndex = tostring(callingArguments[currentIndex])
        local isDoubleArgument, isSingleArgument = stringifiedIndex:match("^%-%-(%S+)"), stringifiedIndex:match("^%-(%S+)");
        
        if (not callingArguments[currentIndex]) then
            return end;
        
        if (not isDoubleArgument and not isSingleArgument) then
            currentIndex = currentIndex + 1 return {error = true, reason = 'exist', name = stringifiedIndex} end;

        local datumTemplate = {name = (isDoubleArgument or isSingleArgument), error = false, reason = "", flagtype = isDoubleArgument and 2 or 1}
        --stringifiedIndex:match("^%-(%S+)%s?=%s?(%S+)"); to check the value for single-dash args
        if (isDoubleArgument) then -- Instead of going "all or nothing," we can use the opportunity to print the description of the flag.
            -- Check if the double argument is valid.
            -- If it isn't, return a table with a {error = true, data = {}} value.
            -- If it is, then simply return an {error = false, data = {}} value.
    
            local argumentTemplate = arguments[isDoubleArgument]
            if (not argumentTemplate) then
                currentIndex = currentIndex + 1
                datumTemplate.error, datumTemplate.reason = true, "exist" return datumTemplate end;

            local Value;
            if (arguments[isDoubleArgument].type == "valueless") then
                Value = true;
                currentIndex = currentIndex + 1;
            else 
                Value = callingArguments[currentIndex + 1];
                -- If the next value is a flag, then that's no good. Use anchor to make sure that '--foo' and "" isn't detected.
                if (tostring(Value):match("^%-%-") or tostring(Value):match("^%-%S+%=")) then
                    datumTemplate.error, datumTemplate.reason = true, "valueless"
                    currentIndex = currentIndex + 1
                    return datumTemplate
                end;

                currentIndex = currentIndex + 2;
            end

            if (not Value) then
                datumTemplate.error, datumTemplate.reason = true, "valueless"
                return datumTemplate;
            end

            if (argumentTemplate.type ~= "valueless" and arguments[isDoubleArgument].type ~= determineTrueType(Value)) then
                datumTemplate.error, datumTemplate.reason  = true, "type" 
                return datumTemplate;
            end;
            
            datumTemplate.value = Value;
         elseif (isSingleArgument) then
            --lookahead 2 tokens ughh
            local doesIndexHaveEquals = stringifiedIndex:match("^-(%S+)=$");
            local isIndexComplete = stringifiedIndex:match("^%-%S+=(%S*)$")
            local nextIndexValue = tostring(callingArguments[currentIndex+1]):match("=(%S+)");
            --If "equals" is present, then that means that we can lookahead one index to check if the value is present.
            -- If equals is not present, then we have to look ahead 1 to see the equals, and another to find the value.

            local Value;
            if (doesIndexHaveEquals) then
                local ci = currentIndex;

                isSingleArgument = doesIndexHaveEquals;
                datumTemplate.name = doesIndexHaveEquals
                Value = callingArguments[currentIndex + 1];
                currentIndex = ci + 2; --wowie, switch-case would be pretty useful here

                if (tostring(Value):match("^%-%-") or tostring(Value):match("^%-%S+%=")) then
                    currentIndex = ci + 1;
                    datumTemplate.error, datumTemplate.reason = true, "valueless"
                    return datumTemplate
                end;

            elseif (isIndexComplete) then
                isSingleArgument = stringifiedIndex:match("^%-(%S-)=")
                Value = isIndexComplete
                currentIndex = currentIndex + 1;

                datumTemplate.name = isSingleArgument;
            elseif (nextIndexValue) then
                Value = nextIndexValue;
                currentIndex = currentIndex + 2
            elseif (callingArguments[currentIndex + 1] == "=" and callingArguments[currentIndex + 2]) then
                print'b'
                Value = callingArguments[currentIndex+2]
                currentIndex = currentIndex + 3;
            end

            if (not arguments[isSingleArgument]) then
                datumTemplate.error, datumTemplate.reason = true, "exist" 
                currentIndex = currentIndex + 1;
                return datumTemplate;
            else datumTemplate.value = Value end;

            if ((not Value) or (#Value == 0)) and arguments[isSingleArgument].type ~= "valueless" then
                datumTemplate.error, datumTemplate.reason = true, "valueless"
                currentIndex = currentIndex + 1;
                return datumTemplate;
            end
            
            if (arguments[isSingleArgument].type == "valueless") then
                Value = true 
                datumTemplate.value = Value 
                currentIndex = currentIndex + 1;
            end

            if (arguments[isSingleArgument].type ~= "valueless" and arguments[isSingleArgument].type ~= determineTrueType(Value)) then
                datumTemplate.error, datumTemplate.reason = true, "type" 
                currentIndex = currentIndex + 1;
            end
            --wow, i really should've just put currentIndex + 1, but c'est la vie
        else currentIndex = currentIndex + 1 end;

        if (not datumTemplate.error) then 
            datumTemplate.reason = nil end;
        return datumTemplate;
    end

    return _itr, callingArguments, currentIndex;
end
-- ^ all this. just to set some variable to true :troll:
-- Returns the Levenshtein distance between the two given strings
function string.levenshtein(str1, str2)
	local len1 = string.len(str1)
	local len2 = string.len(str2)
	local matrix = {}
	local cost = 0
	
        -- quick cut-offs to save time
	if (len1 == 0) then
		return len2
	elseif (len2 == 0) then
		return len1
	elseif (str1 == str2) then
		return 0
	end
	
        -- initialise the base matrix values
	for i = 0, len1, 1 do
		matrix[i] = {}
		matrix[i][0] = i
	end
	for j = 0, len2, 1 do
		matrix[0][j] = j
	end
	
        -- actual Levenshtein algorithm
	for i = 1, len1, 1 do
		for j = 1, len2, 1 do
			if (str1:byte(i) == str2:byte(j)) then
				cost = 0
			else
				cost = 1
			end
			
			matrix[i][j] = math.min(matrix[i-1][j] + 1, matrix[i][j-1] + 1, matrix[i-1][j-1] + cost)
		end
	end
	
        -- return the last value - this is the Levenshtein distance
	return matrix[len1][len2]
end
function cla.setupAutoComplete(_shell)
    _shell.setCompletionFunction(_shell.getRunningProgram(), function(shell, index, currentArgument, previous)
        local didErr, reason = pcall(function()
            -- Default to double-dash flags, if they provide single-dash then compensate for that as well
            local truePrevious = previous[#previous]
            if (currentArgument:match("^%-%-")) then
                local typedValue = currentArgument:match("^%-%-(%S+)$")
                local chosenString, Distance = "", math.huge;

                if (typedValue) then --Implement levenshtein distance between two texts to determine closest match
                    for name, value in pairs(arguments) do
                        if (name:sub(1,1) == typedValue:sub(1,1)) then
                            local levenshteinDistance = string.levenshtein(name, typedValue);
                            if  levenshteinDistance < Distance then
                                chosenString, Distance = name, levenshteinDistance end;
                        end
                    end

                    -- If the chosenstring doesn't match the currently typed argument then return ""
                    if (not chosenString:match("^(" .. typedValue .. ")")) then
                        return {""} end;

                    return {chosenString:sub(#typedValue + 1, #chosenString) .. " " .. "(" .. arguments[chosenString].type .. ")"}
                end
            elseif (currentArgument:match("^%-[^-]")) then
                local typedValue = currentArgument:sub(2, #currentArgument):match("(%S+)")
                local chosenString, Distance = "", math.huge;

                if (typedValue) then
                    for name, value in pairs(arguments) do --COPY AND PASTE IS MY FORTE. FUNCTIONS ARE MY DETRIMENT. RAGE AND SPLITER. SHATTER.
                        if (name:sub(1,1) == typedValue:sub(1,1)) then
                            local levenshteinDistance = string.levenshtein(name, typedValue);
                            if  levenshteinDistance < Distance then
                                chosenString, Distance = name .. (value.type ~= "valueless" and "=" or ""), levenshteinDistance end;
                        end
                    end

                    if (not chosenString:match("^(" .. typedValue .. ")")) then
                        return {""} end;

                    return {chosenString:sub(#typedValue + 1, #chosenString) .. " (" .. arguments[chosenString:gsub("(%=)$", "")].type .. ")"}
                end
                
                return {""}
            end

            return {""}
        end)

        if (not didErr) then
            prettyprint("red", reason)
            return {""}
        else return reason end
    end)
end

function cla:Parse(callingArguments)
    local didError = false;

    for datum in args(callingArguments) do
        if (not datum.error) then
            arguments[datum.name].value = datum.value
            arguments[datum.name].modified = arguments[datum.name].default ~= datum.value;
        else
            if (datum.reason == "exist") then
                prettyprint("red", ("flag %s does not exist\n"):format(datum.name));
            else
                prettyprint("red", ("./%s %s:"):format(select(2, pcall(function() error("　", 1) end)):match("%S-.lua"), ("%s"):format(datum.flagtype == 2 and "--" or "-") .. datum.name));
                prettyprint("lime", ("\t\t" .. arguments[datum.name].type))
                prettyprint("white", ("\t\t%s\n"):format(arguments[datum.name].description or "no description"))
            end
            didError = true;
        end;
    end

    return arguments, didError
end;

return cla;