class Array

  def find()
    i = 0
    found = false
    result = false
    while !found && i < self.size
      found = yield self[i], i
      i += 1
    end

    if found then
      result = self[i - 1]
    end

    result
  end
end