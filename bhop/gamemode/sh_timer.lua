function ConvertTime(ns)
    if ns > 3600 then
        return string.format("%d:%.2d:%.2d.%.3d", math.floor(ns / 3600), math.floor(ns / 60 % 60), math.floor(ns % 60), math.floor(ns * 1000 % 1000))
    else
        return string.format("%.2d:%.2d.%.3d", math.floor(ns / 60 % 60), math.floor(ns % 60), math.floor(ns * 1000 % 1000))
    end
end