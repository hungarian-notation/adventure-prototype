local path = {}

function path.parse(path) 
  local dirEnd, fnPos, fn, extPos, ext = path:match("()[/]?()([^/.]+()([.]?[^./]*))$")
  return {
    filename  = fn,
    prefix    = path:sub(fnPos, extPos-1),
    extension = path:sub(extPos+1, #path),
    directory = dirEnd > 1 and path:sub(1, dirEnd - 1) or ""
  }
end

function path.filename(path)
	return path.parse(path).filename
end

function path.prefix(path) 
	return path.parse(path).prefix
end

function path.extension(path) 
	return path.parse(path).extension
end

function path.directory(path) 
	return path.parse(path).directory
end

function path.join(left, right) 
  return left .. '/' .. right 
end

return path