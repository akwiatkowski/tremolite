struct Time
  def at_beginning_of_next_month
    return (self.at_beginning_of_month + 1.month + 10.days).at_beginning_of_month
  end
end
