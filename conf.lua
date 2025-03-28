function love.conf(t)
    t.identity = "puzzle-crush"        -- The name of the save directory
    t.version = "11.4"                 -- The LÖVE version this game was made for
    t.console = true                   -- Enable the console for debugging
    
    t.window.title = "Puzzle Crush"    -- The window title
    t.window.icon = nil                -- Filepath to an image to use as the window's icon
    t.window.width = 800              -- The window width
    t.window.height = 600             -- The window height
    t.window.minwidth = 400           -- Minimum window width
    t.window.minheight = 300          -- Minimum window height
    t.window.fullscreen = false       -- Enable fullscreen
    t.window.fullscreentype = "desktop" -- Choose between "desktop" fullscreen or "exclusive" fullscreen
    t.window.vsync = 1                -- Vertical sync mode
    t.window.msaa = 0                 -- The number of samples to use with multi-sampled antialiasing
    t.window.depth = nil              -- The number of bits per sample in the depth buffer
    t.window.stencil = nil            -- The number of bits per sample in the stencil buffer
    t.window.display = 1              -- Index of the monitor to show the window in
    t.window.highdpi = false          -- Enable high-dpi mode for the window on a Retina display
    t.window.usedpiscale = true       -- Enable automatic DPI scaling
    t.window.resizable = true         -- Let the window be user-resizable
    t.window.borderless = false       -- Remove all border visuals from the window
    t.window.centered = true          -- Center the window on screen
    t.window.displayindex = 1         -- Index of the monitor to show the window in
    t.window.x = nil                  -- The x-coordinate of the window's position in the specified display
    t.window.y = nil                  -- The y-coordinate of the window's position in the specified display
end 