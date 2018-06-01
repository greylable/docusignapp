class Masterlist < ApplicationRecord
  belongs_to :user, required: true
  require 'base64'
  require 'fileutils'

  def self.docu_auth
    host = 'https://demo.docusign.net/restapi'
    integrator_key = ENV["INTEGRATOR_KEY"]
    user_id = ENV["USER_ID_DEMO"]
    expires_in_seconds = 3600 #1 hour
    auth_server = 'account-d.docusign.com'
    # private_key_filename = '/Users/yetlinong/docusignapp/config/demo_private_key.txt'
    @private_key_filename = ENV["PRIVATE_KEY_DEMO"]
    puts ENV["PRIVATE_KEY_DEMO"]
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


  def self.get_doc(selected_envelopes)
    self.docu_auth
    ea = DocuSign_eSign::EnvelopesApi.new(@api_client)

    selected_envelopes.each do |i|
      puts i.envelope_id
      puts i.rental
      puts i.status
      if i.status == "completed"
        file_contents = ea.get_document(account_id='25ec1df6-8160-48a6-9e25-407b8356bbc4', recipient_id="1", envelope_id=i.envelope_id)
        fileName = 'Rental_' + i.rental.to_s + '_Envelope_' + i.envelope_id.to_s
        base64_doc = Base64.encode64(File.open(file_contents, "rb").read).encode('iso-8859-1').force_encoding('utf-8')
        File.open(fileName + '.pdf', "wb") do |f|
          f.write(Base64.decode64(base64_doc))
        end
      end
    end
  end

end