let
  desktop = import ./quickshell-theme.nix;
  opaque =
    color: if builtins.stringLength color == 9 then "#${builtins.substring 3 6 color}" else color;
in
{
  background = opaque desktop.background;
  overlay = "#b8141414";
  field = "#e61f222b";
  fieldFocus = "#e62c3040";
  text = desktop.text;
  error = desktop.danger;
  accent = desktop.accent;
  border = desktop.border;
  placeholder = "#777d91";
  selection = "#66ffffff";
}
