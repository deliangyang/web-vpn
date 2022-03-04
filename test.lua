

function StripFileName(filename)
    return string.match(filename, "(.+)/[^/]*%.%w+$")  -- *nix system
end

print(StripFileName('/b/c/d/e/f/a.php'))