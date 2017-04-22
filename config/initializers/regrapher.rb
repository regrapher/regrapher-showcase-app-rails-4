#
# emit metrics on active record events
#
ActiveSupport.on_load(:active_record) do
  before_create do |r|
    Regrapher.client.increment("record.#{r.model_name.plural}.created")
    true
  end
  before_destroy do |r|
    Regrapher.client.increment("record.#{r.model_name.plural}.destroyed")
    true
  end
  before_update do |r|
    Regrapher.client.increment("record.#{r.model_name.plural}.updated")
    true
  end
end

#
# emit metrics on authentication events
#
Warden::Manager.after_authentication { Regrapher.client.increment('auth.sign_in') }
Warden::Manager.before_logout { Regrapher.client.increment('auth.sign_out') }

#
# emit metrics for action processing events
#
ActiveSupport::Notifications.subscribe 'process_action.action_controller' do |name, started, finished, unique_id, data|
  next unless data[:status] || data[:exception]
  status = data[:status] || Rack::Utils.status_code(ActionDispatch::ExceptionWrapper.rescue_responses[data[:exception][0]])
  Regrapher.client.gauge("#{name}.view_runtime", data[:view_runtime].round(2)) if data[:view_runtime]
  Regrapher.client.gauge("#{name}.db_runtime", data[:db_runtime].round(2)) if data[:db_runtime]
  Regrapher.client.gauge("#{name}.runtime", ((finished - started) * 1000).round(2))
  Regrapher.client.increment("#{name}.status_#{status}")
end
