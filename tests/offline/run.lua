-- Offline runner (lua5.2). Usage: FV=2.0|2.1 lua5.2 tests/offline/run.lua <file> ["<describe> > <it>"]
-- Exit 0 all pass, 1 any fail or named test not found.
local file, only = arg[1], arg[2]
local tests, current = {}, nil
function describe(name, fn) current = name; fn(); current = nil end
function it(name, fn) tests[#tests + 1] = {name = current .. " > " .. name, fn = fn} end
function eq(got, want, msg)
  if got ~= want then error((msg or "eq") .. ": got " .. tostring(got) .. " want " .. tostring(want), 2) end
end
dofile(file)
local ran, failed = 0, 0
for _, t in ipairs(tests) do
  if not only or t.name == only then
    ran = ran + 1
    local ok, err = pcall(t.fn)
    print((ok and "PASS " or "FAIL ") .. t.name .. (ok and "" or ("\n  " .. tostring(err))))
    if not ok then failed = failed + 1 end
  end
end
if only and ran == 0 then print("NOT FOUND " .. only); os.exit(1) end
print(string.format("%s: %d run, %d failed (FV=%s)", file, ran, failed, os.getenv("FV") or "2.0"))
os.exit(failed == 0 and 0 or 1)
