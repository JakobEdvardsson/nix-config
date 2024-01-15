{
  pkgs,
  config,
  ...
}: {
  programs = {
    firefox = {
      enable = true;
      profiles = {
        jakob = {
          isDefault = true;
          settings = {
            "browser.startup.homepage" = "about:home";
            "browser.aboutConfig.showWarning" = false;
          };
          search.default = "DuckDuckGo";
          extensions = with config.nur.repos.rycee.firefox-addons; [
            ublock-origin
            bitwarden
          ];
          # search = {
          #   default = "DuckDuckGo";
          # };
        };
      };
    };
  };
}
