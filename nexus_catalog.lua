task.spawn(function()
local W=workspace
local H=game:GetService("HttpService")
local G=game:GetService("CoreGui")
local T=game:GetService("TweenService")
local P=game:GetService("Players").LocalPlayer
local PG=P:FindFirstChild("PlayerGui") or G
local RS=game:GetService("ReplicatedStorage")
local U="https://catalogplugins.nvlzskidd.workers.dev"
local PF="nexus_plugins.json"
local UID=tostring(P.UserId)

local function RQ(m,p,b)
    local r=request or http_request or (syn and syn.request) or (fluxus and fluxus.request) or (http and http.request)
    if not r then return false,"no_http" end
    local u=U..p
    local o={Url=u,url=u,Method=m,method=m,Headers={["Content-Type"]="application/json",["X-Admin-Uid"]=UID}}
    if b then local e=H:JSONEncode(b);o.Body=e;o.body=e end
    local ok,res=pcall(r,o)
    if not ok or not res then return false,"conn" end
    local sc=tonumber(res.StatusCode or res.status_code or res.Status)
    local bd=res.Body or res.body
    if not bd then return false,"empty" end
    local okD,d=pcall(H.JSONDecode,H,bd)
    if not okD then return false,"json" end
    if sc and sc>=400 then return false,(type(d)=="table" and (d.reason or d.error)) or ("H"..sc),d end
    return true,d
end

local C={Rm={},In={},Ld=false,UI=nil,OC=nil,Adm=false}
pcall(function() local c=readfile and readfile(PF);if c and c~="" then local d=H:JSONDecode(c);if type(d)=="table" then C.In=d end end end)
local function SV() if not writefile then return end;pcall(writefile,PF,H:JSONEncode(C.In));if C.OC then pcall(C.OC,C.In)end end

function C.H(id) return C.In[id]~=nil end
function C.PE() local o={} for _,p in pairs(C.In)do if p.prompt_extension and p.prompt_extension~="" then table.insert(o,"### PLUGIN: "..p.name.." ###\n"..p.prompt_extension)end end return table.concat(o,"\n\n")end
function C.CT() local t={} for _,p in pairs(C.In)do if p.custom_tools then for _,c in ipairs(p.custom_tools)do t[c.name]={plugin=p.name,spec=c}end end end return t end
function C.SG() local o={} for _,p in pairs(C.In)do if p.suggestions then for _,s in ipairs(p.suggestions)do if #o<6 then table.insert(o,s)end end end end return o end
function C.ET(n,core,a) local c=C.CT()[n] if not c then return false,"nr" end if not c.spec.composes or #c.spec.composes==0 then return false,"nc" end local r={} for _,s in ipairs(c.spec.composes)do local f=core[s.tool] if not f then table.insert(r,"[SKIP] "..s.tool) else local sa={} for k,v in pairs(s.args or {})do sa[k]=v end for k,v in pairs(a or {})do sa[k]=v end local ok,x=pcall(f,sa) table.insert(r,(ok and "[OK] " or "[ERR] ")..s.tool..": "..tostring(x))end end return true,table.concat(r,"\n")end

function C.Ins(id) local ok,d=RQ("GET","/plugins/"..id) if not ok then return false,d end if not d.plugin then return false,"nf" end C.In[id]=d.plugin;SV();return true,d.plugin end
function C.Uns(id) if not C.In[id] then return false,"ni" end C.In[id]=nil;SV();return true end
function C.RF() if C.Ld then return false,"ld" end C.Ld=true local ok,d=RQ("GET","/plugins") C.Ld=false if not ok then return false,d end C.Rm=d.plugins or {} return true end
function C.Pub(pd) local pl={} for k,v in pairs(pd)do pl[k]=v end pl.author_id=UID pl.author_name=P.DisplayName or P.Name local ok,d=RQ("POST","/plugins",pl) if not ok then return false,d end return true,d end
function C.Mine() local ok,d=RQ("GET","/my-plugins?user_id="..UID) if not ok then return false,d end return true,d.plugins or {} end
function C.Rt(id,s) return RQ("POST","/plugins/"..id.."/rate",{stars=s}) end
function C.Au(u) return RQ("GET","/authors/"..u) end
function C.AdL() return RQ("GET","/admin/all-plugins") end
function C.AdA(id) return RQ("POST","/admin/approve/"..id,{reason="a"}) end
function C.AdR(id) return RQ("POST","/admin/reject/"..id,{reason="r"}) end
function C.AdD(id) return RQ("DELETE","/plugins/"..id) end

local SG={Vector3=Vector3,Vector2=Vector2,CFrame=CFrame,Color3=Color3,UDim=UDim,UDim2=UDim2,Enum=Enum,BrickColor=BrickColor,Ray=Ray,math=math,string=string,table=table,tonumber=tonumber,tostring=tostring,type=type,typeof=typeof,ipairs=ipairs,pairs=pairs,next=next,select=select,unpack=unpack or table.unpack,pcall=pcall,xpcall=xpcall,error=error,assert=assert,os={time=os.time,clock=os.clock,date=os.date},task={wait=task.wait,spawn=task.spawn,delay=task.delay,defer=task.defer},coroutine={create=coroutine.create,resume=coroutine.resume,status=coroutine.status,yield=coroutine.yield,wrap=coroutine.wrap,close=coroutine.close}}
local BLK={"game","workspace","Workspace","_G","shared","_ENV","loadstring","load","require","getfenv","setfenv","debug","rawset","rawget","rawequal","rawlen","getreg","request","http_request","syn","fluxus","http","getrawmetatable","setreadonly","newcclosure","hookfunction","hookmetamethod","Instance","script","Player","Players","ReplicatedStorage","ServerScriptService","ServerStorage"}

local function BA(n)
    local function ch() return P.Character end
    local function hu() local c=ch() return c and c:FindFirstChildOfClass("Humanoid")end
    local function hp() local c=ch() return c and c:FindFirstChild("HumanoidRootPart")end
    local bg={say=0,tp=0}
    local a={}
    a.get_local_player=function() return{name=P.Name,display=P.DisplayName,id=P.UserId}end
    a.get_character=ch a.get_humanoid=hu a.get_hrp=hp
    a.get_health=function() local h=hu() return h and h.Health or 0 end
    a.get_position=function() local r=hp() return r and r.Position or Vector3.new(0,0,0)end
    a.set_walkspeed=function(v) v=tonumber(v) if not v then return false end v=math.clamp(v,0,500) local h=hu() if h then h.WalkSpeed=v return true end return false end
    a.set_jumppower=function(v) v=tonumber(v) if not v then return false end v=math.clamp(v,0,500) local h=hu() if h then h.JumpPower=v return true end return false end
    a.set_gravity=function(v) v=tonumber(v) if not v then return false end W.Gravity=math.clamp(v,0,500) return true end
    a.teleport_to=function(x,y,z) bg.tp=bg.tp+1 if bg.tp>20 then return false end x,y,z=tonumber(x),tonumber(y),tonumber(z) if not(x and y and z)then return false end local r=hp() if r then r.CFrame=CFrame.new(x,y,z) return true end return false end
    a.heal=function(v) v=tonumber(v)or 100 local h=hu() if h then h.Health=math.min(h.MaxHealth,h.Health+v) return true end return false end
    a.say=function(t) bg.say=bg.say+1 if bg.say>3 then return false end t=tostring(t or ""):sub(1,200) pcall(function() local l=RS:FindFirstChild("DefaultChatSystemChatEvents") if l and l:FindFirstChild("SayMessageRequest")then l.SayMessageRequest:FireServer(t,"All")else local tc=game:GetService("TextChatService") if tc.ChatVersion==Enum.ChatVersion.TextChatService then local c=tc.TextChannels:FindFirstChild("RBXGeneral") if c then c:SendAsync(t)end end end end) return true end
    a.get_players=function() local o={} for _,p in ipairs(game:GetService("Players"):GetPlayers())do local c=p.Character local h=c and c:FindFirstChildOfClass("Humanoid")local r=c and c:FindFirstChild("HumanoidRootPart")table.insert(o,{name=p.Name,display=p.DisplayName,health=h and h.Health or 0,max_health=h and h.MaxHealth or 0,position=r and r.Position or Vector3.new(0,0,0)})end return o end
    a.get_nearest_player=function() local me=hp() if not me then return nil end local b,bd for _,p in ipairs(game:GetService("Players"):GetPlayers())do if p~=P and p.Character then local r=p.Character:FindFirstChild("HumanoidRootPart")if r then local d=(r.Position-me.Position).Magnitude if not bd or d<bd then b=p bd=d end end end end if b then return{name=b.Name,display=b.DisplayName,distance=bd}end end
    a.log=function(m) print("[P:"..n.."]",m)end
    a.wait=function(s) task.wait(math.clamp(tonumber(s)or 0,0,5))end
    return a
end

local SB={}
function SB.R(n,code,a)
    if type(code)~="string" or code=="" then return false,"e" end
    if #code>8000 then return false,"big" end
    for _,w in ipairs(BLK)do if code:find("%f[%a_]"..w:gsub("%%","%%%%").."%f[^%a_]")then return false,"blk:"..w end end
    local e={} for k,v in pairs(SG)do e[k]=v end e.__args=a or {} e.api=BA(n)
    local ld=loadstring or load if not ld then return false,"nl" end
    local fn,ce=ld(code,"=p_"..n) if not fn then return false,"c:"..tostring(ce)end
    local co=coroutine.create(function() return fn()end)
    local st=tick() local dn=false
    task.spawn(function() while not dn and tick()-st<3 do task.wait(0.05)end if not dn then pcall(coroutine.close,co)end end)
    local ok,r=coroutine.resume(co) dn=true
    if not ok then return false,"r:"..tostring(r)end
    if coroutine.status(co)~="dead" then return false,"t" end
    return true,r
end

local K={Bg=Color3.fromRGB(7,7,8),Sf=Color3.fromRGB(12,12,14),Cd=Color3.fromRGB(17,17,19),CdH=Color3.fromRGB(24,24,27),Bd=Color3.fromRGB(48,48,52),BdS=Color3.fromRGB(31,31,35),Tx=Color3.fromRGB(255,255,255),Tx2=Color3.fromRGB(190,190,195),TxM=Color3.fromRGB(110,110,116),Gr=Color3.fromRGB(46,204,113),Rd=Color3.fromRGB(231,76,60),Yl=Color3.fromRGB(241,196,15),Bl=Color3.fromRGB(88,165,255)}

local function I(c,p,pt) local i=Instance.new(c) if p then for k,v in pairs(p)do i[k]=v end end if pt then i.Parent=pt end return i end
local function CR(o,r,st,sc,col) I("UICorner",{CornerRadius=UDim.new(0,r or 8),Parent=o}) if st then I("UIStroke",{Thickness=st,Transparency=sc or 0.5,Color=col or K.Bd,Parent=o})end return o end
local function TW(o,p,d) T:Create(o,TweenInfo.new(d or 0.15,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),p):Play()end

local function Bld()
    if C.UI then C.UI:Destroy()end
    local g=I("ScreenGui",{Name="NEXUS_CATALOG",ResetOnSpawn=false,IgnoreGuiInset=true,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},PG)
    local us=I("UIScale",nil,g)
    local function up() local c=W.CurrentCamera if not c then return end local v=c.ViewportSize us.Scale=math.clamp(math.min(v.X/900,v.Y/650),0.72,1.15)end
    up() if W.CurrentCamera then W.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(up)end

    local M=I("Frame",{Size=UDim2.new(0,860,0,600),AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),BackgroundColor3=K.Bg,BorderSizePixel=0},g)
    CR(M,14,1,0.55,K.Bd)

    local H=I("Frame",{Size=UDim2.new(1,0,0,62),BackgroundColor3=Color3.fromRGB(11,11,13),BorderSizePixel=0},M)
    CR(H,14)
    I("TextLabel",{Position=UDim2.new(0,20,0,14),Size=UDim2.new(0,400,0,24),BackgroundTransparency=1,Font=Enum.Font.GothamBold,Text="NEXUS • PLUGIN CATALOG",TextColor3=K.Tx,TextSize=16,TextXAlignment=Enum.TextXAlignment.Left},H)
    I("TextLabel",{Position=UDim2.new(0,20,0,36),Size=UDim2.new(0,500,0,16),BackgroundTransparency=1,Font=Enum.Font.Gotham,Text="AI-verified global extensions",TextColor3=K.TxM,TextSize=10,TextXAlignment=Enum.TextXAlignment.Left},H)

    local cl=I("TextButton",{AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-14,.5,0),Size=UDim2.new(0,32,0,32),BackgroundColor3=Color3.fromRGB(20,20,23),BorderSizePixel=0,Text="×",Font=Enum.Font.GothamMedium,TextSize=18,TextColor3=K.TxM,AutoButtonColor=false},H)
    CR(cl,8,1,0.65,K.BdS)
    cl.MouseEnter:Connect(function() TW(cl,{BackgroundColor3=Color3.fromRGB(48,48,52),TextColor3=K.Tx})end)
    cl.MouseLeave:Connect(function() TW(cl,{BackgroundColor3=Color3.fromRGB(20,20,23),TextColor3=K.TxM})end)
    cl.MouseButton1Click:Connect(function() g.Enabled=false end)

    local TB=I("Frame",{Position=UDim2.new(0,14,0,70),Size=UDim2.new(1,-28,0,34),BackgroundTransparency=1},M)
    I("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,6)},TB)

    local PGS=I("Frame",{Position=UDim2.new(0,14,0,112),Size=UDim2.new(1,-28,1,-126),BackgroundTransparency=1},M)
    local Pages={} local Tabs={} local cur
    local function Sel(n) if cur==n then return end cur=n for k,v in pairs(Pages)do v.Visible=(k==n)end for k,v in pairs(Tabs)do local on=(k==n) TW(v,{BackgroundColor3=on and Color3.fromRGB(30,30,34)or Color3.fromRGB(15,15,18),TextColor3=on and K.Tx or K.TxM})end end
    local function Mk(n,l) local b=I("TextButton",{Size=UDim2.new(0,110,0,30),BackgroundColor3=Color3.fromRGB(15,15,18),BorderSizePixel=0,Font=Enum.Font.GothamBold,TextSize=10,Text=l,TextColor3=K.TxM,AutoButtonColor=false},TB) CR(b,8,1,0.7,K.BdS) b.MouseButton1Click:Connect(function() Sel(n)end) Tabs[n]=b local pg=I("ScrollingFrame",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=4,ScrollBarImageColor3=K.Bd,CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,Visible=false},PGS) I("UIListLayout",{Padding=UDim.new(0,10),SortOrder=Enum.SortOrder.LayoutOrder},pg) I("UIPadding",{PaddingTop=UDim.new(0,6),PaddingBottom=UDim.new(0,16),PaddingLeft=UDim.new(0,4),PaddingRight=UDim.new(0,4)},pg) Pages[n]=pg return pg end

    local PC=Mk("catalog","CATALOG")
    local PI=Mk("installed","INSTALLED")
    local PM=Mk("mine","MY PLUGINS")
    local PP=Mk("publish","PUBLISH")
    local PA=C.Adm and Mk("admin","ADMIN") or nil
    Sel("catalog")

    local function Pop(u,nm)
        local pop=I("Frame",{Size=UDim2.new(0,320,0,220),AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),BackgroundColor3=K.Sf,BorderSizePixel=0,ZIndex=100},g)
        CR(pop,12,1,0.4,K.Bd)
        I("TextLabel",{Size=UDim2.new(1,-20,0,30),Position=UDim2.new(0,14,0,14),BackgroundTransparency=1,Font=Enum.Font.GothamBold,TextSize=15,Text="@"..nm,TextColor3=K.Tx,TextXAlignment=Enum.TextXAlignment.Left},pop)
        local inf=I("TextLabel",{Size=UDim2.new(1,-20,0,120),Position=UDim2.new(0,14,0,52),BackgroundTransparency=1,Font=Enum.Font.Gotham,TextSize=12,TextColor3=K.Tx2,TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top,Text="Loading..."},pop)
        local cb=I("TextButton",{Size=UDim2.new(1,-28,0,32),Position=UDim2.new(0,14,1,-46),BackgroundColor3=Color3.fromRGB(20,20,23),BorderSizePixel=0,Text="CLOSE",Font=Enum.Font.GothamBold,TextSize=11,TextColor3=K.Tx2,AutoButtonColor=false},pop)
        CR(cb,8,1,0.6,K.BdS) cb.MouseButton1Click:Connect(function() pop:Destroy()end)
        task.spawn(function() local ok,d=C.Au(u) if not ok or not d then inf.Text="Failed." return end inf.Text=string.format("Status: %s\nDownloads: %d\nPlugins: %d\nReason: %s",d.verified and "✓ VERIFIED"or "unverified",d.total_downloads or 0,d.plugin_count or 0,d.verified_reason or "n/a")end)
    end

    local function Cd(pl,o)
        local cd=I("Frame",{Size=UDim2.new(1,-8,0,110),BackgroundColor3=K.Cd,BorderSizePixel=0,LayoutOrder=o},PC)
        CR(cd,10) local cs=cd:FindFirstChildOfClass("UIStroke")
        I("TextLabel",{Position=UDim2.new(0,14,0,10),Size=UDim2.new(1,-260,0,20),BackgroundTransparency=1,Font=Enum.Font.GothamBold,TextSize=14,Text=pl.name or "?",TextColor3=K.Tx,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd},cd)
        if pl.author_verified then local ab=I("TextLabel",{Position=UDim2.new(0,14,0,30),Size=UDim2.new(0,90,0,16),BackgroundColor3=Color3.fromRGB(15,32,55),BorderSizePixel=0,Font=Enum.Font.GothamBold,TextSize=9,Text="✓ VERIFIED",TextColor3=K.Bl},cd) CR(ab,4,1,0.4,K.Bl) end
        local aY=pl.author_verified and 50 or 30
        local ab=I("TextButton",{Position=UDim2.new(0,14,0,aY),Size=UDim2.new(0,200,0,14),BackgroundTransparency=1,Font=Enum.Font.Gotham,TextSize=10,Text="by @"..tostring(pl.author_name or "?").."  •  v"..tostring(pl.version or "1.0.0"),TextColor3=K.TxM,TextXAlignment=Enum.TextXAlignment.Left,AutoButtonColor=false},cd)
        ab.MouseEnter:Connect(function() TW(ab,{TextColor3=K.Bl})end) ab.MouseLeave:Connect(function() TW(ab,{TextColor3=K.TxM})end)
        ab.MouseButton1Click:Connect(function() if pl.author_id then Pop(pl.author_id,pl.author_name or "?")end end)
        I("TextLabel",{Position=UDim2.new(0,14,0,aY+18),Size=UDim2.new(1,-280,0,40),BackgroundTransparency=1,Font=Enum.Font.Gotham,TextSize=11,TextWrapped=true,Text=pl.description or "",TextColor3=K.Tx2,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top,TextTruncate=Enum.TextTruncate.AtEnd},cd)
        local isI=C.H(pl.id)
        local bt=I("TextButton",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-14,0,10),Size=UDim2.new(0,140,0,32),BorderSizePixel=0,Font=Enum.Font.GothamBold,TextSize=11,BackgroundColor3=isI and Color3.fromRGB(34,34,38)or Color3.fromRGB(242,242,242),Text=isI and "REMOVE"or "INSTALL",TextColor3=isI and K.Tx2 or Color3.fromRGB(12,12,12),AutoButtonColor=false},cd)
        CR(bt,8) if isI then I("UIStroke",{Thickness=1,Transparency=0.6,Color=K.Bd,Parent=bt})end
        bt.MouseEnter:Connect(function() TW(bt,{BackgroundColor3=isI and Color3.fromRGB(58,58,62)or Color3.fromRGB(255,255,255)})end)
        bt.MouseLeave:Connect(function() TW(bt,{BackgroundColor3=isI and Color3.fromRGB(34,34,38)or Color3.fromRGB(242,242,242)})end)
        bt.MouseButton1Click:Connect(function() if C.H(pl.id)then C.Uns(pl.id) bt.Text="INSTALL" bt.TextColor3=Color3.fromRGB(12,12,12) bt.BackgroundColor3=Color3.fromRGB(242,242,242) isI=false else bt.Text="..." task.spawn(function() local ok=C.Ins(pl.id) if ok then bt.Text="REMOVE" bt.TextColor3=K.Tx2 bt.BackgroundColor3=Color3.fromRGB(34,34,38) isI=true else bt.Text="ERR" bt.BackgroundColor3=Color3.fromRGB(45,20,20) bt.TextColor3=K.Rd task.wait(1.5) bt.Text="INSTALL" bt.TextColor3=Color3.fromRGB(12,12,12) bt.BackgroundColor3=Color3.fromRGB(242,242,242)end end)end end)
        if C.Adm then local dl=I("TextButton",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-14,0,48),Size=UDim2.new(0,140,0,26),BackgroundColor3=Color3.fromRGB(45,20,20),BorderSizePixel=0,Font=Enum.Font.GothamBold,TextSize=10,Text="DEL",TextColor3=K.Rd,AutoButtonColor=false},cd) CR(dl,6,1,0.5,K.Rd) dl.MouseButton1Click:Connect(function() dl.Text="..." task.spawn(function() local ok=C.AdD(pl.id) if ok then cd:Destroy()else dl.Text="ERR" task.wait(1.5) dl.Text="DEL" end end)end)end
        local sf=I("Frame",{AnchorPoint=Vector2.new(1,1),Position=UDim2.new(1,-14,1,-8),Size=UDim2.new(0,150,0,20),BackgroundTransparency=1},cd)
        I("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,HorizontalAlignment=Enum.HorizontalAlignment.Right,VerticalAlignment=Enum.VerticalAlignment.Center,Padding=UDim.new(0,2)},sf)
        local cs2=math.floor(pl.rating or 0)
        for i=1,5 do local s=I("TextButton",{Size=UDim2.new(0,22,0,20),BackgroundTransparency=1,Text=i<=cs2 and "★"or "☆",TextSize=16,Font=Enum.Font.GothamBold,TextColor3=i<=cs2 and K.Yl or K.TxM,AutoButtonColor=false},sf) s.MouseEnter:Connect(function() if i>cs2 then s.TextColor3=K.Yl end end) s.MouseLeave:Connect(function() if i>cs2 then s.TextColor3=K.TxM end end) s.MouseButton1Click:Connect(function() task.spawn(function() local ok=C.Rt(pl.id,i) if ok then cs2=i for j,b in ipairs(sf:GetChildren())do if b:IsA("TextButton")then b.Text=j<=i and "★"or "☆" b.TextColor3=j<=i and K.Yl or K.TxM end end end end)end)end
        if (pl.ratings_count or 0)>0 then I("TextLabel",{AnchorPoint=Vector2.new(1,1),Position=UDim2.new(1,-170,1,-8),Size=UDim2.new(0,80,0,16),BackgroundTransparency=1,Font=Enum.Font.Gotham,TextSize=9,Text=string.format("%.1f (%d)",pl.rating or 0,pl.ratings_count or 0),TextColor3=K.TxM,TextXAlignment=Enum.TextXAlignment.Right},cd)end
        cd.MouseEnter:Connect(function() TW(cd,{BackgroundColor3=K.CdH}) if cs then TW(cs,{Transparency=0.4})end end)
        cd.MouseLeave:Connect(function() TW(cd,{BackgroundColor3=K.Cd}) if cs then TW(cs,{Transparency=0.65})end end)
    end

    local function RC() for _,c in ipairs(PC:GetChildren())do if c:IsA("Frame")or c:IsA("TextLabel")then c:Destroy()end end if #C.Rm==0 then I("TextLabel",{Size=UDim2.new(1,0,0,60),BackgroundTransparency=1,Font=Enum.Font.Gotham,TextSize=12,Text=C.Ld and "Loading..."or "No plugins yet.",TextColor3=K.TxM},PC) return end for i,p in ipairs(C.Rm)do Cd(p,i)end end
    RC()

    local rf=I("TextButton",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-14,0,70),Size=UDim2.new(0,90,0,28),BackgroundColor3=Color3.fromRGB(20,20,24),BorderSizePixel=0,Font=Enum.Font.GothamBold,TextSize=10,Text="R",TextColor3=K.Tx2,AutoButtonColor=false},M)
    CR(rf,6,1,0.65,K.BdS) rf.MouseButton1Click:Connect(function() rf.Text="..." task.spawn(function() C.RF() RC() rf.Text="R" end)end)
    task.spawn(function() C.RF() RC() end)

    local function RI() for _,c in ipairs(PI:GetChildren())do if c:IsA("Frame")or c:IsA("TextLabel")then c:Destroy()end end local any=false local o=0 for id,p in pairs(C.In)do any=true o=o+1 local cd=I("Frame",{Size=UDim2.new(1,-8,0,80),BackgroundColor3=K.Cd,BorderSizePixel=0,LayoutOrder=o},PI) CR(cd,10,1,0.65,K.BdS) I("TextLabel",{Position=UDim2.new(0,14,0,12),Size=UDim2.new(1,-160,0,20),BackgroundTransparency=1,Font=Enum.Font.GothamBold,TextSize=14,Text=p.name or "?",TextColor3=K.Tx,TextXAlignment=Enum.TextXAlignment.Left},cd) I("TextLabel",{Position=UDim2.new(0,14,0,36),Size=UDim2.new(1,-160,0,32),BackgroundTransparency=1,Font=Enum.Font.Gotham,TextSize=11,TextWrapped=true,Text=p.description or "",TextColor3=K.Tx2,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top},cd) local rm=I("TextButton",{AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-14,.5,0),Size=UDim2.new(0,120,0,32),BackgroundColor3=Color3.fromRGB(45,20,20),BorderSizePixel=0,Font=Enum.Font.GothamBold,TextSize=11,Text="REMOVE",TextColor3=K.Rd,AutoButtonColor=false},cd) CR(rm,8,1,0.4,K.Rd) rm.MouseButton1Click:Connect(function() C.Uns(id) RI()end)end if not any then I("TextLabel",{Size=UDim2.new(1,0,0,60),BackgroundTransparency=1,Font=Enum.Font.Gotham,TextSize=12,Text="Empty.",TextColor3=K.TxM},PI)end end
    RI() C.OC=function() RI()end

    local function RM() for _,c in ipairs(PM:GetChildren())do if c:IsA("Frame")or c:IsA("TextLabel")then c:Destroy()end end task.spawn(function() local ok,l=C.Mine() if not ok then I("TextLabel",{Size=UDim2.new(1,0,0,40),BackgroundTransparency=1,Font=Enum.Font.Gotham,TextSize=11,Text="E:"..tostring(l),TextColor3=K.Rd},PM) return end if #l==0 then I("TextLabel",{Size=UDim2.new(1,0,0,60),BackgroundTransparency=1,Font=Enum.Font.Gotham,TextSize=12,Text="None.",TextColor3=K.TxM},PM) return end for i,p in ipairs(l)do local cd=I("Frame",{Size=UDim2.new(1,-8,0,70),BackgroundColor3=K.Cd,BorderSizePixel=0,LayoutOrder=i},PM) CR(cd,10,1,0.65,K.BdS) I("TextLabel",{Position=UDim2.new(0,14,0,10),Size=UDim2.new(1,-160,0,20),BackgroundTransparency=1,Font=Enum.Font.GothamBold,TextSize=14,Text=p.name or "?",TextColor3=K.Tx,TextXAlignment=Enum.TextXAlignment.Left},cd) local sc=K.TxM local st=tostring(p.status or "?"):upper() if p.status=="approved"then sc=K.Gr elseif p.status=="rejected"then sc=K.Rd elseif p.status=="pending"then sc=K.Yl elseif p.status=="failed"then sc=K.Rd end I("TextLabel",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-14,0,10),Size=UDim2.new(0,120,0,22),BackgroundColor3=Color3.fromRGB(20,20,24),BorderSizePixel=0,Font=Enum.Font.GothamBold,TextSize=10,Text=st,TextColor3=sc},cd) CR(cd:FindFirstChildOfClass("Frame"),6,1,0.5,sc) end end)end
    RM()

    local function MkInp(y,l,ph,h) I("TextLabel",{Position=UDim2.new(0,6,0,y),Size=UDim2.new(1,-12,0,16),BackgroundTransparency=1,Font=Enum.Font.GothamBold,TextSize=10,Text=l,TextColor3=K.TxM,TextXAlignment=Enum.TextXAlignment.Left},PP) local b=I("TextBox",{Position=UDim2.new(0,6,0,y+20),Size=UDim2.new(1,-12,0,h or 36),BackgroundColor3=Color3.fromRGB(17,17,20),BorderSizePixel=0,Font=Enum.Font.Gotham,TextSize=12,Text="",PlaceholderText=ph,PlaceholderColor3=Color3.fromRGB(78,78,84),TextColor3=K.Tx,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=(h and h>40)and Enum.TextYAlignment.Top or Enum.TextYAlignment.Center,ClearTextOnFocus=false,MultiLine=(h or 0)>40,TextWrapped=(h or 0)>40},PP) CR(b,8,1,0.65,K.BdS) I("UIPadding",{PaddingLeft=UDim.new(0,10),PaddingRight=UDim.new(0,10),PaddingTop=UDim.new(0,8),PaddingBottom=UDim.new(0,8)},b) return b end

    local iN=MkInp(0,"NAME","My Plugin")
    local iD=MkInp(64,"DESC","Description",60)
    local iP=MkInp(148,"PROMPT (OPT)","Optional",100)
    local iT=MkInp(272,"TOOLS (OPT)","Optional",40)
    local iC=MkInp(336,"CODE (OPT)","Optional",140)

    local sl=I("TextLabel",{Position=UDim2.new(0,6,0,500),Size=UDim2.new(1,-12,0,60),BackgroundTransparency=1,Font=Enum.Font.Gotham,TextSize=11,TextWrapped=true,Text="",TextColor3=K.TxM,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top},PP)
    local pb=I("TextButton",{Position=UDim2.new(0,6,0,570),Size=UDim2.new(0,180,0,42),BackgroundColor3=Color3.fromRGB(242,242,242),BorderSizePixel=0,Font=Enum.Font.GothamBold,TextSize=12,Text="PUBLISH",TextColor3=Color3.fromRGB(12,12,12),AutoButtonColor=false},PP) CR(pb,8)
    local pub=false
    pb.MouseButton1Click:Connect(function() if pub then return end local nm=iN.Text:gsub("^%s+",""):gsub("%s+$","") local ds=iD.Text:gsub("^%s+",""):gsub("%s+$","") local pr=iP.Text:gsub("^%s+",""):gsub("%s+$","") local tS=iT.Text local cS=iC.Text:gsub("^%s+",""):gsub("%s+$","") if #nm<3 then sl.TextColor3=K.Rd sl.Text="Name too short" return end if #ds<10 then sl.TextColor3=K.Rd sl.Text="Desc too short" return end local tl={} for t in tS:gmatch("[^,]+")do local c=t:gsub("%s","") if c~=""then table.insert(tl,c)end end local ct={} if cS~=""then local tn=nm:lower():gsub("%s+","_"):gsub("[^%w_]",""):sub(1,40) table.insert(ct,{name=tn,desc=ds:sub(1,200),args={},code=cS})end pub=true pb.Text="..." pb.BackgroundColor3=Color3.fromRGB(200,200,200) sl.TextColor3=K.TxM sl.Text="Reviewing..." task.spawn(function() local pl={name=nm,description=ds,prompt_extension=pr,uses_tools=tl,custom_tools=ct,suggestions={},version="1.0.0"} local ok,d=C.Pub(pl) pub=false local function rs() task.wait(3.5) pb.Text="PUBLISH" pb.BackgroundColor3=Color3.fromRGB(242,242,242) pb.TextColor3=Color3.fromRGB(12,12,12)end local function clf() iN.Text="" iD.Text="" iP.Text="" iT.Text="" iC.Text="" end if ok and d and d.status=="approved"then pb.Text="OK" pb.BackgroundColor3=Color3.fromRGB(50,175,95) pb.TextColor3=K.Tx sl.TextColor3=K.Gr sl.Text="Approved!" clf() task.spawn(function() C.RF() RC() RM()end) rs() elseif ok and d and d.status=="pending"then pb.Text="Q" pb.BackgroundColor3=Color3.fromRGB(200,160,45) sl.TextColor3=K.Yl sl.Text="Queued" clf() task.spawn(function() RM()end) rs() else pb.Text="REJ" pb.BackgroundColor3=Color3.fromRGB(180,55,55) pb.TextColor3=K.Tx sl.TextColor3=K.Rd sl.Text=tostring(d) rs() end end)end)

    if C.Adm and PA then local function RA() for _,c in ipairs(PA:GetChildren())do if c:IsA("Frame")or c:IsA("TextLabel")or c:IsA("TextButton")then c:Destroy()end end local tb=I("Frame",{Size=UDim2.new(1,-8,0,34),BackgroundColor3=Color3.fromRGB(15,15,18),BorderSizePixel=0,LayoutOrder=0},PA) CR(tb,8) local rl=I("TextButton",{Size=UDim2.new(0,120,0,26),Position=UDim2.new(0,4,.5,-13),BackgroundColor3=Color3.fromRGB(30,30,34),BorderSizePixel=0,Font=Enum.Font.GothamBold,TextSize=10,Text="RELOAD",TextColor3=K.Tx2,AutoButtonColor=false},tb) CR(rl,6,1,0.6,K.BdS) local stt=I("TextLabel",{Position=UDim2.new(0,140,0,0),Size=UDim2.new(1,-150,1,0),BackgroundTransparency=1,Font=Enum.Font.Gotham,TextSize=10,TextColor3=K.TxM,TextXAlignment=Enum.TextXAlignment.Left,Text="..."},tb) local function ld() stt.Text="..." task.spawn(function() local ok,d=C.AdL() if not ok or not d then stt.Text="E:"..tostring(d) return end for _,c in ipairs(PA:GetChildren())do if c:IsA("Frame")and c~=tb then c:Destroy()end end stt.Text=string.format("%d plugins",d.count or 0) for i,p in ipairs(d.plugins or {})do local cd=I("Frame",{Size=UDim2.new(1,-8,0,90),BackgroundColor3=K.Cd,BorderSizePixel=0,LayoutOrder=i},PA) CR(cd,10) local sc=K.TxM if p.status=="approved"then sc=K.Gr elseif p.status=="rejected"then sc=K.Rd elseif p.status=="pending"then sc=K.Yl elseif p.status=="failed"then sc=K.Rd end I("UIStroke",{Thickness=1,Transparency=0.65,Color=sc,Parent=cd}) I("TextLabel",{Position=UDim2.new(0,14,0,10),Size=UDim2.new(1,-320,0,20),BackgroundTransparency=1,Font=Enum.Font.GothamBold,TextSize=13,Text=p.name or "?",TextColor3=K.Tx,TextXAlignment=Enum.TextXAlignment.Left},cd) I("TextLabel",{Position=UDim2.new(0,14,0,32),Size=UDim2.new(1,-320,0,14),BackgroundTransparency=1,Font=Enum.Font.Gotham,TextSize=10,Text="@"..tostring(p.author_name or "?").." • "..tostring(p.status):upper(),TextColor3=K.TxM,TextXAlignment=Enum.TextXAlignment.Left},cd) if p.status~="approved"then local ap=I("TextButton",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-14,0,10),Size=UDim2.new(0,90,0,28),BackgroundColor3=Color3.fromRGB(20,45,25),BorderSizePixel=0,Font=Enum.Font.GothamBold,TextSize=10,Text="APPR",TextColor3=K.Gr,AutoButtonColor=false},cd) CR(ap,6,1,0.4,K.Gr) ap.MouseButton1Click:Connect(function() ap.Text="..." task.spawn(function() C.AdA(p.id) ld()end)end)end if p.status~="rejected"and p.status~="approved"then local rj=I("TextButton",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-14,0,44),Size=UDim2.new(0,90,0,28),BackgroundColor3=Color3.fromRGB(45,20,20),BorderSizePixel=0,Font=Enum.Font.GothamBold,TextSize=10,Text="REJ",TextColor3=K.Rd,AutoButtonColor=false},cd) CR(rj,6,1,0.4,K.Rd) rj.MouseButton1Click:Connect(function() rj.Text="..." task.spawn(function() C.AdR(p.id) ld()end)end)end local dl=I("TextButton",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-110,0,10),Size=UDim2.new(0,90,0,28),BackgroundColor3=Color3.fromRGB(30,30,34),BorderSizePixel=0,Font=Enum.Font.GothamBold,TextSize=10,Text="DEL",TextColor3=K.Rd,AutoButtonColor=false},cd) CR(dl,6,1,0.5,K.BdS) dl.MouseButton1Click:Connect(function() dl.Text="..." task.spawn(function() C.AdD(p.id) ld()end)end)end end)end rl.MouseButton1Click:Connect(ld) ld() end RA() end

    local dg=false local ds=nil local sp=nil
    H.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dg=true ds=i.Position sp=M.Position i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then dg=false end end)end end)
    game:GetService("UserInputService").InputChanged:Connect(function(i) if not dg then return end if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then local dl=i.Position-ds M.Position=UDim2.new(sp.X.Scale,sp.X.Offset+dl.X,sp.Y.Scale,sp.Y.Offset+dl.Y)end end)

    C.UI=g return g
end

function C.Open() if not C.UI then local ok,d=C.AdL() C.Adm=ok and d~=nil Bld()end C.UI.Enabled=true end
function C.Close() if C.UI then C.UI.Enabled=false end end

if MainFrame then local cb=I("TextButton",{Name="CatalogBtn",Position=UDim2.new(0,16,1,-158),Size=UDim2.fromOffset(44,44),BackgroundColor3=Color3.fromRGB(20,20,20),BorderSizePixel=0,Text="🧩",TextSize=20,Font=Enum.Font.GothamBold,AutoButtonColor=false,ZIndex=10},MainFrame) CR(cb,8,1,0.65,Color3.fromRGB(55,55,55)) cb.MouseEnter:Connect(function() TW(cb,{BackgroundColor3=Color3.fromRGB(34,34,34)})end) cb.MouseLeave:Connect(function() TW(cb,{BackgroundColor3=Color3.fromRGB(20,20,20)})end) cb.MouseButton1Click:Connect(function() C.Open()end)end

_G.NEXUS_CATALOG=C

local OR={} for n,t in pairs(NEXUS_TOOLS)do OR[n]=t end
local PT={}
function C.RebuildTools()
    for n in pairs(PT)do if not OR[n]then NEXUS_TOOLS[n]=nil end PT[n]=nil end
    for tn,info in pairs(C.CT())do if not OR[tn]then local sp=info.spec local pn=info.plugin NEXUS_TOOLS[tn]={desc=sp.desc.." ("..pn..")",args=sp.args or {},fn=function(args) local stl=false for _,p in pairs(C.In)do if p.name==pn then stl=true break end end if not stl then return "[PLUGIN OFF] "..pn end if sp.code and sp.code~=""then local ok,r=SB.R(pn,sp.code,args) if ok then return tostring(r or "ok")else return "[BLOCKED] "..tostring(r)end elseif sp.composes and #sp.composes>0 then local _,r=C.ET(tn,NEXUS_TOOLS,args) return tostring(r)end return "[none]"end} PT[tn]=true end end
    local t=0 for _ in pairs(NEXUS_TOOLS)do t=t+1 end
    local o=0 for _ in pairs(OR)do o=o+1 end
    local p2=0 for _ in pairs(PT)do p2=p2+1 end
    print(string.format("[NEXUS] Tools: %d orig + %d plugin = %d",o,p2,t))
end
C.RebuildTools()

local _I=C.Ins
C.Ins=function(id) local ok,r=_I(id) if ok then task.spawn(function() task.wait(0.1) C.RebuildTools()end)end return ok,r end
local _U=C.Uns
C.Uns=function(id) local ok,r=_U(id) if ok then task.spawn(function() task.wait(0.1) C.RebuildTools()end)end return ok,r end

end)
