{ ... }:
{
  programs.mise = {
    enable = true;
    enableZshIntegration = true;
    globalConfig = {
      tools = {
        node = "latest";
        "npm:@dataform/cli" = "latest";
      };
    };
  };
}
