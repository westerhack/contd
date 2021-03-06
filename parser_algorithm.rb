  def next(input:, priority:)
    res = []
    until arr.empty?
      if (sym.imp) < arr.first.imp
        res << arr.shift
      else
        break
      end
    end
    res
  end

  def priority(input)
    case input
    when :** then 3
    when :*, :/, :% then 2
    when :+, :- then 1
    when :'=' then 0
    else 4
    end

end
  class Object
  def imp
    case self
    when :** then 1
    when :* then 2
    when :+ then 3
    else 0
    end
  end
end

a = [0, :+, 1, :*, 2, :+, 3]
a = [0, :*, 1, :+, 2, :+, 3]

def next_priority(arr, sym)
  res = []
  until arr.empty?
    if (sym.imp) < arr.first.imp
      res << arr.shift
    else
      break
    end
  end
  res
end

p next_priority(a.clone, :+).join(' ')
p next_priority(a.clone, :*).join(' ')
p next_priority(a.clone, :**).join(' ')
p next_priority(a.clone, :/).join(' ')




