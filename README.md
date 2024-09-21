# AzLink-GMod

[![Latest release](https://img.shields.io/github/v/release/Azuriom/AzLink-GMod?style=flat-square)](https://github.com/Azuriom/AzLink-GMod/releases)
[![Chat](https://img.shields.io/discord/625774284823986183?color=5865f2&label=Discord&logo=discord&logoColor=fff&style=flat-square)](https://azuriom.com/discord)

AzLink-GMod is a [Garry's Mod](https://gmod.facepunch.com/) addon to link a Garry's Mod server with Azuriom.

## Download

You can download the plugin on [Azuriom's website](https://azuriom.com/azlink) or in the [GitHub releases](https://github.com/Azuriom/AzLink-GMod/releases).

## Contributing

This project follows the [CFC Glua Style Guidelines](https://github.com/CFC-Servers/cfc_glua_style_guidelines).

## Dependencies

This addon uses [gmsv_serverstat](https://github.com/WilliamVenner/gmsv_serverstat) as an optional dependency to get
process resources usages.

## Timer

AzLink scheduler is based on Garry's Mod [`timer`](https://wiki.facepunch.com/gmod/timer.Create), whose internals cause it not to advance while the client is timing out from the server or on an empty dedicated server due to hibernation, unless `sv_hibernate_think` is set to `1`.
