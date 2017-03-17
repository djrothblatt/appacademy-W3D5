class AttrAccessorObject
  def self.my_attr_reader(*symbs)
    symbs.each do |symb|
      define_method(symb) do
        instance_variable_get("@#{symb}")
      end
    end
  end

  def self.my_attr_writer(*symbs)
    symbs.each do |symb|
      define_method("#{symb}=") do |value|
        instance_variable_set("@#{symb}", value)
      end
    end
  end

  def self.my_attr_accessor(*names)
    self.my_attr_reader *names
    self.my_attr_writer *names
  end
end
