function getfactors(number) -- Explicitly does not cover 0
    local factors = {1}

    local limit = math.sqrt(number)
    if limit > 100000 then
        error("Number too large")
    end

    -- Special handle 2's
    for l = 1, 64, 1 do
        if not (number % 2 == 0) then break end

        table.insert(factors, 2)
        number = number / 2
    end

    local factor = 3
    for i = 1, limit, 1 do
        --if not factor * factor <= number then break end

        for l = 1, 64, 1 do
            if not (number % factor == 0) then break end

            table.insert(factors, factor)
            number = number / factor
        end
        factor = factor + 2
    end

    if number > 2 then
        table.insert(factors, number)
    end

    return factors
end

function legalnumgen(number)
    local change = 0
    local parts = {}

    for i = 1, 1000, 1 do
    
        local factors = getfactors(number)
        if factors[#factors] > 1000 then
            change = change + 1
            number = number - 1
        else

            local f = 1
            for i, v in ipairs(factors) do
                local num = (parts[f] or 1) * v
                if num > 1000 then
                    f = f + 1
                    parts[f] = v
                else
                    parts[f] = num
                end
            end
            break

        end

    end
    return parts, change
end

function legalnumgenwrapper(number)
    number = number + 0

    local is_negative = false
    if number ~= math.abs(number) then
        is_negative = true
        number = math.abs(number)
    end

    local exp = 0
    for i = 1, 100, 1 do
        if number % 10 ~= 0 then
            number = number * 10
            exp = exp + 1
        else
            break
        end
    end

    local parts, change = legalnumgen(number)
    local result = {ismultipleiotas = true}

    for i, v in ipairs(parts) do
        result[#result+1] = pattern_list[v .. ""]
    end
    for i = 1, (#parts-1), 1 do
        result[#result+1] = pattern_list["Multiplicative Distillation"]
    end

    if change ~= 0 then
        result[#result+1] = pattern_list[change .. ""]
        result[#result+1] = pattern_list["Additive Distillation"]
    end

    if exp ~= 0 then
        result[#result+1] = pattern_list["10"]
        result[#result+1] = pattern_list[exp .. ""]
        result[#result+1] = pattern_list["Power Distillation"]
        result[#result+1] = pattern_list["Division Distillation"]
    end

    if is_negative then
        result[#result+1] = pattern_list["-1"]
        result[#result+1] = pattern_list["Multiplicative Distillation"]
    end

    return result
end