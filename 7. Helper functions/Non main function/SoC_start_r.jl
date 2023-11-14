
function SoC_starter_realized(kWh, Po)

    I = size(kWh)[1]

    SoC_strart = zeros(I)

    for i=1:I
        SoC_strart[i] = kWh[i]/Po[i]
    end

    return SoC_strart
end
