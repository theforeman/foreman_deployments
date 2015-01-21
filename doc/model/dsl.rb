require 'foreman/deployments/dsl'

Foreman::Deployments::DSL.define do
  db_stack = stack :db do
    hostgroup :db do
      parameter :db_password
      parameter :db_url, '<%= compute_url() %>'

      puppet_class :postgres do
        override '$postgres::password',
                 "<%= get_parameter('db_password') %>" # pseudo
      end

      host :db, 1..1 do
        puppet_run >> puppet_run
      end
    end
  end

  web_server_stack = stack :web_server do
    hostgroup :web_server do
      parameter :db_password
      parameter :db_url

      puppet_class :sinatra_app do
        override '$sinatra_app::db_password',
                 "<%= get_parameter('db_password') %>" # pseudo
        override '$sinatra_app::db_url',
                 "<%= get_parameter('db_url') %>" # pseudo
      end

      host :db, 1..n do
        puppet_run
      end
    end
  end

  stack :web_app do
    hostgroup :web_app do
      parent_of db_stack.hostgroups[:db]
      parent_of web_server_stack.hostgroups[:web_server]

      parameter :db_password
      connect db_stack.hostgroups[:db].parameter[:db_url],
              web_server_stack.hostgroups[:web_server].param[:db_url]
    end
  end
end

