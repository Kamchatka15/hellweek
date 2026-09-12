# Quiet Shore lighting rig

Apply on Lighting + Atmosphere + post before calling the place dressed.

- ClockTime: 20.4
- Brightness: 1.8
- Ambient: 20, 22, 28
- OutdoorAmbient: 40, 48, 62
- ColorShift_Top: 180, 160, 140
- LightingStyle: Realistic (small slice)
- Atmosphere.Density: 0.42
- Atmosphere.Offset: 0.15
- Atmosphere.Haze: 2.5
- Atmosphere.Color: 90, 100, 120
- ColorCorrection.Contrast: 0.12
- ColorCorrection.Saturation: -0.08
- ColorCorrection.TintColor: 220, 230, 240
- Bloom: faint; Wick flame + Gift only
- Wick PointLight: Warm, Brightness 2, Range = Wick radius
- No default Studio lighting

## Applied

The whole rig is data in `server/world.luau` (`lighting = {...}`) and `ContentLoader` applies it at boot — no Studio click, no default lighting. Night: `config.night` tweens Brightness → 0.55 and Atmosphere.Density → 0.6 over 4s. **One property is Studio-UI only:** `Lighting.Technology = Future` cannot be set from a script (verified 2026-09-12: "lacking capability RobloxScript"). Justin sets it once in the Lighting properties panel.
