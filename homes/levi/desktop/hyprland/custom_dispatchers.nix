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
            if type(returnValue) == "userdata" then
              returnValue = hl.dispatch(returnValue)
            end
            return returnValue
          end
        end
      end

      -- A custom dispatcher that is like `hl.dsp.workspace.change_id` but actively swaps both workspaces,
      -- including between monitors; also accepts a `follow` parameter (defaults true).
      -- If no workspace corresponding to id exists, "swaps" it by interpreting it as an empty workspace and placing that.
      function workspace_swap_id_and_move(params)
        params = tbl_deepclone(params)
        return function()
          local this_workspace = hl.get_workspace(params.workspace)
          if not this_workspace then
            return -- No-op
          end
          local old_id = this_workspace.id
          local old_id_mon = this_workspace.monitor

          local new_id = params.id
          local other_workspace = hl.get_workspace(new_id)
          local new_id_rules = TRACKED_WORKSPACE_RULES[tostring(new_id)]
          local new_id_mon = new_id_rules and new_id_rules.monitor

          -- Temporarily disable persistence on the involved ids to ensure we can free them in the next step
          local old_persistent; if this_workspace.is_persistent then old_persistent = true hl.workspace_rule({ workspace = old_id, persistent = false }) end
          local new_persistent; if other_workspace and other_workspace.is_persistent then new_persistent = true hl.workspace_rule({ workspace = new_id, persistent = false }) end

          -- First swap the ids proper, only then do the moves. That way, for the swapping
          -- logic we can avoid dealing with edge cases where moving workspaces can
          -- recreate or destroy the involved workspaces (e.g. empty ones)
          if not other_workspace then
            hl.dispatch(WS.change_id(params))

            -- this_workspace moves to a non-existing id, so if it was focused we 'leave' an empty one with the old id.
            if this_workspace == this_workspace.monitor.active_workspace then
              hl.dispatch(DIS.focus({ monitor = old_id_mon }))
              hl.dispatch(DIS.focus({ workspace = old_id }))
            end

            -- Now move the workspace to the bound monitor if its new id has one.
            if new_id_mon then
              hl.dispatch(WS.move({ workspace = new_id, monitor = new_id_mon }))
            end
          else
            -- Since both workspaces exist, just move them to each other's monitor
            -- Now, if an involved workspace is also the active workspace of a monitor,
            -- the 'move' dispatcher will change the active one so make sure to restore that.
            hl.dispatch(WS.change_id({ workspace = this_workspace, id = find_free_workspace_id() }))
            hl.dispatch(WS.change_id({ workspace = other_workspace, id = old_id }))
            hl.dispatch(WS.change_id({ workspace = this_workspace, id = new_id }))
            -- NOTE: they have already swapped ids at this point so this_workspace now has new_id
            local old_id_mon = this_workspace.monitor
            local new_id_mon = other_workspace.monitor
            local restore_old_id_mon = this_workspace == this_workspace.monitor.active_workspace
            local restore_new_id_mon = other_workspace == other_workspace.monitor.active_workspace
            hl.dispatch(WS.move({ workspace = old_id, monitor = old_id_mon }))
            hl.dispatch(WS.move({ workspace = new_id, monitor = new_id_mon }))
            -- Restoring new first and then old means the cursor will stay on the same monitor in almost
            -- every case (the exception being when you swap a non-active workspace with an active one,
            -- but I don't care enough to deal with this rare use case for how niche the problem is)
            if restore_new_id_mon then
              hl.dispatch(DIS.focus({ monitor = new_id_mon }))
              hl.dispatch(DIS.focus({ workspace = new_id }))
            end
            if restore_old_id_mon then
              hl.dispatch(DIS.focus({ monitor = old_id_mon }))
              hl.dispatch(DIS.focus({ workspace = old_id }))
            end
          end

          -- Now finally, follow the swapped workspace if `follow` if set
          if params.follow ~= false then
            hl.dispatch(DIS.focus({ workspace = new_id }))
          end

          -- Restore persistence
          if old_persistent then hl.workspace_rule({ workspace = old_id, persistent = true }) end
          if new_persistent then hl.workspace_rule({ workspace = new_id, persistent = true }) end
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
