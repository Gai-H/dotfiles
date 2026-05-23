local chrome = hs.application.get("Google Chrome")

if not chrome then
  return
end

local appElement = hs.axuielement.applicationElement(chrome)

if not appElement then
  return
end

local function attributeValue(element, attribute)
  local ok, value = pcall(function()
    return element:attributeValue(attribute)
  end)

  if ok then
    return value
  end

  return nil
end

local function isTarget(element)
  local description = attributeValue(element, "AXDescription")
  local role = attributeValue(element, "AXRole")

  return role == "AXButton" and (description == "Ask Gemini" or description == "Close Gemini in Chrome")
end

local function childrenFor(element)
  local children = {}

  for _, attribute in ipairs({ "AXChildren", "AXWindows" }) do
    local value = attributeValue(element, attribute)

    if type(value) == "table" then
      for _, child in ipairs(value) do
        table.insert(children, child)
      end
    end
  end

  return children
end

local function findTarget(element, seen, depth)
  if depth > 30 then
    return nil
  end

  if seen[element] then
    return nil
  end

  seen[element] = true

  if isTarget(element) then
    return element
  end

  for _, child in ipairs(childrenFor(element)) do
    local target = findTarget(child, seen, depth + 1)

    if target then
      return target
    end
  end

  return nil
end

local target = findTarget(appElement, {}, 0)

if target then
  pcall(function()
    target:performAction("AXPress")
  end)
end
