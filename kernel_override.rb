module Kernel
  alias_method :old_system, :system
  # TODO: Need to research what the sig of the Kernel#system command is and print out only the appropriate arguments
  def system(*args)
    puts
    puts "~" * 20
    puts "Running: #{args.join.inspect}"
    puts "~" * 20
    old_system(*args)
  end
end
