{ config, ... }:

{
  # Reroute the mimeapp module's generated mimeapps to secondaryXdg.
  xdg.configFile."mimeapps.list".enable = false;
  xdg.dataFile."applications/mimeapps.list".enable = false;
  modules.xdg.secondaryConfigFile."mimeapps.list".source =
    config.xdg.configFile."mimeapps.list".source;

  xdg.mimeApps =
    let
      textEditors = [ "nvim.desktop" ];
      fileBrowsers = [ "org.kde.dolphin.desktop" ];
      archivers = [ "org.kde.ark.desktop" ];
      imageViewers = [ "qimgv.desktop" "firefox.desktop" ];
      videoViewers = [ "vlc.desktop" "mpv.desktop" "firefox.desktop" ];
      audioViewers = videoViewers;
      pdfViewers = [ "firefox.desktop" "okularApplication_pdf.desktop" ];
    in
    rec {
      enable = true;

      defaultApplications =
        {

          "inode/directory" = fileBrowsers;
          "inode/symlink" = fileBrowsers;

          "text/*" = textEditors; # '*' is a special feature of the HM module
          "application/json" = textEditors;
          "application/yaml" = textEditors;
          "application/xml" = textEditors;
          "application/xhtml+xml" = textEditors;

          "application/zip" = archivers;
          "application/gzip" = archivers;
          "application/x-tar" = archivers;
          "application/vnd.rar" = archivers;
          "application/x-bzip" = archivers;
          "application/x-bzip2" = archivers;
          "application/x-7z-compressed" = archivers;

          "image/jpeg" = imageViewers;
          "image/png" = imageViewers;
          "image/gif" = imageViewers;
          "image/webp" = imageViewers;
          "image/avif" = imageViewers;
          "image/bmp" = imageViewers;
          "image/svg+xml" = imageViewers;

          "video/mp4" = videoViewers;
          "video/matroska" = videoViewers;
          "video/webm" = videoViewers;
          "video/avi" = videoViewers;
          "video/mov" = videoViewers;

          "audio/mp3" = audioViewers;
          "audio/vnd.wave" = audioViewers;
          "audio/ogg" = audioViewers;
          "audio/mp4" = audioViewers;
          "audio/aac" = audioViewers;
          "audio/flac" = audioViewers;
          "audio/x-aiff" = audioViewers;

          "application/pdf" = pdfViewers;
        };

      associations.added =
        let
          prefix = {};
          suffix = {};
          affixedToDefaults =
            builtins.zipAttrsWith (name: values: builtins.concatLists values)
            [ prefix defaultApplications suffix ];
        in
        if prefix != {} || suffix != {} then affixedToDefaults else defaultApplications;

      # Note that there is currently a bug for KService where removed associations are ignored if the file
      # listing them is a symlink https://bugs.kde.org/show_bug.cgi?id=528774
      associations.removed = {
        "application/zip" = "org.prismlauncher.PrismLauncher.desktop";
      };
    };
}
