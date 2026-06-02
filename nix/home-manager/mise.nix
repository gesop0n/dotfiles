{ ... }:
{
  programs.mise = {
    enable = true;
    enableZshIntegration = true;
    globalConfig = {
      tools = {
        node = "latest";
        "npm:@colbymchenry/codegraph" = "latest";
        "npm:vercel" = "latest";
      };
    };
  };
}
