-- NEXUS PLUGIN CATALOG v2.1
task.spawn(function()
local URL="https://catalogplugins.nvlzskidd.workers.dev"
local PFile="nexus_installed_plugins.json"
local HS=game:GetService("HttpService")
local CG=game:GetService("CoreGui")
local TS=game:GetService("TweenService")
local PL=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local LP=PL.LocalPlayer
local UID=tostring(LP.UserId)

local function GetReq()
    if typeof(request)=="function" then return request end
    if typeof(http_request)=="function" then return http_request end
    if syn and typeof(syn.request)=="function" then return syn.request end
    if fluxus and typeof(fluxus.request)=="function" then return fluxus.request end
    if http and typeof(http.request)=="function" then return http.request end
end

local function HTTP(m,p,b)
    local r=GetReq(); if not r then return false,"no_http" end
    local hdr={["Content-Type"]="application/json",["X-Admin-Uid"]=UID}
    local o={Url=URL..p,url=URL..p,Method=m,method=m,Headers=hdr}
    if b then local e=HS:JSONEncode(b); o.Body=e; o.body=e end
    local ok,res=pcall(r,o)
    if not ok or not res then return false,"connection_failed" end
    local sc=tonumber(res.StatusCode or res.status_code or res.Status)
    local body=res.Body or res.body
    if not body then return false,"empty" end
    local okD,dec=pcall(HS.JSONDecode,HS,body)
    if not okD then return false,"bad_json" end
    if sc and sc>=400 then
        local why="HTTP "..sc
        if type(dec)=="table" then why=dec.reason or dec.error or why end
        return false,why,dec
    end
    return true,dec
end

local Cat={Remote={},Installed={},Loading=false,UI=nil,OnChange=nil,IsAdmin=false}

local function LoadInst()
    if not readfile then return end
    pcall(function()
        local c=readfile(PFile)
        if c and c~="" then
            local d=HS:JSONDecode(c)
            if type(d)=="table" then Cat.Installed=d end
        end
    end)
end
local function SaveInst()
    if not writefile then return end
    pcall(writefile,PFile,HS:JSONEncode(Cat.Installed))
    if Cat.OnChange then pcall(Cat.OnChange,Cat.Installed) end
end
LoadInst()

function Cat.IsInstalled(id) return Cat.Installed[id]~=nil end

function Cat.GetActivePromptExtensions()
    local out={}
    for _,p in pairs(Cat.Installed) do
        if p.prompt_extension and p.prompt_extension~="" then
            table.insert(out,"### PLUGIN: "..p.name.." ###\n"..p.prompt_extension)
        end
    end
    return table.concat(out,"\n\n")
end

function Cat.GetActiveCustomTools()
    local t={}
    for _,p in pairs(Cat.Installed) do
        if p.custom_tools then
            for _,ct in ipairs(p.custom_tools) do t[ct.name]={plugin=p.name,spec=ct} end
        end
    end
    return t
end

function Cat.GetActiveSuggestions()
    local out={}
    for _,p in pairs(Cat.Installed) do
        if p.suggestions then for _,s in ipairs(p.suggestions) do if #out<6 then table.insert(out,s) end end end
    end
    return out
end

function Cat.ExecuteCustomTool(name,core,args)
    local ct=Cat.GetActiveCustomTools()[name]
    if not ct then return false,"not_registered" end
    if not ct.spec.composes or #ct.spec.composes==0 then return false,"no_composes" end
    local res={}
    for _,step in ipairs(ct.spec.composes) do
        local fn=core[step.tool]
        if not fn then table.insert(res,"[SKIP] "..step.tool)
        else
            local sa={}
            for k,v in pairs(step.args or {}) do sa[k]=v end
            for k,v in pairs(args or {}) do sa[k]=v end
            local ok,r=pcall(fn,sa)
            table.insert(res,(ok and "[OK] " or "[ERR] ")..step.tool..": "..tostring(r))
        end
    end
    return true,table.concat(res,"\n")
end

function Cat.Install(id)
    local ok,d=HTTP("GET","/plugins/"..id)
    if not ok then return false,d end
    if not d.plugin then return false,"not_found" end
    Cat.Installed[id]=d.plugin
    SaveInst()
    return true,d.plugin
end
function Cat.Uninstall(id)
    if not Cat.Installed[id] then return false,"not_installed" end
    Cat.Installed[id]=nil
    SaveInst()
    return true
end
function Cat.Refresh()
    if Cat.Loading then return false,"loading" end
    Cat.Loading=true
    local ok,d=HTTP("GET","/plugins")
    Cat.Loading=false
    if not ok then return false,d end
    Cat.Remote=d.plugins or {}
    return true
end
function Cat.Publish(pd)
    local pl={}
    for k,v in pairs(pd) do pl[k]=v end
    pl.author_id=UID
    pl.author_name=LP.DisplayName or LP.Name
    local ok,d=HTTP("POST","/plugins",pl)
    if not ok then return false,d end
    return true,d
end
function Cat.MyPlugins()
    local ok,d=HTTP("GET","/my-plugins?user_id="..UID)
    if not ok then return false,d end
    return true,d.plugins or {}
end
function Cat.Rate(id,s) return HTTP("POST","/plugins/"..id.."/rate",{stars=s}) end
function Cat.GetAuthor(u) return HTTP("GET","/authors/"..u) end
function Cat.AdminList() return HTTP("GET","/admin/all-plugins") end
function Cat.AdminApprove(id) return HTTP("POST","/admin/approve/"..id,{reason:"approved by admin"}) end
function Cat.AdminReject(id,r) return HTTP("POST","/admin/reject/"..id,{reason=r or "rejected by admin"}) end
function Cat.AdminDelete(id) return HTTP("DELETE","/plugins/"..id) end

local SB={}
local SG={
    Vector3=Vector3,Vector2=Vector2,CFrame=CFrame,Color3=Color3,UDim=UDim,UDim2=UDim2,
    Enum=Enum,BrickColor=BrickColor,Ray=Ray,
    math=math,string=string,table=table,tonumber=tonumber,tostring=tostring,type=type,typeof=typeof,
    ipairs=ipairs,pairs=pairs,next=next,select=select,unpack=unpack or table.unpack,
    pcall=pcall,xpcall=xpcall,error=error,assert=assert,
    os={time=os.time,clock=os.clock,date=os.date},
    task={wait=task.wait,spawn=task.spawn,delay=task.delay,defer=task.defer},
    coroutine={create=coroutine.create,resume=coroutine.resume,status=coroutine.status,yield=coroutine.yield,wrap=coroutine.wrap,close=coroutine.close},
}
local BLK={"game","workspace","Workspace","_G","shared","_ENV","loadstring","load","require","getfenv","setfenv","debug","rawset","rawget","rawequal","rawlen","getreg","request","http_request","syn","fluxus","http","getrawmetatable","setreadonly","newcclosure","hookfunction","hookmetamethod","Instance","script","Player","Players","ReplicatedStorage","ServerScriptService","ServerStorage"}

local function BuildAPI(name)
    local function ch() return LP and LP.Character end
    local function hu() local c=ch(); return c and c:FindFirstChildOfClass("Humanoid") end
    local function hp() local c=ch(); return c and c:FindFirstChild("HumanoidRootPart") end
    local bg={say=0,tp=0}
    local a={}
    a.get_local_player=function() return {name=LP.Name,display=LP.DisplayName,id=LP.UserId} end
    a.get_character=ch
    a.get_humanoid=hu
    a.get_hrp=hp
    a.get_health=function() local h=hu(); return h and h.Health or 0 end
    a.get_position=function() local r=hp(); return r and r.Position or Vector3.new(0,0,0) end
    a.set_walkspeed=function(n) n=tonumber(n); if not n then return false end; n=math.clamp(n,0,500); local h=hu(); if h then h.WalkSpeed=n; return true end; return false end
    a.set_jumppower=function(n) n=tonumber(n); if not n then return false end; n=math.clamp(n,0,500); local h=hu(); if h then h.JumpPower=n; return true end; return false end
    a.set_gravity=function(n) n=tonumber(n); if not n then return false end; workspace.Gravity=math.clamp(n,0,500); return true end
    a.teleport_to=function(x,y,z) bg.tp=bg.tp+1; if bg.tp>20 then return false end; x,y,z=tonumber(x),tonumber(y),tonumber(z); if not(x and y and z) then return false end; local r=hp(); if r then r.CFrame=CFrame.new(x,y,z); return true end; return false end
    a.heal=function(n) n=tonumber(n) or 100; local h=hu(); if h then h.Health=math.min(h.MaxHealth,h.Health+n); return true end; return false end
    a.say=function(t)
        bg.say=bg.say+1; if bg.say>3 then return false end
        t=tostring(t or ""):sub(1,200)
        pcall(function()
            local lg=RS:FindFirstChild("DefaultChatSystemChatEvents")
            if lg and lg:FindFirstChild("SayMessageRequest") then lg.SayMessageRequest:FireServer(t,"All")
            else local tc=game:GetService("TextChatService"); if tc.ChatVersion==Enum.ChatVersion.TextChatService then local c=tc.TextChannels:FindFirstChild("RBXGeneral"); if c then c:SendAsync(t) end end end
        end)
        return true
    end
    a.get_players=function()
        local out={}
        for _,p in ipairs(PL:GetPlayers()) do
            local c=p.Character; local h=c and c:FindFirstChildOfClass("Humanoid"); local r=c and c:FindFirstChild("HumanoidRootPart")
            table.insert(out,{name=p.Name,display=p.DisplayName,health=h and h.Health or 0,max_health=h and h.MaxHealth or 0,position=r and r.Position or Vector3.new(0,0,0)})
        end
        return out
    end
    a.get_nearest_player=function()
        local me=hp(); if not me then return nil end
        local b,bd
        for _,p in ipairs(PL:GetPlayers()) do
            if p~=LP and p.Character then
                local r=p.Character:FindFirstChild("HumanoidRootPart")
                if r then local d=(r.Position-me.Position).Magnitude; if not bd or d<bd then b=p; bd=d end end
            end
        end
        if b then return {name=b.Name,display=b.DisplayName,distance=bd} end
    end
    a.log=function(m) print("[PLUGIN:"..tostring(name).."]",tostring(m)) end
    a.wait=function(s) task.wait(math.clamp(tonumber(s) or 0,0,5)) end
    return a
end

function SB.Run(name,code,args)
    if type(code)~="string" or code=="" then return false,"empty" end
    if #code>8000 then return false,"too_large" end
    for _,w in ipairs(BLK) do
        if code:find("%f[%a_]"..w:gsub("%%","%%%%").."%f[^%a_]") then return false,"blocked:"..w end
    end
    local env={}
    for k,v in pairs(SG) do env[k]=v end
    env.__args=args or {}
    env.api=BuildAPI(name)
    local ld=loadstring or load
    if not ld then return false,"no_loadstring" end
    local fn,ce=ld(code,"=plugin_"..tostring(name))
    if not fn then return false,"compile:"..tostring(ce) end
    local co=coroutine.create(function() return fn() end)
    local st=tick(); local done=false
    task.spawn(function() while not done and tick()-st<3 do task.wait(0.05) end; if not done then pcall(coroutine.close,co) end end)
    local ok,res=coroutine.resume(co)
    done=true
    if not ok then return false,"runtime:"..tostring(res) end
    if coroutine.status(co)~="dead" then return false,"timeout" end
    return true,res
end

local C={Bg=Color3.fromRGB(7,7,8),Sf=Color3.fromRGB(12,12,14),Cd=Color3.fromRGB(17,17,19),CdH=Color3.fromRGB(24,24,27),
Bd=Color3.fromRGB(48,48,52),BdS=Color3.fromRGB(31,31,35),Tx=Color3.fromRGB(255,255,255),Tx2=Color3.fromRGB(190,190,195),
TxM=Color3.fromRGB(110,110,116),Gr=Color3.fromRGB(46,204,113),Rd=Color3.fromRGB(231,76,60),Yl=Color3.fromRGB(241,196,15),Bl=Color3.fromRGB(88,165,255)}

local function crn(o,r) local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,r or 8); c.Parent=o; return c end
local function stk(o,t,tr,col) local s=Instance.new("UIStroke"); s.Thickness=t or 1; s.Transparency=tr or 0.6; s.Color=col or C.Bd; s.Parent=o; return s end
local function tw(o,d,p) TS:Create(o,TweenInfo.new(d or 0.15,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),p):Play() end

local function BuildUI()
    if Cat.UI then Cat.UI:Destroy() end
    local gui=Instance.new("ScreenGui")
    gui.Name="NEXUS_CATALOG"; gui.ResetOnSpawn=false; gui.IgnoreGuiInset=true
    gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
    gui.Parent=LP:FindFirstChild("PlayerGui") or CG
    local us=Instance.new("UIScale"); us.Parent=gui
    local function upd() local c=workspace.CurrentCamera; if not c then return end; local v=c.ViewportSize; us.Scale=math.clamp(math.min(v.X/900,v.Y/650),0.72,1.15) end
    upd()
    if workspace.CurrentCamera then workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(upd) end

    local M=Instance.new("Frame")
    M.Name="Main"; M.Size=UDim2.new(0,860,0,600); M.AnchorPoint=Vector2.new(0.5,0.5)
    M.Position=UDim2.fromScale(0.5,0.5); M.BackgroundColor3=C.Bg; M.BorderSizePixel=0; M.Parent=gui
    crn(M,14); stk(M,1,0.55,C.Bd)

    local H=Instance.new("Frame")
    H.Size=UDim2.new(1,0,0,62); H.BackgroundColor3=Color3.fromRGB(11,11,13); H.BorderSizePixel=0; H.Parent=M; crn(H,14)

    local t1=Instance.new("TextLabel"); t1.Position=UDim2.new(0,20,0,14); t1.Size=UDim2.new(0,400,0,24)
    t1.BackgroundTransparency=1; t1.Font=Enum.Font.GothamBold; t1.Text="NEXUS • PLUGIN CATALOG"
    t1.TextColor3=C.Tx; t1.TextSize=16; t1.TextXAlignment=Enum.TextXAlignment.Left; t1.Parent=H

    local t2=Instance.new("TextLabel"); t2.Position=UDim2.new(0,20,0,36); t2.Size=UDim2.new(0,500,0,16)
    t2.BackgroundTransparency=1; t2.Font=Enum.Font.Gotham; t2.Text="AI-verified global extensions"
    t2.TextColor3=C.TxM; t2.TextSize=10; t2.TextXAlignment=Enum.TextXAlignment.Left; t2.Parent=H

    local cl=Instance.new("TextButton"); cl.AnchorPoint=Vector2.new(1,0.5); cl.Position=UDim2.new(1,-14,0.5,0)
    cl.Size=UDim2.new(0,32,0,32); cl.BackgroundColor3=Color3.fromRGB(20,20,23); cl.BorderSizePixel=0
    cl.Text="×"; cl.Font=Enum.Font.GothamMedium; cl.TextSize=18; cl.TextColor3=C.TxM; cl.AutoButtonColor=false; cl.Parent=H
    crn(cl,8); stk(cl,1,0.65,C.BdS)
    cl.MouseEnter:Connect(function() tw(cl,0.15,{BackgroundColor3=Color3.fromRGB(48,48,52),TextColor3=C.Tx}) end)
    cl.MouseLeave:Connect(function() tw(cl,0.15,{BackgroundColor3=Color3.fromRGB(20,20,23),TextColor3=C.TxM}) end)
    cl.MouseButton1Click:Connect(function() gui.Enabled=false end)

    local T=Instance.new("Frame"); T.Position=UDim2.new(0,14,0,70); T.Size=UDim2.new(1,-28,0,34)
    T.BackgroundTransparency=1; T.Parent=M
    local TL=Instance.new("UIListLayout"); TL.FillDirection=Enum.FillDirection.Horizontal; TL.Padding=UDim.new(0,6); TL.Parent=T

    local P=Instance.new("Frame"); P.Position=UDim2.new(0,14,0,112); P.Size=UDim2.new(1,-28,1,-126)
    P.BackgroundTransparency=1; P.Parent=M

    local Pages={}; local Tabs={}; local Cur
    local function Sel(n)
        if Cur==n then return end
        Cur=n
        for k,p in pairs(Pages) do p.Visible=(k==n) end
        for k,b in pairs(Tabs) do
            local on=(k==n)
            tw(b,0.15,{BackgroundColor3=on and Color3.fromRGB(30,30,34) or Color3.fromRGB(15,15,18),TextColor3=on and C.Tx or C.TxM})
        end
    end
    local function MkTab(n,l)
        local b=Instance.new("TextButton")
        b.Size=UDim2.new(0,110,0,30); b.BackgroundColor3=Color3.fromRGB(15,15,18); b.BorderSizePixel=0
        b.Font=Enum.Font.GothamBold; b.TextSize=10; b.Text=l; b.TextColor3=C.TxM; b.AutoButtonColor=false; b.Parent=T
        crn(b,8); stk(b,1,0.7,C.BdS)
        b.MouseButton1Click:Connect(function() Sel(n) end)
        Tabs[n]=b
        local pg=Instance.new("ScrollingFrame"); pg.Size=UDim2.fromScale(1,1); pg.BackgroundTransparency=1
        pg.BorderSizePixel=0; pg.ScrollBarThickness=4; pg.ScrollBarImageColor3=C.Bd; pg.CanvasSize=UDim2.new(0,0,0,0)
        pg.AutomaticCanvasSize=Enum.AutomaticSize.Y; pg.Visible=false; pg.Parent=P
        local L=Instance.new("UIListLayout"); L.Padding=UDim.new(0,10); L.SortOrder=Enum.SortOrder.LayoutOrder; L.Parent=pg
        local pd=Instance.new("UIPadding"); pd.PaddingTop=UDim.new(0,6); pd.PaddingBottom=UDim.new(0,16)
        pd.PaddingLeft=UDim.new(0,4); pd.PaddingRight=UDim.new(0,4); pd.Parent=pg
        Pages[n]=pg; return pg
    end

    local PC=MkTab("catalog","CATALOG")
    local PI=MkTab("installed","INSTALLED")
    local PM=MkTab("mine","MY PLUGINS")
    local PP=MkTab("publish","PUBLISH")
    local PA=nil
    if Cat.IsAdmin then PA=MkTab("admin","ADMIN") end
    Sel("catalog")

    local function ShowAuthor(u,nm)
        local pop=Instance.new("Frame"); pop.Size=UDim2.new(0,320,0,220); pop.AnchorPoint=Vector2.new(0.5,0.5)
        pop.Position=UDim2.fromScale(0.5,0.5); pop.BackgroundColor3=C.Sf; pop.BorderSizePixel=0; pop.ZIndex=100; pop.Parent=gui
        crn(pop,12); stk(pop,1,0.4,C.Bd)
        local tt=Instance.new("TextLabel"); tt.Size=UDim2.new(1,-20,0,30); tt.Position=UDim2.new(0,14,0,14)
        tt.BackgroundTransparency=1; tt.Font=Enum.Font.GothamBold; tt.TextSize=15; tt.Text="@"..nm
        tt.TextColor3=C.Tx; tt.TextXAlignment=Enum.TextXAlignment.Left; tt.Parent=pop
        local inf=Instance.new("TextLabel"); inf.Size=UDim2.new(1,-20,0,120); inf.Position=UDim2.new(0,14,0,52)
        inf.BackgroundTransparency=1; inf.Font=Enum.Font.Gotham; inf.TextSize=12; inf.TextColor3=C.Tx2
        inf.TextWrapped=true; inf.TextXAlignment=Enum.TextXAlignment.Left; inf.TextYAlignment=Enum.TextYAlignment.Top
        inf.Text="Loading..."; inf.Parent=pop
        local cb=Instance.new("TextButton"); cb.Size=UDim2.new(1,-28,0,32); cb.Position=UDim2.new(0,14,1,-46)
        cb.BackgroundColor3=Color3.fromRGB(20,20,23); cb.BorderSizePixel=0; cb.Text="CLOSE"
        cb.Font=Enum.Font.GothamBold; cb.TextSize=11; cb.TextColor3=C.Tx2; cb.AutoButtonColor=false; cb.Parent=pop
        crn(cb,8); stk(cb,1,0.6,C.BdS); cb.MouseButton1Click:Connect(function() pop:Destroy() end)
        task.spawn(function()
            local ok,d=Cat.GetAuthor(u)
            if not ok or not d then inf.Text="Failed to load." return end
            inf.Text=string.format("Status: %s\nDownloads: %d\nPlugins: %d\nReason: %s",
                d.verified and "✓ VERIFIED" or "unverified",
                d.total_downloads or 0, d.plugin_count or 0, d.verified_reason or "n/a")
        end)
    end

    local function MkCard(pl,ord)
        local cd=Instance.new("Frame"); cd.Size=UDim2.new(1,-8,0,110); cd.BackgroundColor3=C.Cd
        cd.BorderSizePixel=0; cd.LayoutOrder=ord; cd.Parent=PC
        crn(cd,10); local cs=stk(cd,1,0.65,C.BdS)

        local nm=Instance.new("TextLabel"); nm.Position=UDim2.new(0,14,0,10); nm.Size=UDim2.new(1,-260,0,20)
        nm.BackgroundTransparency=1; nm.Font=Enum.Font.GothamBold; nm.TextSize=14
        nm.Text=pl.name or "Unknown"; nm.TextColor3=C.Tx; nm.TextXAlignment=Enum.TextXAlignment.Left
        nm.TextTruncate=Enum.TextTruncate.AtEnd; nm.Parent=cd

        if pl.author_verified then
            local ab=Instance.new("TextLabel"); ab.Position=UDim2.new(0,14,0,30); ab.Size=UDim2.new(0,90,0,16)
            ab.BackgroundColor3=Color3.fromRGB(15,32,55); ab.BorderSizePixel=0; ab.Font=Enum.Font.GothamBold
            ab.TextSize=9; ab.Text="✓ VERIFIED"; ab.TextColor3=C.Bl; ab.Parent=cd
            crn(ab,4); stk(ab,1,0.4,C.Bl)
        end

        local aY=pl.author_verified and 50 or 30
        local ab=Instance.new("TextButton"); ab.Position=UDim2.new(0,14,0,aY); ab.Size=UDim2.new(0,200,0,14)
        ab.BackgroundTransparency=1; ab.Font=Enum.Font.Gotham; ab.TextSize=10
        ab.Text="by @"..tostring(pl.author_name or "Unknown").."  •  v"..tostring(pl.version or "1.0.0")
        ab.TextColor3=C.TxM; ab.TextXAlignment=Enum.TextXAlignment.Left; ab.AutoButtonColor=false; ab.Parent=cd
        ab.MouseEnter:Connect(function() tw(ab,0.15,{TextColor3=C.Bl}) end)
        ab.MouseLeave:Connect(function() tw(ab,0.15,{TextColor3=C.TxM}) end)
        ab.MouseButton1Click:Connect(function() if pl.author_id then ShowAuthor(pl.author_id,pl.author_name or "Unknown") end end)

        local dsc=Instance.new("TextLabel"); dsc.Position=UDim2.new(0,14,0,aY+18); dsc.Size=UDim2.new(1,-280,0,40)
        dsc.BackgroundTransparency=1; dsc.Font=Enum.Font.Gotham; dsc.TextSize=11; dsc.TextWrapped=true
        dsc.Text=pl.description or ""; dsc.TextColor3=C.Tx2; dsc.TextXAlignment=Enum.TextXAlignment.Left
        dsc.TextYAlignment=Enum.TextYAlignment.Top; dsc.TextTruncate=Enum.TextTruncate.AtEnd; dsc.Parent=cd

        local isI=Cat.IsInstalled(pl.id)
        local bt=Instance.new("TextButton"); bt.AnchorPoint=Vector2.new(1,0); bt.Position=UDim2.new(1,-14,0,10)
        bt.Size=UDim2.new(0,140,0,32); bt.BorderSizePixel=0; bt.Font=Enum.Font.GothamBold; bt.TextSize=11
        bt.BackgroundColor3=isI and Color3.fromRGB(34,34,38) or Color3.fromRGB(242,242,242)
        bt.Text=isI and "REMOVE" or "INSTALL"; bt.TextColor3=isI and C.Tx2 or Color3.fromRGB(12,12,12)
        bt.AutoButtonColor=false; bt.Parent=cd; crn(bt,8); if isI then stk(bt,1,0.6,C.Bd) end
        bt.MouseEnter:Connect(function() tw(bt,0.15,{BackgroundColor3=isI and Color3.fromRGB(58,58,62) or Color3.fromRGB(255,255,255)}) end)
        bt.MouseLeave:Connect(function() tw(bt,0.15,{BackgroundColor3=isI and Color3.fromRGB(34,34,38) or Color3.fromRGB(242,242,242)}) end)
        bt.MouseButton1Click:Connect(function()
            if Cat.IsInstalled(pl.id) then
                Cat.Uninstall(pl.id); bt.Text="INSTALL"; bt.TextColor3=Color3.fromRGB(12,12,12); bt.BackgroundColor3=Color3.fromRGB(242,242,242); isI=false
            else
                bt.Text="INSTALLING..."
                task.spawn(function()
                    local ok=Cat.Install(pl.id)
                    if ok then bt.Text="REMOVE"; bt.TextColor3=C.Tx2; bt.BackgroundColor3=Color3.fromRGB(34,34,38); isI=true
                    else bt.Text="ERROR"; bt.BackgroundColor3=Color3.fromRGB(45,20,20); bt.TextColor3=C.Rd
                        task.wait(1.5); bt.Text="INSTALL"; bt.TextColor3=Color3.fromRGB(12,12,12); bt.BackgroundColor3=Color3.fromRGB(242,242,242)
                    end
                end)
            end
        end)

        if Cat.IsAdmin then
            local dl=Instance.new("TextButton"); dl.AnchorPoint=Vector2.new(1,0); dl.Position=UDim2.new(1,-14,0,48)
            dl.Size=UDim2.new(0,140,0,26); dl.BackgroundColor3=Color3.fromRGB(45,20,20); dl.BorderSizePixel=0
            dl.Font=Enum.Font.GothamBold; dl.TextSize=10; dl.Text="🗑 DELETE"; dl.TextColor3=C.Rd
            dl.AutoButtonColor=false; dl.Parent=cd; crn(dl,6); stk(dl,1,0.5,C.Rd)
            dl.MouseButton1Click:Connect(function()
                dl.Text="DELETING..."
                task.spawn(function()
                    local ok=Cat.AdminDelete(pl.id)
                    if ok then cd:Destroy() else dl.Text="ERROR"; task.wait(1.5); dl.Text="🗑 DELETE" end
                end)
            end)
        end

        local sf=Instance.new("Frame"); sf.AnchorPoint=Vector2.new(1,1); sf.Position=UDim2.new(1,-14,1,-8)
        sf.Size=UDim2.new(0,150,0,20); sf.BackgroundTransparency=1; sf.Parent=cd
        local sl=Instance.new("UIListLayout"); sl.FillDirection=Enum.FillDirection.Horizontal
        sl.HorizontalAlignment=Enum.HorizontalAlignment.Right; sl.VerticalAlignment=Enum.VerticalAlignment.Center
        sl.Padding=UDim.new(0,2); sl.Parent=sf
        local cs2=math.floor(pl.rating or 0)
        for i=1,5 do
            local s=Instance.new("TextButton"); s.Size=UDim2.new(0,22,0,20); s.BackgroundTransparency=1
            s.Text=i<=cs2 and "★" or "☆"; s.TextSize=16; s.Font=Enum.Font.GothamBold
            s.TextColor3=i<=cs2 and C.Yl or C.TxM; s.AutoButtonColor=false; s.Parent=sf
            s.MouseEnter:Connect(function() if i>cs2 then s.TextColor3=C.Yl end end)
            s.MouseLeave:Connect(function() if i>cs2 then s.TextColor3=C.TxM end end)
            s.MouseButton1Click:Connect(function()
                task.spawn(function()
                    local ok=Cat.Rate(pl.id,i)
                    if ok then
                        cs2=i
                        for j,b in ipairs(sf:GetChildren()) do
                            if b:IsA("TextButton") then b.Text=j<=i and "★" or "☆"; b.TextColor3=j<=i and C.Yl or C.TxM end
                        end
                    end
                end)
            end)
        end
        if (pl.ratings_count or 0)>0 then
            local rc=Instance.new("TextLabel"); rc.AnchorPoint=Vector2.new(1,1); rc.Position=UDim2.new(1,-170,1,-8)
            rc.Size=UDim2.new(0,80,0,16); rc.BackgroundTransparency=1; rc.Font=Enum.Font.Gotham; rc.TextSize=9
            rc.Text=string.format("%.1f (%d)",pl.rating or 0,pl.ratings_count or 0)
            rc.TextColor3=C.TxM; rc.TextXAlignment=Enum.TextXAlignment.Right; rc.Parent=cd
        end
        cd.MouseEnter:Connect(function() tw(cd,0.15,{BackgroundColor3=C.CdH}); tw(cs,0.15,{Transparency=0.4}) end)
        cd.MouseLeave:Connect(function() tw(cd,0.15,{BackgroundColor3=C.Cd}); tw(cs,0.15,{Transparency=0.65}) end)
    end

    local function RCat()
        for _,c in ipairs(PC:GetChildren()) do if c:IsA("Frame") or c:IsA("TextLabel") then c:Destroy() end end
        if #Cat.Remote==0 then
            local e=Instance.new("TextLabel"); e.Size=UDim2.new(1,0,0,60); e.BackgroundTransparency=1
            e.Font=Enum.Font.Gotham; e.TextSize=12
            e.Text=Cat.Loading and "Loading..." or "No plugins yet."
            e.TextColor3=C.TxM; e.Parent=PC; return
        end
        for i,p in ipairs(Cat.Remote) do MkCard(p,i) end
    end
    RCat()

    local rf=Instance.new("TextButton"); rf.AnchorPoint=Vector2.new(1,0); rf.Position=UDim2.new(1,-14,0,70)
    rf.Size=UDim2.new(0,90,0,28); rf.BackgroundColor3=Color3.fromRGB(20,20,24); rf.BorderSizePixel=0
    rf.Font=Enum.Font.GothamBold; rf.TextSize=10; rf.Text="↻ REFRESH"; rf.TextColor3=C.Tx2
    rf.AutoButtonColor=false; rf.Parent=M; crn(rf,6); stk(rf,1,0.65,C.BdS)
    rf.MouseButton1Click:Connect(function()
        rf.Text="LOADING..."
        task.spawn(function() Cat.Refresh(); RCat(); rf.Text="↻ REFRESH" end)
    end)
    task.spawn(function() Cat.Refresh(); RCat() end)

    local function RInst()
        for _,c in ipairs(PI:GetChildren()) do if c:IsA("Frame") or c:IsA("TextLabel") then c:Destroy() end end
        local any=false; local o=0
        for id,p in pairs(Cat.Installed) do
            any=true; o=o+1
            local cd=Instance.new("Frame"); cd.Size=UDim2.new(1,-8,0,80); cd.BackgroundColor3=C.Cd
            cd.BorderSizePixel=0; cd.LayoutOrder=o; cd.Parent=PI; crn(cd,10); stk(cd,1,0.65,C.BdS)
            local nm=Instance.new("TextLabel"); nm.Position=UDim2.new(0,14,0,12); nm.Size=UDim2.new(1,-160,0,20)
            nm.BackgroundTransparency=1; nm.Font=Enum.Font.GothamBold; nm.TextSize=14
            nm.Text=p.name or "Unknown"; nm.TextColor3=C.Tx; nm.TextXAlignment=Enum.TextXAlignment.Left; nm.Parent=cd
            local d=Instance.new("TextLabel"); d.Position=UDim2.new(0,14,0,36); d.Size=UDim2.new(1,-160,0,32)
            d.BackgroundTransparency=1; d.Font=Enum.Font.Gotham; d.TextSize=11; d.TextWrapped=true
            d.Text=p.description or ""; d.TextColor3=C.Tx2; d.TextXAlignment=Enum.TextXAlignment.Left
            d.TextYAlignment=Enum.TextYAlignment.Top; d.Parent=cd
            local rm=Instance.new("TextButton"); rm.AnchorPoint=Vector2.new(1,0.5); rm.Position=UDim2.new(1,-14,0.5,0)
            rm.Size=UDim2.new(0,120,0,32); rm.BackgroundColor3=Color3.fromRGB(45,20,20); rm.BorderSizePixel=0
            rm.Font=Enum.Font.GothamBold; rm.TextSize=11; rm.Text="UNINSTALL"; rm.TextColor3=C.Rd
            rm.AutoButtonColor=false; rm.Parent=cd; crn(rm,8); stk(rm,1,0.4,C.Rd)
            rm.MouseButton1Click:Connect(function() Cat.Uninstall(id); RInst() end)
        end
        if not any then
            local e=Instance.new("TextLabel"); e.Size=UDim2.new(1,0,0,60); e.BackgroundTransparency=1
            e.Font=Enum.Font.Gotham; e.TextSize=12; e.Text="No plugins installed."
            e.TextColor3=C.TxM; e.Parent=PI
        end
    end
    RInst()
    Cat.OnChange=function() RInst() end

    local function RMine()
        for _,c in ipairs(PM:GetChildren()) do if c:IsA("Frame") or c:IsA("TextLabel") then c:Destroy() end end
        task.spawn(function()
            local ok,lst=Cat.MyPlugins()
            if not ok then
                local e=Instance.new("TextLabel"); e.Size=UDim2.new(1,0,0,40); e.BackgroundTransparency=1
                e.Font=Enum.Font.Gotham; e.TextSize=11; e.Text="Error: "..tostring(lst); e.TextColor3=C.Rd; e.Parent=PM; return
            end
            if #lst==0 then
                local e=Instance.new("TextLabel"); e.Size=UDim2.new(1,0,0,60); e.BackgroundTransparency=1
                e.Font=Enum.Font.Gotham; e.TextSize=12; e.Text="You have not published any plugins yet."
                e.TextColor3=C.TxM; e.Parent=PM; return
            end
            for i,p in ipairs(lst) do
                local cd=Instance.new("Frame"); cd.Size=UDim2.new(1,-8,0,70); cd.BackgroundColor3=C.Cd
                cd.BorderSizePixel=0; cd.LayoutOrder=i; cd.Parent=PM; crn(cd,10); stk(cd,1,0.65,C.BdS)
                local nm=Instance.new("TextLabel"); nm.Position=UDim2.new(0,14,0,10); nm.Size=UDim2.new(1,-160,0,20)
                nm.BackgroundTransparency=1; nm.Font=Enum.Font.GothamBold; nm.TextSize=14
                nm.Text=p.name or "Unknown"; nm.TextColor3=C.Tx; nm.TextXAlignment=Enum.TextXAlignment.Left; nm.Parent=cd
                local sc=C.TxM; local st=tostring(p.status or "unknown"):upper()
                if p.status=="approved" then sc=C.Gr
                elseif p.status=="rejected" then sc=C.Rd
                elseif p.status=="pending" then sc=C.Yl
                elseif p.status=="failed" then sc=C.Rd end
                local inf=Instance.new("TextLabel"); inf.Position=UDim2.new(0,14,0,34); inf.Size=UDim2.new(1,-160,0,14)
                inf.BackgroundTransparency=1; inf.Font=Enum.Font.Gotham; inf.TextSize=10
                inf.Text="Attempts: "..tostring(p.verify_attempts or 0)
                    ..(p.pending_reason and ("  •  "..p.pending_reason) or "")
                    ..(p.rejection_reason and ("  •  "..p.rejection_reason) or "")
                inf.TextColor3=C.TxM; inf.TextXAlignment=Enum.TextXAlignment.Left
                inf.TextTruncate=Enum.TextTruncate.AtEnd; inf.Parent=cd
                local stl=Instance.new("TextLabel"); stl.AnchorPoint=Vector2.new(1,0); stl.Position=UDim2.new(1,-14,0,10)
                stl.Size=UDim2.new(0,120,0,22); stl.BackgroundColor3=Color3.fromRGB(20,20,24); stl.BorderSizePixel=0
                stl.Font=Enum.Font.GothamBold; stl.TextSize=10; stl.Text=st; stl.TextColor3=sc; stl.Parent=cd
                crn(stl,6); stk(stl,1,0.5,sc)
            end
        end)
    end
    RMine()

    local function MInp(y,l,ph,h)
        local lbl=Instance.new("TextLabel"); lbl.Position=UDim2.new(0,6,0,y); lbl.Size=UDim2.new(1,-12,0,16)
        lbl.BackgroundTransparency=1; lbl.Font=Enum.Font.GothamBold; lbl.TextSize=10; lbl.Text=l
        lbl.TextColor3=C.TxM; lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.Parent=PP
        local bx=Instance.new("TextBox"); bx.Position=UDim2.new(0,6,0,y+20); bx.Size=UDim2.new(1,-12,0,h or 36)
        bx.BackgroundColor3=Color3.fromRGB(17,17,20); bx.BorderSizePixel=0; bx.Font=Enum.Font.Gotham
        bx.TextSize=12; bx.Text=""; bx.PlaceholderText=ph; bx.PlaceholderColor3=Color3.fromRGB(78,78,84)
        bx.TextColor3=C.Tx; bx.TextXAlignment=Enum.TextXAlignment.Left
        bx.TextYAlignment=(h and h>40) and Enum.TextYAlignment.Top or Enum.TextYAlignment.Center
        bx.ClearTextOnFocus=false; bx.MultiLine=(h or 0)>40; bx.TextWrapped=(h or 0)>40; bx.Parent=PP
        crn(bx,8); stk(bx,1,0.65,C.BdS)
        local pd=Instance.new("UIPadding"); pd.PaddingLeft=UDim.new(0,10); pd.PaddingRight=UDim.new(0,10)
        pd.PaddingTop=UDim.new(0,8); pd.PaddingBottom=UDim.new(0,8); pd.Parent=bx
        return bx
    end

    local iN=MInp(0,"PLUGIN NAME","Example: Coin Farm Pro")
    local iD=MInp(64,"DESCRIPTION","Describe your plugin",60)
    local iP=MInp(148,"BEHAVIOR INSTRUCTION (OPTIONAL)","Optional prompt tweak",100)
    local iT=MInp(272,"CORE TOOLS (COMMA SEPARATED)","Optional: scan_interactables, list_players",40)
    local iC=MInp(336,"LUAU CODE (OPTIONAL — RUNS IN SANDBOX)","Optional: api.set_walkspeed(32)",140)

    local sl=Instance.new("TextLabel"); sl.Position=UDim2.new(0,6,0,500); sl.Size=UDim2.new(1,-12,0,60)
    sl.BackgroundTransparency=1; sl.Font=Enum.Font.Gotham; sl.TextSize=11; sl.TextWrapped=true
    sl.Text=""; sl.TextColor3=C.TxM; sl.TextXAlignment=Enum.TextXAlignment.Left
    sl.TextYAlignment=Enum.TextYAlignment.Top; sl.Parent=PP

    local pb=Instance.new("TextButton"); pb.Position=UDim2.new(0,6,0,570); pb.Size=UDim2.new(0,180,0,42)
    pb.BackgroundColor3=Color3.fromRGB(242,242,242); pb.BorderSizePixel=0; pb.Font=Enum.Font.GothamBold
    pb.TextSize=12; pb.Text="PUBLISH PLUGIN"; pb.TextColor3=Color3.fromRGB(12,12,12)
    pb.AutoButtonColor=false; pb.Parent=PP; crn(pb,8)

    local pubing=false
    pb.MouseButton1Click:Connect(function()
        if pubing then return end
        local nm=iN.Text:gsub("^%s+",""):gsub("%s+$","")
        local ds=iD.Text:gsub("^%s+",""):gsub("%s+$","")
        local pr=iP.Text:gsub("^%s+",""):gsub("%s+$","")
        local tS=iT.Text; local cS=iC.Text:gsub("^%s+",""):gsub("%s+$","")
        if #nm<3 then sl.TextColor3=C.Rd; sl.Text="Name too short."; return end
        if #ds<10 then sl.TextColor3=C.Rd; sl.Text="Description too short."; return end
        local tls={}
        for t in tS:gmatch("[^,]+") do local c=t:gsub("%s",""); if c~="" then table.insert(tls,c) end end
        local cts={}
        if cS~="" then
            local tn=nm:lower():gsub("%s+","_"):gsub("[^%w_]",""):sub(1,40)
            table.insert(cts,{name=tn,desc=ds:sub(1,200),args={},code=cS})
        end
        pubing=true; pb.Text="ANALYZING..."; pb.BackgroundColor3=Color3.fromRGB(200,200,200)
        sl.TextColor3=C.TxM; sl.Text="AI reviewing..."
        task.spawn(function()
            local pl={name=nm,description=ds,prompt_extension=pr,uses_tools=tls,custom_tools=cts,suggestions={},version="1.0.0"}
            local ok,d=Cat.Publish(pl)
            pubing=false
            local function rst() task.wait(3.5); pb.Text="PUBLISH PLUGIN"; pb.BackgroundColor3=Color3.fromRGB(242,242,242); pb.TextColor3=Color3.fromRGB(12,12,12) end
            local function clr() iN.Text=""; iD.Text=""; iP.Text=""; iT.Text=""; iC.Text="" end
            if ok and d and d.status=="approved" then
                pb.Text="PUBLISHED ✓"; pb.BackgroundColor3=Color3.fromRGB(50,175,95); pb.TextColor3=C.Tx
                sl.TextColor3=C.Gr; sl.Text="Approved! ID: "..tostring(d.id or "?"):sub(1,8).."..."
                clr(); task.spawn(function() Cat.Refresh(); RCat(); RMine() end); rst()
            elseif ok and d and d.status=="pending" then
                pb.Text="QUEUED"; pb.BackgroundColor3=Color3.fromRGB(200,160,45); pb.TextColor3=Color3.fromRGB(12,12,12)
                sl.TextColor3=C.Yl; sl.Text="Queued. ID: "..tostring(d.id or "?"):sub(1,8).."..."
                clr(); task.spawn(function() RMine() end); rst()
            else
                pb.Text="REJECTED ✗"; pb.BackgroundColor3=Color3.fromRGB(180,55,55); pb.TextColor3=C.Tx
                sl.TextColor3=C.Rd; sl.Text="Rejected: "..tostring(d)
                rst()
            end
        end)
    end)

    if Cat.IsAdmin and PA then
        local function RAdm()
            for _,c in ipairs(PA:GetChildren()) do
                if c:IsA("Frame") or c:IsA("TextLabel") or c:IsA("TextButton") then c:Destroy() end
            end
            local tb=Instance.new("Frame"); tb.Size=UDim2.new(1,-8,0,34); tb.BackgroundColor3=Color3.fromRGB(15,15,18)
            tb.BorderSizePixel=0; tb.LayoutOrder=0; tb.Parent=PA; crn(tb,8)
            local rl=Instance.new("TextButton"); rl.Size=UDim2.new(0,120,0,26); rl.Position=UDim2.new(0,4,0.5,-13)
            rl.BackgroundColor3=Color3.fromRGB(30,30,34); rl.BorderSizePixel=0; rl.Font=Enum.Font.GothamBold
            rl.TextSize=10; rl.Text="↻ RELOAD"; rl.TextColor3=C.Tx2; rl.AutoButtonColor=false; rl.Parent=tb
            crn(rl,6); stk(rl,1,0.6,C.BdS)
            local stt=Instance.new("TextLabel"); stt.Position=UDim2.new(0,140,0,0); stt.Size=UDim2.new(1,-150,1,0)
            stt.BackgroundTransparency=1; stt.Font=Enum.Font.Gotham; stt.TextSize=10; stt.TextColor3=C.TxM
            stt.TextXAlignment=Enum.TextXAlignment.Left; stt.Text="Loading..."; stt.Parent=tb
            local function ld()
                stt.Text="Loading..."
                task.spawn(function()
                    local ok,d=Cat.AdminList()
                    if not ok or not d then stt.Text="Error: "..tostring(d) return end
                    for _,c in ipairs(PA:GetChildren()) do if c:IsA("Frame") and c~=tb then c:Destroy() end end
                    stt.Text=string.format("%d plugins",d.count or 0)
                    for i,p in ipairs(d.plugins or {}) do
                        local cd=Instance.new("Frame"); cd.Size=UDim2.new(1,-8,0,90); cd.BackgroundColor3=C.Cd
                        cd.BorderSizePixel=0; cd.LayoutOrder=i; cd.Parent=PA; crn(cd,10)
                        local sc=C.TxM
                        if p.status=="approved" then sc=C.Gr
                        elseif p.status=="rejected" then sc=C.Rd
                        elseif p.status=="pending" then sc=C.Yl
                        elseif p.status=="failed" then sc=C.Rd end
                        stk(cd,1,0.65,sc)
                        local nm=Instance.new("TextLabel"); nm.Position=UDim2.new(0,14,0,10); nm.Size=UDim2.new(1,-320,0,20)
                        nm.BackgroundTransparency=1; nm.Font=Enum.Font.GothamBold; nm.TextSize=13
                        nm.Text=p.name or "?"; nm.TextColor3=C.Tx; nm.TextXAlignment=Enum.TextXAlignment.Left; nm.Parent=cd
                        local inf=Instance.new("TextLabel"); inf.Position=UDim2.new(0,14,0,32); inf.Size=UDim2.new(1,-320,0,14)
                        inf.BackgroundTransparency=1; inf.Font=Enum.Font.Gotham; inf.TextSize=10
                        inf.Text="@"..tostring(p.author_name or "?").."  •  "..tostring(p.status):upper().."  •  "..tostring(p.downloads or 0).." dl"
                        inf.TextColor3=C.TxM; inf.TextXAlignment=Enum.TextXAlignment.Left; inf.Parent=cd
                        local rs=Instance.new("TextLabel"); rs.Position=UDim2.new(0,14,0,50); rs.Size=UDim2.new(1,-320,0,32)
                        rs.BackgroundTransparency=1; rs.Font=Enum.Font.Gotham; rs.TextSize=10
                        rs.Text=p.rejection_reason or p.pending_reason or ""; rs.TextColor3=C.Tx2; rs.TextWrapped=true
                        rs.TextXAlignment=Enum.TextXAlignment.Left; rs.TextYAlignment=Enum.TextYAlignment.Top; rs.Parent=cd
                        if p.status~="approved" then
                            local ap=Instance.new("TextButton"); ap.AnchorPoint=Vector2.new(1,0); ap.Position=UDim2.new(1,-14,0,10)
                            ap.Size=UDim2.new(0,90,0,28); ap.BackgroundColor3=Color3.fromRGB(20,45,25); ap.BorderSizePixel=0
                            ap.Font=Enum.Font.GothamBold; ap.TextSize=10; ap.Text="✓ APPROVE"; ap.TextColor3=C.Gr
                            ap.AutoButtonColor=false; ap.Parent=cd; crn(ap,6); stk(ap,1,0.4,C.Gr)
                            ap.MouseButton1Click:Connect(function()
                                ap.Text="..."
                                task.spawn(function()
                                    local ok2=Cat.AdminApprove(p.id)
                                    if ok2 then ld() else ap.Text="ERROR"; task.wait(1.5); ap.Text="✓ APPROVE" end
                                end)
                            end)
                        end
                        if p.status~="rejected" and p.status~="approved" then
                            local rj=Instance.new("TextButton"); rj.AnchorPoint=Vector2.new(1,0); rj.Position=UDim2.new(1,-14,0,44)
                            rj.Size=UDim2.new(0,90,0,28); rj.BackgroundColor3=Color3.fromRGB(45,20,20); rj.BorderSizePixel=0
                            rj.Font=Enum.Font.GothamBold; rj.TextSize=10; rj.Text="✗ REJECT"; rj.TextColor3=C.Rd
                            rj.AutoButtonColor=false; rj.Parent=cd; crn(rj,6); stk(rj,1,0.4,C.Rd)
                            rj.MouseButton1Click:Connect(function()
                                rj.Text="..."
                                task.spawn(function()
                                    local ok2=Cat.AdminReject(p.id)
                                    if ok2 then ld() else rj.Text="ERROR"; task.wait(1.5); rj.Text="✗ REJECT" end
                                end)
                            end)
                        end
                        local dl=Instance.new("TextButton"); dl.AnchorPoint=Vector2.new(1,0); dl.Position=UDim2.new(1,-110,0,10)
                        dl.Size=UDim2.new(0,90,0,28); dl.BackgroundColor3=Color3.fromRGB(30,30,34); dl.BorderSizePixel=0
                        dl.Font=Enum.Font.GothamBold; dl.TextSize=10; dl.Text="🗑 DELETE"; dl.TextColor3=C.Rd
                        dl.AutoButtonColor=false; dl.Parent=cd; crn(dl,6); stk(dl,1,0.5,C.BdS)
                        dl.MouseButton1Click:Connect(function()
                            dl.Text="..."
                            task.spawn(function()
                                local ok2=Cat.AdminDelete(p.id)
                                if ok2 then ld() else dl.Text="ERROR"; task.wait(1.5); dl.Text="🗑 DELETE" end
                            end)
                        end)
                    end
                end)
            end
            rl.MouseButton1Click:Connect(ld)
            ld()
        end
        RAdm()
    end

    local dg=false; local ds=nil; local sp=nil
    H.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            dg=true; ds=i.Position; sp=M.Position
            i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then dg=false end end)
        end
    end)
    game:GetService("UserInputService").InputChanged:Connect(function(i)
        if not dg then return end
        if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then
            local dl=i.Position-ds
            M.Position=UDim2.new(sp.X.Scale,sp.X.Offset+dl.X,sp.Y.Scale,sp.Y.Offset+dl.Y)
        end
    end)

    Cat.UI=gui
    return gui
end

function Cat.Open()
    if not Cat.UI then
        local ok,d=HTTP("GET","/admin/all-plugins")
        Cat.IsAdmin=ok and d~=nil
        BuildUI()
    end
    Cat.UI.Enabled=true
end
function Cat.Close()
    if Cat.UI then Cat.UI.Enabled=false end
end

-- Botão 🧩 no painel
if MainFrame then
    local cb=Instance.new("TextButton"); cb.Name="CatalogBtn"
    cb.Position=UDim2.new(0,16,1,-158); cb.Size=UDim2.fromOffset(44,44)
    cb.BackgroundColor3=Color3.fromRGB(20,20,20); cb.BorderSizePixel=0
    cb.Text="🧩"; cb.TextSize=20; cb.Font=Enum.Font.GothamBold
    cb.AutoButtonColor=false; cb.ZIndex=10; cb.Parent=MainFrame
    crn(cb,8)
    local s1=Instance.new("UIStroke"); s1.Thickness=1; s1.Transparency=0.65; s1.Color=Color3.fromRGB(55,55,55); s1.Parent=cb
    cb.MouseEnter:Connect(function() TS:Create(cb,TweenInfo.new(0.15,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{BackgroundColor3=Color3.fromRGB(34,34,34)}):Play() end)
    cb.MouseLeave:Connect(function() TS:Create(cb,TweenInfo.new(0.15,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{BackgroundColor3=Color3.fromRGB(20,20,20)}):Play() end)
    cb.MouseButton1Click:Connect(function() Cat.Open() end)
end

_G.NEXUS_CATALOG=Cat

-- ====================================================
-- HÍBRIDO: preserva tools originais + adiciona/remove de plugins
-- ====================================================
local ORIG={}
for n,t in pairs(NEXUS_TOOLS) do ORIG[n]=t end
local PT={}

function Cat.RebuildTools()
    for n in pairs(PT) do
        if not ORIG[n] then NEXUS_TOOLS[n]=nil end
        PT[n]=nil
    end
    for tn,info in pairs(Cat.GetActiveCustomTools()) do
        if not ORIG[tn] then
            local sp2=info.spec; local pn=info.plugin
            NEXUS_TOOLS[tn]={
                desc=sp2.desc.." (plugin: "..pn..")",
                args=sp2.args or {},
                fn=function(args)
                    local still=false
                    for _,p in pairs(Cat.Installed) do if p.name==pn then still=true break end end
                    if not still then return "[PLUGIN REMOVED] "..pn end
                    if sp2.code and sp2.code~="" then
                        local ok,r=SB.Run(pn,sp2.code,args)
                        if ok then return tostring(r or "ok") else return "[SANDBOX BLOCKED] "..tostring(r) end
                    elseif sp2.composes and #sp2.composes>0 then
                        local _,r=Cat.ExecuteCustomTool(tn,NEXUS_TOOLS,args)
                        return tostring(r)
                    end
                    return "[No impl]"
                end,
            }
            PT[tn]=true
        end
    end
    local total=0
    for _ in pairs(NEXUS_TOOLS) do total=total+1 end
    local origN=0
    for _ in pairs(ORIG) do origN=origN+1 end
    local plN=0
    for _ in pairs(PT) do plN=plN+1 end
    print(string.format("[NEXUS] Tools: %d original + %d plugin = %d total",origN,plN,total))
end

Cat.RebuildTools()

local _origI=Cat.Install
Cat.Install=function(id)
    local ok,r=_origI(id)
    if ok then task.spawn(function() task.wait(0.1); Cat.RebuildTools() end) end
    return ok,r
end
local _origU=Cat.Uninstall
Cat.Uninstall=function(id)
    local ok,r=_origU(id)
    if ok then task.spawn(function() task.wait(0.1); Cat.RebuildTools() end) end
    return ok,r
end

end)
