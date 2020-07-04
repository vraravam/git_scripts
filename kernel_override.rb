module Kernel
  alias_method :old_system, :system
  # TODO: Need to research what the sig of the Kernel#system command is and print out only the appropriate arguments
  def system(*args)
    str = "Running: #{args.join.inspect}"
    puts
    puts "~" * str.length
    puts str
    puts "~" * str.length
    old_system(*args)
  end
end
