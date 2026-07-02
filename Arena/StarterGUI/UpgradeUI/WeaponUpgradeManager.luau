local ReplicatedStorage = game:GetService("ReplicatedStorage")
local beliSenjata = ReplicatedStorage:WaitForChild("BeliSenjataFunction")


local wadah = script.Parent


local tombolMax = wadah:WaitForChild("ImageButtonMaxUpgrade")


local urutanTombol = {
	{
		Tombol = wadah:WaitForChild("ImageButtonShotugn"),
		Harga = 500,
		NamaItem = "Shotgun" 
	},
	{
		Tombol = wadah:WaitForChild("ImageButtonUzi"),
		Harga = 1500,
		NamaItem = "Uzi"
	},
	{
		Tombol = wadah:WaitForChild("ImageButtonRiffle"),
		Harga = 2250,
		NamaItem = "Riffle"
	},
	{
		Tombol = wadah:WaitForChild("ImageButtonSniper"),
		Harga = 1950,
		NamaItem = "Sniper"
	},
	{
		Tombol = wadah:WaitForChild("ImageButtonMachineGun"),
		Harga = 3750,
		NamaItem = "MachineGun"
	}
}

local tahapSekarang = 1


tombolMax.Visible = false


for indeks, data in ipairs(urutanTombol) do
	if indeks == tahapSekarang then
		data.Tombol.Visible = true
	else
		data.Tombol.Visible = false
	end
end


for indeks, data in ipairs(urutanTombol) do
	data.Tombol.MouseButton1Click:Connect(function()


		if indeks ~= tahapSekarang then return end

		print("Mencoba membeli: " .. data.NamaItem .. " seharga " .. data.Harga)


		local sukses = beliSenjata:InvokeServer(data.Harga, data.NamaItem)

		if sukses then
			print("Pembelian sukses!")

			data.Tombol.Visible = false

			tahapSekarang = tahapSekarang + 1

			if urutanTombol[tahapSekarang] then

				urutanTombol[tahapSekarang].Tombol.Visible = true
			else

				print("Semua senjata sudah MAX!")
				tombolMax.Visible = true 
			end
		else
			print("Uang tidak cukup untuk membeli " .. data.NamaItem)

		end

	end)
end