-----------------------------------------------------------------------------
--脚本文件：tiled_intersect.lua
--功能设计：
--功能开发：page(pk)
--开发时间：2020/10/15 00:15:41
--脚本功能：求格子占用相关的算法
--修改记录：
-----------------------------------------------------------------------------

local TILE_OUT_DIR_TYPE = {
    NONE        = 0,
    LEFT        = 1,
    TOP         = 2,
    RIGHT       = 3,
    BOTTOM      = 4
}

local TILE_STATE_TYPE = {
    ODD     = false,
    EVEN    = true
}

---@class LTileIntersect
LTileIntersect = LTileIntersect or class("LTileIntersect");

function LTileIntersect:ctor()
    
end

function LTileIntersect:dtor()
    --
end

--@function update one tile{x, y, state} state
--@param table tile set which with state
--@param table a tile {x, y, t}
--@param number directon out of a tile
function LTileIntersect:_UpdateTileState(tbTilesSet, tbTile, nDir)
    if type(tbTilesSet) ~= "table" then
        return false;
    end

    if type(tbTile) ~= "table" then
        return false;
    end

    local nPos = 0;
    -- find first
    for k, v in ipairs(tbTilesSet or {}) do
        if v.x == tbTile.x and v.y == tbTile.y then
            nPos = k;
            break;
        end
    end

    -- print("LTileIntersect:_UpdateTileState-", #tbTilesSet, tbTile.x, tbTile.y, nPos)
    if 0 < nPos and nPos <= #tbTilesSet then    -- exist
        local t = tbTilesSet[nPos];
        if nDir == TILE_OUT_DIR_TYPE.LEFT then
            t.state = not t.state;
        end
        if nDir == TILE_OUT_DIR_TYPE.RIGHT then
        end
    else                                        -- not exist
        if nDir == TILE_OUT_DIR_TYPE.LEFT then
            tbTile.state = TILE_STATE_TYPE.ODD;
        else
            tbTile.state = TILE_STATE_TYPE.EVEN;
        end
        -- lua里面用的是table的索引，否则外面改变了数据，比如x,y的增加，都会改到这个里面
        local tbNewTile = {x = tbTile.x, y = tbTile.y, state = tbTile.state};
        table.insert(tbTilesSet, tbNewTile);
    end
end


--@function check which side of tile segment intersect with
--@param table a Segment with two vertices{{x, y}, {x, y}}
--@param table one tile with four vertices {{x, y}, {x, y}, {x, y}, {x, y}}
--@param number adjacent tiles have one common side, only test one time when not a new segment
--@return 0-none, 1-left;2-top;4-right;8-bottom
function LTileIntersect:TestSegmentIntersectTile(tbSegment, tbRectTile, nExceptDir, bNewSegment)
    local bNewSegment = bNewSegment or false;
    local nTileVertices = #(tbRectTile or {});
    if nTileVertices ~= 4 or #(tbSegment or {}) ~= 2 then
        return 0;
    end

    local nStart = 1;
    local nEnd = nTileVertices;
    if nExceptDir > 0 then
        -- 从上一次检测到的边开始，否则和tile顶点相交的线段判断会进入死循环。
        nStart = (nExceptDir % nTileVertices) + 1;
        if not bNewSegment then
            nEnd = nStart + nTileVertices - 1;
        else
            nEnd = nStart + nTileVertices;
        end
    end

    -- print("LTileIntersect:TestSegmentIntersectTile-", nStart, nEnd, nExceptDir);
    for i = nStart, nEnd do
        local nTile = (i - 1) % nTileVertices + 1;
        local tbVertStart = tbRectTile[nTile];
        local nEndIndex = 1;
        if nTile + 1 <= nTileVertices then
            nEndIndex = nTile + 1;
        end
        local tbVertEnd = tbRectTile[nEndIndex];
        local a0 = KVec2:new_local(tbSegment[1].x, tbSegment[1].y);
        local a1 = KVec2:new_local(tbSegment[2].x, tbSegment[2].y);
        local b0 = KVec2:new_local(tbVertStart.x, tbVertStart.y);
        local b1 = KVec2:new_local(tbVertEnd.x, tbVertEnd.y);
        if TestSegmentIntersect(a0, a1, b0, b1) then
            return nTile;
        end
    end
end

--@function find polygon border occupy tiles
--@param tbPolygonVertices, a table of all vertices of the polygon
--@return a table of all tiles in the polygon border, or nil if some data error
function LTileIntersect:FindPolygonBorderTiles(tbPolygonVertices, nStep)
    local STEP = nStep or 32.0;
    local tbOutTiles = {};
    local tbPolygonVertices = tbPolygonVertices or {};
    local nVertices = #tbPolygonVertices;
    if nVertices < 1 then
        return nil;
    end

    -- print("LTileIntersect:FindPolygonBorderTiles---", #tbPolygonVertices, STEP)
    local nExceptDir = 0;
    for i = 1, nVertices do
        local tbVertStart = tbPolygonVertices[i];
        local tbVertEnd = tbPolygonVertices[1];
        if i + 1 <= nVertices then
            tbVertEnd = tbPolygonVertices[i+1];
        end
        local tbSegment = {tbVertStart, tbVertEnd};
        local nStartTileX = math.floor(tbVertStart.x / STEP);
        local nStartTileY = math.floor(tbVertStart.y / STEP);

        -- 改成r和c会不会好理解点？
        local tc = {
            x = nStartTileX,
            y = nStartTileY
        };
        local te = {
            x = math.floor(tbVertEnd.x / STEP),
            y = math.floor(tbVertEnd.y / STEP)
        };
        -- print(111, tc.x, tc.y, te.x, te.y)
        -- tc != te
        while not (tc.x == te.x and tc.y == te.y) do
            ------------------------------------------------------------------------------------------------------
            -- imgui coordinate
            -- 0-------> x
            -- |
            -- |
            -- y
            ------------------------------------------------------------------------------------------------------
            -- construct one tile useing four vertices
            local tbLeftBottom = {
                x = tc.x * STEP,
                y = (tc.y + 1) * STEP
            }
            local tbLeftTop = {
                x = tc.x * STEP,
                y = tc.y  * STEP
            }
            local tbRightTop = {
                x = (tc.x + 1) * STEP,
                y = tc.y * STEP
            }
            local tbRightBottom = {
                x = (tc.x + 1) * STEP,
                y = (tc.y + 1) * STEP
            }
            local tbOneTile = {tbLeftBottom, tbLeftTop, tbRightTop, tbRightBottom};
            local bNewSegment = (nStartTileX == tc.x and nStartTileY == tc.y);
            local nDir = self:TestSegmentIntersectTile(tbSegment, tbOneTile, nExceptDir, bNewSegment);
            -- print("222", tc.x, tc.y, nDir, nExceptDir)
            if nDir > 0 then
                self:_UpdateTileState(tbOutTiles, tc, nDir);
                
                -- check next tile
                if nDir == 1 then           -- left
                    tc.x = tc.x - 1;
                    nExceptDir = 3;
                elseif nDir == 2 then       -- top
                    tc.y = tc.y - 1;
                    nExceptDir = 4;
                elseif nDir == 3 then       -- right
                    tc.x = tc.x + 1;
                    nExceptDir = 1;
                elseif nDir == 4 then       -- bottom
                    tc.y = tc.y + 1;
                    nExceptDir = 2;
                end
                self:_UpdateTileState(tbOutTiles, tc, nExceptDir);
            else 
                break;
            end
        end
    end

    -- print("#tbOutTiles = ", #tbOutTiles)
    return tbOutTiles;
end

--@function merge one out ring and some inner ring border tiles state
function LTileIntersect:MergeTiles( tbAllRingBorderTiles)
    local tbOutTiles = {};
    local tbExist = {};
    if #tbAllRingBorderTiles <= 0 then
        return nil;
    end

    local tbOutRing = tbAllRingBorderTiles[1] or {};
    for i = 1, #tbOutRing do
        local nKey = (65536 * tbOutRing[i].x) + tbOutRing[i].y;
        tbExist[nKey] = i;
    end
    
    -- inner ring 
    for i = 2, #tbAllRingBorderTiles do
        local tbInnerRing = tbAllRingBorderTiles[i] or {};
        for j = 1, #tbInnerRing do
            local nKey = (65536 * tbInnerRing[j].x) + tbInnerRing[j].y;
            if tbExist[tbExist[nKey]] then
                local tbFind = tbInnerRing[tbExist[nKey]];
                tbFind.state = not (tbFind.state ^ tbInnerRing[j].state);
            else
                table.insert(tbOutRing, tbInnerRing[j]);
            end
        end
    end

    return tbOutRing;
end

function LTileIntersect:MakeCellRanges(tbPolygonBorderTiles)
    local tbOutPolygonAllTiles = {};
    local tbPolygonBorderTiles = tbPolygonBorderTiles or {};
    local tbPolygonRange = {
        -- {start tile{x, y}, end tile{x, y}}
    };

    table.sort(tbPolygonBorderTiles, function(a, b)
        if a.x ~= b.x then
            return a.x < b.x;
        end

        if a.y ~= b.y then
            return a.y < b.y;
        end

        return false;
    end)
    -- print("LTileIntersect:MakeCellRanges--", #tbPolygonBorderTiles);

    local c = -1;
    local nSize = #tbPolygonBorderTiles;
    local i = 1;
    while (i <= nSize) do
        c = tbPolygonBorderTiles[i].x;
        local k = i;
        while (k <= nSize and tbPolygonBorderTiles[k].x == c) do
            -- print("222", k, nSize, tbPolygonBorderTiles[k].x, c)
            local tk = tbPolygonBorderTiles[k];
            local nLower = tk.y;
            local nState = tk.state;

            local tk_1 = tk;
            k = k + 1;
            while (k <= nSize and tbPolygonBorderTiles[k].x == c and 
                ((tk_1.y == tbPolygonBorderTiles[k].y - 1) or (nState == TILE_STATE_TYPE.ODD)) ) do
                tk = tbPolygonBorderTiles[k];
                if tk.state == TILE_STATE_TYPE.ODD then
                    nState = not nState;
                end
                tk_1 = tk;
                k = k + 1;
            end

            -- calc range
            local nUpper = tk_1.y;
            local tbOneRange = {{x = c, y = nLower}, {x = c, y = nUpper}};
            table.insert(tbPolygonRange, tbOneRange);
        end

        i = k;
    end

    return tbPolygonRange;
end
