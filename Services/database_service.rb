module Database_service
  def self.settings
    {
      host: 'localhost',
      port: 5432,
      dbname: 'postgres',
      user: 'postgres',
      password: 'admin'
    }
  end
end