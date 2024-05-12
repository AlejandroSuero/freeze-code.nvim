Add-Type -AssemblyName System.Windows.Forms; [Windows.Forms.Clipboard]::SetImage($[Syste.Drawing.Image]::FromFile("$args[0]")))
