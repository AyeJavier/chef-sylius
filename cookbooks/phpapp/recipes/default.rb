#
# curl -L https://www.opscode.com/chef/install.sh | bash
#
# Cookbook Name:: phpapp
# Recipe:: default
#
# Copyright 2016, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#



#include_recipe "mysql"
 include_recipe "apache2"
 include_recipe "apache2::default"
# #include_recipe "php"
 include_recipe "apache2::mod_php5"
#recipe[selinux::disabled]
package ["npm"]  do
  action :install
end

package ["git"]  do
  action :install
end

package ["mercurial"]  do
  action :install
end


template ("/etc/hosts") do
 source ("hosts.erb")
 owner "root"
 group "root"
 mode 0644
 variables(
    hosts: '127.0.0.1',
    hostname: node['aplicativo']['nombre'],

 )
end

## template para acceso desde afuera al puerto 80 ##
template ("/etc/sysconfig/iptables") do
 source ("iptables.erb")
 owner "root"
 group "root"
 mode 0600
end

# directory(node[:phpprueba][:app_root])

# web_app("wsj") do
#   server_name("wsj")
#   docroot("/var/wsj/web")

#   template('vhost.conf.erb')
# end


yum_package 'mysql-libs' do
  action :purge
  version "5.1.66-2.el6_3"
end

yum_package 'ca-certificates' do
  action :upgrade
  #options "--disablerepo=epel"
end


cookbook_file '/tmp/mysql57-community-release-el6-8.noarch.rpm' do
  source 'mysql57-community-release-el6-8.noarch.rpm'
  owner 'root'
  group 'root'
  mode '0755'
  not_if { File.exist?("/tmp/mysql57-community-release-el6-8.noarch.rpm") }
  action :create
end

cookbook_file '/tmp/epel-release-6-8.noarch.rpm' do
  source 'epel-release-6-8.noarch.rpm'
  owner 'root'
  group 'root'
  mode '0755'
  not_if { File.exist?("/tmp/epel-release-6-8.noarch.rpm") }
  action :create
end

cookbook_file '/tmp/latest.rpm' do
  source 'latest.rpm'
  owner 'root'
  group 'root'
  mode '0755'
  not_if { File.exist?("/tmp/latest.rpm") }
  action :create
end
cookbook_file '/etc/yum.repos.d/remi.repo' do
  source 'remi.repo'
  owner 'root'
  group 'root'
  mode '0755'
  not_if { File.exist?("/etc/yum.repos.d/remi.repo") }
  action :create
end

execute 'instalando rpm mysql' do
  #command   "npm install -g n && n 0.12.4"
  command  "yum -y localinstall /tmp/mysql57-community-release-el6-8.noarch.rpm"
  user  "root"
  group "root"
  not_if { File.exist?("/etc/yum.repos.d/mysql-community.repo") }
  action  :run
end


execute 'instalando rpm epel' do
  #command   "npm install -g n && n 0.12.4"
  command  "yum -y localinstall /tmp/epel-release-6-8.noarch.rpm"
  user  "root"
  group "root"
  not_if { File.exist?("/etc/yum.repos.d/epel.repo") }
  action  :run
end

execute 'instalando rpm latest' do
  #command   "npm install -g n && n 0.12.4"
  command  "yum -y localinstall /tmp/latest.rpm"
  user  "root"
  group "root"
  #not_if { File.exist?("/etc/yum.repos.d/latest.repo") }
  not_if { File.exist?("/etc/yum.repos.d/webtatic.repo") }
  action  :run
end
pass = node['bd']['clave-acceso']
mysql_service "default" do
  port '3306'
  version '5.7'
  initial_root_password "#{pass}"
  #package_version '5.6.32-1ubuntu14.04'
  #package_version "5.6.31-0ubuntu0.14.04.2"
  #package_version "5.5.50-0ubuntu0.14.04.1"
  action [:create, :start]
end

package "php"  do
  action :install
end
package "php-mysql"  do 
  action :install
end
service "apache2" do
  supports :restart => true
  action :start
  subscribes :reload,"package[php-mysql]" , :immediately
end
service "apache2" do
  supports :restart => true
  action :start
  subscribes :reload,"package[php]" , :immediately	
end
package "php-curl"  do
  action :install
end
service "apache2" do
  supports :restart => true
  action :start
  subscribes :reload,"package[php-curl]" , :immediately
end

package "php-intl"  do
  action :install
end
service "apache2" do
  supports :restart => true
  action :start
  subscribes :reload,"package[php-intl]" , :immediately
end

package "php-gd"  do 
  action :install
end
service "apache2" do
  supports :restart => true
  action :start
  subscribes :reload,"package[php-gd]" , :immediately
end

package "php-xml"  do 
  action :install
end
service "apache2" do
  supports :restart => true
  action :start
  subscribes :reload,"package[php-xml]" , :immediately
end

package "php-mbstring"  do 
  action :install
end
service "apache2" do
  supports :restart => true
  action :start
  subscribes :reload,"package[php-mbstring]" , :immediately
end

package "php-dom"  do 
  action :install
end
service "apache2" do
  supports :restart => true
  action :start
  subscribes :reload,"package[php-dom]" , :immediately
end

package "php-process"  do 
  action :install
end
service "apache2" do
  supports :restart => true
  action :start
  subscribes :reload,"package[php-process]" , :immediately
end

#package ["apache2-utils"]  do
#  action :install
#end

execute 'instalando  composer' do
  #command   "npm install -g n && n 0.12.4"
  command  "cd /tmp &&  php -r \"copy('https://getcomposer.org/installer', 'composer-setup.php');\" && php composer-setup.php && mv /tmp/composer.phar /vagrant/"
  user  "root"
  group "root"
  not_if { File.exist?("/vagrant/composer.phar") }
  action  :run
end
#ver el tamaño por var se seteo
template ("/etc/php.ini") do
 source ("php.erb")
 owner "root"
 group "root"
 mode 0640
end

# #ver el nombreservidor por seteo
# # template ("/etc/httpd/conf/httpd.conf") do
# #  source ("httpd.erb")
# #  owner "root"
# #  group "root"
# #  mode 0640
# # end

nombre_aplicativo = node['aplicativo']['nombre']
template ("/etc/httpd/sites-available/sylius.conf") do
 source ("sylius.erb")
 owner "root"
 group "apache"
 mode 0750
 variables(aplicativo: nombre_aplicativo)
 #verify 'file /var/#{nombre_aplicativo} |grep ": directory" '
end
execute 'enable sylius' do
    command  "cd /etc/httpd/sites-enabled/ &&  ln -s ../sites-available/sylius.conf sylius.conf "
    user  "root"
    #ignore_failure true
    #not_if { File.exist?("etc/apache2/conf-enabled/phpmyadmin.conf") }
    not_if 'file /etc/httpd/sites-enabled/sylius.conf |grep symbolic '
    action  :run
end

execute 'enable variable term' do
    command  "echo 'export TERM=linux' > ~/.bash_profile && source ~/.bash_profile"
    user  "root"
    group "root"
    #ignore_failure true
    #not_if { File.exist?("etc/apache2/conf-enabled/phpmyadmin.conf") }
    #not_if 'file /etc/httpd/sites-enabled/sylius.conf '
    action  :run
end

# hola = node['prueba']['directorio']
# execute 'enable sylius' do
#     command  "cd /tmp && mkdir #{hola}"
#     user  "root"
#     group "root"
#     #ignore_failure true
#     #not_if { File.exist?("etc/apache2/conf-enabled/phpmyadmin.conf") }
#     #not_if 'file /etc/httpd/sites-enabled/sylius.conf '
#     action  :run
# end
execute 'modulo rewrite' do
    command  " a2enmod rewrite "
    user  "root"
    #ignore_failure true
    #not_if { File.exist?("etc/apache2/conf-enabled/phpmyadmin.conf") }
    
    action  :run
end
service "apache2" do
  supports :restart => true
  action :enable
  subscribes :restart,"modulo rewrite" , :immediately
end

package "php-mcrypt"  do 
  action :install
end
# execute 'mcryp' do
#     command  "php5enmod mcrypt "
#     user  "root" 
#     action  :run
# end
# execute 'install mcrypt ' do
#     command  "yum install php-mcrypt"
#     user  "root" 
#     action  :run
# end
package ["phpmyadmin"]  do
  action :install
end
service "apache2" do
  supports :restart => true
  action :enable
  subscribes :restart,"package[phpmyadmin]" , :immediately
end

template ("/usr/share/phpMyAdmin/.htaccess") do
 source (".htaccess.erb")
 owner "root"
 group "root"
 mode 0755
end

cookbook_file '/tmp/create_tables.sql' do
  source 'create_tables.sql'
  owner 'root'
  group 'root'
  mode '0755'
  not_if { File.exist?("/tmp/create_tables.sql") }
  action :create
end
pass = node['bd']['clave-acceso']
execute 'crea bd phpmyadmin  ' do
    command  " mysql -u root -p#{pass} -h 127.0.0.1 < /tmp/create_tables.sql "
    user  "root"
    #ignore_failure true
    #not_if { File.exist?("etc/apache2/conf-enabled/phpmyadmin.conf") }
    action  :run
end
cookbook_file '/tmp/user_pma.sql' do
  source 'user_pma.sql'
  owner 'root'
  group 'root'
  mode '0755'
  not_if { File.exist?("/tmp/user_pma.sql") }
  action :create
end
pass = node['bd']['clave-acceso']
template ("/tmp/user_pma.sql") do
 source ("user_pma.sql.erb")
 owner "root"
 group "root"
 mode 0750
 variables(server: "localhost",clave: pass)
 #verify 'file /var/#{nombre_aplicativo} |grep ": directory" '
end
pass = node['bd']['clave-acceso']
execute 'crea crea usuario pma y accesos a phpmyadmin (BD)' do
    command  " mysql -u root -p#{pass} -h 127.0.0.1 < /tmp/user_pma.sql "
    user  "root"
    #ignore_failure true
    #not_if { File.exist?("etc/apache2/conf-enabled/phpmyadmin.conf") }
    not_if 'mysql -uroot -p#{pass} -h 127.0.0.1 -e"SELECT User FROM mysql.user;" |grep pma'
    action  :run
end
pass = node['bd']['clave-acceso']
template ("/etc/phpMyAdmin/config-db.php") do
 source ("config-db.php.erb")
 owner "root"
 group "apache"
 variables(clave: pass)
 mode 0640
end