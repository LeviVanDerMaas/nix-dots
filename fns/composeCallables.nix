{ lib, ... }:
  /**
    Call a collection of functions with the attrset
    `extraArgs // { namespace = «result of *this* function»; }`, and compose
    their results into a single attribute set. Since each callable is passed the
    final result of *this* function, every callable has access to every other
    callable in `callables` while called via this function.

    `callables` may be given as: a function that accepts `args`, a path to such a
    function, an attrset of the former two, or a list of any of these. Non-attrset
    MUST return an attrset themselves. Attrsets will have each of their resolved
    values made available under the name cooresponding to that value; additionally,
    if `subAttrsToTop` is `true`, any such resolved value that is an attrset will
    have each of that attrsets attributes made available on `namespace` as well.
  */
  namespace:
  { extraArgs ? {}, subAttrsToTop ? true }:
  callables:
  let
    composedArgs = extraArgs // { ${namespace} = composition; };
    callCallable = c: (if builtins.isFunction c then c else import c) composedArgs;

    filterNonAttrsValuesFromAttrs = lib.filterAttrs (n: c: builtins.isAttrs c);
    resolveAttrCallable = n: c: callCallable c;
    resolveInputCallable =
      input:
      if builtins.isAttrs input then
        let
          # Returns an attrset where each attribute has been resolved.
          r = builtins.mapAttrs resolveAttrCallable input;
        in
        if subAttrsToTop then 
          lib.mergeAttrsList (builtins.attrValues (filterNonAttrsValuesFromAttrs r)) // r
        else
          r
      else
        let
          r = callCallable input;
        in
          # Returns the result of one resolution, which must be an attrset.
          if builtins.isAttrs r then r else abort "Callable is not in attrset, but does not return an attrset either!";

    composition =
      lib.mergeAttrsList (map resolveInputCallable (lib.toList callables));
  in
  composition
