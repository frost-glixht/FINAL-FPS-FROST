--[[
	FROST BOOST FPS  (Roblox / Luau, mobile friendly)
	FPS boost, FPS + ping counter, player hider, nametag changer, auto code redeemer.
	(The auto clicker / macro lives in its own script: frost_clicker.lua)

	Drag the header to move it. X hides the panel, tap the snowflake to reopen.
	On PC, RightShift also toggles the panel.
]]

------------------------------------------------------------
-- CONFIG (edit these)
------------------------------------------------------------
local CONFIG = {
	CodeCommand = "/code",       -- chat command used to redeem ("/redeem" etc.)
	DefaultCodes = {},           -- codes pre-stacked on start, e.g. { "WELCOME", "UPDATE1" }
	AutoRedeemOnStart = false,   -- true = redeem DefaultCodes a few seconds after start
	RedeemDelay = 2,             -- seconds between codes (avoids chat spam limits)
	ParentToPlayerGui = false,   -- set true if you can't type in the boxes (keyboard won't open)
	ShowIntro = true,            -- black "OPTIMIZED BY FROST" intro on start
	SliceBudget = 0.0015,        -- seconds of heavy work per frame (lower = smoother, but slower to apply)
}

-- Optional overrides from a loader, so you never have to edit the hosted file:
--   getgenv().FrostBoostConfig = { DefaultCodes = { "WELCOME" }, AutoRedeemOnStart = true }
do
	local ok, env = pcall(function() return getgenv() end)
	if ok and type(env) == "table" and type(env.FrostBoostConfig) == "table" then
		for k, v in pairs(env.FrostBoostConfig) do CONFIG[k] = v end
	end
end

------------------------------------------------------------
-- EMBEDDED ASSETS (do not edit)
------------------------------------------------------------
local MC_B64 = [==[
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
]==]

local BG_B64 = [==[
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
oJ/p1FJr7Ez2fkOP968V/EeX9o9M4z8Sba5sKthoKqSdaLhO5nHl5YvdRW+fU820+8nYXcLmjGDqU3mHMspPs8H1dX0CnpWmUrud
7TuJ158tJUV8xrGW89z6XhvwvS4i1KrVvk3ZWiTnBPHtJPaOfLo2zrjjx8HHbPTzXPk6rOR8arr2s3cnJ3902v8AZyaS+pHI07i/
V7GovaXDuaa3hW6/buj360s7WzoqjaW9KjTSwoU4KK+w6f4jcJ2WoaLdahbW8KV/bQdXnpxS9pFdWpefTPU4Ydbhll23HUerP8Py
wx7pdupahx9QVpTen0JSuZxzJVfo035fzjrFxxNrdzPLv60c/o0nyr4I+t4f8GT4kqyuruU6WnUpcrlHpKrL9WL+9nsul6Jpmk0V
S0+yo0Ipbxj85+97s3y9Tx8V7ZN1z4ej5OWd1uo8IseLdasqifyydaKfWnX+cn+KPReGuIbbXraUqa9lcU0va0W8teqfdHZuJOGN
O16xq0a9vTjXcX7KvGKU4S7PPdeh4HYX13ouoSrW0vZ3EFOm8rK8n/56F4+THqJdTVjPPwZcFm7uV2vxAsNKt67uKVwqV9U6zt4r
Kn/Of6v4nT6FzXoNuhWqUs7uE3HPwPrcOcO6pxXqE/YZcebNe6q5ajnzfd+h65oHh/oekRjOpQV7crercLKz6R2Rrk6jDhnbfNTh
6Xk5vOPiPEaFne3snKhbXFeT3dOnKefgjeromsqKdTTL/lSws28+i+B+kIQjCKjCKjFbJLCRR5r+IX4xeyfhs+cn5kp1Lqxrfwc6
1tVXR8rcJfgxVa1S4q89zWnOb6OdSTkz9J3un2d/TdO9taNxB9qtNS+86JxL4YWdzCdfQZ/Ja6WfYTbdOXonvH7jrx9dhlf1TTjy
/h/JjP03bhcG6ZptpZO4sbiN1VqLFSsljH83G6+s7EeQ21zqXDOqzi4ToXFJ8tWjPaS8n5ryfwO265xlRjo1Kemyxd3MX0fV0ezz
6+XxO2WNt3PLxS68V9XXuKLDRs0pt1rnH8TTfVf0n2+86PqPGmr3kmqNWNpTe0aS6/2n1J4U4Xv+Kr+caUnChF5r3M+qjn75PyPY
9B4K0PRacfY2cK9dLrXuEpzb9M9F9Ry5Obj4fF816eHpuTm8+o8Nj+Wb/wCdH8oXGe8VUkOVtrNr86VHUKOO7hUifpJJJYSwvQZw
/P3+16v+nT+5+dbPinWrJpRvZ1Et4Vvnr7ep2nTeP7WdvP8AKVCVKtCOY+y+dGo/JeTPTdW4d0jWKbhqFhQqt/p8vLNe6S6njHiB
we+GLulUt6kqtjcNqm5/Sg1+i/P0Z24uo4+a9tmq8/N0nJwzu3uPm8R8S3WuzjGtCFK3pycqdOPbtlvuz0zwXpKPDt5VS6zu2s+e
Ix/ecfwu4R0+Wi0tX1C2p3NxcNukqseaNOCeFhPpl4zk9Go0qdCChRpwpwW0YRSX2HDquoxsvHjHq6TprjZyWrAAPA+i/MlWrK21
GdSlJRnSruUX5NS6HaNM4+u6dWMdTpU61JvrOnHlkvXGzPaZ6bYTzz2VtLO+aMXn7Dy3xW4Ts9Nt6Wr6ZRjQhKp7OvSgsRTe0ku2
2H9R9Xi6rHkymNj43N0WXHjc5duy29eldUIXFvNVKVSPNGS7os6V4aXs50buym240mqkPTPRr44O7YO1mrp4zSKXQF0Otalq+o6r
e1dG4UoutdQ6XF30VOh6ZfTP/iyYtk81uS5XUfU1fXdO0eP+XXMY1H9GlH505e5I61ccdXE3/kOlNw7SuKvK39SNaXhXry5q09R0
93E+spVFUnJv1kfI1jh3X9Dg6moacqlvHe4s5OcV6tbo8XN1HN64cZf8/wDx+g/Dvw78Oys/O8mU/iTU/wA3z/6j7uhcaUr2+hY6
lbfI7ip0pyU+aE35Z7M7a0eP6B8jveLNMdyo1qEqjilnpzYbi39a2PYXudem5by8cyymr8vD+MdFx9F1d4uK7w1LL78X+WcuhDZc
yD0Pl7AIEXHoUkNbDACKBS2GTPYCCSiS1IeRpkgiCxABpAADAuOx5Fxi/wD1JqP9Z/hR67HY8i4x/wBJdR/rP8KN8X3JXv8AofXR
dP8A2an/AHUc44Oh/wAi6f8As1P+6jnHw8vur9Jj9sTUgqkJQltJNM8//NLoqfS+v0vLmh/0noQGsOTPD7bpnPiw5Pum3n35ptG/
36//ALUP+k+brPhP7O2nU0i/nUrRWVRrxXz/AEUls/qPUwOuPV80u+5yvR8Nmu1+YK069ODtKrnGNOo26Uv0ZbPp2Z6z4KJfkbUZ
d3dJf/BfvPP/ABA9kuMtV9hjl9t1x+tyrm+3J6D4KfyHqH7X/gie/qsu7g3++nzukx7eo1+23opjeUFdWle3k8KrTlBvG2Vg2A+Q
+04Wj6bb6Rpltp9pHFKhTUF6+bfq31OaY3l3b2NtUubytCjQprM5zeEkdIu/FXQ6NZwoW95Xin/GRgop+7LydMOPPk+2bcs+Xj4p
rK6d4uq9O2tqtxWly06UHOT8klln5z0jTrjiTiCNrbrlndVpTlLtCLbbb9yO18aeIz1vTpadplvUt6FXpWqVWuaS/VSWy8z7Hgtp
cY219qs4/PnNUKb8kknL4tr4Ht4scun4ss8vdeHlzx6nlxwx9R6Do2l2mjadRsbGmoUaa+uT7t+bZzQA+fbbd19KSSagEpJ7NPHk
eR+JnF91V1KrpGnV5Ubag+WtKnLDqT7rPktseeTo9veX+n1adzQrXFCp9KE03HP7z28fQ5Z491ung5fxDHDPtk3p+lQOs8A8SPiT
Rva1+VXlCXs66j0TfaS96+1M7MePPG4ZXGvdhnM8ZlPVdQ8ROFaevaZK6toJajbRbptLrUit4P8AD1954U03LCWXsl6n6kPz3xjZ
w0fjW7pKOKUbiNaK8oyxLH2s+j0PLdXCvm9fwyWck+fb27hXR6Wh6Fa2NOKUowUqr/Wm/pP4/cfWJhKM4KUXmMllNd0UfNytt3X0
scZjJI4Oravp+jW6r6ndU7enJ8sXN9ZPySXVnC0/i3QNRqKlaarbyqPaEpcjfuUsZMOM+FLfimzpUqtedCtQblSqRWUs7pruuiPK
tY8OeIdO5pUqEb2kv0rZ5f8AZfX4ZPTw8XFnP1Zarzc/LzceX6cdx7ueaeNN7Q+RWFgmnXdV1mu8YpNfa39h0Gz4l4i0dO0o6hd0
FHp7Kr15fqkuhwK1zc6pe+1vLl1K9V4dWtP732R6+HorhnMrfDx9R10z47jJ5r2Xws1i2veGrexjUirq0ThOm315ctqSXlhncz80
XlnfaVXirinUoVGswkpYyvNNHsvhPWq1+E1OvVnUn8oqLmnJyfbuzh1fTTDfJL7rv0XVfU1hZ6juQAB4X0AeY+MOv2s7Clo1tVhV
ruqqlblefZqOyfq29vQ87uNR1Krc1KPy27nzVHFR9tJ567bn1dM4K1K7qqV7H5JRz85zw5v3L959Pi6SceUzyr4/P13fjcJNPp+G
dnONO9vJLEZuNOL88dX+B3pLqcaws6FhaU7W2hyUqaxFfi/U5Udjvld3bwx8fi6/radoVeraf5zUcaNH0lN4TPtW+k3/AAnwrQte
GbG3vb2MlKv7er7P2ja+fNvu8/Ydf45hNaC7mnBzdpXpXDiu6jLLO51J317Wt9RsLqlW0mdnKUrT2Scq8pLMWp9unQ8XVW+H0+gm
Osr8rstfta9KnTqTpxvXTTnb058yU8dYqWz69BcMazLiDSvllWwrWeakqfsq3VtLpn3fuZ1+pLRtMc76403VKdW2tad5Ut40nNRU
njlTW8k91nsdsta93VvbiNW3hCzUISoVeb5020+ZNdsdPifN4Pr9uX15N/Gn1ub6PdPpW6+dz5eYeIHDNnod9S4i02kqKoXVOd1R
gsRlFyXzkuzX4nbFOM4qcXmMllPzTOB4o3MP/py+pfSncuFvSit5Sclt8Gcq1pyo2tClL6UKcYv3pJH2eLdwlr4HU3ef+jSSMzRv
BGTrHn0EUiUNbhpYABEApbD7CewGYmihF0hYHgA2J4AAC7ltQxrcQ1uX4GiPIeMXniTUf6z8EevLY8i4vX/qTUf6x/cjfD9yV7/o
n8jWH7NT/uo5pwtE/kaw/Zqf91HNPh5e6/SY/bE1JqnTlOWcRTbx6HSo+KPDku94vfQ/7ncrlZt6q/mP7j8zWFs7u9t7WM1B1qig
pNZxl4PX0vBhy77vh5Os6jPh12/L2n85/Dn693/yH+8+brXipZxtZw0a2rTuJLEaleKjGD88ZbfuOsx8PbjvqNL/AJT/AHnLtPD6
jGad3fzqRW8aUOXP1vJ6Z03BLt4Mut58pqOg3EqtapUr1nKc5zbnN95Pq/rPW/BRY0K//a/8ETq/iBYW2naZp1CypRpUlVnlLu8L
q33Z2nwV/kG//a/8ETfV3fBuL0P/AJo9EAAZ8d9t4z4ua3Wu9c/JUJtW1pGLlFPpKo1nL9yaXxOBoPA9XULOF3e3DoU6i5qcIxzJ
rs3nY+Zx3Nz4v1dvtcSXwSR6tYJKwtktlRh/dR9rH/t8WMxfnufK58uVryfi3RaOh31G2oValXnpc8pTSXXLXTHuPXfCulGnwVZS
iutSVSb9/O1+B554pUXG/sa+Ok6MoZ9U8/id58IbyNxwjChn51tXqU2vRvmX944dXbeGX+Xo6DU5f8O7g9gA+Y+y/NlL/wC4cQQ9
v875Rd/P9eafX7z0XxBoU5cNVpcqzRnB0+n0euOn1M6BrtnW0Lia6otNTt7nnpt9455ov4YPt8VcXW+r6VG0taVWEqklKrzpYWOu
F59T72rl22en5nLxlZX1PBWrJavqVFN8kreMmvVSx+J68eX+C2nTjHUdRmmoS5aMH546y/A9QPldXZea6fb6KWcEB4d4vxS4wbXe
2pt//I9xPA/E26jd8Z33K8xoqFL61FZ+1s30Uv1P8M9fdcX+XfvDHi6jqWnUtJvqqjf28eSnzP8AjoLbHql0a+s78fluE5U5qdOT
jOLypJ4afmd50DxO1bT4RpajCOoUV05pvlqJf0u/1o7c/RW3uw/2cOn66STHk/3e1gdQ0jxH4f1DljWrzsqr/RuI4Wf6SyvuO2Ua
1OvTjUo1IVKcusZQkmn9aPBnx5YfdNPo4cmGf23bhatomm6xRdLUrOlXWOkpR+dH3S3R5Dx1wNU4fTvbCU62nyeHzfSot7J+a9fi
e3GN7a0b20rWtzBTo1oOE4vumdODqM+K/wAOPP02HLj68/u/NFe6rV6dGlWqOcaMXGnnss5wez+EX+iK/aan4HjGpW0rLULm0k8u
hVlTb8+VtHs/hD/ogv2mp+B9Hrrvh/y+d0GOuaz+HdgAD477T80U/wCWI/tP+M9qa6v3niU5ew1KU5J/wddtr3SPSrHjTSLyqqc5
VbaUn0daOI/FbH3c5bJp+Y8br6HEEtWp6dKrodKjWuoSUnSq/px7pPszqulcS/lnjXTKdF16PLZV43VpUyvZ1E+67+jO36tpVnrF
tGhfQlUpKXMlCpKHX3xZ1LX+ErbQ6P5c4acbC8sYyqT5pylCtDHWLy31Z4+SZ73PT1cN45Ljl7dw1W9sLCyqVdTq06du04yU+vNn
sl3PicFXnE2nU6v5K0W5u+H3NytqdzUjTqwi/wBTO8fQrw90ifE9y+I+JIqVWm0rWxlFqNFNZU2nvndfH3eonPm58ftk29nTdLlP
1W6dajxVWisXXDmt0pd+W3VRfGLIr8TXFxBwstG1Pmx/raHs/tk8I5Wm8V6bqXEV5odsq3yq0i3UlKGIPDSaT9G12Pvdupw7scb5
xei4Z8k1M/8Ah43qt5qVnxDaanxfYqnp0Mq0VCqqkLeo/wBKeN5Y/wCx3KFxSqW6uKVSM6Uo88ZxeU1vnJ9PiKxs5WdZX0KTspwf
tVV+il3z5e88UsZ3OpXtXhzQ9Rq0OHrivNU7qrB800lmVOD7+7pnv5P1Tmmpr2+fn017rvxJ7c7hniq9lp6s9Ntauo6jUr1Kkudv
2dKLl05pfgei0HVdGm66gqvKudQbcVLvjPY61a8B2VhT5LHVNWt47tU7lJN+eMHZ4Q9nTjDmlLlSXNJ5b9X6nThmcn63Lny48st4
KBMQHZx2tPAJkDGitBPYZM9jIkQMWS7QxonI0zNWDuLAwNSIBx6sRUCjRLoeRcY/6Sal/Wf4UeurY8m44oyo8S3nNtVamn6OKNcP
3JXvWirGj2K8ren/AHUc0+NwfqNLVOGtPuaMk/4GMJpfozisNfFH2T4ucsysr9JhZcZYiss0Zr+a/uPzXonTXLD0uYf3kfonXNQo
6XpF3e3ElGFGlKXXu8dF9bwj8+cM0ZXPEOnwisv28ZP0SeX9x9DoPtyr5n4jZvGPZHuAAdXz3SfE/wDzOw/rZ/3Ufe8Ff5Dv/wBr
/wAET4XifSlLT7KqvowrST+tdPuPqeCd5TdpqVi5JVY1I1ku7i1yv4NL4k6jz09erorrnj04AFJpRbk0kt2z5L7b87ccrHF2sftM
z1iw/wAxtv6qH91HkPEt1DVOJdQubb50K9zL2bX6SzhP6z2ChB0qFOm94QjF/UsH28p+jGPznJd53TrviDpzvtBlVprNS1l7X/8A
XaX2dfqPieEmvQ0vW56fczUaF+lGLb6RqL6Pxy18D0CcVOLjKKlFrDT2aPIuLdBq6FqDdJS+SVXzUKi/R/mt+aMyTPC4VeLO8eUy
j9FAed+H3H9HUKVPTNbrRp30Uo0683iNfyy+0vvPRD5PJx5ceWsn3uPkx5Me7F1zizg/TuJoxncc1C6gsQuKa648mu6Oq2fhJRjX
UrzVZ1KSf0KVFRb+tt4PTQN4dRy4Y9uN8MZ9NxZ5d2U8uNpthbaZZUrOxpKlQpLEYr/zqzkgcbUL+1021ndX1eFChBfOnN4X/d+h
y82u3jGfww17VaGi6Tc6hctclGGVHvKXaK97PzvbUrnXNbhS5s3N7cYcn+tKXV/aff494wq8S3UaVBSpadRlmnB7zf60vwXY+Jod
7LRtcsr2rSk/k1aM5Qaw2u/2M+t03DeLC3+qvjdT1GPLySf0x79onDmmaLYQtLS1p4S+fUnBOVR93Jnydf8AD/Q9X5qkKPyK4f8A
rLdJJ++Oz+w7Hp99balZ07uyrRrUKizGcX/5h+hyT5k5OTHLe/L6t4uPLHWvDxy+8KdXozfyK7tLiGenM3Tl8MNfady8OuGdR4ct
bqOo3EJe2lFwo05OUYYzl5836eR3EDpn1XJyY9uTnx9Jx8effiBSajFuTSS6tsZ554mcZ0rK1raNplRTvKsXCvUi/wCJi91/Sf2H
Pj48uTLtjry8uPFj3ZPKdbuo3usX91D6Na4qTj7nJtHrng1cRqcMV6Kfz6N1LK9Gk1+J5do3D13q1lfXVBYhbU249P4yS68q+rL+
B9nwz4kp6DrMqN5PksrxKE5PaEl9GT9OrT9/ofW6nDv4rjj8PjdLyzHm7svl7qAoyUoqUWmmspruM+K+66RrnhrpmqajVvaVzXtZ
Vpc1SFNJxcnu1nbJ0bjfgerw3Rp3dvXlc2c5ckpSjiVOXbOOz8z3A6l4o16VHg28jVa5qsoQpp95cyf3Jns6fqOTvxx3uPD1PS8X
ZllJquo+Hmqzu7KrYV5OU7bDpt78j7fU/vN+OFO9Wk6JTlj8p30KVT+rTzI6/wCGqk9YuZL6Kt3n+0sHZdaap8Z8JVan8WrqpDL/
AFnFYPbzTVuny+DVzkr0ynThThGFOKjGKUUktktkWCA+M/ROr6BxHoOqcRajZ6fb+z1CnlVazoqLrKL5X87d4fmdoOtcP3/DF3rm
ox0WNv8AlFN/KpQpOMp4eG8tdVnfHc7Kazmqxx715u/9Hy+JNFste0qpY6jTlUoNqbjGbjlx6rqux0Pj7T6VjwxRuNOpQofkqtTr
0YU1hRinhr7T0u5moW9ST7RZ0Pj6rGnwbqzm96HKve2kj0dNPO3l6v3I5tvWjcW9KtH6NSCmvc1kbOJotOVLRbCnP6Ubamn/AGUc
tnvj45AAIfIBoQFGpE9yyZIkaQ9iShMVCBBgEQUgAC+ohoqJKKXmK1PSjq/HOgT1W2hd2kOa6oJpwW9SHkvVHZ08jEuruJY8o4V4
q1Hhe5n8mxUoTf8AC29TPK35+jO+w8W7N0sz0q4VTH0VVi18f+xWr8NaZq0nUr0XCs96tJ8sn7+zPi/m+tObKv6/L5ckcjPj4eS7
ynl0w6jm45rG+Hw+LuMdQ4nlGlOKoWcJZhbwecvzk+7OwcCcPVNPg9RvYONxUjy0qb3hF7t+r+4+ppHC+maXNVaVJ1ay2qVnlr3L
ZH2jVuOOPbhNRztyzvdlfIDIshkwrh61p1PVtNrWdV45182X6slszymlU1ThbWlUpOVveUHvjKlH8Ys9jOHqWl2WqUfZX9vGrFfR
e0o+57o1jlqavpPMu4+Xp/i5SdBLUNLqKsl1lQqJxf1PqvtPjcV+JF5rFpUstPt3Z29RctSTnzVJrusrokcqr4f6fKbdG7uacf1W
oyOXYcFaTazU6yqXUlsqr+b8EZnDwY3ukdsuq58p22us8C6BUvL2nqNzBq1oS5oZX8ZNbY9Eel5JjGMIqMIqMYrCSWEkM1ll3Xbj
IfMce+tLe/tp213SjUpTWHF/evJm4GVeW8Q8H3mmznVs4yubTfMVmcF/OX4ovQePNe0WEaMbhXVvHoqVynLC8k90enPofN1DQNL1
FuV1Z03N/px+bL4o3bjlNZzZjllhd43Th2Xi7byile6TVhLu6NVSXweDlz8WtJUfmWF7J+T5F+J8S44B02bbo3FzS9G1JfccdeH1
DPXUauP6pfvOf5bp78O/53nny5mp+LN3Ui4aZp1Og3tUrT52vqWEdLvNQ1niW9XyircXtbPzYJdI+5Loju1rwRpFFp1vb12u054X
wR2CztbaypeytKFOjDyhHGff5m8cePj+yOPJzcnJ91dX4Z4Lhayhd6so1Ky6woLrGL85eb9NjkcX8KflWTvbFxjeY+fBvCq49ezO
0pjyO/Le2O14/YanrXDF5KNtWr2dVP59KS+bL3xfR+87jp3i3e0ko6jp1GvjedGbpt/U8o7PeWdre0/Z3dCnWj5VIp4Ov3fA2j12
3SVe3b/2c8r4PJcpxcn34unHy8nH9tfSp+LWlyXz9OvIvyTg/wATK58W7SMH8l0uvOXb2tSMV9mT4j8PLbPzNQrJetNP8TSjwBYR
f8NeXNT0iox/ec/y/T/s63ref93ytc8Q9d1WEqVOrGyoy6ONvlN++T6/DBwtB4VvtWnGrWUre1by6s186X9Fd/ed60/hzSdPkp0L
SMqi2nVfO/tPr5wdZccJrCaebLPLO7zu06faUNPtKdraQ5KVNYS/F+bOhcYcJVKVapf6XSc6E25VKMF1pvu0u6+49A50VzeRjG3G
7NPMeGuOtY4fhG3hONzaR6KhXy+X+i917tjult4uWEor5VplzTl39nOM19uDTU+HNJ1OTncWsVVe9Sk+SX143+s+HV8PrJyzSvbi
C8pRjL9wy4+Dku8p5dsOo5uOalfVvfFu1UWrHS605dnWqKKXwydD4h4h1Tii8pu7fMk8UbelF8sc+S3b9TtNDgCwjJOteXNReUVG
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
jA1pNpwwwUA0bSBTJM1QNbCHEsSmNCGVH//Z
]==]

------------------------------------------------------------
-- Services
------------------------------------------------------------
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Stats = game:GetService("Stats")
local TextChatService = game:GetService("TextChatService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

local conns = {}
local cleanups = {}   -- functions run when the script is executed again
local onReady = {}    -- functions run once the panel is ready (after the intro)
local function track(c)
	conns[#conns + 1] = c
	return c
end

-- if the script is executed again, shut the old copy down first
do
	local ok, env = pcall(function() return getgenv() end)
	if ok and type(env) == "table" and type(env.FrostBoostCleanup) == "function" then
		pcall(env.FrostBoostCleanup)
		task.wait(0.6)
	end
end

------------------------------------------------------------
-- Helpers
------------------------------------------------------------
local C = {
	ice = Color3.fromRGB(120, 220, 255),
	blue = Color3.fromRGB(0, 140, 220),
	green = Color3.fromRGB(0, 170, 110),
	red = Color3.fromRGB(200, 55, 70),
	gray = Color3.fromRGB(70, 78, 98),
	dark = Color3.fromRGB(10, 14, 24),
	text = Color3.new(1, 1, 1),
	dim = Color3.fromRGB(190, 200, 215),
}

local function new(class, props, parent)
	local o = Instance.new(class)
	for k, v in pairs(props) do o[k] = v end
	o.Parent = parent
	return o
end

local function corner(inst, r)
	return new("UICorner", { CornerRadius = UDim.new(0, r or 8) }, inst)
end

local B64CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
local function b64decode(data)
	data = data:gsub("[^%w%+/=]", "")
	local lut = {}
	for i = 1, 64 do lut[B64CHARS:byte(i)] = i - 1 end
	local out, n = {}, 0
	local byte, char = string.byte, string.char
	for i = 1, #data, 4 do
		local a, b, c, d = byte(data, i, i + 3)
		local v = lut[a] * 262144 + lut[b] * 4096 + (lut[c] or 0) * 64 + (lut[d] or 0)
		n += 1
		out[n] = char(v // 65536, (v // 256) % 256, v % 256)
	end
	local s = table.concat(out)
	if data:sub(-2) == "==" then
		s = s:sub(1, -3)
	elseif data:sub(-1) == "=" then
		s = s:sub(1, -2)
	end
	return s
end

-- writes the embedded file once, then returns a usable asset url (or nil)
local function loadAsset(fileName, b64)
	if not (writefile and getcustomasset) then return nil end
	local ok, asset = pcall(function()
		if not (isfile and isfile(fileName)) then
			writefile(fileName, b64decode(b64))
		end
		return getcustomasset(fileName)
	end)
	if ok then return asset end
	return nil
end

local function getParent()
	if CONFIG.ParentToPlayerGui then
		return player:WaitForChild("PlayerGui")
	end
	local ok, ui = pcall(function()
		return (gethui and gethui()) or game:GetService("CoreGui")
	end)
	if ok and ui then return ui end
	return player:WaitForChild("PlayerGui")
end

local old = getParent():FindFirstChild("FrostBoostFPS")
if old then old:Destroy() end

------------------------------------------------------------
-- Window
------------------------------------------------------------
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local cam = workspace.CurrentCamera
local vp = cam and cam.ViewportSize or Vector2.new(800, 600)
local W = math.clamp(vp.X - 20, 200, isMobile and 236 or 264)
local H = math.clamp(vp.Y - 30, 300, 392)

local gui = new("ScreenGui", {
	Name = "FrostBoostFPS",
	ResetOnSpawn = false,
	IgnoreGuiInset = true,
	DisplayOrder = 999,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, nil)
gui.Parent = getParent()

local main = new("Frame", {
	Name = "Main",
	Size = UDim2.fromOffset(W, H),
	Position = UDim2.new(0.5, -W / 2, 0.5, -H / 2),
	BackgroundColor3 = C.dark,
	BorderSizePixel = 0,
	ClipsDescendants = true,
	Active = true,
	Visible = false,
}, gui)
corner(main, 14)

local NEON = Color3.fromRGB(0, 170, 255)
local stroke = new("UIStroke", { Thickness = 2, Color = Color3.new(1, 1, 1) }, main)
local grad = new("UIGradient", {
	Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 200, 255)),
		ColorSequenceKeypoint.new(0.35, Color3.fromRGB(150, 225, 255)),
		ColorSequenceKeypoint.new(0.7, Color3.fromRGB(0, 110, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 200, 255)),
	}),
}, stroke)

-- background: the Frost logo image (or the blocky texture, from the THEME tab), with a shade
local bgAsset = loadAsset("frostboost_v4_bg.jpg", BG_B64)
local mcAsset = loadAsset("frostboost_v4_mc.jpg", MC_B64)
local bg = new("ImageLabel", {
	Name = "Background",
	Size = UDim2.fromScale(1, 1),
	BackgroundColor3 = Color3.fromRGB(70, 160, 220),   -- icy blue fallback if the image can't load
	BorderSizePixel = 0,
	Image = bgAsset or "",
	ScaleType = Enum.ScaleType.Crop,
}, main)
corner(bg, 14)
local function setBackground(useBlocky)
	if useBlocky and mcAsset then
		bg.Image = mcAsset
		bg.ScaleType = Enum.ScaleType.Tile
		bg.TileSize = UDim2.fromOffset(72, 72)
	else
		bg.Image = bgAsset or ""
		bg.ScaleType = Enum.ScaleType.Crop
	end
end
if not bgAsset then
	new("UIGradient", {
		Color = ColorSequence.new(Color3.fromRGB(110, 200, 255), Color3.fromRGB(30, 90, 160)),
		Rotation = 90,
	}, bg)
end
local shade = new("Frame", {
	Name = "Shade",
	Size = UDim2.fromScale(1, 1),
	BackgroundColor3 = Color3.fromRGB(6, 30, 62),
	BackgroundTransparency = 0.5,
	BorderSizePixel = 0,
}, main)
corner(shade, 14)

-- blue neon down both sides: a soft pulsing glow plus a bright core line
local neonGlow = {}
local function neonSide(rightSide)
	local glow = new("Frame", {
		Size = UDim2.new(0, 22, 1, 0),
		Position = rightSide and UDim2.new(1, -22, 0, 0) or UDim2.new(0, 0, 0, 0),
		BackgroundColor3 = NEON,
		BorderSizePixel = 0,
	}, main)
	new("UIGradient", {
		Rotation = rightSide and 180 or 0,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.2),
			NumberSequenceKeypoint.new(1, 1),
		}),
	}, glow)
	new("Frame", {
		Size = UDim2.new(0, 2, 1, 0),
		Position = rightSide and UDim2.new(1, -4, 0, 0) or UDim2.new(0, 2, 0, 0),
		BackgroundColor3 = Color3.fromRGB(170, 230, 255),
		BackgroundTransparency = 0.1,
		BorderSizePixel = 0,
	}, main)
	neonGlow[#neonGlow + 1] = glow
end
neonSide(false)
neonSide(true)

-- header (drag handle)
local header = new("Frame", {
	Name = "Header",
	Size = UDim2.new(1, 0, 0, 36),
	BackgroundColor3 = Color3.new(0, 0, 0),
	BackgroundTransparency = 0.45,
	BorderSizePixel = 0,
}, main)

local title = new("TextLabel", {
	BackgroundTransparency = 1,
	Size = UDim2.new(1, -76, 1, 0),
	Position = UDim2.fromOffset(12, 0),
	Font = Enum.Font.GothamBold,
	TextSize = 14,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextColor3 = C.text,
	TextStrokeTransparency = 0.5,
	Text = "❄ FROST BOOST FPS",
}, header)

local function headerButton(text, x)
	local b = new("TextButton", {
		Size = UDim2.fromOffset(26, 26),
		Position = UDim2.new(1, x, 0.5, -13),
		BackgroundColor3 = C.dark,
		BackgroundTransparency = 0.2,
		Text = text,
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		TextColor3 = C.text,
	}, header)
	corner(b, 8)
	return b
end
local minBtn = headerButton("–", -66)
local closeBtn = headerButton("X", -34)

-- live counters
local fpsLabel = new("TextLabel", {
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(10, 40),
	Size = UDim2.new(0.5, -12, 0, 24),
	Font = Enum.Font.GothamBold,
	TextSize = 17,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextColor3 = C.text,
	TextStrokeTransparency = 0.4,
	Text = "FPS --",
}, main)
local pingLabel = new("TextLabel", {
	BackgroundTransparency = 1,
	Position = UDim2.new(0.5, 2, 0, 40),
	Size = UDim2.new(0.5, -12, 0, 24),
	Font = Enum.Font.GothamBold,
	TextSize = 17,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextColor3 = C.text,
	TextStrokeTransparency = 0.4,
	Text = "PING --",
}, main)

-- mini FPS graph
local graph = new("Frame", {
	Position = UDim2.fromOffset(8, 66),
	Size = UDim2.new(1, -16, 0, 34),
	BackgroundColor3 = Color3.new(0, 0, 0),
	BackgroundTransparency = 0.45,
	BorderSizePixel = 0,
	ClipsDescendants = true,
}, main)
corner(graph, 6)
local BARS = 20
local bars, history = {}, {}
for i = 1, BARS do
	history[i] = 0
	bars[i] = new("Frame", {
		AnchorPoint = Vector2.new(0, 1),
		Size = UDim2.new(1 / BARS, -1, 0.05, 0),
		Position = UDim2.new((i - 1) / BARS, 0, 1, 0),
		BorderSizePixel = 0,
		BackgroundColor3 = C.ice,
	}, graph)
end

-- tabs + pages
local tabBar = new("Frame", {
	Position = UDim2.fromOffset(8, 106),
	Size = UDim2.new(1, -16, 0, 28),
	BackgroundTransparency = 1,
}, main)
new("UIListLayout", {
	FillDirection = Enum.FillDirection.Horizontal,
	Padding = UDim.new(0, 4),
	SortOrder = Enum.SortOrder.LayoutOrder,
}, tabBar)

local function makePage()
	local sf = new("ScrollingFrame", {
		Position = UDim2.fromOffset(8, 140),
		Size = UDim2.new(1, -16, 1, -172),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = C.ice,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		Visible = false,
	}, main)
	new("UIListLayout", { Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder }, sf)
	return sf
end
local pgBoost, pgPlayers, pgCodes, pgTheme, pgRoll = makePage(), makePage(), makePage(), makePage(), makePage()
local pages = { pgBoost, pgPlayers, pgCodes, pgTheme, pgRoll }

local tabBtns = {}
local tabW = math.floor((W - 16 - 16) / 5)
local function selectTab(i)
	for k, pg in ipairs(pages) do
		pg.Visible = (k == i)
		tabBtns[k].BackgroundColor3 = (k == i) and C.blue or C.dark
		tabBtns[k].BackgroundTransparency = (k == i) and 0.05 or 0.4
	end
end
for i, name in ipairs({ "BOOST", "USERS", "CODES", "THEME", "auto roll" }) do
	local b = new("TextButton", {
		LayoutOrder = i,
		Size = UDim2.fromOffset(tabW, 28),
		BackgroundColor3 = C.dark,
		BackgroundTransparency = 0.4,
		Text = name,
		Font = Enum.Font.GothamBold,
		TextSize = 12,
		TextColor3 = C.text,
	}, tabBar)
	corner(b, 8)
	tabBtns[i] = b
	b.MouseButton1Click:Connect(function() selectTab(i) end)
end

local statusLabel = new("TextLabel", {
	BackgroundTransparency = 1,
	Position = UDim2.new(0, 10, 1, -28),
	Size = UDim2.new(1, -20, 0, 24),
	Font = Enum.Font.Gotham,
	TextSize = 12,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextColor3 = C.dim,
	TextStrokeTransparency = 0.5,
	TextTruncate = Enum.TextTruncate.AtEnd,
	Text = "Ready.",
}, main)
local function setStatus(t) statusLabel.Text = t end

-- small popup at the top of the screen: shows for ~2 seconds, then fades out
local toastCur = nil
local function showToast(text)
	if toastCur then
		pcall(function() toastCur:Destroy() end)
		toastCur = nil
	end
	local inset = game:GetService("GuiService"):GetGuiInset()
	local lbl = new("TextLabel", {
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, inset.Y + 14),
		Size = UDim2.new(0, 0, 0, 30),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundColor3 = C.dark,
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		TextSize = 13,
		TextColor3 = C.text,
		TextTransparency = 1,
		Text = "  " .. text .. "  ",
		ZIndex = 120,
	}, gui)
	corner(lbl, 10)
	local lStroke = new("UIStroke", { Thickness = 1, Color = C.ice, Transparency = 1 }, lbl)
	toastCur = lbl
	TweenService:Create(lbl, TweenInfo.new(0.15), { BackgroundTransparency = 0.1, TextTransparency = 0 }):Play()
	TweenService:Create(lStroke, TweenInfo.new(0.15), { Transparency = 0.3 }):Play()
	task.delay(1.75, function()
		if toastCur ~= lbl then return end
		local t1 = TweenService:Create(lbl, TweenInfo.new(0.25), { BackgroundTransparency = 1, TextTransparency = 1 })
		TweenService:Create(lStroke, TweenInfo.new(0.25), { Transparency = 1 }):Play()
		t1:Play()
		t1.Completed:Wait()
		if toastCur == lbl then toastCur = nil end
		lbl:Destroy()
	end)
end

------------------------------------------------------------
-- Widgets
------------------------------------------------------------
local function makeButton(parent, text, order, color)
	local b = new("TextButton", {
		LayoutOrder = order,
		Size = UDim2.new(1, -4, 0, 32),
		BackgroundColor3 = color,
		BackgroundTransparency = 0.1,
		Text = text,
		Font = Enum.Font.GothamBold,
		TextSize = 13,
		TextColor3 = C.text,
	}, parent)
	corner(b, 8)
	return b
end

local function makeToggle(parent, text, order, initial, callback)
	local btn = new("TextButton", {
		LayoutOrder = order,
		Size = UDim2.new(1, -4, 0, 32),
		BackgroundColor3 = C.dark,
		BackgroundTransparency = 0.3,
		Text = "",
	}, parent)
	corner(btn, 8)
	new("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -64, 1, 0),
		Position = UDim2.fromOffset(10, 0),
		Font = Enum.Font.GothamMedium,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		TextColor3 = C.text,
		Text = text,
	}, btn)
	local pill = new("Frame", {
		Size = UDim2.fromOffset(38, 20),
		Position = UDim2.new(1, -48, 0.5, -10),
		BorderSizePixel = 0,
	}, btn)
	corner(pill, 10)
	local knob = new("Frame", {
		Size = UDim2.fromOffset(16, 16),
		BackgroundColor3 = C.text,
		BorderSizePixel = 0,
	}, pill)
	corner(knob, 8)

	local state = initial and true or false
	local function paint(animate)
		local pc = state and C.green or C.gray
		local kp = state and UDim2.fromOffset(20, 2) or UDim2.fromOffset(2, 2)
		if animate then
			local ti = TweenInfo.new(0.12)
			TweenService:Create(pill, ti, { BackgroundColor3 = pc }):Play()
			TweenService:Create(knob, ti, { Position = kp }):Play()
		else
			pill.BackgroundColor3 = pc
			knob.Position = kp
		end
	end
	paint(false)

	btn.MouseButton1Click:Connect(function()
		state = not state
		paint(true)
		local ok, err = pcall(callback, state)
		if not ok then warn("[FrostBoost] " .. text .. ": " .. tostring(err)) end
	end)

	return {
		set = function(on)
			on = on and true or false
			if on == state then return end
			state = on
			paint(true)
		end,
		destroy = function() btn:Destroy() end,
	}
end

local function makeBox(parent, order, placeholder, text, height, multi)
	local box = new("TextBox", {
		LayoutOrder = order,
		Size = UDim2.new(1, -4, 0, height or 30),
		BackgroundColor3 = C.dark,
		BackgroundTransparency = 0.25,
		BorderSizePixel = 0,
		Font = Enum.Font.Gotham,
		TextSize = 13,
		TextColor3 = C.text,
		PlaceholderText = placeholder,
		PlaceholderColor3 = Color3.fromRGB(140, 150, 170),
		Text = text or "",
		ClearTextOnFocus = false,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = multi and Enum.TextYAlignment.Top or Enum.TextYAlignment.Center,
		MultiLine = multi and true or false,
		TextWrapped = multi and true or false,
	}, parent)
	corner(box, 8)
	new("UIPadding", {
		PaddingLeft = UDim.new(0, 8),
		PaddingRight = UDim.new(0, 8),
		PaddingTop = UDim.new(0, multi and 6 or 0),
	}, box)
	return box
end

------------------------------------------------------------
-- Performance helpers: big jobs run a few milliseconds per frame
------------------------------------------------------------
local SLICE_BUDGET = tonumber(CONFIG.SliceBudget) or 0.0015

-- run fn(item) over `list` without ever hogging a frame; stops early if alive() turns false
local function sliceEach(list, fn, alive)
	local i, n = 1, #list
	while i <= n do
		if alive and not alive() then return false end
		local t0 = os.clock()
		repeat
			local stop = math.min(i + 11, n)
			for k = i, stop do pcall(fn, list[k]) end
			i = stop + 1
		until i > n or os.clock() - t0 > SLICE_BUDGET
		RunService.Heartbeat:Wait()
	end
	return true
end

-- only one heavy workspace scan (boost / dark textures) runs at a time, so
-- toggling several things at once can no longer stack up and cause a freeze
local heavyLock = { busy = false, queue = {} }
local function runHeavy(fn, onDone)
	if heavyLock.busy then
		table.insert(heavyLock.queue, { fn = fn, onDone = onDone })
		return
	end
	heavyLock.busy = true
	task.spawn(function()
		local ok, err = pcall(fn)
		if not ok then warn("[FrostBoost] " .. tostring(err)) end
		if onDone then pcall(onDone) end
		heavyLock.busy = false
		local nxt = table.remove(heavyLock.queue, 1)
		if nxt then runHeavy(nxt.fn, nxt.onDone) end
	end)
end

local function getProp(inst, prop) return inst[prop] end
local function setProp(inst, prop, value) inst[prop] = value end

-- records look like { instance, prop1, value1, prop2, value2, ... }
local function restoreRecords(records, onDone)
	runHeavy(function()
		sliceEach(records, function(rec)
			local inst = rec[1]
			for k = 2, #rec, 2 do pcall(setProp, inst, rec[k], rec[k + 1]) end
		end)
	end, onDone)
end


------------------------------------------------------------
-- auto roll tab: landing roll animation (mobile/PC, no input needed)
-- Logic kept as given; only wrapped so it starts/stops with a toggle
-- instead of running the moment the script loads.
------------------------------------------------------------
do
	local ANIM_ID = "rbxassetid://93445209648664"
	local AIR = {
		[Enum.HumanoidStateType.Freefall] = true,
		[Enum.HumanoidStateType.Jumping] = true,
	}

	local roll = { on = false, track = nil, stateConn = nil, charConn = nil, airborne = false }

	local function setup(char)
		if roll.stateConn then
			roll.stateConn:Disconnect()
			roll.stateConn = nil
		end
		roll.airborne = false

		local hum = char:WaitForChild("Humanoid")
		local animator = hum:FindFirstChildOfClass("Animator") or Instance.new("Animator", hum)

		local anim = Instance.new("Animation")
		anim.AnimationId = ANIM_ID
		roll.track = animator:LoadAnimation(anim)
		roll.track.Priority = Enum.AnimationPriority.Action

		roll.stateConn = hum.StateChanged:Connect(function(_, state)
			if not roll.on then return end
			if AIR[state] then
				roll.airborne = true
			elseif state == Enum.HumanoidStateType.Landed and roll.airborne then
				roll.airborne = false
				if char:FindFirstChildOfClass("Tool") and not roll.track.IsPlaying then
					roll.track:Play()
				end
			end
		end)
	end

	local function setRoll(on)
		roll.on = on
		if on then
			if not roll.charConn then
				roll.charConn = track(player.CharacterAdded:Connect(setup))
			end
			if player.Character then setup(player.Character) end
			setStatus("Auto Roll ON: rolls on landing while a tool is out.")
			showToast("Auto Roll: ON")
		else
			if roll.stateConn then
				roll.stateConn:Disconnect()
				roll.stateConn = nil
			end
			if roll.track then pcall(function() roll.track:Stop() end) end
			setStatus("Auto Roll OFF.")
			showToast("Auto Roll: OFF")
		end
	end

	new("TextLabel", {
		LayoutOrder = 1, Size = UDim2.new(1, -4, 0, 40),
		BackgroundTransparency = 1, Font = Enum.Font.Gotham,
		TextSize = 11, TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top,
		TextColor3 = C.dim,
		Text = "Plays a roll animation when you land with a tool out. Works the same on mobile and PC.",
	}, pgRoll)
	makeToggle(pgRoll, "Auto Roll", 2, false, setRoll)

	cleanups[#cleanups + 1] = function()
		setRoll(false)
		if roll.charConn then
			roll.charConn:Disconnect()
			roll.charConn = nil
		end
	end
end

------------------------------------------------------------
-- THEME tab: switch the panel background
------------------------------------------------------------
do
	new("TextLabel", {
		LayoutOrder = 1, Size = UDim2.new(1, -4, 0, 40),
		BackgroundTransparency = 1, Font = Enum.Font.GothamBold,
		TextSize = 12, TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top,
		TextColor3 = C.ice,
		Text = "BACKGROUND\nOriginal blocky grass/dirt theme (not Minecraft's own art).",
	}, pgTheme)

	local preview = new("ImageLabel", {
		LayoutOrder = 2,
		Size = UDim2.new(1, -4, 0, 70),
		BackgroundColor3 = C.dark,
		BorderSizePixel = 0,
		Image = mcAsset or "",
		ScaleType = Enum.ScaleType.Tile,
		TileSize = UDim2.fromOffset(48, 48),
	}, pgTheme)
	corner(preview, 8)
	if not mcAsset then
		new("TextLabel", {
			Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
			Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = C.dim,
			Text = "(texture needs writefile + getcustomasset)",
		}, preview)
	end

	makeToggle(pgTheme, "Use Blocky Texture", 3, false, function(on)
		setBackground(on)
		setStatus(on and "Background: blocky texture." or "Background: Frost logo.")
	end)
end

------------------------------------------------------------
-- Dragging (mouse + touch), kept on screen
------------------------------------------------------------
local minimized = false
local draggables = {}

local function clampTo(d)
	local screen = gui.AbsoluteSize
	if screen.X < 50 or screen.Y < 50 then return end
	local p = d.target.Position
	local x = p.X.Scale * screen.X + p.X.Offset
	local y = p.Y.Scale * screen.Y + p.Y.Offset
	x = math.clamp(x, 0, math.max(screen.X - d.w, 0))
	y = math.clamp(y, 0, math.max(screen.Y - (d.keepH or d.h), 0))
	d.target.Position = UDim2.fromOffset(x, y)
end

local function reclampAll()
	for _, d in ipairs(draggables) do pcall(clampTo, d) end
end

-- drag `target` by grabbing `handle`. d.moved tells taps apart from drags.
local function makeDraggable(handle, target, w, h, keepH)
	local d = { target = target, w = w, h = h, keepH = keepH, moved = false }
	draggables[#draggables + 1] = d
	local active, startInput, dragStart, startPos = false, nil, nil, nil

	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			active = true
			d.moved = false
			startInput = input
			dragStart = input.Position
			local screen = gui.AbsoluteSize
			local p = target.Position
			startPos = Vector2.new(p.X.Scale * screen.X + p.X.Offset, p.Y.Scale * screen.Y + p.Y.Offset)
		end
	end)
	track(UserInputService.InputChanged:Connect(function(input)
		if not active then return end
		if input == startInput or input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStart
			if delta.Magnitude > 6 then d.moved = true end
			if d.moved then
				target.Position = UDim2.fromOffset(startPos.X + delta.X, startPos.Y + delta.Y)
				clampTo(d)
			end
		end
	end))
	track(UserInputService.InputEnded:Connect(function(input)
		if not active then return end
		if input == startInput or input.UserInputType == Enum.UserInputType.MouseButton1 then
			active = false
		end
	end))
	return d
end

local mainDrag = makeDraggable(header, main, W, H, 40)

-- screen rotated / resized: keep the panel usable and on screen
local function relayout()
	local s = gui.AbsoluteSize
	if s.X < 50 or s.Y < 50 then return end
	local newH = math.clamp(s.Y - 30, 300, 392)
	if newH ~= H then
		H = newH
		mainDrag.h = H
		if main.Visible and not minimized then main.Size = UDim2.fromOffset(W, H) end
	end
	reclampAll()
end
pcall(function()
	track(gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(relayout))
end)

------------------------------------------------------------
-- Shadows
------------------------------------------------------------
local shadowsOn = Lighting.GlobalShadows
local shadowConn = nil   -- (unused now, kept so cleanup stays compatible)

-- GlobalShadows alone switches shadows off for the whole scene, so we no longer
-- touch CastShadow on every part (that full scan was a big source of lag).
local function setShadows(on)
	shadowsOn = on
	Lighting.GlobalShadows = on
end

------------------------------------------------------------
-- FPS boost
------------------------------------------------------------
local boost = {
	on = false, busy = false, saved = {}, conn = nil, gen = 0, prevShadows = true,
	seen = setmetatable({}, { __mode = "k" }),
}
local shadowToggle = nil

local FACE_CLASSES = { Decal = true, Texture = true }
local OFF_CLASSES = {
	ParticleEmitter = true, Trail = true, Beam = true, Smoke = true, Fire = true, Sparkles = true,
	BloomEffect = true, BlurEffect = true, ColorCorrectionEffect = true,
	DepthOfFieldEffect = true, SunRaysEffect = true,
}
local SMOOTH = Enum.Material.SmoothPlastic

-- one compact record per instance, written/saved only when something really changes
local function optimize(inst)
	local seen = boost.seen
	if seen[inst] then return end
	local cls = inst.ClassName
	if FACE_CLASSES[cls] then
		seen[inst] = true
		if inst.Transparency < 1 then
			local s = boost.saved
			s[#s + 1] = { inst, "Transparency", inst.Transparency }
			inst.Transparency = 1
		end
	elseif OFF_CLASSES[cls] then
		seen[inst] = true
		if inst.Enabled then
			local s = boost.saved
			s[#s + 1] = { inst, "Enabled", true }
			inst.Enabled = false
		end
	elseif cls ~= "Terrain" and inst:IsA("BasePart") then
		seen[inst] = true
		local mat, refl = inst.Material, inst.Reflectance
		if mat ~= SMOOTH or refl ~= 0 then
			local s = boost.saved
			s[#s + 1] = { inst, "Material", mat, "Reflectance", refl }
			inst.Material = SMOOTH
			inst.Reflectance = 0
		end
	end
end

local boostBtn = makeButton(pgBoost, "ENABLE BOOST", 1, C.green)

local function enableBoost()
	if boost.busy then
		setStatus("Still restoring the last boost, one moment...")
		return
	end
	boost.on = true
	boost.saved = {}
	boost.seen = setmetatable({}, { __mode = "k" })
	boost.gen += 1
	local gen = boost.gen

	boost.prevShadows = shadowsOn
	setShadows(false)
	if shadowToggle then shadowToggle.set(false) end

	local function keep(inst, prop)
		local ok, v = pcall(getProp, inst, prop)
		if ok then boost.saved[#boost.saved + 1] = { inst, prop, v } end
	end

	keep(Lighting, "FogEnd")
	pcall(setProp, Lighting, "FogEnd", 9e9)

	local terrain = workspace:FindFirstChildOfClass("Terrain")
	if terrain then
		for _, p in ipairs({ "WaterWaveSize", "WaterWaveSpeed", "WaterReflectance", "WaterTransparency" }) do
			keep(terrain, p)
			pcall(setProp, terrain, p, 0)
		end
	end

	pcall(function()
		local r = settings().Rendering
		keep(r, "QualityLevel")
		r.QualityLevel = Enum.QualityLevel.Level01
	end)

	-- things created while boosting are queued and handled in small time slices
	local pending, pHead, pTail = {}, 1, 0
	local queued = setmetatable({}, { __mode = "k" })
	boost.conn = workspace.DescendantAdded:Connect(function(inst)
		if queued[inst] then return end
		queued[inst] = true
		pTail += 1
		pending[pTail] = inst
	end)

	local function alive() return boost.on and boost.gen == gen end

	for _, inst in ipairs(Lighting:GetChildren()) do pcall(optimize, inst) end
	runHeavy(function()
		sliceEach(workspace:GetDescendants(), optimize, alive)
	end, function()
		while alive() do
			if pHead <= pTail then
				local t0 = os.clock()
				while pHead <= pTail and os.clock() - t0 < SLICE_BUDGET do
					local item = pending[pHead]
					pending[pHead] = nil
					pHead += 1
					queued[item] = nil
					if item.Parent then pcall(optimize, item) end
				end
				if pHead > pTail then pending, pHead, pTail = {}, 1, 0 end
				RunService.Heartbeat:Wait()
			else
				task.wait(0.4)
			end
		end
	end)

	boostBtn.Text = "DISABLE BOOST"
	boostBtn.BackgroundColor3 = C.red
	setStatus("Boost ON: shadows, textures, particles, effects reduced.")
	showToast("Boost: ON")
end

local function disableBoost()
	boost.on = false
	boost.gen += 1
	if boost.conn then
		boost.conn:Disconnect()
		boost.conn = nil
	end
	local saved = boost.saved
	boost.saved = {}
	boost.seen = setmetatable({}, { __mode = "k" })
	boost.busy = true
	restoreRecords(saved, function() boost.busy = false end)

	setShadows(boost.prevShadows)
	if shadowToggle then shadowToggle.set(boost.prevShadows) end

	boostBtn.Text = "ENABLE BOOST"
	boostBtn.BackgroundColor3 = C.green
	setStatus("Boost OFF: restoring original settings.")
	showToast("Boost: OFF")
end

boostBtn.MouseButton1Click:Connect(function()
	if boost.on then disableBoost() else enableBoost() end
end)

------------------------------------------------------------
-- Stretch resolution (experimental camera effect)
------------------------------------------------------------
local stretchEnabled = false
local STRETCH_NAME = "FrostStretchRes"
local stretchScale = 0.65
local stretchCF = CFrame.new(0, 0, 0, 1, 0, 0, 0, stretchScale, 0, 0, 0, 1)   -- built once
local stretchLast = nil
local stretchBtn = makeButton(pgBoost, "STRETCH RESOLUTION: OFF", 10, C.blue)

local function stopStretch()
	if not stretchEnabled then return end
	stretchEnabled = false
	pcall(function() RunService:UnbindFromRenderStep(STRETCH_NAME) end)
	stretchLast = nil
	stretchBtn.Text = "STRETCH RESOLUTION: OFF"
	stretchBtn.BackgroundColor3 = C.blue
	setStatus("Stretch resolution OFF.")
end

local function startStretch()
	if stretchEnabled then return end
	stretchEnabled = true
	-- runs right AFTER the camera scripts, so it never fights them or compounds
	pcall(function()
		RunService:BindToRenderStep(STRETCH_NAME, Enum.RenderPriority.Camera.Value + 1, function()
			local cam = workspace.CurrentCamera
			if not cam then return end
			local cf = cam.CFrame
			if cf == stretchLast then return end   -- nobody rewrote it this frame: don't stack the effect
			stretchLast = cf * stretchCF
			cam.CFrame = stretchLast
		end)
	end)
	stretchBtn.Text = "STRETCH RESOLUTION: ON"
	stretchBtn.BackgroundColor3 = C.green
	setStatus("Stretch camera effect ON (experimental).")
end

stretchBtn.Activated:Connect(function()
	if stretchEnabled then stopStretch() else startStretch() end
end)

shadowToggle = makeToggle(pgBoost, "Shadows", 2, shadowsOn, function(on)
	setShadows(on)
	setStatus(on and "Shadows ON." or "Shadows OFF.")
end)

------------------------------------------------------------
-- Dark textures
------------------------------------------------------------
local DARK = Color3.fromRGB(38, 38, 44)
local DARK_TEX = Color3.fromRGB(45, 45, 50)
local DARK_AMBIENT = Color3.fromRGB(32, 32, 38)
local dark = { on = false, busy = false, saved = {}, conn = nil, gen = 0, seen = setmetatable({}, { __mode = "k" }) }

-- Is this Model a character? Cached, so big models aren't re-scanned for every part.
local charCache = setmetatable({}, { __mode = "k" })   -- model -> true | expiry time (not a character)
local function isCharModel(m)
	if Players:GetPlayerFromCharacter(m) then
		charCache[m] = true
		return true
	end
	local c = charCache[m]
	if c == true then return true end
	local now = os.clock()
	if c and now < c then return false end
	local isChar = m:FindFirstChildOfClass("Humanoid") ~= nil
	charCache[m] = isChar or (now + 5)
	return isChar
end

local function isCharPart(inst)
	local p, depth = inst.Parent, 0
	while p and p ~= workspace and depth < 8 do
		if p.ClassName == "Model" and isCharModel(p) then return true end
		p = p.Parent
		depth += 1
	end
	return false
end

local function darken(inst)
	local seen = dark.seen
	if seen[inst] then return end
	local cls = inst.ClassName
	if cls == "Decal" or cls == "Texture" then
		if isCharPart(inst) then return end
		seen[inst] = true
		local s = dark.saved
		s[#s + 1] = { inst, "Color3", inst.Color3 }
		inst.Color3 = DARK_TEX
	elseif cls == "SurfaceAppearance" then
		seen[inst] = true
		local s = dark.saved
		s[#s + 1] = { inst, "Color", inst.Color }
		inst.Color = DARK_TEX
	elseif cls ~= "Terrain" and inst:IsA("BasePart") then
		if isCharPart(inst) then return end
		seen[inst] = true
		local s = dark.saved
		s[#s + 1] = { inst, "Color", inst.Color }
		inst.Color = DARK
	end
end

local darkToggle = nil
local function setDark(on)
	dark.gen += 1
	local gen = dark.gen
	if on then
		if dark.busy then
			setStatus("Still restoring the last change, one moment...")
			task.defer(function() if darkToggle then darkToggle.set(false) end end)
			return
		end
		dark.on = true
		dark.saved = {}
		dark.seen = setmetatable({}, { __mode = "k" })
		dark.saved[1] = { Lighting, "Ambient", Lighting.Ambient, "OutdoorAmbient", Lighting.OutdoorAmbient }
		Lighting.Ambient = DARK_AMBIENT
		Lighting.OutdoorAmbient = DARK_AMBIENT
		dark.conn = workspace.DescendantAdded:Connect(function(inst)
			pcall(darken, inst)
		end)
		runHeavy(function()
			sliceEach(workspace:GetDescendants(), darken, function()
				return dark.on and dark.gen == gen
			end)
		end)
		setStatus("Dark textures ON.")
		showToast("Dark Textures: ON")
	else
		dark.on = false
		if dark.conn then
			dark.conn:Disconnect()
			dark.conn = nil
		end
		local saved = dark.saved
		dark.saved = {}
		dark.seen = setmetatable({}, { __mode = "k" })
		dark.busy = true
		restoreRecords(saved, function() dark.busy = false end)
		setStatus("Dark textures OFF.")
		showToast("Dark Textures: OFF")
	end
end
darkToggle = makeToggle(pgBoost, "Dark Textures", 3, false, setDark)

------------------------------------------------------------
-- FPS unlock / low detail / net + physics lite
------------------------------------------------------------
local unlockT = nil
unlockT = makeToggle(pgBoost, "FPS Unlock", 4, false, function(on)
	if setfpscap then
		pcall(setfpscap, on and 0 or 60)
		setStatus(on and "FPS cap removed." or "FPS cap back to 60.")
		showToast(on and "FPS Unlock: ON" or "FPS Unlock: OFF")
	else
		setStatus("FPS Unlock isn't supported by your executor.")
		task.defer(function() unlockT.set(false) end)
	end
end)

local lowSaved = {}
makeToggle(pgBoost, "Low-Detail Render", 5, false, function(on)
	if on then
		lowSaved = {}
		pcall(function()
			if gethiddenproperty and sethiddenproperty then
				lowSaved.tech = gethiddenproperty(Lighting, "Technology")
				sethiddenproperty(Lighting, "Technology", Enum.Technology.Compatibility)
			end
		end)
		pcall(function()
			lowSaved.mesh = settings().Rendering.MeshPartDetailLevel
			settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level04
		end)
		pcall(function()
			local t = workspace:FindFirstChildOfClass("Terrain")
			lowSaved.deco = t.Decoration
			t.Decoration = false
		end)
		setStatus("Low-detail rendering ON.")
		showToast("Low-Detail Render: ON")
	else
		pcall(function()
			if lowSaved.tech ~= nil and sethiddenproperty then
				sethiddenproperty(Lighting, "Technology", lowSaved.tech)
			end
		end)
		pcall(function()
			if lowSaved.mesh ~= nil then settings().Rendering.MeshPartDetailLevel = lowSaved.mesh end
		end)
		pcall(function()
			local t = workspace:FindFirstChildOfClass("Terrain")
			if lowSaved.deco ~= nil then t.Decoration = lowSaved.deco end
		end)
		setStatus("Low-detail rendering OFF.")
	end
end)

local netSaved = {}
makeToggle(pgBoost, "Net + Physics Lite", 6, false, function(on)
	if on then
		netSaved = {}
		pcall(function()
			netSaved.interp = workspace.InterpolationThrottling
			workspace.InterpolationThrottling = Enum.InterpolationThrottlingMode.Enabled
		end)
		pcall(function()
			local ph = settings().Physics
			netSaved.throttle = ph.PhysicsEnvironmentalThrottle
			ph.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.Always
			netSaved.sleep = ph.AllowSleep
			ph.AllowSleep = true
		end)
		setStatus("Net + physics lite ON.")
		showToast("Net + Physics Lite: ON")
	else
		pcall(function()
			if netSaved.interp ~= nil then workspace.InterpolationThrottling = netSaved.interp end
		end)
		pcall(function()
			local ph = settings().Physics
			if netSaved.throttle ~= nil then ph.PhysicsEnvironmentalThrottle = netSaved.throttle end
			if netSaved.sleep ~= nil then ph.AllowSleep = netSaved.sleep end
		end)
		setStatus("Net + physics lite OFF.")
	end
end)

------------------------------------------------------------
-- More tools (BOOST tab): Anti-AFK, mute, rejoin
------------------------------------------------------------
do
	local afkConn = nil
	makeToggle(pgBoost, "Anti-AFK", 7, false, function(on)
		if afkConn then
			afkConn:Disconnect()
			afkConn = nil
		end
		if on then
			afkConn = player.Idled:Connect(function()
				pcall(function()
					local vu = game:GetService("VirtualUser")
					vu:CaptureController()
					vu:ClickButton2(Vector2.new())
				end)
			end)
			setStatus("Anti-AFK ON: idling won't kick you.")
		else
			setStatus("Anti-AFK OFF.")
		end
	end)
	cleanups[#cleanups + 1] = function()
		if afkConn then
			afkConn:Disconnect()
			afkConn = nil
		end
	end

	local muteSaved = nil
	local function setMute(on)
		return (pcall(function()
			local gs = UserSettings():GetService("UserGameSettings")
			if on then
				muteSaved = gs.MasterVolume
				gs.MasterVolume = 0
			elseif muteSaved ~= nil then
				gs.MasterVolume = muteSaved
				muteSaved = nil
			end
		end))
	end
	local muteToggle = nil
	muteToggle = makeToggle(pgBoost, "Mute Game Audio", 8, false, function(on)
		if setMute(on) then
			setStatus(on and "Game audio muted." or "Game audio restored.")
		else
			setStatus("Muting isn't supported by your executor.")
			task.defer(function() muteToggle.set(false) end)
		end
	end)
	cleanups[#cleanups + 1] = function() setMute(false) end

	local rejoinBtn = makeButton(pgBoost, "REJOIN SERVER", 9, C.gray)
	rejoinBtn.MouseButton1Click:Connect(function()
		setStatus("Rejoining...")
		pcall(function()
			local TeleportService = game:GetService("TeleportService")
			if #Players:GetPlayers() <= 1 then
				TeleportService:Teleport(game.PlaceId, player)
			else
				TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, player)
			end
		end)
	end)
end

------------------------------------------------------------
-- Players tab: hide everyone, or pick who disappears
------------------------------------------------------------
local hiddenState = {}   -- instance -> original value
local hideSet = {}       -- [Player] = true while hidden
local hideConns = {}     -- [Player] = { connections }
local rows = {}          -- [Player] = toggle row
local hideAllOn = false
local rowOrder = 100

local function hideInst(inst)
	if hiddenState[inst] ~= nil then return end
	if inst:IsA("BasePart") then
		hiddenState[inst] = inst.LocalTransparencyModifier
		inst.LocalTransparencyModifier = 1
	elseif inst:IsA("Decal") then
		hiddenState[inst] = inst.Transparency
		inst.Transparency = 1
	elseif inst:IsA("BillboardGui") then
		hiddenState[inst] = inst.Enabled
		inst.Enabled = false
	end
end

local function restoreInst(inst, orig)
	pcall(function()
		if inst:IsA("BasePart") then
			inst.LocalTransparencyModifier = orig
		elseif inst:IsA("Decal") then
			inst.Transparency = orig
		elseif inst:IsA("BillboardGui") then
			inst.Enabled = orig
		end
	end)
end

local function setPlayerHidden(p, on)
	if p == player then return end
	if on then
		if hideSet[p] then return end
		hideSet[p] = true
		local conns = {}
		local function hook(char)
			for _, d in ipairs(char:GetDescendants()) do pcall(hideInst, d) end
			conns[#conns + 1] = char.DescendantAdded:Connect(function(d)
				pcall(hideInst, d)
			end)
		end
		if p.Character then hook(p.Character) end
		conns[#conns + 1] = p.CharacterAdded:Connect(hook)
		hideConns[p] = conns
	else
		if not hideSet[p] then return end
		hideSet[p] = nil
		for _, c in ipairs(hideConns[p] or {}) do c:Disconnect() end
		hideConns[p] = nil
		local char = p.Character
		if char then
			for inst, orig in pairs(hiddenState) do
				if inst:IsDescendantOf(char) then
					restoreInst(inst, orig)
					hiddenState[inst] = nil
				end
			end
		end
	end
end

-- My nametag: change or hide the name above your head (only you see it)
do
	new("TextLabel", {
		LayoutOrder = 1,
		Size = UDim2.new(1, -4, 0, 20),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = C.ice,
		TextStrokeTransparency = 0.5,
		Text = "MY NAMETAG (only you see it)",
	}, pgPlayers)
	local nameBox = makeBox(pgPlayers, 2, "new name above your head", "", 30, false)
	local nameRow = new("Frame", {
		LayoutOrder = 3,
		Size = UDim2.new(1, -4, 0, 32),
		BackgroundTransparency = 1,
	}, pgPlayers)
	local applyBtn = new("TextButton", {
		Size = UDim2.new(0.5, -3, 1, 0),
		BackgroundColor3 = C.blue,
		BackgroundTransparency = 0.1,
		Text = "APPLY",
		Font = Enum.Font.GothamBold,
		TextSize = 13,
		TextColor3 = C.text,
	}, nameRow)
	corner(applyBtn, 8)
	local resetBtn = new("TextButton", {
		Position = UDim2.new(0.5, 3, 0, 0),
		Size = UDim2.new(0.5, -3, 1, 0),
		BackgroundColor3 = C.gray,
		BackgroundTransparency = 0.1,
		Text = "RESET",
		Font = Enum.Font.GothamBold,
		TextSize = 13,
		TextColor3 = C.text,
	}, nameRow)
	corner(resetBtn, 8)

	local st = { text = nil, orig = nil, hooked = {}, conns = {}, guard = false, olds = {} }

	local function esc(s) return (s:gsub("%p", "%%%0")) end
	local function repl(s) return (s:gsub("%%", "%%%%")) end

	local function swap(txt)
		if not st.text or txt:find(st.text, 1, true) then return txt end
		local out = txt
		for _, o in ipairs(st.olds) do
			if o ~= "" then out = out:gsub(esc(o), repl(st.text)) end
		end
		return out
	end

	local function isTagLabel(d)
		return (d:IsA("TextLabel") or d:IsA("TextButton"))
			and (d:FindFirstAncestorOfClass("BillboardGui") ~= nil
				or d:FindFirstAncestorOfClass("SurfaceGui") ~= nil)
	end

	local function hookLabel(lbl)
		if st.hooked[lbl] ~= nil then return end
		st.hooked[lbl] = lbl.Text
		local function fix()
			if st.guard or not st.text then return end
			local nt = swap(lbl.Text)
			if nt ~= lbl.Text then
				st.guard = true
				pcall(function() lbl.Text = nt end)
				st.guard = false
			end
		end
		st.conns[#st.conns + 1] = lbl:GetPropertyChangedSignal("Text"):Connect(fix)
		fix()
	end

	local function applyToCharacter(char)
		local hum = char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid", 5)
		if hum then
			if st.orig == nil then st.orig = hum.DisplayName end
			pcall(function() hum.DisplayName = st.text end)
		end
		st.olds = { player.Name, player.DisplayName, st.orig or "" }
		for _, d in ipairs(char:GetDescendants()) do
			if isTagLabel(d) then pcall(hookLabel, d) end
		end
		st.conns[#st.conns + 1] = char.DescendantAdded:Connect(function(d)
			task.defer(function()
				if st.text and d.Parent and isTagLabel(d) then pcall(hookLabel, d) end
			end)
		end)
	end

	local function resetName()
		for _, c in ipairs(st.conns) do pcall(function() c:Disconnect() end) end
		st.conns = {}
		st.text = nil
		for lbl, orig in pairs(st.hooked) do
			pcall(function()
				if lbl.Parent then lbl.Text = orig end
			end)
		end
		st.hooked = {}
		local char = player.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if hum and st.orig ~= nil then
			pcall(function() hum.DisplayName = st.orig end)
		end
		st.orig = nil
	end

	applyBtn.MouseButton1Click:Connect(function()
		local n = nameBox.Text:match("^%s*(.-)%s*$")
		if n == "" then
			setStatus("Type a name first.")
			return
		end
		if #n > 40 then n = n:sub(1, 40) end
		resetName()
		st.text = n
		if player.Character then task.spawn(applyToCharacter, player.Character) end
		setStatus("Nametag set to: " .. n .. " (only you see it)")
	end)
	resetBtn.MouseButton1Click:Connect(function()
		resetName()
		setStatus("Nametag reset.")
	end)
	track(player.CharacterAdded:Connect(function(char)
		if st.text then task.spawn(applyToCharacter, char) end
	end))
	cleanups[#cleanups + 1] = resetName

	local tagSaved = nil
	makeToggle(pgPlayers, "Hide My Nametag", 4, false, function(on)
		local char = player.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if not hum then
			setStatus("Character isn't loaded yet.")
			return
		end
		if on then
			tagSaved = hum.DisplayDistanceType
			hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		elseif tagSaved ~= nil then
			hum.DisplayDistanceType = tagSaved
			tagSaved = nil
		end
	end)
end

makeToggle(pgPlayers, "Hide All Players", 10, false, function(on)
	hideAllOn = on
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= player then
			setPlayerHidden(p, on)
			if rows[p] then rows[p].set(on) end
		end
	end
	setStatus(on and "All other players hidden." or "Other players visible again.")
	showToast(on and "Hide All Players: ON" or "Hide All Players: OFF")
end)

new("TextLabel", {
	LayoutOrder = 11,
	Size = UDim2.new(1, -4, 0, 20),
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamBold,
	TextSize = 12,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextColor3 = C.ice,
	TextStrokeTransparency = 0.5,
	Text = "PICK WHO DISAPPEARS",
}, pgPlayers)

local function addRow(p)
	if p == player or rows[p] then return end
	rowOrder += 1
	rows[p] = makeToggle(pgPlayers, "• " .. p.DisplayName, rowOrder, hideSet[p] == true, function(on)
		setPlayerHidden(p, on)
		setStatus((on and "Hidden: " or "Visible: ") .. p.DisplayName)
	end)
end

local function removeRow(p)
	setPlayerHidden(p, false)
	if rows[p] then
		rows[p].destroy()
		rows[p] = nil
	end
end

for _, p in ipairs(Players:GetPlayers()) do addRow(p) end
track(Players.PlayerAdded:Connect(function(p)
	addRow(p)
	if hideAllOn then
		setPlayerHidden(p, true)
		if rows[p] then rows[p].set(true) end
	end
end))
track(Players.PlayerRemoving:Connect(removeRow))

------------------------------------------------------------
-- Codes tab: auto redeem
------------------------------------------------------------
local cmdBox = makeBox(pgCodes, 1, "command (default /code)", CONFIG.CodeCommand, 30, false)

-- type a code, tap ADD (or press enter) and it stacks up in the list below
local inputRow = new("Frame", {
	LayoutOrder = 2,
	Size = UDim2.new(1, -4, 0, 30),
	BackgroundTransparency = 1,
}, pgCodes)
local codeInput = new("TextBox", {
	Size = UDim2.new(1, -62, 1, 0),
	BackgroundColor3 = C.dark,
	BackgroundTransparency = 0.25,
	BorderSizePixel = 0,
	Font = Enum.Font.Gotham,
	TextSize = 13,
	TextColor3 = C.text,
	PlaceholderText = "type a code, tap ADD",
	PlaceholderColor3 = Color3.fromRGB(140, 150, 170),
	Text = "",
	ClearTextOnFocus = false,
	TextXAlignment = Enum.TextXAlignment.Left,
}, inputRow)
corner(codeInput, 8)
new("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) }, codeInput)
local addBtn = new("TextButton", {
	Position = UDim2.new(1, -56, 0, 0),
	Size = UDim2.fromOffset(56, 30),
	BackgroundColor3 = C.green,
	BackgroundTransparency = 0.1,
	Text = "ADD",
	Font = Enum.Font.GothamBold,
	TextSize = 13,
	TextColor3 = C.text,
}, inputRow)
corner(addBtn, 8)

local redeemBtn = makeButton(pgCodes, "REDEEM ALL (0)", 3, C.blue)

local btnRow = new("Frame", {
	LayoutOrder = 4,
	Size = UDim2.new(1, -4, 0, 32),
	BackgroundTransparency = 1,
}, pgCodes)
local stopBtn = new("TextButton", {
	Size = UDim2.new(0.5, -3, 1, 0),
	BackgroundColor3 = C.red,
	BackgroundTransparency = 0.1,
	Text = "STOP",
	Font = Enum.Font.GothamBold,
	TextSize = 13,
	TextColor3 = C.text,
}, btnRow)
corner(stopBtn, 8)
local clearBtn = new("TextButton", {
	Position = UDim2.new(0.5, 3, 0, 0),
	Size = UDim2.new(0.5, -3, 1, 0),
	BackgroundColor3 = C.gray,
	BackgroundTransparency = 0.1,
	Text = "CLEAR ALL",
	Font = Enum.Font.GothamBold,
	TextSize = 13,
	TextColor3 = C.text,
}, btnRow)
corner(clearBtn, 8)

local stackHeader = new("TextLabel", {
	LayoutOrder = 5,
	Size = UDim2.new(1, -4, 0, 20),
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamBold,
	TextSize = 12,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextColor3 = C.ice,
	TextStrokeTransparency = 0.5,
	Text = "STACK: 0 codes",
}, pgCodes)

local logLabel = new("TextLabel", {
	LayoutOrder = 1000,
	Size = UDim2.new(1, -4, 0, 78),
	BackgroundColor3 = C.dark,
	BackgroundTransparency = 0.35,
	Font = Enum.Font.Code,
	TextSize = 11,
	TextWrapped = true,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextYAlignment = Enum.TextYAlignment.Top,
	TextColor3 = C.dim,
	Text = "log: nothing sent yet",
}, pgCodes)
corner(logLabel, 8)
new("UIPadding", {
	PaddingLeft = UDim.new(0, 6), PaddingTop = UDim.new(0, 4), PaddingRight = UDim.new(0, 6),
}, logLabel)

local OK_COLOR = Color3.fromRGB(120, 255, 140)
local stack = {}        -- the stacked codes, top to bottom
local stackRows = {}    -- [i] = { frame, label }
local redeem = { running = false, token = 0, log = {} }
local lastReply = nil

local function updateRedeemText()
	if not redeem.running then
		redeemBtn.Text = ("REDEEM ALL (%d)"):format(#stack)
	end
end

local function addLog(line)
	local l = redeem.log
	l[#l + 1] = line
	while #l > 5 do table.remove(l, 1) end
	logLabel.Text = table.concat(l, "\n")
end

local function refreshStack()
	for _, r in ipairs(stackRows) do r.frame:Destroy() end
	stackRows = {}
	for i, code in ipairs(stack) do
		local fr = new("Frame", {
			LayoutOrder = 100 + i,
			Size = UDim2.new(1, -4, 0, 28),
			BackgroundColor3 = C.dark,
			BackgroundTransparency = 0.3,
			BorderSizePixel = 0,
		}, pgCodes)
		corner(fr, 8)
		local lbl = new("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -40, 1, 0),
			Position = UDim2.fromOffset(10, 0),
			Font = Enum.Font.GothamMedium,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			TextColor3 = C.text,
			Text = i .. ". " .. code,
		}, fr)
		local x = new("TextButton", {
			Position = UDim2.new(1, -28, 0.5, -11),
			Size = UDim2.fromOffset(22, 22),
			BackgroundColor3 = C.red,
			BackgroundTransparency = 0.2,
			Text = "x",
			Font = Enum.Font.GothamBold,
			TextSize = 12,
			TextColor3 = C.text,
		}, fr)
		corner(x, 6)
		x.MouseButton1Click:Connect(function()
			if redeem.running then
				setStatus("Stop redeeming before removing codes.")
				return
			end
			table.remove(stack, i)
			refreshStack()
		end)
		stackRows[i] = { frame = fr, label = lbl }
	end
	stackHeader.Text = ("STACK: %d code%s"):format(#stack, #stack == 1 and "" or "s")
	updateRedeemText()
end

-- accepts one code or many at once (space, comma or new line separated)
local function addCodes(text)
	local added = 0
	for c in tostring(text):gmatch("[^%s,;]+") do
		local dupe = false
		for _, e in ipairs(stack) do
			if e:lower() == c:lower() then
				dupe = true
				break
			end
		end
		if not dupe then
			stack[#stack + 1] = c
			added += 1
		end
	end
	refreshStack()
	return added
end

local function submitInput()
	local text = codeInput.Text
	if text:match("^%s*$") then return end
	local n = addCodes(text)
	codeInput.Text = ""
	if n > 0 then
		setStatus(("Stacked %d code(s). Total: %d"):format(n, #stack))
	else
		setStatus("That code is already in the stack.")
	end
end
addBtn.MouseButton1Click:Connect(submitInput)
codeInput.FocusLost:Connect(function(enterPressed)
	if enterPressed then submitInput() end
end)

for _, c in ipairs(CONFIG.DefaultCodes) do stack[#stack + 1] = c end
refreshStack()

-- remember the newest system message so we can show the game's reply
pcall(function()
	track(TextChatService.MessageReceived:Connect(function(m)
		if m.TextSource == nil then
			lastReply = tostring(m.Text):gsub("<[^>]+>", "")
		end
	end))
end)

local function sendChat(msg)
	if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
		local ok = pcall(function()
			local channels = TextChatService:WaitForChild("TextChannels", 3)
			local ch = channels:FindFirstChild("RBXGeneral") or channels:FindFirstChildWhichIsA("TextChannel")
			assert(ch, "no text channel")
			ch:SendAsync(msg)
		end)
		if ok then return true end
	end
	return (pcall(function()
		local ev = ReplicatedStorage:WaitForChild("DefaultChatSystemChatEvents", 3)
		ev.SayMessageRequest:FireServer(msg, "All")
	end))
end

local function redeemAll()
	if redeem.running then return end
	local cmd = (cmdBox.Text or ""):match("^%s*(.-)%s*$")
	if cmd == "" then cmd = CONFIG.CodeCommand end
	if cmd:sub(1, 1) ~= "/" then cmd = "/" .. cmd end

	-- anything typed but not added yet gets stacked first
	if not codeInput.Text:match("^%s*$") then submitInput() end

	if #stack == 0 then
		setStatus("Stack some codes first (type one, tap ADD).")
		addLog("! stack is empty")
		return
	end

	local codes = {}
	for i, c in ipairs(stack) do codes[i] = c end
	for _, r in ipairs(stackRows) do r.label.TextColor3 = C.text end

	redeem.running = true
	redeem.token += 1
	local myToken = redeem.token
	redeemBtn.Text = "REDEEMING..."

	task.spawn(function()
		local failed = false
		for i, c in ipairs(codes) do
			if redeem.token ~= myToken or not gui.Parent then break end
			setStatus(("Redeeming %d/%d: %s"):format(i, #codes, c))
			if stackRows[i] then stackRows[i].label.TextColor3 = C.ice end
			lastReply = nil
			if sendChat(cmd .. " " .. c) then
				addLog("> sent " .. cmd .. " " .. c)
				if stackRows[i] then stackRows[i].label.TextColor3 = OK_COLOR end
				task.wait(CONFIG.RedeemDelay)
				if lastReply and redeem.token == myToken then
					addLog("   reply: " .. tostring(lastReply):sub(1, 38))
				end
			else
				addLog("x chat unavailable")
				if stackRows[i] then stackRows[i].label.TextColor3 = Color3.fromRGB(255, 90, 90) end
				failed = true
				break
			end
		end
		if redeem.token == myToken then
			redeem.running = false
			updateRedeemText()
			if failed then
				setStatus("Couldn't send to chat in this game.")
			else
				setStatus(("Done: sent %d code(s)."):format(#codes))
			end
		end
	end)
end

redeemBtn.MouseButton1Click:Connect(redeemAll)
stopBtn.MouseButton1Click:Connect(function()
	if redeem.running then
		redeem.token += 1
		redeem.running = false
		updateRedeemText()
		setStatus("Stopped.")
		addLog("# stopped")
	end
end)
clearBtn.MouseButton1Click:Connect(function()
	if redeem.running then
		redeem.token += 1
		redeem.running = false
	end
	stack = {}
	refreshStack()
	redeem.log = {}
	logLabel.Text = "log: cleared"
	setStatus("Stack cleared.")
end)

------------------------------------------------------------
-- FPS + ping counter
------------------------------------------------------------
local function readDataPing() return Stats.Network.ServerStatsItem["Data Ping"]:GetValue() end
local function readPerfPing() return Stats.PerformanceStats.Ping:GetValue() end
local function readNetPing() return player:GetNetworkPing() * 2000 end

local function getPing()
	local ok, v = pcall(readDataPing)
	if ok and type(v) == "number" and v > 0 then return v end
	ok, v = pcall(readPerfPing)
	if ok and type(v) == "number" and v > 0 then return v end
	ok, v = pcall(readNetPing)
	if ok and type(v) == "number" and v > 0 then return v end
	return nil
end

local function colorFor(value, good, ok, lowerBetter)
	if lowerBetter then
		if value <= good then return Color3.fromRGB(120, 255, 140) end
		if value <= ok then return Color3.fromRGB(255, 220, 80) end
		return Color3.fromRGB(255, 90, 90)
	end
	if value >= good then return Color3.fromRGB(120, 255, 140) end
	if value >= ok then return Color3.fromRGB(255, 220, 80) end
	return Color3.fromRGB(255, 90, 90)
end

local frames, lastCount, lastGraph = 0, os.clock(), os.clock()
local fps = 0

track(RunService.RenderStepped:Connect(function()
	frames += 1
	local now = os.clock()

	if now - lastCount >= 0.5 then
		fps = math.floor(frames / (now - lastCount) + 0.5)
		frames, lastCount = 0, now

		fpsLabel.Text = "FPS " .. fps
		fpsLabel.TextColor3 = colorFor(fps, 50, 30, false)

		local ping = getPing()
		if ping then
			ping = math.floor(ping + 0.5)
			pingLabel.Text = "PING " .. ping .. "ms"
			pingLabel.TextColor3 = colorFor(ping, 80, 150, true)
		else
			pingLabel.Text = "PING --"
			pingLabel.TextColor3 = C.text
		end
	end

	if now - lastGraph >= 0.5 then
		lastGraph = now
		if main.Visible and not minimized then
			table.remove(history, 1)
			history[BARS] = fps
			for i, bar in ipairs(bars) do
				local v = history[i]
				bar.Size = UDim2.new(1 / BARS, -1, math.clamp(v / 120, 0.05, 1), 0)
				bar.BackgroundColor3 = colorFor(v, 50, 30, false)
			end
		end
	end
end))

------------------------------------------------------------
-- Minimize / close / reopen
------------------------------------------------------------
local reopen = new("TextButton", {
	Name = "Reopen",
	Size = UDim2.fromOffset(46, 46),
	Position = UDim2.new(0, 10, 0.5, -23),
	BackgroundColor3 = C.dark,
	Text = "❄",
	TextSize = 22,
	Font = Enum.Font.GothamBold,
	TextColor3 = C.text,
	Visible = false,
}, gui)
corner(reopen, 23)
local rStroke = new("UIStroke", { Thickness = 2, Color = Color3.new(1, 1, 1) }, reopen)
local rGrad = new("UIGradient", { Color = grad.Color }, rStroke)


local sizeTween = nil
local function playSize(size, info)
	if sizeTween then sizeTween:Cancel() end
	sizeTween = TweenService:Create(main, info, { Size = size })
	sizeTween:Play()
end

local function setOpen(open)
	if open then
		reopen.Visible = false
		main.Visible = true
		main.Size = UDim2.fromOffset(W, 0)
		pcall(reclampAll)
		playSize(
			minimized and UDim2.fromOffset(W, 36) or UDim2.fromOffset(W, H),
			TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		)
	else
		if sizeTween then sizeTween:Cancel() end
		main.Visible = false
		pcall(reclampAll)
		reopen.Visible = true
	end
end

minBtn.MouseButton1Click:Connect(function()
	minimized = not minimized
	playSize(
		minimized and UDim2.fromOffset(W, 36) or UDim2.fromOffset(W, H),
		TweenInfo.new(0.25, Enum.EasingStyle.Quad)
	)
	minBtn.Text = minimized and "+" or "–"
end)
closeBtn.MouseButton1Click:Connect(function() setOpen(false) end)

-- the snowflake: drag it anywhere, tap it to bring the panel back
local reopenDrag = makeDraggable(reopen, reopen, 46, 46, nil)
reopen.Activated:Connect(function()
	if not reopenDrag.moved then setOpen(true) end
end)

track(UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Enum.KeyCode.RightShift then
		setOpen(not main.Visible)
	end
end))

-- animated border and neon pulse (one cheap loop, ~20 updates/sec)
local acc, spin = 0, 0
track(RunService.Heartbeat:Connect(function(dt)
	if not main.Visible and not reopen.Visible then return end
	acc += dt
	if acc < 0.05 then return end
	spin = (spin + acc * 80) % 360
	acc = 0
	grad.Rotation = spin
	rGrad.Rotation = spin
	if main.Visible and not minimized then
		local now = os.clock()
		local pulse = 0.5 + 0.5 * math.sin(now * 2.4)
		for _, g in ipairs(neonGlow) do g.BackgroundTransparency = 0.05 + 0.25 * pulse end
	end
end))

------------------------------------------------------------
-- Cleanup (runs automatically if the script is executed again)
------------------------------------------------------------
do
	local ok, env = pcall(function() return getgenv() end)
	if ok and type(env) == "table" then
		env.FrostBoostCleanup = function()
			pcall(stopStretch)
			pcall(function() if boost.on then disableBoost() end end)
			pcall(function() if dark.on then setDark(false) end end)
			pcall(function()
				for p in pairs(hideSet) do setPlayerHidden(p, false) end
			end)
			pcall(function() if shadowConn then shadowConn:Disconnect() end end)
			for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
			for _, f in ipairs(cleanups) do pcall(f) end
			pcall(function() gui:Destroy() end)
		end
	end
end

------------------------------------------------------------
-- Start
------------------------------------------------------------
------------------------------------------------------------
-- Intro: black screen, bold "OPTIMIZED BY FROST"
------------------------------------------------------------
local function playIntro(onDone)
	if not CONFIG.ShowIntro then
		onDone()
		return
	end
	local overlay = new("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		Active = true,
		ZIndex = 100,
	}, gui)
	local label = new("TextLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.new(0.9, 0, 0, 44),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBlack,
		TextSize = 30,
		TextColor3 = Color3.new(1, 1, 1),
		TextTransparency = 1,
		TextWrapped = true,
		Text = "OPTIMIZED BY FROST",
		ZIndex = 101,
	}, overlay)
	local glow = new("UIStroke", {
		Thickness = 2, Color = C.ice, Transparency = 1,
	}, label)

	local skip = new("TextButton", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Text = "",
		ZIndex = 110,
	}, overlay)

	local done = false
	local function finish()
		if done then return end
		done = true
		TweenService:Create(overlay, TweenInfo.new(0.3), { BackgroundTransparency = 1 }):Play()
		TweenService:Create(label, TweenInfo.new(0.25), { TextTransparency = 1 }):Play()
		task.delay(0.3, function()
			overlay:Destroy()
			onDone()
		end)
	end
	skip.Activated:Connect(finish)

	TweenService:Create(label, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		TextTransparency = 0,
	}):Play()
	TweenService:Create(glow, TweenInfo.new(0.45), { Transparency = 0.3 }):Play()
	task.delay(1.6, finish)
end

selectTab(1)
playIntro(function()
	setOpen(true)
	for _, f in ipairs(onReady) do pcall(f) end
	if CONFIG.AutoRedeemOnStart and #CONFIG.DefaultCodes > 0 then
		task.delay(4, redeemAll)
	end
end)
