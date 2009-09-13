#!/usr/bin/env ruby

# Andrew Pennebaker
#
# Based on Colin Edwards' UAC Bypass
# http://www.recursivepenguin.com/index.php?projectID=3
#
# == Synopsis
#
# gilgamesh: logs into a Juniper UAC web proxy (GMU by default)
#
# Gilgamesh is better than the Odyssey (client).
#
# == Usage
#
# ./gilgamesh.rb
#
# --config, -c <file>:
#    specify a config file (if not in same directory as uac_bypass)
#
# --no-config, -n [options]
#
# --help, -h:
#    show help

require "getoptlong"
require "rdoc/usage"
require "time"

require "rubygems"
require "mechanize"

# From Philippe Hanrigou's "Reliable Ruby timeouts with System Timer" (http://ph7spot.com/articles/system_timer)
def timeout(sec, exception=Exception)
	return yield if sec==nil or sec.zero?
	raise ThreadError, "timeout within critical session" if Thread.critical
	begin
		x=Thread.current
		y=Thread.start {
			sleep sec
			x.raise exception, "execution expired" if x.alive?
		}
		yield sec
	ensure
		y.kill if y and y.alive?
	end
end

def login(settings)
	begin
		agent=WWW::Mechanize.new
		agent.user_agent_alias=settings["useragent"]
		page=nil

		begin
			timeout(settings["timeout"]) {
				settings["connection"]="wireless"

				page=agent.get(settings["url_wireless"])

				form=page.form_with(:name=>"frmLogin")
				form.field_with(:name=>"username").value=settings["username"]
				form.field_with(:name=>"password").value=settings["password"]
				page=agent.submit(form)

				form=page.form_with(:name=>"frmGrab")
				page=agent.submit(form)

				return page.body.include?(settings["success_wireless"])
			}
		rescue
			begin
				agent=WWW::Mechanize.new
				agent.user_agent_alias=settings["useragent"]

				timeout(settings["timeout"]) {
					settings["connection"]="wired"

					page=agent.get(settings["url"])

					form=page.form_with(:name=>"frmLogin")
					form.field_with(:name=>"username").value=settings["username"]
					form.field_with(:name=>"password").value=settings["password"]
					page=agent.submit(form)

					form=page.form_with(:name=>"frmGrab")
					page=agent.submit(form)

					return page.body.include?(settings["success"])
				}
			rescue
				return false
			end
		end
	# silently ignore
#	rescue
		return false
	end
end

def main
	settings={}
	no_config=false

	opts=GetoptLong.new(
		["--config", "-c", GetoptLong::REQUIRED_ARGUMENT],
		["--no-config", "-n", GetoptLong::NO_ARGUMENT],
		["--help", "-h", GetoptLong::NO_ARGUMENT]
	)

	opts.each { |option, value|
		case option
		when "--help"
			RDoc::usage("Usage")
		when "--config"
			config=value
		when "--no-config"
			no_config=true
		end
	}

	if no_config
		settings={
			"url" => ARGV[0],
			"url_wireless" => ARGV[1],
			"useragent" => ARGV[2],
			"success" => ARGV[3],
			"success_wireless" => ARGV[4],
			"timeout" => ARGV[5].to_i,
			"wait" => ARGV[6].to_i,
			"username" => ARGV[7],
			"password" => ARGV[8]
		}

		if login(settings)
			exit(0)
		else
			exit(1)
		end
	else
		begin
			config="#{File.dirname($0)}/gilgamesh.yaml"

			open(config) { |file|
				settings=YAML::load(file)
			}
		rescue Errno::ENOENT=>e
			raise "Error opening config file #{config}"
		end

		while true
			t=Time.now

			if login(settings)
				puts "Login   #{t}"
			else
				puts "Failure #{t}"
			end

			sleep settings["wait"]
		end
	end
end

if __FILE__==$0
	begin
		main
	rescue RuntimeError=>e
		puts e
	rescue Interrupt=>e
		nil
	end
end