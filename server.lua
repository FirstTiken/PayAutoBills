ESX                 = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

MySQL.ready(function()
	MySQL.Async.fetchAll('SELECT * FROM billing', {}, function(result)
		for i=1, #result, 1 do
			local xPlayer = ESX.GetPlayerFromIdentifier(result[i].identifier)

			-- add society money
			TriggerEvent('esx_addonaccount:getSharedAccount', result[i].target, function(account)
				
				if account == nil then
				
					MySQL.Sync.execute('UPDATE addon_account_data SET money = money + @money WHERE account_name = @account_name',
					{
						['@money']       = result[i].amount,
						['@account_name'] = result[i].target
					})
					print(result[i].target.." a reçu un paiement, de $"..result[i].amount)
				else
				
					account.addMoney(result[i].amount)
					print(result[i].target.." a reçu un paiement, de $"..result[i].amount)
					
				end
				
			end)

			if xPlayer then
				xPlayer.removeAccountMoney('bank', result[i].amount)
			else
				MySQL.Sync.execute('UPDATE users SET bank = bank - @bank WHERE identifier = @identifier',
				{
					['@bank']       = result[i].amount,
					['@identifier'] = result[i].identifier
				})
			end

			MySQL.Async.execute('DELETE FROM billing WHERE id = @id', {
				['@id'] = result[i].id
			})
			
		end
	end)
end)
