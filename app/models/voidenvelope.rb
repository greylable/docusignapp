class Voidenvelope < ApplicationRecord
  # has_attached_file :attachment
  belongs_to :user, required: true
  require 'csv'
  require 'docusign_esign'
  require 'uri'

  def self.import(file, user)
    CSV.foreach(file.path, headers:true, encoding: 'iso-8859-1:utf-8') do |row|
      puts row[0]
      Voidenvelope.create(envelope_id: row[0], name: row[1], void_reason: row[2], user: user)
    end
  end

  def self.docu_auth
    host = 'https://eu.docusign.net/restapi'
    integrator_key = ENV["INTEGRATOR_KEY"]
    user_id = ENV["USER_ID_LIVE"]
    expires_in_seconds = 3600 #1 hour
    auth_server = 'account.docusign.com'
    # private_key_filename = '/Users/yetlinong/docusignapp/config/demo_private_key.txt'
    @private_key_filename = ENV["PRIVATE_KEY_LIVE"]
    # puts ENV["PRIVATE_KEY_LIVE"]
    # private_key_filename = ENV["PRIVATE_KEY_DEMO"].to_s.gsub("\\n", "\n")

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

  def self.void(selected_envelopes)
    self.docu_auth
    void_array = []
    ea = DocuSign_eSign::EnvelopesApi.new(@api_client)
    ee = DocuSign_eSign::Envelope.new
    selected_envelopes.each do |env|
      ee.status = 'voided'
      ee.voided_reason = env.void_reason.to_s
      begin
        ea.update(account_id=ENV["ACCOUNT_ID_LIVE"],envelope_id=env.envelope_id,envelope=ee)
        void_array = void_array + [env.id]
      rescue
        next
      end

    end
    return void_array
  end
end