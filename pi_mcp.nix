{ config, lib, ... }:
{
  options.pi.mcpServers = lib.mkOption {
    type = lib.types.attrsOf (lib.types.attrsOf lib.types.anything);
    default = { };
    description = "MCP server configurations written to Pi's user config";
  };

  config = lib.mkIf (config.pi.mcpServers != { }) {
    home.file.".pi/agent/mcp.json".text = builtins.toJSON {
      mcpServers = config.pi.mcpServers;
    };
  };
}
