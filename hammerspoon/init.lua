-- ============================================================
-- HYPER key = ctrl + opt + cmd (ShiftIt互換)
-- ============================================================

local hyper = { 'ctrl', 'alt', 'cmd' }

-- ユーティリティ: 現在のフォーカスウィンドウを取得
local function win()
    return hs.window.focusedWindow()
end

-- ユーティリティ: ウィンドウをスクリーン内の割合で配置
-- x, y: 左上起点 (0.0〜1.0)
-- w, h: 幅・高さ (0.0〜1.0)
local function move(x, y, w, h)
    local window = win()
    if not window then return end
    window:moveToUnit(hs.geometry.rect(x, y, w, h))
end

-- 左右半分
-- ----------
hs.hotkey.bind(hyper, 'Left', function() move(0, 0, 0.5, 1) end)    -- 左半分
hs.hotkey.bind(hyper, 'Right', function() move(0.5, 0, 0.5, 1) end) -- 右半分

-- 上下半分
-- ----------
hs.hotkey.bind(hyper, 'Up', function() move(0, 0, 1, 0.5) end)     -- 上半分
hs.hotkey.bind(hyper, 'Down', function() move(0, 0.5, 1, 0.5) end) -- 下半分

-- 四隅 (1/4サイズ)
-- ----------
hs.hotkey.bind(hyper, 'U', function() move(0, 0, 0.5, 0.5) end)     -- 左上
hs.hotkey.bind(hyper, 'I', function() move(0.5, 0, 0.5, 0.5) end)   -- 右上
hs.hotkey.bind(hyper, 'J', function() move(0, 0.5, 0.5, 0.5) end)   -- 左下
hs.hotkey.bind(hyper, 'K', function() move(0.5, 0.5, 0.5, 0.5) end) -- 右下

-- 最大化 / 中央寄せ
-- ----------
hs.hotkey.bind(hyper, 'M', function() move(0, 0, 1, 1) end)         -- 最大化
hs.hotkey.bind(hyper, 'C', function() move(0.1, 0.1, 0.8, 0.8) end) -- 中央80%

-- ディスプレイ移動: cmd + opt + ctrl + N → 次のスクリーンへ
-- ----------
hs.hotkey.bind(hyper, 'N', function()
    local window = win()
    if not window then return end

    local currentScreen = window:screen()
    local nextScreen    = currentScreen:next() -- 循環して次のスクリーン

    -- サイズを保持したまま移動 (animate=false, retain=true)
    window:moveToScreen(nextScreen, false, true)
end)
