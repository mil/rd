#!/usr/bin/env ruby
require 'securerandom'
require 'trollop'
require 'pp'
require 'yaml'

fp = File.dirname(__FILE__)
$config_file            = "#{fp}/settings.yaml"
$user_styles_directory  = "#{fp}/user_styles"
$user_scripts_directory = "#{fp}/user_scripts"

class Rd
  attr_accessor :configFile
  attr_accessor :stylesDirectory
  attr_accessor :scriptsDirectory

  attr_accessor :tmpDirectory
  attr_accessor :tmpFilehandle
  attr_accessor :tmpScript

  attr_accessor :userStyles
  attr_accessor :userScripts


  def parse_file_config
    config = YAML.load(File.read(@configFile))
    @userStyles = config['user_styles']
    @userScripts = config['user_scripts']
  end
  def parse_cli_options
  end
  def setup_signals
    trap("INT") do
      puts "Control-C Exiting"
      File.delete "#{@tmpDirectory}/#{@tmpFilehandle}"
      File.delete "#{@tmpDirectory}/#{@tmpScript}"
      exit
    end
  end
  def ensure_stdin_piped
    if STDIN.tty?
      puts "No Piped Input Provided" 
      exit
    end
  end
  def ensure_tmp_dir_exists
    # Does not worry about making nested dirs for now
    Dir.mkdir @tmpDirectory if !File.directory?(@tmpDirectory)
  end
  def write_pipe_to_tmp_fh(filehandle)
    content = "<!doctype html><html><body>#{ARGF.read}</body></html>"
    File.open("#{@tmpDirectory}/#{filehandle}", 'w') do |file|
      file.write(content)
    end
  end
  def build_script

    # Onload Assembler
    # > Add Styles Javascripter
    addStylesJs = ""
    Dir["#{@stylesDirectory}/*.css"].each do |style|
      css = File.read(style).gsub("\n", '')
      styleHandle = style.split("/").last.split(".css")[0]
      addStylesJs += 'rd.add_style("' + styleHandle + '", "' + css + '");'
    end
    pp addStylesJs

    # > Pre-enabled JS Modules Calls to rd.activate_script(handle)
    onloadFunction = "\nwindow.onload = function() {"
    @userScripts.each do |script|
      script_handle = script.split(".js")[0]
      onloadFunction += ("rd.activate_script('" + script_handle + "');")
    end 
    onloadFunction += addStylesJs
    @userStyles.each do |style|
      style_handle = style.split(".js")[0]
      onloadFunction += ("rd.activate_style('" + style_handle + "');")
    end
    onloadFunction += "}"


    # JS Modules to Append to End of Template Build
    appendJsModules = ""
    Dir["#{@scriptsDirectory}/*.js"].each do |script|
      appendJsModules += File.read(script)
      appendJsModules += "\n"
    end

    # Assemble Final Content Script
    scriptContent = [
      File.read(@rdBase),
      appendJsModules,
      onloadFunction
    ].join("\n")

    File.open("#{@tmpDirectory}/#{@tmpScript}", 'w') do |file|
      file.write(scriptContent)
    end
  end

  def launch_surf
    switches = {
      "-r" => "#{@tmpDirectory}/#{@tmpScript}",
      "-t" => "#{@tmpDirectory}/#{@tmpStyle}" 
    }.map { |flag, value| "#{flag} '#{value}'" }.join(" ")
    %x[surf #{switches} '#{@tmpDirectory}/#{@tmpFilehandle}']
  end
  

  def initialize
    @tmpDirectory     = "/tmp/rd"
    @configFile       = $config_file
    @scriptsDirectory = $user_scripts_directory
    @stylesDirectory  = $user_styles_directory
    @rdBase           = "#{File.dirname(__FILE__)}/rd_base.js"

    @tmpFilehandle = SecureRandom.uuid
    @tmpScript     = SecureRandom.uuid

    ensure_stdin_piped 
    setup_signals

    # Sets @userStyles & @userScripts
    parse_file_config

    ensure_tmp_dir_exists
    write_pipe_to_tmp_fh(@tmpFilehandle) 

    # Create the script to inject incorporating @userStles & @userScripts
    build_script
    launch_surf
  end 
end

rd = Rd.new
