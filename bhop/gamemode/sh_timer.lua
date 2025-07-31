function ConvertTime(ns)
    if (type(ns)=='boolean') then ns = 0 end 

    if ns > 3600 then
        return string.format("%d:%.2d:%.2d.%.03i", math.floor(ns / 3600), math.floor(ns / 60 % 60), math.floor(ns % 60), (ns - math.floor(ns)) * 1000)
    elseif ns > 60 then 
        return string.format("%.1d:%.2d.%.03i", math.floor(ns / 60 % 60), math.floor(ns % 60), (ns - math.floor(ns)) * 1000)
    else
        return string.format("%.1d.%.03i", math.floor(ns % 60), (ns - math.floor(ns)) * 1000)
    end
end 