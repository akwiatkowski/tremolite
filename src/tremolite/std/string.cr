class String
  def to_guid
    "#{self[0,8]}-#{self[8,4]}-#{self[12,4]}-#{self[16,4]}-#{self[20,12]}"
  end
end
