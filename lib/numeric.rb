class Numeric
    
  def percent()
      "#{sprintf("%2d", self.to_i)}.#{sprintf("%.2f", self).split(".")[1]}"
  end
  
end
