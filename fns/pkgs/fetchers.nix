{ pkgs, lib, ... }:

{
  /**
    Fetches a raw file at a given path in a github repo using fetchurl. Path
    should be relative to the repo root.
    Name will be the basenameOf the url if not given.
  */
  fetchRawFileFromGitHub = { owner, repo, rev, path, hash, name ? null }: pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/${owner}/${repo}/${rev}/${lib.escapeURL path}";
    inherit hash name;
  };
}
