
function resoivior_avaible_s()
   global start_3 = time_ns()
   Max_power_for20M = ones(M_d,S)*1000
   for m=1:M_d-1
      m_a_max = m+20
      if m_a_max > M_d
        m_a_max = M_d
      end
      for s=1:S
         global resoivior_avaible = zeros(m_a_max-m)
         for i=1:I
            m_dis = 0
            m_connect = 0
            Connect = false
            for m_inner=m+1:m_a_max
               if Connected_s[m_inner,i,s] == 1 && Connect == false
                  m_connect = m_inner
                  Connect = true
               end
               if (Connected_s[m_inner-1,i,s] == 1 && Connected_s[m_inner,i,s] == 0) || (Connected_s[m_inner,i,s] == 1 && m_inner==m_inner )
                  m_dis = m_inner
               end
            end

            # compute how much power we acutlly can charge with if not to violate capacity
            if m_connect != 0
               addional_resovior =  (kWh_cap_s[m_dis,i,s]/po_cap_s[m_dis,i,s]/RM-kWh_cap_s[m_dis,i,s])/(m_dis+1-m_connect)
               for m_inner=m_connect:m_dis
                  global resoivior_avaible[m_inner-m] = addional_resovior
               end
            end
         end
         min = findmin(resoivior_avaible)[1]
         if min > 0
            Max_power_for20M[m,s] = min
         else
            Max_power_for20M[m,s] = 0
         end
      end
   end
   println(round((time_ns() - start_3) / 1e9, digits = 3))
   return Max_power_for20M
end


function resoivior_avaible_r()
   global start_3 = time_ns()
   Max_power_for20M = ones(M_d)*1000
   for m=1:M_d-1
      m_a_max = m+20
      if m_a_max > M_d
        m_a_max = M_d
      end
      global resoivior_avaible = zeros(m_a_max-m)
      for i=1:I
         m_dis = 0
         m_connect = 0
         Connect = false
         for m_inner=m+1:m_a_max
            if Connected_r[m_inner,i] == 1 && Connect == false
               m_connect = m_inner
               Connect = true
            end
            if (Connected_r[m_inner-1,i] == 1 && Connected_r[m_inner,i] == 0) || (Connected_r[m_inner,i] == 1 && m_inner==m_inner )
               m_dis = m_inner
            end
         end

         # compute how much power we acutlly can charge with if not to violate capacity
         if m_connect != 0
            addional_resovior =  (kWh_cap_r[m_dis,i]/po_cap_r[m_dis,i]/RM-kWh_cap_r[m_dis,i])/(m_dis+1-m_connect)
            for m_inner=m_connect:m_dis
               global resoivior_avaible[m_inner-m] = addional_resovior
            end
         end

         #println(resoivior_avaible)
         min = findmin(resoivior_avaible)[1]
         if min > 0
            Max_power_for20M[m] = min
         else
            Max_power_for20M[m] = 0
         end
      end
   end
   println(round((time_ns() - start_3) / 1e9, digits = 3))
   return Max_power_for20M
end



function resoivior_avaible_excel(Connected, po_cap, kWh_cap, RM)
   global start_3 = time_ns()

   global resoivior_avaible_all = ones(M_d, 20)*100


   for m=1:M_d
      m_a_max = m+20
      if m_a_max > M_d
        m_a_max = M_d
      end
      global resoivior_avaible = zeros(m_a_max-m)

      m_dis = 0
      m_connect = 0
      Connect = false
      for m_inner=m:m_a_max-1
         if Connected[m_inner] == 1 && Connect == false
            m_connect = m_inner
            Connect = true
         end
         if m_inner+1 > 1440
            m_dis = 1441
         elseif (Connected[m_inner] == 1 && Connected[m_inner+1] == 0) || (Connected[m_inner] == 1 && m_inner==m_inner )
            m_dis = m_inner+1
         end
      end

      # compute how much power we acutlly can charge with if not to violate capacity
      if m_connect != 0
         addional_resovior =  (kWh_cap[m_dis-1]/po_cap[m_dis-1]/RM-kWh_cap[m_dis-1])/(m_dis-m_connect)
         if addional_resovior > -0-1

         else
            println(addional_resovior)
            println(po_cap[m_dis-1])
            println(m_dis)
            println(m_connect)
            println((m_dis+1-m_connect))
            error()
         end
         for m_inner=m_connect:m_dis-1
            global resoivior_avaible[m_inner-m+1] = addional_resovior
         end
      end
      resoivior_avaible_all[m,1:m_a_max-m] = resoivior_avaible

   end

   return resoivior_avaible_all
end
