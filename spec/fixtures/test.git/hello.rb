class Hello
  def initialize(n)
    @n = n.capitalize
  end

  def say
    puts "Hello #{@n}!"
  end
end

Hello.new('world').say
