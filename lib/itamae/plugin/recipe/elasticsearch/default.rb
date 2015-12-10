if  /\A1.*/ =~ node[:elasticsearch][:version]
  include_recipe 'el_version1'
else
  include_recipe 'el_version2'
end
