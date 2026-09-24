{
  time.timeZone = "Europe/Amsterdam";

  i18n.defaultLocale = "en_US.UTF-8"; # System Language and default for others LC vars.
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "nl_NL.UTF-8";
    LC_MEASUREMENT = "nl_NL.UTF-8"; # i18n metric, like most other locales
    LC_PAPER = "nl_NL.UTF-8"; # A4 paper, like most other locales
    LC_TELEPHONE = "nl_NL.UTF-8"; # common formatting in Europe

    # Closely resembles Dutch formatting, but English spelling and yyyy-mm-dd
    LC_TIME = "en_DK.UTF-8"; 
    # Same format as nl_NL, but includes no localized titles (none at all in fact).
    LC_NAME = "en_DK.UTF-8";

    # Since we're programmers, I'd like for these to stay in US format.
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
  };
}
