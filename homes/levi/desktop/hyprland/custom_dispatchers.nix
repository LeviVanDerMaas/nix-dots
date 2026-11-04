{ lib, config, ... }:

let
  cfg = config.modules.hyprland;
in
# NOTE: ALL "custom dispatchers" SHOULD BE FUNCTIONS THAT
#   1. Accept exactly one table with all its parameters
#   2. Keep their own copy of the input parameters.
#   3. Return a function that when called does the actual dispatching
# THIS ALLOWS THEM TO BE USED IN THE SAME WAY AND PLACES THAT BUILT-IN
# HYPRLAND DISPATHCERS ARE, WHICH IS HELPFUL FOR HELPER FUNCTIONS THAT WORK WITH DISPATCHERS.
{
  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland.extraConfig = lib.mkOrder 10 /* lua */ ''
      -- Given a `dispatcher` (or function that accepts a single table), that has `field`
      -- as one of its parameters fields, return a custom dispatcher that accepts the
      -- same parameters fields, but maps the `field` parameter through `map1to10toUniqueIdForMon`.
      -- Consequently, `field` may only be in the range [1, 10].
      -- `Field` defaults to `workspace`. If the passed parameters contain a `monitor` field, that
      -- is taken into consideration for the mapping.
      function dispatcher_map1to10toUniqueIdForMon(dispatcher, field)
        field = field or "workspace"
        return function(params)
          params = tbl_deepclone(params)
          return function()
            local dParams = tbl_deepclone(params)
            dParams[field] = map1to10toUniqueIdForMon(dParams[field], dParams.monitor)
            local returnValue = dispatcher(dParams)
            local returnType = type(returnValue)
            -- A function that mimmicks a dispatcher will return a callable function instead of userdata
            if returnType == "userdata" or returnType == "function" then
              returnValue = hl.dispatch(returnValue)
            end
            return returnValue
          end
        end
      end

      -- Like `hl.dsp.workspace.change_id` but actively swaps both workspaces,
      -- also accepts a `follow` parameter (defaults true).
      function workspace_swap_id_and_move(params)
        params = tbl_deepclone(params)
        return function()
          local wsPrimary = hl.get_workspace(params.workspace)
          if not wsPrimary then
            error("workspace_swap_id_and_move: `workspace` must exist!")
          end
          ---@type string stop diagnostics from bitching
          ---@diagnostic disable-next-line assign-type-mismatch
          local fromId = wsPrimary.id
          local fromMon = wsPrimary.monitor
          local fromWasPersistent = wsPrimary.is_persistent
          local fromMonActiveId = fromMon and fromMon.active_workspace.id
          -- Temporarily enforce existence
          hl.workspace_rule({ workspace = fromId, persistent = true })

          local wsOther = hl.get_workspace(params.id) -- Might not exist yet here
          local targetId = params.id
          local targetWasPersistent = wsOther and wsOther.is_persistent or false
          -- Temporarily enforce existence
          hl.workspace_rule({ workspace = targetId, persistent = true })
          hl.exec_scheduled_prop_refresh_immediately()
          wsOther = hl.get_workspace(targetId) -- Now it def exists
          local targetMon = wsOther.monitor ---@diagnostic disable-line need-check-nil
          local targetMonActiveId = targetMon and targetMon.active_workspace.id

          -- First swap the ids proper, prevents edge cases where moving workspaces
          -- around can destroy them (thus our references would become invalid)
          local tempWsId = find_free_workspace_id()
          hl.dispatch(WS.change_id({ workspace = wsOther, id = tempWsId }))
          hl.dispatch(WS.change_id({ workspace = wsPrimary, id = targetId }))
          hl.dispatch(WS.change_id({ workspace = wsOther, id = fromId }))

          -- Then move them to each other's monitor
          hl.dispatch(WS.move({ workspace = wsPrimary, monitor = targetMon }))
          hl.dispatch(WS.move({ workspace = wsOther, monitor = fromMon }))
          -- restore previously active workspaces on monitors
          if fromMon then fromMon:set_workspace(fromMonActiveId) end
          if targetMon then targetMon:set_workspace(targetMonActiveId) end

          -- Finally, follow if needed
          if params.follow ~= false then
            hl.dispatch(DIS.focus({ workspace = wsPrimary }))
          end

          -- Restore workspace persistence rules
          hl.workspace_rule({ workspace = fromId, persistent = fromWasPersistent})
          hl.workspace_rule({ workspace = targetId, persistent = targetWasPersistent})
        end
      end

      -- Like `workspace_swap_id_and_move` but takes a `monitor` instead of an `id` parameter.
      -- Does nothing if `monitor` is not found.
      function workspace_swap_id_and_monitor(params)
        params = tbl_deepclone(params)
        return function()
          local monitor = hl.get_monitor(params.monitor)
          if not monitor then return end

          local dParams = tbl_deepclone(params)
          dParams.id = monitor.active_workspace.id
          hl.dispatch(workspace_swap_id_and_move(dParams))
        end
      end
    '';
  };
}
