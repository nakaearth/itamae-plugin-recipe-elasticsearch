node.reverse_merge!(
  elasticsearch: {
    cluster_name: "nakamura-elasticsearch",
    version: "1.7.3",
    index_shards_num: "5",
    index_replicas_num: "1",
    plugin: {
      kuromoji: {
        version: "2.7.0"
      }
    }
  }
)


%w( yum java-1.8.0-openjdk wget ).each do |pkg|
  package pkg do
    action :install
  end
end

execute 'rm elasticsearch.tar.gz' do
  only_if "test -e ~/elaticsearch.tar.gz"
end


execute 'elasticsearch file get' do
  command "wget https://download.elastic.co/elasticsearch/elasticsearch/elasticsearch-#{node[:elasticsearch][:version]}.tar.gz -O elasticsearch.tar.gz"
end

execute 'file unzip' do
  command 'tar -zxf elasticsearch.tar.gz'
end

execute 'sudo rm -R /usr/local/share/elasticsearch' do
  only_if 'ls /usr/local/share/elasticsearch'
end

execute 'sudo mv elasticsearch-* /usr/local/share/elasticsearch' do
  not_if 'ls /usr/local/share/elasticsearch'
end

execute 'sudo chmod -R 755 /usr/local/share/elasticsearch' do
  only_if 'ls /usr/local/share/elasticsearch'
end

execute 'mkdir /usr/local/share/elasticsearch/plugins' do
  not_if 'ls /usr/local/share/elasticsearch/plugins'
end

# elasticsearch.ymlをコピー
template "/usr/local/share/elasticsearch/config/elasticsearch.yml" do
  path "/usr/local/share/elasticsearch/config/elasticsearch.yml" # 任意指定。ここに記載するとブロック引数より優先される。
  source "itamae/plugin/recipe/elasticsearch/config/elasticsearch_yml.erb" #必須指定。
  variables({cluster_name: 'elasticsearch_app', index_shards_num: "5", index_replicas_num: "1"}) # 任意指定。
end

# プラグイン
execute 'bin/plugin --remove mobz/elasticsearch-head' do
  only_if 'cd /usr/local/share/elasticsearch/plugins/head'
  cwd '/usr/local/share/elasticsearch'
end

execute 'bin/plugin -install mobz/elasticsearch-head' do
  cwd '/usr/local/share/elasticsearch'
end

execute 'bin/plugin --remove elasticsearch/marvel/latest' do
  only_if 'cd /usr/local/share/elasticsearch/plugins/mavel'
  cwd '/usr/local/share/elasticsearch'
end

execute 'bin/plugin -install elasticsearch/marvel/latest' do
  cwd '/usr/local/share/elasticsearch'
end

execute "bin/plugin --remove elasticsearch/elasticsearch-analysis-kuromoji/#{node['elasticsearch']['plugin']['kuromoji']['version']}" do
  only_if 'cd /usr/local/share/elasticsearch/plugins/analysis-kuromoji'
  cwd '/usr/local/share/elasticsearch'
end

execute "bin/plugin -install elasticsearch/elasticsearch-analysis-kuromoji/#{node['elasticsearch']['plugin']['kuromoji']['version']}" do
  cwd '/usr/local/share/elasticsearch'
end
