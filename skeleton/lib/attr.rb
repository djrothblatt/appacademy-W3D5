class Class
  def my_attr_reader(*symbs)
    symbs.each do |symb|
      define_method(symb) do
        instance_variable_get("@#{symb}")
      end
    end
  end

  def my_attr_writer(*symbs)
    symbs.each do |symb|
      define_method(symb) do
        instance_variable_set("@#{symb}")
      end
    end
  end

  def my_attr_accessor(*symbs)
    my_attr_reader *symbs
    my_attr_writer *symbs
  end
end
