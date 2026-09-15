--!strict
-- vision.luau — the one switch for the VisionRework look.
--
-- Everything the rework changes checks this and nothing else. `on = false` puts the
-- previous camp, palette, star and needle back exactly, which is how "hide, do not
-- delete" works in a source-built place: the old data is still on disk, it is simply
-- not the data being built.
return { on = true }
