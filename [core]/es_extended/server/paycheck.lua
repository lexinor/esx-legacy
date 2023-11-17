function StartPayCheck()
  CreateThread(function()
    while true do
      Wait(Config.PaycheckInterval)
      for player, xPlayer in pairs(ESX.Players) do
        local jobLabel = xPlayer.job.label
        local job = xPlayer.job.grade_name
        local salary = xPlayer.job.grade_salary

        if salary > 0 then
          if job == 'unemployed' then -- unemployed
            xPlayer.addAccountMoney('bank', salary, "Welfare Check")
            TriggerClientEvent('esx:showAdvancedNotification', player, TranslateCap('bank'), TranslateCap('received_paycheck'), TranslateCap('received_help', salary),
              'CHAR_BANK_MAZE', 9)
            if Config.LogPaycheck then
                ESX.DiscordLogFields("Paycheck", "Salaire - " .. jobLabel, "green", {
                    { name = "Joueur", value = xPlayer.name,    inline = true },
                    { name = "ID",     value = xPlayer.source,  inline = true },
                    { name = "JOB",    value = jobLabel,        inline = true },
                    { name = "Montant", value = salary,         inline = true },
                })
            end
          elseif Config.EnableSocietyPayouts then -- possibly a society
            if Config.PayCheckOnlyOnduty == true and Player(xPlayer.source).state.onduty == true or Config.PayCheckOnlyOnduty == false then
                TriggerEvent('esx_society:getSociety', xPlayer.job.name, function(society)
                    if society ~= nil then              -- verified society
                        TriggerEvent('esx_addonaccount:getSharedAccount', society.account, function(account)
                        if account.money >= salary then -- does the society money to pay its employees?
                            xPlayer.addAccountMoney('bank', salary, "Paycheck")
                            account.removeMoney(salary)
                            if Config.LogPaycheck then
                                ESX.DiscordLogFields("Paycheck", "Salaire - " .. jobLabel, "green", {
                                    { name = "Joueur", value = xPlayer.name,    inline = true },
                                    { name = "ID",     value = xPlayer.source,  inline = true },
                                    { name = "JOB",    value = jobLabel,        inline = true },
                                    { name = "Montant", value = salary,         inline = true },
                                })
                            end
    
                            TriggerClientEvent('esx:showAdvancedNotification', player, TranslateCap('bank'), TranslateCap('received_paycheck'),
                            TranslateCap('received_salary', salary), 'CHAR_BANK_MAZE', 9)
                            else
                                TriggerClientEvent('esx:showAdvancedNotification', player, TranslateCap('bank'), '', TranslateCap('company_nomoney'), 'CHAR_BANK_MAZE', 1)
                            end
                        end)
                    else -- not a society
                        xPlayer.addAccountMoney('bank', salary, "Salaire")
                        if Config.LogPaycheck then
                            ESX.DiscordLogFields("Paycheck", "Salaire - " .. jobLabel, "green", {
                                { name = "Joueur", value = xPlayer.name,    inline = true },
                                { name = "ID",     value = xPlayer.source,  inline = true },
                                { name = "JOB",    value = jobLabel,        inline = true },
                                { name = "Montant", value = salary,         inline = true },
                            })
                        end
                        TriggerClientEvent('esx:showAdvancedNotification', player, TranslateCap('bank'), TranslateCap('received_paycheck'), TranslateCap('received_salary', salary),
                        'CHAR_BANK_MAZE', 9)
                    end
                end)
            end
            
          else -- generic job
            local paycheckSucess = false
            if Config.PayCheckOnlyOnduty == true and Player(xPlayer.source).state.onduty == true or Config.PayCheckOnlyOnduty == false then
                xPlayer.addAccountMoney('bank', salary, "Salaire")
                paycheckSucess = true
            end
            if Config.LogPaycheck and paycheckSucess == true then
                ESX.DiscordLogFields("Paycheck", "Salaire - " .. jobLabel, "green", {
                    { name = "Joueur", value = xPlayer.name,    inline = true },
                    { name = "ID",     value = xPlayer.source,  inline = true },
                    { name = "JOB",    value = jobLabel,        inline = true },
                    { name = "Montant", value = salary,         inline = true },
                })
            end
            if paycheckSucess == true then
                TriggerClientEvent('esx:showAdvancedNotification', player, TranslateCap('bank'), TranslateCap('received_paycheck'), TranslateCap('received_salary', salary),
                'CHAR_BANK_MAZE', 9)
            end
          end
        end
      end
    end
  end)
end
