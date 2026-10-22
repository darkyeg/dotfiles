{ ... }:
{
  services.sunshine = {
    enable = true;
    openFirewall = true;
    capSysAdmin = true;
  };

  services.avahi = {
    openFirewall = true;
    # Sunshine's upstream module still supplies the obsolete defaults.
    publish = {
      enable = null;
      userServices = null;
    };
    settings.publish = {
      disable-publishing = false;
      disable-user-service-publishing = false;
      publish-addresses = true;
    };
  };
}
