#!/usr/bin/env ruby

# This script is useful to flag existing repositories that need to be backed up; and the reverse process ie resurrecting repo-configurations from backup
# It assumes the following:
#   1. The '.git/config' file ie the repo config file is captured in a backup location and is available during resurrection
#   2. The yaml config conforms to the structure as depicted down below
#   3. Ruby language is present in the system prior to this resurrection being done.

# Note: This script has to be run from the user's home folder - since the yml structure assumes this relative path when creating missing directories

# The input file for this script is a file with this path and name: `<User-home>\.repositories.yml`
# Sample contents of such a file are:
#
# ```
# - folder: dev/oss/git_scripts
#   config_file: ~/Personal/dev/git_scripts.git.config
#   active: true
#   post_clone:
#     - ln -sf ~/Personal/dev/XXX.gradle.properties ~/.gradle/gradle.properties
#     - git-crypt unlock XXX
# ```
#
# 'folder' specifies the target folder where the repo should reside on local machine (relative to where the script is being run from)
# 'config_file' specifies the location/name of the back-up of the git config
# 'branch' (optional; default: 'master') specifies the branch to checkout
# 'active' (optional; default: false) specifies whether to set this folder/repo up or not on local
# 'post_clone' (optional; default: empty array) specifies other bash commands (in sequence) to be run once the resurrection is done - for eg, symlink the '.envrc' file if one exists

class String
  # colorization
  def colorize(color_code)
    "\e[#{color_code}m#{self}\e[0m"
  end

  def red
    colorize(31)
  end

  def green
    colorize(32)
  end

  def yellow
    colorize(33)
  end

  def blue
    colorize(34)
  end

  def pink
    colorize(35)
  end

  def light_blue
    colorize(36)
  end
end

if ARGV.length != 1 || ARGV[0] == '--help' || !['-r', '-c'].include?(ARGV[0])
  puts "This script resurrects or flags for backup all known repositories in the 'dev' folder"
  puts "Usage:".pink + " #{__FILE__} -<r/c>".yellow
  puts "  '-r' resurrects 'known' codebases (usually on fresh laptop)"
  puts "  '-c' captures 'known' codebases (in case of future resurrection on fresh laptop)"
  puts "Environment variables:"
  puts "  FOLDER can be used to apply the operation to a subset of codebases (will match on folder name)"
  exit(0)
end

require 'fileutils'
require 'yaml'

def justify(num)
  num.to_s.rjust(2, ' ')
end

def resurrect(repo, idx, total)
  folder = repo['folder'].strip
  puts "***** Resurrecting [#{justify(idx + 1)} of #{justify(total)}]: #{folder} *****".green
  # Debugging with a different folder name
  # folder.sub!('dev/', 'dev2/')
  FileUtils.mkdir_p(folder)
  Dir.chdir(folder) do
    config_file = repo['config_file']
    branch = repo['branch'] || 'master'
    cmd = "git init . -q \
          && rm .git/config; ln -sf #{config_file} .git/config \
          && git fetch -q --all --tags \
          && git checkout -f -q #{branch} \
          && git config --local core.filemode true"
    system(cmd)
    if repo['post_clone']
      Array(repo['post_clone']).each { |step| system(step) }
      system("git checkout -f -q #{branch}")
    end
  end
end

filter = (ENV['FILTER'] || '').strip
puts "Using filter: " + filter.green
yml_file = File.join(ENV['HOME'], '.repositories.yml')
repositories = YAML.load_file(yml_file)
if ARGV[0] == '-r'
  puts "Running operation: " + "resurrection".green
  repositories = repositories.select{ |repo| repo['active']}
  repositories = repositories.select{ |repo| repo['folder'] =~ /#{filter}/} if filter
  repositories.each_with_index { |repo, idx| resurrect(repo, idx, repositories.length) }
elsif ARGV[0] == '-c'
  puts "Running operation: " + "verification".green
  yml_folders = repositories.map{ |repo| repo['folder']}
  git_folders = Dir.glob('dev/**/.git').each{|r| r.sub!('/.git', '')}
  git_folders = git_folders.select{ |repo| repo =~ /#{filter}/} if filter
  missing_folders = git_folders - yml_folders
  if missing_folders.any?
    puts "Please correlate the following missing projects manually:\n#{missing_folders.join("\n")}".red
    exit(-1)
  else
    puts 'Everything is kosher!'.green
  end
end
