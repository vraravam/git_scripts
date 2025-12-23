#!/usr/bin/env ruby

def help
  puts "Usage: #{$0} [-v]"
  puts " -v  Turn on/off the verbose flag (default: off)"
  exit(-1)
end

verbose = ARGV.delete("-v")

require 'open3'
require File.expand_path('./kernel_override', File.dirname(__FILE__)) unless verbose.nil?

local_branches = `git branch -l`.split("\n").each(&:strip!)
current_branch = `git rev-parse --abbrev-ref HEAD`.chomp
(local_branches - ["* #{current_branch}"]).each do |branch|
  system("git checkout #{branch}")
  system("git pull --rebase")
  Open3.popen3("git status") do |i,o,e|
    if o.readlines.include?("nothing to commit (working directory clean)\n")
      system("git checkout #{current_branch}")
      system("git branch -d #{branch}")
    else
      system("git checkout #{current_branch}")
      puts("****** #{branch} could not be deleted due to uncommitted changes")
    end
  end
end
