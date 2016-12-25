struct Float
  def round(precision : Int32)
    x = 10.0 ** precision
    return (self * x).round / x
  end
end
