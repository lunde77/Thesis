

# Static Parameters
T = 24 # hours on a day
M = 60 # minutes in an hour
M_d = T*M # minutes per model, i.e. per day

Power

SoC_start

Connected

po_cap

kWh_cap

SoC_syn = zeros(M_d)
m_d = 1
while Connected[m_d] == 1
        if m==1
                SoC_syn[m] = SoC_start +  Power[m]/60
        else
                SoC_syn[m] = SoC_syn[m-1] +  Power[m]/60
        end

        if SoC_syn[m] > kWh_cap[m]/po_cap[m]
                Power[m]


        m_d = m_d + 1
