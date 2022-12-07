Rails.application.config.middleware.insert_before 0, Rack::Cors do
    allow do
        origins ENV['ALLOWED_ORIGIN'] || 'http://localhost:5000'
        resource '*', headers: :any, methods: [:get, :post, :patch, :put]
    end
end