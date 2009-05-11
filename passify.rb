#!/usr/bin/env ruby

# This simple utility is for quickly adding a new site to your local passenger
# setup. It will:
#   - Create the apache virtual host entry
#   - Add an entry for the site in your hosts file
#   - Tell apache to reload it's config
#
# This utility must be run with sudo or you must have access to all the files it relies on.
# Installation: cd /usr/local/bin && ln -s LOCATION/OF/THIS/FILE passify
# Usage: sudo passify (from within the site's root directory)
# Access: Your site will be available at http://site-directory-name.local

require "fileutils"

# Grab information to be used for the site
site_root   = File.join(FileUtils.pwd, "public")
site_name   = FileUtils.pwd.split(/\//).last.gsub(/_/, "-") + ".local"
config_path = File.join("/etc/apache2/sites-enabled", site_name)

# Error checking
raise "Hosts file is not writable. Got root?" unless File.writable?("/etc/hosts")
raise "Apache is not executable. Got root?" unless File.executable?("/etc/init.d/apache2")

# Setup the apache virtual host config
config_contents = <<-CONF
<VirtualHost *:80>
	ServerName #{site_name}
	DocumentRoot #{site_root}
</VirtualHost>
CONF
File.open(config_path, "w+"){ |f| f.write(config_contents) }

# Setup the hosts file
File.open("/etc/hosts", "a+"){|f| f.write("\n127.0.0.1	#{site_name}") }

# Reload apache conf
system("/etc/init.d/apache2 reload")

