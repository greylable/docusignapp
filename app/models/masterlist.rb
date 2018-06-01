class Masterlist < ApplicationRecord
  belongs_to :user, required: true

  def self.docu_auth
    host = 'https://demo.docusign.net/restapi'
    integrator_key = ENV["INTEGRATOR_KEY"]
    user_id = ENV["USER_ID_DEMO"]
    expires_in_seconds = 3600 #1 hour
    auth_server = 'account-d.docusign.com'
    @private_key_filename = ENV["PRIVATE_KEY_DEMO"]
    puts ENV["PRIVATE_KEY_DEMO"]

    # STEP 1: Initialize API Client
    configuration = DocuSign_eSign::Configuration.new
    configuration.host = host

    @api_client = DocuSign_eSign::ApiClient.new(configuration)
    @api_client.configure_jwt_authorization_flow(@private_key_filename, auth_server, integrator_key, user_id, expires_in_seconds)

    # STEP 2: Initialize Authentication API using the API Client
    authentication_api = DocuSign_eSign::AuthenticationApi.new(@api_client)


    # STEP 3: Make the login call
    login_options = DocuSign_eSign::LoginOptions.new
    login_information = authentication_api.login(login_options)

    if !login_information.nil?
      login_information.login_accounts.each do |login_account|
        if login_account.is_default == "true"
          # STEP 4: Extract the user information
          base_url = login_account.base_url
          account_id = login_account.account_id

          puts base_url
          puts account_id
          puts "authenticated successfully"

          # IMPORTANT: Use the base url from the login account to update the api client which will be used in future api calls
          base_uri = URI.parse(base_url)
          @api_client.config.host = "%s://%s/restapi" % [base_uri.scheme, base_uri.host]
        end
      end
    end
  end

  def self.testing_only(var_1)
    var_1.each do |f|
      puts f.envelope_id
    end
  end

  def self.refresh_masterlist
    self.docu_auth
    start_date_sf = DateTime.strptime('2018-04-25 19:00:00', "%Y-%m-%d %H:%M:%S") - 15.hours
    end_date_sf = DateTime.strptime('2028-04-24 23:59:59', "%Y-%m-%d %H:%M:%S") - 15.hours
    folders_1 = DocuSign_eSign::FoldersApi.new(@api_client)
    options = DocuSign_eSign::SearchOptions.new
    options.include_recipients = "True"
    options.from_date = start_date_sf
    options.to_date = end_date_sf
    options.count = 100
    # The time is the creation time of the envelope i.e Sent time
    position = -100
    folder_items_contain = []
    while position <= 30000 do
      position = position + 100
      options.start_position = position
      folder_2 = folders_1.search(account_id=ENV["ACCOUNT_ID_DEMO"],search_folder_id="all",options).folder_items
      if folder_2.present?
        folder_items_contain = folder_items_contain + folder_2
      else
        puts 'the end!'
        break
      end
    end
    folder_items_contain.each do |i|

    end
  end
end
