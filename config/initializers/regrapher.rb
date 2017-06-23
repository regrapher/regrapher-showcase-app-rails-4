#
# emit metrics on active record events
#
ActiveSupport.on_load(:active_record) do
  before_create do |r|
    Regrapher.client.increment("record.created.#{r.class.table_name}")
    true
  end
  before_destroy do |r|
    Regrapher.client.increment("record.destroyed.#{r.class.table_name}")
    true
  end
  before_update do |r|
    Regrapher.client.increment("record.updated.#{r.class.table_name}")
    true
  end
end

#
# emit metrics on authentication events
#
if defined?(Warden)
  Warden::Manager.after_authentication do |r|
    Regrapher.client.increment("auth.sign_in.#{r.class.table_name}")
  end
  Warden::Manager.before_logout do |r|
    Regrapher.client.increment("auth.sign_out.#{r.class.table_name}")
  end
end

#
# emit metrics on action processing events
#
ActiveSupport::Notifications.subscribe 'process_action.action_controller' do |name, started, finished, unique_id, data|
  next unless data[:status] || data[:exception]

  Regrapher.client.gauge("#{name}.runtime.view", data[:view_runtime].to_f)
  Regrapher.client.gauge("#{name}.runtime.db", data[:db_runtime].to_f)
  Regrapher.client.gauge("#{name}.runtime.total", (finished - started) * 1000.0)

  status = data[:status] || Rack::Utils.status_code(ActionDispatch::ExceptionWrapper.rescue_responses[data[:exception][0]])
  Regrapher.client.increment("#{name}.status.#{status}")
end
